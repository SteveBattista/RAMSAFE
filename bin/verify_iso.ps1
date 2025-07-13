#
# RAMSAFE ISO Verification Script (PowerShell)
# 
# This script verifies the SHA256 hash of the RAMSAFE ISO file to ensure
# it hasn't been tampered with or corrupted during download.
#
# AUTHOR: RAMSAFE Project Team
# PURPOSE: Verify integrity of RAMSAFE ISO file
# REQUIREMENTS: PowerShell 5.1 or later, RAMSAFE ISO file
# USAGE: .\verify_iso.ps1 "path\to\ramsafe.iso"
#
# Example: .\verify_iso.ps1 "C:\Downloads\ramsafe.iso"
#

param(
    [Parameter(Mandatory=$true)]
    [string]$IsoPath
)

# Expected SHA256 hash for authentic RAMSAFE ISO
$expected = "121167d6b7c5375cd898c717edd8cb289385367ef8aeda13bf4ed095b7065b0d"

# Check if the file exists
if (-not (Test-Path $IsoPath)) {
    Write-Host "[ERROR] File not found: $IsoPath" -ForegroundColor Red
    Write-Host "Please check the file path and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Verifying RAMSAFE ISO integrity..." -ForegroundColor Cyan
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
