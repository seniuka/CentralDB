# ADR-0001: CentralDB rebuild strategy and topology

> **Name:** ADR-0001-rebuild-strategy.md · **Purpose:** record the intake answers and the chosen rebuild strategy · **Version:** 0.1.0 · **Standard:** DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo) · **Author:** Your Friendly Neighbourhood DBA · **Date:** 2026-10-24

**Status:** Proposed. It becomes Accepted when you merge the pull request that adds it (gate G3).

Tags: `VERIFIED` (checked against a source this session), `UNVERIFIED` (not checked), `DECISION` (needs your call).

## 1. Context

CentralDB is the central SQL Server inventory and monitoring database for 1,300+ instances and 445 Availability Groups across Zone 4 and Zone 5, Protected A/B and Protected C tiers. The Database Platform Services team owns infrastructure, availability, performance and access management only.

The current repository (`seniuka/CentralDB`, a fork of `CrazyDBA/CentralDB`) `VERIFIED 2026-10-24`:

- Schemas in the create script: `AS`, `DB`, `FRK`, `IS`, `Inst`, `RS`, `Svr`, `Tbl`, plus four `dbo` tables.
- Seven `Collect/*.ps1` scripts built on dbatools, run as SQL Agent CmdExec steps with a dual-block shape, targets from CMS and `Svr.ServerList`.
- Fifteen `*Current` views in `SQL/Views/CurrentState.Views.sql` and a set of SSRS `.rdl` reports.
- No `CLAUDE.md`, no `.claude/` folder, no tests beyond two manual scripts.
- The v4.1.0 PowerShell guidelines, not v5.0.0.

This pass builds the workflow scaffold that the rebuild will run through. It does not rebuild CentralDB.

## 2. Intake answers

| # | Question | Answer | Source |
|---|---|---|---|
| 1 | Repo state, branch | "new branch": work on `claude/cdb-workflow-scaffold`, cut from `origin/master`. No existing CLAUDE.md, `.claude/`, commands or skills | your answer; branch base is a default I chose, `master` rather than the unmerged `feature/current-state-views` |
| 2 | Central instance and scope | "We will be rebuilding it all so it can support all supported configurations for SQL Server, and extend support for postgres/oracle." Clarified: the report and analytics servers are a SQL Server 2025 AG pair; central management servers are individual (standalone) servers; their SQL Server version was not given | your answer and clarification |
| 3 | Rebuild strategy and topology | "Central mgmt servers to collect the inventory and then a process to merge central mgmt servers to a centralized reporting and analytics server" | your answer |
| 4 | Collection model | "Per server to central mgmt server, or run from central mgmt server": support push and pull | your answer |
| 5 | First milestone | M1 `svr-core`, `inst-core`, `run-log`, `rpt-views-v1`; M2 `inst-commandlog`, `ag`, `backup`; M3 `security`, `audit`, `cache`, platform adapters | "great that works for me" (default accepted) |
| 6 | Consumers to keep | "Clear out reports they are old and archaic, clean out views and redesign": no legacy consumer contract. Deletions are proposed, not done | your answer |
| 7 | Approval flow | G1 plan, G2 new schema or exception, G3 PR review, G4 Director (production only), GD deletions | "great works for me" (default accepted) |
| 8 | Documentation layout | `docs/scripts/`, `docs/schemas/`, `docs/decisions/`, impacted-doc lists; "document it all and make a new readme" | default accepted, plus your instruction |

Defaults applied after your "go" without an explicit answer, `DECISION` to confirm:

| Item | Default applied |
|---|---|
| Standard v5.0.0 text | Not supplied. Conformance claims are `UNVERIFIED` and checked against the brief's constraints |
| v4.1.0 says dual-block for every script and `[string[]]` for instance parameters; the brief says single-block primary and `[DbaInstanceParameter]` | The brief and v5.0.0 win. Dual-block is used only for the SQL Agent CmdExec wrapper, with string parameters at script level because `powershell.exe -File` cannot resolve `[DbaInstanceParameter]` before dbatools loads (`VERIFIED` on 5.1.26100) |
| Existing code against the deny-list (`Write-Host`, `SELECT *`, SQL authentication in docs and tests) | The deny-list gates files generated in the rebuild only. `/cdb-discover` records legacy hits as BASELINE and fixes none |
| README tells users to `Install-Module dbatools` | Conflicts with the air-gapped rule. Recorded here; the new README says modules come from the UNC PSRepository |
| Function naming | New code `Verb-DbtCentralDb<Noun>`; legacy `*-Central*` names stay until a later migration |
| Reporting AG edition | Unknown. Treated as an open `DECISION`; designs that need Enterprise are tagged |

