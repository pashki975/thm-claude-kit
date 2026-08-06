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
    │   ├── start.md        →  /start        (room coach: setup + teach you through it)
    │   ├── vpn-check.md    →  /vpn-check
    │   ├── recon.md        →  /recon
    │   ├── enum-udp.md     →  /enum-udp
    │   ├── enum-web.md     →  /enum-web
    │   ├── web-recon.md    →  /web-recon     (vhosts / subdomains / cert SANs)
    │   ├── enum-smb.md     →  /enum-smb
    │   ├── db-enum.md      →  /db-enum
    │   ├── steg.md         →  /steg          (offline file/image analysis)
    │   ├── listener.md     →  /listener
    │   ├── linux-privesc.md→  /linux-privesc
    │   ├── tunnel.md       →  /tunnel
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
        ├── thm-trainer/SKILL.md               ← the decision loop (runs first, every room)
        ├── thm-methodology/SKILL.md           ← Linux game plan
        └── windows-ad-methodology/SKILL.md    ← Windows/AD game plan
```

**Commands** = things you trigger by typing `/name`. Fast, predictable, one job each.
**Agents** = specialists Claude hands a focused task to ("use the cve-researcher agent"). They
run in a separate context so heavy output doesn't clutter your main session.
**Skills** = the connective tissue. They tell Claude *how to think and in what order* so when
you ask "what next?" you get a methodical answer instead of a guess.

### The trainer loop (read this once)

The most important skill is `thm-trainer` — the decision loop that runs on **every** room
before any tool does. It exists because the #1 failure mode is an agent confidently doing
things that lead nowhere: parallel scans, sshing into a box that was never about shells, an
hour of motion with no progress. The loop fixes that by forcing five beats:

```
1. CLASSIFY   → what is this room teaching? what's the goal (flag string vs shell)?
2. OBSERVE    → the lightest thing that fits the class — don't over-scan
3. HYPOTHESIZE→ "the way in is probably X, because Y" (one sentence, out loud)
4. TEST       → one focused action whose result decides the next move
5. DECIDE     → new info → loop; goal met → STOP; no new info → reclassify
```

The rule underneath it all: **every action should change what you do next.** If a scan
wouldn't change your plan, don't run it. Being *stuck* = repeating actions with no new
information — the signal to reclassify, not to scan harder.

You kick a room off with **`/start`** (below). It's a **playing coach**, not an autosolver: it
does the mechanical setup (VPN check, `/etc/hosts`, notes), classifies the room and names the
goal, then teaches you through it one step at a time — explaining *why* each step, pointing you
at the right kit command, and letting **you** run it. It reads your level: light and terse when
you're flowing, and when you're stuck it drops into drive mode, reasons through the loop out
loud, and walks you through the next move in detail. The `thm-trainer` skill supplies the loop
it coaches from.

---

## 2. Install

### a. Prerequisites (one time)

```
# Node.js 18+ and Claude Code
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
npm install -g @anthropic-ai/claude-code

# Tools the Linux commands assume are present
sudo apt install -y seclists enum4linux smbclient hashid john hashcat rlwrap exploitdb
# For UDP + database + pivoting commands:
sudo apt install -y snmp onesixtyone tftp-hpa proxychains4 chisel mariadb-client postgresql-client redis-tools
# ligolo-ng and mongosh aren't apt packages — grab ligolo-ng from GitHub releases,
# mongosh from MongoDB's site. sshuttle: pipx install sshuttle

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
**winPEAS**, **linpeas**, **pspy**, **PowerUp.ps1**, **PrintSpoofer64.exe**, **GodPotato**,
**chisel/ligolo agent binaries**. Grab them from their GitHub releases and keep them in a
`~/thm/tools/` folder to serve over HTTP.

### b. Drop the kit in place

Put this whole `thm/` folder in your home directory:

```
cp -r thm ~/thm
chmod +x ~/thm/new-room.sh
```

The `.claude/` folder lives at `~/thm/`, so **every room folder underneath it inherits the same
commands, agents, and skill automatically.** You configure once, use everywhere.

### c. First run

```
cd ~/thm
claude          # authenticate on first launch
```

---

## 3. Daily workflow

### Step 1 — Start a room

```
cd ~/thm
./new-room.sh blue          # creates ~/thm/rooms/blue/ with scans/ + notes.md
cd rooms/blue
claude
```

All room folders live under `rooms/`, which is git-ignored — so your scans, notes,
cracked creds, and flags never get committed. The shared `.claude/` config at the repo
root **is** tracked, and rooms still inherit it because `rooms/` sits underneath it.

### Step 2 — Start the coach

Point Claude at the room. `/start` is your playing coach for the whole room:

```
/start https://tryhackme.com/room/<room>     # or paste the room description
```

