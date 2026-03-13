---
name: security-scanning
description: Application security — OWASP Top 10, secret detection, dependency CVEs, and GitHub Actions security. Use when reviewing code for vulnerabilities, auditing security posture, or hardening a codebase before release.
---

# Security Scanning

**Core principle:** Security is not a gate at the end of development — it's a quality property built in throughout. The goal is to find real vulnerabilities, not generate noise.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Code vulnerabilities (injection, auth, XSS) | **Application** | `references/application-security.md` |
| Secrets, tokens, credentials in code | **Secrets** | `references/secrets.md` |
| Dependency CVEs, supply chain | **Dependencies** | `references/dependency-security.md` |

---

## Core Principles

### Find real vulnerabilities, not theoretical ones

Before reporting a finding, confirm:
1. The code path is reachable in production
2. The input can be controlled by an attacker
3. There's no existing mitigation (escaping, validation, authorization check)

A false positive wastes engineer time and erodes trust in security reviews.

### Severity is about exploitability, not just impact

A critical vulnerability that requires physical access to the server is less urgent than a high-severity one that's exploitable remotely with no authentication.

| Factor | Raises severity | Lowers severity |
|--------|-----------------|-----------------|
| Authentication required | — | Yes (lowers) |
| Remote exploitability | Yes | — |
| User interaction required | — | Yes (lowers) |
| Data scope | Full DB access | Single row |
| Existing WAF/controls | — | Yes (lowers) |

### Fix the class, not the instance

When you find an injection vulnerability in one query, audit all queries of the same pattern. When you find a committed secret, audit the entire credential rotation history.

---

## OWASP Top 10 Quick Reference

1. **Broken Access Control** — IDOR, missing auth checks, path traversal
2. **Cryptographic Failures** — weak ciphers, cleartext storage of sensitive data
3. **Injection** — SQL, command, template, LDAP injection
4. **Insecure Design** — missing rate limiting, no abuse prevention
5. **Security Misconfiguration** — permissive CORS, verbose errors, default credentials
6. **Vulnerable Components** — outdated dependencies with known CVEs
7. **Authentication Failures** — weak passwords, missing MFA, insecure session management
8. **Integrity Failures** — unsigned updates, insecure deserialization
9. **Logging Failures** — insufficient logging, log injection
10. **SSRF** — server-side request forgery, unvalidated redirects
