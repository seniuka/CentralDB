---
description: Generate a collector function for one CentralDB domain and its SQL Agent job definition, push or pull, SQL Server first
argument-hint: <unit> <sqlserver|postgresql|oracle> <nonprod-target-instance> [-Apply]
allowed-tools: Read, Write, Edit, Grep, Glob, Agent, Bash(git status *), Bash(git diff *)
---
<!-- Name: cdb-collector.md | Purpose: Lock 2 collector and job generation | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-collector

Inputs: $ARGUMENTS. Unit name, platform, a non-production target instance, optional `-Apply`.

Preconditions:

- `docs/rebuild/plans/<unit>.md` is APPROVED and names the collection mode (push, pull or both). Otherwise stop and name `/cdb-plan <unit> --approve`.
- Target guard: the instance must be in `docs/nonprod-targets.md` and must not look like a production listener. If the check fails, stop and print: "Target refused. To proceed, type: CONFIRM-TARGET: <exact name>". The confirmation must be typed by the user in this session.
- Platform `postgresql` or `oracle`: stop unless the plan records an approved driver decision. Those platforms cannot use dbatools, and a new module or driver is a proposal that needs the user first.

Steps:

1. Use the `cdb-collector-pattern` skill. It defines the function shape, the result contract, throttled parallel dual-path, run-log capture, staging write-back and the parse checks.
2. Write `src/powershell/Get-DbtCentralDb<Domain>.ps1`, one function per file, single-block shape. Report-only by default; `-Apply` writes to staging. Instance parameter is `[DbaInstanceParameter]`. Targets come from the inventory, never from a hard-coded list.
3. If the plan's collection mode includes push, also write the dual-block wrapper for SQL Agent CmdExec as `src/jobs/Invoke-DbtCentralDb<Domain>Job.ps1`. This is the only place dual-block is allowed.
4. Write the Agent job definition `src/jobs/New-DbtCentralDb<Domain>Job.ps1` (idempotent, report-only unless `-Apply`) and its rollback `src/jobs/Remove-DbtCentralDb<Domain>Job.ps1` (also report-only unless `-Apply`). Verify each dbatools parameter you use against the installed version with `Get-Command <name> | Select-Object -ExpandProperty Parameters`. Tag anything unchecked UNVERIFIED.
5. Write `docs/scripts/<Name>.md` for each script with the standard header and the impacted-docs list. Always include `docs/SCRIPT-REFERENCE.md` and `docs/SQL-AGENT-JOBS.md`; add each `docs/schemas/<schema>.md` the script reads or writes.
6. Parse-check every `.ps1` on Windows PowerShell 5.1 and PowerShell 7.2 or later (skill section "Parse checks"). This needs a PowerShell approval prompt, by design.
7. Call the `dbatools-script-reviewer` agent on the new files and fix every blocking finding.
8. Without `-Apply`, nothing runs against any instance. With `-Apply` typed by the user, run the job script once against the guarded target and show the result.

Exit check: each function parses on 5.1 and 7.2+; no deny-list pattern is present; the reviewer reports no blocking finding; docs exist; rollback exists.

Next: `/cdb-test <unit> <nonprod-target>`.
