# TryHackMe + Claude Code Attack Kit

An agentic assistant setup for solving TryHackMe rooms in Kali/WSL2. It gives Claude Code a
consistent methodology, ready-made slash commands for common tasks, and specialist subagents
for parsing, CVE research, privesc, and writeups.

> ⚠️ **Scope discipline.** Everything here is built for *authorized* practice on TryHackMe
> boxes you've deployed. The config repeatedly tells Claude to stay on the assigned target IP
> only. Keep that guardrail. Never point this at a host you don't have explicit permission to test.

---

## 1. What's in the box

```
thm/
├── README.md               ← you are here
├── CLAUDE.md               ← global context Claude reads automatically
├── WINDOWS-CHEATSHEET.md   ← Linux-attacker's quick reference for Windows/AD
├── new-room.sh            ← scaffolds a new room folder under rooms/
├── .gitignore             ← ignores rooms/ (your scans, notes, creds, flags)
├── rooms/                 ← ALL room folders live here (git-ignored)
│   └── .gitkeep            ← keeps the empty dir in the repo
└── .claude/
    ├── commands/           ← slash commands (manual triggers you type)
    │   ├── vpn-check.md    →  /vpn-check
    │   ├── recon.md        →  /recon
    │   ├── enum-web.md     →  /enum-web
    │   ├── enum-smb.md     →  /enum-smb
    │   ├── listener.md     →  /listener
    │   ├── crack.md        →  /crack
    │   ├── notes.md        →  /notes
    │   │   ── Windows/AD ──
    │   ├── enum-ad.md      →  /enum-ad
    │   ├── kerberos.md     →  /kerberos
    │   ├── win-shell.md    →  /win-shell
    │   └── win-privesc.md  →  /win-privesc
    ├── agents/             ← subagents (specialists, run in their own context)
    │   ├── recon-parser.md
    │   ├── privesc-advisor.md       (Linux)
    │   ├── cve-researcher.md
    │   ├── report-writer.md
    │   ├── win-privesc-advisor.md   (Windows)
    │   └── ad-attack-advisor.md     (Active Directory)
    └── skills/
        ├── thm-methodology/SKILL.md          ← Linux game plan
        └── windows-ad-methodology/SKILL.md   ← Windows/AD game plan
```

**Commands** = things you trigger by typing `/name`. Fast, predictable, one job each.
**Agents** = specialists Claude hands a focused task to ("use the cve-researcher agent"). They
run in a separate context so heavy output doesn't clutter your main session.
**Skill** = the connective tissue. It tells Claude the *order of operations* so when you ask
"what next?" you get a methodical answer instead of a guess.

---

## 2. Install

### a. Prerequisites (one time)

```bash
# Node.js 18+ and Claude Code
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
npm install -g @anthropic-ai/claude-code

# Tools the Linux commands assume are present
sudo apt install -y seclists enum4linux smbclient hashid john hashcat rlwrap exploitdb

# Tools the Windows/AD commands assume are present
sudo apt install -y netexec impacket-scripts evil-winrm enum4linux-ng freerdp2-x11 ldap-utils
# certipy + bloodhound-python (pipx keeps them tidy):
pipx install certipy-ad
pipx install bloodhound
```

> Package names vary a little by Kali version. If `netexec` isn't found, it may still be
> `crackmapexec` (`cme`) on older images, or install with `pipx install netexec`. The
> commands use `nxc`; alias `cme` to it if needed.

Some tools aren't apt packages — you download them onto the *target* at exploit time:
**winPEAS**, **PowerUp.ps1**, **PrintSpoofer64.exe**, **GodPotato**. Grab them from their
GitHub releases and keep them in a `~/thm/tools/` folder to serve over HTTP.

### b. Drop the kit in place

Put this whole `thm/` folder in your home directory:

```bash
cp -r thm ~/thm
chmod +x ~/thm/new-room.sh
```

The `.claude/` folder lives at `~/thm/`, so **every room folder underneath it inherits the same
commands, agents, and skill automatically.** You configure once, use everywhere.

### c. First run

```bash
cd ~/thm
claude          # authenticate on first launch
```

---

## 3. Daily workflow

### Step 1 — Start a room

