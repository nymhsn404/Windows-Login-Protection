# Windows Login Protection - Successful Logon Handler
. "$PSScriptRoot\..\Config\config.ps1"

if (!(Test-Path $InstallRoot)) { New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null }

$event = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} -MaxEvents 1 -ErrorAction SilentlyContinue
if (-not $event) { exit }
if (((Get-Date) - $event.TimeCreated).TotalSeconds -gt 15) { exit }

try {
    $xml = [xml]$event.ToXml()
    $logonType = ($xml.Event.EventData.Data | Where-Object {$_.Name -eq 'LogonType'}).'#text'
} catch { exit }

if ($logonType -notin @('2','10')) { exit }

Set-Content $StateFile '0' -Force
$time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Add-Content $LogFile "$time - SUCCESSFUL LOGIN - Counter reset to 0."
