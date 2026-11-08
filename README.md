<div align="center">

# AI Technician

**Offline Windows Technician USB — AI inside your bootable Windows 11 installer**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![llama.cpp](https://img.shields.io/badge/llama.cpp-CPU%20AVX2-blue.svg)](https://github.com/ggml-org/llama.cpp)
[![Model](https://img.shields.io/badge/Qwen2.5-1.5B_3B%20Q4_K_M-green.svg)](https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF)
[![RAM](https://img.shields.io/badge/4GB_%7C_8GB%20RAM-orange.svg)](#)
[![Offline](https://img.shields.io/badge/100%25%20Offline-success.svg)](#)

</div>

> Turn any bootable Windows 11 USB into a 100% offline AI repair bench. No internet. No cloud. Diagnosis first, repair only after you say **YES**.

---

## What it does

| | |
|---|---|
| **You give it** | Existing bootable Windows 11 USB (installer) + 64GB total |
| **What it adds** | `AI-TECH` folder — llama.cpp CPU engine + Qwen models + safe agent |
| **Specs tuned for** | Intel/AMD, 4GB / 8GB RAM, CPU-only (no GPU needed), English |
| **How it runs** | Local `llama-server` on `127.0.0.1:8080` → PowerShell agent → allowlisted Windows tools |
| **Safety** | AI **never** repairs without your `YES`. Backup before sfc/DISM/chkdsk/bootrec. |

```text
Boot USB -> Windows Setup (or Live Windows) -> Start-AI-Technician.bat
  -> Detects free RAM -> picks 1.5B (4GB) or 3B (8GB) model
  -> llama-server starts (localhost only, ctx 2048)
  -> Chat: "PC slow, blue screen, disk clicking?"
  -> AI calls allowlisted tools -> explains in plain English
  -> AI asks: "Run sfc /scannow? Type YES"
  -> You type YES -> backup restore point -> repair -> verify -> report
```

## Features

- ✅ Works **100% offline** after one-time model download (airplane mode OK)
- ✅ Diagnose-only tools: SMART, disk free, RAM, CPU load, drivers, event log errors, network status, update status, battery health, temperature, `sfc /verifyonly`
- ✅ Repair tools (YES-gated): restore point, registry backup, `sfc /scannow`, `DISM /RestoreHealth`, `chkdsk`, DNS flush, temp cleanup, `bootrec`/`bcdboot`
- ✅ Auto model picker by free RAM (no manual switch)
- ✅ Runs from Windows Setup (`Shift+F10`) **or** Live Windows To Go
- ✅ Logs to `AI-TECH/logs/agent.log` — nothing leaves the PC
- ✅ CPU-only AVX2 — works on almost any Intel/AMD from last 10 years

## Quick Start

### 1. Get the code

```powershell
git clone https://github.com/qubexs/AI-Technician.git
cd AI-Technician
```

### 2. Download models (ONE-TIME internet)

```powershell
.\AI-TECH\download_models.bat
```

This auto-downloads:

| File | Size | RAM | Use |
|---|---|---|---|
| `qwen2.5-1.5b-instruct-q4_k_m.gguf` | ~1.0 GB | 4 GB | Default on small PCs, 8-12 tok/s |
| `qwen2.5-3b-instruct-q4_k_m.gguf` | ~2.0 GB | 8 GB | Better answers, 5-8 tok/s |
| `llama.cpp` win-x64 AVX2 | ~20 MB | — | CPU engine |

Models are **not** in Git (see `.gitignore`) — they live on Hugging Face + this repo's Releases.

### 3. Copy to USB

Copy the whole `AI-TECH` folder to your USB root (keep your Windows installer intact):

```text
USB:\
  EFI\ sources\          <- your Windows 11 installer (untouched)
  AI-TECH\               <- copy this
    Start-AI-Technician.bat
    llama\ llama-server.exe
    models\ *.gguf
    tools\  (portable CrystalDiskInfo, HWiNFO — optional)
    drivers\ (Intel/AMD offline pack — optional)
```

### 4. Boot & run

**Mode A — From Windows Setup (no Live Windows needed):**
1. Boot from USB → Windows Setup screen
2. Press `Shift+F10`
3. Type: `D:\AI-TECH\Start-AI-Technician.bat` *(drive letter may vary)*
4. Chat in English

**Mode B — Live Windows To Go (recommended for 4GB):**
1. Use WinToUSB to install Tiny11 to a 20GB second partition
2. Boot it → AI auto-starts from Desktop/Startup shortcut
3. 3-4× faster than Setup mode

## RAM Logic

| Free RAM at boot | Model used | Speed (i3) | RAM used |
|---|---|---|---|
| < 2.5 GB | 1.5B Instruct Q4_K_M | 8–12 tok/s | ~1.2 GB |
| ≥ 2.5 GB | 3B Instruct Q4_K_M | 5–8 tok/s | ~2.3 GB |

Server: `--ctx-size 2048 --threads 2 --parallel 1` — tuned for 4GB (not 8192).

Force a model: `powershell -File .\AI-TECH\Start-AI-Technician.ps1 -ForceSmall`

## Tech Stack

```
llama.cpp (ggml-org)  CPU AVX2, no CUDA — llama-server + llama-cli
Qwen2.5 1.5B / 3B Instruct GGUF (Q4_K_M)  CPU quantized models
PowerShell 5.1 agent  Tools allowlist, YES-gate for repairs
Storage: bootable USB, NTFS/FAT32 mix, UEFI/GPT
```

## Tool Catalog

**Diagnostics (auto):** `get_system_info`, `get_disk_space`, `get_disk_smart`, `get_memory_info`, `get_cpu_info`, `list_drivers`, `get_recent_errors`, `get_event_log_errors`, `get_network_status`, `get_windows_update_status`, `get_battery_health`, `get_temperature`, `get_installed_apps_count`, `verify_sfc_only`

**Repairs (requires YES):** `create_restore_point`, `registry_backup`, `run_sfc`, `run_dism`, `run_chkdsk`, `flush_dns`, `cleanup_temp`, `repair_boot`, `bcdboot_repair`

AI can only output JSON: `{"tool": "get_disk_smart", "params": {}}` — no invented commands.

## GitHub Publishing

> Public: https://github.com/qubexs/AI-Technician
> Internal (OSDeC GitLab): https://git.osdec.gov.my/johar/AI-Technician

Models are git-ignored. Publish code to repo, models to **Releases**:

1. `git push` code (see `GITHUB_PUBLISH.md`)
2. Releases → `v1.0-models` → upload `.gguf` + `llama-cpp-win-x64-avx2.zip`
3. Users clone code, run `download_models.bat` once, then offline forever

See `.gitignore`, `.gitattributes`, `LICENSE` (MIT).

## Docs

- `README-USB.md` — full build steps, troubleshooting, offline test script
- `GITHUB_PUBLISH.md` — exact git/gh commands
- `AI-TECH/config/settings.json` — server + model paths + temps
- `AI-TECH/agent/system_prompt.txt` — technician persona + tool rules

## Troubleshooting

| Symptom | Fix |
|---|---|
| `llama-server.exe not found` | Run `download_models.bat`, check `AI-TECH/llama/*.dll` next to exe |
| Server not ready in 60s | Close heavy apps, force small model, check `logs/` |
| SFC/DISM fails in Setup | Use Mode B (Live Windows) — those need a running Windows |
| Missing driver offline | Add pack to `AI-TECH/drivers/`, install via Device Manager |
| Very slow | Close browser, use `-ForceSmall`, ctx already 2048 |
| Port 8080 in use | Kill old `llama-server.exe` (Task Manager) and retry |

## Offline Test

1. Wi-Fi OFF, Ethernet unplugged, airplane mode ON
2. Boot USB, run `Start-AI-Technician.bat`
3. Say: *"PC slow and blue screen 0x0000007F, disk clicking"*
4. AI should call `get_disk_smart` + `get_recent_errors`, explain, and ask for `YES` before any repair

## License

MIT — see `LICENSE`. Qwen models are Apache-2.0 (Qwen team). llama.cpp is MIT.

---

*Built for technicians who fix PCs with zero internet. Put it on a USB, carry it anywhere.*
