---
description: Set up a reverse shell listener and generate matching payloads
---

Set up to catch a reverse shell on port: $ARGUMENTS (default 4444)

1. Show my tun0 IP as LHOST
2. Give me ready-to-paste payloads for that LHOST/LPORT in: bash, python3, nc mkfifo, and a PowerShell one-liner
3. Tell me to start the listener in a separate terminal with:
   `rlwrap nc -lvnp <port>`   (rlwrap gives arrow-key history)
4. Remind me of the post-shell TTY upgrade steps:
   - `python3 -c 'import pty;pty.spawn("/bin/bash")'`
   - Ctrl-Z, then `stty raw -echo; fg`, then `export TERM=xterm`

Do not execute the payload — just prepare everything.
