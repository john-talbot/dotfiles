# Global Instructions

## Test-driven development — use the user-scope skill, not the plugin's

For any TDD work, invoke the **unnamespaced** `test-driven-development` skill:

```
Skill(test-driven-development)
```

Do **NOT** invoke the namespaced plugin form `Skill(superpowers:test-driven-development)`. Both skills exist; the unnamespaced user-scope one at `~/.claude/skills/test-driven-development/SKILL.md` is the authoritative version. The superpowers plugin version is superseded and should be ignored.

If both appear in the available-skills list, always prefer the unnamespaced form.

## Custom skills in general override plugin skills

Whenever a user-scope skill at `~/.claude/skills/<name>/SKILL.md` exists alongside a plugin skill with the same descriptive purpose, prefer the user-scope (unnamespaced) one.
