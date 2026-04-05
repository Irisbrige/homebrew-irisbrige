# Linux 部署说明

[English](./linux.md)

本文说明如何在 Linux 上部署 `irisbrige-edge` 并使用 `systemd` 配置自动启动。

包含两种方式：

1. 使用仓库内的安装脚本自动部署。
2. 不使用脚本，手动一步一步部署。

## 前提条件

- 操作系统为 Linux。
- 系统使用 `systemd`。
- 已安装 `curl`、`tar`、`systemctl`。
- 具备 `root` 或 `sudo` 权限。

## 方式一：使用脚本自动部署

安装脚本路径：

```bash
scripts/install-irisbrige-edge-linux.sh
```

### 1. 获取脚本

如果你已经在仓库目录中，可以直接使用：

```bash
cd /path/to/homebrew-irisbrige
chmod +x ./scripts/install-irisbrige-edge-linux.sh
```

### 2. 执行安装

直接执行：

```bash
sudo ./scripts/install-irisbrige-edge-linux.sh
```

脚本会自动完成以下操作：

- 判断当前架构是 `amd64` 还是 `arm64`
- 通过 GitHub `releases/latest` 获取最新版本标签
- 按最新版本和当前架构拼接下载地址
- 下载并解压 `irisbrige-edge`
- 安装到 `/usr/local/bin/irisbrige-edge`
- 生成 `systemd` 服务文件
- 执行 `systemctl daemon-reload`
- 执行 `systemctl enable irisbrige-edge`
- 启动或重启服务

### 3. 默认安装位置

- 二进制文件：`/usr/local/bin/irisbrige-edge`
- systemd 服务文件：`/etc/systemd/system/irisbrige-edge.service`

### 4. 默认运行用户

脚本对运行用户的处理规则如下：

- 如果显式传入了 `SERVICE_USER`，则使用该用户
- 如果通过 `sudo` 执行，默认使用 `SUDO_USER`
- 如果直接以 `root` 执行，默认使用 `root`

例如：

```bash
sudo SERVICE_USER=appuser ./scripts/install-irisbrige-edge-linux.sh
```

### 5. 常见可覆盖变量

例如：

```bash
sudo SERVICE_USER=appuser INSTALL_DIR=/usr/local/bin ./scripts/install-irisbrige-edge-linux.sh
```

支持的变量：

- `SERVICE_USER`
- `INSTALL_DIR`
- `SERVICE_FILE`
- `REPOSITORY`

### 6. 如需额外环境变量

当前脚本不会创建单独的环境变量文件。

如果 `irisbrige-edge` 运行时需要额外环境变量，建议直接编辑 systemd 服务文件：

```bash
sudo vi /etc/systemd/system/irisbrige-edge.service
```

在 `[Service]` 段中增加例如：

```dotenv
Environment=OPENAI_API_KEY=your-token
```

修改后执行：

```bash
sudo systemctl daemon-reload
sudo systemctl restart irisbrige-edge
```

### 7. 查看服务状态和日志

查看服务状态：

```bash
systemctl status irisbrige-edge --no-pager
```

实时查看日志：

```bash
journalctl -u irisbrige-edge -f
```

### 8. 常见管理命令

启动：

```bash
sudo systemctl start irisbrige-edge
```

停止：

```bash
sudo systemctl stop irisbrige-edge
```

重启：

```bash
sudo systemctl restart irisbrige-edge
```

设置开机自启：

```bash
sudo systemctl enable irisbrige-edge
```

取消开机自启：

```bash
sudo systemctl disable irisbrige-edge
```

## 方式二：不使用脚本，手动部署

以下步骤与脚本逻辑一致，但全部手动执行。

### 1. 确认架构

```bash
uname -m
```

架构映射规则：

- `x86_64` 或 `amd64` 对应发布资产后缀 `amd64`
- `aarch64` 或 `arm64` 对应发布资产后缀 `arm64`

