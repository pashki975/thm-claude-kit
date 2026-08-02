---
description: Windows local privilege escalation — enumeration checklist and analysis
---

Guide Windows privesc on the shell we have. Args (optional): $ARGUMENTS

Walk me through enumeration, then analyze whatever output I paste back. Prioritize the
quick wins first.

## 1. Quick manual checks (paste output back to me)
- `whoami /priv` — look for SeImpersonatePrivilege, SeBackupPrivilege, SeDebugPrivilege, etc.
- `whoami /groups` — group memberships
- `systeminfo` — OS build + hotfixes (for kernel-exploit matching)
- `net user` / `net localgroup administrators`

## 2. Token privilege exploits (very common on THM)
- SeImpersonatePrivilege → **Potato attacks** (PrintSpoofer / GodPotato / JuicyPotato).
  This is the single most common Windows CTF privesc. If present, prioritize it.
- SeBackupPrivilege → dump SAM/SYSTEM hives, extract hashes offline
- SeDebugPrivilege → dump lsass / migrate into a SYSTEM process

## 3. Automated enum (upload and run one)
- winPEAS: `winPEASx64.exe` (host it over HTTP, download to the box, run)
- PowerUp: `powershell -ep bypass -c ". .\PowerUp.ps1; Invoke-AllChecks"`
- Serve files from Kali: `python3 -m http.server 80`

## 4. Other classic vectors to check
- Unquoted service paths, weak service permissions (accesschk / PowerUp)
- AlwaysInstallElevated registry keys
- Stored creds: `cmdkey /list`, registry autologon, unattend.xml, saved PowerShell history
- Scheduled tasks running as SYSTEM

## 5. Analysis
When I paste enum output, hand it to the win-privesc-advisor agent for a ranked plan
with exact commands. Record the winning path and the root/administrator flag in notes.md.
