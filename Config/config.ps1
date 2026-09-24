# Windows Login Protection configuration
$MaxAttempts = 5
$InstallRoot = "C:\ProgramData\LoginProtection"
$StateFile   = "$InstallRoot\failed_count.txt"
$BootFile    = "$InstallRoot\boot_time.txt"
$LogFile     = "$InstallRoot\protection.log"
