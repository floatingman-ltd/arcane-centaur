'use strict';

// ---------------------------------------------------------------------------
// Markdown preview server — replaces markserv with diagram-aware rendering.
//
// Fenced `plantuml` code blocks are converted to <img> tags whose src points
// at the local PlantUML Docker server (http://localhost:8080).  The browser
// fetches each image directly — the server running here does not proxy it.
//
// Fenced `mermaid` code blocks are emitted as <pre class="mermaid"> elements;
// Mermaid.js loaded from jsDelivr CDN renders them client-side.
//
// Live reload is delivered via Server-Sent Events (SSE) on the same port as
// the HTTP server using the /__livereload endpoint.
// ---------------------------------------------------------------------------

const fs      = require('fs');
const path    = require('path');
const zlib    = require('zlib');
const express      = require('express');
const rateLimit    = require('express-rate-limit');
const mdIt         = require('markdown-it');
// GitHub-flavoured alert blockquotes ([!NOTE], [!TIP], [!IMPORTANT], [!WARNING],
// [!CAUTION]).  The package is ES-module-only, so require() hands back a module
// namespace object rather than the plugin function -- hence `.default`.  The
// fallback arm keeps this working if it ever ships a CommonJS build.  Requiring
// an ES module needs Node >= 20.19; the Dockerfile pins the base image for it.
const mdAlertsMod  = require('markdown-it-github-alerts');
const mdAlerts     = mdAlertsMod.default || mdAlertsMod;
const chokidar = require('chokidar');

// ---------------------------------------------------------------------------
// PlantUML encoding
//
// Matches the scheme used by the plantuml-server HTTP API and by the Pandoc
// filter in docker/md2pdf/plantuml-filter.lua:
//   1. Raw DEFLATE (no zlib header or checksum)
//   2. Base64 with PlantUML's custom 64-character alphabet
// ---------------------------------------------------------------------------
const PUML_ALPHA = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_';
const B64_ALPHA  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function encodePlantUML(source) {
  const compressed = zlib.deflateRawSync(Buffer.from(source, 'utf-8'));
  return compressed.toString('base64').split('').map(c => {
    const i = B64_ALPHA.indexOf(c);
    return i >= 0 ? PUML_ALPHA[i] : ''; // drop '=' padding chars
  }).join('');
}

// ---------------------------------------------------------------------------
// markdown-it setup — override fence renderer for plantuml and mermaid
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Alert vocabulary
//
// MD_ALERT_VOCAB selects how many markers are treated as alerts:
//
//   gfm       (default) the five GitHub markers, and nothing else.  Matches
//             what GitHub itself renders, so a document previewed here looks
//             the way it will look when pushed.
//   extended  the five, plus the twenty-two Obsidian markers that
//             render-markdown.nvim already renders in the buffer.  Makes the
//             two local previews agree, at the cost of showing panels GitHub
//             and Confluence will render as plain blockquotes.
//
// It is an environment variable rather than a build argument so switching is
// `MD_ALERT_VOCAB=extended docker compose up -d` -- a container recreate, with
// no image rebuild.
// ---------------------------------------------------------------------------
const GFM_MARKERS = ['NOTE', 'TIP', 'IMPORTANT', 'WARNING', 'CAUTION'];

// Grouped by the GFM marker each one borrows its colour and icon from.  The
// grouping mirrors render-markdown.nvim's own: it collapses all 27 markers onto
// five highlight groups, so following it keeps the buffer and the browser
// showing the same colour for the same marker.
const OBSIDIAN_MARKERS = {
  note:      ['ABSTRACT', 'SUMMARY', 'TLDR', 'INFO', 'TODO'],
  tip:       ['HINT', 'SUCCESS', 'CHECK', 'DONE'],
  important: ['EXAMPLE'],
  warning:   ['QUESTION', 'HELP', 'FAQ', 'ATTENTION'],
  caution:   ['FAILURE', 'FAIL', 'MISSING', 'DANGER', 'ERROR', 'BUG'],
  quote:     ['QUOTE', 'CITE'],
};

// Default capitalisation of the marker name gets these two wrong.
const ALERT_TITLES = { tldr: 'TL;DR', faq: 'FAQ' };

const EXTENDED = (process.env.MD_ALERT_VOCAB || 'gfm').toLowerCase() === 'extended';

