# build_usb_layout.ps1 - Helper to format USB for AI Technician (DO NOT RUN until backup!)
param([string]$DriveLetter="F", [switch]$Force)

Write-Host "=== AI Technician USB Builder ===" -ForegroundColor Green
Write-Host "This script shows the layout and prepares AI-TECH. It does NOT format anything without -Force" -ForegroundColor Yellow

if (-not $Force) {
    Write-Host "Dry-run mode. To actually format, add -Force and backup first." -ForegroundColor Cyan
}

# Create folders on local source folder (E:\pr\bootable Ai)
$base = $PSScriptRoot
$folders = @("AI-TECH\llama","AI-TECH\models","AI-TECH\tools","AI-TECH\drivers","AI-TECH\logs","AI-TECH\config","AI-TECH\agent")
foreach ($f in $folders) { New-Item -ItemType Directory -Path "$base\$f" -Force | Out-Null; Write-Host "Created $f" }

# Placeholder files
Set-Content "$base\AI-TECH\models\PLACEHOLDER.txt" "Download Qwen2.5 1.5B and 3B Q4_K_M GGUF here. Filenames must match config/settings.json"
Set-Content "$base\AI-TECH\llama\PLACEHOLDER.txt" "Download llama.cpp Windows CPU AVX2 release here. Must contain llama-server.exe"
Set-Content "$base\AI-TECH\tools\PLACEHOLDER.txt" "Add CrystalDiskInfo, HWiNFO portable, .bat tools here"
Set-Content "$base\AI-TECH\drivers\PLACEHOLDER.txt" "Add Intel/AMD offline chipset+LAN drivers here (extracted folders)"

Write-Host "`nLayout ready. Copy entire AI-TECH folder to USB root." -ForegroundColor Green
Write-Host "Then download models: AI-TECH\download_models.bat (internet ONCE)" -ForegroundColor Cyan
Write-Host "Then verify: AI-TECH\verify_setup.bat - must show PASSED>0 FAILED=0" -ForegroundColor Cyan
Write-Host "Then publish code to GitHub: README -> GITHUB_PUBLISH.md (models via Release, not commit)" -ForegroundColor Cyan

if ($Force) {
    Write-Host "WARNING: Formatting drive $DriveLetter : is dangerous!" -ForegroundColor Red
    $ans = Read-Host "Type YES to continue formatting $DriveLetter : (all data lost)"
    if ($ans.ToUpper() -ne 'YES') { Write-Host "Aborted."; return }
    # Example DiskMgmt via PowerShell: for safety we just create folders on target drive
    $target = "${DriveLetter}:\AI-TECH"
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    robocopy "$base\AI-TECH" $target /E
    Write-Host "Copied AI-TECH to $target"
    Write-Host "Now partition USB manually in Disk Management for Live Windows if needed."
}
