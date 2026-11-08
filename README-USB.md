# AI Technician - Offline Windows Technician USB (Intel/AMD, 4GB/8GB RAM)

## What this does
Turns your existing bootable Windows 11 installer USB into an offline AI repair tool.
AI runs 100% offline with llama.cpp (CPU-only), English only.
AI diagnoses first, only repairs after you type YES.

## USB Size Plan (64GB recommended)
- Partition 1 (8GB): Existing Windows 11 installer
- Partition 2 (20GB): Live Windows To Go / Tiny11 - debloated, no Defender
- AI-TECH folder: ~5GB (llama.cpp + 2 models + agent + tools)
- drivers\ : offline Intel/AMD chipset + LAN pack (~2GB)

## Folder Structure
```
USB \
  EFI\ sources\  (your current Windows installer - DO NOT DELETE)
  AI-TECH\
    Start-AI-Technician.bat
    Start-AI-Technician.ps1
    config\settings.json
    agent\technician.ps1, tools.ps1, system_prompt.txt
    llama\ llama-server.exe, llama-cli.exe, *.dll
    models\ qwen2.5-1.5b-instruct-q4_k_m.gguf (1.0GB)
            qwen2.5-3b-instruct-q4_k_m.gguf   (2.0GB)
    tools\  (CrystalDiskInfo, HWiNFO, MemTest)
    drivers\ (Intel + AMD offline drivers)
    logs\
```

## Download Checklist
1. llama.cpp Windows CPU AVX2 release: https://github.com/ggerganov/llama.cpp/releases
   Extract to AI-TECH\llama\
2. Model small: https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF or loracnnaa variant Q4_K_M
3. Model medium: https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF Q4_K_M
4. Tiny11 / Live Windows builder: https://github.com/xkelx314/Creator-Edition-Windows-11 (debloat) or Microsoft WinToUSB
5. CrystalDiskInfo portable, HWiNFO portable
6. DriverPack Solution offline or Samsung/Intel/AMD official driver folders

## Build Steps
1. Plug 64GB USB, backup.
2. Mount your current Windows 11 USB, keep it untouched.
3. Create second partition (DiskMgmt -> Shrink -> New) for Live Windows.
4. Use WinToUSB to install Tiny11 to that partition (UEFI mode, USB physical).
5. Copy AI-TECH folder to USB root (or Live partition root).
6. Copy models to AI-TECH\models\
7. Extract llama.cpp to AI-TECH\llama\
8. Copy tools + drivers.
9. Disable Secure Boot in BIOS if installing Live Windows (or sign drivers).
10. On Live Windows: Create shortcut on Desktop -> Start-AI-Technician.bat
    Place in Shell:Startup for auto-launch: C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

## Boot Modes
### Mode A - Emergency from Windows Setup (no Live Windows needed)
1. Boot from USB -> Windows Setup screen
2. Press Shift+F10
3. Type: D:\AI-TECH\Start-AI-Technician.bat
4. AI starts in console. Works but slower.

### Mode B - Full Live Windows (recommended for 4GB)
1. Boot from USB -> choose "Windows To Go" / Live Windows partition
2. AI auto-starts on Desktop
3. Chat in English

### Mode C - Normal Windows installed (test lab)
1. Boot normal Windows (internet OFF)
2. Run AI-TECH\Start-AI-Technician.bat
3. Must work fully offline

## RAM Logic
- Free RAM < 2.5GB -> force 1.5B model (max 1.2GB RAM)
- Free RAM >= 2.5GB -> use 3B model
- ctx-size = 2048, threads = 2, parallel = 1 (tuned for 4GB)
- Expected speed: 1.5B = 8-12 t/s, 3B = 5-8 t/s on i3

## Safety
- AI never runs repair without your YES
- Repair creates registry backup + restore point first
- Logs in AI-TECH\logs\agent.log
- All servers bound to 127.0.0.1 only - no LAN exposure

## Offline Test
1. Disconnect Wi-Fi, Ethernet, phone hotspot. Airplane mode ON.
2. Boot USB.
3. Run agent.
4. Chat: "PC slow and blue screen 0x0000007F, disk makes clicking noise"
5. AI should call get_disk_smart, get_recent_errors
6. AI should explain and ask for YES before any repair.

## Troubleshooting
- llama-server not starting: Check llama\*.dll next to exe, need MSVC++ Redist installed on Live Windows (offline add to WinPE).
- Model loads but no answer: Check logs, port 8080 blocked by firewall, restart.
- SFC/DISM fails in Live/WinPE: Those need running Windows, not Setup. Use Mode B.
- Driver missing offline: Add drivers\ to Live Windows Device Manager manually.
- Very slow on 4GB: Close browser, force small model: Start-AI-Technician.bat -ForceSmall (via ps1 param)

## Update / Swap Model
Just replace .gguf file in models\ with same name. No rebuild needed.
