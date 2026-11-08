Windows install media for Crouton Alpha - keep your existing Windows 11 installer.
Do NOT delete EFI/ and sources/ if present.
If you are cloning this repo to a USB, copy this folder structure alongside AI-TECH.
Two partitions recommended (64GB USB):
  - Partition 1: Windows 11 installer (existing)
  - Partition 2: Live Windows To Go / Tiny11 (20GB)
AI-TECH runs from either disk letter (D:, E:, F: etc) - it auto-detects via %~dp0.
Boot modes: Setup Shift+F10 (emergency) or Live Windows desktop (recommended).
