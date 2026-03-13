# copilot-cli-essentials

A Claude Code plugin providing essential GitHub delivery and maintenance workflows — commands, skills, and agents for CI/CD, releases, security, incidents, and team operations.

## Install

```bash
/plugin install https://github.com/kellyirvin/copilot-cli-essentials
```

## Commands

| Command | Description |
|---------|-------------|
| `/cpe:deploy [env]` | Deploy to an environment with pre-flight checks and rollback guidance |
| `/cpe:release [version]` | Cut a versioned release with changelog, tag, and GitHub release |
| `/cpe:workflow [name\|run-id]` | Debug, fix, or optimize a GitHub Actions workflow |
| `/cpe:audit` | Security and dependency audit — vulnerabilities, secrets, outdated packages |
| `/cpe:standup` | Generate standup notes from git history, PRs, and issues |
| `/cpe:incident [description]` | Incident response — triage, investigate, mitigate, and document |
| `/cpe:sync` | Sync fork or branch with upstream |
| `/cpe:onboard` | Onboard to a new project — structure, conventions, workflow |

## Skills

Skills are loaded on-demand via the `Skill()` tool:

| Skill | Description |
|-------|-------------|
| `cpe:ci-cd-pipelines` | GitHub Actions patterns, caching, security, matrix builds |
| `cpe:release-management` | Semver, changelog authoring, release branches |
| `cpe:security-scanning` | OWASP Top 10, secret detection, dependency CVEs |
| `cpe:dependency-management` | CVE triage, safe upgrades, Dependabot/Renovate |
| `cpe:branching-strategy` | Trunk-based, naming conventions, PR workflow |
| `cpe:incident-response` | Severity triage, investigation, post-mortems |
| `cpe:deployment-strategies` | Blue/green, canary, feature flags, DB migrations |
| `cpe:code-ownership` | CODEOWNERS setup, review standards |
| `cpe:reading-logs` | Log investigation for GitHub Actions, CircleCI, and Jenkins |

## Agents

| Agent | Description |
|-------|-------------|
| `cpe:release-engineer` | Orchestrates end-to-end releases with validation and rollback |
| `cpe:security-auditor` | Security-focused code review and vulnerability assessment |
| `cpe:incident-commander` | Incident response coordination from triage through post-mortem |
| `cpe:code-reviewer` | Comprehensive PR review — correctness, security, DX, CI/CD, CODEOWNERS |
| `cpe:devils-advocate` | Poke holes in plans, deployments, and architecture before committing |
| `cpe:log-reader` | Efficiently triage GitHub Actions logs and deployment failures |
| `cpe:haiku` | Lightweight executor for delegated tasks from commands |

## License

MIT
