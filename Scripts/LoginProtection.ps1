# Windows Login Protection - Failed Logon Handler
. "$PSScriptRoot\..\Config\config.ps1"

if (!(Test-Path $InstallRoot)) { New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null }

$event = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 1 -ErrorAction SilentlyContinue
if (-not $event) { exit }
if (((Get-Date) - $event.TimeCreated).TotalSeconds -gt 15) { exit }

try {
    $xml = [xml]$event.ToXml()
    $logonType = ($xml.Event.EventData.Data | Where-Object {$_.Name -eq 'LogonType'}).'#text'
} catch { exit }

if ($logonType -notin @('2','10')) { exit }

$bootTime = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$bootString = $bootTime.ToString('yyyy-MM-dd HH:mm:ss')
$previousBoot = if (Test-Path $BootFile) { Get-Content $BootFile -Raw } else { '' }

if ($previousBoot.Trim() -ne $bootString) {
    Set-Content $StateFile '0' -Force
    Set-Content $BootFile $bootString -Force
}

$count = 0
if (Test-Path $StateFile) {
    try { $count = [int](Get-Content $StateFile -Raw) } catch { $count = 0 }
}

$count++
Set-Content $StateFile $count -Force

$time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Add-Content $LogFile "$time - FAILED LOGIN - LogonType=$logonType - Attempt $count/$MaxAttempts"

if ($count -ge $MaxAttempts) {
    Add-Content $LogFile "$time - SECURITY ACTION - Threshold reached. Shutting down."
    shutdown.exe /s /f /t 10 /c "Security protection: too many failed login attempts."
}
