---
name: rtsql-docs
description: "Use when working with the rtsql CLI or install.sh: install, create, query, back up, restore, import, analyze, encrypt, troubleshoot, or uninstall an RTsql database. Provides safe one-shot workflows, storage paths, failure handling, and cleanup rules."
compatibility: "RTsql CLI on Linux or macOS; Bash and standard Unix user tools for install.sh."
metadata:
  author: RTsql
  version: "0.2.0"
---

# RTsql Operations

[English README](../README.md) | [简体中文 README](../README.zh-CN.md)

Use this skill to operate an RTsql database from a shell or an automated agent. RTsql is a one-shot CLI: each invocation opens a database, performs the requested work, closes the database, and exits. It has no interactive REPL or database server.

## Operating rules

- Run installation commands from a trusted RTsql source checkout.
- Use an isolated `RTSQL_HOME` for examples, tests, and migrations.
- Treat SQL text, dump files, and database files as untrusted input.
- Quote SQL as one shell argument. Use semicolons only when multiple statements are intended.
- Use an explicit `--format` in automation so output does not depend on TTY detection.
- Keep `BEGIN`, its statements, and `COMMIT` or `ROLLBACK` in one invocation.
- Do not retry exit code `4` blindly; another RTsql process owns the database lock.
- Do not retry encryption errors with guessed keys. Confirm the database type and key source first.
- Use `RTSQL_KEY` instead of a command-line key when process arguments may be visible. Environment variables are not a secret store.
- Obtain explicit approval before running `install.sh --uninstall --purge-data`.

## Install and deploy

### Prerequisites

Check the build tools before installing:

```bash
command -v cargo
rustc --version
bash --version
command -v strip
```

RTsql targets Linux and macOS. `strip` is optional; the installer skips it with a warning when it is unavailable. The installer does not use `sudo` and does not download anything outside Cargo's normal build behavior.

### Install

From the repository root:

```bash
./install.sh
source ~/.bashrc
rtsql --version
```

The default installation is `$HOME/.local/bin/rtsql`. The installer:

1. Checks for `cargo`.
2. Builds the release binary in the repository.
3. Strips the binary when `strip` is available.
4. Installs `$PREFIX/bin/rtsql`.
5. Installs completions for the detected shell.
6. Adds the selected binary directory to `$HOME/.bashrc` when the matching PATH export is absent.

Opening a new terminal is equivalent to `source ~/.bashrc`. The current shell does not receive the new PATH value until it reloads the file.

Use another installation prefix:

```bash
PREFIX_DIR=$(mktemp -d)
./install.sh --prefix "$PREFIX_DIR"
source ~/.bashrc
rtsql --version
```

Skip completion installation:

```bash
./install.sh --prefix "$PREFIX_DIR" --no-completions
```

`--prefix` changes the binary location. Completions remain in the standard user directories:

| Shell | Completion file |
|---|---|
| bash | `~/.local/share/bash-completion/completions/rtsql` |
| zsh | `~/.zsh/completions/_rtsql` |
| fish | `~/.config/fish/completions/rtsql.fish` |

For zsh, add `~/.zsh/completions` to `fpath` when needed. Generate a completion script without installing it:

```bash
rtsql completions bash > rtsql.bash
rtsql completions zsh > _rtsql
rtsql completions fish > rtsql.fish
```

The `completions` command is hidden from `rtsql --help` and does not open a database.

Build without installing:

```bash
cargo build --release
./target/release/rtsql --version
```

## Resolve a database

A database argument follows two rules:

- A bare name such as `demo` resolves to `$RTSQL_HOME/db/demo.db`.
- An argument containing `/`, such as `./demo.db` or `/var/lib/rtsql/demo.db`, is used as a file path.

`RTSQL_HOME` defaults to `$HOME/.rtsql`. Use a separate home for automation:

```bash
export RTSQL_HOME=$(mktemp -d)
rtsql new demo
rtsql list
```

A subcommand name takes precedence over a bare database name. To open a database literally named `list`, use a path such as `./list.db`.

`:memory:` is a reserved main-command target for a database that never touches disk:

```bash
rtsql :memory: "CREATE TABLE t (id INTEGER PRIMARY KEY, name TEXT); INSERT INTO t VALUES (1, 'Ada'); SELECT name FROM t"
```

