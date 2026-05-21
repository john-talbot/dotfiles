# Global Instructions

## Canonical TDD skills

The authoritative copies of `test-driven-development`, `writing-good-tests`, and `testing-boundaries` live in the dotfiles repo at `~/.dotfiles/dot-claude/skills/<name>/SKILL.md`, stowed into `~/.claude/skills/<name>/`. Edit them in the dotfiles repo. Projects that need these skills check real copies into their own `.claude/skills/` directory (so teammates and VMs pick them up without depending on the host's `~/.claude/`).

When a project ships its own `.claude/skills/test-driven-development/SKILL.md`, that copy shadows the global one — intentional, so the version that ran for that work is captured in the repo. If you edit the global, sync into projects that depend on it; if you edit a project copy, mirror back into the dotfiles. The copies will drift otherwise.

## Custom skills override plugin skills

If a plugin ships a skill with the same descriptive purpose as one in `~/.claude/skills/` or a project's `.claude/skills/`, always prefer the user/project copy. Invoke by its unnamespaced name.
