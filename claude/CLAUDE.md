# Global instructions

Applies to every repo. Project-level `CLAUDE.md` files add to this; they do not override it.

## Git & GitHub

- **NEVER CREATE GITHUB PR STACKS.** Every PR branches from the default branch and targets it. Do
  not open a PR whose base is another open PR's branch, and do not chain branches to keep moving
  while a dependency is in review. If work genuinely depends on something unmerged, say so and let
  me decide — land the dependency first, or accept the overlap in one PR and explain why
- **Keep PR descriptions short** — a short paragraph, or four or five bullets. What changed, why,
  anything I need to decide, and how you verified it. That is the whole body. No section headings,
  no file-by-file walkthrough, no summary tables, no test-plan checklists. The diff already says
  what changed; the description says what I cannot read off it. If something genuinely needs more
  room, tell me in chat rather than growing the PR body
- Don't respond to comments on PRs without asking, prefer not to do it at all. Applies to both
  human comments and agent review comments.

## Writing

Applies everywhere you produce words: chat, code comments, commit messages, PR bodies, docs.

- Use this standard for your chat replies: **AST-STE100 Simplified Technical English** (**STE**). 
  Also consider ELI18 and TLDR. Apart from that: silence is gold. Your responses should be easy
  to read and understand
- Always use American English spellings of words
  - enroll instead of enrol
- **Talk like a human. No AI-isms.** Say the thing and stop. Skip the preamble, skip restating my
  question back to me
- **Do not write the "does A, not B" contrast.** A comment reading `// resolves the token; it does
  not verify it, which was decided against` is just `// resolves the token`. Drop the road not
  taken, the reassurance, and the list of things the code is not. Same in chat: state what is true,
  not the alternatives you ruled out
- No fluff — no throat-clearing openers, no "great catch", no three adjectives where one works, no
  caveat that does not change what I do next
- Keep code comments to a minimum. Only explain what's absolutely necessary, no fluff

## Editing

Applies to code and docs edits

- Make the smallest edit possible to solve the problem well and completely. Simplicity is often 
  better than complexity
- Ensure you write complete solutions in code. When decisions are required ask of course, but
  when a problem is presented your goal should be to solve that problem satisfactorily
- Update docs without asking - if there's a document relevant to a change you're making,
  default to making the update that makes sense
  - This applies to tickets in linear too, if a ticket is done close it and say you closed it.
    If you're adding a comment, just add it and mention you did it
  - However, if you're opening a ticket, ask first with a short description