```bash
cd ~/thm
./new-room.sh blue          # creates ~/thm/rooms/blue/ with scans/ + notes.md
cd rooms/blue
claude
```

All room folders live under `rooms/`, which is git-ignored — so your scans, notes,
cracked creds, and flags never get committed. The shared `.claude/` config at the repo
root **is** tracked, and rooms still inherit it because `rooms/` sits underneath it.

### Step 2 — Confirm connectivity

```
/vpn-check 10.10.123.45
```

Checks `tun0` is up, shows your VPN IP (you'll need it for reverse shells), and pings the target.

### Step 3 — Recon

```
/recon 10.10.123.45
```

Full port sweep → targeted service scan on open ports → summary table → notes.md updated →
suggested next steps. Then let a specialist parse it:

```
use the recon-parser agent on the latest scans
```

### Step 4 — Enumerate per service

Pick the command matching what's open:

```
/enum-web http://10.10.123.45
/enum-smb 10.10.123.45
```

Check versions against known vulns:

```
use the cve-researcher agent on the services in notes.md
```

### Step 5 — Get a foothold

```
/listener 4444
```

Gives you LHOST, copy-paste payloads (bash/python/nc/PowerShell), the listener command to run in
a **separate terminal**, and TTY-upgrade steps for after you land the shell.

### Step 6 — Privilege escalation

Run your local enum on the box (linpeas, `sudo -l`, etc.), paste the output back, then:

```
use the privesc-advisor agent on this output: <paste>
```

### Step 7 — Document

```
/notes                                   # keep notes.md current anytime
use the report-writer agent              # generates writeup.md when solved
```

### When you're stuck

Just ask:

```
what next?
```

The `thm-methodology` skill kicks in and gives you the next methodical step — usually "you
skipped an enumeration path," which is true more often than not.

---

## 3b. Windows / Active Directory workflow

Windows boxes are a different game (see `WINDOWS-CHEATSHEET.md` for the Linux→Windows
mental-model table). Claude auto-loads the `windows-ad-methodology` skill when it sees a
Windows/AD target, so `what next?` gives Windows-appropriate steps. Recognize an AD box by
open ports **88 (Kerberos) + 389/636 (LDAP) + 445 (SMB)**.

### Step 1 — Recon + spot the domain

```
/vpn-check 10.10.123.45
/recon 10.10.123.45
```

Note the domain name and DC hostname. **Add the DC's FQDN to `/etc/hosts`** pointing at the
target — Kerberos tooling fails without name resolution.

### Step 2 — Enumerate AD

```
/enum-ad 10.10.123.45
```

Null/guest sessions, shares, RPC, LDAP, and a harvested user list (`users.txt`).

### Step 3 — Get a foothold credential

```
/kerberos 10.10.123.45 SPOOKY.THM users.txt
```

AS-REP roasting needs no creds — it finds users with pre-auth disabled and hands you a hash
to crack. Also try password spraying and reading anonymous shares.

### Step 4 — Once you have any valid cred

Build the picture and let the AD specialist plan the path:

```
use the ad-attack-advisor agent — run BloodHound with user:pass and plan the route to DA
```

Then Kerberoast service accounts:

```
/kerberos 10.10.123.45 SPOOKY.THM svc_user:Password123
```

### Step 5 — Get a shell

```
/win-shell 10.10.123.45 svc_user Password123
```

Picks evil-winrm / psexec / RDP based on what the cred allows.

### Step 6 — Local privesc to SYSTEM

```
/win-privesc
```

Run the enum it lists, paste output back, then:

```
use the win-privesc-advisor agent on this output: <paste whoami /priv + winPEAS>
```

`SeImpersonatePrivilege` → a **Potato attack** is the most common THM Windows privesc — the
advisor gives you the exact `PrintSpoofer64.exe` line.

### Step 7 — Domain dominance & document

DCSync `krbtgt` if you reach it (full domain compromise), record flags in `notes.md`, then
`use the report-writer agent`.

---

## 4. Command quick reference

| Command | Argument | Does |
|---------|----------|------|
| `/vpn-check` | target IP | Verify VPN up + target reachable, show your tun0 IP |
| `/recon` | target IP | Staged nmap (all ports → service scan), summarized |
| `/enum-web` | URL | whatweb + ffuf dirs + nikto + common files |
| `/enum-smb` | target IP | enum4linux + share listing + smb nmap scripts |
| `/listener` | port (opt) | Reverse shell payloads + listener + TTY upgrade steps |
| `/crack` | hash or file | Identify hash, pick john/hashcat, crack it |
| `/notes` | — | Update notes.md from scans + conversation |
| **`/enum-ad`** | target IP | Windows/AD: SMB, LDAP, RPC, user harvesting |
| **`/kerberos`** | DC-IP DOMAIN [users/creds] | AS-REP roast + Kerberoast |
| **`/win-shell`** | IP user pass/hash | Get a session: evil-winrm / psexec / RDP |
| **`/win-privesc`** | — | Windows local privesc checklist + analysis |

| Agent | Invoke with | Does |
|-------|-------------|------|
| recon-parser | "use the recon-parser agent" | Structures raw scan output into findings |
| cve-researcher | "use the cve-researcher agent" | Maps versions → CVEs, checks searchsploit |
| privesc-advisor | "use the privesc-advisor agent" | Ranks Linux privesc vectors from enum output |
| report-writer | "use the report-writer agent" | Builds writeup.md from notes + scans |
| **win-privesc-advisor** | "use the win-privesc-advisor agent" | Ranks Windows privesc (tokens, services, kernel) |
| **ad-attack-advisor** | "use the ad-attack-advisor agent" | Plans AD attack path from BloodHound/enum |

Two skills load automatically by target type: `thm-methodology` (Linux) and
`windows-ad-methodology` (Windows/AD). You don't invoke skills manually — Claude picks the
right one and it drives what `what next?` recommends.

---

## 5. Customizing

- **Edit any command** — they're just markdown prompt templates. `$ARGUMENTS` is replaced by
  whatever you type after the slash command. Change wordlist paths, add flags, whatever fits
  your style.
- **Add a command** — drop a new `.md` in `.claude/commands/`. The filename becomes the command
  name. The `description:` in the frontmatter shows in the `/` menu.
- **Add an agent** — drop a new `.md` in `.claude/agents/`. Keep the `tools:` list minimal (only
  what it needs) so it stays focused.
- **Per-room overrides** — a `.claude/` folder inside a specific room folder overrides the shared
  one for that room only.

---

## 5b. Version control (git)

The kit is laid out so you can safely put it in a git repo and share/back up your *config*
without ever leaking *target data*.

- **Tracked** (safe to commit/push): `README.md`, `CLAUDE.md`, `WINDOWS-CHEATSHEET.md`,
  `new-room.sh`, and the whole `.claude/` folder — your commands, agents, and skills.
- **Ignored** (never committed): everything under `rooms/`. That's where every box's scans,
  notes, cracked creds, flags, and writeups live. `.gitignore` excludes `rooms/*` but keeps
  the empty `rooms/` directory itself (via `.gitkeep`) so it survives a fresh clone. `tools/`
  and `*.log` are ignored too.

To start tracking it:

```bash
cd ~/thm
git init
git add .
git commit -m "THM Claude Code kit"
# verify no room data is staged:
git status --ignored     # rooms/<yourbox>/ should appear under "Ignored files"
```

Because rooms live *under* the repo root where `.claude/` sits, they still inherit all the
config — git-ignoring them changes nothing about how the tools work, only what gets committed.

---

## 6. Notes & gotchas

- **Wordlist paths** assume `seclists` is installed at `/usr/share/seclists/`. Adjust if yours
  differ.
- **Permission prompts**: Claude Code asks before running commands by default. That's a good
  thing here — it keeps scope in check. If you run with `--dangerously-skip-permissions`, only do
  it in a throwaway VM and understand you're auto-approving arbitrary commands.
- **GUI tools** (Burp, Wireshark) aren't driven by Claude Code — it's CLI-only. It can use
  `tshark`, `mitmproxy`, or Burp's REST API instead.
- **The listener runs in its own terminal**, not inside Claude Code — `nc -lvnp` blocks, so keep
  a spare terminal open for the catch.
- **Keep notes.md honest** — the agents (especially report-writer and privesc-advisor) read it,
  so the better your notes, the better their output.

Happy hacking — stay on scope.