## 3. Decision

**Strategy: hybrid, domain by domain.** Each domain (schema, collector, merge, view contract) is built side by side as new objects under `src/`, tested on non-production pairs, and cut over one domain at a time. The legacy tree stays in place until the deletion proposal is approved.

Reasons:

1. 1,300+ instances and two classification tiers make an all-at-once cutover hard to roll back.
2. The topology changes (three tiers, two collection modes, new platforms), so an in-place refactor by schema would keep the old shape.
3. Domain-by-domain units fit the LOCKS gates and the approval flow.

**Topology.**

- Tier 0: targets. SQL Server on every supported version, later PostgreSQL and Oracle through adapters.
- Tier 1: standalone management servers. They collect inventory, by push (a job on each target writes to its management server) or by pull (a runner on the management server collects from targets).
- Tier 2: the reporting and analytics server, a SQL Server 2025 AG pair. A merge process moves Tier 1 data to Tier 2.

**Version rule.** Tier 2 may use SQL Server 2025 features, gated by the edition. Tier 1 and Tier 0 code uses only features present on every supported version, and anything newer is version-gated and tagged. Supported-version baseline `VERIFIED 2026-10-24`: 2016 extended support ended 2026-07-15, 2017 ends 2027-10-13, 2019 ends 2030-01-09, 2022 ends 2033-01-12.

**Dependencies.** dbatools stays the primary layer. PostgreSQL and Oracle cannot use it; a driver is a proposed dependency (see `docs/modernization-candidates.md`, P1) and is not added.

## 4. Changes to the brief's command set

| Brief | Now | Why |
|---|---|---|
| `/cdb-view-compat` | `/cdb-views` | Intake answer 6 removes the legacy contract, so the command defines a new versioned contract instead of preserving old views |
| (none) | `/cdb-merge` added | The Tier 1 to Tier 2 merge is a distinct, ongoing process, not a one-time migration |

The other twelve commands are kept as specified.

## 5. Proposed schemas (each needs its own ADR before use)

| Schema | Use | Status |
|---|---|---|
| `stg` | Staging tables for collector write-back and the merge | Proposed, `DECISION` |
| `ops` | Run log and merge watermarks | Proposed, `DECISION` |
| `rpt` | Versioned reporting views | Proposed, `DECISION` |
| `cache`, `AG`, `Backup`, `Security`, `Audit` | Named in the brief but not in the repo | Proposed for M2 and M3, `DECISION` |

## 6. Alternatives considered

- **Greenfield side by side, single cutover.** Clean, but one large cutover across the whole fleet and no early feedback.
- **In-place refactor by schema.** Lowest effort at the start, but it keeps the single-server shape and ties the rebuild to the legacy objects.

## 7. Consequences

- A new `src/` tree sits beside the legacy tree until deletions are approved.
- Each unit needs a plan card, an approved gate, tests on a non-production pair and a quality report before it can ship.
- Two sets of conventions coexist for a while (legacy and rebuilt). New work follows the rebuilt conventions only.
- Reporting consumers are redesigned, so every reader of the old views and reports changes. The deletion proposal lists them.
- Several designs depend on open `DECISION` items (section 8).

## 8. Open DECISIONs

1. Provide the v5.0.0 standard text, or confirm v4.1.0 plus the brief as the working rule set.
2. Provide `docs/nonprod-targets.md` (the allow-list of non-production targets). Commands refuse any target not on it.
3. Edition of the Tier 2 AG pair (Enterprise or Standard).
4. SQL Server versions of the Tier 1 management servers.
5. Whether Protected A/B and Protected C data share one reporting pair.
6. Confirm `src/` as the home for rebuilt code and the three proposed schemas (`stg`, `ops`, `rpt`).
7. PostgreSQL and Oracle driver choice, and its authentication model.
8. Pester 5 source on the UNC PSRepository.
9. Whether an internal copy of the project has `cache.JsonStore`, `cache.QueryRegistry`, `vwGETAGReplicasInfoCurrent` and the sliding-window `Inst.CommandLog` (none are in this repo).
10. Approve, amend or reject `docs/decisions/deletion-proposal.md` (gate GD).
11. Whether one failed instance should fail an Agent job step (the template fails the step only when every target fails).
12. Execution policy for Agent job steps (the template assumes `RemoteSigned`).

## 9. Reversing this decision

The scaffold adds files only. To back it out, close the pull request without merging; nothing outside the new files changed.
