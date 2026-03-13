# Writing Hooks

Hooks run shell commands in response to Claude Code lifecycle events. They let the plugin inject context, trigger notifications, or run side-effects at key moments.

## File Location

```
plugins/cpe/hooks/
├── hooks.json          # Event → command mapping
├── session-start.sh    # Script for SessionStart hook
└── notify.sh           # Script for Notification hook
```

## hooks.json Schema

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "regex pattern or empty string",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/your-script.sh"
          }
        ]
      }
    ]
  }
}
```

### Available Hook Events

| Event | Fires when | matcher matches |
|-------|------------|-----------------|
| `SessionStart` | A session begins | The session start reason/message |
| `Notification` | Claude wants to send a notification (waiting for input) | The notification text |
| `PreToolUse` | Before Claude calls a tool | The tool name |
| `PostToolUse` | After a tool call completes | The tool name |
| `Stop` | Claude finishes a response | The final message text |
| `SubagentStop` | A subagent finishes | The subagent's final message |

### matcher field

A regex pattern matched against the event's context string. Use `""` (empty string) to match all occurrences.

```json
// Only fire on session startup/resume/clear/compact
"matcher": "startup|resume|clear|compact"

// Fire on all notifications
"matcher": ""

// Only fire before Bash tool calls
"matcher": "Bash"

// Only fire before write operations
"matcher": "Edit|Write"
```

### CLAUDE_PLUGIN_ROOT

Available in all hook commands. Resolves to the absolute path of the plugin directory at runtime.

```bash
# Use it to reference scripts and assets relative to the plugin
"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
"command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/notify.sh ${CLAUDE_PLUGIN_ROOT}"
```

Do not hardcode absolute paths — the plugin may be installed in different locations.

## Hook Output

Hooks can return JSON to inject context into Claude's session:

```bash
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Your context string here"
  }
}
EOF
```

Claude Code reads this output and injects `additionalContext` into the conversation. This is how `session-start.sh` injects the skills list into every new session.

## Writing a Hook Script

Shell scripts must:
- Use `#!/usr/bin/env bash` shebang
- Set `set -euo pipefail` for safe execution
- Exit 0 on success (non-zero suppresses output and may log an error)
- Be executable (`chmod +x script.sh`)

```bash
#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Your hook logic here
# Output JSON if you want to inject context

exit 0
```

The fallback `$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)` for `PLUGIN_ROOT` ensures the script also works when run directly during development.

## Common Patterns

### Injecting context on session start

The `session-start.sh` script in this plugin scans all `SKILL.md` files, extracts their names and descriptions, and injects a skills list into `~/.claude/CLAUDE.md`. This ensures Claude always knows which `cpe:` skills are available, even in subagents.

Key logic:
1. Parse `SKILL.md` frontmatter to extract `name` and `description`
2. Build an instruction block listing all skills
3. Compare against existing content in `~/.claude/CLAUDE.md`
4. Only update (and output context) if the content changed — avoids redundant injection

### Desktop notifications

The `notify.sh` script fires on `Notification` events and uses `terminal-notifier` (macOS) or `notify-send` (Linux) to alert the user that Claude is waiting for input.

## Adding a New Hook

1. Write the shell script in `plugins/cpe/hooks/`
2. Make it executable: `chmod +x plugins/cpe/hooks/my-hook.sh`
3. Add the event entry to `hooks.json`:
   ```json
   "PreToolUse": [
     {
       "matcher": "Bash",
       "hooks": [
         {
           "type": "command",
           "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/my-hook.sh"
         }
       ]
     }
   ]
   ```
4. Run `/reload-plugins` to pick up the change
5. Test by triggering the event and checking the hook ran

## Debugging Hooks

```bash
# Run a hook script manually to test it
CLAUDE_PLUGIN_ROOT=/path/to/plugins/cpe bash plugins/cpe/hooks/session-start.sh

# Check if hook output is valid JSON
CLAUDE_PLUGIN_ROOT=/path/to/plugins/cpe bash plugins/cpe/hooks/session-start.sh | jq .
```

Hooks that exit non-zero or produce invalid JSON are silently ignored by Claude Code — always test before deploying.
