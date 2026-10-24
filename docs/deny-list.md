# CentralDB rebuild: deny-list

> **Name:** deny-list.md · **Purpose:** single source of truth for the Lock 4 deny-list that `cdb-deny-list-scanner` enforces · **Version:** 0.1.0 · **Standard:** DBA Automation Engineering Standard v5.0.0 (UNVERIFIED, text not in repo) · **Author:** Your Friendly Neighbourhood DBA · **Date:** 2026-10-24

Any hit on any row fails Lock 4. The work drops back to Develop. A hit is waived only by a documented exception (section 3), which is a G2 decision.

This file and `.claude/agents/cdb-deny-list-scanner.md` define the patterns, so they are exempt from scanning.

## 1. Rows

Patterns are .NET regular expressions, case-insensitive, matched per line unless a row says otherwise. Inside this table a literal `\|` stands for the regex alternation `|` (the backslash only protects the markdown table), so unescape it before use. Patterns in one cell are separated by a space, a comma and a space. They find candidates. The scanner then reads the surrounding lines to confirm the hit, because some rows depend on context (for example whether code sits inside an `-Apply` block).

| ID | Row | Candidate patterns | Confirm by reading |
|---|---|---|---|
| R1 | `Invoke-Expression` / `iex` on dynamic strings | `\bInvoke-Expression\b` , `\biex\b` | Any use is a hit. There is no safe dynamic-string use in this repo |
| R2 | Plaintext passwords, `ConvertTo-SecureString -AsPlainText`, other secrets | `ConvertTo-SecureString[^\r\n]*-AsPlainText` , `(password\|pwd)\s*[=:]\s*['"][^'"<$\{][^'"]*['"]` , `Password\s*=\s*[^;<$\{\s'"][^;]*` , `-Password\s+['"]?[^<$\s]` , `(api[_-]?key\|secret\|token\|connection ?string)\s*[=:]\s*['"][A-Za-z0-9+/=_-]{12,}` | Placeholders such as `<secret-name>` are fine. Secrets are referenced by name only. Scan prose as well as code for this row |
| R3 | `sa` login or SQL logins for automation | `\b(User ID\|uid\|-Username\|-User)\s*[=\s]\s*['"]?sa\b` , `\bCREATE LOGIN\b[^\r\n]*\bWITH PASSWORD\b` , `-SqlCredential\b` , `\bGet-Credential\b` , `\bPSCredential\b` , `Authentication\s*=\s*SQL` | Hit unless the file carries a documented exception for a platform that cannot use Windows or gMSA authentication (for example a PostgreSQL or Oracle adapter) |
| R4 | `xp_cmdshell` enablement | `\bxp_cmdshell\b` , `sp_configure[^\r\n]*xp_cmdshell` | Any occurrence in code is a hit |
| R5 | `DROP`, `TRUNCATE`, `DELETE` without a `WHERE`, outside an `-Apply` block | `^\s*DROP\s+(TABLE\|VIEW\|PROC(EDURE)?\|FUNCTION\|SCHEMA\|INDEX\|DATABASE\|TRIGGER\|SYNONYM\|TYPE\|SEQUENCE\|SECURITY\s+POLICY\|LOGIN\|USER)\b` , `\bTRUNCATE\s+TABLE\b` , `\bDELETE\s+(FROM\s+)?[\w\[\]\.#@]+` | A `DELETE` is a hit only if no `WHERE` appears before the next `;` or `GO` line. `DROP` and `TRUNCATE` are always hits outside an Apply block. See "Apply block" in section 2 |
| R6 | `-Force` on destructive cmdlets without `-Apply` | `\b(Remove\|Clear\|Stop\|Reset\|Uninstall\|Disable\|Restore\|Drop)-[A-Za-z]+\b[^\r\n\|]*-Force\b` | See "Apply block" in section 2 |
| R7 | `SELECT *` in views and collectors | `\bSELECT\s+(DISTINCT\s+)?(TOP\s*\(?\d+\)?\s+(PERCENT\s+)?)?([\w\[\]]+\.)?\*` , `\b[\w\]]+\.\*` inside a select list | `COUNT(*)` is allowed. Every other star in a select list is a hit, including inside PowerShell here-strings |
| R8 | Trust-all or disabled certificate validation | `-TrustServerCertificate\b` , `TrustServerCertificate\s*=\s*(true\|yes)` , `-TrustCert\b` , `trustcert[^\r\n]*\$true` , `ServerCertificateValidationCallback[^\r\n]*\{\s*\$?true` , `Encrypt\s*=\s*(false\|no\|optional)` , `-EncryptConnection:\s*\$false` | Hit unless a documented exception names the instance role and the reason |
| R9 | Hard-coded server or listener names | `(-SqlInstance\|-ComputerName\|-ServerInstance\|-CmsInstance\|-Source\|-Destination)\s+['"]?(?!\$\|<\|\()[A-Za-z0-9][A-Za-z0-9._\\-]*` , `(?<![\w.$@])(Server\|Data Source\|Host)\s*=\s*(?!\$\|<\|\{)[A-Za-z0-9][A-Za-z0-9._\\-]*` , `\$(server\|instance\|sqlInstance\|computer)\w*\s*=\s*['"][A-Za-z0-9]` | Placeholders in angle brackets and variables fed from the inventory are fine. `localhost` and `.` are hits in shipped code. Test fixtures use synthetic names built at run time |
| R10 | `Write-Host` for data output | `\bWrite-Host\b` | Any use is a hit. Use `Write-Output` for data, `Write-Verbose` or `Write-Information` for messages |
| R11 | Unbounded `-Parallel` | `ForEach-Object\b[^\r\n{]*-Parallel` | A hit unless `-ThrottleLimit` appears on the same statement (before or after the script block) and is not `0`. `-Parallel` is allowed only through the dual-path with a PowerShell 5.1 fallback, as in the `cdb-collector-pattern` skill |

## 2. Scope and definitions

**Scanned text.** All lines of `.ps1`, `.psm1`, `.psd1`, `.sql`, `.json` and `.yml` files, and all lines inside fenced code blocks of `.md` files. Prose is not scanned, except for R2, which scans every line.

**Exempt files.** This file and `.claude/agents/cdb-deny-list-scanner.md`. Nothing else is exempt.

**Legacy code.** Files outside the rebuild (`Collect/`, `SQL/`, `CentralDB/`, `CentralDB_Reports/`, `Original/`, `OlaHallengren/`, `Tests/Test-*.ps1`) are not scanned for gating. `/cdb-discover` reports their hits as BASELINE in `docs/rebuild/discovery/legacy-baseline.md`.

**Apply block.** For PowerShell, code that executes only when `$Apply` is true, or inside `if ($PSCmdlet.ShouldProcess(...))` whose parent function has `-Apply` defaulting to off. For T-SQL, a file named `*.rollback.sql` or `*.apply.sql`. Those files are executed only by a wrapper that refuses to run them without `-Apply`. Statements in any other `.sql` file are outside an Apply block. `CREATE OR ALTER` is preferred over `DROP ... ; CREATE`.

## 3. Documented exceptions

An exception is a comment within three lines above the code:

`DENYLIST-EXCEPTION: ADR-NNNN R<id> <reason in one line>`

It counts only if `docs/decisions/ADR-NNNN-*.md` exists with `Status: Accepted` and names the row and the instance role. The scanner reports excepted lines separately and does not count them as hits. Granting an exception is gate G2.

## 4. Report format

The scanner returns one table with all eleven rows, including rows with no hits:

| ID | Hits | Files and lines | Excepted |
|---|---|---|---|

Verdict: PASS only if the Hits column is zero in every row.
