# 04 设备权限与 USB 验证

## 加入 video 组

RealSense 通过 `/dev/video*` 设备节点访问,默认权限 `crw-rw---- root:video`。用户需加入 `video` 组:

```bash
sudo usermod -aG video $USER
```

**生效需新登录会话**:退出当前 SSH 重连,或重启。

验证:

```bash
groups | tr ' ' '\n' | grep video
```

应输出 `video`。

## USB 端口验证

将 RealSense 连接 Pi **蓝色 USB 3.0** 端口,执行:

```bash
lsusb | grep -i intel
lsusb -t
```

预期:

```
Bus 002 Device 003: ID 8086:0b3a Intel Corp. Intel(R) RealSense(TM) Depth Camera 435i
/:  Bus 002.Port 001: Dev 001, ..., 5000M
    |__ Port 001: Dev 003, ..., 5000M
```

**关键**:RealSense 必须挂在 **5000M** 总线。若挂 480M,IMU 不可用。

## 链路联调

启动 RealSense ROS 节点:

```bash
ros2 launch realsense2_camera rs_launch.py \
    enable_color:=true \
    enable_depth:=true \
    align_depth.enable:=true \
    rgb_camera.color_profile:=640x480x30 \
    depth_module.depth_profile:=480x270x30
```

另一终端查看话题与频率:

```bash
ros2 topic list | grep camera
ros2 topic hz /camera/camera/color/image_raw
ros2 topic hz /camera/camera/aligned_depth_to_color/image_raw
```

应见 ~30 Hz。Ctrl+C 终止节点。

## 验证 camera_info 标定数据

```bash
ros2 topic echo /camera/camera/color/camera_info --once
```

应见非零的 `k`(内参矩阵)、`d`(畸变系数)。
