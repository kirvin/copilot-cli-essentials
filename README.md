# copilot-cli-essentials

A GitHub Copilot CLI plugin providing essential GitHub delivery and maintenance workflows — agents and skills for CI/CD, releases, security, incidents, and team operations.

## Install

```bash
copilot plugin install https://github.com/kellyirvin/copilot-cli-essentials
```

## Agents

Agents are specialized AI assistants invoked with `@agent-name`. Each has a defined role, curated tool access, and pre-loaded skills.

| Agent | Description |
|-------|-------------|
| `@release-engineer` | Orchestrates end-to-end releases — versioning, changelog, tagging, GitHub release, and post-release validation |
| `@security-auditor` | Security-focused code review and vulnerability assessment before merges and releases |
| `@incident-commander` | Incident response coordination from triage through mitigation and post-mortem |
| `@code-reviewer` | Comprehensive PR review covering correctness, security, DX, CI/CD, and CODEOWNERS |
| `@devils-advocate` | Poke holes in plans, deployments, and architecture decisions before committing |
| `@log-reader` | Efficiently triage build and deployment failures across GitHub Actions, CircleCI, and Jenkins |
| `@haiku` | Lightweight executor for well-defined delegated tasks |

## Skills

Skills are on-demand knowledge and workflow documents. They are loaded automatically by agents when relevant.

### Delivery Workflows

| Skill | Description |
|-------|-------------|
| `deploy` | Run the deployment workflow — pre-flight checks, environment targeting, production gate, and rollback |
| `release` | Cut a versioned release — semver bump, changelog, tag, and GitHub release |
| `incident` | Incident response workflow — triage, investigate, mitigate, communicate, and post-mortem |
| `workflow` | Debug and fix CI/CD pipeline failures |
| `standup` | Generate standup notes from git history, PRs, and issues |
| `sync` | Sync a fork or branch with upstream |
| `onboard` | Orient to a new project — structure, conventions, CI/CD, and workflows |

### Code Quality

| Skill | Description |
|-------|-------------|
| `review` | Comprehensive code review of the current branch |
| `audit` | Security and dependency audit — vulnerabilities, secrets, outdated packages |
| `fix-issue` | Fetch a GitHub issue and implement a fix |
| `test` | Run tests and analyze failures |
| `commit` | Stage changes, run preflight checks, and create a conventional commit |
| `pr` | Create a pull request with auto-generated title and description |
| `deps` | Audit, check, or upgrade project dependencies |

### Dev Workflows

| Skill | Description |
|-------|-------------|
| `explain` | Deep explanation of a file, function, or concept |
| `execute` | Find and execute an implementation plan from the plans folder |
| `init` | Initialize GitHub repo best practices — CODEOWNERS, Dependabot, branch protection, PR templates |

### Domain Knowledge

| Skill | Description |
|-------|-------------|
| `ci-cd-pipelines` | GitHub Actions patterns, caching, security, matrix builds |
| `release-management` | Semver, changelog authoring, release branching |
| `security-scanning` | OWASP Top 10, secret detection, dependency CVEs |
| `dependency-management` | CVE triage, safe upgrades, Dependabot/Renovate configuration |
| `branching-strategy` | Trunk-based development, naming conventions, PR workflow |
| `incident-response` | Severity triage, investigation playbooks, post-mortems |
| `deployment-strategies` | Blue/green, canary, feature flags, database migrations |
| `code-ownership` | CODEOWNERS setup, review standards, team routing |
| `reading-logs` | Log investigation across GitHub Actions, CircleCI, and Jenkins |

### General Engineering

| Skill | Description |
|-------|-------------|
| `architecting-systems` | Clean system architecture, module boundaries, dependency management |
| `writing-tests` | Behavior-focused tests using the Testing Trophy model |
| `refactoring-code` | Structure improvements while preserving behavior |
| `systematic-debugging` | Four-phase root cause analysis before proposing fixes |
| `handling-errors` | Preventing silent failures and context loss |
| `migrating-code` | Safe migrations with backward compatibility and reversibility |
| `optimizing-performance` | Measure-first performance work |
| `fixing-flaky-tests` | Diagnosing tests that fail when run concurrently |
| `condition-based-waiting` | Replacing arbitrary timeouts with condition polling |
| `managing-databases` | Schema design, query optimization, PostgreSQL/DuckDB/PGVector |
| `preflight-checks` | Detect and run linters, formatters, and type checkers |
| `verification-before-completion` | Verification standards before claiming work is done |
| `post-mortem` | Session review to extract actionable improvements |
| `planning-products` | Feature scoping, product specs, JTBD analysis |
| `writing-plans` | Implementation plans grouped by subsystem |
| `executing-plans` | Orchestrating multi-agent plan execution |

### Style & Documentation

| Skill | Description |
|-------|-------------|
| `writer` | Writing style guide for human-sounding content |
| `documentation` | Task-oriented technical documentation |
| `design` | Precise, minimal UI design for dashboards and admin interfaces |
| `visualizing-with-mermaid` | Professional Mermaid diagrams with semantic styling |
| `configuring-copilot` | How to write skills, agents, and hooks for this plugin system |

## License

MIT
