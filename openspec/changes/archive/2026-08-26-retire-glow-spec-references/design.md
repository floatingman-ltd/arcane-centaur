## Context

`replace-glow-renderer` removed `glow.nvim` and the `glow` binary, replacing them with in-editor rendering via `render-markdown.nvim` and a shared float in `lua/config/cheatsheet.lua`. Two capability specs were left describing the old world in normative text:

```
asciidoc-inbuffer-preview            ide-layout
  Requirement: In-buffer preview       Requirement: Floating UIs unaffected
  coexists with ... the Markdown         "... (Glow previews, which-key hints,
  workflow                                Conjure HUD/eval popups, ...)"
    Scenario: Markdown workflow          Scenario: Popup over the assembled layout
    untouched                              "WHEN a Glow preview or which-key hint
      "... glow.nvim SHALL behave           is triggered ..."
       exactly as before this change"
```

Both were left deliberately: `replace-glow-renderer` task 5.9 judged them and logged them rather than editing them, on the grounds that changing a spec outside a delta is how specs stop reflecting the changes that govern them.

The intent of both requirements survives the plugin's removal. The Docker/Antora preview and the Markdown workflow must still be unaffected by markview; floats must still be unaffected by the IDE layout. Only the examples are stale.

## Goals / Non-Goals

**Goals:**

- Neither spec references a plugin that does not exist.
- The behavioural guarantees both requirements express are preserved unchanged.
- Scenarios remain testable — a scenario whose trigger cannot occur is worse than a vague one, because it looks verifiable and is not.

**Non-Goals:**

- Any runtime change. No Lua, no keymaps, no plugin specs, no documentation.
- The `code-folding` glow reference. It was rewritten by `align-treesitter-providers` into deliberate history recording why treesitter folding was disabled and why that reason lapsed. It is correct and stays.
- Reviewing either capability more broadly. Only the glow-dependent text is in scope.

## Decisions

**D1 — Name the replacement float rather than generalising the wording.**

`ide-layout`'s float list becomes "the markdown preview popup, which-key hints, Conjure HUD/eval popups, cheatsheet popups, Claude CLI scratch window", and its scenario triggers the markdown popup.

- _Why:_ the requirement's value is that it is concrete and testable — someone can open that float and check. Replacing the list with "floating windows generally" would make it unfalsifiable, and an untestable requirement is not much better than a wrong one.
- _Trade-off, worth naming given the circumstances:_ this change exists **because** a named float was replaced. Naming another one accepts that the same edit may be needed again if the markdown popup is ever replaced in turn. That is a real cost, accepted on the grounds that a vague requirement fails silently while a stale one fails loudly — as this one did, by being caught.
- _Alternative rejected — drop the parenthetical list entirely._ Shortest, but the list is what tells a reader which floats were actually considered, and losing it discards information nobody wrote down elsewhere.

**D2 — Replace "exactly as before this change" with the behaviour itself.**

The `asciidoc-inbuffer-preview` scenario says the Markdown workflow shall behave "exactly as before this change". That referred to the change which introduced the requirement; once promoted into the capability spec and that change archived, the phrase has no referent.

- _Why fix it here:_ it is in the same sentence as the glow reference, so leaving it would mean knowingly re-promoting text that cannot be evaluated. The requirement should state what must be true, not defer to a vanished baseline.
- _Note:_ this is a latent problem in any spec written as a delta against a moment in time, not unique to this requirement. Only the instance being touched is fixed here.

## Risks / Trade-offs

- **Naming the markdown popup dates the requirement again.** → Accepted under D1; a stale concrete requirement is discoverable, a vague one is not.
- **Editing promoted specs invites drift.** → Which is why this is a change with deltas rather than a direct edit, exactly as `replace-glow-renderer` task 5.9 argued.
- **Low value, easy to defer indefinitely.** → It is cheap now and the context is fresh; deferred, it becomes archaeology for whoever next reads either spec and wonders what a Glow preview was.

## Migration Plan

1. Delta for `asciidoc-inbuffer-preview`, modifying the coexistence requirement.
2. Delta for `ide-layout`, modifying the floating-UI requirement.
3. `openspec validate --all --strict`.
4. Confirm by grep that no live spec references glow except the `code-folding` history.
5. Remove the item from `recommendations/ideas.md`, including its entry in the priority queue.

**Rollback:** revert the commit; nothing else depends on this.

## Open Questions

None. The one judgement call — naming versus generalising the float — is settled in D1 with its cost stated.
