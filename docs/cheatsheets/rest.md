# REST Client Cheatsheet (rest.nvim)

**LocalLeader** = `,` in `.http` buffers

→ Back to [main cheatsheet](index.md)

## Running Requests

| Keys | Mode | Action |
|---|---|---|
| `,r` | Normal | Run request under cursor (`:Rest run`) |
| `,l` | Normal | Re-run last request (`:Rest last`) |
| `,o` | Normal | Open result pane (`:Rest open`) |
| `,e` | Normal | Select environment file (`:Rest env select`) |

## Result Pane Navigation

These keys are active inside the result pane window:

| Keys | Action |
|---|---|
| `H` | Cycle to previous result pane |
| `L` | Cycle to next result pane |

## Commands Reference

| Command | Action |
|---|---|
| `:Rest run` | Run request under cursor |
| `:Rest run {name}` | Run named request |
| `:Rest last` | Re-run last executed request |
| `:Rest open` | Open result pane |
| `:Rest logs` | Edit rest.nvim log file |
| `:Rest cookies` | Edit cookies file |
| `:Rest env show` | Show registered `.env` file |
| `:Rest env select` | Select & register a `.env` file |
| `:Rest env set {path}` | Register a specific `.env` file |

→ [Guide](../guides/rest.md)
