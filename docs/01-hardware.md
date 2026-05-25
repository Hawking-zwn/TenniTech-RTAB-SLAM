# 01 硬件清单与采购

## 物料清单

| 类别 | 型号 / 规格 | 备注 |
|---|---|---|
| 主板 | Raspberry Pi 5 Model B,**8GB** | 4GB 版可运行,但同时跑 RTAB-Map + Foxglove 内存紧张 |
| 电源 | 官方 27W USB-C PD | 非官方电源易掉电导致 SD 卡损坏 |
| 散热 | 官方 Active Cooler | 长时间 SLAM 不带散热会触发降频 |
| 存储 | microSD ≥ 32GB,U3/A2 等级 | SanDisk Extreme / Samsung EVO Plus |
| 深度相机 | Intel RealSense **D435i** | 仅 D435i 含 IMU;D435 / D415 可视觉 SLAM 但无惯性融合 |
| 数据线 | USB-C 转 USB-A **SuperSpeed (USB 3.0)** | A 头内塑料片为蓝色;USB 2.0 线导致 IMU 不可用且分辨率受限 |
| 显示 | HDMI 显示器(首次调试) | 后续可纯 SSH 远程 |

## USB 3.0 线材验证

将 RealSense 连接 Pi 后执行:

```bash
lsusb -t
```

需满足:RealSense 设备挂在 **5000M** 速率的总线上。

正常输出片段:

```
/:  Bus 002.Port 001: Dev 001, Class=root_hub, Driver=xhci-hcd/1p, 5000M
    |__ Port 001: Dev 002, ..., 5000M
```

若挂 480M(USB 2.0)总线,说明线材或端口非 USB 3.0,IMU 不可用,分辨率上限为 RGB 640×480 / Depth 480×270。

## Pi 5 USB 端口分布

| 颜色 | 协议 | 用途 |
|---|---|---|
| 蓝色 × 2 | USB 3.0 | 连接 RealSense |
| 黑色 × 2 | USB 2.0 | 键盘鼠标等低带宽设备 |
