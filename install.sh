#!/usr/bin/env bash
set -e  # stop on error
set -o pipefail

DIR="$PWD"
MAIN_REPO=git@github.com:FT-Autonomous/FT-FSAI-23.git

echo "FT AUTONOMOUS SETUP STARTED"

echo "Installing prerequisites..."
sudo bash setup/get-prerequisites

echo "Installing ROS2..."
if ! sudo bash setup/get-ros; then
    # Check if the specific error file exists
    if [ -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
        echo "Error: default sources list file already exists. Removing and retrying..."
        sudo rm -f /etc/ros/rosdep/sources.list.d/20-default.list

        echo "Retrying ROS2 installation..."
        sudo bash setup/get-ros
    fi
else
    echo "ROS2 installation completed successfully."
fi

echo "Installing Gazebo..."
sudo bash setup/get-gazebo

echo "Installing EUFS..."
bash setup/get-eufs

echo "Installing ROS dependencies..."
bash setup/get-rosdeps

ROS_SOURCE_LINE=". /opt/ros/humble/setup.bash"
# shouldve been added in get-eufs but checks in case not 
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

echo "\nInstalling Python requirements...\n"
cd "FT-FSAI-23"
python3 -m pip install --upgrade pip
pip install -r requirements.txt

cd $DIR 
echo "\nBuilding workspace using colcon...\n"
colcon build --symlink-install || {
    echo "Build failed once, retrying..."
    colcon build --symlink-install 
}

echo "\nPost sucessful colcon build\n"
colcon build --symlink-install

echo "========================================="
echo "FT Autonomous setup complete"
echo "!!May need to run cbuildsym again!!"
echo "Use ros2init to initialise... ros2"
echo "	.w	 # opens top dir and sources setup files"
echo "  .r       # to source the setup files"
echo "  ros2 ... # to run ROS2 commands"
echo "========================================="

