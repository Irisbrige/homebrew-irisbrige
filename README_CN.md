# Irisbrige Edge

[English](./README.md)

`homebrew-irisbrige` 提供了 `irisbrige-edge` 在不同平台上的安装和部署入口。

## 平台说明

- `macOS`：通过 Homebrew 安装和管理服务。
- `Linux`：通过仓库内脚本或手动方式部署，并使用 `systemd` 管理。
- `Windows`：当前仓库未提供安装和服务管理说明。

## macOS

适用于 Apple Silicon 和 Intel Mac。

1. 添加 tap：

```bash
brew tap Irisbrige/irisbrige
```

2. 安装：

```bash
brew install irisbrige
```

3. 启动后台服务：

```bash
brew services start irisbrige
```

4. 查看状态：

```bash
brew services list | grep irisbrige
```

5. 查看日志：

```bash
tail -f "$(brew --prefix)/var/log/irisbrige.log"
```

注意：

- 实际执行文件名为 `irisbrige-edge`
- 服务实际运行命令为 `irisbrige-edge server`
- 运行时要求 `codex` CLI 在 `PATH` 中可用

## Linux

Linux 部署说明单独放在文档中，包括：

- 使用仓库内 shell 脚本自动部署
- 不使用脚本时手动下载安装并配置 `systemd`

详细说明见：

- [Linux 部署文档](./linux_CN.md)

## 仓库内容

- [Formula/irisbrige.rb](./Formula/irisbrige.rb)：macOS Homebrew Formula
- [scripts/install-irisbrige-edge-linux.sh](./scripts/install-irisbrige-edge-linux.sh)：Linux 自动部署脚本
- [linux_CN.md](./linux_CN.md)：Linux 中文部署文档