It does the setup (VPN check, `/etc/hosts` if there's a domain, seeds `notes.md`), classifies
the room, names the goal (flag vs shell), then lays out the game plan and coaches you into the
first step — explaining why it's first and which command to run. From there it guides you one
step per turn: you run each command and paste the output, it teaches you to read it and points
you at the next move. It stays light when you're flowing and drives harder when you're stuck.
You can still run the individual commands below yourself at any time; `/start` is the guided
way through.

`/vpn-check` is folded into `/start`'s setup, but you can also run it standalone:

```
/vpn-check 10.10.123.45
```

Checks `tun0` is up, shows your VPN IP (you'll need it for reverse shells), and pings the target.

### Step 3 — Recon

```
/recon 10.10.123.45
/enum-udp 10.10.123.45      # UDP hides SNMP/TFTP/DNS — run it alongside the TCP scan
```

Full port sweep → targeted service scan on open ports → summary table → notes.md updated →
suggested next steps. Then let a specialist parse it:

```
use the recon-parser agent on the latest scans
```

### Step 4 — Enumerate per service

Pick the command matching what's open (and what the room is about):

```
/enum-web http://10.10.123.45
/web-recon futurevera.thm          # vhosts/subdomains/cert SANs — when a domain is in play
/enum-smb 10.10.123.45
/db-enum 10.10.123.45 mysql        # or mssql/postgres/mongo/redis
/steg ./downloaded-image.png       # when the room hands you a file to analyze
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

```
/linux-privesc      # walks the checklist: sudo -l, SUID, caps, cron/pspy, cred hunting
```

Run the enum it lists, paste the output back, then:

```
use the privesc-advisor agent on this output: <paste>
```

### Step 7 — Pivot (multi-host rooms)

If a second internal host appears, tunnel to it and keep going:

```
/tunnel 172.16.0.0/24     # ligolo-ng / chisel / sshuttle / SSH forwards
```

Record each internal host in notes.md as a new target and re-run the methodology against it.

### Step 8 — Document

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
skipped an enumeration path" (often UDP), which is true more often than not.

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
to crack. Also try password spraying, reading anonymous shares, and `/db-enum` if MSSQL is up.

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

### Step 7 — Pivot & domain dominance

Domain rooms pivot constantly — from the compromised host, `/tunnel` to internal targets and
reuse domain creds across the range (one cred often unlocks many hosts). Then DCSync `krbtgt`
if you reach it (full domain compromise), record flags in `notes.md`, and
`use the report-writer agent`.

---

## 4. Command quick reference

| Command            | Argument                   | Does                                                  |
| ------------------ | -------------------------- | ----------------------------------------------------- |
| `/start`           | room URL or description    | Playing coach: setup + teach you through the room step by step |
| `/vpn-check`       | target IP                  | Verify VPN up + target reachable, show your tun0 IP   |
| `/recon`           | target IP                  | Staged nmap (all ports → service scan), summarized    |
| `/enum-udp`        | target IP                  | UDP scan + SNMP/TFTP/DNS/IKE follow-up                |
| `/enum-web`        | URL                        | whatweb + ffuf dirs + nikto + common files            |
| `/web-recon`       | domain or IP               | Vhost/subdomain fuzzing + cert SANs + takeover check  |
| `/enum-smb`        | target IP                  | enum4linux + share listing + smb nmap scripts         |
| `/db-enum`         | IP type [creds]            | MySQL/MSSQL/Postgres/Mongo/Redis enum + RCE paths     |
| `/steg`            | file or dir                | Offline file/image analysis (metadata, embedded, LSB) |
| `/listener`        | port (opt)                 | Reverse shell payloads + listener + TTY upgrade steps |
| `/linux-privesc`   | —                          | Linux local privesc checklist + analysis              |
| `/tunnel`          | subnet/target (opt)        | Pivot in: ligolo-ng / chisel / sshuttle / SSH forward |
| `/crack`           | hash or file               | Identify hash, pick john/hashcat, crack it            |
| `/notes`           | —                          | Update notes.md from scans + conversation             |
| **`/enum-ad`**     | target IP                  | Windows/AD: SMB, LDAP, RPC, user harvesting           |
| **`/kerberos`**    | DC-IP DOMAIN [users/creds] | AS-REP roast + Kerberoast                             |
| **`/win-shell`**   | IP user pass/hash          | Get a session: evil-winrm / psexec / RDP              |
| **`/win-privesc`** | —                          | Windows local privesc checklist + analysis            |

| Agent                   | Invoke with                         | Does                                             |
| ----------------------- | ----------------------------------- | ------------------------------------------------ |
| recon-parser            | "use the recon-parser agent"        | Structures raw scan output into findings         |
| cve-researcher          | "use the cve-researcher agent"      | Maps versions → CVEs, checks searchsploit        |
| privesc-advisor         | "use the privesc-advisor agent"     | Ranks Linux privesc vectors from enum output     |
| report-writer           | "use the report-writer agent"       | Builds writeup.md from notes + scans             |
| **win-privesc-advisor** | "use the win-privesc-advisor agent" | Ranks Windows privesc (tokens, services, kernel) |
| **ad-attack-advisor**   | "use the ad-attack-advisor agent"   | Plans AD attack path from BloodHound/enum        |

Three skills load automatically. `thm-trainer` is the decision loop that runs first on every
room (classify → observe → hypothesize → test → decide). Then `thm-methodology` (Linux) or
`windows-ad-methodology` (Windows/AD) supplies the ordered steps, routing to the UDP, web-recon,
database, steg, privesc-checklist, and pivoting commands as needed. You don't invoke skills
manually — Claude picks them and they drive what `what next?` recommends. When Claude starts
wandering, the phrase that snaps it back is: **"you're churning — reclassify."** `/start` is the
coach that walks you through this loop out loud; the skill is what it coaches from, and it also
applies when you ask `what next?` without going through `/start`.

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

```
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
- **UDP + pivoting are the two most-missed paths** — if a Linux box has you stumped, check
`/enum-udp` output, and if the network has more than one host, `/tunnel` in.
- **Reuse creds everywhere** — SSH/SMB/web/db password reuse is rampant on THM. `/db-enum`
findings in particular tend to unlock other services.
- **Keep notes.md honest** — the agents (especially report-writer and privesc-advisor) read it,
so the better your notes, the better their output.

Happy hacking — stay on scope.
