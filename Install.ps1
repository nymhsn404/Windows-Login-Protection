#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$Root = "C:\ProgramData\LoginProtection"

Write-Host "Installing Windows Login Protection..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $Root -Force | Out-Null

Copy-Item "$PSScriptRoot\Scripts\LoginProtection.ps1" "$Root\LoginProtection.ps1" -Force
Copy-Item "$PSScriptRoot\Scripts\ResetCounter.ps1" "$Root\ResetCounter.ps1" -Force
Copy-Item "$PSScriptRoot\Config\config.ps1" "$Root\config.ps1" -Force

Set-Content "$Root\failed_count.txt" "0" -Force
$boot = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToString("yyyy-MM-dd HH:mm:ss")
Set-Content "$Root\boot_time.txt" $boot -Force

$failedCmd = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$Root\LoginProtection.ps1`""
$resetCmd  = "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$Root\ResetCounter.ps1`""

schtasks.exe /Create /TN "Login Protection - Failed Attempts" /SC ONEVENT /EC Security /MO "*[System[(EventID=4625)]]" /TR $failedCmd /RU SYSTEM /F | Out-Null
schtasks.exe /Create /TN "Login Protection - Successful Login Reset" /SC ONEVENT /EC Security /MO "*[System[(EventID=4624)]]" /TR $resetCmd /RU SYSTEM /F | Out-Null

Write-Host "Installation completed." -ForegroundColor Green