It creates no `.db`, `.wal`, or `.checkpoint` file, `close()` and `checkpoint()` do nothing, and the data is gone when the process exits. Use it for tests, throwaway calculations, and multi-statement pipelines that should leave no cleanup behind. Reject other lifecycle subcommands, `--key`, and `--readonly` for `:memory:` with exit code `2` instead of silently ignoring them; the one exception is `import`, which works and leaves nothing behind (with `--key` it is still refused).

## Command reference

### Main command

`rtsql <db> <sql>` opens the database, runs the SQL, and exits. `<db>` is a bare name or a file path (see Resolve a database). `:memory:` targets a throwaway in-memory database instead.

| Surface | Effect |
|---|---|
| `--format <table\|json\|csv\|tsv>` | Output format; default is `table` on a TTY and `json` otherwise. Global flag. |
| `--key <key>` | Key for an encrypted database; `RTSQL_KEY` is the fallback. Global flag; applies to every command that opens a database. |
| `--busy-timeout <ms>` | Lock wait budget in milliseconds (default 5000); `0` waits only for an internal ~8 ms visibility floor. Applies to every command that opens a database, for the exclusive and the read-only shared lock alike; an explicit flag wins over `RTSQL_BUSY_TIMEOUT`. `:memory:` accepts and ignores it; the `delete` lock probe never waits. |
| `--readonly` | Open the main database read-only (shared advisory lock; writes are refused at plan time with SQLSTATE `25006`, exit `3`). Main command only; rejected with exit `2` alongside a subcommand. |
| `;`-separated statements | Each statement runs as its own auto-commit transaction, in order, with fail-fast reporting (`statement k of n failed`). Wrap atomic work in `BEGIN` … `COMMIT` inside one invocation. |

### Lifecycle subcommands

| Command | Example | Effect |
|---|---|---|
| `new` | `rtsql new demo` | Create an empty database; fails if the target already exists. This is the only creation channel for a missing database. |
| `list` | `rtsql list` | Enumerate `$RTSQL_HOME/db/*.db` without opening the files. |
| `schema` | `rtsql schema demo` | Print user-table DDL. |
| `dump` | `rtsql dump demo > demo.sql` | Export SQL text (`CREATE TABLE` + `INSERT` rows). A missing or damaged data-page chain is reported on stderr (see Behavioral notes) while the reachable part is still exported. |
| `restore` | `rtsql restore demo-restored demo.sql` | Load a dump into an existing, still-empty target database (create it with `new` first); `-` reads the dump from stdin. |
| `import` | `rtsql import demo people people.csv --csv` | Load a CSV file into a table (`--csv` required). The target table may already exist (header must match its column names) or it is auto-created from the CSV header with inferred types. `-` reads the CSV from stdin. Rows commit one by one. |
| `delete` | `rtsql delete demo --dry-run` | Remove a database file and its `.wal`/`.checkpoint` sidecars and report each file. `--dry-run` previews only; a locked file is refused with exit `4`. |
| `checkpoint` | `rtsql checkpoint demo` | Force a checkpoint: truncate the WAL and advance the checkpoint site so committed data is stable — the clean sync point before an external backup or file handoff. Prints one confirmation line; a clean database reports `no pending work` and still exits `0`. A missing database is exit `1`; a lock conflict waits out `--busy-timeout` and then exits `4`. |
| `check` | `rtsql check demo` | Read-only structural integrity scan (page census, catalog, data/overflow chains, index trees). One line per finding with its page and cause; a clean database prints a single confirmation. Exit `0` clean, `1` on error-level findings (informational findings do not change the code), `4` lock conflict, `5` wrong key; `:memory:` and `--readonly` combinations are usage errors (`2`). Never repairs or modifies the file; a database with pending WAL is refused at open (exit `1`) — open it read-write once to recover, then check. `--format` is accepted and ignored. |
| `stats` | `rtsql stats demo people` | Per-column row count, null rate, distinct count, min/max, numeric percentiles. |
| `sample` | `rtsql sample demo people 5` | Reservoir sample of N rows; default 10, `N` of `0` or a non-integer is a usage error. |
| `profile` | `rtsql profile demo people --top 10` | Frequent values for String columns; default top 5, maximum 20. |

### Environment variables