// The plugin keeps its octicons in a module-internal constant it does not
// export, so the only way to give an Obsidian marker the same icon as the GFM
// marker it borrows from is to ask the plugin to render one of each and lift
// the <svg> out of the result.  Harvesting beats hard-coding: copies of ~2.5 KB
// of upstream SVG would drift silently the first time the plugin updates them.
//
// If the plugin's output shape ever changes this yields an empty map, and the
// extended markers render titled but iconless -- degraded, not broken.
function harvestIcons() {
  try {
    const probe = mdIt({ html: true }).use(mdAlerts);
    const source = GFM_MARKERS.map(m => `> [!${m}]\n> x\n`).join('\n');
    const html = probe.render(source);
    const found = {};
    const re = /<div class="markdown-alert markdown-alert-([a-z]+)"[^>]*>\s*<p class="markdown-alert-title">(<svg[\s\S]*?<\/svg>)/g;
    let m;
    while ((m = re.exec(html)) !== null) found[m[1]] = m[2];
    return found;
  } catch {
    return {};
  }
}

function alertOptions() {
  if (!EXTENDED) return undefined; // plugin defaults: the five GFM markers

  const gfmIcons = harvestIcons();
  const markers = [...GFM_MARKERS];
  // The plugin's `icons` option *replaces* its default map rather than merging
  // into it, so the five GFM icons have to be re-supplied here or they vanish
  // the moment any custom icon is given.  Seeding from the harvest does both
  // jobs at once: it keeps the five and provides the source for the borrowed
  // ones below.
  const icons = { ...gfmIcons };

  for (const [borrowFrom, extra] of Object.entries(OBSIDIAN_MARKERS)) {
    for (const marker of extra) {
      markers.push(marker);
      // 'quote' has no GFM counterpart, so it stays iconless by design.
      if (gfmIcons[borrowFrom]) icons[marker.toLowerCase()] = gfmIcons[borrowFrom];
    }
  }

  return { markers, icons, titles: ALERT_TITLES };
}

// Alerts are a blockquote-level construct and do not interact with the fence
// override below; registration sits next to construction to match the file's
// existing shape.  Note the alert titles carry an inline <svg> octicon, which
// only survives because `html: true` is set here.
const md = mdIt({ html: true, linkify: true, typographer: true })
  .use(mdAlerts, alertOptions());

const defaultFence = md.renderer.rules.fence ||
  ((tokens, idx, options, _env, self) => self.renderToken(tokens, idx, options));

md.renderer.rules.fence = function (tokens, idx, options, env, self) {
  const token = tokens[idx];
  const lang  = token.info.trim().toLowerCase();

  if (lang === 'plantuml') {
    const encoded = encodePlantUML(token.content);
    // The browser fetches this URL directly from the PlantUML server running
    // on the host at localhost:8080 — no proxy is needed here.
    return `<p><img src="http://localhost:8080/svg/${encoded}" ` +
      `alt="PlantUML diagram" style="max-width:100%"></p>\n`;
  }

  if (lang === 'mermaid') {
    // Mermaid.js (injected in the page template) renders <pre class="mermaid">
    // blocks client-side.  Escape HTML entities so the raw source is not
    // interpreted as markup before Mermaid gets to it.
    const safe = token.content
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
    return `<pre class="mermaid">${safe}</pre>\n`;
  }

  return defaultFence(tokens, idx, options, env, self);
};

