---
name: handoff
description: Prepare a concise, self-contained state packet so a fresh coding agent can continue the current task. Use when the user invokes $handoff or asks to hand off, transfer, preserve, summarize, or resume work in a new agent or context window.
---

# Handoff

Create a continuation packet from the current conversation, workspace, and external state.

## Gather state

1. Read the applicable repository instruction files.
2. Use read-only checks to confirm the current branch, working tree, changed files, and relevant diff. Inspect active commands or external state when they matter.
3. Separate verified facts from assumptions. Preserve user decisions, approval boundaries, and rejected approaches that could otherwise be repeated.
4. Include only details needed to continue. Reference files, symbols, commands, tickets, and URLs instead of copying large logs or source blocks.
5. Redact secrets, credentials, tokens, PHI, personal data, and sensitive record contents. Point to the authorized source when the next agent must retrieve protected data.

Do not edit files, commit, push, post messages, or change external state while preparing the handoff unless the user explicitly asks.

## Output

Return only a Markdown handoff with these sections. Omit empty optional details, but keep every heading.

```markdown
# Handoff

## Objective
State the requested outcome and completion criteria.

## Constraints
List scope limits, repository rules, user decisions, and required approvals.

## Current state
- Repository and branch
- Ticket or issue
- Changed and untracked files
- Active processes, sessions, deployments, or external state

## Completed
List established findings and completed work with precise references.

## Decisions
Record important choices and short reasons.

## Verification
List commands or checks run and their exact outcomes. State what remains unverified.

## Remaining
Give an ordered, concrete task list.

## Risks or blockers
Record failures, uncertainties, dependencies, and rejected approaches worth preserving.

## Start here
Give the exact first file, symbol, command, or URL to inspect, followed by the immediate next action.
```

Keep the packet short enough to paste into a fresh agent. Make it self-contained. Tell the next agent to verify the packet against the workspace before editing.
