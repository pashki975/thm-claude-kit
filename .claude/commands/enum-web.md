---
description: Enumerate a web service — cheap recon first, heavy scans only when they'll pay off
---

Enumerate the web service at: $ARGUMENTS  (e.g. http://10.10.x.x:80)

## The gate (apply this before the heavy steps — it's the whole point)
Enumeration steps split into CHEAP (always worth it) and HEAVY (only when they'll actually
tell us something new). Before running any HEAVY step, stop and reason out loud:
- What do we already know from the cheap steps? (page source, JS bundles, whatweb fingerprint)
- Would this heavy scan find anything the cheap steps didn't already hand us?
- If the app is bespoke/single-page (all logic in one JS file, no CMS, no server-rendered
  dirs), a directory brute-force and a nikto sweep are usually LOW YIELD — the source already
  reveals the real endpoints. Say so, and suggest the better move instead (read the JS, hit the
  API endpoints the source names, test those params).
State the one-line hypothesis for a heavy step before running it. If the hypothesis is "this
probably finds nothing new," skip it and explain why, then offer it as opt-in ("say the word
and I'll run the full ffuf/nikto anyway").

## CHEAP — always do these first
1. Fetch the page and READ THE SOURCE — HTML comments, linked JS bundles, inline config,
   API paths referenced in the code. On a custom app this often hands you every real endpoint.
2. `whatweb $ARGUMENTS` — fingerprint the tech stack (is this a known CMS or a bespoke app?)
3. Check the obvious files: robots.txt, sitemap.xml, /.git/, backups, /api/ paths named in source.

## HEAVY — gate each behind the hypothesis above
4. Directory/content brute-force — ONLY if the cheap steps left real gaps (server-rendered app,
   unknown framework, dirs likely hidden). First verify the wordlist exists:
   `ls /usr/share/seclists/Discovery/Web-Content/` — do NOT guess a filename (CLAUDE.md rule).
   `ffuf -u $ARGUMENTS/FUZZ -w <verified-wordlist> -mc 200,204,301,302,307,401,403 -o scans/ffuf.json`
5. `nikto -h $ARGUMENTS -o scans/nikto.txt` — ONLY if it's a real server-side app where known
   misconfigs/CVEs are plausible. Skip for a static single-page app.

## Summarize
Report what the CHEAP steps revealed first. For any HEAVY step, say whether you ran it and why
(or why you skipped it). Recommend next steps based on the actual app, not a generic checklist.
Save findings to notes.md under "Web Enumeration".