可以直接用下面的命令得到下载架构名：

```bash
case "$(uname -m)" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

echo "$ARCH"
```

### 2. 获取最新版本标签

```bash
LATEST_URL="$(curl -fsSL --location --retry 3 --output /dev/null --write-out '%{url_effective}' https://github.com/Irisbrige/homebrew-irisbrige/releases/latest)"
RELEASE_TAG="${LATEST_URL##*/}"
RELEASE_VERSION="${RELEASE_TAG#v}"

echo "$RELEASE_TAG"
```

例如当前可能得到：

```bash
v0.6.0
```

### 3. 拼接下载地址

```bash
DOWNLOAD_URL="https://github.com/Irisbrige/homebrew-irisbrige/releases/download/${RELEASE_TAG}/irisbrige-edge_${RELEASE_VERSION}_linux_${ARCH}.tar.gz"

echo "$DOWNLOAD_URL"
```

### 4. 下载并解压

```bash
TMP_DIR="$(mktemp -d)"
ARCHIVE_PATH="${TMP_DIR}/irisbrige-edge.tar.gz"

curl -fL --retry 3 -o "${ARCHIVE_PATH}" "${DOWNLOAD_URL}"
tar -xzf "${ARCHIVE_PATH}" -C "${TMP_DIR}"
```

如果发布包内带有 macOS 扩展头，Linux 上解压时出现 `Ignoring unknown extended header keyword` 告警通常不影响使用。

### 5. 安装二进制

```bash
sudo install -d /usr/local/bin
sudo install -m 0755 "${TMP_DIR}/irisbrige-edge" /usr/local/bin/irisbrige-edge
```

验证：

```bash
/usr/local/bin/irisbrige-edge --help
```

### 6. 选择服务运行用户

以 `root` 为例：

```bash
APP_USER=root
APP_GROUP=root
APP_HOME=/root
```

如果你希望使用普通用户，例如 `appuser`：

```bash
APP_USER=appuser
APP_GROUP="$(id -gn "${APP_USER}")"
APP_HOME="$(getent passwd "${APP_USER}" | awk -F: '{print $6}')"
```

确认该用户的 home 目录存在：

```bash
test -d "${APP_HOME}"
```

### 7. 创建 systemd 服务文件

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

如果需要额外环境变量，可以在 `[Service]` 段中继续增加：

```dotenv
Environment=OPENAI_API_KEY=your-token
```

### 8. 重新加载 systemd 并启动服务

```bash
sudo systemctl daemon-reload
sudo systemctl enable irisbrige-edge
sudo systemctl start irisbrige-edge
```

如果服务已经存在并且你修改了配置，可以改为：

```bash
sudo systemctl daemon-reload
sudo systemctl restart irisbrige-edge
```

### 9. 检查服务是否正常运行

查看状态：

```bash
systemctl status irisbrige-edge --no-pager
```

查看日志：

```bash
journalctl -u irisbrige-edge -f
```

### 10. 清理临时文件

```bash
rm -rf "${TMP_DIR}"
```

## 故障排查

### 服务启动失败

优先查看：

```bash
systemctl status irisbrige-edge --no-pager
journalctl -u irisbrige-edge -n 100 --no-pager
```

### 提示找不到二进制

检查文件是否存在且可执行：

```bash
ls -l /usr/local/bin/irisbrige-edge
```

### 提示权限不足

确认安装、写入 `/etc/systemd/system`、`systemctl enable` 和 `systemctl start` 都使用了 `sudo` 或 root 权限。

### 服务需要额外环境变量

直接编辑服务文件：

```bash
sudo vi /etc/systemd/system/irisbrige-edge.service
```

在 `[Service]` 段添加 `Environment=KEY=value`，然后执行：

```bash
sudo systemctl daemon-reload
sudo systemctl restart irisbrige-edge
```

也可以使用：

```bash
sudo systemctl edit irisbrige-edge
```
