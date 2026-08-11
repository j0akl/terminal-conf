# Global instructions

Applies to every repo. Project-level `CLAUDE.md` files add to this; they do not override it.

## Git & GitHub

- **NEVER CREATE GITHUB PR STACKS.** Every PR branches from the default branch and targets it. Do
  not open a PR whose base is another open PR's branch, and do not chain branches to keep moving
  while a dependency is in review. If work genuinely depends on something unmerged, say so and let
  me decide — land the dependency first, or accept the overlap in one PR and explain why.
- **Keep PR descriptions short** — a short paragraph, or four or five bullets. What changed, why,
  anything I need to decide, and how you verified it. That is the whole body. No section headings,
  no file-by-file walkthrough, no summary tables, no test-plan checklists. The diff already says
  what changed; the description says what I cannot read off it. If something genuinely needs more
  room, tell me in chat rather than growing the PR body.
