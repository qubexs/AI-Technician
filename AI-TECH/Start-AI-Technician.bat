@echo off
title AI Technician - Offline PC Technician
cd /d %~dp0
echo Deleting logs older than 7 days...
if exist logs\agent.log echo [%DATE% %TIME%] Start > logs\agent.log
echo Checking for llama.cpp...
if not exist llama\llama-server.exe (
  echo [ERROR] llama-server.exe not found in AI-TECH\llama
  echo Download llama.cpp Windows CPU AVX2 release and put files here.
  pause
  exit /b 1
)
echo Checking models...
if not exist models\qwen2.5-1.5b-instruct-q4_k_m.gguf (
  echo [ERROR] Small model missing: models\qwen2.5-1.5b-instruct-q4_k_m.gguf
  echo Run download_models.bat with internet ONCE to fetch from Hugging Face.
  pause
  exit /b 1
)
if not exist models\qwen2.5-3b-instruct-q4_k_m.gguf (
  echo [WARNING] Medium model missing: models\qwen2.5-3b-instruct-q4_k_m.gguf
  echo 4GB PCs will use 1.5B automatically. 8GB PCs should download 3B too.
)
echo.
echo Starting AI Technician...
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0Start-AI-Technician.ps1"
echo.
echo Press any key to close...
pause >nul
