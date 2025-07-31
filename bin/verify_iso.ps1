#
# RAMSAFE ISO Verification Script (PowerShell)
# 
# This script verifies the SHA256 hash of the RAMSAFE ISO file to ensure
# it hasn't been tampered with or corrupted during download.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Verify integrity of RAMSAFE ISO file
# REQUIREMENTS: PowerShell 5.1 or later, RAMSAFE ISO file
# USAGE: .\verify_iso.ps1 [OPTIONS] -IsoPath "path\to\file.iso"
#
# Parameters:
#   -IsoPath         Path to the ISO file to verify (required)
#   -Hash            Custom expected SHA256 hash (optional)
#   -Help            Show help information
#
# Examples: 
#   .\verify_iso.ps1 -IsoPath "C:\Downloads\ramsafe.iso"
#   .\verify_iso.ps1 -IsoPath "C:\Downloads\custom.iso" -Hash "abc123def456..."
#   .\verify_iso.ps1 -Help
#

param(
    [Parameter(Mandatory=$false)]
    [string]$IsoPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Hash = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$Help
)

# Function to show usage information
function Show-Usage {
    Write-Host "Usage: .\verify_iso.ps1 [OPTIONS] -IsoPath `"path\to\file.iso`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -IsoPath         Path to the ISO file to verify (required)" -ForegroundColor Gray
    Write-Host "  -Hash            Custom expected SHA256 hash (optional)" -ForegroundColor Gray
    Write-Host "  -Help            Show this help information" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\verify_iso.ps1 -IsoPath `"C:\Downloads\ramsafe.iso`"" -ForegroundColor Gray
    Write-Host "  .\verify_iso.ps1 -IsoPath `"C:\Downloads\custom.iso`" -Hash `"abc123def456...`"" -ForegroundColor Gray
    Write-Host "  .\verify_iso.ps1 -Help" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script verifies the SHA256 hash of an ISO file." -ForegroundColor Gray
}

# Show help if requested
if ($Help) {
    Show-Usage
    exit 0
}

# Check if IsoPath is provided
if ([string]::IsNullOrEmpty($IsoPath)) {
    Write-Host "[ERROR] No ISO file path provided." -ForegroundColor Red
    Show-Usage
    exit 1
}

# Default expected SHA256 hash for authentic RAMSAFE ISO
$defaultExpected = "b975e776538b80152e0f1b1293e39b674821c1beb4fd9e2088c932ccbbb39105"

# Use custom hash if provided, otherwise use default
if ([string]::IsNullOrEmpty($Hash)) {
    $expected = $defaultExpected
    Write-Host "[INFO] Using default RAMSAFE hash for verification" -ForegroundColor Cyan
    Write-Host "[WARNING] Always double check the expected hash value from an official source." -ForegroundColor Yellow
    Write-Host "          Do not trust this script's built-in hash unless you have verified it yourself." -ForegroundColor Yellow
} else {
    $expected = $Hash.ToLower()
    Write-Host "[INFO] Using custom hash for verification" -ForegroundColor Cyan
}

# Validate hash format (should be 64 hexadecimal characters)
if ($expected -notmatch '^[a-fA-F0-9]{64}$') {
    Write-Host "[ERROR] Invalid hash format" -ForegroundColor Red
    Write-Host "Expected SHA256 hash should be 64 hexadecimal characters" -ForegroundColor Yellow
    Write-Host "Provided: $expected" -ForegroundColor Yellow
    exit 1
}

# Check if the file exists
if (-not (Test-Path $IsoPath)) {
    Write-Host "[ERROR] File not found: $IsoPath" -ForegroundColor Red
    Write-Host "Please check the file path and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Verifying ISO integrity..." -ForegroundColor Cyan
Write-Host "File: $IsoPath" -ForegroundColor Gray

# Calculate the SHA256 hash of the provided file
try {
    $calculated = (Get-FileHash -Path $IsoPath -Algorithm SHA256).Hash.ToLower()
    
    Write-Host "Expected:   $expected" -ForegroundColor Gray
    Write-Host "Calculated: $calculated" -ForegroundColor Gray
    
    # Compare the calculated hash with the expected hash
    if ($calculated -eq $expected) {
        Write-Host "[SUCCESS] VERIFICATION PASSED - ISO is authentic and safe to use" -ForegroundColor Green
        Write-Host "You can proceed with creating the RAMSAFE USB drive" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "[FAILED] VERIFICATION FAILED - DO NOT USE THIS ISO" -ForegroundColor Red
        Write-Host "[WARNING] The file may be corrupted or tampered with" -ForegroundColor Yellow
        Write-Host "[TIP] Please re-download the ISO from the official source" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to calculate hash - $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
