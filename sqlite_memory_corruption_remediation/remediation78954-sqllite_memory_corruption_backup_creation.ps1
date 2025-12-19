<#
.SYNOPSIS
Rolls back SQLite remediation by restoring backed-up SQLite binaries.

.DESCRIPTION
- Finds SQLite backup files created during remediation
- Restores the most recent backup to original locations
- Logs all rollback actions
- Designed for Windows 11 enterprise rollback scenarios

Must be run as Administrator.
#>

# ===============================
# Configuration Section
# ===============================

# Directory where remediation script stored backups
$BackupDir = "C:\SQLite_Backups"

# Log file for rollback operations
$LogFile = "C:\Temp\sqlite_rollback.log"

# ===============================
# Helper Functions
# ===============================

# Function to write messages to both console and log file
function Write-Log {
    param ([string]$Message)

    # Generate timestamp for log entry
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Write message to console and append to log file
    "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

# ===============================
# Script Start
# ===============================

# Log the start of rollback operation
Write-Log "Starting SQLite rollback process"

# Verify backup directory exists
if (-not (Test-Path $BackupDir)) {
    Write-Log "ERROR: Backup directory not found at $BackupDir"
    Write-Log "Rollback aborted"
    exit 1
}

# ===============================
# Identify Backup Files
# ===============================

# Retrieve all backed-up SQLite binaries
$BackupFiles = Get-ChildItem `
    -Path $BackupDir `
    -Filter "sqlite3_*.exe" `
    -ErrorAction SilentlyContinue

# Exit if no backups are found
if (-not $BackupFiles) {
    Write-Log "No SQLite backup files found — nothing to roll back"
    exit 0
}

# ===============================
# Locate Active SQLite Installations
# ===============================

# Common directories where SQLite may be installed
$SearchPaths = @(
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\Windows",
    "C:\"
)

# Locate existing sqlite3.exe files on the system
$ActiveSQLiteFiles = Get-ChildItem `
    -Path $SearchPaths `
    -Recurse `
    -Include "sqlite3.exe" `
    -ErrorAction SilentlyContinue

# ===============================
# Rollback Logic
# ===============================

foreach ($ActiveFile in $ActiveSQLiteFiles) {

    # Log discovered SQLite binary
    Write-Log "Evaluating SQLite binary at $($ActiveFile.FullName)"

    # Select the most recent backup file
    $LatestBackup = $BackupFiles |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    # If no backup exists, skip rollback for this file
    if (-not $LatestBackup) {
        Write-Log "No backup available — skipping"
        continue
    }

    # Log which backup will be restored
    Write-Log "Restoring backup $($LatestBackup.FullName)"

    # Restore the backup over the current SQLite binary
    Copy-Item `
        -Path $LatestBackup.FullName `
        -Destination $ActiveFile.FullName `
        -Force

    # Log successful restore
    Write-Log "Rollback successful for $($ActiveFile.FullName)"
}

# ===============================
# Script Completion
# ===============================

# Log completion message
Write-Log "SQLite rollback process completed"
