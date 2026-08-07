---
name: thm-trainer
description: The core decision loop for driving any TryHackMe room. Use at the START of every room, whenever the user asks "what next", and whenever progress stalls. Teaches classify -> observe -> hypothesize -> test -> decide, so the approach is chosen from what the room is actually teaching rather than defaulting to port-scan-then-privesc. This is the thinking layer above the methodology and command skills.
---

# THM Trainer — how to drive a room

A coaching guide, not a solutions list. It teaches the loop a good player runs on ANY room —
familiar or not — so neither you nor Claude confidently does things that lead nowhere. The
commands and agents are just tools this loop reaches for.

## The loop
1. CLASSIFY   -> what is this room teaching? what's the goal (flag string vs shell)?
2. OBSERVE    -> the lightest thing that fits the class; don't over-scan
3. HYPOTHESIZE-> "the way in is probably X, because Y" (one sentence, out loud)
4. TEST       -> one focused action whose result decides the next move
5. DECIDE     -> new info -> loop; goal met -> STOP; no new info -> reclassify

Underneath it all: every action should change what you do next. If a scan wouldn't change
your plan, don't run it.

## Beat 1 — CLASSIFY (the beat everyone skips)
Read what the room tells you before touching a tool:
- Room card / tags — "web", "subdomain enumeration", "Active Directory", "OSINT", "steg". The
  strongest signal. Read it first, every time.
- Title — "Takeover" -> subdomain/DNS takeover. Names hint.
- Task text — a domain name means DNS/vhost work; a downloadable file means offline analysis.
- a .pcap / capture file       -> traffic analysis with tshark (/pcap)
- Difficulty — "easy" usually means one technique, one insight. Don't over-engineer.
Then name the GOAL: flag string (many recon/web/OSINT rooms — no shell needed) vs user+root
shell (full compromise) vs a specific answer. Write it in notes.md before scanning.
> For Claude: state the classification and goal in your first message, before any tool. If the
> category isn't given, infer it from the card or ask — don't default to a port scan.

## Beat 2 — OBSERVE (enough, not everything)
Match the observation to the class. A port scan is the default for a service box, not always
the right first move. Signal -> first observation:
- domain name (foo.thm)      -> /etc/hosts, vhost fuzz, cert SANs (/web-recon)
- 80/443 + a real website    -> browse it, view source, dirs, params (/enum-web)
- 88 + 389 + 445             -> Active Directory (/enum-ad)
- 22 + a versioned service   -> version -> CVE lookup
- a downloadable file        -> file/strings/exiftool/binwalk (/steg)
- a .pcap / capture file       -> traffic analysis with tshark (/pcap)
- "find the answer to..."    -> OSINT / careful reading

## Beat 3 — HYPOTHESIZE (say it before you test)
One sentence: "the way in is probably X, because Y." If you can't finish it, observe more.
> For Claude: state the hypothesis before the tool call, not after.

## Beat 4 — TEST (one focused action)
The single action that best confirms or kills the hypothesis. Not three tools in parallel —
that's usually avoidance. The test should read clearly yes/no.

## Beat 5 — DECIDE (and know when to stop)
- New info -> loop back to Beat 2 with a new hypothesis.
- Goal met -> STOP. Got the flag the room asked for? Done. Don't escalate to a shell you don't need.
- No new info -> you're off the path.

### The stuck signal
You're off the path when you repeat actions without new information — another wordlist, another
tool, another port, learning nothing. That churn feels like progress and isn't. When you feel
it, re-run Beat 1: did I classify right? am I chasing a shell when the goal was a flag? what is
the room tagged, and am I doing that technique? did I skip a hint?
> For Claude: if two consecutive actions produce no new information, stop and say so: "I'm not
> learning anything new — let me reclassify." Never fire tools to look busy.

## Worked example: "Takeover"
1. CLASSIFY: tagged subdomain enumeration; title "Takeover"; task about futurevera.thm. Goal:
   one flag, no shell. -> we will not ssh into anything.
2. OBSERVE: signal is a domain, so first move is resolving it — add futurevera.thm to
   /etc/hosts, browse. Main site is a dead end, which fits a recon room.
3. HYPOTHESIZE: "probably a forgotten subdomain, because the room is about subdomain takeover
   and the main site is a dead end."
4. TEST: vhost fuzz — ffuf -H "Host: FUZZ.futurevera.thm" -fs <default>. support.futurevera.thm
   appears. New info -> loop.
5. DECIDE -> loop: add it to hosts, observe. The artifact is the SSL cert — read its SANs, which
   reveal another subdomain. Visit it -> redirects to an AWS S3 URL with the flag in the URL.
   Goal met -> STOP.
Elapsed with the loop: minutes. The tools (ffuf, openssl) were always in the kit. What was
missing was Beat 1 — classifying as recon and naming the goal as a flag, which stops you
sshing into a box that was never about shells. The lesson generalizes: classify before acting,
hypothesize before testing, stop when the goal is met.

## One-screen version
1. Classify — read the card. What's it teaching? Goal (flag vs shell)? Write it down.
2. Observe — lightest thing that fits the class. Don't over-scan.
3. Hypothesize — "the way in is probably X because Y." One sentence.
4. Test — one focused action whose result decides the next move.
5. Decide — new info -> loop; goal met -> stop; no new info -> reclassify.
Stuck = repeating actions with no new information. Then go back to step 1. The flag is the
finish line — know which flag you're chasing.
