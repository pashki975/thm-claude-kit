---
description: Enumerate a web service on the target
---

Enumerate the web service at: $ARGUMENTS  (e.g. http://10.10.x.x:80)

1. `whatweb $ARGUMENTS` — fingerprint tech stack
2. Directory brute force:
   `ffuf -u $ARGUMENTS/FUZZ -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -mc 200,204,301,302,307,401,403 -o scans/ffuf.json`
3. `nikto -h $ARGUMENTS -o scans/nikto.txt`
4. Check for common files: robots.txt, sitemap.xml, .git/, backup files
5. Summarize interesting paths/findings and recommend next steps
6. Save findings to notes.md under a "Web Enumeration" section
