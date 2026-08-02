---
description: UDP port scan + follow-up enumeration of common UDP services
---

Scan and enumerate UDP services on: $ARGUMENTS  (target IP)

UDP is slow, so scan the top ports first and only go wider if nothing turns up.
Save output to scans/ and update notes.md.

## 1. Scan
- `nmap -sU --top-ports 50 -T4 $ARGUMENTS -oN scans/nmap-udp.txt`
- If time allows and nothing found: `nmap -sU -p- --min-rate 1000 $ARGUMENTS` (slow)

## 2. Follow up per open UDP service
- 161 SNMP → try community strings, then walk:
  - `onesixtyone $ARGUMENTS public private community`
  - `snmpwalk -v2c -c public $ARGUMENTS | tee scans/snmpwalk.txt`
  - `snmpwalk -v2c -c public $ARGUMENTS 1.3.6.1.4.1.77.1.2.25`  (users)
  - `snmpwalk -v2c -c public $ARGUMENTS 1.3.6.1.2.1.25.4.2.1.2` (running processes — creds in cmdlines!)
- 69 TFTP → `tftp $ARGUMENTS` then try `get`/`put` on known filenames
- 53 DNS → attempt zone transfer: `dig axfr @$ARGUMENTS <domain>`
- 500 IKE → `ike-scan $ARGUMENTS`
- 123 NTP → `ntpq -p $ARGUMENTS`

## 3. Summarize
Table: port | service | finding. SNMP process/username leaks and TFTP file access are
the usual wins — call those out explicitly and record any creds in notes.md.
