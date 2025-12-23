<#
.SYNOPSIS
Rolls back SQLite remediation using backup manifest.

.DESCRIPTION
- Restores sqlite3.exe from backups
- Skips embedded SQLite entries

Must be run as Administrator.
#>

# ===============================
# CONFIGURATION
# ===============================

$BackupRoot = "C:\SQLite_Backups"
$ManifestPath = "$BackupRoot\rollback_manifest.json"
$LogFile = "C:\Temp\sqlite_rollback.log"

# ===============================
# LOGGING FUNCTION
# ===============================

function Write-Log {
    param ([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

# ===============================
# START ROLLBACK
# ===============================

Write-Log "Starting SQLite rollback"

if (-not (Test-Path $ManifestPath)) {
    Write-Log "No rollback manifest found — rollback not possible"
    exit 0
}

$Manifest = Get-Content $ManifestPath | ConvertFrom-Json

foreach ($Entry in $Manifest) {

    if (-not (Test-Path $Entry.BackupPath)) {
        Write-Log "Backup missing for $($Entry.OriginalPath)"
        continue
    }

    Write-Log "Restoring sqlite3.exe to $($Entry.OriginalPath)"

    Copy-Item -Path $Entry.BackupPath `
        -Destination $Entry.OriginalPath -Force

    Write-Log "Restore successful"
}

Write-Log "SQLite rollback completed"
