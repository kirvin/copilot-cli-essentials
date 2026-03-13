# Database Migrations

## The Fundamental Problem

Code and database schema change together, but they don't deploy atomically. During a rolling deploy, old code and new code run simultaneously against the same database.

**Never write a migration that:**
- Drops a column that old code reads
- Renames a column that old code uses
- Changes a constraint that old code violates
- Removes a table that old code queries

## Expand-Contract Pattern

The safest migration pattern for zero-downtime deploys.

### Phase 1: Expand (backward-compatible schema change)
Deploy the new schema in a way that both old and new code can work with it.

```sql
-- Add new column (nullable so old code doesn't break)
ALTER TABLE users ADD COLUMN display_name VARCHAR(255);

-- Add new index
CREATE INDEX CONCURRENTLY idx_users_display_name ON users(display_name);
```

### Phase 2: Migrate (deploy new code)
Deploy code that writes to both old and new columns / reads from new column.

```javascript
// Write to both during transition
await db.query(
  'UPDATE users SET display_name = full_name WHERE id = $1',
  [user.id]
);
```

### Phase 3: Backfill (populate existing rows)
Fill in historical data in the new column/table.

```sql
-- Backfill in batches to avoid table locks
UPDATE users SET display_name = full_name
WHERE id IN (
  SELECT id FROM users WHERE display_name IS NULL LIMIT 1000
);
```

### Phase 4: Contract (remove old schema)
Deploy code that only uses the new column. Then remove the old column.

```sql
-- Safe to drop now — no code references it
ALTER TABLE users DROP COLUMN full_name;
```

## Migration Anti-Patterns

```sql
-- DANGEROUS: Rename column (breaks old code immediately)
ALTER TABLE users RENAME COLUMN name TO full_name;

-- DANGEROUS: Drop column (breaks old code immediately)
ALTER TABLE users DROP COLUMN legacy_field;

-- DANGEROUS: Change column type (may break constraints)
ALTER TABLE users ALTER COLUMN status TYPE INTEGER;  -- was VARCHAR
```

## Testing Migrations

Always test migrations against a copy of production data:

```bash
# Restore production snapshot to test DB
pg_restore -d test_db production_snapshot.dump

# Run migration
npm run db:migrate -- --env test

# Verify data integrity
psql test_db -c "SELECT COUNT(*) FROM users WHERE display_name IS NULL"

# Run migration rollback
npm run db:rollback -- --env test
```

## CI/CD Integration

```yaml
jobs:
  test:
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_DB: test_db

    steps:
      - run: npm run db:migrate
      - run: npm test
      - run: npm run db:rollback  # Verify rollback works
```

Every migration must have a working rollback. No exceptions.
