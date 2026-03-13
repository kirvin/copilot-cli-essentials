# PR Review Standards

## What a Good Review Looks Like

A high-quality review does three things:
1. **Validates correctness** — the code does what it claims
2. **Assesses risk** — surfaces issues before they hit production
3. **Transfers knowledge** — reviewer understands the change, not just approves it

A review that just says "LGTM" is not a review. It's a signature.

## Review Checklist

**Correctness:**
- [ ] Does the code do what the PR description says?
- [ ] Are edge cases handled? (empty input, null, overflow, concurrent access)
- [ ] Are error paths handled and meaningful?
- [ ] Is the change backward-compatible (or is breaking change documented)?

**Security:**
- [ ] Is user input validated/sanitized?
- [ ] Are authorization checks in place?
- [ ] No secrets or credentials in code?
- [ ] Dependencies introduced — are they trusted and necessary?

**Quality:**
- [ ] Is the code readable without needing the PR description?
- [ ] Are functions/methods doing one thing?
- [ ] Is there unnecessary complexity?
- [ ] Are tests included and meaningful?

**Observability:**
- [ ] Are key operations logged?
- [ ] Are metrics/traces instrumented for new code paths?
- [ ] Will failures surface in alerts?

## Giving Feedback

**Be specific.** Vague feedback is unhelpful.

| Instead of... | Say... |
|---------------|--------|
| "This could be cleaner" | "Extract this into a function — it's called in 3 places" |
| "This is wrong" | "This will fail if `user` is null — add a null check before line 42" |
| "Good job" | "Smart use of the debounce here — that prevents the race condition" |

**Tag severity.** Use prefixes so the author knows what's required vs. optional:

```
nit: minor style suggestion (optional to address)
suggestion: improvement worth considering (optional)
question: I don't understand this — explain or document?
issue: functional problem that must be fixed
blocker: must be addressed before merge
```

**Distinguish blocking from non-blocking.** Clearly mark whether each comment requires action before merge.

## Reviewing Efficiently

- Read the PR description before the diff
- Look at test changes first — they reveal intent
- For large PRs, review commit-by-commit rather than as a monolithic diff
- Ask questions before assuming intent: "Why did you choose X over Y?" not "X is wrong"

## PR Size Guidelines

| Lines changed | Review time | Recommendation |
|--------------|-------------|----------------|
| < 100 | Minutes | Ideal |
| 100–400 | 30–60 min | Acceptable |
| 400–1000 | Hours | Break it up |
| > 1000 | Days | Must be split |

If you receive a 1000-line PR with no context, it's okay to ask the author to split it before reviewing.
