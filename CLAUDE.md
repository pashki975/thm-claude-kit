# TryHackMe Attack Machine Context

## Environment
- Kali Linux on WSL2
- Tools: nmap, ffuf, gobuster, nikto, whatweb, tshark, sqlmap, hydra, netcat, enum4linux, smbclient, john, hashcat
- Connected to THM via OpenVPN (tun0)

## Scope & Rules
- ONLY test the active target IP(s) listed in the current room's notes.md
- Never scan or touch anything outside the assigned target
- This is authorized CTF practice on TryHackMe boxes only

## Workflow preferences
- Always save raw tool output to ./scans/<tool>-<timestamp>.txt
- Keep notes.md updated with findings as we go (open ports, services, creds, flags)
- After every scan, summarize findings and propose the next 2-3 concrete steps
- Prefer non-destructive enumeration first; ask before anything intrusive (brute force, exploit)
- Wordlists live in /usr/share/wordlists/ (seclists, rockyou.txt)

## Output style
- Be terse. Show the command, key findings, next step.

## Approach — run the loop
For every room, follow the thm-trainer skill (classify -> observe -> hypothesize -> test -> decide).
Classify the room and name the goal BEFORE running any tool. Start a room with /start <url-or-description>.
When stuck (repeating actions with no new info), stop and reclassify rather than scanning harder.
