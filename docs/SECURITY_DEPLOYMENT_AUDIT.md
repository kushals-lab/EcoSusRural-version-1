# EcoSusRural security and deployment-readiness audit

Audit date: 2026-10-24. Scope: repository source and safe local automated checks only. No services were exposed, deployed, or reconfigured; no passwords or local secret files were read.

## Executive status

**Not production-ready.** Authentication is not connected to a user credential store, no authorised payment provider or signed webhook exists, TLS termination and backup operations need production infrastructure, and the dependency scan reports unresolved critical/high findings.

## Implemented protections

| Area | Evidence | Status |
|---|---|---|
| Local backend exposure | Backend now listens on `127.0.0.1` by default; an explicit `BACKEND_HOST` is required to change it. | Implemented, code-reviewed |
| Production configuration | Production startup refuses missing/weak JWT secret, default/missing database password, missing PostgreSQL TLS, wildcard CORS, or no explicit CORS origin. | Implemented and fail-closed tested |
| API transport | Flutter rejects non-HTTPS non-loopback API URLs; Android declares Internet/network-state access without runtime Internet permission. | Implemented, static-analysis tested |
| HTTP hardening | `nosniff`, frame denial, referrer policy, restrictive permissions policy, request IDs, JSON size limit and rate limiting are present. | Code-reviewed |
| Authentication middleware | Bearer JWT verification, expiry validation and non-access token rejection are present. Password login returns 501 rather than minting a token without a user store. | Code-reviewed |
| Payments | Payment route requires auth, validates integer minor units, binds idempotency keys to a request, and only returns `initiated`. Client local-success path is disabled; no payment is confirmed without a provider. | Code-reviewed |
| PostgreSQL timestamps | `TIMESTAMPTZ` and server-managed `updated_at` triggers exist for core data tables. | Code-reviewed |
| Secret hygiene | `.env*`, private key formats, and local backup archives are ignored by Git. Default hard-coded mandi key was removed from both route variants. | Git-ignore checked |

## Tested protections

| Check | Result |
|---|---|
| `flutter analyze` on modified connectivity/payment code | Pass (no issues) |
| JavaScript syntax checks for modified backend files | Pass |
| Backend fixture test: `node --test test/ai_gateway.test.js` | Pass: 16 tests |
| Production configuration with no supplied secrets/infrastructure | Pass: process refused startup as designed |
| Git ignore rules for `.env`, key files | Pass: ignore rules matched; no secret values inspected |
| Local PostgreSQL listener | Fail: port 5432 is currently listening on `0.0.0.0` and `::`; firewall/network exposure was not assessed or changed |
| End-to-end payment/webhook, database TLS, backup/restore, real device | Not tested: requires approved infrastructure/credentials |

## Critical findings and required remediation

1. **No real user authentication backend.** The password-login route intentionally returns `501`; deploy only after implementing a user table, Argon2id/bcrypt password verification, account lifecycle controls, refresh-token revocation, and tested OTP delivery.
2. **No authorised payment-provider integration or signed webhook.** The app now fails safely, but commerce cannot go live until a licensed provider, signature verification, durable idempotency storage, reconciliation, and refund controls exist.
3. **Dependency vulnerabilities.** `npm audit --omit=dev --audit-level=high` reported four findings, including one critical and two high. Review the full audit output, upgrade/pin affected transitive packages, then rerun the audit and regression suite. Do not use automatic force upgrades without review.
4. **No production TLS termination or certificate lifecycle.** Put the loopback/private backend behind a managed HTTPS reverse proxy/load balancer with TLS 1.2+ (prefer 1.3), HSTS after validation, certificate renewal, WAF/rate controls, and access logs. Do not publicly bind this Windows development process.
5. **No proven backup/restore regime.** `scripts/backup_postgres.ps1` is a manual helper only. Configure encrypted off-host retention, least-privileged backup credentials, monitoring, retention/legal holds, and scheduled restore rehearsals.
6. **Local PostgreSQL is bound to all interfaces.** The read-only listener check observed `0.0.0.0:5432` and `:::5432`. Do not expose this database publicly. An authorised administrator must verify firewall rules and either bind PostgreSQL to loopback/private-network addresses or restrict inbound TCP/5432 to only approved application hosts.

## PostgreSQL requirements

- Use a private network/database endpoint; never publish port 5432.
- Require a non-default secret via a secret manager, `PGSSL=true`, certificate validation, a least-privilege application role, and separate migration/backup roles.
- Enable managed backups or a scheduled `pg_dump` process with encrypted off-host storage. Test restoration to an isolated environment before launch.
- Ensure PostgreSQL server logging/auditing, patching, connection limits, and monitoring are configured by the infrastructure owner.

## Public deployment prerequisites

1. Approved domain, managed TLS certificate and HTTPS reverse proxy/load balancer.
2. Secret manager populated privately with JWT, database, provider, SMTP, and external-service credentials.
3. Specific frontend CORS origin; private backend/database network paths; WAF and centralised monitoring/alerts.
4. Independent penetration test, dependency remediation, threat model, privacy/legal review, incident response and data-retention procedures.
5. Authorised payment, OTP, weather/mandi and other provider contracts; signed webhook verification and reconciliation tests.
6. Android release signing, unique application ID, store/privacy disclosure review, and real-device network testing.

## Local-test requirements

- Set only temporary local environment variables; never commit them.
- PostgreSQL client tools (`pg_dump`) are needed for the backup helper.
- Use a disposable local database for migration/restore tests.
- Flutter widget tests currently cannot start because the workspace `build\\unit_test_assets` directory is locked; release the lock or use a clean clone/build workspace.
- The package test script currently targets a missing `backend/test` path. Use `node --test test/ai_gateway.test.js` until the script is corrected.

## Deliberate non-actions

No firewall, Windows security, router, public-IP, database, production credentials, or deployment state was changed. No security certification is claimed.
