# Writing Agents

Agents are specialized Claude instances with a defined role, tool access, and optional skill preloading. They run in their own context window, isolated from the main conversation.

## File Location

```
plugins/cpe/agents/my-agent.md
```

Register in `marketplace.json`:
```json
"agents": ["./agents/my-agent.md"]
```

## Frontmatter Schema

```yaml
---
name: my-agent
description: When to use this agent. Can be multi-line with examples.
tools: Bash, Glob, Grep, Read
skills: cpe:skill-one, cpe:skill-two
model: haiku
color: green
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | kebab-case. Invoked as `cpe:name`. |
| `description` | Yes | When to spawn this agent. Supports multi-line YAML with `|`. |
| `tools` | Yes | Comma-separated. Limits the agent's tool access. |
| `skills` | No | Space or comma-separated `namespace:skill-name`. Preloaded into agent context. |
| `model` | No | Override the model. Use `haiku` for lightweight delegated tasks. Omit to inherit parent model. |
| `color` | No | Visual indicator in the UI. |

### tools values

```
Bash          Shell execution
Glob          File pattern matching
Grep          Content search
Read          File reading
Edit          File editing (use carefully)
Write         File writing (use carefully)
Skill         Load additional skills
Agent         Spawn sub-subagents (use sparingly)
Task          Background task management
WebFetch      URL fetching
WebSearch     Web search
mcp__ide__getDiagnostics   IDE diagnostics (for code review agents)
```

**Principle of least privilege:** Only list the tools the agent actually needs. An agent that only reads files should have `Glob, Grep, Read` — not `Bash`. This prevents accidental side effects and makes the agent's scope clear.

### color values

`red`, `orange`, `yellow`, `green`, `teal`, `blue`, `purple`, `gray`

Use color to signal the agent's domain or risk level:
- `red` — code review, security, critical path
- `green` — release, deployment, green-light operations
- `yellow` — incidents, warnings, triage
- `teal` — investigation, log reading, diagnostic
- `gray` — lightweight utility agents (haiku)
- `orange` — adversarial critique, devil's advocate

### model field

Omit `model` to use the same model as the parent conversation (default).

Use `model: haiku` for:
- Delegated, well-defined tasks with detailed instructions
- High-volume operations (many file reads, repetitive transforms)
- Tasks where speed matters more than reasoning depth

Do not use `haiku` for:
- Complex architectural decisions
- Security reviews
- Anything requiring nuanced judgment

## Agent Body Structure

```markdown
# Purpose / Role Statement

[2-3 sentences establishing who this agent is and what they optimize for.]

[Optional: One "axiom" — a core principle that overrides all other guidance.]

## Workflow

### Phase 1: [Name]
[Instructions with shell commands]

### Phase 2: [Name]
[Instructions with shell commands]

## Output Format

[Required output structure — use code blocks to show the template]

## [Domain-Specific Section]

[Patterns, decision tables, common cases for this agent's domain]
```

## Description Format for Complex Agents

For agents with specific activation patterns, use the multi-line YAML format with examples:

```yaml
description: |
  Use this agent when you want to poke holes in a plan before committing.

  <example>
  Context: User has a deployment plan
  user: "What could go wrong with this approach?"
  assistant: "I'll examine the risks and failure modes."
  </example>

  <example>
  Context: Architecture decision
  user: "Play devil's advocate on this database choice."
  assistant: "I'll examine the real costs and risks."
  </example>
```

The `<example>` tags help Claude understand invocation patterns beyond keyword matching.

## Agent vs. Command: When to Use Each

| Use a **command** when... | Use an **agent** when... |
|--------------------------|--------------------------|
| The task is a linear workflow | The task requires autonomous reasoning and iteration |
| You want to guide the main context | You want an isolated context (won't pollute main thread) |
| The output is a simple report or action | The agent needs to make many tool calls |
| No specialized persona needed | A distinct role/expertise improves the output |
| Task completes in 1-3 steps | Task requires 5+ steps with branching logic |

## Skill Preloading

The `skills:` field preloads skills into the agent's context at spawn time. Use it when:
- The agent will always need that skill (e.g., a security-auditor always needs security-scanning)
- The skill is small enough to justify always loading it

Don't preload skills the agent might use in some cases but not others — let the agent load them via `Skill()` as needed.
