# HIPAA technical safeguards checklist for code review

Grounded in the HIPAA Security Rule (45 CFR 164.312) and the January 2025
Security Rule NPRM (RIN 0945-AA22), which makes previously "addressable"
specifications mandatory — encryption at rest and in transit, MFA, network
segmentation, and audit controls. The final rule is expected ~2027 with a
240-day compliance window, but OCR enforcement and breach safe-harbor already
treat encryption as the de-facto standard: unencrypted PHI loss is presumed a
reportable breach; properly encrypted data falls under safe harbor.

Severity tags below are defaults — adjust per the Judgment Calls section of SKILL.md.

## 1. Encryption in transit (TLS)

- [ ] **CRITICAL** — Any PHI sent over plain `http://`, `ws://`, unencrypted
  SMTP, FTP, or raw TCP. Includes internal service-to-service traffic and
  webhooks.
- [ ] **HIGH** — TLS below 1.2 accepted, or weak cipher suites explicitly
  configured (RC4, 3DES, CBC-mode with TLS 1.0/1.1, export ciphers). Target:
  TLS 1.2 minimum, TLS 1.3 preferred (`TLS_AES_256_GCM_SHA384`,
  `TLS_CHACHA20_POLY1305_SHA256`).
- [ ] **HIGH** — Certificate verification disabled (`verify=False`,
  `rejectUnauthorized: false`, `InsecureSkipVerify: true`, custom trust-all
  TrustManager) anywhere PHI flows — including "temporary" dev flags that ship.
- [ ] **MEDIUM** — Missing HSTS header (`max-age` ≥ 1 year) on web apps serving
  PHI; missing HTTPS redirect.
- [ ] **MEDIUM** — Internal service-to-service PHI traffic terminates TLS at the
  edge and travels plaintext inside the network. NPRM network-segmentation
  expectations favor mTLS or in-mesh encryption.
- [ ] **LOW** — Mobile clients without certificate pinning for PHI endpoints.

## 2. Encryption at rest

- [ ] **CRITICAL** — PHI written to disk, database, object storage, backups, or
  device storage with no encryption at any layer (no disk/volume encryption, no
  server-side encryption, no application-level encryption).
- [ ] **HIGH** — New datastore/bucket/volume/queue added in IaC or config
  without an explicit encryption setting (e.g. S3 bucket without SSE-KMS, RDS
  without `storage_encrypted`, EBS/GCE disk without CMEK, unencrypted Redis/
  Elasticache snapshots, Kafka topics on unencrypted disks). Standard: AES-256.
- [ ] **HIGH** — PHI cached in plaintext: Redis/Memcached values, local files,
  browser `localStorage`/`sessionStorage`/IndexedDB, mobile SQLite without
  SQLCipher/keystore-backed encryption.
- [ ] **MEDIUM** — Highly sensitive fields (SSN, diagnoses, medications, mental
  health, HIV status, genetics, substance abuse) stored without field/column-
  level encryption on top of volume encryption, where the codebase otherwise
  does this.
- [ ] **MEDIUM** — Backups, exports, or dumps (CSV/PDF/report generation) that
  bypass the encrypted store and land somewhere unencrypted.

## 3. Key and secret management

- [ ] **CRITICAL** — Encryption keys, DB credentials, or API secrets hardcoded
  in source, committed .env files, or client-side code.
- [ ] **HIGH** — Keys stored alongside the data they encrypt (key in the same
  DB/bucket/config as ciphertext).
- [ ] **MEDIUM** — No KMS/HSM usage (AWS KMS, GCP KMS, Azure Key Vault, Vault)
  for PHI encryption keys; keys generated ad hoc in application code.
- [ ] **MEDIUM** — No key-rotation support: single hardcoded key version, no
  key-id stored with ciphertext (rotation target: ≤ 1 year; FIPS 140-2/140-3
  validated modules).
- [ ] **LOW** — DB admins/app roles able to read keys (no separation of duties
  in IAM policies).

## 4. PHI leakage into logs, errors, and URLs

- [ ] **CRITICAL** — PHI in logs shipped to third parties without a BAA path:
  error trackers (Sentry, Rollbar), APM, analytics (GA, Mixpanel, Segment),
  LLM APIs. Check what objects get serialized into log/capture calls.
- [ ] **HIGH** — PHI (names, MRNs, SSNs, DOBs, diagnoses) logged in application
  or access logs, including full request/response body logging middleware and
  ORM query logging with bound parameters in production.
- [ ] **HIGH** — PHI or patient identifiers in URLs/query strings (`GET
  /patients?ssn=...`, tokens or MRNs in path where they hit access logs,
  browser history, referrer headers). Use opaque IDs and POST bodies.
- [ ] **HIGH** — Stack traces, SQL errors, or record contents returned to the
  client in error responses. Return generic messages + correlation ID; log
  detail server-side only.
- [ ] **MEDIUM** — No redaction/sanitization layer for structured logging of
  request objects that can contain PHI (`[REDACTED]` placeholders, field
  allowlists).
- [ ] **MEDIUM** — PHI in push-notification payloads, email subject lines, or
  SMS bodies (these transit third-party infrastructure and lock screens).

## 5. Authentication and access control (§164.312(a),(d))

