---
description: Build the OCEANS prompt card and intake for one rebuild unit; with --approve, record gate G1
argument-hint: <unit> [sqlserver|postgresql|oracle] [--approve]
allowed-tools: Read, Grep, Glob, Write, Edit, Bash(git status *), Bash(git log *)
---
<!-- Name: cdb-plan.md | Purpose: Lock 1 plan card for one rebuild unit | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-plan

Inputs: $ARGUMENTS. First word is the unit name in kebab-case (for example `svr-core`). Optional platform, default `sqlserver`. Optional `--approve`.

Preconditions: `docs/rebuild/discovery/dependency-map.md` exists. If not, stop and name `/cdb-discover all`.

Without `--approve`:

1. If `docs/rebuild/plans/<unit>.md` already exists and is APPROVED, stop and say so. Changing an approved card needs the user to say so in chat.
2. Ask at most one batch of questions for anything the discovery and `docs/workflow-map.md` do not answer. Offer a recommended default for each. Stop if any answer is missing.
3. Write `docs/rebuild/plans/<unit>.md` with the OCEANS card:
   - **Mission and role:** one paragraph. Platform and team scope (infrastructure, availability, performance, access management only).
   - **O Output:** exact files and paths the Develop commands will produce.
   - **C Constraints:** deny-list, `-Apply` gating, non-production targets, classification tiers, air-gapped modules.
   - **E Examples:** the skill or existing file that the unit follows.
   - **A Audience:** Claude Code, senior DBAs, Director.
   - **N Notation:** function names (`Verb-DbtCentralDb<Noun>`), schemas, file names. List every new schema.
   - **S Standardization:** the LOCKS path for this unit and which commands run in what order.
   - **Unit facts:** tier (T0, T1, T2), zone, classification tier, collection mode (push, pull or both), supported SQL Server versions, platform, consumers (reporting view contract), merge needs, rollback approach, test plan with synthetic data, risks, `DECISION` items.
   - First line after the header: `Status: DRAFT`.
4. For each new schema, write a stub `docs/decisions/ADR-<next free number>-<schema>-schema.md` with `Status: Proposed`. New schemas need an ADR before use.
5. Tag every unchecked claim UNVERIFIED.
6. Gate G1: print "Decision needed: approve the plan card for <unit>. To approve, run: /cdb-plan <unit> --approve" and end.

With `--approve`:

1. Only act if the user typed this invocation. Never run it from inside another command or agent.
2. Confirm the card has no empty section and no unresolved `DECISION` that blocks the unit. If any exist, list them and stop.
3. Change the status line to `Status: APPROVED (G1, <today's date>)`.

Exit check: the card has all seven OCEANS sections filled and a status line; every new schema has an ADR stub; the only files changed are under `docs/rebuild/plans/` and `docs/decisions/`.

Next: after approval, the Develop command that matches the unit: `/cdb-schema`, `/cdb-collector`, `/cdb-merge` or `/cdb-views`, as listed in the card.
