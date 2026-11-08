# tools.ps1 - Allowlisted technician tools for Crouton Alpha
# All functions return a string result to feed back to the AI.

function Write-ToolLog {
    param([string]$Message)
    $logDir = Join-Path $PSScriptRoot "..\logs"
    if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content "$logDir\agent.log" $line
    Write-Host $line -ForegroundColor DarkGray
}

function Run-CommandSafe {
    param([string]$Cmd)
    Write-ToolLog "RUN: $Cmd"
    try { $out = Invoke-Expression $Cmd 2>&1 | Out-String; return "COMMAND: $Cmd`n$out" }
    catch { return "ERROR running $Cmd : $($_.Exception.Message)" }
}

# ---- DIAGNOSTICS ----

function Get-SystemInfo {
    $os = (Get-CimInstance Win32_OperatingSystem)
    $cs = (Get-CimInstance Win32_ComputerSystem)
    $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
    return @"
OS: $($os.Caption) Build $($os.BuildNumber) $($os.OSArchitecture)
Computer: $($cs.Manufacturer) $($cs.Model)
Total RAM: $([math]::Round($cs.TotalPhysicalMemory/1GB,2)) GB
Free RAM: $([math]::Round($os.FreePhysicalMemory/1MB,2)) GB
CPU: $cpu
Uptime: $((Get-Date) - $os.LastBootUpTime)
"@
}

function Get-DiskSpace {
    $d = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null }
    $s = foreach ($x in $d) {
        $freeGB = [math]::Round($x.Free/1GB,2)
        $usedGB = [math]::Round($x.Used/1GB,2)
        "$($x.Name): $($x.Root) Used $usedGB GB Free $freeGB GB"
    }
    return "DISKS:`n$($s -join "`n")"
}

function Get-DiskSmart {
    try {
        $disks = Get-WmiObject -Namespace root/wmi -Class MSStorageDriver_FailurePredictStatus -ErrorAction Stop
        $s = foreach ($d in $disks) { "Disk Status: Predict Fail=$($d.PredictFailure) Reason=$($d.Reason)" }
        return "SMART WMI:`n$($s -join "`n")`nNote: For full SMART + temp run CrystalDiskInfo portable from Tools folder."
    } catch {
        return Run-CommandSafe "Get-PhysicalDisk | Format-List FriendlyName,MediaType,HealthStatus,OperationalStatus,Size"
    }
}

function Get-MemoryInfo {
    $s = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($s.TotalVisibleMemorySize/1MB,2)
    $free = [math]::Round($s.FreePhysicalMemory/1MB,2)
    $used = [math]::Round($total-$free,2)
    $pct = [math]::Round(($used/$total)*100,1)
    return "MEMORY: Total ${total}MB Used ${used}MB (${pct}%) Free ${free}MB"
}

function Get-CPUInfo {
    $c = Get-CimInstance Win32_Processor | Select-Object -First 1
    $load = $c.LoadPercentage
    return "CPU: $($c.Name) Load ${load}% Cores=$($c.NumberOfCores) Threads=$($c.NumberOfLogicalProcessors)"
}

function List-Drivers {
    return Run-CommandSafe "Get-WindowsDriver -Online | Select-Object Driver,Provider,Date | Format-Table -AutoSize | Out-String"
}

function Get-RecentErrors {
    try {
        $ev = Get-WinEvent -FilterHashtable @{LogName='System'; Level=2,3} -MaxEvents 20 -ErrorAction Stop
        $s = foreach ($e in $ev) { "$($e.TimeCreated) ID=$($e.Id) $($e.ProviderName): $($e.Message)" }
        return "SYSTEM ERRORS (last 20):`n$($s -join "`n`n")"
    } catch { return "No WinEvent access: $($_.Exception.Message)`nTry: eventvwr.msc" }
}

function Get-EventLogErrors {
    return Get-RecentErrors
}

function Get-NetworkStatus {
    $a = Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,Status,LinkSpeed
    $ip = Get-IPConfiguration -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,IPv4Address | Out-String
    return "ADAPTERS:`n$($a | Out-String)`nIP:`n$ip`nPing DNS test offline: $($((Test-NetConnection 8.8.8.8 -Count 2 -ErrorAction SilentlyContinue).PingSucceeded))"
}

function Get-WindowsUpdateStatus {
    return Run-CommandSafe "Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 | Format-Table Source,InstalledOn,Description -AutoSize | Out-String"
}

