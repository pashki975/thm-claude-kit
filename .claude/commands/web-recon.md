---
description: Subdomain / virtual-host / certificate recon (the DNS-side of web enum)
---

Recon the DNS/vhost surface of: $ARGUMENTS  (a domain, or the target IP with a known domain)

The DNS-side complement to /enum-web. Use when the room gives you a domain name, hints at
subdomains, or is about subdomain takeover. Goal is usually a hidden host — often the flag
lives there, no shell needed.

## 1. Resolve
- Ensure the domain is in /etc/hosts pointing at the target IP (add with my approval).

## 2. Virtual-host fuzzing
- ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
    -u http://<IP> -H "Host: FUZZ.<domain>" -fs <default-page-size>
- Find the default response size first (curl the IP) and filter with -fs/-fw. Repeat on https.

## 3. Certificate inspection (subdomains leak in SAN fields)
- openssl s_client -connect <domain>:443 </dev/null 2>/dev/null | openssl x509 -noout -text \
    | grep -A1 "Subject Alternative Name"
- Or sslscan <domain>. The classic Takeover-style insight.

## 4. DNS enumeration
- Zone transfer: dig axfr @<IP> <domain>
- dnsrecon -d <domain> -n <IP>

## 5. Subdomain takeover check
- A subdomain whose CNAME points to an unclaimed cloud resource (S3/Azure/GitHub Pages/Heroku)
  — tell is a NoSuchBucket/404 fingerprint. Flag is often in the redirect URL.

## 6. Summarize
List every subdomain found and how. Add each to /etc/hosts, note which to investigate, record
in notes.md. If the goal was a flag and you found it, stop.
