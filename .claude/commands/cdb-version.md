---
description: Update version headers, changelog, documentation set and ADRs for a unit; prepare commit and pull request text
argument-hint: <unit> [major|minor|patch]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git branch *)
---
<!-- Name: cdb-version.md | Purpose: Lock 5 versioning and PR preparation | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-version

Inputs: $ARGUMENTS. Unit name and an optional bump level (default `minor` for a new unit, `patch` for fixes).

Preconditions:

- The quality report for the unit says PASS, and no file of the unit is newer than the report (compare `git log -1 --format=%cI -- <path>` with the report date). If a file changed after the report, stop and name `/cdb-quality <unit>`.
- `/cdb-docs <unit>` has run (the impact file exists).
- Current branch is not `master`.

Steps:

1. Bump the version in the header of each unit file and its doc. Semantic versioning: breaking contract change is major, new capability minor, fix patch. A change to a reporting view contract version (`_v1` to `_v2`) is never a silent edit.
2. Add an entry to `CHANGELOG.md` (create it with the Keep a Changelog layout if it does not exist): version, date, units, added, changed, removed (proposals only), verified and unverified items.
3. Update or add ADRs: any new schema, deny-list exception, or driver decision gets an ADR with its status. Link them from the plan card.
4. Prepare commit text, one deliverable per commit, each stating what it is and which command or doc it affects. Write it to `docs/rebuild/release/<unit>.md`. Do not run `git commit` or `git push`.
5. Prepare pull request text in the same file: summary, files by deliverable, the list of UNVERIFIED items, the list of DECISION items for the user, the Lock 4 result, and the rollback summary. State that Claude does not merge.
6. Tag any unchecked statement UNVERIFIED.

Gate G3: print "Decision needed: review the pull request and merge it yourself" and end.

Exit check: `CHANGELOG.md` has an entry for the new version; header versions match the changelog; the release file lists UNVERIFIED and DECISION items; Lock 4 is clean on the final tree (re-read the report date).

Next: after the user merges, `/cdb-deploy-plan <unit> <test|stage|prod>`.
