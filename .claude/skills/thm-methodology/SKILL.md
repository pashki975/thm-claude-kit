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
- Full TCP port scan, then targeted -sV -sC on open ports (/recon)
- Don't forget UDP — SNMP/TFTP/DNS hide there (/enum-udp). Run it in parallel with TCP enum.
- Record every open port/service in notes.md

## 2. Enumerate per service
Match each open port to its enumeration path:
- 80/443/8080 → web (/enum-web): dirs, vhosts, tech stack, source, robots.txt
- 139/445 → SMB (/enum-smb)
- 21 → FTP: try anonymous login
- 22 → SSH: note version, save creds for later; don't brute unless hinted
- 25/110/143 → mail
- 3306/1433/5432/27017/6379 → databases (/db-enum): creds to reuse + RCE paths
- 161/69/53 (UDP) → /enum-udp
- Map service versions to CVEs (cve-researcher agent)

## 3. Foothold
- Exploit the most promising verified vector
- Set up listener + payload (/listener) for reverse shells
- Upgrade to a stable TTY immediately after landing a shell

## 4. Post-exploitation / privesc
- Grab the user flag
- Run local enum with the checklist (/linux-privesc): sudo -l, SUID, capabilities, cron/pspy, cred hunting
- Analyze with privesc-advisor agent
- Escalate to root, grab root flag

## 5. Pivot (if the room has more than one host)
- Check the foothold for a second NIC / internal subnet (ip a, ip route, arp -a)
- Tunnel in (/tunnel) with ligolo-ng, chisel, sshuttle, or SSH forwards
- Record each internal host in notes.md as a new target and re-run this methodology against it

## 6. Loot & document
- Record all flags and creds in notes.md
- Generate writeup (report-writer agent)

## Rules
- Stay strictly on the assigned target IP/range
- Enumerate thoroughly before exploiting — most CTF blockers are missed enum
- Reuse found credentials everywhere (SSH/SMB/web/db) — password reuse is rampant on THM
- When stuck: re-read scan output, try a bigger wordlist, check UDP, check for vhosts, revisit versions
