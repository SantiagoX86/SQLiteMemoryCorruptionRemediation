<#
.SYNOPSIS
    Script intended to perform a rollback of SQLite Memory Corruption remediation in case
    dependent assets are negatively affected.

.NOTES
    Author        : Sean Santiago
    Date Created  : 2025-12-18
    Last Modified : 2025-12-21
    Github        : https://github.com/SantiagoX86
    Version       : 2.0
    CVEs          : 2025-6965, 2025-29087, 2025-29088
    Plugin IDs    : 242325, 240237
    STIG-ID       : N/A

.TESTED ON
    Date(s) Tested   : 
    Tested By        : 
    Systems Tested   : 
    PowerShell Ver.  : 

.USAGE
    Untested as of yet as backup files were not created by backup script due to
    non-esisting SQLite3.exe script on host machine. 

    Must be run with Administrator privileges.

    Example syntax:
        PS C:\> .\02_Remediate-SQLite-MemoryCorruption.ps1
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
