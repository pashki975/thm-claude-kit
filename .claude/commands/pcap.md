---
description: Analyze a packet capture (or live-capture) with tshark — overview first, targeted digs gated
---

Analyze traffic for: $ARGUMENTS
Expected: a path to a .pcap/.pcapng file, OR "live <interface>" to capture first.

tshark is the CLI of Wireshark, so I can actually drive it. Work the same cheap→heavy way as the
enum commands: get the overview first, form a hypothesis about what the room wants, THEN run the
targeted extraction — don't blindly dump every packet.

## The gate
Before a heavy extraction (carving all files, exporting every object, following hundreds of
streams), say a one-line hypothesis about what the room is asking for (a credential? a
transferred file? a specific conversation? evidence of an attack?) and let the overview point
you at it. The protocol breakdown usually tells you where the answer lives — go there, don't
grep the whole capture blindly.

## 0. Live capture first (only if $ARGUMENTS starts with "live")
- `sudo tshark -i <interface> -w scans/capture.pcap` (Ctrl-C to stop), then analyze that file.
- Or capture with a filter: `sudo tshark -i <interface> -f "port 21 or port 80" -w scans/capture.pcap`

## 1. CHEAP overview — always do these first
- Protocol hierarchy (what's even in here): `tshark -r <file> -q -z io,phs`
- Conversations (who talked to whom, volumes): `tshark -r <file> -q -z conv,ip`
- Top talkers / endpoints: `tshark -r <file> -q -z endpoints,ip`
- A quick skim of the first packets: `tshark -r <file> -c 50`
Read these and form the hypothesis before digging.

## 2. Credential & data extraction (gate to what the overview suggests)
- Cleartext creds (HTTP/FTP/Telnet/POP/IMAP/SMTP): filter to the protocol and read it, e.g.
  `tshark -r <file> -Y "http.request.method==POST" -T fields -e http.file_data`
  `tshark -r <file> -Y "ftp.request.command==USER || ftp.request.command==PASS" -T fields -e ftp.request.arg`
- Follow a specific TCP stream once you know which one:
  `tshark -r <file> -q -z follow,tcp,ascii,<stream-number>`
- Search everything for a token when you must: `tshark -r <file> -Y 'frame contains "flag"'`
- DNS queries (exfil / C2 hints): `tshark -r <file> -Y dns -T fields -e dns.qry.name | sort -u`
- HTTP objects (URLs, user-agents, hosts):
  `tshark -r <file> -Y http.request -T fields -e http.host -e http.request.uri`

## 3. File carving / object export (heavy — gate it)
- Export HTTP objects to disk: `tshark -r <file> --export-objects http,scans/http-objects/`
  (also smb/tftp/imf/ftp-data as the object type). Then inspect carved files with /steg if needed.
- For odd protocols, follow the stream and save raw, then `file`/`binwalk` the bytes.

## 4. Attack / anomaly analysis (if the room is "what happened")
- Look for scans (many SYNs), brute force (repeated logins), odd ports, large transfers.
- `tshark -r <file> -q -z expert` surfaces warnings/anomalies tshark flagged.

## Summarize
Lead with the overview (protocols + conversations), then the specific answer the room wanted
(cred / file / event) and exactly how you found it. Record it in notes.md. If you carved files,
note where they are. If the goal (the flag / the answer) is met, stop.

Tip: if the capture has TLS and the room provides a key or SSLKEYLOGFILE, add
`-o tls.keylog_file:<path>` (or the RSA key) to decrypt — otherwise HTTPS payloads stay opaque.
