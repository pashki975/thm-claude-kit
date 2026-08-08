---
description: WordPress enumeration & exploitation with wpscan — cheap enum first, heavy/creds gated
---

Attack the WordPress site at: $ARGUMENTS  (e.g. http://10.10.x.x or http://blog.thm)

WordPress has its own tool (wpscan) and a distinct attack chain, so this is separate from the
generic /enum-web path. Same gating discipline: enumerate cheaply, form a hypothesis about the
way in (vulnerable plugin? weak creds? exposed config?), THEN run the heavy/noisy steps.

## The gate
Before brute-forcing logins or firing an exploit, say a one-line hypothesis from what enum found:
- A specific vulnerable plugin/theme version → that CVE is the way in (don't brute logins).
- A discovered username + a login form → password attack is justified (mind lockout).
- xmlrpc.php enabled → amplified brute or pingback SSRF may fit.
State it, then run only the step that matches. Get a wpscan API token (free) for CVE data:
add `--api-token <token>` to enrich plugin/theme vuln output.

## 1. CHEAP enumeration — always
- Passive + light: `wpscan --url $ARGUMENTS --enumerate vp,vt,u --plugins-detection passive`
  (vp=vuln plugins, vt=vuln themes, u=users)
- Read the site: /wp-login.php (version, custom login), /?author=1 (username leak), /readme.html,
  /wp-content/ listing, robots.txt. Note the WP core version.
- Check xmlrpc.php: is it enabled? (POST to it — 405 vs 200 tells you).

## 2. Map versions to known vulns (gate the exploit)
- Note core, plugin, and theme versions from enum. For anything flagged, verify the CVE actually
  applies to THIS version before chasing it. `searchsploit wordpress <plugin>` for local PoCs.
- Common wins: outdated plugin with auth-bypass/RCE/LFI/SQLi; a theme with file-upload.

## 3. Credential attack — only if enum gave a username and no easier path
- `wpscan --url $ARGUMENTS -U users.txt -P /usr/share/wordlists/rockyou.txt`
  (wpscan brute uses wp-login by default; add `--password-attack xmlrpc` if xmlrpc is enabled — faster).
- Watch for lockout plugins; if present, prefer the CVE path over brute.

## 4. Authenticated → shell (once you have wp-admin)
- Appearance → Theme Editor: edit 404.php/header.php of an inactive theme to a PHP webshell, then
  browse to it. (Or Plugins → upload a malicious plugin zip.)
- Set up the catch with /listener first, then trigger the shell.
- Metasploit alt: `wp_admin_shell_upload` if you prefer.

## 5. Loot wp-config.php (huge — often the pivot)
- Once you have any file read or a shell, read `wp-config.php` for the DB creds. Those creds are
  frequently reused for SSH or the DB (→ /db-enum). Record them in the room brain immediately.

## Summarize
Lead with what enum found (versions, users, xmlrpc). Say which vuln/path you took and why. Put
any creds (esp. from wp-config.php) in notes.md and try them elsewhere — WordPress DB creds are a
classic reuse pivot. If the goal (flag/shell) is met, stop.
