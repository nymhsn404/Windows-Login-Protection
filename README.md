# Windows Login Protection

A lightweight PowerShell-based security utility for Windows that monitors failed interactive login attempts and automatically shuts down the PC after a configurable number of consecutive failures.

## Features

- 🔐 Automatic shutdown after 5 failed interactive login attempts
- 🔄 Counter resets after a successful interactive login
- 🔄 Counter resets after a Windows reboot
- 🖥️ Supports local interactive logins and Remote Desktop (RDP)
- 📝 Local protection log
- ⚙️ Configurable attempt limit
- 📦 Simple PowerShell installation
- 🗑️ Clean uninstall script

## How it works

The protection uses Windows Security Event Log:

- `4625` — failed logon
- `4624` — successful logon

Only interactive (`Logon Type 2`) and Remote Interactive / RDP (`Logon Type 10`) logons are considered.

Default behavior:

```text
Wrong password  → 1/5
Wrong password  → 2/5
Wrong password  → 3/5
Wrong password  → 4/5
Wrong password  → 5/5
                         ↓
                  Automatic shutdown
                         ↓
                     PC starts
                         ↓
                    Counter = 0
```

If the correct password is entered before the fifth failure:

```text
Wrong → 1/5
Wrong → 2/5
Correct login
     ↓
Counter reset → 0
```

## Requirements

- Windows 10 / Windows 11
- Windows PowerShell 5.1 or newer
- Administrator privileges
- Security event auditing enabled

## Installation

1. Download or clone this repository.
2. Open **PowerShell as Administrator**.
3. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Install.ps1
```

The installer creates the protection scripts and Windows Scheduled Tasks.

## Configuration

Open:

```text
Config\config.ps1
```

Change:

```powershell
$MaxAttempts = 5
```

For example:

```powershell
$MaxAttempts = 3
```

Then run the installer again.

## Logs

Protection logs are stored at:

```text
C:\ProgramData\LoginProtection\protection.log
```

The current counter is stored at:

```text
C:\ProgramData\LoginProtection\failed_count.txt
```

These files are reset/updated automatically by the protection scripts.

## Uninstall

Run PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\Uninstall.ps1
```

The scheduled tasks and application directory will be removed.

## Important testing note

Test this on a non-critical PC first. Automatic shutdown can interrupt active work and may affect remote administration.

If you administer a server, workstation, or domain environment, consider Microsoft's native account lockout policies and endpoint security controls alongside this project.

## License

MIT License. See `LICENSE`.
