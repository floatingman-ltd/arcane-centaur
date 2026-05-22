# Guide: dotnet-fsi — F# Interactive REPL

## Quick start

iron.nvim starts `dotnet fsi --stdin` automatically when you send the
first line/selection in an `.fs` buffer. No manual setup needed.

```
,sl    send current line to REPL   (starts fsi if not running)
,sc    send motion / selection
,sp    send paragraph
,sf    send entire file
```

The REPL pane opens at the bottom of the screen.

---

## Restart the REPL

```
,sq    quit fsi
,sl    send any line to start a fresh session
```

---

## Verify dotnet fsi is available

```sh
dotnet fsi --version
# e.g. Microsoft (R) F# Interactive version 12.x
```

If missing, install the .NET SDK:

```sh
# Ubuntu / Debian
sudo apt install dotnet-sdk-8.0
```

---

> Full guide: `docs/modules/ROOT/pages/guides/fsharp.adoc` or the Antora site.
