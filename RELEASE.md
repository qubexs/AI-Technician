# Release v1.0-models - What to upload

> Code lives in Git (GitHub + OSDeC). Large binaries live here as **Release assets**, never as commits.

## Create the release on GitHub

1. https://github.com/qubexs/AI-Technician -> Releases -> Draft a new release
2. **Tag:** `v1.0-models`
3. **Title:** `AI Models + llama.cpp (v1.0)`
4. **Description:** paste contents of this file (short version below)
5. Upload these 3 files from your local `release\` folder:

| File | Size | Source |
|---|---|---|
| `qwen2.5-1.5b-instruct-q4_k_m.gguf` | 1.07 GB | Hugging Face Qwen2.5-1.5B-Instruct-GGUF (Q4_K_M) — SHA256 `6A1A2EB6D15622BF3C96857206351BA97E1AF16C30D7A74EE38970E434E9407E` |
| `qwen2.5-3b-instruct-q4_k_m.gguf` | 2.01 GB | Hugging Face Qwen2.5-3B-Instruct-GGUF (Q4_K_M) — SHA256 `626B4A6678B86442240E33DF819E00132D3BA7DDDFE1CDC4FBB18E0A9615C62D` |
| `llama-cpp-windows-x64-avx2.zip` | 24.2 MB | llama.cpp `b12110` `llama-b12110-bin-win-cpu-x64.zip` (53 files incl. `llama-server.exe`, `llama-cli.exe`, `ggml-cpu-*.dll`, `libomp.dll`) — SHA256 `282E97F0F11D62DA9C5F2E78BB472CA05E4C4DD6B7B8A5698C006C4C020ED611` (after re-zip; original zip hash differs only by compression) |

6. Publish release.

## Mirror on OSDeC GitLab

`https://git.osdec.gov.my/johar/AI-Technician` - Uploads tab -> New -> same 3 files (max size limit per instance may apply; if >2GB single file is blocked, split or host on GitHub Release only and link from OSDeC README).

## Short description (paste into GitHub Release body)

```
Offline AI models for AI Technician USB.

Billing:
- qwen2.5-1.5b-instruct-q4_k_m.gguf (1.07GB) - 4GB RAM PCs, 8-12 tok/s
- qwen2.5-3b-instruct-q4_k_m.gguf (2.01GB) - 8GB RAM PCs, 5-8 tok/s
- llama-cpp-windows-x64-avx2.zip (24 MB, llama.cpp b12110, 53 files) - CPU-only win-x64 (`llama-server.exe`)

Setup:
1. Clone https://github.com/qubexs/AI-Technician.git
2. Put llama.cpp zip contents into AI-TECH\llama\
3. Put .gguf files into AI-TECH\models\
4. Run AI-TECH\verify_setup.bat - must show PASSED with FAILED=0
5. Copy AI-TECH\ to USB root, boot offline.

Models: Apache-2.0 (Qwen). llama.cpp: MIT. This repo code: MIT.
```
