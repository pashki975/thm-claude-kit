---
name: thm-methodology
description: Standard operating procedure for solving a TryHackMe box. Use when starting a new room, when the user asks "what next", or when stuck and needing a methodical next step. Guides the recon → enum → foothold → privesc → loot flow and enforces scope discipline.
---

# TryHackMe Methodology

Follow this flow. Never skip enumeration to jump to exploitation.

## 0. Setup
- Confirm VPN up and target reachable (/vpn-check)
- Create room folder + scans/ + notes.md

## 1. Recon
- Full port scan, then targeted -sV -sC on open ports (/recon)
- Record every open port/service in notes.md

## 2. Enumerate per service
Match each open port to its enumeration path:
- 80/443/8080 → web (/enum-web): dirs, vhosts, tech stack, source, robots.txt
- 139/445 → SMB (/enum-smb)
- 21 → FTP: try anonymous login
- 22 → SSH: note version, save creds for later; don't brute unless hinted
- 25/110/143 → mail
- 3306/5432/1433 → databases
- Map service versions to CVEs (cve-researcher agent)

## 3. Foothold
- Exploit the most promising verified vector
- Set up listener + payload (/listener) for reverse shells
- Upgrade to a stable TTY immediately after landing a shell

## 4. Post-exploitation / privesc
- Grab the user flag
- Run local enum (linpeas/winpeas, `id`, `sudo -l`, SUID, cron)
- Analyze with privesc-advisor agent
- Escalate to root/SYSTEM, grab root flag

## 5. Loot & document
- Record all flags and creds in notes.md
- Generate writeup (report-writer agent)

## Rules
- Stay strictly on the assigned target IP
- Enumerate thoroughly before exploiting — most CTF blockers are missed enum
- When stuck: re-read scan output, try a bigger wordlist, check for vhosts/UDP, revisit versions
