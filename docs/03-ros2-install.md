# 03 ROS 2 与 RTAB-Map 安装

## 前置条件

- 已完成 [02 系统准备](02-os-setup.md)
- 国内网络参考 [08 国内网络配置](08-china-network.md) 切换镜像

## 安装 ROS 2 Jazzy

```bash
# 1. 启用 universe 仓库
sudo apt update && sudo apt install -y software-properties-common
sudo add-apt-repository universe

# 2. 添加 ROS 2 GPG key
sudo apt update && sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg

# 3. 添加 ROS 2 apt source
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# 4. 安装 ROS 2 Desktop
sudo apt update
sudo apt install -y ros-jazzy-desktop
```

## 安装 RTAB-Map、RealSense、Foxglove Bridge

```bash
sudo apt install -y \
    ros-jazzy-rtabmap \
    ros-jazzy-rtabmap-ros \
    ros-jazzy-realsense2-camera \
    ros-jazzy-foxglove-bridge
```

## 环境变量

```bash
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

## 验证

```bash
ros2 --version
ros2 pkg list | grep -E "rtabmap|realsense|foxglove"
```

预期输出:

```
ros2 cli version: ...
foxglove_bridge
realsense2_camera
realsense2_camera_msgs
realsense2_description
rtabmap
rtabmap_ros
```
