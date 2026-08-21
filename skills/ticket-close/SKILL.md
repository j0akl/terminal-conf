---
name: ticket-close
description: Close a Linear ticket across the relevant repositories by orchestrating focused context research, reproduction, fix planning, implementation, and independent reviews. Keep each change inside the ticket bounds, land independent PRs from origin/main, and update Linear from verified evidence. Use when asked to investigate, work, fix, resolve, or close a Linear ticket such as KEY-123.
---

# Close a Linear ticket

Close one ticket with the smallest correct change and an honest state update.
The main agent is the orchestrator. Give each subagent only the ticket facts,
evidence, repository context, and prior-stage conclusions needed for its task.
Subagents return concise evidence packets that the main agent curates for later
stages.

## Agent roles

Use the native role name for the active agent system.

| Task | Claude Code agent | Claude model | Codex agent | Codex model |
| --- | --- | --- | --- | --- |
| Related Linear context | `ticket-linear-context` | Sonnet, medium effort | `ticket_linear_context` | GPT-5.6 Terra, medium reasoning |
| Slack context | `ticket-slack-context` | Sonnet, medium effort | `ticket_slack_context` | GPT-5.6 Terra, medium reasoning |
| Notion context | `ticket-notion-context` | Sonnet, medium effort | `ticket_notion_context` | GPT-5.6 Terra, medium reasoning |
| Granola context | `ticket-granola-context` | Sonnet, medium effort | `ticket_granola_context` | GPT-5.6 Terra, medium reasoning |
| Reproduce the issue | `ticket-reproducer` | Opus, high effort | `ticket_reproducer` | GPT-5.6 Sol, high reasoning |
| Propose the fix | `ticket-fix-planner` | Opus, high effort | `ticket_fix_planner` | GPT-5.6 Sol, high reasoning |
| Implement the accepted fix | `ticket-implementer` | Opus, high effort | `ticket_implementer` | GPT-5.6 Sol, high reasoning |
| Security review | `ticket-security-reviewer` | Opus, high effort | `ticket_security_reviewer` | GPT-5.6 Sol, xhigh reasoning |
| Code review | `ticket-code-reviewer` | Opus, high effort | `ticket_code_reviewer` | GPT-5.6 Sol, xhigh reasoning |
| HIPAA review | `ticket-hipaa-reviewer` | Opus, high effort | `ticket_hipaa_reviewer` | GPT-5.6 Sol, xhigh reasoning |

If a required role is unavailable, use a fresh general-purpose subagent with the
matching role instructions from `references/agents/`. Record the fallback in the
final report.

## 1. Read and bound the ticket

The main agent reads the specified Linear ticket, including its comments and
relations. Establish:

- the claim and why it matters;
- the closing condition and the environment where it must hold;
- blockers, dependencies, duplicates, and prior decisions;
- the repository or repositories that own the change;
- any merge, deployment, migration, or live-verification step required after the
  code changes.

Stop for direction when ownership is ambiguous, a blocker prevents useful work,
or the ticket contains materially different changes that need separate scope.

## 2. Select the execution tier

Use the tier requested by the user. Otherwise, select **Standard** after reading
the ticket and state the choice with one sentence of rationale before starting
substantial work.

| Tier | Use when | Context research | Delivery agents | Independent review |
| --- | --- | --- | --- | --- |
| **Fast** | The closing condition is clear and the change is small, isolated, and low risk. Typical examples are documentation, tests, copy, and straightforward defects. | Skip context agents unless the ticket links to a source needed to understand the work. | Reproducer, main-agent fix proposal, implementer. | Code reviewer. Add security or HIPAA review when the repository or diff has that surface. |
| **Standard** | Normal feature and defect work with clear ownership in one repository. This is the default. | Run the Linear context agent. Run Slack, Notion, and Granola agents when the ticket, product area, ambiguity, or known prior decisions make that source relevant. Run selected agents concurrently. | Reproducer, fix planner, implementer. | Code reviewer. Add security or HIPAA review when the repository or diff has that surface. |
| **Full** | The work is ambiguous, high impact, sensitive, cross-repository, or difficult to reverse. | Run all four context agents concurrently. | Reproducer, fix planner, implementer. | Security, code, and HIPAA reviewers concurrently. Use fresh relevant reviewers after approved corrections. |

Use the Full tier for PHI or clinical behavior; patient identity; authentication
or authorization; security boundaries; secrets; encryption; logging; data
retention; infrastructure; migrations; deployments; irreversible operations;
multiple repositories or teams; production incidents; substantial customer
impact; conflicting requirements; missing acceptance criteria; prior failed
fixes; or material uncertainty after initial investigation.

