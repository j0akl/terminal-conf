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
- Use this standard for your chat replies: **AST-STE100 Simplified Technical English** (**STE**). 
  Also consider ELI18 and TLDR. Apart from that: silence is gold. Your responses should be easy
  to read and understand
- Always use American English spellings of words

## Writing

Applies everywhere you produce words: chat, code comments, commit messages, PR bodies, docs.

- **Talk like a human. No AI-isms.** Say the thing and stop. Skip the preamble, skip restating my
  question back to me, skip the closing summary of what you just did
- **Do not write the "does A, not B" contrast.** A comment reading `// resolves the token; it does
  not verify it, which was decided against` is just `// resolves the token`. Drop the road not
  taken, the reassurance, and the list of things the code is not. Same in chat: state what is true,
  not the alternatives you ruled out
- No fluff — no throat-clearing openers, no "great catch", no three adjectives where one works, no
  caveat that does not change what I do next
