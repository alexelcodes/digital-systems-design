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

## Custom fixes for 2024.2

_(Apply these only if the repository doesn’t yet include native support for 2024.2.)_

See **PR #68** for example changes:
<https://github.com/ichi4096/vivado-on-silicon-mac/pull/68/files>

1. **Install config**  
   Create `scripts/install_configs/202420.txt`. This is just a copy of
   `202410.txt` with a new name (no internal edits needed).

2. **Web‑installer hash**  
   In `scripts/hashes.sh` add:
   ```bash
   ["20c806793b3ea8d79273d5138fbd195f"]=202420
   ```
   > The MD5 must match the official hash shown on the AMD/Xilinx download page.

### Notes

- The **Custom fixes for 2024.2** section is only for Vivado **2024.2** (until upstream adds support).
- Future versions may require adding a new install config and hash in the same way.

---

## Troubleshooting

### Synthesis crash (RAM / Swap)

Vivado may crash during **synthesis** if Docker resource limits are too low.
This is usually related to insufficient RAM or Swap allocation.
Adjust these values in Docker Desktop if you encounter such issues.

### Fixing incomplete LXDE startup (no icons or wallpaper)

If, after starting the Vivado Docker container, the VNC window shows no desktop background or icons, follow these steps.

1. Go to the project folder

   ```bash
   cd ~/Downloads/vivado-on-silicon-mac-main
   ```

2. Create a startup script for the desktop and panel

   ```bash
   mkdir -p bin
   cat > bin/start-pcmanfm.sh <<'EOF'
   #!/bin/sh
   LOG=/tmp/pcmanfm-start.log
   {
    echo "=== start $(date) ==="
    export DISPLAY="${DISPLAY:-:1}"

    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax)" 2>/dev/null && echo "dbus-launch ok"
    fi

    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}"
    mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

    sleep 2
    pcmanfm --desktop --profile LXDE & echo "pcmanfm started $!"
    lxpanel  --profile LXDE & echo "lxpanel started $!"
    echo "=== done ==="
   } >> "$LOG" 2>&1
   EOF
   chmod +x bin/start-pcmanfm.sh
   ```

3. Create an LXDE autostart entry

   ```bash
   mkdir -p .config/lxsession/LXDE
   cat > .config/lxsession/LXDE/autostart <<'EOF'
   @/home/user/bin/start-pcmanfm.sh
   EOF
   ```

4. Restart the container

   ```bash
   ./scripts/start_container.sh
   ```

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
