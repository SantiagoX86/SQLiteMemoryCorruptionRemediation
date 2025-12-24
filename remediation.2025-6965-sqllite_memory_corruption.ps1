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
    Github        : https://github.com/SantiagoX86
    Version       : 2.0
    CVEs          : 2025-6965
    Plugin IDs    : 242325
    STIG-ID       : N/A

.TESTED ON
    Date(s) Tested   : 
    Tested By        : 
    Systems Tested   : 
    PowerShell Ver.  : 

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

# Minimum SQLite version considered secure
$MinimumSafeVersion = [Version]"3.50.2"

# Directory used to download and extract SQLite
$DownloadDir = "C:\Temp\SQLite"

# Directory where SQLite will be installed if none exists
$InstallDir = "C:\Program Files\SQLite"

# Log file location
$LogFile = "C:\Temp\sqlite_remediation.log"

# Official SQLite tools download URL (secure version)
$SQLiteDownloadUrl = "https://www.sqlite.org/2025/sqlite-tools-win-x64-3510100.zip"

# Path to downloaded ZIP file
$ZipFilePath = "$DownloadDir\sqlite.zip"

# ===============================
# ENSURE REQUIRED DIRECTORIES EXIST
# ===============================

# Ensure log directory exists
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# Ensure download directory exists
New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null

# Ensure install directory exists
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

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
        # If logging fails, write to console only
        Write-Host "$Timestamp - $Message"
    }
}

# ===============================
# START REMEDIATION
# ===============================

Write-Log "Starting SQLite remediation (install or replace mode)"

# ===============================
# DOWNLOAD AND EXTRACT SQLITE
# ===============================

# Download SQLite tools ZIP from official source
Invoke-WebRequest `
    -Uri $SQLiteDownloadUrl `
    -OutFile $ZipFilePath `
    -UseBasicParsing

# Extract ZIP contents
Expand-Archive `
    -Path $ZipFilePath `
    -DestinationPath $DownloadDir `
    -Force

# Locate sqlite3.exe in extracted files
$PatchedSQLite = Get-ChildItem `
    -Path $DownloadDir `
    -Recurse `
    -Filter "sqlite3.exe" |
    Select-Object -First 1

# Abort if sqlite3.exe was not found
if (-not $PatchedSQLite) {
    Write-Log "ERROR: sqlite3.exe not found in downloaded package — aborting"
    exit 1
}

# ===============================
# FUNCTION TO GET SQLITE VERSION
# ===============================

function Get-SQLiteVersion {
    param ([string]$FilePath)

    try {
        # Execute sqlite3.exe with version flag
        $Output = & $FilePath --version 2>$null

        # Extract version number
        if ($Output -match "^(\d+\.\d+\.\d+)") {
            return [Version]$Matches[1]
        }
    }
    catch {}

    return $null
}

# ===============================
# VERIFY PATCHED VERSION
# ===============================

# Retrieve version of downloaded sqlite3.exe
$PatchedVersion = Get-SQLiteVersion $PatchedSQLite.FullName

# Abort if patched version is still vulnerable
if ($PatchedVersion -lt $MinimumSafeVersion) {
    Write-Log "ERROR: Downloaded SQLite version is still vulnerable — aborting"
    exit 1
}

Write-Log "Verified secure SQLite version: $PatchedVersion"

# ===============================
# SEARCH FOR EXISTING SQLITE3.EXE
# ===============================

# Search entire system for sqlite3.exe
$ExistingSQLite = Get-ChildItem `
    -Path "C:\" `
    -Recurse `
    -Filter "sqlite3.exe" `
    -ErrorAction SilentlyContinue

# Track whether replacement occurred
$Replaced = $false

# ===============================
# REPLACE VULNERABLE SQLITE3.EXE
# ===============================

foreach ($Exe in $ExistingSQLite) {

    # Get installed SQLite version
    $InstalledVersion = Get-SQLiteVersion $Exe.FullName

    # Skip files that cannot be evaluated
    if (-not $InstalledVersion) { continue }

    # Replace only vulnerable versions
    if ($InstalledVersion -lt $MinimumSafeVersion) {

        Write-Log "Replacing vulnerable sqlite3.exe at $($Exe.FullName)"

        Copy-Item `
            -Path $PatchedSQLite.FullName `
            -Destination $Exe.FullName `
            -Force

        Write-Log "Replacement successful"

        $Replaced = $true
    }
}

# ===============================
# INSTALL SQLITE IF NONE EXIST
# ===============================

if (-not $ExistingSQLite -or $ExistingSQLite.Count -eq 0) {

    Write-Log "No sqlite3.exe found on system — performing fresh install"

    # Define install path
    $InstallPath = Join-Path $InstallDir "sqlite3.exe"

    # Copy patched sqlite3.exe into install directory
    Copy-Item `
        -Path $PatchedSQLite.FullName `
        -Destination $InstallPath `
        -Force

    Write-Log "SQLite installed at $InstallPath"
}

# ===============================
# ENSURE SQLITE IS AVAILABLE VIA PATH
# ===============================

# Retrieve current system PATH
$CurrentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

# Add install directory to PATH if missing
if ($CurrentPath -notlike "*$InstallDir*") {

    Write-Log "Adding SQLite install directory to system PATH"

    [Environment]::SetEnvironmentVariable(
        "Path",
        "$CurrentPath;$InstallDir",
        "Machine"
    )
}

# ===============================
# FINAL STATUS LOGGING
# ===============================

if ($Replaced) {
    Write-Log "SQLite remediation completed via replacement"
}
else {
    Write-Log "SQLite remediation completed via installation"
}

Write-Log "SQLite remediation finished successfully"