function Get-BatteryHealth {
    try {
        $b = Get-WmiObject -ClassName Win32_Battery | Where-Object { $_.Name -ne $null }
        return "BATTERY:`n$($b | Format-List Name,EstimatedChargeRemaining,Status,DesignCapacity,FullChargeCapacity | Out-String)`nNote: Run powercfg /batteryreport for full report."
    } catch { return "No battery found (desktop PC?) : $($_.Exception.Message)" }
}

function Get-Temperature {
    return "Temp via WMI: $($((Get-WmiObject -Namespace root/wmi -Class MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue | Select-Object -First 1).CurrentTemperature - 273.15)) C`nFor accurate CPU/GPU temp use HWiNFO portable. Chipset driver may be missing offline."
}

function Get-InstalledAppsCount {
    $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue
    return "Installed apps count: $($apps.Count)`nTop heavy (size unknown offline): $($apps | Select-Object -First 20 DisplayName | Out-String)"
}

function Verify-SFCOnly {
    return Run-CommandSafe "sfc /verifyonly"
}

# ---- REPAIRS (require YES) ----

function Create-RestorePoint {
    return Run-CommandSafe "Enable-ComputerRestore -Drive 'C:\'; Checkpoint-Computer -Description 'Crouton Alpha Auto Backup' -RestorePointType 'MODIFY_SETTINGS'"
}

function Registry-Backup {
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $dest = "C:\CroutonBackup_$ts.reg"
    return Run-CommandSafe "reg export HKLM $dest /y; echo Backup saved to $dest"
}

function Run-SFC {
    return Run-CommandSafe "sfc /scannow"
}

function Run-DISM {
    return Run-CommandSafe "DISM.exe /Online /Cleanup-Image /RestoreHealth"
}

function Run-CHKDSK {
    return Run-CommandSafe "chkdsk C: /f /r"
}

function Flush-DNS {
    return Run-CommandSafe "ipconfig /flushdns; netsh winsock reset; netsh int ip reset"
}

function Cleanup-Temp {
    return Run-CommandSafe "Get-ChildItem C:\Windows\Temp -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; Get-ChildItem $env:TEMP -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; echo Cleanup done"
}

function Repair-Boot {
    return Run-CommandSafe "bootrec /fixmbr; bootrec /fixboot; bootrec /rebuildbcd; bcdboot C:\Windows /s Z: /f UEFI"
}

function Bcdboot-Repair {
    return Repair-Boot
}

# ---- Router ----
$ToolMap = @{
    get_system_info      = { Get-SystemInfo }
    get_disk_space       = { Get-DiskSpace }
    get_disk_smart       = { Get-DiskSmart }
    get_memory_info      = { Get-MemoryInfo }
    get_cpu_info         = { Get-CPUInfo }
    list_drivers         = { List-Drivers }
    get_recent_errors    = { Get-RecentErrors }
    get_event_log_errors = { Get-EventLogErrors }
    get_network_status   = { Get-NetworkStatus }
    get_windows_update_status = { Get-WindowsUpdateStatus }
    get_battery_health   = { Get-BatteryHealth }
    get_temperature      = { Get-Temperature }
    get_installed_apps_count = { Get-InstalledAppsCount }
    verify_sfc_only      = { Verify-SFCOnly }
    create_restore_point = { Create-RestorePoint }
    registry_backup      = { Registry-Backup }
    run_sfc              = { Run-SFC }
    run_dism             = { Run-DISM }
    run_chkdsk           = { Run-CHKDSK }
    flush_dns            = { Flush-DNS }
    cleanup_temp         = { Cleanup-Temp }
    repair_boot          = { Repair-Boot }
    bcdboot_repair       = { Bcdboot-Repair }
}

$RepairTools = @('create_restore_point','registry_backup','run_sfc','run_dism','run_chkdsk','flush_dns','cleanup_temp','repair_boot','bcdboot_repair')

function Invoke-TechnicianTool {
    param([string]$Name)
    $key = $Name.ToLower().Trim()
    if (-not $ToolMap.ContainsKey($key)) { return "UNKNOWN TOOL: $Name. Allowed: $($ToolMap.Keys -join ', ')" }
    if ($RepairTools -contains $key) {
        Write-Host "`n[BLOCKED] REPAIR TOOL requested: $key" -ForegroundColor Yellow
        Write-Host "Type YES to confirm this repair, or type NO to skip." -ForegroundColor Cyan
        $ans = Read-Host "Confirm repair '$key' ? (YES/NO)"
        if ($ans.Trim().ToUpper() -ne 'YES') {
            return "USER SKIPPED repair tool '$key' (typed NO). Do not retry without asking again."
        }
    }
    Write-Host "[Running tool] $key ..." -ForegroundColor Green
    $fn = $ToolMap[$key]
    return & $fn
}