| Variable | Effect |
|---|---|
| `RTSQL_HOME` | Base directory for bare-name resolution (`<home>/db/<name>.db`); defaults to `$HOME/.rtsql`. |
| `RTSQL_KEY` | Default key for encrypted databases; an explicit `--key` wins. An empty value is refused with exit `2`. |
| `RTSQL_WAL_CHECKPOINT_BYTES` | Auto-checkpoint threshold in bytes (default 16 MiB); `0` disables. An invalid value is refused before the database opens with exit `2`. |
| `RTSQL_BUSY_TIMEOUT` | Default lock wait budget in milliseconds (default 5000); `0` waits only for the internal ~8 ms visibility floor. An invalid value is refused before any database opens with exit `2`; an explicit `--busy-timeout` wins. |

### Exit codes

| Code | Meaning |
|---:|---|
| 0 | Success |
| 1 | General error: I/O, storage, missing database, or output format |
| 2 | CLI usage error (bad flag combination, empty key, invalid environment value) |
| 3 | SQL parse or execution error |
| 4 | Database is locked by another process |
| 5 | Encryption-key error |
| 130 | SIGINT received |
| 143 | SIGTERM received |

Per-code action guidance is in Select output and handle failures.

### Behavioral notes

- The main command does not create a missing database. A missing bare name or path is refused with exit `1` and a `rtsql new <name>` hint, and no file is created. The `new` subcommand and the library API keep their creation behavior.
- `dump` runs a data-page chain integrity precheck for each user table. When a table's page chain ends before the catalog-persisted tail page, one warning line goes to stderr — naming the table, the catalog tail page, and the chain end — while the reachable rows are still exported. stdout stays pure SQL and the exit code stays `0`.
- `dump` renders `PRIMARY KEY` in the exported DDL only when the primary-key column is declared `INTEGER` (the only form the engine enforces). Dumps produced by older versions that embed a non-integer `... PRIMARY KEY` DDL fail `restore` on a new database (plan-time refusal, exit 3) — that declaration was never enforced; re-dump with the current version or edit the DDL.
- `rtsql check <db>` scans the whole file read-only: it never repairs, never writes, and leaves the file byte-identical. After a crash recovery the data chain can legitimately terminate on a page ahead of the persisted catalog tail (the replay advances the tail in memory only); `check` reports that as an informational line (`benign after crash recovery`) without changing the exit code, while a chain that ends before the persisted tail is an error.
- `SELECT` resolves `FROM` table aliases across all clauses: qualified references such as `u.id` work in `SELECT`, `ON`, `WHERE`, `GROUP BY`, aggregate arguments, and `ORDER BY`; an unknown qualifier is a plan-time error.
- Long values are transparent: a row value larger than the single-page inline capacity (~4KB) is stored through overflow page chains with no artificial limit. `INSERT`/`UPDATE`/`SELECT`, `dump`/`restore`, and `import` round-trip oversized values unchanged (the internal switch between the ≤65535-byte and long-string representations is invisible to users), and crash recovery, `DROP TABLE`/`TRUNCATE`, encrypted databases, `:memory:`, and read-only sessions handle them the same way. The one visible bound: a `DEFAULT` literal lives in the catalog's in-page column row (~4KB), so an oversized default is refused at `CREATE TABLE` with the existing page-full error, while written values have no such limit.

## Execute SQL

The main command accepts a database and SQL text:

```bash
rtsql <db> <sql>
rtsql --format <table|json|csv|tsv> <db> <sql>
```

Create and query a table:

```bash
rtsql new demo
rtsql demo "CREATE TABLE people (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)"
rtsql --format table demo "INSERT INTO people VALUES (1, 'Ada', 36), (2, 'Lin', 41)"
rtsql --format table demo "SELECT id, name, age FROM people WHERE age >= 40"
rtsql schema demo
```

Without an explicit transaction, each semicolon-separated statement is committed independently. If a later statement fails, earlier statements may already be committed. The error identifies the failed statement.

### Transactions

Keep the complete transaction in one invocation:

```bash
rtsql --format table demo "BEGIN; INSERT INTO people VALUES (3, 'Kai', 22); COMMIT;"
rtsql --format table demo "BEGIN; INSERT INTO people VALUES (4, 'Mira', 29); ROLLBACK;"
rtsql --format table demo "SELECT id, name FROM people ORDER BY id"
```

`COMMIT` makes the transaction durable through the normal WAL and close path. `ROLLBACK` discards its writes. If input ends with an active transaction, RTsql rolls it back, reports the rollback on stderr, and keeps exit code `0` for the completed CLI action.

Do not send `BEGIN` in one process and `COMMIT` in another.

### Cross-database sessions

