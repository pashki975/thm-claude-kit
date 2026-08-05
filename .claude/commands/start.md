---
description: Kick off a room — classify it and set the goal before touching any tool
---

Start a TryHackMe room the right way. Argument: $ARGUMENTS
This can be a room URL, a pasted room description, or "name + tag + target IP".

Follow the thm-trainer loop. Do NOT run any scanning tool until Beat 1 is done and I've
seen the plan.

## Beat 1 — Classify (do this first, in your reply)
1. If $ARGUMENTS is a URL, fetch it and read the room card: title, tags, task text, hints.
   If it's a pasted description, read that. If the page is login-gated and you can't fetch it,
   say so and ask me to paste the description.
2. State the classification: category (web / subdomain-enum / AD / Linux service / OSINT /
   steg / crypto / reversing / …) and what signal tells you that.
3. State the GOAL and stop condition: flag string? user+root shell? a specific answer?
4. If a domain name is present, note it needs adding to /etc/hosts, and do it (with my
   approval) pointing at the target IP.
5. Write the classification + goal into notes.md.

## Then — state the plan, and stop
Give me a 2-4 step plan for the first leg (observe -> hypothesize -> test). Name the first
concrete action and WHY it fits this room type. Then stop and let me approve before running
anything.

Remember: match the first action to the class (don't default to a port scan if the room is
about DNS, files, or reading); name the goal so we stop when it's met; one focused test at a
time, not parallel scans.