- [ ] **CRITICAL** — PHI endpoints reachable without authentication (missing
  auth middleware/decorator on new routes, public bucket ACLs, unauthenticated
  GraphQL resolvers or debug endpoints).
- [ ] **HIGH** — Missing authorization (tenant/record-level checks): IDOR
  patterns where any authenticated user can fetch any patient by ID. Every PHI
  read must be scoped to the caller's permitted patients.
- [ ] **HIGH** — JWTs signed with symmetric HS256 + shared secret, no
  expiration, or PHI placed in JWT claims (JWTs are base64, not encrypted).
  Target: RS256/ES256, ≤ 30-min access tokens, `jti`, refresh-token rotation.
- [ ] **HIGH** — Session tokens in `localStorage`; cookies without
  `Secure`/`HttpOnly`/`SameSite`.
- [ ] **MEDIUM** — No MFA hook on new authentication flows for systems
  accessing ePHI (mandatory under the NPRM); password-only admin logins.
- [ ] **MEDIUM** — No automatic session timeout/logoff for PHI-facing UIs
  (§164.312(a)(2)(iii)); infinite sessions.
- [ ] **MEDIUM** — Overbroad data returns violating minimum-necessary: an
  endpoint returning full patient records where the caller needs demographics;
  `SELECT *`/full-object serialization of PHI models into APIs.
- [ ] **LOW** — No per-user rate limiting on PHI query/search endpoints
  (bulk-scrape risk).

## 6. Audit controls (§164.312(b))

- [ ] **HIGH** — New PHI read/write paths with no audit logging at all: who
  (user ID + role), what (patient ID, record type), when (ISO 8601 + TZ),
  where from (IP), action, and outcome.
- [ ] **MEDIUM** — Audit logs mutable or deletable by the application role
  (should be append-only/write-once, separate store, ≥ 6-year retention).
- [ ] **MEDIUM** — Audit events missing on the failure path (denied access
  attempts unlogged) or on bulk exports.
- [ ] **LOW** — Audit logs themselves contain full PHI payloads (log the
  pointer — patient ID — not the clinical content).

## 7. Integrity and disposal (§164.312(c), §164.310(d))

- [ ] **MEDIUM** — PHI records hard-deleted or updated with no
  integrity/versioning mechanism where the system needs tamper-evidence
  (checksums, versioned storage, WORM).
- [ ] **MEDIUM** — Deletion features that don't actually dispose: soft-delete
  flags leaving PHI queryable forever with no purge job; temp files/uploads not
  cleaned; PHI left in caches/queues after record deletion.
- [ ] **LOW** — Downloaded/generated files (reports, exports) written to shared
  temp dirs with world-readable permissions.

## 8. Third parties and boundaries

- [ ] **HIGH** — New dependency/SDK/API call that receives PHI (email, SMS,
  analytics, error tracking, LLM/AI APIs, cloud services) — flag for BAA
  verification. Common no-BAA-by-default traps: standard Google Analytics,
  most free-tier SaaS, consumer LLM endpoints.
- [ ] **HIGH** — Production PHI copied into dev/staging/test: fixtures or seed
  files with realistic patient data, prod-DB-to-staging sync scripts, real
  data in recorded API cassettes/snapshots. Use synthetic data (e.g. Synthea)
  or documented de-identification (Safe Harbor: strip all 18 identifiers).
- [ ] **MEDIUM** — PHI crossing into non-covered infrastructure: CI logs,
  build artifacts, public/team Slack webhooks, GitHub issue templates
  auto-filled with request data.
- [ ] **LOW** — Realistic-looking PHI in code comments, README examples, or
  API docs.

## 9. Infrastructure / IaC (when in the diff)

- [ ] **CRITICAL** — Public exposure of PHI stores: `0.0.0.0/0` security-group
  ingress to a database, public S3/GCS ACLs, public snapshots.
- [ ] **HIGH** — No network segmentation between PHI systems and general
  workloads (flat VPC, no subnet isolation) — explicit NPRM requirement to
  prevent lateral movement.
- [ ] **MEDIUM** — Missing/disabled provider audit trails (CloudTrail, GCP
  audit logs) or flow logs on PHI networks.
- [ ] **MEDIUM** — Backup/DR config without encryption or with retention that
  can't meet the 6-year documentation requirement.

## The 18 HIPAA identifiers (what makes health data PHI)

Names; geographic subdivisions smaller than state; dates (birth, admission,
discharge, death; ages > 89); phone; fax; email; SSN; MRN; health-plan
beneficiary number; account numbers; certificate/license numbers; vehicle
identifiers (VIN, plates); device identifiers/serials; URLs; IP addresses;
biometric identifiers; full-face photos; any other unique identifying number,
characteristic, or code — when linked to health information.

## Sources (as of July 2026)

- HHS Security Rule NPRM, Jan 6 2025 (RIN 0945-AA22); final action expected
  ~July 2027, 240-day compliance window after publication.
- 45 CFR 164.312 (technical safeguards), 164.514 (de-identification).
- NIST SP 800-66r2 (implementing the HIPAA Security Rule), SP 800-52r2 (TLS),
  FIPS 140-3 (crypto modules).
- Breach safe harbor: encrypted-per-NIST PHI loss is not a reportable breach
  (HITECH / 45 CFR 164.402).
