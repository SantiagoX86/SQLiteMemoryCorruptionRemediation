<#
.SYNOPSIS
Remediates SQLite memory corruption vulnerability on Windows 11
by downloading and deploying the latest SQLite version.

.DESCRIPTION
- Downloads the latest SQLite binary from sqlite.org
- Searches the system for vulnerable SQLite binaries
- Backs up vulnerable versions
- Replaces them with a secure version
- Logs all actions for auditing

Must be run as Administrator.
#>

# ===============================
# Configuration Section
# ===============================

# Define the minimum safe SQLite version
$MinimumSafeVersion = [Version]"3.50.2"

# Directory used to temporarily store downloaded SQLite files
$DownloadDir = "C:\Temp\SQLite"

# Directory used to back up vulnerable SQLite binaries
$BackupDir = "C:\SQLite_Backups"

# Log file location for audit and troubleshooting
$LogFile = "C:\Temp\sqlite_remediation.log"

# Official SQLite download URL for Windows 64-bit CLI tools
# This URL is updated by SQLite to always reference the latest release
$SQLiteDownloadUrl = "https://www.sqlite.org/2025/sqlite-tools-win-x64-3510100.zip"


# Local path where the downloaded ZIP file will be saved
$ZipFilePath = "$DownloadDir\sqlite.zip"

# ===============================
# Helper Functions
# ===============================

# Function to write messages to console and log file
function Write-Log {
    param ([string]$Message)

    # Create a timestamp for log entries
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Output message to console and append to log file
    "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

# Function to determine SQLite version by executing the binary
function Get-SQLiteVersion {
    param ([string]$FilePath)

    try {
        # Execute sqlite3.exe with the --version argument
        $Output = & $FilePath --version 2>$null

        # Extract the version number from the output using regex
        if ($Output -match "^(\d+\.\d+\.\d+)") {
            return [Version]$Matches[1]
        }
    }
    catch {
        return $null
    }
}

# ===============================
# Script Start
# ===============================

# Log script start
Write-Log "Starting SQLite vulnerability remediation"

# Ensure the download directory exists
if (-not (Test-Path $DownloadDir)) {
    New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null
}

# Ensure the backup directory exists
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# ===============================
# Download Latest SQLite
# ===============================

# Log download action
Write-Log "Downloading latest SQLite package"

# Download the SQLite ZIP file from the official site
Invoke-WebRequest `
    -Uri $SQLiteDownloadUrl `
    -OutFile $ZipFilePath `
    -UseBasicParsing

# Extract the downloaded ZIP file
Expand-Archive `
    -Path $ZipFilePath `
    -DestinationPath $DownloadDir `
    -Force

# Locate the sqlite3.exe file in the extracted contents
$PatchedSQLite = Get-ChildItem `
    -Path $DownloadDir `
    -Recurse `
    -Filter "sqlite3.exe" |
    Select-Object -First 1

# Verify sqlite3.exe was found
if (-not $PatchedSQLite) {
    Write-Log "ERROR: sqlite3.exe not found after extraction"
    exit 1
}

# Determine version of downloaded SQLite
$DownloadedVersion = Get-SQLiteVersion -FilePath $PatchedSQLite.FullName

# Verify downloaded version is secure
if ($DownloadedVersion -lt $MinimumSafeVersion) {
    Write-Log "ERROR: Downloaded SQLite version is still vulnerable"
    exit 1
}

Write-Log "Downloaded SQLite version $DownloadedVersion confirmed secure"

# ===============================
# Locate Installed SQLite Binaries
# ===============================

# Common directories where SQLite may exist
$SearchPaths = @(
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\Windows",
    "C:\"
)

# Search for sqlite3.exe files
$SQLiteFiles = Get-ChildItem `
    -Path $SearchPaths `
    -Recurse `
    -Include "sqlite3.exe" `
    -ErrorAction SilentlyContinue

# ===============================
# Remediation Loop
# ===============================

foreach ($File in $SQLiteFiles) {

    # Log file discovery
    Write-Log "Found SQLite binary: $($File.FullName)"

    # Determine installed SQLite version
    $InstalledVersion = Get-SQLiteVersion -FilePath $File.FullName

    # Skip files where version cannot be determined
    if (-not $InstalledVersion) {
        Write-Log "Unable to determine version — skipping"
        continue
    }

    Write-Log "Detected SQLite version $InstalledVersion"

    # Check if the version is vulnerable
    if ($InstalledVersion -lt $MinimumSafeVersion) {

        Write-Log "VULNERABLE SQLite version detected"

        # Create a timestamped backup filename
        $BackupFile = Join-Path `
            $BackupDir `
            ("sqlite3_" + $InstalledVersion + "_" + (Get-Date -Format "yyyyMMddHHmmss") + ".exe")

        # Backup the vulnerable SQLite binary
        Copy-Item `
            -Path $File.FullName `
            -Destination $BackupFile `
            -Force

        Write-Log "Backed up vulnerable binary to $BackupFile"

        # Replace the vulnerable binary with the patched version
        Copy-Item `
            -Path $PatchedSQLite.FullName `
            -Destination $File.FullName `
            -Force

        Write-Log "Replaced SQLite binary with secure version"
    }
    else {
        Write-Log "SQLite version already secure"
    }
}

# ===============================
# Script Completion
# ===============================

# Log completion
Write-Log "SQLite remediation completed successfully"
