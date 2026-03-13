# Plugin Structure

## Repository Layout

```
copilot-cli-essentials/
├── .claude-plugin/
│   └── marketplace.json        # Plugin registry — lists all plugins in this repo
├── plugins/
│   └── cpe/
│       ├── .claude-plugin/
│       │   └── plugin.json     # Plugin metadata (name, version, author)
│       ├── commands/           # Slash command definitions
│       │   └── deploy.md
│       ├── skills/             # On-demand skill documents
│       │   └── release-management/
│       │       ├── SKILL.md
│       │       └── references/
│       │           └── versioning.md
│       ├── agents/             # Specialized agent definitions
│       │   └── release-engineer.md
│       └── hooks/              # Event hooks
│           ├── hooks.json      # Hook event configuration
│           ├── session-start.sh
│           └── notify.sh
├── README.md
└── LICENSE
```

## marketplace.json

Located at `.claude-plugin/marketplace.json`. Defines the repository as a plugin source and lists every plugin it contains.

```json
{
  "name": "copilot-cli-essentials",
  "owner": {
    "name": "Kelly Irvin",
    "url": "https://github.com/kellyirvin"
  },
  "metadata": {
    "description": "...",
    "version": "1.3.0"
  },
  "plugins": [
    {
      "name": "cpe",
      "source": "./plugins/cpe/",
      "description": "...",
      "version": "1.3.0",
      "author": { "name": "...", "url": "..." },
      "homepage": "...",
      "repository": "...",
      "license": "MIT",
      "keywords": [...],
      "category": "workflows",
      "strict": true,
      "commands": ["./commands/deploy.md", ...],
      "skills":   ["./skills/release-management", ...],
      "agents":   ["./agents/release-engineer.md", ...]
    }
  ]
}
```

**Key fields:**
- `source` — path to the plugin directory, relative to marketplace.json
- `strict` — when `true`, only listed commands/skills/agents are registered (recommended)
- `commands` — paths to `.md` files, relative to `source`
- `skills` — paths to skill *directories* (not SKILL.md), relative to `source`
- `agents` — paths to `.md` files, relative to `source`

**When to update:**
- Bump `version` whenever commands, skills, or agents change
- Add new entries to `commands`, `skills`, or `agents` arrays when adding files
- Both the `metadata.version` and the plugin's `version` field should stay in sync

## plugin.json

Located at `plugins/cpe/.claude-plugin/plugin.json`. Minimal metadata for the plugin itself.

```json
{
  "name": "cpe",
  "description": "...",
  "version": "1.3.0",
  "author": { "name": "Kelly Irvin" },
  "license": "MIT"
}
```

The `name` field here defines the namespace prefix. All commands become `/cpe:*`, all skills become `cpe:*`, all agents become `cpe:*`.

## Adding a New Plugin Component

**New command:**
1. Create `plugins/cpe/commands/my-command.md`
2. Add `"./commands/my-command.md"` to `commands` array in `marketplace.json`
3. Bump version in `marketplace.json` and `plugin.json`
4. Run `/reload-plugins` in Claude Code

**New skill:**
1. Create `plugins/cpe/skills/my-skill/SKILL.md` (and `references/` if needed)
2. Add `"./skills/my-skill"` to `skills` array in `marketplace.json`
3. Bump version, reload

**New agent:**
1. Create `plugins/cpe/agents/my-agent.md`
2. Add `"./agents/my-agent.md"` to `agents` array in `marketplace.json`
3. Bump version, reload

## Installing and Reloading

```bash
# Install from GitHub
/plugin install https://github.com/kellyirvin/copilot-cli-essentials

# Reload after local changes
/reload-plugins

# Verify what's loaded
/plugin list
```
