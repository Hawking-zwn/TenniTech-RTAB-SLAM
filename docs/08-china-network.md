# 08 国内网络配置

## apt 镜像(Ubuntu 24.04)

编辑 `/etc/apt/sources.list.d/ubuntu.sources`,替换为清华镜像:

```yaml
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

更新:

```bash
sudo apt update
```

## pip 镜像

```bash
mkdir -p ~/.pip
cat > ~/.pip/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
```

## ROS 2 apt 镜像(可选)

ROS 2 官方源 `packages.ros.org` 国内访问较慢,可换中科大镜像。参考 <https://mirrors.ustc.edu.cn/help/ros2.html>。

## GitHub 访问

### 方案 A:Watt Toolkit(Steam++)

下载:<https://steampp.net/>

**已知问题**:Watt Toolkit 的 "GitHub 加速" 在部分网络下会失败回退,将 GitHub 域名写入 hosts 指向 `127.0.0.1`,导致 git/curl 完全无法访问。

**排查**:

```powershell
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String github
```

**修复**:右键托盘 Watt Toolkit 图标 → 退出。hosts 自动恢复,git push 即可正常工作。

### 方案 B:ghfast.top 镜像(仅 clone)

```bash
git clone https://ghfast.top/https://github.com/<user>/<repo>.git
```

**不支持 push**,push 必须直连 github.com 或走代理。

### 方案 C:git 代理配置

若使用本地 HTTP / SOCKS 代理:

```bash
git config --global http.proxy http://127.0.0.1:<port>
git config --global https.proxy http://127.0.0.1:<port>
```

撤销:

```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```

某些代理在 GFW 强化期可能仍触发 TLS 错误。此时切回方案 A。

### Windows Git 在非系统盘的 ownership 警告

```
fatal: detected dubious ownership in repository at 'F:/dev/...'
```

添加白名单:

```bash
git config --global --add safe.directory F:/dev/<repo>
```

## Foxglove Studio 下载

国内访问 `foxglove.dev` 较慢。可使用代理或镜像下载安装包。安装后正常使用不需要联网(本地连接 Pi 即可)。
