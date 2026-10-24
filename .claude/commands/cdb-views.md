---
description: Generate the versioned reporting-view contract for a unit; replaces backward-compatible view generation because the old views are being redesigned
argument-hint: <unit> [contract-version, default v1]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status *), Bash(git diff *)
---
<!-- Name: cdb-views.md | Purpose: Lock 2 reporting views (renamed from cdb-view-compat) | Version: 0.1.0 | Standard: v5.0.0 | Author: Your Friendly Neighbourhood DBA | Date: 2026-10-24 -->

# /cdb-views

Why the rename: the brief's `/cdb-view-compat` kept old consumers working. Intake answer 6 says the old reports and views are cleared out and redesigned, so there is no legacy contract to preserve. The command now defines the new contract. DECISION: if some consumer must still read an old view name, say so in chat and the plan card gets a compat section.

Inputs: $ARGUMENTS. Unit name, optional contract version (default `v1`).

Preconditions: the plan card is APPROVED and lists the consumers (reports, the web reporting app, ad hoc queries) and the columns they need. The tables the views read exist in `src/sql/`. Otherwise stop and name the missing command.

Steps:

1. Write `src/sql/rpt/<Unit>.views.<version>.sql`. Proposed schema `rpt` needs an ADR, so check `docs/decisions/` and stop at gate G2 if it is only Proposed.
2. View naming: `rpt.v<Subject><Grain>_<version>`, for example `rpt.vInstanceCurrent_v1`. Each view lists every column by name. `SELECT *` is on the deny-list.
3. Row-level security and masking: if the plan names a restricted audience, add a security policy and mask definitions in `<Unit>.views.<version>.security.sql`. Dynamic data masking is not a strong boundary against users who can run ad hoc queries; say so in the doc. Row-level security predicate functions must be inline table-valued and schema-bound.
4. A version change never edits an existing version in place: add `_v2` next to `_v1`, and record the change in the contract doc.
5. Write `docs/schemas/rpt.md` as the consumer contract (view, column, type, meaning, nullability, introduced-in version) and `docs/scripts/<Unit>-views.md`. List impacted docs.
6. Parse-check the SQL offline (skill `cdb-collector-pattern`, section "Parse checks").

Exit check: every view is versioned, names its columns, and parses; the contract doc lists every column; no `SELECT *`; no hard-coded server names.

Next: `/cdb-test <unit> <nonprod-target>`.
