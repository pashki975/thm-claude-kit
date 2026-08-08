---
description: Maintain the ROOM BRAIN — the structured state file the coach reasons from
---

Update notes.md as the room's working memory (the "room brain"), not a passive log. Review
scans/ and our conversation, then keep these sections current and factual — only what's confirmed.

```
# <Room> — Room Brain

## Goal / stop condition
- (flag string? user+root? specific answer?)

## Kill-chain position
- recon | foothold | lateral/pivot | privesc | domain/loot   ← mark where we are

## Confirmed facts
- Target IP / hostname / OS:
- Open ports & services (with versions):
- Tech stack:

## Creds / keys held        ← most important on complex rooms
| cred | type | works on | tried elsewhere? |
|------|------|----------|------------------|

## Hosts / network
- (every host/subnet found; note reachable vs pivot-only)

## Open leads
- (seen but not yet chased)

## Dead ends
- (tried, didn't pay off — don't loop back)

## Flags
- User:
- Root:
```

When called, reconcile this with everything we've learned: add new confirmed facts, record every
cred and where it does/doesn't work, list new hosts and leads, cross off dead ends, and update
the kill-chain position. This file is what lets the coach reason about the room as a whole rather
than reacting to the last command.
