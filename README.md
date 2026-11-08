<<<<<<< HEAD
<div align="center">

# Ai Technician

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

> Repo: https://github.com/qubexs/AI-Technician (empty until first push)
> Internal: https://git.osdec.gov.my/ (GitLab, .gov.my account only)

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
=======
# ai-technician



## Getting started

To make it easy for you to get started with GitLab, here's a list of recommended next steps.

Already a pro? Just edit this README.md and make it your own. Want to make it easy? [Use the template at the bottom](#editing-this-readme)!

## Add your files

* [Create](https://docs.gitlab.com/user/project/repository/web_editor/#create-a-file) or [upload](https://docs.gitlab.com/user/project/repository/web_editor/#upload-a-file) files
* [Add files using the command line](https://docs.gitlab.com/topics/git/add_files/#add-files-to-a-git-repository) or push an existing Git repository with the following command:

```
cd existing_repo
git remote add origin https://git.osdec.gov.my/johar/ai-technician.git
git branch -M main
git push -uf origin main
```

## Integrate with your tools

* [Set up project integrations](https://git.osdec.gov.my/johar/ai-technician/-/settings/integrations)

## Collaborate with your team

* [Invite team members and collaborators](https://docs.gitlab.com/user/project/members/)
* [Create a new merge request](https://docs.gitlab.com/user/project/merge_requests/creating_merge_requests/)
* [Automatically close issues from merge requests](https://docs.gitlab.com/user/project/issues/managing_issues/#closing-issues-automatically)
* [Enable merge request approvals](https://docs.gitlab.com/user/project/merge_requests/approvals/)
* [Set auto-merge](https://docs.gitlab.com/user/project/merge_requests/auto_merge/)

## Test and Deploy

Use the built-in continuous integration in GitLab.

* [Get started with GitLab CI/CD](https://docs.gitlab.com/ci/quick_start/)
* [Analyze your code for known vulnerabilities with Static Application Security Testing (SAST)](https://docs.gitlab.com/user/application_security/sast/)
* [Deploy to Kubernetes, Amazon EC2, or Amazon ECS using Auto Deploy](https://docs.gitlab.com/topics/autodevops/requirements/)
* [Use pull-based deployments for improved Kubernetes management](https://docs.gitlab.com/user/clusters/agent/)
* [Set up protected environments](https://docs.gitlab.com/ci/environments/protected_environments/)

***

# Editing this README

When you're ready to make this README your own, just edit this file and use the handy template below (or feel free to structure it however you want - this is just a starting point!). Thanks to [makeareadme.com](https://www.makeareadme.com/) for this template.

## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
>>>>>>> 4fc3bd0f213fa86cce914c1b05846f8a47184229
