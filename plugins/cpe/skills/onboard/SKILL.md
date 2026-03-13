---
name: onboard
description: Use when the user wants to onboard to a new project, understand a codebase, or get oriented to team conventions and workflow.
---

Load the branching-strategy skill: `Skill(cpe:branching-strategy)`
Load the code-ownership skill: `Skill(cpe:code-ownership)`

Rapidly orient to a new project: understand structure, conventions, CI/CD, and how to contribute.

## Mode

Determine the desired mode from the user's message:
- Quick mode — 5-minute scan: project type, how to run, how to contribute
- Full mode (default) — comprehensive onboarding including team conventions, architecture, CI/CD

---

## Project Discovery

```bash
# Identity
cat README.md 2>/dev/null | head -50
cat package.json 2>/dev/null | jq '{name, description, version, scripts}' 2>/dev/null || true

# Structure
find . -maxdepth 2 -type d | grep -v node_modules | grep -v ".git" | sort | head -40

# Tech stack
[ -f package.json ]     && echo "Node.js / JavaScript"
[ -f tsconfig.json ]    && echo "TypeScript"
[ -f pyproject.toml ]   && echo "Python"
[ -f go.mod ]           && echo "Go"
[ -f Cargo.toml ]       && echo "Rust"
[ -f pom.xml ]          && echo "Java/Maven"
[ -f build.gradle ]     && echo "Java/Gradle"
[ -f Dockerfile ]       && echo "Docker"
[ -f docker-compose.yml ] && echo "Docker Compose"
```

---

## Development Setup

```bash
# How to install dependencies
[ -f package.json ]      && echo "npm install"
[ -f pyproject.toml ]    && echo "pip install -e '.[dev]'"
[ -f go.mod ]            && echo "go mod download"

# How to run locally
[ -f package.json ] && cat package.json | jq '.scripts' 2>/dev/null
[ -f Makefile ]     && grep "^[a-z].*:" Makefile | head -10

# Environment setup
ls .env.example .env.sample 2>/dev/null && echo "Copy .env.example to .env and fill values"
```

---

## CI/CD & Workflows

```bash
ls .github/workflows/ 2>/dev/null
cat .github/workflows/*.yml 2>/dev/null | grep -E "^name:|^on:" | head -20

# Active PRs / recent merges
gh pr list --limit 5 --json number,title,author 2>/dev/null | jq -r '.[] | "#\(.number) \(.title) by \(.author.login)"'
```

---

## Team Conventions

```bash
# CODEOWNERS
cat .github/CODEOWNERS 2>/dev/null | head -20
cat CODEOWNERS 2>/dev/null | head -20

# Contributing guide
cat CONTRIBUTING.md 2>/dev/null | head -60

# Code style
ls .eslintrc* .prettierrc* pyproject.toml .rubocop.yml 2>/dev/null

# Branch naming from recent branches
git branch -r --sort=-committerdate | head -10

# Commit style from history
git log --oneline -10
```

---

## Onboarding Summary Output

Produce a structured onboarding doc:

```
## Project: [name]
[1-sentence description]

## Tech Stack
[detected stack]

## Get Started
1. [install command]
2. [env setup]
3. [run locally command]
4. [run tests command]

## Branch & PR Workflow
[detected from CONTRIBUTING.md / branch history]

## Key People
[CODEOWNERS / frequent committers]

## CI/CD
[workflows detected]

## First Things to Know
[anything unusual or important discovered — e.g., monorepo, custom tooling, known gotchas]
```

---

## Quick Mode

If the user requested a quick onboarding, skip the Team Conventions and CI/CD sections. Output only Get Started and key commands.
