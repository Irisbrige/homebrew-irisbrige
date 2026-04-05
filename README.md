# Irisbrige Edge

[中文说明](./README_CN.md)

`homebrew-irisbrige` provides installation and deployment entry points for `irisbrige-edge` across supported platforms.

## Platform Guide

- `macOS`: install and manage the service with Homebrew.
- `Linux`: deploy with the included script or manually, then manage with `systemd`.
- `Windows`: this repository does not currently provide install or service management instructions.

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
- The service runs `irisbrige-edge server`
- The runtime expects the `codex` CLI to be available on `PATH`

## Linux

Linux deployment is documented separately. The Linux guide includes:

- automatic deployment with the repository shell script
- manual deployment without the script, including `systemd` setup

See:

- [Linux Deployment Guide](./linux.md)

## Repository Contents

- [Formula/irisbrige.rb](./Formula/irisbrige.rb): Homebrew formula for macOS
- [scripts/install-irisbrige-edge-linux.sh](./scripts/install-irisbrige-edge-linux.sh): automated Linux deployment script
- [linux.md](./linux.md): detailed Linux deployment guide
