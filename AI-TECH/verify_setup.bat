@echo off
title AI Technician - Verify Offline Setup
cd /d %~dp0
echo ==========================================
echo  AI Technician - Pre-flight check
echo ==========================================
echo.
set PASSED=0
set FAILED=0

echo [1] Checking llama.cpp...
if exist llama\llama-server.exe ( echo   OK: llama\llama-server.exe & set /a PASSED+=1 ) else ( echo   MISSING: llama\llama-server.exe - run download_models.bat & set /a FAILED+=1 )
if exist llama\llama-cli.exe ( echo   OK: llama\llama-cli.exe ) else ( echo   WARN: llama-cli.exe missing (server mode ok) )

echo.
echo [2] Checking models...
if exist models\qwen2.5-1.5b-instruct-q4_k_m.gguf ( echo   OK: 1.5B model & set /a PASSED+=1 ) else ( echo   MISSING: models\qwen2.5-1.5b-instruct-q4_k_m.gguf ! & set /a FAILED+=1 )
if exist models\qwen2.5-3b-instruct-q4_k_m.gguf ( echo   OK: 3B model & set /a PASSED+=1 ) else ( echo   MISSING: models\qwen2.5-3b-instruct-q4_k_m.gguf (optional, need 8GB) & set /a FAILED+=1 )

echo.
echo [3] Checking agent scripts...
if exist agent\technician.ps1 ( echo   OK: agent\technician.ps1 & set /a PASSED+=1 ) else ( echo   MISSING agent\technician.ps1 & set /a FAILED+=1 )
if exist agent\tools.ps1 ( echo   OK: agent\tools.ps1 ) else ( echo   MISSING agent\tools.ps1 & set /a FAILED+=1 )
if exist config\settings.json ( echo   OK: config\settings.json ) else ( echo   MISSING config & set /a FAILED+=1 )

echo.
echo [4] Checking PowerShell...
powershell -NoProfile -Command "Write-Host '   OK: PowerShell' -ForegroundColor Green"

echo.
echo [5] RAM...
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; Write-Host ('   Free: ' + [math]::Round($os.FreePhysicalMemory/1MB,2) + ' GB  Total: ' + [math]::Round($os.TotalVisibleMemorySize/1MB,2) + ' GB')"

echo.
echo [6] Offline mode (informational)...
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'http://1.1.1.1' -TimeoutSec 3 -UseBasicParsing | Out-Null; Write-Host '   ONLINE: internet reachable (offline test needs airplane mode)' -ForegroundColor Yellow } catch { Write-Host '   OFFLINE: no internet (good for flight test)' -ForegroundColor Green }"

echo.
echo ==========================================
echo  Result: PASSED=%PASSED% FAILED=%FAILED%
echo ==========================================
echo.
if %FAILED% gtr 0 (
  echo Action: run download_models.bat with internet ON, then this check again.
) else (
  echo Ready! Run Start-AI-Technician.bat (offline safe).
)
echo.
pause
