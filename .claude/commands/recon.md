---
description: Run staged nmap recon against the target and parse results
---

Run reconnaissance against target IP: $ARGUMENTS

Steps:
1. Create ./scans/ if it doesn't exist
2. Fast port discovery: `nmap -p- --min-rate 5000 -T4 $ARGUMENTS -oN scans/nmap-allports.txt`
3. Parse open ports, then run a targeted service/version + default-script scan on ONLY those ports:
   `nmap -sV -sC -p<open_ports> $ARGUMENTS -oN scans/nmap-services.txt`
4. Summarize: table of port | service | version | notes
5. Update notes.md with the target IP and discovered services
6. Propose the next 2-3 enumeration steps based on what's open
