# Why?

This repository is a set of tools meant to speed up the FTA onboarding process.

# WSL

```
mkdir -p ~/colcon_ws && cd ~/colcon_ws
sudo sh get-prerequisites
sudo sh get-ros
sudo sh get-gazebo
sh get-eufs
sh get-rosdeps
. /opt/ros/galactic/setup.bash
colcon build --symlink-install
```

Clone this private repository.

```
colcon build --symlink-install
```
