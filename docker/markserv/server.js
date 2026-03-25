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
const md = mdIt({ html: true, linkify: true, typographer: true });

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
