# TenniTech-RTAB-SLAM

> 树莓派 5 + Intel RealSense D435i 上的 RTAB-Map RGB-D 视觉 SLAM 完整部署手册

本仓库记录了从**烧录操作系统**到**录制 bag 离线建图**的全流程,目标是让任何拿到同款硬件的同学都能照着 1:1 复刻。

---

## 硬件与软件版本

| 组件 | 版本 / 型号 |
|---|---|
| 主板 | Raspberry Pi 5 (8GB) |
| 深度相机 | Intel RealSense D435i |
| 操作系统 | Ubuntu 24.04 LTS Desktop (aarch64) |
| ROS | ROS 2 Jazzy Jalisco |
| SLAM 算法 | RTAB-Map (ros-jazzy-rtabmap) |
| 远程可视化 | Foxglove Studio + foxglove_bridge |

> 为什么选这套:Pi 5 + Ubuntu 24.04 + Jazzy 是树莓派官方唯一的 Tier 1 组合,Pi 5 不支持 22.04 + Humble,踩坑过的人都知道。详见 [`docs/02-os-setup.md`](docs/02-os-setup.md)。

---

## 文档导航

按推荐阅读顺序排列。新同学**从 01 看到 07**,边看边动手,大约半天到一天可以打通整个链路。

| # | 章节 | 内容 |
|---|---|---|
| 01 | [硬件清单与采购](docs/01-hardware.md) | 元器件清单、USB 3.0 SuperSpeed 线避坑、电源选型 |
| 02 | [系统准备](docs/02-os-setup.md) | Ubuntu 24.04 烧录、首次启动、SSH 配置 |
| 03 | [ROS 2 与 RTAB-Map 安装](docs/03-ros2-install.md) | apt 源、ros-jazzy-desktop、RTAB-Map、RealSense ROS wrapper |
| 04 | [设备权限与 USB 验证](docs/04-permissions-usb.md) | video 组、USB 3.0 端口确认、lsusb -t 看协商速率 |
| 05 | [录制-回放-建图工作流](docs/05-record-replay.md) | 三脚本架构、bag 录制、回放建图、调参迭代 |
| 06 | [远程可视化](docs/06-remote-viz.md) | Foxglove Bridge + Studio、X11 转发(备用) |
| 07 | [故障排查](docs/07-troubleshooting.md) | IP 动态变化、camera_info 不发、odom quality 低等常见坑 |
| 08 | [国内网络配置](docs/08-china-network.md) | apt 镜像、pip 镜像、GitHub 代理、ghfast.top 加速 |

---

## 快速开始(老司机版)

> 假设你已经按 01–04 配好了系统,只想看脚本怎么用。

```bash
# 1. 录制一个 bag(场景名随便取)
~/slam_record_ws/scripts/1_record.sh kitchen
# Ctrl+C 停止

# 2. 回放 + 建图(自动生成 db)
~/slam_record_ws/scripts/2_replay_and_map.sh ~/slam_record_ws/bags/kitchen_<时间戳>

# 3. 看结果(需要 X11 转发,或用 Foxglove)
~/slam_record_ws/scripts/3_inspect.sh ~/slam_record_ws/maps/kitchen_<时间戳>_run1.db
```

三个脚本的源码在 [`scripts/`](scripts/),原理见 [docs/05](docs/05-record-replay.md)。

---

## 仓库结构

```
.
├── README.md              ← 你正在看的这份
├── LICENSE                ← MIT
├── .gitignore             ← 排除 bag/db/log 等大文件
├── docs/                  ← 8 篇分章文档
└── scripts/               ← Pi 上的 3 个工作流脚本(示例)
```

---

## 贡献

欢迎组内同学:
- 发现文档错误 → 提 [Issue](https://github.com/Hawking-zwn/TenniTech-RTAB-SLAM/issues)
- 想加新功能 / 改进 → fork → 改 → 提 Pull Request
- 想直接 push → 联系仓库 owner 加为 collaborator

---

## License

MIT — 见 [LICENSE](LICENSE) 文件。
