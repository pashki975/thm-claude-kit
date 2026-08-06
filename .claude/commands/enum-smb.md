---
description: Enumerate SMB/NetBIOS — cheap listing first, heavy brute/enumeration only when it'll pay off
---

Enumerate SMB on: $ARGUMENTS

## The gate (before any HEAVY step)
Reason out loud first: what did the cheap listing already give us, and would a heavy step find
anything new? If a null/guest session already listed the shares and their contents, a full
RID-brute or exhaustive per-share crawl may add nothing — say so and suggest the better move
(go read the interesting share, try found creds elsewhere). State a one-line hypothesis before
a heavy step; if it's "probably nothing new," skip and offer it as opt-in.

## CHEAP — always
1. `nxc smb $ARGUMENTS` — host/domain/OS/signing
2. `nxc smb $ARGUMENTS -u '' -p '' --shares` and `-u guest -p '' --shares` — null/guest shares
3. List and read anything already readable: `smbclient -L //$ARGUMENTS/ -N`

## HEAVY — gate each
4. `enum4linux-ng -A $ARGUMENTS | tee scans/enum4linux.txt` — thorough, but skip if cheap steps
   already answered what we need
5. RID brute / exhaustive user enumeration — ONLY if we still lack a user list and it matters
6. nmap SMB script sweep — ONLY if the above left gaps:
   `nmap --script smb-enum-shares,smb-enum-users,smb-os-discovery -p139,445 $ARGUMENTS -oN scans/smb-nmap.txt`

## Summarize
Lead with what the cheap steps found. For heavy steps, say ran/skipped and why. Reuse any creds
elsewhere. Update notes.md.
