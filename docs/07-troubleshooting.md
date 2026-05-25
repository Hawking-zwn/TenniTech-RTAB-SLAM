# 07 故障排查

## SSH

### `Connection timed out`

TCP 不通。Pi IP 已变化(校园网动态 IP)。

在 Pi 本地获取新 IP:

```bash
ip a | grep "inet "
```

### `Connection refused`

TCP 通但 SSH 服务未启动。检查并启动:

```bash
sudo systemctl status ssh
sudo systemctl enable --now ssh
```

### `Permission denied (publickey,password)`

SSH key 未配置或公钥未上传。参考 [02 系统准备](02-os-setup.md)。

## RealSense

### `Permission denied: /dev/video*`

用户未加入 `video` 组:

```bash
sudo usermod -aG video $USER
# 退出 SSH 重连
```

### `lsusb -t` 显示 480M 而非 5000M

线材或端口非 USB 3.0。检查:
- 数据线 A 头内塑料片为 **蓝色**
- 插入 Pi **蓝色** USB 端口

后果:IMU 不可用,RGB 限 640×480,Depth 限 480×270。

### `Reduced performance is expected`

USB 2.0 降级模式。同上修复。

## RTAB-Map

### `Did not receive data since 5 seconds`

排查清单:

| 检查项 | 命令 |
|---|---|
| 话题是否在发布 | `ros2 topic hz /camera/camera/color/image_raw` |
| QoS 是否兼容 | `ros2 topic info /camera/camera/color/camera_info --verbose` |
| 启动参数 qos 是否对齐 | 通常应为 `qos:=1` (RELIABLE) |

### `Not enough inliers` / `Odom: quality=0`

视觉里程计失败,通常因运动过快或场景纹理不足。措施:
- 重新录制,平移 ≤ 30 cm/s,旋转 ≤ 30 °/s
- 或降低 `--Vis/MinInliers`(参考 [05 工作流](05-record-replay.md))

### `Detected jump back in time`

bag 时间戳与系统时钟冲突。措施:
- 启动 RTAB-Map 时去掉 `use_sim_time:=true`
- bag 播放不加 `--clock`

(本仓库 `2_replay_and_map.sh` 已正确处理实时场景与 bag 回放场景,通常不会触发)

## Git / GitHub

### `TLS connect error: unexpected eof while reading`

GFW 干扰 TLS 握手。检查 hosts 污染:

```powershell
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String github
```

若出现 `127.0.0.1 github.com` 等条目,为 Watt Toolkit / Steam++ 加速失败导致 hosts 污染。退出该软件,hosts 自动恢复,再 push。参考 [08 国内网络配置](08-china-network.md)。

### `Failed to connect to github.com port 443 after N ms`

同上,hosts 被指向 127.0.0.1 导致 TCP 不通。

### `fatal: detected dubious ownership`

非系统盘(NTFS / exFAT)文件系统不记录 ownership。添加白名单:

```bash
git config --global --add safe.directory <repo-path>
```

## Foxglove

### Studio 显示 "Disconnected"

- 检查 Pi 端 bridge 是否运行:`ss -tlnp | grep 8765`
- 检查笔记本与 Pi 是否在同网段:`ping <pi-ip>`
- 校园网客户端隔离会阻断 8765 端口
