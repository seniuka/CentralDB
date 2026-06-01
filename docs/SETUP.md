# CentralDB Setup Guide

## Prerequisites

### 1. Install dbatools

```powershell
# Run as Administrator
Install-Module dbatools -Scope AllUsers -Force
```

Verify:
```powershell
Get-Module dbatools -ListAvailable | Select-Object Name, Version
```

### 2. Create the output log directory

```powershell
New-Item -ItemType Directory -Path 'C:\Logs\CentralDB' -Force
```

### 3. Install ImportExcel (optional - for Excel output)

```powershell
Install-Module ImportExcel -Scope AllUsers -Force
```

---

## Deploy CentralDB database

Edit the file paths in `CreateScript-NewCentralDB-Database.sql` replacing
`{PATH_TO_DATAFILE}` with your data directory, then execute:

```powershell
$sqlcmd = 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\SQLCMD.EXE'
& $sqlcmd -S localhost -E -i CreateScript-NewCentralDB-Database.sql
```

---

## Deploy stored procedures

Run all stored procedures in `SQL/StoredProcedures/` against CentralDB:

```powershell
$sqlcmd = 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\180\Tools\Binn\SQLCMD.EXE'
$server = 'localhost'
$db     = 'CentralDB'

Get-ChildItem 'SQL\StoredProcedures\*.sql' | Sort-Object Name | ForEach-Object {
    Write-Host "Deploying $($_.Name)..."
    & $sqlcmd -S $server -d $db -E -i $_.FullName
}
```

### Stored procedures deployed

| File | Object | Purpose |
|------|--------|---------|
| `Svr.usp_GetCollectionTargets.sql` | `[Svr].[usp_GetCollectionTargets]` | Server list query |
| `Svr.usp_SetCollectionLastRun.sql` | `[Svr].[usp_SetCollectionLastRun]` | Last-run tracking |
| `Inst.usp_GetBaselineStats.sql` | `[Inst].[usp_GetBaselineStats]` | DMV perf counter snapshot |

---

## Register target servers

Populate `[Svr].[ServerList]` with the instances you want to collect from:

```sql
USE CentralDB;
GO

-- Windows instance (Windows auth)
INSERT INTO [Svr].[ServerList]
    (ServerName, InstanceName, Active, Baseline)
VALUES
    ('SQL-PROD-01', 'MSSQLSERVER', 1, 1);

-- Named Windows instance
INSERT INTO [Svr].[ServerList]
    (ServerName, InstanceName, Active, Baseline)
VALUES
    ('SQL-PROD-01', 'REPORTING', 1, 1);

-- Linux instances (SQL auth required - store credential separately)
INSERT INTO [Svr].[ServerList]
    (ServerName, InstanceName, Active, Baseline)
VALUES
    ('10.0.1.129', 'MSSQLSERVER', 1, 1),
    ('10.0.1.171', 'MSSQLSERVER', 1, 1),
    ('10.0.1.196', 'MSSQLSERVER', 1, 1);
```

### Column reference

| Column | Type | Description |
|--------|------|-------------|
| `ServerName` | `nvarchar(255)` | Hostname or IP address |
| `InstanceName` | `nvarchar(255)` | Instance name (`MSSQLSERVER` for default) |
| `Active` | `bit` | 1 = include in all collections |
| `Baseline` | `bit` | 1 = include in baseline/wait stats |

---

## Configure SQL Server credentials for Linux targets

Linux targets require SQL authentication. The recommended approach is to
store the credential as a SQL Agent proxy or use Windows Credential Manager:

```powershell
# Store credential in Windows Credential Manager
$cred = Get-Credential -UserName 'sa' -Message 'SQL Server sa password'
$cred | Export-CliXml -Path 'C:\Secrets\sql-sa.clixml'

# Use in scripts
$cred = Import-CliXml -Path 'C:\Secrets\sql-sa.clixml'
.\Collect\Get-CentralWaitStats.ps1 -SqlCredential $cred -CMSInstanceName 'localhost' -OutputPath 'C:\Logs\CentralDB'
```

> **Security note**: `Export-CliXml` encrypts with DPAPI. The `.clixml` file
> can only be decrypted by the same Windows user account on the same machine.
> Never commit credential files to source control.

---

## Deploy Ola Hallengren maintenance solution

```powershell
# Install on all registered instances at once
$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'

$allInstances = @('localhost', '10.0.1.129', '10.0.1.171', '10.0.1.196')

foreach ($inst in $allInstances) {
    $params = @{ SqlInstance = $inst; Database = 'master' }
    if ($inst -ne 'localhost') { $params['SqlCredential'] = $saCred }
    Install-DbaMaintenanceSolution @params
}
```

---

## Deploy Brent Ozar First Responder Kit

```powershell
$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'

$allInstances = @('localhost', '10.0.1.129', '10.0.1.171', '10.0.1.196')

foreach ($inst in $allInstances) {
    $params = @{ SqlInstance = $inst; Database = 'master' }
    if ($inst -ne 'localhost') { $params['SqlCredential'] = $saCred }
    Install-DbaFirstResponderKit @params
}
```

---

## Verify the setup

```powershell
$env:PSModulePath += ';C:\Program Files\WindowsPowerShell\Modules'
Import-Module dbatools
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false

$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'

# Check all instances are reachable
$instances = @{
    'localhost'   = $null
    '10.0.1.129'  = $saCred
    '10.0.1.171'  = $saCred
    '10.0.1.196'  = $saCred
}

foreach ($inst in $instances.GetEnumerator()) {
    $p = @{ SqlInstance = $inst.Key }
    if ($inst.Value) { $p['SqlCredential'] = $inst.Value }
    $result = Test-DbaConnection @p
    Write-Host "$($inst.Key): $($result.ConnectSuccess)"
}
```

---

## Next steps

- [SQL Agent job deployment](SQL-AGENT-JOBS.md)
- [Testing the collection scripts](TESTING.md)
- [Script reference](SCRIPT-REFERENCE.md)
