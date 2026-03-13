# Writing Commands

Commands are slash commands invoked as `/cpe:name [arguments]`. Each command is a single markdown file.

## File Location

```
plugins/cpe/commands/my-command.md
```

Register in `marketplace.json`:
```json
"commands": ["./commands/my-command.md"]
```

## Frontmatter Schema

```yaml
---
description: One-line description shown in command picker and help
argument-hint: "[optional-arg] [--flag]"
allowed-tools: Bash, Glob, Grep, Read, Skill
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `description` | Yes | Shown in `/cpe:command --help` and UI autocomplete. Keep under 100 chars. |
| `argument-hint` | No | Displayed as placeholder text when typing the command. Use brackets for optional args, angle brackets for required. |
| `allowed-tools` | Yes | Comma-separated. Controls which tools Claude can use when executing this command. |

### allowed-tools values

```
Bash          Shell commands
Glob          File pattern matching
Grep          Content search
Read          File reading
Edit          File editing
Write         File writing
Skill         Load skills via Skill() tool
Agent         Spawn subagents
Task          Create background tasks
WebFetch      Fetch URLs
WebSearch     Web search
```

Include `Skill` whenever the command should be able to load skills. Omit tools the command doesn't need — it reduces attack surface and makes the command's scope clearer.

## Body Structure

The body is instruction prose for Claude. It receives `$ARGUMENTS` containing whatever the user typed after the command name.

### Proven pattern

```markdown
One sentence context-setter.

Load skill if relevant: `Skill(cpe:relevant-skill)`

## Step 1: Parse Arguments

Explain how to interpret $ARGUMENTS. State defaults.

## Step 2: Gather Context

Shell commands to run before acting.

## Step 3: Execute

What to do based on the gathered context.

## Step 4: Report

What to output and in what format.
```

### $ARGUMENTS

`$ARGUMENTS` is replaced at runtime with the raw argument string the user typed.

```markdown
Parse `$ARGUMENTS` for:
- First word as environment name (default: `staging`)
- `--dry-run` flag: run checks but don't execute
- `--fix` flag: apply fixes automatically
```

If no arguments are expected, omit the parsing step entirely.

## Example: Minimal Command

```markdown
---
description: Show git status in a clean format
allowed-tools: Bash
---

Show the current repository status, recent commits, and branch divergence.

```bash
git status --short
git log --oneline -5
git log --oneline HEAD..origin/$(git branch --show-current) 2>/dev/null | wc -l
```

Report: branch name, number of uncommitted changes, commits ahead/behind origin.
```

## Example: Command with Argument and Skill

```markdown
---
description: Audit dependencies for the specified package ecosystem
argument-hint: "[npm|python|go] [--fix]"
allowed-tools: Bash, Read, Skill
---

Load the dependency-management skill: `Skill(cpe:dependency-management)`

Parse `$ARGUMENTS`:
- First word is ecosystem (default: auto-detect from project files)
- `--fix` flag: apply safe fixes automatically

[... rest of instructions ...]
```

## Design Guidelines

**Do one thing.** If a command is doing two unrelated things, split it into two commands.

**Load skills, don't duplicate them.** If the logic you need is in a skill, call `Skill(cpe:that-skill)` rather than copying the content inline.

**Fail gracefully.** When a prerequisite isn't met (no lockfile, CI not configured, etc.), explain what's missing and what to do — don't silently produce wrong output.

**Default to safe.** For destructive or irreversible operations, make the safe path the default (e.g., `--dry-run` output before executing).
