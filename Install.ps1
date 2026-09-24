#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

$Root = "C:\ProgramData\LoginProtection"
$ScriptsRoot = "$Root\Scripts"
$ConfigRoot = "$Root\Config"

Write-Host "Installing Windows Login Protection..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Path $Root -Force | Out-Null
New-Item -ItemType Directory -Path $ScriptsRoot -Force | Out-Null
New-Item -ItemType Directory -Path $ConfigRoot -Force | Out-Null

# Copy scripts
Copy-Item `
    "$PSScriptRoot\Scripts\LoginProtection.ps1" `
    "$ScriptsRoot\LoginProtection.ps1" `
    -Force

Copy-Item `
    "$PSScriptRoot\Scripts\ResetCounter.ps1" `
    "$ScriptsRoot\ResetCounter.ps1" `
    -Force

# Copy configuration
Copy-Item `
    "$PSScriptRoot\Config\config.ps1" `
    "$ConfigRoot\config.ps1" `
    -Force

# Initialize counter
Set-Content "$Root\failed_count.txt" "0" -Force

# Save current boot time
$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToString("yyyy-MM-dd HH:mm:ss")
Set-Content "$Root\boot_time.txt" $boot -Force

# Scheduled task commands
$failedCmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$ScriptsRoot\LoginProtection.ps1`""

$resetCmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$ScriptsRoot\ResetCounter.ps1`""

# Failed login task
schtasks.exe /Create `
    /TN "Login Protection - Failed Attempts" `
    /SC ONEVENT `
    /EC Security `
    /MO "*[System[(EventID=4625)]]" `
    /TR $failedCmd `
    /RU SYSTEM `
    /F | Out-Null

# Successful login task
schtasks.exe /Create `
    /TN "Login Protection - Successful Login Reset" `
    /SC ONEVENT `
    /EC Security `
    /MO "*[System[(EventID=4624)]]" `
    /TR $resetCmd `
    /RU SYSTEM `
    /F | Out-Null

Write-Host ""
Write-Host "Installation completed successfully." -ForegroundColor Green
Write-Host ""
Write-Host "Install location: $Root"
Write-Host "Maximum failed attempts: 5"
Write-Host "Local Login + RDP protection enabled."