Increase the tier when later evidence exposes greater risk, ambiguity, or scope.
State the increase and its reason. If it materially changes cost, scope, or an
accepted implementation, take it to the user before continuing. When a
user-requested lower tier would omit a necessary safeguard, explain the conflict
and wait for direction.

Tier selection controls which agents run. It does not change their assigned
models. Every tier still requires ticket bounds, an `origin/main` worktree,
reproduction before editing, a minimal implementation, focused verification,
independent code review, an orchestrator requirements check, honest delivery and
Linear state, review-finding approval, and the no-PR-stacks rule.

## 3. Start from `origin/main`

Unless the user instructs otherwise, fetch `origin/main` and create a dedicated
ticket-named worktree and branch from that exact ref. Prefer Linear's
`gitBranchName`. Confirm the worktree, branch, base SHA, and ancestry before any
edit. Preserve dirty and active worktrees.

For a multi-repository ticket, create one independent worktree and branch per
repository. Each later PR targets that repository's `main`; never create a PR
stack.

Read the applicable repository instructions inside each worktree. Record its
build, test, generated-artifact, security, deployment, commit, and PR rules for
the downstream agents.

## 4. Collect context in parallel

Run the context research required by the selected tier:

- **Fast:** skip context agents unless the ticket links to a source needed to
  understand the work or closing condition.
- **Standard:** run `ticket-linear-context`. Run the other context agents when
  the ticket, product area, ambiguity, or known prior decisions make their
  source relevant.
- **Full:** run all four context agents.

Run selected context agents concurrently:

1. `ticket-linear-context`: inspect related Linear tickets, comments, projects,
   blockers, duplicates, and prior work.
2. `ticket-slack-context`: find relevant Slack decisions and incident context.
   Search the ticket ID and title, then broader product, component, symptom,
   customer-impact, and participant terms because Slack may omit the ticket ID.
3. `ticket-notion-context`: find relevant PINTs, RFCs, specifications, decisions,
   and project documentation. Search broadly enough to find documents that omit
   the ticket ID.
4. `ticket-granola-context`: find relevant meeting notes and transcripts in
   Granola. Search the ticket ID and title, then broader product, component,
   symptom, decision, and participant terms because meeting notes may omit the
   ticket ID.

Give each selected agent the primary ticket facts and a narrow search brief.
These agents are read-only. They must return material facts, decisions,
contradictions, blockers, source links or identifiers, dates when relevant, and
remaining uncertainty. They must not post, comment, edit, or resolve anything.

If a source is unavailable, record the gap. Ask the user only when the missing
context could change the fix or its authorization.

The main agent combines the selected reports into a short evidence packet.
Preserve source links and exact decisions. Remove repeated history and details
unrelated to the ticket's closing condition.

## 5. Reproduce before planning

Spawn `ticket-reproducer` with:

- the ticket claim and closing condition;
- the curated evidence collected for the selected tier;
- the worktree paths and base SHAs;
- relevant repository instructions and known commands.

The reproducer works read-only. It verifies the current behavior first-hand and
returns the exact commands, files, lines, environment, and observed results. It
also states whether the ticket is current, stale, already fixed, invalid, or only
partly reproducible.

When the issue does not reproduce, do not manufacture a diff. Use the evidence
to propose the accurate Linear state and comment, then stop unless the user asks
for further investigation.

## 6. Propose the smallest correct fix

For Fast tickets, the main agent proposes the straightforward fix from the
reproduction report. For Standard and Full tickets, spawn `ticket-fix-planner`
with the reproduction report and only the source context that affects the
solution. The planner stays read-only and returns:

- the corrected problem statement and closing condition;
- the smallest correct implementation;
- exact files and committed artifacts expected to change;
- tests and verification that will prove the fix;
- security, privacy, deployment, and migration implications;
- explicit out-of-scope findings;
- any choice that requires the user.

The main agent checks the proposal against the ticket and repository rules, then
presents it to the user. Wait for acceptance before editing unless the user
already specified the approach or explicitly asked the agent to proceed without
that checkpoint.

## 7. Implement the accepted proposal

Spawn `ticket-implementer` with the accepted proposal, worktree path, relevant
reproduction evidence, repository rules, and exact scope. The implementer makes
the minimal complete change, updates affected tests and documentation, regenerates
required committed artifacts, and runs focused checks while iterating.

The implementer stops and reports when the accepted fix requires another file,
repository, dependency, migration, trust-boundary change, or live side effect
that was not in the proposal. The main agent takes that divergence back to the
user before work continues.

## 8. Review independently

