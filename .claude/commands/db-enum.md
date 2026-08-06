---
description: Enumerate/exploit a database — connect and read first, heavy brute only when justified
---

Enumerate the database at: $ARGUMENTS
Expected: <target-IP> <type> [user:pass]  (type = mysql|mssql|postgres|mongo|redis)

## The gate (before any HEAVY step)
Reason first: once connected, reading the schema and hunting stored creds is cheap and high
value. HEAVY steps (credential brute-forcing the DB login, mass-dumping every table) should be
gated — if you already have creds or the interesting table is obvious, don't brute or dump
everything. State the hypothesis; skip low-yield heavy steps and say why.

## CHEAP — always (once you can connect)
1. Connect with what you have (provided creds, or try weak/blank on the relevant engine).
2. Enumerate structure: list databases/tables, dump the user/creds table, look for anything
   app-specific. This is usually where the win is.
3. Reuse any recovered creds against SSH/SMB/web — password reuse is rampant.

## HEAVY — gate each
4. Brute-forcing the DB login — ONLY if unauthenticated access fails and it's the intended path.
5. RCE paths (xp_cmdshell / INTO OUTFILE / COPY FROM PROGRAM / Redis config write) — these are
   powerful but noisy; use when you actually need code exec, and say why. See the per-engine
   commands below.

## Per-engine reference
- MySQL: `mysql -h <IP> -u <user> -p<pass>` ; FILE priv → LOAD_FILE / INTO OUTFILE webshell
- MSSQL: `impacket-mssqlclient <user>:<pass>@<IP> -windows-auth` ; enable_xp_cmdshell
- Postgres: `psql -h <IP> -U <user>` ; COPY ... FROM PROGRAM for RCE (needs superuser)
- Mongo: `mongosh --host <IP>` (often no auth) ; show dbs / find()
- Redis: `redis-cli -h <IP>` ; INFO / CONFIG GET dir ; unauth write-key/cron RCE

## Summarize
Lead with schema + creds found. For heavy/RCE steps, say ran/skipped and why. Update notes.md.
