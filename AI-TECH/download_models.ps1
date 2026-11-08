# download_models.ps1 - Download Qwen models + llama.cpp (ONE-TIME internet, then offline forever)
param(
  [string]$OutDir = "$PSScriptRoot\models",
  [string]$LlamaDir = "$PSScriptRoot\llama",
  [switch]$SkipLlama,
  [switch]$OnlySmall
)

$ErrorActionPreference = "Continue"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
if (-not (Test-Path $LlamaDir)) { New-Item -ItemType Directory -Path $LlamaDir -Force | Out-Null }

# ---- Model URLs (Hugging Face, official Qwen GGUF mirrors) ----
$models = @(
  @{
    Name = "qwen2.5-1.5b-instruct-q4_k_m.gguf"
    Url  = "https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf"
    SizeGB = 1.0
    AltUrl = "https://huggingface.co/lmstudio-community/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/Qwen2.5-1.5B-Instruct-Q4_K_M.gguf"
  },
  @{
    Name = "qwen2.5-3b-instruct-q4_k_m.gguf"
    Url  = "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
    SizeGB = 2.0
    AltUrl = "https://huggingface.co/lmstudio-community/Qwen2.5-3B-Instruct-GGUF/resolve/main/Qwen2.5-3B-Instruct-Q4_K_M.gguf"
  }
)

if ($OnlySmall) { $models = $models[0..0] }

function Download-File {
  param([string]$Url,[string]$Dest)
  try {
    Write-Host "Downloading: $Url" -ForegroundColor Cyan
    Write-Host "  -> $Dest" -ForegroundColor DarkGray
    $tmp = "$Dest.part"
    # Try primary URL, fallback to AltUrl
    try { Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing } 
    catch { throw "Primary failed: $($_.Exception.Message)" }
    if (Test-Path $tmp) { Move-Item $tmp $Dest -Force; Write-Host "OK: $Dest" -ForegroundColor Green }
  } catch {
    Write-Host "Primary failed, trying AltUrl..." -ForegroundColor Yellow
    $alt = $models | Where-Object { $_.Name -eq [System.IO.Path]::GetFileName($Dest) } | Select-Object -ExpandProperty AltUrl
    if ($alt) {
      try { Invoke-WebRequest -Uri $alt -OutFile "$Dest.part" -UseBasicParsing; Move-Item "$Dest.part" $Dest -Force; Write-Host "OK via Alt: $Dest" -ForegroundColor Green; return }
      catch { Write-Host "Alt also failed: $($_.Exception.Message)" -ForegroundColor Red }
    }
  }
}

foreach ($m in $models) {
  $dest = Join-Path $OutDir $m.Name
  if (Test-Path $dest) {
    $sizeMB = [math]::Round((Get-Item $dest).Length/1MB,1)
    Write-Host "Exists: $($m.Name) (${sizeMB} MB) - skipping" -ForegroundColor Yellow
  } else {
    Download-File -Url $m.Url -Dest $dest
  }
}

# ---- llama.cpp (Windows CPU AVX2, CPU-only for Intel/AMD 4GB) ----
if (-not $SkipLlama) {
  Write-Host "`n=== llama.cpp ===" -ForegroundColor Green
  if (Test-Path "$LlamaDir\llama-server.exe") {
    Write-Host "llama-server.exe already exists, skipping" -ForegroundColor Yellow
  } else {
    $releasesApi = "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest"
    Write-Host "Querying latest llama.cpp release (CPU AVX2)..." -ForegroundColor Cyan
    try {
      $rel = Invoke-RestMethod -Uri $releasesApi -Headers @{ "User-Agent"="AI-Technician" }
      $asset = $rel.assets | Where-Object { $_.name -match 'bin-win-cpu.*\.zip$|.*win.*cpu.*\.zip$|.*windows.*cpu.*\.zip$' } | Select-Object -First 1
      if (-not $asset) {
        # v0.9.0 release JSON only has placeholder assets; nightly binaries live under tag b12110
        # https://github.com/ggml-org/llama.cpp/releases/tag/b12110
        Write-Host "No CPU zip in 'latest' release (v0.9.0). Falling back to nightly b12110." -ForegroundColor Yellow
        $nightlyApi = "https://api.github.com/repos/ggml-org/llama.cpp/releases/tags/b12110"
        $rel = Invoke-RestMethod -Uri $nightlyApi -Headers @{ "User-Agent"="AI-Technician" }
        $asset = $rel.assets | Where-Object { $_.name -match 'bin-win-cpu-x64\.zip$|.*win.*cpu.*\.zip$' } | Select-Object -First 1
      }
      if (-not $asset) { $asset = $rel.assets | Where-Object { $_.name -match '\.zip$' } | Select-Object -First 1 }
      if ($asset) {
        $zip = "$env:TEMP\$($asset.name)"
        Write-Host "Downloading: $($asset.browser_download_url)" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip -UseBasicParsing
        Write-Host "Extracting to $LlamaDir ..." -ForegroundColor DarkGray
        Expand-Archive -Path $zip -DestinationPath $LlamaDir -Force
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        Write-Host "llama.cpp ready: $LlamaDir" -ForegroundColor Green
      } else { Write-Host "No zip asset found, download manually: https://github.com/ggml-org/llama.cpp/releases" -ForegroundColor Red }
    } catch {
      Write-Host "Failed to auto-download llama.cpp: $($_.Exception.Message)" -ForegroundColor Red
      Write-Host "Manual: https://github.com/ggml-org/llama.cpp/releases/tag/b12110 -> download llama-b12110-bin-win-cpu-x64.zip -> extract to $LlamaDir" -ForegroundColor Yellow
    }
  }
}

Write-Host "`n=== Done ===" -ForegroundColor Green
Get-ChildItem $OutDir
Get-ChildItem $LlamaDir
Write-Host "`nNow run: Start-AI-Technician.bat (works offline from now on)" -ForegroundColor Cyan
