## MODIFIED Requirements

### Requirement: Skill is invocable as add-learning-lesson
The repository SHALL contain a skill at `.claude/skills/add-learning-lesson/SKILL.md` that is loadable by Claude Code and invocable as the `/add-learning-lesson` slash command.

#### Scenario: Skill loads successfully
- **WHEN** a user invokes the `add-learning-lesson` skill (e.g. `/add-learning-lesson`)
- **THEN** the skill context is injected and the agent follows its workflow