After implementation and focused checks, always spawn the read-only
`ticket-code-reviewer`. For Fast and Standard tickets, also spawn the security
reviewer when the repository or diff touches trust boundaries, authentication,
authorization, inputs, secrets, dependencies, infrastructure, networking,
storage, or logging. Spawn the HIPAA reviewer when the repository or diff
touches patient or health data, patient identity, access, storage, transmission,
logging, third-party handling, or patient isolation. For Full tickets, spawn all
three reviewers concurrently against the same final diff and base:

1. `ticket-security-reviewer` for exploitable defects, trust-boundary changes,
   secrets, authentication, authorization, injection, and unsafe dependencies or
   infrastructure.
2. `ticket-code-reviewer` for correctness, regressions, incomplete behavior,
   missing tests, unrelated changes, and repository convention violations.
3. `ticket-hipaa-reviewer` for PHI storage, transmission, logging, access,
   third-party handling, and patient isolation.

Give each reviewer only:

- the worktree path and exact base SHA;
- the final diff, or the exact command that produces it;
- applicable repository review rules;
- its review lens from `references/agents/`.

Do not give reviewers the ticket claim or closing condition, source-context
reports, reproduction report, accepted proposal, implementation explanation,
approved scope, or verification results. Reviewers start from the diff and may
inspect directly supporting repository code or run read-only checks to validate
a finding. They report only actionable findings with evidence and severity.
They do not edit the worktree.

While the reviewers run, the main agent independently checks the final
implementation and verification against the ticket closing condition. Keep this
requirements check separate from defect review. Surface any confirmed
requirements gap with the review findings.

### Optional review-finding correction

When any reviewer reports a confirmed finding, or the main agent finds a
confirmed requirements gap, the main agent first presents it to the user with
severity, evidence, effect on the ticket, and the smallest proposed correction.
Group findings that share one correction. Identify findings that would expand
the accepted scope.

Wait for the user's approval before changing the implementation. After approval,
send the approved findings and correction scope to `ticket-implementer`, rerun
affected checks, and give the new final diff to fresh instances of the relevant
reviewers. Keep the repeated review blind to the earlier findings and correction
rationale. Leave declined findings unchanged and record the user's decision for
the PR, Linear update, and final report when it affects delivery or residual
risk.

Resolve conflicting review advice against the ticket, repository rules, and user
decisions. Ask the user when the conflict changes scope or risk.

## 9. Verify and land

Run the repository's full required gates after review corrections. Record exact
commands and results. Keep skipped, failed, blocked, and sandbox-limited checks
explicit.

Before committing, confirm that every changed file supports the closing
condition. Move unrelated findings into proposed follow-up tickets. Ask the user
before creating any new ticket.

Use the repository's commit convention. Open one ready PR per repository from
the ticket branch to `main`. Keep every PR independent. Use a short PR body: a
short paragraph or four or five bullets covering the defect, the change, relevant
scope boundaries, and verification. Wait for required CI and review state.

Do not reply to or resolve PR comments unless the user asks. Perform deployment,
migration, production mutation, or live-data verification only with the required
authorization. Keep merge, deployment, publication, and live behavior as separate
verified states.

## 10. Update Linear honestly

Add a concise ticket comment with:

- worktree branches, commit SHAs, and PR links;
- what changed and where;
- tests and independent review results;
- evidence for the closing condition;
- merge, deployment, migration, and live-verification status;
- out-of-scope findings and approved follow-up tickets.

Set the state from current evidence:

- **Done** when the ticket's claim is false in the environment named by the
  closing condition and no required delivery step remains.
- **In Review** when a PR is open or merged code still awaits deployment,
  migration, publication, or required live verification.
- **In Progress** when only part of the ticket is complete.
- **Canceled** or **Duplicate** when the evidence supports that result.

Never infer deployment or live behavior from a merge. Verify the relevant remote,
artifact, deployment, or endpoint when authorized and safe.

## 11. Report and clean up

Report the ticket's current state, PRs and commits, diff size, checks and reviews,
delivery status, remaining work, blockers, and approved follow-up tickets.

After the ticket is fully complete, confirm each ticket worktree is clean and its
branch is safely retained in the remote or merged history. Remove clean completed
worktrees and verify with `git worktree list`. Never force-remove a dirty
worktree.

## Sensitive context

Keep secrets, credentials, tokens, PHI, personal data, customer-confidential
content, and protected document text out of delegation prompts, commits, PRs,
Linear, Slack, Notion, and Granola. Pass redacted facts, stable identifiers, and
authorized source links. A downstream agent should receive conclusions and
evidence relevant to its task, not raw source dumps or unrelated conversation
history.
