# GitHub / GitLab Publish - qubexs/AI-Technician

> This file lives in `E:\pr\bootable Ai` and pushes to **qubexs/AI-Technician**.
> `https://git.osdec.gov.my/` is a separate GitLab instance (Malaysian gov) — do NOT push big models there either. Push code to GitHub; host it in OSDeC only if you need internal audit.

## 1. Init (already done in this folder)

```powershell
git init
git branch -M main
git add .
git status
```

Check status: should NOT show any .gguf, llama-server.exe, *.dll (see .gitignore).

```powershell
git commit -m "Crouton Alpha: offline Windows technician USB"
```

## 2. Optional: Install Git LFS

```powershell
git lfs install
git lfs track "*.gguf"
# then re-add if needed
```

**Recommended:** SKIP LFS. Use Release for models (free, no LFS quota).

## 3. Push to GitHub (qubexs/AI-Technician)

Already exists and is empty (empty repo). Push your first commit:

```powershell
git remote add origin https://github.com/qubexs/AI-Technician.git
git push -u origin main
```

You will be prompted for username `qubexs` + Personal Access Token (PAT) or SSH key.

### If you prefer SSH:

```powershell
git remote add origin git@github.com:qubexs/AI-Technician.git
git push -u origin main
```

### If you prefer GitHub CLI (gh):

```powershell
winget install GitHub.cli
gh auth login   # follow prompts, choose HTTPS, login with web browser
gh repo view qubexs/AI-Technician
git remote add origin https://github.com/qubexs/AI-Technician.git
git push -u origin main
```

## 4. Publish Models as Release

1. On https://github.com/qubexs/AI-Technician -> Releases -> Draft a new release
2. Tag: `v1.0-models`
3. Title: `AI Models + llama.cpp (v1.0)`
4. Upload assets:
   - `qwen2.5-1.5b-instruct-q4_k_m.gguf` (1.0 GB)
   - `qwen2.5-3b-instruct-q4_k_m.gguf` (2.0 GB)
   - `llama-cpp-windows-x64-avx2.zip` (llama.cpp CPU build)
5. Publish release

## 5. Update repo settings

- About: Offline Windows Technician USB, llama.cpp, Qwen, English, 4GB/8GB
- Topics: `windows`, `offline-ai`, `llama-cpp`, `qwen`, `winpe`, `technician`

## 6. Verify push

```powershell
git ls-files | Select-String "gguf|llama-server"
# should return NOTHING (models ignored)
# if it shows .gguf, you forgot .gitignore - run:
git rm --cached AI-TECH/models/*.gguf
git commit -m "Remove large model from tracking"
git push
```

## 7. For users downloading your repo

```powershell
git clone https://github.com/qubexs/AI-Technician.git
cd AI-Technician
# models auto-download (internet needed ONCE):
.\AI-TECH\download_models.bat
# then AI-TECH\Start-AI-Technician.bat works 100% offline after that
```

## 8. Optional: Mirror to OSDeC GitLab (https://git.osdec.gov.my/)

OSDeC requires a `.gov.my` or `.edu.my` gov email. If you have access:

Namespace is `johar` for this project.

1. Log in at https://git.osdec.gov.my/
2. Create project: `AI-Technician` (copy URL)
3. Add second remote in this repo:

```powershell
git remote add osdec https://git.osdec.gov.my/johar/AI-Technician.git
# or SSH:
git remote add osdec git@git.osdec.gov.my:johar/AI-Technician.git
git push osdec main
# from now on, push both:
git push origin main
git push osdec main
```

⚠️ Do NOT push .gguf / llama.cpp binaries to OSDeC GitLab either. Use Releases / object storage.
