# SQL Agent Job Deployment

All collection scripts are designed to run as SQL Agent CmdExec job steps
using the dual-block pattern. This means each server runs the script locally
(`-RunLocally`) and reports back to CentralDB.

---

## Job step settings

| Setting | Value |
|---------|-------|
| Step type | CmdExec |
| Run As | Proxy account with local admin + sysadmin |
| On success | Go to next step |
| On failure | Quit with failure (so SQL Agent reports FAILED) |

---

## Command template

```
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass
    -File "\\FILESERVER\CentralDB\Collect\<ScriptName>.ps1"
    -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))"
    -RunLocally
    -OutputPath "D:\Logs\CentralDB"
```

The `$(ESCAPE_DQUOTE(SRVR))` token resolves to the local server name at
runtime - this is what makes a single MSX job work correctly across all TSX
servers.

---

## Job definitions

### Wait Statistics (daily)

```sql
USE msdb;
EXEC sp_add_job @job_name = N'CentralDB - Wait Stats';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - Wait Stats',
    @step_name  = N'Collect wait stats',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Get-CentralWaitStats.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Daily 06:00',
    @freq_type            = 4,
    @freq_interval        = 1,
    @active_start_time    = 060000;
EXEC sp_attach_schedule @job_name = N'CentralDB - Wait Stats', @schedule_name = N'Daily 06:00';
EXEC sp_add_jobserver @job_name = N'CentralDB - Wait Stats';
```

### Inventory (weekly)

```sql
EXEC sp_add_job @job_name = N'CentralDB - Inventory';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - Inventory',
    @step_name  = N'Collect full inventory',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Get-CentralInventory.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Weekly Sunday 02:00',
    @freq_type            = 8,
    @freq_interval        = 1,
    @freq_recurrence_factor = 1,
    @active_start_time    = 020000;
EXEC sp_attach_schedule @job_name = N'CentralDB - Inventory', @schedule_name = N'Weekly Sunday 02:00';
EXEC sp_add_jobserver @job_name = N'CentralDB - Inventory';
```

### Baseline Stats (every 15 minutes)

```sql
EXEC sp_add_job @job_name = N'CentralDB - Baseline Stats';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - Baseline Stats',
    @step_name  = N'Collect baseline performance counters',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Get-CentralBaselineStats.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Every 15 Minutes',
    @freq_type            = 4,
    @freq_interval        = 1,
    @freq_subday_type     = 4,
    @freq_subday_interval = 15;
EXEC sp_attach_schedule @job_name = N'CentralDB - Baseline Stats', @schedule_name = N'Every 15 Minutes';
EXEC sp_add_jobserver @job_name = N'CentralDB - Baseline Stats';
```

### sp_Blitz (weekly)

```sql
EXEC sp_add_job @job_name = N'CentralDB - sp_Blitz';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - sp_Blitz',
    @step_name  = N'Run sp_Blitz and centralize findings',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Invoke-CentralBlitzCollection.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Weekly Sunday 04:00',
    @freq_type            = 8,
    @freq_interval        = 1,
    @freq_recurrence_factor = 1,
    @active_start_time    = 040000;
EXEC sp_attach_schedule @job_name = N'CentralDB - sp_Blitz', @schedule_name = N'Weekly Sunday 04:00';
EXEC sp_add_jobserver @job_name = N'CentralDB - sp_Blitz';
```

### Full backup (daily)

```sql
EXEC sp_add_job @job_name = N'CentralDB - Full Backup';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - Full Backup',
    @step_name  = N'DatabaseBackup FULL',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Invoke-CentralBackup.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -BackupType FULL -Directory "E:\Backups" -CleanupTime 72 -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Daily 22:00',
    @freq_type            = 4,
    @freq_interval        = 1,
    @active_start_time    = 220000;
EXEC sp_attach_schedule @job_name = N'CentralDB - Full Backup', @schedule_name = N'Daily 22:00';
EXEC sp_add_jobserver @job_name = N'CentralDB - Full Backup';
```

### Index optimize (weekly)

```sql
EXEC sp_add_job @job_name = N'CentralDB - Index Optimize';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - Index Optimize',
    @step_name  = N'IndexOptimize USER_DATABASES',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Invoke-CentralIndexOptimize.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Weekly Saturday 01:00',
    @freq_type            = 8,
    @freq_interval        = 64,
    @freq_recurrence_factor = 1,
    @active_start_time    = 010000;
EXEC sp_attach_schedule @job_name = N'CentralDB - Index Optimize', @schedule_name = N'Weekly Saturday 01:00';
EXEC sp_add_jobserver @job_name = N'CentralDB - Index Optimize';
```

