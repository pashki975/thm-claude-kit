---
name: windows-ad-methodology
description: Standard operating procedure for solving Windows and Active Directory TryHackMe boxes. Use when the target is Windows/domain-joined (SMB/LDAP/Kerberos/WinRM ports open, or the room mentions AD/domain), when asked "what next" on a Windows room, or when a Linux-oriented approach isn't fitting. Guides the recon → AD enum → foothold → Kerberos → privesc → domain flow.
---

# Windows / Active Directory Methodology

For readers who live in Linux: Windows CTF is a different surface. Instead of web/SSH →
SUID/sudo, the game is SMB/LDAP/Kerberos → tokens/ACLs/tickets. Follow this flow.

## Recognizing a Windows box
Open 135/139/445 (SMB), 3389 (RDP), 5985 (WinRM), and especially 88 (Kerberos) +
389/636 (LDAP) → domain-joined AD. Kerberos (88) present = treat it as full AD.

## 0. Setup
- /vpn-check the target
- Add the DC's FQDN to /etc/hosts (Kerberos needs name resolution)
- Watch clock skew: sync to the DC if Kerberos tooling errors (`sudo rdate -n <DC-IP>`)

## 1. Recon
- /recon as usual. Note the domain name, DC hostname, OS build.

## 2. AD / SMB enumeration
- /enum-ad — null/guest sessions, shares, RPC, LDAP, build a user list
- Harvest usernames from RID cycling, shares, LDAP. Save to users.txt.

## 3. Get a foothold credential (try in order)
- AS-REP roast the user list (/kerberos) — no creds needed
- Password spray weak/found passwords across users (careful of lockout)
- Anonymous/guest readable shares — look for creds, configs, scripts
- Any web app on the box → normal web enum (/enum-web)

## 4. Situational awareness (once you have ANY valid cred)
- Run BloodHound collection — let the ad-attack-advisor agent read the results
- Validate the cred everywhere: `nxc smb <IP/range> -u <u> -p <p>` (look for Pwn3d!)

## 5. Escalate within the domain
- Kerberoast service accounts (/kerberos), crack offline
- Abuse ACLs / delegation / DCSync per BloodHound (ad-attack-advisor agent)
- Check ADCS (certipy) if certificate services are present

## 6. Get a shell
- /win-shell — evil-winrm, psexec/wmiexec, or RDP depending on the cred
- Immediately run `whoami /priv` and `whoami /groups`

## 7. Local privesc (if not already SYSTEM/admin)
- /win-privesc — token privileges first (SeImpersonate → Potato is the classic),
  then services, stored creds, kernel last
- Analyze enum with the win-privesc-advisor agent

## 8. Domain dominance & loot
- DCSync krbtgt if you reach it — note the domain is fully compromised
- Record all flags (user.txt, root.txt/admin) and creds in notes.md
- report-writer agent for the writeup

## Rules
- Stay strictly on the assigned target IP/range
- Most Windows CTF blockers are: missed enum, /etc/hosts, or clock skew — check those first
- Prefer credentialed remote tools (evil-winrm) over noisy reverse shells when you can
