# CI/CD Scaling — Matrix Builds, Parallelism, Environments

## Matrix Builds

Run the same job across multiple dimensions simultaneously.

```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: ['18', '20', '22']
        exclude:
          - os: windows-latest
            node: '18'    # Skip specific combinations
      fail-fast: false    # Don't cancel all when one fails
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
```

## Dynamic Matrix

Generate matrix entries from a script:

```yaml
jobs:
  setup:
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - id: set-matrix
        run: echo "matrix=$(find packages -maxdepth 1 -type d | jq -Rc '[.,inputs]')" >> $GITHUB_OUTPUT

  test:
    needs: setup
    strategy:
      matrix:
        package: ${{ fromJson(needs.setup.outputs.matrix) }}
```

## Parallel Test Splitting

Split a large test suite across multiple runners:

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - run: npx jest --shard=${{ matrix.shard }}/4
```

## Deployment Environments

```yaml
jobs:
  deploy-staging:
    environment:
      name: staging
      url: https://staging.app.example.com
    steps:
      - run: ./deploy.sh staging

  deploy-production:
    needs: deploy-staging
    environment:
      name: production       # Requires manual approval if configured
      url: https://app.example.com
    steps:
      - run: ./deploy.sh production
```

## Reusable Workflows

Extract shared logic into reusable workflows:

```yaml
# .github/workflows/test.yml (reusable)
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '20'
    secrets:
      NPM_TOKEN:
        required: false

# Caller
jobs:
  test:
    uses: ./.github/workflows/test.yml
    with:
      node-version: '22'
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```
