<#
.SYNOPSIS
    Remediates the SQLite memory corruption vulnerability (SQLite < 3.50.2)
    by detecting old version of SQLite if an exe file exists, downloading
    a secure SQLite version, and installing the secure version on the system.
    Ensures the system is compliant even when no prior sqlite3.exe exists.

.NOTES
    Author        : Sean Santiago
    Date Created  : 2025-12-18
    Last Modified : 2025-12-21
    Version       : 2.0
    CVEs          : 2025-6965
    Plugin IDs    : 242325
    STIG-ID       : N/A

.TESTED ON
    Date(s) Tested   : 2025-12-21
    Tested By        : Sean Santiago
    Systems Tested   : Windows 11 Pro 24H2 (Microsoft Azure VM)
    PowerShell Ver.  : 5.1.26100.7462

.USAGE
    Remediates the vulnerability regardless of whether a vulnerable sqlite3.exe
    is found. Installs SQLite if none exists. Embedded SQLite libraries
    (e.g., Python _sqlite3.pyd or application-bundled SQLite) are logged
    but require application-level remediation.

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
