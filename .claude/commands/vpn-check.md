---
description: Verify THM VPN is up and the target is reachable
---

Confirm connectivity before we start. Target: $ARGUMENTS

1. Check tun0 exists and show its IP: `ip addr show tun0` (if missing, tell me the VPN is down and stop)
2. Show my THM IP (the tun0 inet address) — I'll need it for reverse shells
3. If a target was given, test reachability: `ping -c 3 $ARGUMENTS`
4. Report: VPN status | my tun0 IP | target reachable yes/no
5. If anything fails, give the exact fix (e.g. `sudo openvpn ~/thm/thm.ovpn`)