One invocation can `ATTACH` other database files and address them with qualified names; bare names keep pointing at the main database:

```bash
rtsql new orders
rtsql orders "CREATE TABLE recent (id INTEGER PRIMARY KEY, name TEXT)"
rtsql demo "ATTACH 'orders' AS o; \
  INSERT INTO o.recent SELECT id, name FROM people WHERE age >= 40; \
  SELECT COUNT(*) FROM o.recent"
```

Writes on `alias.table` execute against that file with its own transaction and WAL, and each file commits independently — a later failing statement does not undo earlier per-file commits. Writes to an attached target inside `BEGIN` are refused with SQLSTATE `0A000` before any row is touched; main-database writes keep the full transaction semantics, DDL on an attached target is refused at plan time, and a `--readonly` session opens attached databases read-only. `INSERT ... SELECT` materializes the source rows first, so it can join across databases or write back into its own target, support `ON CONFLICT` / `REPLACE INTO`, and reports `affected_rows: 0` for an empty source. There is no `DETACH`: attached databases stay registered until the invocation ends, which is one reason to keep a multi-database job in a single invocation.

### SQL capability surface

Beyond the examples above, the engine implements a practical relational core:

| Area | Supported |
|---|---|
| Read | `INNER`/`LEFT`/`RIGHT`/`FULL` joins; `SELECT DISTINCT`; `UNION [ALL]`/`INTERSECT`/`EXCEPT`; non-recursive `WITH` (CTE); scalar and `IN` subqueries, correlated included; `CASE`/`COALESCE`/`CAST`; `LIKE`/`IN`/`BETWEEN`/`IS NULL`; `ORDER BY` by output alias or qualified name; `FROM` table aliases in every clause; expressions without `FROM` (`SELECT 1+1`) |
| Aggregate | `COUNT`/`SUM`/`AVG`/`MIN`/`MAX` (each with `DISTINCT`), `group_concat`, `GROUP BY` expressions and aliases, `HAVING`. Aggregates nest inside SELECT value expressions (`SELECT MAX(id) + 1`, `COALESCE(MAX(id), 0)`), `HAVING` conditions (`HAVING MAX(id) + 1 > 2`), and aggregate-query `ORDER BY` keys (`ORDER BY MAX(v)`); a select list can mix aggregates with plain constants (`SELECT MAX(id), 1`), and the same aggregate call appearing several times shares one output column. Still refused at plan time: aggregates inside `WHERE` or `JOIN ... ON`, aggregate nesting (`MAX(MIN(x))`), and a non-aggregated column reference without `GROUP BY` |
| Write | `UPDATE` and `DELETE`; subset-column `INSERT` with `DEFAULT`; `ON CONFLICT DO NOTHING` / `DO UPDATE SET`; `REPLACE INTO`; writes are type-checked against column declarations before any row changes, and declared `DEFAULT` literals are validated the same way at plan time (a FLOAT column upgrades an integer literal; a DATE/TIMESTAMP column parses the string; other mismatches refuse the statement with zero side effects). `UPDATE ... SET` accepts several assignments at once and full value expressions on the right-hand side — column references evaluate against the row's old values as one snapshot (`SET v = v + 1`; `SET a = a + 1, b = a` reads the old `a`), plus arithmetic, `CAST`, `CASE`, `COALESCE`, and scalar functions. Aggregate calls and subqueries on the right-hand side are refused at plan time |
| Schema | `CREATE TABLE` with `NOT NULL`, an `INTEGER` `PRIMARY KEY`, and single-column `INTEGER` `UNIQUE` — these are enforced at write time. `UNIQUE` on a non-integer column or a composite `UNIQUE` is refused at plan time (declare them as refused rather than silently unenforced), and an explicit non-integer `PRIMARY KEY` is refused at plan time — declare `INTEGER` when you need an enforced key (databases created before this rule keep working: their non-integer primary-key tables open, read, and dump normally, with the DDL rendered without `PRIMARY KEY` so `dump` → `restore` round-trips them). `ALTER TABLE ADD/DROP COLUMN`; `TRUNCATE TABLE`; `CREATE`/`DROP INDEX`; `CREATE`/`DROP VIEW` (views are read-only — DML on a view is refused); `DROP TABLE` |
| Types | `INTEGER`, `FLOAT`, `TEXT`, `BOOLEAN`, `DATE`, `TIMESTAMP`, with date functions such as `now`, `date_trunc`, `datediff` |
| Functions | String: `upper`, `lower`, `length`, `substr`, `replace`, `trim`; math: `abs`, `round`, `floor`, `ceil`; date/time: `now`, `date`, `year`, `month`, `day`, `hour`, `minute`, `second`, `date_trunc`, `datediff`. Arguments are strictly typed with no implicit conversion; unregistered function names are refused at plan time |
| Sessions | `BEGIN`/`COMMIT`/`ROLLBACK` in one invocation; `ATTACH` with cross-database reads and routed writes (per-file commits; writes to an attached target inside `BEGIN` refuse with `0A000`); `INSERT ... SELECT` into main or attached targets; `CREATE TABLE AS SELECT`; `EXPLAIN SELECT` plan-tree text |

