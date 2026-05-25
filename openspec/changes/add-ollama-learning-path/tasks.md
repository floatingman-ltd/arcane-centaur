## 1. Series index page

- [ ] 1.1 Create `docs/modules/ROOT/pages/learning/ollama/index.adoc` — lesson table with xref links to all seven core lessons and a stubbed Deep-Dives section

## 2. Lesson 01 — Setup & Verification

- [ ] 2.1 Create `docs/modules/ROOT/pages/learning/ollama/01-setup.adoc` — prerequisites checklist, start Docker service, health check (`curl 127.0.0.1:11434`), RAM-based model decision, pull model, verify model list, Avante smoke test, troubleshooting section; nav bar: Index + Next only

## 3. Lesson 02 — First Conversations

- [ ] 3.1 Create `docs/modules/ROOT/pages/learning/ollama/02-first-conversations.adoc` — opening Avante (`<leader>ao`/`ac`/`aa`), the buffer layout, sending messages, conversation history, switching providers mid-session; nav bar pointing to 01 and 03

## 4. Lesson 03 — Prompting Fundamentals

- [ ] 4.1 Create `docs/modules/ROOT/pages/learning/ollama/03-prompting-fundamentals.adoc` — why prompt quality matters, specificity, providing context, role-setting, before/after prompt examples using real config code; nav bar pointing to 02 and 04

## 5. Lesson 04 — Code Assistance Workflow

- [ ] 5.1 Create `docs/modules/ROOT/pages/learning/ollama/04-code-assistance.adoc` — visual selection → Avante ask, explain this code, review this code, suggest a refactor; exercises using actual files from this config; nav bar pointing to 03 and 05

## 6. Lesson 05 — Model Selection

- [ ] 6.1 Create `docs/modules/ROOT/pages/learning/ollama/05-model-selection.adoc` — RAM/speed/quality tradeoff table, `llama3.1:8b` vs `llama3.2:3b`, how to pull a different model, how to update `model =` in `avante.lua`, pointer to future deep-dives (08+); nav bar pointing to 04 and 06

## 7. Lesson 06 — System Prompts & Context

- [ ] 7.1 Create `docs/modules/ROOT/pages/learning/ollama/06-system-prompts.adoc` — what a system prompt does, context window limits, structuring multi-turn conversations, how to set a system prompt in Avante; nav bar pointing to 05 and 07

## 8. Lesson 07 — The Ollama API

- [ ] 8.1 Create `docs/modules/ROOT/pages/learning/ollama/07-the-api.adoc` — Ollama HTTP API, `curl` generate and chat endpoints, streaming responses, what Avante sends under the hood, scripting possibilities; nav bar pointing to 06, index only (no Next)

## 9. Navigation

- [ ] 9.1 Update `docs/modules/ROOT/nav.adoc` — add Ollama series index and lessons 01–07 under the Learning section, following the Janet pattern
- [ ] 9.2 Verify all xref links in new `.adoc` files resolve
- [ ] 9.3 Run Antora build and confirm build succeeds and new pages render
