---
description: Run the deny-list scan, standard conformance and the scoring rubric; zero deny-list hits or the work drops back to Develop
argument-hint: <unit|all>
allowed-tools: Read, Write, Grep, Glob, Agent, Bash(git status *), Bash(git diff *), Bash(git log *)
---
<!-- Name: cdb-quality.md | Purpose: Lock 4 quality gate | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-quality

Inputs: $ARGUMENTS. A unit name or `all`.

Preconditions: test results exist for the unit (`docs/rebuild/test-results/<unit>.md`). Otherwise stop and name `/cdb-test <unit> <nonprod-target>`. No backflow: Lock 4 is not run on a unit that skipped Lock 3.

Steps:

1. Collect the unit's files from the plan card's Output section, plus their docs.
2. Call the `cdb-deny-list-scanner` agent on those files. It returns a table of hits per deny-list row with file and line. Any hit fails the gate. There is no waiver inside this command. A waiver is a G2 decision with an exception recorded in an ADR.
3. Conformance: check the files against DBA Automation Engineering Standard v5.0.0. The v5.0.0 text is not in this repo (only v4.1.0 is). Until the user supplies it, every conformance line is tagged UNVERIFIED and checked against the brief's constraints instead (PowerShell 5.1 floor and 7.2+ support, `Verb-Dbt*` names, `[DbaInstanceParameter]`, single-block shape with dual-block only for CmdExec, `-Apply` gating, `-ThrottleLimit` with a 5.1 fallback, file headers) and the prose rules in `docs/deny-list.md` section 5.
4. Score out of 100 and record the rubric used:
   - Safety (gating, guards, no secrets, no production target): 30
   - Standard and constraint conformance: 25
   - Documentation complete with impacted-doc lists: 15
   - Tests present and passing: 15
   - Reliability (idempotence, error capture, rollback): 15
   Pass needs a score of at least 80, zero deny-list hits and no blocking finding.
5. Write `docs/rebuild/quality/<unit>.md`: date, commit hash (`git log -1 --format=%h`), deny-list table, conformance table with VERIFIED or UNVERIFIED, score, verdict.
6. If any deny-list row has a hit: print "Lock 4 failed: work drops back to Develop" with the hits, name the Develop command that produced each file, and stop.

Exit check: the report exists, the deny-list table covers every row of `docs/deny-list.md`, and the verdict is PASS or FAIL.

Next: on PASS, `/cdb-docs <unit>` then `/cdb-version <unit>`. On FAIL, the Develop command named in step 6.
