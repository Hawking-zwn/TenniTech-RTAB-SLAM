# 06 远程可视化

## 方案对比

| 方案 | 协议 | 性能 | 适用 |
|---|---|---|---|
| Foxglove Studio + Bridge | WebSocket | 流畅 | 推荐,主用 |
| X11 转发 RViz2 / rqt_image_view | X11 | 3D 卡顿,2D 流畅 | 备选 |
| 笔记本本地 ROS 2 + DDS | UDP 多播 | 最快 | 笔记本需装 ROS 2,校园网常隔离 |

## Foxglove Studio(推荐)

### Pi 端:启动 Bridge

```bash
ros2 launch foxglove_bridge foxglove_bridge_launch.xml
```

默认监听 `0.0.0.0:8765`。验证:

```bash
ss -tlnp | grep 8765
```

### 笔记本端:安装 Studio

下载:<https://foxglove.dev/download>

启动后选 `Open Connection` → `Foxglove WebSocket`,URL:

```
ws://<pi-ip>:8765
```

### 推荐面板配置

| 面板类型 | 关联话题 | 用途 |
|---|---|---|
| Image | `/camera/camera/color/image_raw` | RGB 实时图 |
| 3D | `/rtabmap/cloud_map` | 3D 点云地图 |
| 3D(同上) | `/rtabmap/odom` | 相机轨迹 |
| Map | `/rtabmap/map` | 2D 占据栅格 |
| Indicator | `/rtabmap/info` | 实时状态 |

3D 面板 Fixed Frame 设为 `map`。

## X11 转发(备选)

### Windows 端要求

MobaXterm(内置 X Server)运行,自动监听 6000 端口。

PowerShell 设置 DISPLAY 并使用 `-Y`:

```powershell
$env:DISPLAY = "localhost:0.0"
ssh -Y z@<pi-ip>
```

### Pi 端启动 GUI

实时 RGB:

```bash
ros2 run rqt_image_view rqt_image_view /camera/camera/color/image_raw
```

RViz2(3D 卡顿明显):

```bash
rviz2 -d /opt/ros/jazzy/share/rtabmap_launch/launch/config/rgbd.rviz
```

## Pi 端 Foxglove Bridge 开机自启(可选)

`/etc/systemd/system/foxglove-bridge.service`:

```ini
[Unit]
Description=Foxglove Bridge
After=network-online.target

[Service]
Type=simple
User=z
ExecStart=/bin/bash -lc "source /opt/ros/jazzy/setup.bash && ros2 launch foxglove_bridge foxglove_bridge_launch.xml"
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

启用:

```bash
sudo systemctl enable --now foxglove-bridge
sudo systemctl status foxglove-bridge
```
