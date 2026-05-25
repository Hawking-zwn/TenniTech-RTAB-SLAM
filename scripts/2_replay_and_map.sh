#!/bin/bash
# Phase 2: Replay a recorded bag and build a map with RTAB-Map.
# Usage: ./2_replay_and_map.sh <bag_path> [run_name] [extra_rtabmap_args]
#
# Output: ~/slam_record_ws/maps/<bag_name>_<run_name>.db

BAG_PATH="${1:-}"
RUN_NAME="${2:-run1}"
EXTRA_ARGS="${3:-}"

if [ -z "$BAG_PATH" ] || [ ! -d "$BAG_PATH" ]; then
    echo "Usage: $0 <bag_path> [run_name] [extra_rtabmap_args]"
    echo ""
    echo "Available bags:"
    ls -1d "$HOME/slam_record_ws/bags/"*/ 2>/dev/null | sed 's|/$||' || echo "  (none yet — run 1_record.sh first)"
    exit 1
fi

BAG_NAME=$(basename "$BAG_PATH")
WORK_DIR="$HOME/slam_record_ws"
DB_PATH="$WORK_DIR/maps/${BAG_NAME}_${RUN_NAME}.db"
LOG_PATH="$WORK_DIR/logs/rtabmap_${BAG_NAME}_${RUN_NAME}.log"
mkdir -p "$(dirname "$DB_PATH")" "$(dirname "$LOG_PATH")"

source /opt/ros/jazzy/setup.bash

# Wipe old db so each run starts fresh
rm -f "$DB_PATH"

cleanup() {
    echo ""
    echo "==> Stopping RTAB-Map..."
    pkill -f "ros2 launch rtabmap" 2>/dev/null
    pkill -f rgbd_odometry 2>/dev/null
    pkill -f "rtabmap " 2>/dev/null
    sleep 1
    if [ -f "$DB_PATH" ]; then
        SIZE=$(du -h "$DB_PATH" | cut -f1)
        echo "==> Map saved: $DB_PATH ($SIZE)"
    else
        echo "==> WARNING: No map db produced at $DB_PATH"
    fi
    echo "==> Odom quality summary (last 100 frames):"
    grep -oE "quality=[0-9]+" "$LOG_PATH" 2>/dev/null | tail -100 | \
        awk -F= '{sum+=$2; n++; if(min==""||$2<min)min=$2; if($2>max)max=$2} END {if(n>0)printf "  avg=%.0f  min=%d  max=%d  samples=%d\n", sum/n, min, max, n; else print "  (no quality data — check log)"}'
    echo "==> Full log: $LOG_PATH"
}
trap cleanup EXIT INT TERM

echo "==> Starting RTAB-Map (headless, sim_time mode)..."
echo "    DB output:  $DB_PATH"
echo "    Log output: $LOG_PATH"
nohup ros2 launch rtabmap_launch rtabmap.launch.py \
    rtabmap_args:="--delete_db_on_start" \
    database_path:="$DB_PATH" \
    rgb_topic:=/camera/camera/color/image_raw \
    depth_topic:=/camera/camera/aligned_depth_to_color/image_raw \
    camera_info_topic:=/camera/camera/color/camera_info \
    frame_id:=camera_link \
    approx_sync:=true \
    qos:=1 \
    use_sim_time:=true \
    rtabmap_viz:=false \
    rviz:=false \
    $EXTRA_ARGS \
    > "$LOG_PATH" 2>&1 &

echo "==> Waiting 5s for RTAB-Map subscribers to be ready..."
sleep 5

echo ""
echo "============================================================"
echo "  Playing bag: $BAG_PATH"
echo "  --rate 1.0  (Ctrl+C to abort early)"
echo "============================================================"
echo ""

ros2 bag play "$BAG_PATH" --clock

echo ""
echo "==> Bag finished. Letting RTAB-Map flush remaining frames..."
sleep 3
