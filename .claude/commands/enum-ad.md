---
description: Enumerate a Windows / Active Directory target (SMB, LDAP, RPC, users)
---

Enumerate the Windows host at: $ARGUMENTS  (target IP)

Work through these, saving output to scans/ and updating notes.md as you go.
Do unauthenticated checks first; only use creds once we have them.

## 1. SMB (unauthenticated)
- `nxc smb $ARGUMENTS` — grab hostname, domain, OS, signing status
- `nxc smb $ARGUMENTS -u '' -p '' --shares` — null-session share list
- `nxc smb $ARGUMENTS -u 'guest' -p '' --shares` — guest fallback
- `enum4linux-ng -A $ARGUMENTS | tee scans/enum4linux-ng.txt`

## 2. RPC / null session
- `rpcclient -U '' -N $ARGUMENTS` then try `enumdomusers`, `enumdomgroups`, `querydominfo`

## 3. LDAP (if 389/636 open)
- `nxc ldap $ARGUMENTS -u '' -p ''` — anonymous bind check
- `ldapsearch -x -H ldap://$ARGUMENTS -s base namingcontexts` — find the base DN

## 4. Note the domain + DC
Record the DOMAIN name, FQDN, and DC hostname in notes.md — you'll need them for
Kerberos attacks. Add the FQDN to /etc/hosts pointing at $ARGUMENTS.

## 5. Summarize
Table: share | access | notes. List any usernames discovered. Recommend next step
(often: build a user list → AS-REP roast, or use found creds with the ad-attack flow).
