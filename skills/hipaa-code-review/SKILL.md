---
name: hipaa-code-review
description: HIPAA compliance review of pending code changes — checks PHI data storage, transmission, logging, auth, and third-party handling against current HIPAA Security Rule technical safeguards. Use during code review of any code that touches patient/health data, when the user asks for a HIPAA or PHI compliance check, or alongside /security-review for healthcare codebases.
---

# HIPAA compliance code review

Review the pending code changes for HIPAA Security Rule violations in how the
code stores, transmits, logs, and exposes PHI/ePHI. This is a technical-safeguards
review of code, not legal advice — flag that distinction once at the end of the report.

The full rule-by-rule checklist lives in `references/hipaa-checklist.md` in this
skill's directory. **Read it before reviewing** — it encodes the current standards (2025 Security Rule NPRM:
mandatory AES-256 at rest, TLS 1.2+ in transit, MFA, audit logging, network
segmentation) and the concrete code patterns that violate them.

## Scope of a review

1. **Determine the diff.** Default to the working diff: `git diff` +
   `git diff --staged`, plus untracked files (`git status --porcelain`). If the
   user names a branch or PR, diff against that instead (`git diff main...HEAD`
   or `gh pr diff <n>`). If there is no diff at all, ask whether to review the
   whole repo or stop.

2. **Identify PHI-touching surfaces.** PHI is any of the 18 HIPAA identifiers
   (name, MRN, SSN, DOB, address, email, phone, biometrics, photos, device IDs,
   IPs tied to a patient, etc.) plus any health/diagnosis/medication/lab data.
   In the diff, look for: database models/migrations/schemas, API
   request/response handling, file uploads/downloads, logging and error
   reporting, caching, queues/events, analytics calls, third-party SDK calls,
   test fixtures and seed data, infra/config (Terraform, k8s, docker-compose,
   CI files), and client-side storage. Also read enough surrounding code
   (the touched files, not just hunks) to understand how data flows.

3. **Apply the checklist.** Work through every section of
   `references/hipaa-checklist.md` against the identified surfaces. For each
   potential finding, verify against the actual code before reporting — read
   the definitions, follow the call, confirm the data involved can actually be
   PHI in this codebase. Drop anything you cannot substantiate.

4. **Report.** If a `ReportFindings` tool is available in this session, report
   confirmed findings through it (most severe first). Otherwise print a report:

   - **Verdict line** — pass / N findings, worst severity.
   - **Findings**, ordered by severity, each with:
     - Severity: `CRITICAL` (PHI exposed or transmitted/stored in plaintext),
       `HIGH` (violates a required safeguard), `MEDIUM` (violates a best
       practice that becomes required under the pending Security Rule update),
       `LOW` (hardening/hygiene).
     - `file:line` reference, one-sentence defect statement, the checklist item
       it violates, and a concrete fix (specific code or config change, not
       "consider encrypting").
   - **Not code-fixable** — a short section for things the diff surfaces that
     need organizational action (missing BAA with a newly added vendor,
     retention policy, risk analysis), so they aren't silently dropped.
   - Close with the one-line disclaimer that this is a technical review, not a
     compliance certification or legal advice.

## Judgment calls

- **Severity is about exposure, not style.** Plaintext PHI in logs shipped to a
  third party (Sentry, Datadog) is CRITICAL even if the logger call looks tidy.
  A missing HSTS header on an internal admin panel behind a VPN is LOW.
- **Don't flag encrypted-by-platform as unencrypted** — e.g. RDS/EBS with
  encryption enabled in Terraform, or S3 with SSE. But DO flag when the diff
  adds storage without any visible encryption setting; absence of evidence is a
  finding (MEDIUM, "verify encryption at rest is enabled").
- **Test/dev code counts.** Real-looking PHI in fixtures, seeds, or docs
  examples is a finding. Clearly synthetic data ("Test Patient 123",
  555-01xx phones) is fine.
- **New third-party dependencies that receive PHI** (analytics, error tracking,
  LLM APIs, email/SMS providers) always get a finding: either confirm a BAA
  path exists or mark it "not code-fixable" for the team.
- If the codebase demonstrably never handles PHI, say so and stop — don't
  invent findings to have something to report.
