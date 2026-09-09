## REMOVED Requirements

### Requirement: F# indentation remains unsupported

**Reason**: No longer true. The requirement recorded a gap and stated it "SHALL remain recorded until addressed by a dedicated change"; this is that change. F# indentation is now supplied by a vendored `indentexpr`, so an assertion that it does not work would be actively misleading — and its scenario, which asserts that Enter after `| Circle r ->` merely copies the previous indent, now describes a defect rather than expected behaviour.

**Migration**: Covered by the `fsharp-indent` capability, which owns indentation and deliberately keeps it independent of the language server. The concern this requirement was protecting — that installing a language server should not be read as fixing indentation — is preserved there: `fsharp-indent` requires indentation to work with no server present at all.
