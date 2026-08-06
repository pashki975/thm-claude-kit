---
description: UDP scan + service follow-up — top ports first, full sweep only when justified
---

Scan and enumerate UDP services on: $ARGUMENTS  (target IP)

## The gate (before any HEAVY step)
UDP scanning is slow — that's exactly why the gate matters. Reason first: did the top-ports
scan already find the service we needed? A full 65535-port UDP sweep is HEAVY and usually
low-yield — only justify it if the top-ports scan came up empty AND the room points at UDP.
State the hypothesis before the full sweep; if weak, skip and say why.

## CHEAP — always
1. `nmap -sU --top-ports 50 -T4 $ARGUMENTS -oN scans/nmap-udp.txt`
2. Follow up on whatever opened (these are cheap and targeted):
   - 161 SNMP → `snmpwalk -v2c -c public $ARGUMENTS` (users/processes leak creds)
   - 69 TFTP → `tftp $ARGUMENTS` ; 53 DNS → `dig axfr @$ARGUMENTS <domain>`
   - 500 IKE → `ike-scan $ARGUMENTS` ; 123 NTP → `ntpq -p $ARGUMENTS`

## HEAVY — gate it
3. Full UDP sweep `nmap -sU -p- --min-rate 1000 $ARGUMENTS` — ONLY if top-ports found nothing
   and there's a real reason to think a high UDP port matters. Otherwise skip and move on.

## Summarize
Lead with what the top-ports scan + follow-ups found. Note if you skipped the full sweep and why.
Record SNMP/TFTP leaks in notes.md.
