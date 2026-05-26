---
name: database-optimization
description: Database optimization combining SQL query tuning, index strategy, EXPLAIN plan analysis, performance profiling, schema design, and HA patterns
---

# Database Optimization - Enhanced Edition

Professional database tuning combining **SQL query optimization**, **index strategy**, **EXPLAIN plan analysis**, **performance profiling**, **schema normalization**, **data migration patterns**, and **HA cluster design**.

## When to Use

- ✅ Optimizing **slow queries**
- ✅ Designing **indexing strategies**
- ✅ Analyzing **EXPLAIN plans**
- ✅ **Connection pooling** optimization
- ✅ **Sharding and replication** design
- ✅ **Query rewriting** for performance
- ✅ **HA cluster** setup (High Availability)

## Core Patterns

### 1. Query Optimization

```sql
-- BEFORE: Slow query (full table scan)
SELECT * FROM users
WHERE created_at > '2024-01-01' AND status = 'active';

-- AFTER: With index
CREATE INDEX idx_users_created_status
ON users(created_at, status)
WHERE status = 'active';

SELECT u.id, u.name, u.email
FROM users u
WHERE u.created_at > '2024-01-01'
  AND u.status = 'active';

-- N+1 Query Problem
-- SLOW: Separate query for each user's posts
SELECT * FROM users;
-- Then loop: SELECT * FROM posts WHERE user_id = $id;

-- FAST: Join in single query
SELECT u.*, p.id as post_id, p.title
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.status = 'active';

-- Or use aggregation
SELECT u.id, u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id;
```

### 2. Index Strategy

```sql
-- Single column index (for WHERE clauses)
CREATE INDEX idx_users_email ON users(email);

-- Composite index (for multiple columns)
CREATE INDEX idx_orders_user_date
ON orders(user_id, created_at DESC)
WHERE status != 'cancelled';

-- Partial index (for specific rows)
CREATE INDEX idx_active_users
ON users(email)
WHERE deleted_at IS NULL;

-- Covering index (includes all needed columns)
CREATE INDEX idx_user_posts_covering
ON posts(user_id)
INCLUDE (title, created_at);

-- Text search index
CREATE INDEX idx_posts_text
ON posts USING GIN (to_tsvector('english', title || ' ' || body));
```

### 3. EXPLAIN Plan Analysis

```sql
-- See query execution plan
EXPLAIN ANALYZE
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id
HAVING COUNT(p.id) > 5;

-- Output interpretation:
-- Seq Scan = Full table scan (SLOW - add index!)
-- Index Scan = Using index (GOOD)
-- Index Only Scan = Index has all data (BEST)
-- Hash Join = Hash-based join (good for large datasets)
-- Nested Loop = Loop through rows (slow with large sets)

-- Cost interpretation:
-- < 1000 = Very fast
-- 1000-10000 = Fast
-- 10000-100000 = Moderate
-- > 100000 = Slow (optimize!)

-- Analyze full query performance
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM large_table WHERE expensive_condition = true;
```

### 4. Connection Pooling

```javascript
const { Pool } = require('pg');

// Create connection pool (5-20 connections optimal)
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'mydb',
  user: 'user',
  password: 'password',
  max: 10, // Max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Use connection from pool
pool.query('SELECT * FROM users WHERE id = $1', [userId])
  .then(result => console.log(result.rows))
  .catch(err => console.error(err));

// With transaction
const client = await pool.connect();
try {
  await client.query('BEGIN');
  await client.query('UPDATE accounts SET balance = balance - $1 WHERE id = $2', [amount, fromId]);
  await client.query('UPDATE accounts SET balance = balance + $1 WHERE id = $2', [amount, toId]);
  await client.query('COMMIT');
} catch (e) {
  await client.query('ROLLBACK');
  throw e;
} finally {
  client.release();
}
```

### 5. Performance Profiling

```python
import time
from contextlib import contextmanager

@contextmanager
def query_timer():
    """Measure query execution time"""
    start = time.time()
    try:
        yield
    finally:
        elapsed = time.time() - start
        print(f"Query executed in {elapsed:.3f}s")

def profile_slow_queries():
    """Identify slow queries"""
    results = db.query("""
        SELECT
            query,
            calls,
            mean_exec_time,
            max_exec_time
        FROM pg_stat_statements
        WHERE mean_exec_time > 100 -- > 100ms
        ORDER BY mean_exec_time DESC
        LIMIT 20;
    """)

    for query in results:
        print(f"Query: {query['query']}")
        print(f"  Avg time: {query['mean_exec_time']:.2f}ms")
        print(f"  Max time: {query['max_exec_time']:.2f}ms")
        print(f"  Calls: {query['calls']}")
```

### 6. Scaling Patterns

**Vertical Scaling (Single server):**
```sql
-- Allocate more RAM to buffer pool
shared_buffers = 25% of RAM
effective_cache_size = 75% of RAM

-- More parallel workers
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
```

**Horizontal Scaling (Sharding):**
```javascript
// Shard by user_id
function getShardKey(userId) {
  return userId % NUM_SHARDS;
}

function getDatabase(shardKey) {
  const databases = [
    'db_shard_0', 'db_shard_1', 'db_shard_2', 'db_shard_3'
  ];
  return databases[shardKey];
}

// Query sharded data
async function getUserPosts(userId) {
  const shard = getShardKey(userId);
  const db = getDatabase(shard);

  return db.query(
    'SELECT * FROM posts WHERE user_id = $1',
    [userId]
  );
}
```

**Replication:**
```javascript
// Read-write splitting
const writeDB = new Pool({...primaryConfig});
const readDB = new Pool({...replicaConfig});

async function getUserData(userId) {
  // Write operations
  await writeDB.query('UPDATE users SET last_login = NOW() WHERE id = $1', [userId]);

  // Read operations (from replica for better performance)
  return await readDB.query('SELECT * FROM users WHERE id = $1', [userId]);
}
```

### 7. Schema Design

```sql
-- NORMALIZATION (avoid data duplication)

-- BAD: Denormalized (duplicated email in orders)
CREATE TABLE orders (
  id INT PRIMARY KEY,
  user_email VARCHAR(255),
  user_name VARCHAR(255),
  product_name VARCHAR(255)
);

-- GOOD: Normalized (foreign keys reference)
CREATE TABLE users (
  id INT PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  name VARCHAR(255)
);

CREATE TABLE orders (
  id INT PRIMARY KEY,
  user_id INT REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
  id INT PRIMARY KEY,
  order_id INT REFERENCES orders(id),
  product_id INT REFERENCES products(id),
  quantity INT,
  price DECIMAL(10, 2)
);

-- Proper relationships
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
```

## Monitoring & Alerting

```sql
-- Monitor active queries
SELECT
  pid,
  usename,
  query,
  duration,
  state
FROM pg_stat_activity
WHERE state = 'active'
  AND duration > INTERVAL '10 minutes';

-- Monitor table sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 20;

-- Set query timeouts
SET statement_timeout = '30s';

-- Monitor replication lag
SELECT
  slot_name,
  restart_lsn,
  confirmed_flush_lsn
FROM pg_replication_slots;
```

## Common Use Cases

1. **Slow Query Diagnosis** → Use EXPLAIN to identify bottlenecks
2. **Index Design** → Create strategic indexes for common queries
3. **Bulk Operations** → Optimize inserts and updates
4. **Reporting Queries** → Separate OLAP from OLTP traffic
5. **HA Setup** → Replicate for resilience

---

**Enhanced version combining query optimization, indexing, EXPLAIN analysis, connection pooling, profiling, scaling patterns, and schema design.**
