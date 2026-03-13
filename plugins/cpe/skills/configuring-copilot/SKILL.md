---
name: configuring-copilot
description: Authoring and extending the copilot-cli-essentials plugin — writing commands, skills, agents, and hooks. Use when adding new cpe commands or skills, designing new agents, configuring hooks, understanding the plugin structure, or extending the plugin for project-specific needs.
---

# Configuring Copilot CLI Essentials

**Core principle:** Every piece of this plugin — commands, skills, agents, hooks — is a markdown or JSON file. There is no build step, no compilation. You edit a file, reload the plugin, and the change is live. Keep things simple and composable.

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Overall plugin layout, marketplace.json, plugin.json | **Structure** | `references/plugin-structure.md` |
| Writing `/cpe:` slash commands | **Commands** | `references/commands.md` |
| Writing `cpe:` skills (SKILL.md files) | **Skills** | `references/skills.md` |
| Writing `cpe:` agents | **Agents** | `references/agents.md` |
| Writing hooks (SessionStart, Notification, etc.) | **Hooks** | `references/hooks.md` |

Load multiple references when working across concerns — e.g., a new feature may need a command + a skill + an agent.

---

## Plugin Namespace

Every public identifier in this plugin uses the `cpe:` prefix:

| Type | How invoked | Example |
|------|-------------|---------|
| Command | `/cpe:name` | `/cpe:deploy production` |
| Skill | `Skill(cpe:name)` | `Skill(cpe:systematic-debugging)` |
| Agent | `@cpe:name` or via Task tool | `@cpe:release-engineer` |

The prefix comes from the `name` field in `plugins/cpe/.claude-plugin/plugin.json`. Changing it renames all commands, skills, and agents — avoid doing so after the plugin is published.

---

## Core Principles

### Everything is discoverable from the file tree

The plugin structure mirrors the user-facing taxonomy. A developer unfamiliar with the plugin should be able to infer what a file does from its location alone:

```
plugins/cpe/
├── commands/deploy.md         → /cpe:deploy command
├── skills/release-management/ → cpe:release-management skill
├── agents/release-engineer.md → cpe:release-engineer agent
└── hooks/session-start.sh     → runs on SessionStart
```

### Instructions over code

Commands, skills, and agents are instruction documents, not programs. They tell Claude *what to do* and *how to reason*, not imperative scripts. If a task requires reliable execution of exact shell commands, put those commands in the instruction document — don't write wrapper scripts.

### Progressive disclosure

Skills use three levels of detail:

1. **Frontmatter** — always loaded; describes what the skill does and when to use it
2. **SKILL.md body** — loaded when the skill is activated; provides reasoning framework and routing table
3. **Reference files** — loaded on demand; contain detailed how-to for a specific subtopic

Keep SKILL.md bodies focused and under 500 lines. Move detail into references.

### One concern per file

Each command does one thing. Each skill covers one domain. Each agent has one role. When something starts doing two different things, split it.

---

## Anti-Patterns

| Pattern | Problem |
|---------|---------|
| Adding a command that just delegates to a shell script | Bypasses Claude's reasoning; use instructions instead |
| Skills with no Topic Selection table | Forces loading everything upfront; add references for detail |
| Agents with `tools: *` or no tools restriction | Gives agents unintended access; be explicit |
| Commands that replicate existing skills inline | Creates drift; load the skill instead |
| Deeply nested references (skill → ref → ref) | Claude stops reading past one level deep |
| Updating `marketplace.json` version without a code change | Version bumps should correspond to actual changes |
