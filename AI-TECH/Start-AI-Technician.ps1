# Start-AI-Technician.ps1
param([switch]$ForceSmall, [switch]$ForceMedium)

$base = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $base

if (-not (Test-Path "llama")) {
    Write-Host "Folder llama/ not found. Put llama-server.exe + llama-cli.exe + dlls in AI-TECH\llama" -ForegroundColor Red
} 

# Detect RAM
$os = Get-CimInstance Win32_OperatingSystem
$freeGB = [math]::Round($os.FreePhysicalMemory/1MB,2)
Write-Host "Free RAM: ${freeGB} GB" -ForegroundColor Cyan

$config = Get-Content "$base\config\settings.json" -Raw | ConvertFrom-Json
$useSmall = $freeGB -lt $config.models.ramThresholdGB
if ($ForceSmall) { $useSmall = $true }
if ($ForceMedium) { $useSmall = $false }

$modelRel = if ($useSmall) { $config.models.small } else { $config.models.medium }
$modelPath = Join-Path $base $modelRel
if (-not (Test-Path $modelPath)) {
    Write-Host "Model not found: $modelPath" -ForegroundColor Red
    Write-Host "Run AI-TECH\download_models.bat with internet ONCE to download from Hugging Face" -ForegroundColor Yellow
    Write-Host "Expected path: $modelRel" -ForegroundColor Cyan
    Write-Host "Then run AI-TECH\verify_setup.bat to confirm offline readiness" -ForegroundColor Cyan
    Write-Host "Press any key to exit"
    [void][System.Console]::ReadKey()
    exit 1
}

Write-Host "Starting AI Technician with model: $modelPath" -ForegroundColor Green

$llamaExe = "$base\llama\llama-server.exe"
if (-not (Test-Path $llamaExe)) { $llamaExe = "$base\llama\llama-cli.exe" }

$url = "http://127.0.0.1:$($config.server.port)/health"
$argsList = @(
    "-m", "`"$modelPath`"",
    "--host", $config.server.host,
    "--port", $config.server.port,
    "--ctx-size", $config.server.ctxSize,
    "--threads", $config.server.threads,
    "--parallel", $config.server.parallel,
    "-ot", "output_layer=0"
) -join " "

Write-Host "Starting server: $llamaExe $argsList" -ForegroundColor DarkGray
$proc = Start-Process -FilePath $llamaExe -ArgumentList $argsList -PassThru -WindowStyle Minimized

# Wait for server
$ready = $false
for ($i=0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 2
    try { $r = Invoke-WebRequest -Uri $url -TimeoutSec 2 -UseBasicParsing; if ($r.StatusCode -eq 200) { $ready = $true; break } } catch {}
    Write-Host "Waiting for AI... ($i)" -ForegroundColor DarkGray
}
if (-not $ready) { Write-Host "Server did not start in 60s. Continue anyway, try llama-cli mode." -ForegroundColor Yellow }

# Launch agent
powershell -ExecutionPolicy Bypass -File "$base\agent\technician.ps1" -SettingsPath "$base\config\settings.json"

Write-Host "Agent ended. Stopping llama-server..." -ForegroundColor Cyan
try { Stop-Process -Id $proc.Id -Force } catch {}