// ---------------------------------------------------------------------------
// HTML page template
// ---------------------------------------------------------------------------
function escapeHtml(str) {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function renderPage(title, bodyHtml, isMarkdown) {
  const mermaidScript = isMarkdown
    ? `  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.esm.min.mjs';
    mermaid.initialize({ startOnLoad: true, theme: 'default' });
  </script>\n`
    : '';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial,
           sans-serif; line-height: 1.6; max-width: 900px; margin: 0 auto;
           padding: 2rem; color: #24292e; }
    h1,h2,h3,h4,h5,h6 { margin-top: 1.5em; margin-bottom: .5em; font-weight: 600;
                         border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
    code { background: rgba(27,31,35,.05); border-radius: 3px;
           padding: .2em .4em; font-size: 85%; font-family: monospace; }
    pre  { background: #f6f8fa; border-radius: 6px; overflow: auto; padding: 16px; }
    pre code { background: none; padding: 0; font-size: 100%; }
    blockquote { border-left: .25em solid #dfe2e5; color: #6a737d; margin: 0; padding: 0 1em; }

    /* GFM alerts.  Inlined from markdown-it-github-alerts'
       styles/github-base.css and styles/github-colors-light.css -- the
       package ships them as files, but this server has no stylesheet and no
       static route, so they travel with the page like every other rule here.
       Both halves are required: the base rules below reference
       var(--color-note) and friends, which only the :root block defines, so
       base-only styling renders grey borders and uncoloured titles.

       Alerts are <div class="markdown-alert">, not <blockquote>, so the
       blockquote rule above deliberately does not apply to them and a
       blockquote that is not an alert is unaffected. */
    :root { --color-note: #0969da; --color-tip: #1a7f37; --color-warning: #9a6700;
            --color-severe: #bc4c00; --color-caution: #d1242f; --color-important: #8250df; }
    .markdown-alert { padding: .5rem 1rem; margin-bottom: 16px; color: inherit;
                      border-left: .25em solid #888; }
    .markdown-alert > :first-child { margin-top: 0; }
    .markdown-alert > :last-child  { margin-bottom: 0; }
    .markdown-alert .markdown-alert-title { display: flex; font-weight: 500;
                                            align-items: center; line-height: 1; }
    .markdown-alert .markdown-alert-title .octicon { margin-right: .5rem;
            display: inline-block; overflow: visible !important;
            vertical-align: text-bottom; fill: currentColor; }
    .markdown-alert.markdown-alert-note      { border-left-color: var(--color-note); }
    .markdown-alert.markdown-alert-note      .markdown-alert-title { color: var(--color-note); }
    .markdown-alert.markdown-alert-tip       { border-left-color: var(--color-tip); }
    .markdown-alert.markdown-alert-tip       .markdown-alert-title { color: var(--color-tip); }
    .markdown-alert.markdown-alert-important { border-left-color: var(--color-important); }
    .markdown-alert.markdown-alert-important .markdown-alert-title { color: var(--color-important); }
    .markdown-alert.markdown-alert-warning   { border-left-color: var(--color-warning); }
    .markdown-alert.markdown-alert-warning   .markdown-alert-title { color: var(--color-warning); }
    .markdown-alert.markdown-alert-caution   { border-left-color: var(--color-caution); }
    .markdown-alert.markdown-alert-caution   .markdown-alert-title { color: var(--color-caution); }

    /* Obsidian markers, active only under MD_ALERT_VOCAB=extended.  Each
       borrows the colour of the GFM marker it is grouped with in server.js,
       following render-markdown.nvim's own 27-onto-5 collapse so the buffer and
       the browser agree.  These rules are inert when the vocabulary is "gfm":
       the classes simply never appear.  'quote' has no GFM counterpart and uses
       the blockquote grey instead. */
    :root { --color-quote: #6a737d; }
    .markdown-alert-abstract, .markdown-alert-summary, .markdown-alert-tldr,
    .markdown-alert-info, .markdown-alert-todo
      { border-left-color: var(--color-note); }
    .markdown-alert-abstract .markdown-alert-title, .markdown-alert-summary .markdown-alert-title,
    .markdown-alert-tldr .markdown-alert-title, .markdown-alert-info .markdown-alert-title,
    .markdown-alert-todo .markdown-alert-title
      { color: var(--color-note); }
    .markdown-alert-hint, .markdown-alert-success, .markdown-alert-check,
    .markdown-alert-done
      { border-left-color: var(--color-tip); }
    .markdown-alert-hint .markdown-alert-title, .markdown-alert-success .markdown-alert-title,
    .markdown-alert-check .markdown-alert-title, .markdown-alert-done .markdown-alert-title
      { color: var(--color-tip); }
    .markdown-alert-example
      { border-left-color: var(--color-important); }
    .markdown-alert-example .markdown-alert-title
      { color: var(--color-important); }
    .markdown-alert-question, .markdown-alert-help, .markdown-alert-faq,
    .markdown-alert-attention
      { border-left-color: var(--color-warning); }
    .markdown-alert-question .markdown-alert-title, .markdown-alert-help .markdown-alert-title,
    .markdown-alert-faq .markdown-alert-title, .markdown-alert-attention .markdown-alert-title
      { color: var(--color-warning); }
    .markdown-alert-failure, .markdown-alert-fail, .markdown-alert-missing,
    .markdown-alert-danger, .markdown-alert-error, .markdown-alert-bug
      { border-left-color: var(--color-caution); }
    .markdown-alert-failure .markdown-alert-title, .markdown-alert-fail .markdown-alert-title,
    .markdown-alert-missing .markdown-alert-title, .markdown-alert-danger .markdown-alert-title,
    .markdown-alert-error .markdown-alert-title, .markdown-alert-bug .markdown-alert-title
      { color: var(--color-caution); }
    .markdown-alert-quote, .markdown-alert-cite
      { border-left-color: var(--color-quote); }
    .markdown-alert-quote .markdown-alert-title, .markdown-alert-cite .markdown-alert-title
      { color: var(--color-quote); }
    table { border-collapse: collapse; width: 100%; }
    table th, table td { border: 1px solid #dfe2e5; padding: 6px 13px; }
    table tr:nth-child(2n) { background: #f6f8fa; }
    img { max-width: 100%; }
    a { color: #0366d6; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .dir-entry { padding: .2em 0; }
  </style>
</head>
<body>
${bodyHtml}
${mermaidScript}<script>
  // Live reload via Server-Sent Events on /__livereload
  (function () {
    var es = new EventSource('/__livereload');
    es.onmessage = function () { location.reload(); };
    es.onerror   = function () { es.close(); setTimeout(function () { location.reload(); }, 2000); };
  })();
</script>
</body>
</html>`;
}

// ---------------------------------------------------------------------------
// Express app
// ---------------------------------------------------------------------------
const app  = express();
const PORT = parseInt(process.env.PORT || '8080', 10);
const HOST = process.env.HOST || '0.0.0.0';
const ROOT = path.resolve(process.env.ROOT || '/docs');

// SSE client set for live reload
const sseClients = new Set();

// Rate limiter — local dev server, allow generous limits while guarding
// against runaway scripts or misconfigured tools hammering the file system.
const limiter = rateLimit({ windowMs: 60 * 1000, max: 300, standardHeaders: true, legacyHeaders: false });
app.use(limiter);

chokidar.watch(ROOT, { ignoreInitial: true }).on('all', () => {
  for (const res of sseClients) {
    res.write('data: reload\n\n');
  }
});

// Server-Sent Events endpoint — browsers connect here once and wait for reload
// messages triggered by file changes in the watched directory.
app.get('/__livereload', (req, res) => {
  res.setHeader('Content-Type',  'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection',    'keep-alive');
  res.flushHeaders();
  const heartbeat = setInterval(() => res.write(': ping\n\n'), 15000);
  sseClients.add(res);
  req.on('close', () => { clearInterval(heartbeat); sseClients.delete(res); });
});

app.get('*', (req, res) => {
  const urlPath  = decodeURIComponent(req.path);
  // Normalise explicitly before comparison to prevent path-traversal attacks
  // (path.normalize collapses any '..' sequences left over from the URL).
  const filePath = path.normalize(path.join(ROOT, urlPath));

  if (!filePath.startsWith(ROOT + path.sep) && filePath !== ROOT) {
    return res.status(403).send('Forbidden');
  }

  if (!fs.existsSync(filePath)) {
    return res.status(404).send('Not found');
  }

  const stat = fs.statSync(filePath);

  // Directory listing
  if (stat.isDirectory()) {
    let entries;
    try { entries = fs.readdirSync(filePath).sort(); } catch { return res.status(500).send('Failed to read directory'); }
    const parentLink = urlPath !== '/'
      ? `<div class="dir-entry"><a href="${escapeHtml(path.posix.dirname(urlPath.replace(/\/$/, '')) + '/')}">..</a></div>`
      : '';
    const links = entries.map(name => {
      let isDir = false;
      try { isDir = fs.statSync(path.join(filePath, name)).isDirectory(); } catch { /* skip */ }
      const href = escapeHtml(path.posix.join(urlPath, name) + (isDir ? '/' : ''));
      return `<div class="dir-entry"><a href="${href}">${escapeHtml(name)}${isDir ? '/' : ''}</a></div>`;
    });
    const body = `<h1>Index of ${escapeHtml(urlPath)}</h1>\n${parentLink}\n${links.join('\n')}`;
    return res.send(renderPage(urlPath, body, false));
  }

  // Markdown → render to HTML with diagram support
  if (/\.md$/i.test(filePath)) {
    let source;
    try { source = fs.readFileSync(filePath, 'utf-8'); } catch { return res.status(500).send('Failed to read markdown file'); }
    const body = md.render(source);
    return res.send(renderPage(path.basename(filePath), body, true));
  }

  // All other files — serve as-is
  res.sendFile(filePath);
});

app.listen(PORT, HOST, () => {
  process.stdout.write(`Markdown preview server listening on http://${HOST}:${PORT}\n`);
  process.stdout.write(`Serving files from: ${ROOT}\n`);
  process.stdout.write('PlantUML: http://localhost:8080 (requires plantuml-server Docker container)\n');
  process.stdout.write('Mermaid:  rendered client-side via jsDelivr CDN\n');
});