### Integrity check (weekly)

```sql
EXEC sp_add_job @job_name = N'CentralDB - Integrity Check';
EXEC sp_add_jobstep
    @job_name   = N'CentralDB - Integrity Check',
    @step_name  = N'DatabaseIntegrityCheck ALL_DATABASES',
    @subsystem  = N'CmdExec',
    @command    = N'powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "\\FILESERVER\CentralDB\Collect\Invoke-CentralIntegrityCheck.ps1" -CMSInstanceName "$(ESCAPE_DQUOTE(SRVR))" -RunLocally -OutputPath "D:\Logs\CentralDB"',
    @on_success_action = 1,
    @on_fail_action    = 2;
EXEC sp_add_schedule
    @schedule_name        = N'Weekly Sunday 01:00',
    @freq_type            = 8,
    @freq_interval        = 1,
    @freq_recurrence_factor = 1,
    @active_start_time    = 010000;
EXEC sp_attach_schedule @job_name = N'CentralDB - Integrity Check', @schedule_name = N'Weekly Sunday 01:00';
EXEC sp_add_jobserver @job_name = N'CentralDB - Integrity Check';
```

---

## Deploy all jobs with dbatools

```powershell
$env:PSModulePath += ';C:\Program Files\WindowsPowerShell\Modules'
Import-Module dbatools
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false

$share    = '\\FILESERVER\CentralDB'
$logPath  = 'D:\Logs\CentralDB'
$cms      = '$(ESCAPE_DQUOTE(SRVR))'

$jobs = @(
    @{ Name='CentralDB - Wait Stats';      Script='Get-CentralWaitStats.ps1';          ExtraArgs='' }
    @{ Name='CentralDB - Inventory';       Script='Get-CentralInventory.ps1';           ExtraArgs='' }
    @{ Name='CentralDB - Baseline Stats';  Script='Get-CentralBaselineStats.ps1';       ExtraArgs='' }
    @{ Name='CentralDB - sp_Blitz';        Script='Invoke-CentralBlitzCollection.ps1';  ExtraArgs='' }
    @{ Name='CentralDB - Full Backup';     Script='Invoke-CentralBackup.ps1';           ExtraArgs='-BackupType FULL -Directory "E:\Backups" -CleanupTime 72' }
    @{ Name='CentralDB - Index Optimize';  Script='Invoke-CentralIndexOptimize.ps1';    ExtraArgs='' }
    @{ Name='CentralDB - Integrity Check'; Script='Invoke-CentralIntegrityCheck.ps1';   ExtraArgs='' }
)

foreach ($j in $jobs) {
    $cmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass " +
           "-File `"$share\Collect\$($j.Script)`" " +
           "-CMSInstanceName `"$cms`" -RunLocally -OutputPath `"$logPath`" $($j.ExtraArgs)"

    $existingJob = Get-DbaAgentJob -SqlInstance localhost -Job $j.Name -ErrorAction SilentlyContinue
    if ($existingJob) { Remove-DbaAgentJob -SqlInstance localhost -Job $j.Name -Confirm:$false }

    New-DbaAgentJob -SqlInstance localhost -Job $j.Name -Description "CentralDB collection job" | Out-Null
    New-DbaAgentJobStep -SqlInstance localhost -Job $j.Name -StepName 'Execute' -Subsystem CmdExec -Command $cmd | Out-Null
    Set-DbaAgentJob -SqlInstance localhost -Job $j.Name -Enabled
    Write-Host "Created: $($j.Name)"
}
```

---

## Sync jobs to Linux fleet

Use the `Sync Jobs to Linux Fleet` job (already deployed) to push these
jobs from SeniukA to all three Linux servers automatically.

Or push manually:

```powershell
$saCred = Import-CliXml 'C:\Secrets\sql-sa.clixml'
$linuxTargets = @('10.0.1.129', '10.0.1.171', '10.0.1.196')
$jobsToSync = Get-DbaAgentJob -SqlInstance localhost | Where-Object { $_.Name -like 'CentralDB -*' }

Copy-DbaAgentJob -Source localhost -Destination $linuxTargets `
    -DestinationSqlCredential $saCred `
    -Job $jobsToSync.Name -Force
```
