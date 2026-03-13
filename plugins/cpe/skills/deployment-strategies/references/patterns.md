# Deployment Patterns

## All-at-Once (Simple Deploy)

Replace all instances simultaneously. Fastest to deploy, highest blast radius.

```bash
# Deploy new version
./scripts/deploy.sh production

# Rollback: redeploy previous version
git checkout v1.1.0
./scripts/deploy.sh production
```

**Use when:** Small teams, low traffic, fast redeploy, non-critical services.

---

## Rolling Deploy

Replace instances gradually (10% → 50% → 100%). GitHub Actions default for most cloud platforms.

```yaml
# GitHub Actions with rolling deploy
- name: Deploy
  run: |
    # Deploy to 10% of servers first
    aws ecs update-service \
      --cluster production \
      --service my-service \
      --deployment-configuration "deploymentCircuitBreaker={enable=true,rollback=true}"
```

**Rollback:** Re-deploy the previous version; rolling update reverses.

---

## Blue/Green

Maintain two identical environments. Route traffic to "blue" (current). Deploy to "green" (new). Switch traffic. Old environment is instant rollback.

```bash
# Route 100% to green
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$GREEN_TARGET_GROUP

# Rollback: route back to blue
aws elbv2 modify-listener \
  --listener-arn $LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TARGET_GROUP
```

**Rollback time:** Seconds (DNS/load balancer switch).

**Cost:** Double the infrastructure during deploy window.

---

## Canary Release

Route a small percentage of traffic to the new version. Monitor. Expand gradually.

```yaml
# GitHub Actions with canary steps
jobs:
  deploy-canary:
    steps:
      - name: Deploy to 5% of traffic
        run: ./deploy.sh --canary 5

      - name: Monitor for 10 minutes
        run: ./scripts/monitor-canary.sh --duration 600 --threshold 0.1

      - name: Expand to 50%
        if: success()
        run: ./deploy.sh --canary 50

      - name: Full rollout
        if: success()
        run: ./deploy.sh --canary 100
```

**Rollback:** Route 0% to canary, drain connections.

---

## Comparing Rollback Speeds

| Strategy | Time to rollback | Data risk |
|----------|-----------------|-----------|
| All-at-once | Minutes (re-deploy) | Medium |
| Rolling | Minutes | Low |
| Blue/Green | Seconds | Low |
| Canary | Seconds (route to 0%) | Minimal |
| Feature flag | Seconds (toggle off) | None |
