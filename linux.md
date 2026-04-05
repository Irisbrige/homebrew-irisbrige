# Linux Deployment Guide

[中文说明](./linux_CN.md)

This document explains how to deploy `irisbrige-edge` on Linux and manage it with `systemd`.

It covers two approaches:

1. Deploy automatically with the repository shell script.
2. Deploy manually without using the script.

## Prerequisites

- A Linux system.
- `systemd` is available.
- `curl`, `tar`, and `systemctl` are installed.
- You have `root` or `sudo` privileges.

## Option 1: Deploy with the Script

Script URL:

```bash
https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-linux.sh
```

### 1. Run the installer directly

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-linux.sh | sudo bash
```

The script automatically:

- detects whether the current machine is `amd64` or `arm64`
- resolves the latest GitHub release tag
- builds the download URL for the current architecture
- downloads and extracts `irisbrige-edge`
- installs the binary to `/usr/local/bin/irisbrige-edge`
- writes the `systemd` service file
- runs `systemctl daemon-reload`
- runs `systemctl enable irisbrige-edge`
- starts or restarts the service

### 2. Default install locations

- Binary: `/usr/local/bin/irisbrige-edge`
- systemd unit: `/etc/systemd/system/irisbrige-edge.service`

### 3. Default service user

The script chooses the service user as follows:

- if `SERVICE_USER` is set, that user is used
- if the script is run through `sudo`, it uses `SUDO_USER`
- otherwise it uses `root`

Example:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-linux.sh | \
  sudo env SERVICE_USER=appuser bash
```

### 4. Common override variables

Example:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/install-irisbrige-edge-linux.sh | \
  sudo env SERVICE_USER=appuser INSTALL_DIR=/usr/local/bin bash
```

Supported variables:

- `SERVICE_USER`
- `INSTALL_DIR`
- `SERVICE_FILE`
- `REPOSITORY`

### 5. Additional environment variables

The script does not create a separate environment file.

If `irisbrige-edge` needs extra environment variables, edit the systemd service file directly:

```bash
sudo vi /etc/systemd/system/irisbrige-edge.service
```

Add lines such as this under `[Service]`:

```dotenv
Environment=OPENAI_API_KEY=your-token
```

Then reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart irisbrige-edge
```

### 6. Status and logs

Check service status:

```bash
systemctl status irisbrige-edge --no-pager
```

Follow logs:

```bash
journalctl -u irisbrige-edge -f
```

### 7. Common management commands

Start:

```bash
sudo systemctl start irisbrige-edge
```

Stop:

```bash
sudo systemctl stop irisbrige-edge
```

Restart:

```bash
sudo systemctl restart irisbrige-edge
```

Enable at boot:

```bash
sudo systemctl enable irisbrige-edge
```

Disable at boot:

```bash
sudo systemctl disable irisbrige-edge
```

### 8. Uninstall with the script

Uninstaller URL:

```bash
https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-linux.sh
```

Run it directly from GitHub:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-linux.sh | sudo bash
```

Default behavior:

- stops the `systemd` service if it is running
- disables the service if it is installed
- removes `/etc/systemd/system/irisbrige-edge.service`
- removes `/usr/local/bin/irisbrige-edge`
- reloads `systemd`

## Option 2: Manual Deployment

These steps mirror the script logic, but everything is done manually.

### 1. Detect the architecture

```bash
uname -m
```

Architecture mapping:

- `x86_64` or `amd64` maps to release suffix `amd64`
- `aarch64` or `arm64` maps to release suffix `arm64`

You can resolve it with:

```bash
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

echo "$ARCH"
```

### 2. Resolve the latest release tag

```bash
LATEST_URL="$(curl -fsSL --location --retry 3 --output /dev/null --write-out '%{url_effective}' https://github.com/Irisbrige/homebrew-irisbrige/releases/latest)"
RELEASE_TAG="${LATEST_URL##*/}"
RELEASE_VERSION="${RELEASE_TAG#v}"

echo "$RELEASE_TAG"
```

Example output:

```bash
v0.7.0
```

### 3. Build the download URL

```bash
DOWNLOAD_URL="https://github.com/Irisbrige/homebrew-irisbrige/releases/download/${RELEASE_TAG}/irisbrige-edge_${RELEASE_VERSION}_linux_${ARCH}.tar.gz"

echo "$DOWNLOAD_URL"
```

### 4. Download and extract

```bash
TMP_DIR="$(mktemp -d)"
ARCHIVE_PATH="${TMP_DIR}/irisbrige-edge.tar.gz"

curl -fL --retry 3 -o "${ARCHIVE_PATH}" "${DOWNLOAD_URL}"
tar -xzf "${ARCHIVE_PATH}" -C "${TMP_DIR}"
```

If the archive contains macOS extended headers, Linux may print `Ignoring unknown extended header keyword`. That warning usually does not affect installation.

### 5. Install the binary

```bash
sudo install -d /usr/local/bin
sudo install -m 0755 "${TMP_DIR}/irisbrige-edge" /usr/local/bin/irisbrige-edge
```

Verify:

```bash
/usr/local/bin/irisbrige-edge --help
```

### 6. Choose the service user

Example with `root`:

```bash
APP_USER=root
APP_GROUP=root
APP_HOME=/root
```

If you want a regular user such as `appuser`:

```bash
APP_USER=appuser
APP_GROUP="$(id -gn "${APP_USER}")"
APP_HOME="$(getent passwd "${APP_USER}" | awk -F: '{print $6}')"
```

Confirm the home directory exists:

```bash
test -d "${APP_HOME}"
```

### 7. Create the systemd service

```bash
sudo tee /etc/systemd/system/irisbrige-edge.service >/dev/null <<EOF
[Unit]
Description=irisbrige-edge service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${APP_HOME}
Environment=HOME=${APP_HOME}
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${APP_HOME}/.local/bin:${APP_HOME}/bin
ExecStart=/usr/local/bin/irisbrige-edge server
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

If you need extra environment variables, add more `Environment=KEY=value` lines under `[Service]`.

### 8. Reload systemd and start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable irisbrige-edge
sudo systemctl start irisbrige-edge
```

If the service already exists and you changed its configuration:

```bash
sudo systemctl daemon-reload
sudo systemctl restart irisbrige-edge
```

### 9. Verify the service

Status:

```bash
systemctl status irisbrige-edge --no-pager
```

Logs:

```bash
journalctl -u irisbrige-edge -f
```

### 10. Clean up temporary files

```bash
rm -rf "${TMP_DIR}"
```

## Troubleshooting

### Service failed to start

Check:

```bash
systemctl status irisbrige-edge --no-pager
journalctl -u irisbrige-edge -n 100 --no-pager
```

### Binary not found

Verify the file exists and is executable:

```bash
ls -l /usr/local/bin/irisbrige-edge
```

### You want to remove the service completely

Use the uninstall script:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/Irisbrige/homebrew-irisbrige/refs/heads/main/scripts/uninstall-irisbrige-edge-linux.sh | sudo bash
```

### Permission denied

Make sure installation, writing `/etc/systemd/system`, `systemctl enable`, and `systemctl start` are all run with `sudo` or as `root`.

### Extra environment variables are required

Edit the service file directly:

```bash
sudo vi /etc/systemd/system/irisbrige-edge.service
```

Add `Environment=KEY=value` lines under `[Service]`, then run:

```bash
sudo systemctl daemon-reload
sudo systemctl restart irisbrige-edge
```

You can also use:

```bash
sudo systemctl edit irisbrige-edge
```
