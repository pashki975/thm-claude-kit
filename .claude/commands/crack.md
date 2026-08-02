---
description: Identify and crack a hash or password-protected file
---

Crack the following: $ARGUMENTS  (a hash string, or a path to a hash/file)

1. If it's a hash, identify the type: `hashid` / `hash-identifier`, and give the matching hashcat mode (-m) and john format
2. Recommend the approach (john vs hashcat) and the wordlist (default: rockyou)
3. Provide the exact command, e.g.:
   `john --format=<fmt> --wordlist=/usr/share/wordlists/rockyou.txt hash.txt`
   `hashcat -m <mode> hash.txt /usr/share/wordlists/rockyou.txt`
4. For protected files (zip/pdf/ssh key), show the *2john step first (zip2john, ssh2john, etc.)
5. Run it if I confirm, and report the cracked value
