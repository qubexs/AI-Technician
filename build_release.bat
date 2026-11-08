@echo off
REM Build release assets: zip llama.cpp + collect .gguf models
REM Usage: build_release.bat   (run after download_models.bat)
REM Output: release\  (local only, gitignored - upload to GitHub Releases)
setlocal
cd /d %~dp0
if not exist release mkdir release
if not exist AI-TECH\llama\llama-server.exe (
  echo [ERROR] AI-TECH\llama\llama-server.exe not found. Run AI-TECH\download_models.bat first.
  pause
  exit /b 1
)
echo Zipping llama.cpp...
powershell -NoProfile -Command "Compress-Archive -Path 'AI-TECH\llama\*' -DestinationPath 'release\llama-cpp-windows-x64-avx2.zip' -Force"
echo Copying models...
if exist AI-TECH\models\qwen2.5-1.5b-instruct-q4_k_m.gguf copy /y AI-TECH\models\qwen2.5-1.5b-instruct-q4_k_m.gguf release\ >nul
if exist AI-TECH\models\qwen2.5-3b-instruct-q4_k_m.gguf copy /y AI-TECH\models\qwen2.5-3b-instruct-q4_k_m.gguf release\ >nul
echo.
dir release
echo.
echo Next: github.com/qubexs/AI-Technician - Releases - Draft new release - Tag v1.0-models
echo Upload the 3 files in release\ and Publish. See RELEASE.md
echo.
pause
endlocal
