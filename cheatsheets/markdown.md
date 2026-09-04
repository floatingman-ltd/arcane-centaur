# Markdown

**LocalLeader** = `,`

---

## Navigation (mkdnflow)

| Key | Mode | Action |
|-----|------|--------|
| `Enter` | n | Follow / create link under cursor |
| `Backspace` | n | Go back in link history |
| `Delete` | n | Go forward in link history |
| `Tab` | n | Jump to next link in buffer |
| `S-Tab` | n | Jump to previous link in buffer |
| `]]` | n | Jump to next heading |
| `[[` | n | Jump to previous heading |
| `][` | n | Next heading of the same level |
| `[]` | n | Previous heading of the same level |
| `+` | n, v | Increase heading importance (remove `#`) |
| `-` | n, v | Decrease heading importance (add `#`) |
| `Ctrl-Space` | n, v | Toggle to-do item status |
| `o` | n | New list item below (enter insert mode) |
| `O` | n | New list item above (enter insert mode) |
| `yaa` | n | Yank anchor link to heading under cursor |
| `yfa` | n | Yank file-relative anchor link |

### Table editing (mkdnflow — insert mode)

| Key | Mode | Action |
|-----|------|--------|
| `Tab` | i | Next table cell |
| `S-Tab` | i | Previous table cell |
| `<leader>ir` | n | Insert table row below |
| `<leader>iR` | n | Insert table row above |
| `<leader>ic` | n | Insert table column after |
| `<leader>iC` | n | Insert table column before |
| `<leader>dr` | n | Delete current table row |
| `<leader>dc` | n | Delete current table column |

## Preview

| Key | Action |
|-----|--------|
| `,p` | Toggle preview (console: in-editor popup, GUI: markdown-preview) |
| `,pp` | Toggle rendered Markdown / raw source (popup: `:MarkdownPopup`) |
| `,sp` | Open in markserv Docker server (cross-page links) |

### GFM alerts (`,sp` preview only)

A blockquote whose first line is one of these renders as a titled, coloured panel. The marker itself is not shown.

| Marker | Panel |
|--------|-------|
| `> [!NOTE]` | Blue **Note** |
| `> [!TIP]` | Green **Tip** |
| `> [!IMPORTANT]` | Purple **Important** |
| `> [!WARNING]` | Amber **Warning** |
| `> [!CAUTION]` | Red **Caution** |

For the 22 extra Obsidian markers the in-buffer renderer already shows (`[!EXAMPLE]`, `[!QUESTION]`, `[!TODO]`, ...), start the container with `MD_ALERT_VOCAB=extended` — env var, so a recreate rather than a rebuild. Those extras render locally only, not on GitHub or Confluence.

Body content is ordinary markdown. Rendered by `,sp` only — not by `,pp`, `,p`, `:MarkdownPopup`, or on Confluence. Anything else falls back to a plain blockquote.

## Export

| Key | Action |
|-----|--------|
| `,dp` | Export to PDF with PlantUML diagrams rendered |

---

## MARP Presentations

| Key | Action |
|-----|--------|
| `,mp` | Open slide in preview server |
| `,mx` | Export to PowerPoint (`.pptx`) |
| `,mh` | Export to HTML |
| `,md` | Export to PDF |

---

## Confluence

| Key | Action |
|-----|--------|
| `,cc` | Publish current file to Confluence |
| `,cf` | Pull current Confluence page to local file |
| `,ck` | Fetch Confluence comments to sidecar file |

---

## Jira

| Key | Action |
|-----|--------|
| `,ji` | Create Jira Task issue |
| `,js` | Create Jira Story |
