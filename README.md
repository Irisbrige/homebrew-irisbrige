# Irisbrige Edge

[中文说明](./README_CN.md)

`homebrew-irisbrige` provides installation and deployment entry points for `irisbrige-edge` across supported platforms.

## Contents

- [Platform Guide](#platform-guide)
- [macOS](#macos)
- [Linux](#linux)
- [Windows](#windows)
- [Repository Contents](#repository-contents)

<a id="platform-guide"></a>
## Platform Guide

- `macOS`: install and manage the service with Homebrew.
- `Linux`: deploy with the included script or manually, then manage with `systemd`.
- `Windows`: deploy with the included PowerShell installer or manually with WinSW.

<a id="macos"></a>
## macOS

Supports both Apple Silicon and Intel Macs.

1. Add the tap:

```bash
brew tap Irisbrige/irisbrige
```

2. Install:

```bash
brew install irisbrige
```

3. Start the background service:

```bash
brew services start irisbrige
```

4. Check service status:

```bash
brew services list | grep irisbrige
```

5. View logs:

```bash
tail -f "$(brew --prefix)/var/log/irisbrige.log"
```

Notes:

- The installed executable is `irisbrige-edge`
- The service starts `irisbrige-edge server` through a Homebrew-installed wrapper
- The runtime expects the `codex` CLI to be available on `PATH`

### Service environment

`brew services` starts `irisbrige-edge` under `launchd`. It does not inherit environment variables from your interactive shell startup files such as `.zshrc` or `.bashrc`.

Instead of relying on shell environment inheritance, the background service uses one dedicated editable file:

```bash
~/.config/irisbrige-edge/service.env
```

You can create and edit that file directly:

```bash
mkdir -p ~/.config/irisbrige-edge
cat > ~/.config/irisbrige-edge/service.env <<'EOF'
MY_PROVIDER_API_KEY=replace-me
MY_CUSTOM_BASE_URL=https://example.com
IRISBRIGE_ENV_CHECK=service-ready
EOF
```

If you prefer, the service wrapper also creates this file with commented examples on first start when it is missing.

The wrapper loads this file before it starts `irisbrige-edge server`. The wrapper also preserves Homebrew's service `PATH`, so the `codex` CLI remains discoverable even if you add more variables here.

After changing the file, restart the service:

```bash
brew services restart irisbrige
```

If you want the wrapper to create the file template for you, start or restart the service once:

```bash
brew services start irisbrige
```

To verify that the editable env file was created or reloaded, check the service log for the wrapper message:

```bash
tail -n 20 "$(brew --prefix)/var/log/irisbrige.log"
```

You should see a line similar to one of these:

```text
irisbrige-edge service: created editable env file at /Users/you/.config/irisbrige-edge/service.env
irisbrige-edge service: loaded environment from /Users/you/.config/irisbrige-edge/service.env
```

To verify that a specific non-secret variable reached the running service process:

```bash
PID="$(launchctl print gui/$(id -u)/homebrew.mxcl.irisbrige | awk '/pid = / {print $3; exit}')"
ps eww -p "$PID" | grep -F 'IRISBRIGE_ENV_CHECK=service-ready'
```

<a id="linux"></a>
## Linux

Linux deployment is documented separately. The Linux guide includes:

- automatic deployment with the repository shell script
- manual deployment without the script, including `systemd` setup

See:

- [Linux Deployment Guide](./linux.md)

<a id="windows"></a>
## Windows

Windows deployment is documented separately. The Windows guide includes:

- automatic deployment with the repository PowerShell installer
- manual deployment with WinSW

See:

- [Windows Deployment Guide](./windows.md)

<a id="repository-contents"></a>
## Repository Contents

- [Formula/irisbrige.rb](./Formula/irisbrige.rb): Homebrew formula for macOS
- [scripts/install-irisbrige-edge-linux.sh](./scripts/install-irisbrige-edge-linux.sh): automated Linux deployment script
- [scripts/uninstall-irisbrige-edge-linux.sh](./scripts/uninstall-irisbrige-edge-linux.sh): Linux uninstaller script
- [scripts/install-irisbrige-edge-windows.ps1](./scripts/install-irisbrige-edge-windows.ps1): automated Windows deployment script
- [scripts/uninstall-irisbrige-edge-windows.ps1](./scripts/uninstall-irisbrige-edge-windows.ps1): Windows uninstaller script
- [linux.md](./linux.md): detailed Linux deployment guide
- [windows.md](./windows.md): detailed Windows deployment guide
