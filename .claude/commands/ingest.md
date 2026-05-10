---
description: Run the wiki ingest workflow against the files queued in .claude/pending-ingest.txt
---

Read `wiki/prompts/ingest.md` and execute the workflow it describes in full.

The list of changed files lives at `.claude/pending-ingest.txt`. If that file is empty or missing, emit `INGEST: skipped — no pending files` and stop.

Do not skip phases. Do not return a final response until phases I-0 through I-7 (including the L-0 through L-7 lint pass run by I-7) are complete and the pending list has been cleared.
