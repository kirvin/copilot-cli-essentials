# Writing Skills

Skills are on-demand knowledge documents loaded via `Skill(cpe:name)`. Each skill lives in its own directory with a required `SKILL.md` and optional `references/` subdirectory.

## File Structure

```
plugins/cpe/skills/my-skill/
├── SKILL.md              # Required
└── references/           # Optional
    ├── topic-a.md
    └── topic-b.md
```

Register in `marketplace.json`:
```json
"skills": ["./skills/my-skill"]
```

Note: register the *directory*, not the SKILL.md file.

## SKILL.md Frontmatter

```yaml
---
name: my-skill
description: What it does and when to use it. Include specific trigger phrases.
---
```

| Field | Required | Notes |
|-------|----------|-------|
| `name` | Yes | kebab-case. Must match the directory name. Used as `cpe:name`. |
| `description` | Yes | How Claude decides when to activate. Max 1024 chars. Most important field. |
| `argument-hint` | No | Rarely used for skills. Prefer putting argument parsing in commands. |

### Writing the description

The description is evaluated at skill-selection time. It needs to answer: "Is this skill relevant to what I'm doing right now?"

**Formula:** `[Action verb] + [what it covers] + [when to use it] + [key triggers]`

```yaml
# Good — specific, includes trigger phrases
description: Guides release versioning, changelog authoring, and GitHub release
  mechanics. Use when planning a release, deciding version bumps, writing
  changelogs, or cutting a tag.

# Bad — too vague
description: Helps with releases.

# Bad — no trigger phrases
description: Contains information about semantic versioning and changelogs.
```

## SKILL.md Body Structure

```markdown
---
name: my-skill
description: ...
---

# Skill Title

**Core principle:** One sentence stating the fundamental "why". (Bold.)

## Topic Selection

| Working on... | Load | File |
|---------------|------|------|
| Specific subtopic A | **Label A** | `references/topic-a.md` |
| Specific subtopic B | **Label B** | `references/topic-b.md` |

Load multiple references when the task spans topics.

---

## Core Principles

### Principle Name
[Content]

---

## Anti-Patterns

| Pattern | Problem |
|---------|---------|
| Common mistake | Why it fails |
```

**Size target:** Under 500 lines. Move detail into references.

## Progressive Disclosure

Skills use three levels:

| Level | Loaded when | Cost |
|-------|-------------|------|
| Frontmatter (name + description) | Always — in system prompt | Always paid |
| SKILL.md body | When Claude activates the skill | Paid on activation |
| Reference files | When Claude reads them via the Topic Selection | Paid on demand |

This means:
- Put routing logic and principles in SKILL.md
- Put detailed how-to, examples, and reference tables in `references/`
- Keep reference files focused on one subtopic (20–150 lines each)
- Never chain references (ref file should not point to another ref file)

## Reference File Conventions

```markdown
# Topic A

[Focused content on one subtopic only]

## Pattern / Decision Table / Code Examples

[Concrete, scannable content — prefer tables and code over prose]
```

- One topic per file
- File name should match the topic: `cpe:ci-cd-pipelines` → `references/security.md` covers pipeline security
- Keep under 150 lines
- No frontmatter needed (reference files are read directly, not as skills)

## Naming

| Rule | Example |
|------|---------|
| Gerund or noun phrase | `writing-tests`, `release-management`, `incident-response` |
| kebab-case only | `code-ownership` not `codeOwnership` |
| Folder name matches `name:` field | folder `writing-tests/` → `name: writing-tests` |
| Descriptive enough to stand alone | `ci-cd-pipelines` not `pipelines` |

## Testing a Skill

After writing, verify:

1. **Activation trigger**: Run a task where the skill should load. Did it?
2. **Non-activation**: Run an unrelated task. Did it stay unloaded?
3. **Reference routing**: When you reach the Topic Selection step, does the right reference file get loaded?
4. **Content quality**: After loading, does following the skill produce the right outcome?

If the skill never loads, the description is too vague — add specific trigger phrases matching what users will say.
If the skill loads for everything, the description is too broad — add scope boundaries.