Refused at plan time with the capability named, never silently ignored: `CHECK` and `FOREIGN KEY` constraints, an explicit non-integer `PRIMARY KEY`, recursive CTEs, window functions, qualified wildcards (`SELECT t.*`), triggers, writes to views, and non-storable column types (time-zone-aware timestamps, `TIME`, `INTERVAL`). One honest exception to know: other type keywords beyond the six above (such as `DECIMAL` or `BLOB`) parse successfully and the column is created as `TEXT` — declare `TEXT` explicitly when text storage is what you want.

## Manage data

### Create and inspect

```bash
rtsql new demo
rtsql new ./local.db
rtsql list
rtsql schema demo
```

`new` creates an empty database and fails if the target already exists. `list` enumerates `$RTSQL_HOME/db/*.db` without opening the listed databases. `schema` prints user-table DDL.

### Evolve schema

Structure can be changed in place; a full dump → `new` → restore cycle is only needed for encryption migration or a fresh copy:

```bash
rtsql demo "ALTER TABLE people ADD COLUMN email TEXT"
rtsql demo "ALTER TABLE people DROP COLUMN age"
rtsql demo "TRUNCATE TABLE staging"
rtsql demo "CREATE INDEX idx_people_name ON people (name)"
rtsql demo "EXPLAIN SELECT id FROM people WHERE name = 'Ada'"
```

- `ALTER TABLE` accepts one operation per statement. `ADD COLUMN` appends at the tail; existing rows read back the declared `DEFAULT` or NULL (`NOT NULL` without `DEFAULT` is refused on a non-empty table); the declared `DEFAULT` is validated against the column type exactly like `CREATE TABLE` (a FLOAT column upgrades an integer literal, a DATE/TIMESTAMP column parses the string, other mismatches are refused with the table unchanged). `DROP COLUMN` rewrites the table in one implicit transaction — all rows or none — and refuses a column referenced by an index or the last remaining column.
- `TRUNCATE` empties a table and releases its data pages immediately, keeping the definition and index definitions (indexes rebuild empty).
- `CREATE INDEX` builds a secondary index on a single integer column (non-unique; `UNIQUE` comes from the column constraint) and backfills existing rows; `DROP INDEX` removes it.
- `EXPLAIN SELECT` prints the plan tree without executing the query.

### Dump and restore

```bash
rtsql dump demo > demo.sql
rtsql new demo-restored
rtsql restore demo-restored demo.sql
rtsql --format table demo-restored "SELECT id, name, age FROM people ORDER BY id"
```

Read a dump from stdin:

```bash
rtsql new demo-stdin
rtsql dump demo | rtsql restore demo-stdin -
```

A restore target must be empty. Dump files contain SQL and row data in plaintext; protect them as plaintext database exports.

### Import CSV

`import` loads a CSV file (`--csv` required) into a table, committing each row and stopping at the first conversion or execution error. The file argument is a path, or `-` to read the CSV from stdin.

When the target table already exists, the CSV header must match its column names:

```bash
cat > people.csv <<'CSV'
id,name,age
3,Kai,22
4,Mira,29
CSV
rtsql import demo people people.csv --csv
```

When the target table does not exist, it is auto-created from the CSV header. Each column's type is inferred from its data: an all-integer column becomes `INTEGER`, a column mixing integers and decimals becomes `FLOAT`, and an all-empty column becomes `TEXT`; a column that mixes text with numbers is a type conflict and refuses the import with zero side effects. The first column becomes the implicit primary key (the engine default for a table without a declared one), so when that column is integer-typed, duplicate first-column values fail fast with exit `3` — a `FLOAT` or `TEXT` first column accepts duplicates. Duplicate headers are refused at plan time the same way. Auto-created imports go through the regular `CREATE TABLE` channel, so the same declaration rules apply:

