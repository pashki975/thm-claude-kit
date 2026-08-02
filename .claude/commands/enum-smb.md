---
description: Enumerate SMB/NetBIOS shares on the target
---

Enumerate SMB on: $ARGUMENTS

1. `enum4linux -a $ARGUMENTS | tee scans/enum4linux.txt`
2. List shares: `smbclient -L //$ARGUMENTS/ -N`
3. `nmap --script smb-enum-shares,smb-enum-users,smb-os-discovery -p139,445 $ARGUMENTS -oN scans/smb-nmap.txt`
4. For any readable share, attempt anonymous listing with smbclient
5. Summarize: shares | access level | interesting files. Update notes.md.
