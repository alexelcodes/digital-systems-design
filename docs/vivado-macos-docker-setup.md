# Running Vivado on macOS (Apple Silicon) via Docker and Rosetta

A concise, step‑by‑step note on installing and running **Vivado** inside the
[`vivado-on-silicon-mac`](https://github.com/ichi4096/vivado-on-silicon-mac) Docker environment on Apple Silicon Macs.

---

## Setup

### 1) Project location

Keep the repo folder `vivado-on-silicon-mac-main` in `~/Downloads/`.
Moving it elsewhere may cause the installer to fail (per the upstream scripts).

### 2) Download the installer

- Go to the [Xilinx Download Center](https://www.xilinx.com/support/download.html).
- Choose the required version: **Linux® self‑extracting web installer**.
- Registration with an AMD/Xilinx account is required.
- Keep your account credentials — you’ll need them during the installation inside the container.

### 3) Drag‑and‑drop prompt

When prompted, drag the installer binary directly into **Terminal** and press **Enter**.

### 4) Docker Desktop settings

- **General → Virtual Machine Options**
  - **Apple Virtualization Framework** — enabled by default
  - **Use Rosetta** for x86_64/amd64 emulation on Apple Silicon — enabled by default
- **Resources → Resource Allocation**
  - You may need to increase RAM and/or Swap if Vivado crashes during synthesis or runs slowly. The exact values depend on your system.

---

## Custom fixes for unsupported Vivado versions

If the upstream repository **doesn’t yet support the Vivado version you want**, you can usually enable it with small manual tweaks:

- Add a new install config under `scripts/install_configs/<new_version>.txt` (most often by copying an existing config with a new name from a nearby version).

- Add the installer checksum/version mapping in `scripts/hashes.sh` so the setup script can recognize that installer.
  > The MD5 must match the official hash shown on the AMD/Xilinx download page.

---

## Troubleshooting

### Synthesis crash (RAM / Swap)

Vivado may crash during **synthesis** if Docker resource limits are too low.
This is usually related to insufficient RAM or Swap allocation.
Adjust these values in Docker Desktop if you encounter such issues.

### Fixing incomplete LXDE startup (no icons or wallpaper)

In rare cases, LXDE may start without the desktop manager, resulting in a black background and missing icons.

This is not a Dockerfile issue.
The problem is usually related to how the LXDE session is started by TigerVNC.

If this happens, the fix should be applied in:

`scripts/linux_start.sh`

Typically the issue is caused by LXDE being started without a proper D-Bus session, which prevents pcmanfm and lxpanel from initializing correctly.

If your desktop shows icons and a panel, no action is required.

---

## Board files location

If you need the board definition files downloaded during setup (for example, for **PYNQ‑Z2**), they can be found at:

```bash
~/Downloads/vivado-on-silicon-mac-main/.Xilinx/Vivado/2024.2/xhub/board_store/xilinx_board_store/XilinxBoardStore/Vivado/2024.2/boards/TUL/pynq-z2/A.0
```

This directory contains `board.xml`, `preset.xml`, `part0_pins.xml`, `xitem.json`, and the board image `pynq_z2.jpg`.

---

## Usage

### Start Vivado container

```bash
~/Downloads/vivado-on-silicon-mac-main/scripts/start_container.sh
```

Stop with **Ctrl‑C** in the terminal or by logging out of the container.

### File sharing

Place files in the local `vivado-on-silicon-mac-main` folder. Inside Vivado, they appear under `/home/user`.