```bash
echo 'id,score
1,9.5' | rtsql import demo measurements - --csv
echo 'id,name
1,Ada' | rtsql import :memory: people - --csv   # in-memory import: nothing left behind
```

A file-based import against a missing database is exit `1` with no file created; `:memory:` is accepted for `import` (and `import` only) while `--key` on an in-memory import is a usage error, exit `2`.

### Analyze data

```bash
rtsql --format table stats demo people
rtsql --format table sample demo people 5
rtsql --format table profile demo people --top 10
```

- `stats` reports count, null rate, distinct count, minimum, maximum, and numeric percentiles.
- `sample` uses reservoir sampling and defaults to 10 rows.
- `profile` reports column metadata and frequent values for String columns. The default top count is 5 and the maximum is 20.

## Use encrypted databases

Create an encrypted database and open every database command with its key:

```bash
rtsql new secure --key 'replace-with-a-password'
rtsql --key 'replace-with-a-password' secure "CREATE TABLE notes (id INTEGER PRIMARY KEY, body TEXT)"
rtsql --key 'replace-with-a-password' secure "INSERT INTO notes VALUES (1, 'private')"
rtsql --key 'replace-with-a-password' secure "SELECT id, body FROM notes"
```

Use the environment channel when process arguments should not contain the key:

```bash
RTSQL_KEY='replace-with-a-password' rtsql secure "SELECT id, body FROM notes"
```

`--key` overrides `RTSQL_KEY` and applies to every command that opens a database. `list` does not open a database and is unaffected.

| Condition | Exit | Action |
|---|---:|---|
| Encrypted database, no key | 5 | Supply `--key` or `RTSQL_KEY` |
| Plaintext database, key supplied | 5 | Check the database type and remove the key |
| Wrong key | 5 | Confirm the intended key; do not guess |
| Corrupted encrypted page | 5 | Treat the authentication failure as possible page damage |
| Empty key | 2 | Correct the key before opening a database |

Migrate between plaintext and encrypted databases with dump and restore:

```bash
rtsql dump plaintext-db > database.sql
rtsql new encrypted-copy --key 'replace-with-a-password'
rtsql --key 'replace-with-a-password' restore encrypted-copy database.sql
```

Restore into a target created without a key for the reverse migration. Encryption covers the main database file only; `.wal`, `.checkpoint`, and dump output remain plaintext.

## Select output and handle failures

Use an explicit format in scripts:

```bash
rtsql --format json demo "SELECT * FROM people"
rtsql --format csv demo "SELECT id, name, age FROM people"
rtsql --format tsv demo "SELECT id, name, age FROM people"
rtsql --format table demo "SELECT id, name, age FROM people"
```

Without `--format`, an interactive terminal receives a table and redirected output receives JSON.

| Exit code | Meaning | Action |
|---:|---|---|
| 0 | Success | Continue |
| 1 | General I/O, storage, missing-database, or format error | Inspect the path and storage before retrying |
| 2 | CLI usage error | Correct the command or empty-key input |
| 3 | SQL parse or execution error | Inspect the SQL and statement number |
| 4 | Database is locked | Find the owning process and release the lock |
| 5 | Encryption-key error | Confirm database type and key source |
| 130 | SIGINT | Inspect whether the close path completed |
| 143 | SIGTERM | Inspect whether the close path completed |

A handled SIGINT or SIGTERM runs the normal close/checkpoint path after the database opens. SIGKILL cannot be handled and relies on WAL recovery.

## Manage files and locks

A centralized database named `demo` uses this layout:

```text
$RTSQL_HOME/
└── db/
    └── demo.db
```

A path-opened database can have sidecars beside its main file:

```text
/path/demo.db
/path/demo.db.wal
/path/demo.db.checkpoint
```

The `.wal` file stores redo records. The `.checkpoint` file stores the safe replay position and transaction watermark. Do not edit or delete either file independently while RTsql is running. After a clean shutdown the main file alone is complete; RTsql recreates missing sidecars on the next open.

RTsql takes an advisory exclusive lock when opening a database. A second process waits for the lock up to the busy-timeout budget (default 5000 ms; `--busy-timeout` or `RTSQL_BUSY_TIMEOUT`, `0` = only the internal ~8 ms visibility floor) and receives exit code `4` before SQL execution only when the budget is exhausted. Record the exact path, find the owning process, stop it gracefully, and retry only after the lock is released. Do not remove lock files to bypass the lock.

