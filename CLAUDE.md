# CLAUDE.md

Project memory for Claude Code in this repository. This file did not exist before the rebuild scaffold, so it starts with the section below. Add other sections under their own headings; do not rewrite this one without the user's say-so.

## CentralDB rebuild

Government of Alberta Database Platform Services. CentralDB is the central SQL Server inventory and monitoring database for 1,300+ instances (445 Availability Groups), Zone 4 and Zone 5, Protected A/B and Protected C tiers. The team owns infrastructure, availability, performance and access management only, not application or data-side work.

Topology being built (ADR-0001): Tier 0 targets (SQL Server all supported versions, later PostgreSQL and Oracle) feed Tier 1 standalone management servers, either per-server push or pull from the management server. A merge process moves Tier 1 data to Tier 2, the reporting and analytics server (a SQL Server 2025 AG pair).

### Where things are

- Workflow map, phases, gates, current state: [docs/workflow-map.md](docs/workflow-map.md). Start any session with `/cdb-status`.
- Commands (`.claude/commands/`): `/cdb-status`, `/cdb-discover`, `/cdb-plan`, `/cdb-schema`, `/cdb-collector`, `/cdb-merge`, `/cdb-views`, `/cdb-migrate`, `/cdb-test`, `/cdb-quality`, `/cdb-docs`, `/cdb-version`, `/cdb-deploy-plan`, `/cdb-modernize-audit`.
- Agents (`.claude/agents/`, read-only): `cdb-schema-reviewer`, `dbatools-script-reviewer`, `cdb-deny-list-scanner`.
- Skills (`.claude/skills/`): `cdb-collector-pattern`, `cdb-partition-pattern`, `cdb-merge-pattern`.
- Standard: DBA Automation Engineering Standard **v5.0.0**. Its text is not in the repo (only v4.1.0 is, at `powershell-dba-engineer-guidelines-v4.1.0.md`). Until it is supplied, conformance claims are `UNVERIFIED`. Where v4.1.0 and the brief disagree, the brief and v5.0.0 win and the conflict is recorded in the ADR.
- Deny-list: [docs/deny-list.md](docs/deny-list.md). One hit fails Lock 4.
- Decisions: [docs/decisions/](docs/decisions/), starting with ADR-0001. Modernization candidates: [docs/modernization-candidates.md](docs/modernization-candidates.md).

### Hard rules

- Report-only by default. Anything that changes state needs `-Apply`, typed by the user for that run.
- Never connect to or modify production. A target must be listed in `docs/nonprod-targets.md` and must not look like a production listener. Otherwise refuse and print: "Target refused. To proceed, type: CONFIRM-TARGET: <exact name>". A confirmation counts only if the user typed it in this session. Scripts themselves do not embed this guard, because approved production runs happen through the runbook.
- No credentials, connection strings with secrets, tokens or keys anywhere. Integrated authentication or gMSA only. Refer to secrets by name.
- Protected C inventory never appears in Protected A/B docs, examples or fixtures. Test data is synthetic.
- Do not delete files, drop objects or force-push. Propose deletions in `docs/decisions/deletion-proposal.md` and wait (gate GD).
- dbatools is the primary layer. A new module or driver is proposed first. Air-gapped: modules come from the UNC PSRepository, never `Install-Module` from the internet or runtime downloads.
- PowerShell 5.1 floor, 7.2+ supported. Functions `Verb-Dbt*`, CentralDB-facing `Verb-DbtCentralDb<Noun>`, `[DbaInstanceParameter]` for instances, single-block primary, dual-block only for SQL Agent CmdExec, `ForEach-Object -Parallel` only through the dual-path with `-ThrottleLimit` and a 5.1 fallback.
- Do not guess dbatools parameters, SQL Server behavior or Claude Code conventions. Verify, or tag `UNVERIFIED`.
- Human gates are real stops: print the decision needed and end. Never merge a pull request.
- Prose: no em dashes, and do not use the words "simply" or "easy".

### Notation

- Tags in generated docs: `VERIFIED` (checked against a source this session), `UNVERIFIED` (not checked), `DECISION` (needs the user).
- Every generated file carries a header: name, purpose, version, standard version (v5.0.0), author "Your Friendly Neighbourhood DBA", date.
- Files: `kebab-case.md` for docs, `Verb-DbtNoun.ps1` for scripts, one function per file. Keep existing schema names (`Svr`, `Inst`, and so on); a new schema needs an ADR.
- New rebuilt code goes under `src/`. The legacy tree (`Collect/`, `SQL/`, `CentralDB/`, `CentralDB_Reports/`, `Original/`) is left in place until the user approves the deletion proposal.
- LOCKS gates, in order, no skipping and no backflow: 1 Plan, 2 Develop, 3 Test, 4 Quality, 5 Version, 6 Deploy.
