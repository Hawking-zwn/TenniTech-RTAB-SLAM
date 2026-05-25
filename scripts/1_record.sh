#!/bin/bash
# Phase 1: Start RealSense and record a bag.
# Usage: ./1_record.sh <scene_name>
#
# Output: ~/slam_record_ws/bags/<scene>_<YYYYMMDD_HHMMSS>/

SCENE_NAME="${1:-unnamed}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
WORK_DIR="$HOME/slam_record_ws"
BAG_DIR="$WORK_DIR/bags/${SCENE_NAME}_${TIMESTAMP}"
LOG_DIR="$WORK_DIR/logs"
RS_LOG="$LOG_DIR/rs_${TIMESTAMP}.log"
mkdir -p "$LOG_DIR" "$WORK_DIR/bags"

source /opt/ros/jazzy/setup.bash

cleanup() {
    echo ""
    echo "==> Stopping recording and camera..."
    pkill -f "ros2 bag record" 2>/dev/null
    pkill -f realsense2_camera_node 2>/dev/null
    pkill -f "ros2 launch realsense2_camera" 2>/dev/null
    sleep 1
    if [ -d "$BAG_DIR" ]; then
        echo ""
        echo "==> Validating bag at $BAG_DIR ..."
        ros2 bag info "$BAG_DIR" 2>/dev/null || echo "(bag info failed)"
    fi
}
trap cleanup EXIT INT TERM

echo "==> Starting RealSense (USB 2.0 safe profile)..."
nohup ros2 launch realsense2_camera rs_launch.py \
    enable_depth:=true \
    enable_color:=true \
    enable_infra:=false \
    align_depth.enable:=true \
    rgb_camera.color_profile:=640x480x30 \
    depth_module.depth_profile:=480x270x30 \
    > "$RS_LOG" 2>&1 &

echo "==> Waiting 6s for camera to be ready..."
sleep 6

if ! ros2 topic list 2>/dev/null | grep -q "/camera/camera/color/image_raw"; then
    echo "ERROR: RealSense topics not found. See $RS_LOG"
    exit 1
fi

echo "==> Camera ready."
echo ""
echo "============================================================"
echo "  Recording to: $BAG_DIR"
echo "  Topics: color + aligned_depth + camera_info(x2) + tf + tf_static"
echo "  Press Ctrl+C to stop"
echo "============================================================"
echo ""

ros2 bag record \
    -o "$BAG_DIR" \
    /camera/camera/color/image_raw \
    /camera/camera/color/camera_info \
    /camera/camera/aligned_depth_to_color/image_raw \
    /camera/camera/aligned_depth_to_color/camera_info \
    /tf \
    /tf_static
