#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Detects and restarts non-working devices on Windows
.DESCRIPTION
    This script identifies devices with errors and attempts to fix them
    by disabling and then re-enabling the device.
.EXAMPLE
    .\Restart-FaultyDevices.ps1
#>

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows Device Troubleshooter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get all PnP devices that have problems
Write-Host "Scanning for devices with errors..." -ForegroundColor Yellow

$problematicDevices = Get-PnpDevice | Where-Object { $_.Status -ne "OK" -and $_.Class -ne $null -and $_.Status -ne "Unknown" }

if ($problematicDevices.Count -eq 0)
{
    Write-Host ""
    Write-Host "No problematic devices found. All devices are working correctly!" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Found $($problematicDevices.Count) device(s) with issues:" -ForegroundColor Red
Write-Host ""

# Display problematic devices
foreach ($device in $problematicDevices)
{
    Write-Host "  Device: $($device.FriendlyName)" -ForegroundColor White
    Write-Host "    Class: $($device.Class)" -ForegroundColor Gray
    Write-Host "    Status: $($device.Status)" -ForegroundColor Red
    Write-Host "    Instance ID: $($device.InstanceId)" -ForegroundColor DarkGray
    Write-Host ""
}

# Ask for confirmation
$confirmation = Read-Host "Do you want to attempt to restart these devices? (Y/N)"

if ($confirmation -ne 'Y' -and $confirmation -ne 'y')
{
    Write-Host ""
    Write-Host "Operation cancelled by user." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Attempting to restart problematic devices..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($device in $problematicDevices)
{
    Write-Host "Processing: $($device.FriendlyName)" -ForegroundColor Cyan
    
    try
    {
        # Disable the device
        Write-Host "  Disabling..." -ForegroundColor Gray
        Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
        Start-Sleep -Seconds 2
        
        # Enable the device
        Write-Host "  Enabling..." -ForegroundColor Gray
        Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false -ErrorAction Stop
        Start-Sleep -Seconds 2
        
        # Check new status
        $updatedDevice = Get-PnpDevice -InstanceId $device.InstanceId
        
        if ($updatedDevice.Status -eq "OK")
        {
            Write-Host "  Successfully restarted - Status: OK" -ForegroundColor Green
            $successCount++
        }
        else
        {
            Write-Host "  Restarted but status still: $($updatedDevice.Status)" -ForegroundColor Yellow
            $failCount++
        }
    }
    catch
    {
        Write-Host "  Failed to restart: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Successfully restarted: $successCount" -ForegroundColor Green

if ($failCount -gt 0)
{
    Write-Host "Failed or still problematic: $failCount" -ForegroundColor Red
}
else
{
    Write-Host "Failed or still problematic: $failCount" -ForegroundColor Green
}

Write-Host ""

if ($failCount -gt 0)
{
    Write-Host "Note: Some devices may require:" -ForegroundColor Yellow
    Write-Host "  Driver updates" -ForegroundColor Gray
    Write-Host "  System restart" -ForegroundColor Gray
    Write-Host "  Hardware replacement" -ForegroundColor Gray
    Write-Host ""
}