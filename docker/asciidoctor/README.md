# asciidoctor Docker Wrapper

Converts AsciiDoc files to HTML (and other formats) using the official
[`asciidoctor/docker-asciidoctor`](https://hub.docker.com/r/asciidoctor/docker-asciidoctor)
image. No Ruby or gem installation required.

## First Use

The image (~200 MB) is pulled automatically the first time you run `run.sh` or
use the `,p` preview keymap on a `.adoc` file in Neovim. Subsequent runs use the
cached image and start in under a second.

## Usage

```sh
# Convert a file to HTML in /tmp
./docker/asciidoctor/run.sh myfile.adoc -o /tmp/myfile.html

# Convert to PDF (requires asciidoctor-pdf, included in the image)
./docker/asciidoctor/run.sh -r asciidoctor-pdf -b pdf myfile.adoc

# Check asciidoctor version
./docker/asciidoctor/run.sh --version
```

The script mounts the **current working directory** as `/documents` inside the
container. Paths in your `.adoc` file should be relative to where you run the
script from.

## Neovim Preview

In any `.adoc` buffer, use the same preview keys as Markdown:

| Key  | Action |
|------|--------|
| `,p` | Convert to HTML and open in system browser (GUI only) |
| `,pp`| Same as `,p` |

> **Note:** AsciiDoc preview requires a graphical environment (`$DISPLAY` or
> `$WAYLAND_DISPLAY`). In console/TTY mode, a notification is shown instead.

## Requirements

- Docker installed and daemon running
- `xdg-open` available (standard on GNOME/KDE desktops)