`--readonly` takes an advisory shared lock instead, which enables many readers over one file while a writer stays alone:

```bash
rtsql --readonly demo "SELECT count(*) FROM people"
rtsql --readonly demo "ATTACH './other.db' AS other; SELECT p.name FROM people p JOIN other.team t ON t.id = p.id"
```

Read-only sessions never write: they skip recovery and checkpoint, and they refuse `INSERT` / `UPDATE` / `DELETE` / `UPSERT` / `REPLACE` and all DDL at plan time with SQLSTATE `25006` (exit code `3`). `SELECT`, `ATTACH`, and transaction statements still work, and an attached database opens read-only too.

Two refusals are specific to read-only opens:

- Exit code `1` with a message naming pending WAL: the database has unreplayed `.wal` records. Open it once without `--readonly` to complete recovery, then retry read-only. The refusal leaves every file unchanged.
- Exit code `2`: `--readonly` was combined with a subcommand. `--readonly` belongs to the main command; subcommands keep their read-write open.

An encrypted database opens read-only with `--key` as usual. A read-write session excludes readers and other writers, and a read-only session excludes a read-write one; conflicts wait out the busy-timeout budget and are reported as exit code `4` only when the budget is exhausted.

A plaintext database starts with a 64-byte header and stores 4096-byte page images. An encrypted database uses the same header size, a 32-byte random salt, persisted Argon2id parameters, and 4124-byte encrypted page records containing a nonce, ciphertext, and authentication tag.

## Keep the WAL bounded in long sessions

A read-write session truncates the `.wal` file at `close()`. A long-running session that keeps writing also checkpoints automatically once the bytes appended since the last checkpoint reach a threshold (16 MiB by default), which keeps the file from growing without bound. An explicit `rtsql checkpoint <db>` performs the same truncation on demand — the clean sync point before an external backup or file handoff; a clean database reports `no pending work` and exits `0`:

```bash
RTSQL_WAL_CHECKPOINT_BYTES=1048576 rtsql demo "INSERT INTO log (id, line) VALUES (1, 'first')"
```

- The check runs at each commit boundary — after an auto-commit statement and after an explicit `COMMIT` — and is deferred while another transaction of the same session is still active, so it never interleaves with in-flight work.
- `RTSQL_WAL_CHECKPOINT_BYTES=0` disables the automatic checkpoint. The `.wal` then grows for the whole session and `close()` still truncates it.
- A non-numeric, negative, or overflowing value is refused before the database opens: exit code `2` with a message naming the variable and the rejected value, and no file is created. Fix the value or unset the variable.
- If the automatic checkpoint fails, the statement that triggered it reports the failure and names the checkpoint (exit code `3`). Committed data is unaffected — the commit is fsynced first, and a later commit retries. Treat a repeated `checkpoint failed` message as a disk or file-system problem on the database's directory and check the free space and write permissions of the `.wal` and `.checkpoint` sidecars.
- Read-only and `:memory:` sessions hold no WAL, so the setting does nothing there.

## Uninstall

Run uninstall commands from the source checkout.

Remove the program while keeping data:

```bash
./install.sh --uninstall
```

This removes the selected `$PREFIX/bin/rtsql`, shell completion files, and the PATH export line for that prefix from `$HOME/.bashrc`. It leaves `$RTSQL_HOME`, its databases, and the source checkout intact.

For a custom prefix, pass the same prefix used during installation:

```bash
./install.sh --uninstall --prefix "$HOME/.local-rtsql"
```

Remove the program and all data only after explicit approval:

```bash
./install.sh --uninstall --purge-data
```

The installer prints the data path before deleting `$RTSQL_HOME`, or `$HOME/.rtsql` when `RTSQL_HOME` is unset. The deletion includes databases and sidecars and cannot be recovered through RTsql.

## Completion checklist

Before reporting an RTsql operation as complete:

1. Confirm the resolved database path.
2. Confirm whether the database is plaintext or encrypted.
3. Supply the intended key through `--key` or `RTSQL_KEY` when needed.
4. Use an explicit output format for machine-readable work.
5. Keep multi-statement atomic work inside one transaction invocation.
6. Check the process exit code, not only stdout.
7. Treat exit codes `4` and `5` as distinct operational failures.
8. Verify the target before destructive lifecycle commands.
