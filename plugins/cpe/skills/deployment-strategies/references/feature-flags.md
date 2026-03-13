# Feature Flags

## Why Feature Flags

Feature flags decouple **deploying code** from **releasing features**. With flags:
- Code ships continuously to production
- Features release on demand, to specific users, or at specific times
- High-risk changes can be enabled for internal users first
- Rollback is instant — toggle the flag, no redeploy needed

## Implementation Patterns

### Environment variable flags (simple)

```javascript
// Simple boolean flag from env
const NEW_DASHBOARD = process.env.FEATURE_NEW_DASHBOARD === 'true';

if (NEW_DASHBOARD) {
  return <NewDashboard />;
}
return <OldDashboard />;
```

### Config-file flags (team-wide)

```json
// flags.json — committed to repo
{
  "new-dashboard": false,
  "bulk-import": true,
  "ai-suggestions": false
}
```

### User-targeting flags (production)

For production feature rollouts, use a flag service (LaunchDarkly, Unleash, Split, Flagsmith):

```javascript
// LaunchDarkly example
const showNewDashboard = await ldClient.variation(
  'new-dashboard',
  { key: user.id, email: user.email },
  false  // default value
);
```

## Rollout Stages

1. **Internal** — company employees only (catch obvious bugs)
2. **Beta** — opt-in users (gather feedback)
3. **Canary** — 5% of all users (monitor metrics)
4. **Progressive** — 25% → 50% → 100% (expand if stable)
5. **GA** — flag removed, code ships unconditionally

## Flag Hygiene

Flags accumulate debt. Every flag should have:
- An owner
- A target removal date
- An issue tracking removal

```bash
# Find old flags in the codebase
grep -rn "FEATURE_\|featureFlag\|feature_flag" --include="*.js" --include="*.ts" . \
  | grep -v node_modules | head -20
```

Remove flags within one sprint of full rollout. Permanent flags become permanent complexity.

## Testing with Flags

Always test both flag states in CI:

```javascript
describe('Dashboard', () => {
  it('renders new dashboard when flag enabled', () => {
    mockFlag('new-dashboard', true);
    render(<Dashboard />);
    expect(screen.getByTestId('new-dashboard')).toBeInTheDocument();
  });

  it('renders old dashboard when flag disabled', () => {
    mockFlag('new-dashboard', false);
    render(<Dashboard />);
    expect(screen.getByTestId('old-dashboard')).toBeInTheDocument();
  });
});
```
