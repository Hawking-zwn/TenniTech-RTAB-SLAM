# 05 录制-回放-建图工作流

## 设计

采用 record-once / replay-many 模式,将数据采集与算法解耦:

| 阶段 | 输入 | 输出 |
|---|---|---|
| Phase 1 录制 | 实时 RealSense 数据流 | ROS 2 bag(`bags/` 下) |
| Phase 2 回放建图 | bag | RTAB-Map 数据库 `.db`(`maps/` 下) |
| Phase 3 查看 | `.db` | Qt GUI 离线浏览 |

## 目录结构

```
~/slam_record_ws/
├── scripts/                # 三个核心脚本
│   ├── 1_record.sh
│   ├── 2_replay_and_map.sh
│   └── 3_inspect.sh
├── bags/                   # 录制输出
├── maps/                   # 建图数据库
└── logs/                   # 节点日志
```

部署:

```bash
mkdir -p ~/slam_record_ws/{scripts,bags,maps,logs}
```

从仓库复制脚本到 Pi:

```bash
scp <repo>/scripts/*.sh z@<pi-ip>:~/slam_record_ws/scripts/
ssh z@<pi-ip> "chmod +x ~/slam_record_ws/scripts/*.sh"
```

## Phase 1: 录制 bag

```bash
~/slam_record_ws/scripts/1_record.sh <场景名>
# Ctrl+C 停止
```

脚本流程:
1. 启动 `realsense2_camera` 节点(USB 2.0 安全档位)
2. 等待 6 秒确认话题就绪
3. `ros2 bag record` 录制以下话题:
   - `/camera/camera/color/image_raw`
   - `/camera/camera/color/camera_info`
   - `/camera/camera/aligned_depth_to_color/image_raw`
   - `/camera/camera/aligned_depth_to_color/camera_info`
   - `/tf`
   - `/tf_static`
4. Ctrl+C 触发 trap,停止 record 与 RealSense 节点,自动执行 `ros2 bag info` 验证

输出:`~/slam_record_ws/bags/<场景名>_<YYYYMMDD_HHMMSS>/`

## Phase 2: 回放 + 建图

```bash
~/slam_record_ws/scripts/2_replay_and_map.sh <bag路径> [运行名] [额外参数]
```

示例:

```bash
~/slam_record_ws/scripts/2_replay_and_map.sh \
    ~/slam_record_ws/bags/lab_view_20260524_183911 run1
```

输出:`~/slam_record_ws/maps/<bag名>_<运行名>.db`

完成后打印 odom quality 统计(avg / min / max)。

## Phase 3: 离线查看

```bash
~/slam_record_ws/scripts/3_inspect.sh <db路径>
```

需 X11 转发(`ssh -Y`)。详见 [06 远程可视化](06-remote-viz.md)。

## 调参迭代

同一 bag 可多次回放,通过命名区分:

```bash
~/slam_record_ws/scripts/2_replay_and_map.sh \
    ~/slam_record_ws/bags/lab_view_20260524_183911 run2_loose \
    'rtabmap_args:="--delete_db_on_start --Vis/MinInliers 10"'
```

常用调优参数:

| 参数 | 默认 | 用途 |
|---|---|---|
| `--Vis/MinInliers` | 20 | 调低至 10 可容忍低纹理场景 |
| `--Vis/CorGuessWinSize` | 40 | 调大提升快速运动跟踪 |
| `--Odom/ResetCountdown` | 0 | 设为 1 在里程计失败时自动复位 |

## 数据集质量准则

录制时遵循以下约束以保证 odom quality > 100:

- 平移速度 ≤ 30 cm/s
- 旋转速度 ≤ 30 °/s
- 避免长时间面对纯白墙、玻璃、强反光面
- 单次录制 1–3 分钟
