---
description: Produce the deployment runbook, change-request text, rollback plan and a one-page Director summary; never executes a deployment
argument-hint: <unit> <test|stage|prod>
allowed-tools: Read, Write, Grep, Glob, Bash(git status *), Bash(git log *)
---
<!-- Name: cdb-deploy-plan.md | Purpose: Lock 6 deployment planning | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-deploy-plan

Inputs: $ARGUMENTS. Unit name and the target environment label (`test`, `stage` or `prod`). A label only. No server names in this command's output; use roles such as `<management-server>` and `<reporting-primary>`.

Preconditions: the unit's release file exists (`docs/rebuild/release/<unit>.md`) and the branch is merged by the user. Otherwise stop and name `/cdb-version <unit>`.

This command never connects to an instance, never runs a script and never opens a change ticket. It writes documents.

Steps:

1. Write `docs/rebuild/deploy/<unit>-<environment>.md` with these parts in order:
   1. **Director summary (one page, plain language, readable in under five minutes):** what changes, why, who is affected, what could go wrong in one sentence each, how long, what the rollback is, and the decision requested. No jargon without a one-line gloss. No SQL.
   2. **Change-request text:** title, description, risk level and reason, impact on availability, maintenance window, approvers, backout trigger.
   3. **Runbook:** numbered steps, each with the exact script name from `src/`, the report-only dry run first, the `-Apply` run second, the expected output, and a stop condition. Include pre-checks (backups, AG health on the reporting pair, free space, Agent running) and post-checks (reconciliation output, run-log rows, reporting view row counts).
   4. **Rollback plan:** trigger, steps using the rollback scripts, data restoration from backup, verification, time estimate.
   5. **Classification and zone notes:** which zone and classification tier each step touches. No cross-tier copying.
   6. **Open items:** every UNVERIFIED and DECISION item still unresolved. A production plan with an unresolved DECISION is marked NOT READY.
2. For `prod`: add the line "Production deployment requires Director change approval (G4). This document is not that approval."
3. Check the length of part 1 (about 400 words at most).

Gate G4 (production only): print "Decision needed: Director change approval for <unit> in prod" and end.

Exit check: the file has all six parts; the summary has no unexplained jargon; rollback is present; no server names appear; nothing was executed.

Next: for `test` or `stage`, the user runs the runbook. For `prod`, wait for G4, then the user runs the runbook. `/cdb-status` after each deployment.
