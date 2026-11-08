@echo off
title AI Technician - Download Models (one-time)
cd /d %~dp0
echo ==========================================
echo  AI Technician Model Downloader
echo  Internet needed ONCE, offline after.
echo ==========================================
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0download_models.ps1" %*
if errorlevel 1 (
  echo.
  echo Download failed. Check internet and run again.
  pause
  exit /b 1
)
echo.
echo Press any key to close...
pause >nul
