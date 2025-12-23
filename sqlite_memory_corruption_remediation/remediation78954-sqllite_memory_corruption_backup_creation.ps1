<#
.SYNOPSIS
Creates backups and a rollback manifest prior to SQLite remediation.

.DESCRIPTION
- Searches for vulnerable sqlite3.exe files
- Creates backups if found
- Generates a rollback manifest
- Warns if no backup can be created
- Hardened to handle missing directories and access errors safely

Must be run as Administrator.
#>

# ===============================
# CONFIGURATION
# ===============================

# Minimum secure SQLite version
$MinimumSafeVersion = [Version]"3.50.2"

# Backup directory
$BackupRoot = "C:\SQLite_Backups"

# Rollback manifest path
$ManifestPath = "$BackupRoot\rollback_manifest.json"

# Log file path
$LogFile = "C:\Temp\sqlite_pre_backup.log"

# ===============================
# ENSURE REQUIRED DIRECTORIES EXIST
# ===============================

# Extract directory path from log file
$LogDir = Split-Path $LogFile -Parent

# Create log directory if it does not exist
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Create backup directory if it does not exist
if (-not (Test-Path $BackupRoot)) {
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
}

# ===============================
# LOGGING FUNCTION (FAIL-SAFE)
# ===============================

function Write-Log {
    param ([string]$Message)

    # Generate timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    try {
        # Write to console and append to log file
        "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
    }
    catch {
        # If logging fails, write only to console
        Write-Host "$Timestamp - $Message"
    }
}

# ===============================
# INITIALIZATION
# ===============================

Write-Log "Starting SQLite pre-remediation backup process"

# Initialize rollback manifest
$RollbackManifest = @()

# ===============================
# FUNCTION TO GET SQLITE VERSION
# ===============================

function Get-SQLiteVersion {
    param ([string]$FilePath)

    try {
        # Execute sqlite3.exe to retrieve version
        $Output = & $FilePath --version 2>$null

        # Parse version number
        if ($Output -match "^(\d+\.\d+\.\d+)") {
            return [Version]$Matches[1]
        }
    }
    catch {
        # Ignore execution failures
    }

    return $null
}

# ===============================
# SEARCH FOR SQLITE3.EXE
# ===============================

$SearchPaths = @(
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\"
)

Write-Log "Searching for sqlite3.exe binaries"

$SQLiteExecutables = Get-ChildItem `
    -Path $SearchPaths `
    -Recurse `
    -Filter "sqlite3.exe" `
    -ErrorAction SilentlyContinue

$BackupCreated = $false

# ===============================
# BACKUP PROCESS
# ===============================

foreach ($Exe in $SQLiteExecutables) {

    $InstalledVersion = Get-SQLiteVersion $Exe.FullName

    # Skip files that cannot be evaluated
    if (-not $InstalledVersion) { continue }

    # Skip secure versions
    if ($InstalledVersion -ge $MinimumSafeVersion) { continue }

    Write-Log "Found vulnerable sqlite3.exe at $($Exe.FullName)"

    # Generate short, safe backup filename using hash
    $PathHash = (Get-FileHash -Algorithm SHA256 -InputStream (
        [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($Exe.FullName))
    )).Hash.Substring(0,16)

    $BackupPath = "$BackupRoot\sqlite3_$PathHash.bak"

    try {
        # Create backup
        Copy-Item -Path $Exe.FullName -Destination $BackupPath -Force

        if (Test-Path $BackupPath) {

            Write-Log "Backup successfully created at $BackupPath"

            # Record rollback metadata
            $RollbackManifest += [PSCustomObject]@{
                OriginalPath    = $Exe.FullName
                BackupPath      = $BackupPath
                OriginalVersion = $InstalledVersion.ToString()
                Timestamp       = (Get-Date).ToString("o")
            }

            $BackupCreated = $true
        }
    }
    catch {
        Write-Log "ERROR: Failed to back up $($Exe.FullName)"
    }
}

# ===============================
# FINALIZE MANIFEST AND WARNINGS
# ===============================

if ($BackupCreated) {

    # Save rollback manifest
    $RollbackManifest |
        ConvertTo-Json -Depth 5 |
        Set-Content $ManifestPath

    Write-Log "Rollback manifest created successfully"
    Write-Log "Safe to proceed with remediation script"
}
else {

    Write-Log "No backups were created"
    Write-Log "Likely causes:"
    Write-Log "- No vulnerable sqlite3.exe present"
    Write-Log "- SQLite is embedded (Python, application)"
    Write-Log "WARNING: Remediation script will NOT be rollback-safe"
    Write-Log "Proceed with remediation only if acceptable"
}
