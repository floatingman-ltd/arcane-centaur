## MODIFIED Requirements

### Requirement: avante is Ollama-only after the upgrade
The upgraded avante SHALL configure the `ollama` provider as the default, with model `qwen2.5:0.5b`, and SHALL NOT configure a `claude` provider. `<leader>aa` SHALL open with the current provider and `<leader>ao` SHALL select ollama and open. When Claude is selected by `config.ai_agent`, ollama SHALL be the only provider and `<leader>ac` SHALL NOT be mapped. When Copilot is selected, a `copilot` provider SHALL also be configured and `<leader>ac` SHALL select it and open avante.

#### Scenario: Ollama keymaps work; claude keymap absent
- **WHEN** the user presses `<leader>aa` or `<leader>ao` on the upgraded avante
- **THEN** avante SHALL open with the current (ollama) provider, and `<leader>ao` SHALL select ollama and open
- **WHEN** Claude is selected and the user presses `<leader>ac`
- **THEN** no avante action SHALL occur (the mapping does not exist)

#### Scenario: Copilot provider on Copilot machines
- **WHEN** Copilot is selected, copilot.vim is authenticated, and the user presses `<leader>ac`
- **THEN** avante SHALL switch to the `copilot` provider and open
- **WHEN** the user then presses `<leader>ao`
- **THEN** avante SHALL switch back to ollama
