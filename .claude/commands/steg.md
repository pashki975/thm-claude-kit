---
description: Offline file / image analysis — steganography, metadata, embedded data
---

Analyze the file(s): $ARGUMENTS  (a path, or a directory of downloaded files)

Use when a room hands you a file to download and the flag is hidden in or behind it. Work
cheap-to-slow. The flag is the goal — most of these need no shell.

## 1. Identify
- file <f>            — real type regardless of extension
- exiftool <f>       — metadata: authors, comments, GPS, flags in fields
- strings -n 6 <f>   — grep for flag{, THM{, base64, URLs

## 2. Embedded / appended data
- binwalk <f> ; binwalk -e <f> (or foremost <f>)
- try unzip/7z x on an image (polyglots)

## 3. Image steganography
- steghide info <f> ; steghide extract -sf <f> (blank passphrase + room passwords)
- zsteg <f> (PNG/BMP LSB) ; stegseek <f> <wordlist> (brute steghide w/ rockyou)
- stegsolve for visual LSB / colour-plane inspection

## 4. Audio / docs
- Audio: spectrogram in Audacity/sonic-visualiser (flags drawn there)
- PDFs: pdfdetach -list, pdf-parser ; Office: unzip and read XML/macros

## 5. Protected/hashed
- Hand off to /crack (zip2john etc.)

## 6. Summarize
Say what the file was, what was hidden, how you got it. If you recovered the flag, stop.
Record in notes.md. Note: steg is mostly beginner/jeopardy-CTF — on a normal box, don't
rabbit-hole where straightforward enumeration is intended.
