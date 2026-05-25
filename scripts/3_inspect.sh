#!/bin/bash
# Phase 3: Open a saved RTAB-Map database for inspection.
# Usage: ./3_inspect.sh <db_path>
#
# Requires X11 forwarding (run from "ssh -Y") to see the Qt window.

DB_PATH="${1:-}"
if [ -z "$DB_PATH" ] || [ ! -f "$DB_PATH" ]; then
    echo "Usage: $0 <db_path>"
    echo ""
    echo "Available DBs:"
    ls -lh "$HOME/slam_record_ws/maps/"*.db 2>/dev/null || echo "  (none yet — run 2_replay_and_map.sh first)"
    exit 1
fi

source /opt/ros/jazzy/setup.bash

if ! command -v rtabmap-databaseViewer >/dev/null 2>&1; then
    echo "rtabmap-databaseViewer not installed."
    echo "Install with: sudo apt install ros-jazzy-rtabmap-tools"
    echo ""
    echo "Alternative: copy the db to Windows and open with rtabmap GUI there,"
    echo "or replay through foxglove_bridge for live inspection."
    exit 1
fi

echo "==> Opening $DB_PATH ..."
echo "    (Requires X11 forwarding via 'ssh -Y')"
rtabmap-databaseViewer "$DB_PATH"
