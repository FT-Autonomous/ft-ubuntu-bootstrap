#!/usr/bin/env bash
set -e  # stop on error
set -o pipefail

MAIN_REPO=git@github.com:FT-Autonomous/FT-FSAI-23.git

echo "FT AUTONOMOUS SETUP STARTED"

if ! grep -qi ubuntu /etc/os-release; then
    echo "This script is intended for Ubuntu-based systems."
    echo "Press Ctrl+C to cancel or wait 5s to continue anyway..."
    sleep 5
fi

echo "Installing prerequisites..."
#sudo bash setup/get-prerequisites

echo "Installing ROS2..."
#sudo bash setup/get-ros

echo "Installing Gazebo..."
#sudo bash setup/get-gazebo

echo "Installing EUFS..."
#bash setup/get-eufs

echo "Installing ROS dependencies..."
#bash setup/get-rosdeps

ROS_SOURCE_LINE=". /opt/ros/humble/setup.bash"
if ! grep -Fxq "$ROS_SOURCE_LINE" ~/.bashrc; then
    echo "$ROS_SOURCE_LINE" >> ~/.bashrc
    echo "Added ROS2 sourcing to ~/.bashrc"
fi
source /opt/ros/humble/setup.bash

if [ ! -d "FT-FSAI-23" ]; then
    echo "Cloning FT-FSAI-23 repository..."
    git clone --recurse-submodules "$MAIN_REPO"
else
    echo "FT-FSAI-23 already exists, pulling latest..."
    cd FT-FSAI-23
    git pull
    git submodule update --init --recursive
fi

#echo "→ Installing Python requirements..."
#cd "FT-FSAI-23"
#python3 -m pip install --upgrade pip
#pip install -r requirements.txt

MAX_RETRIES=3
COUNT=1
cd ~/ft/ft-ubuntu-bootstrap
echo "Building workspace using colcon..."
colcon build --symlink-install || {
    echo "Build failed once, retrying..."
    colcon build --symlink-install || {
    	echo "Oops failed again, one more time..."
		colcon build --symlink-install
	}
}

echo "========================================="
echo "FT Autonomous setup complete"
echo "!!May need to run cbuildsym again!!"
echo "Use ros2init to initialise... ros2"
echo "  .w       # to enter workspace"
echo "  ros2 ... # to run ROS2 commands"
echo "========================================="

