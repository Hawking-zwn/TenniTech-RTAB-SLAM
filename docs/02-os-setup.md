# 02 系统准备

## 镜像选型

| 项 | 值 |
|---|---|
| 操作系统 | Ubuntu 24.04 LTS Desktop (aarch64) |
| 不可选 | Debian / Ubuntu 22.04 / Raspberry Pi OS |
| 后续 ROS 版本 | ROS 2 Jazzy Jalisco |

## 烧录

1. 下载 Raspberry Pi Imager:<https://www.raspberrypi.com/software/>
2. 选择:
   - **Device**: Raspberry Pi 5
   - **OS**: Other general-purpose OS → Ubuntu → Ubuntu Desktop 24.04 LTS (64-bit)
   - **Storage**: 目标 microSD
3. 点击齿轮(OS Customization)预设:
   - Hostname: `z-desktop`
   - Enable SSH: 是(use password authentication)
   - Username / Password: `z` / `<password>`
   - WiFi: SSID + Password + Country
   - Locale: `Asia/Shanghai` + `en_US.UTF-8`
4. 写入完成,插卡通电

## 首次启动

桌面环境约 90 秒就绪。在 Pi 终端执行:

```bash
ip a | grep "inet "
hostname
```

记录 IP(校园网为动态分配,每次重连可能变化)。

## 笔记本端 SSH 接入

### 测试连接

```powershell
ssh z@<pi-ip>
```

首次连接确认主机指纹后输入密码登录。

### 配置免密登录

笔记本若无 SSH key:

```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\id_ed25519" -N ""
```

上传公钥(需输一次密码):

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh z@<pi-ip> "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

验证:

```powershell
ssh z@<pi-ip> "hostname"
```

应直接返回 `z-desktop` 且不再提示密码。
