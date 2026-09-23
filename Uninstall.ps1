#Requires -RunAsAdministrator
$ErrorActionPreference = 'SilentlyContinue'
$Root = "C:\ProgramData\LoginProtection"

schtasks.exe /Delete /TN "Login Protection - Failed Attempts" /F | Out-Null
schtasks.exe /Delete /TN "Login Protection - Successful Login Reset" /F | Out-Null

if (Test-Path $Root) { Remove-Item $Root -Recurse -Force }

Write-Host "Windows Login Protection has been removed." -ForegroundColor Green
