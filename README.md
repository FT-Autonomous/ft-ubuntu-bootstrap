# Why?

This repository is a set of tools meant to speed up the FTA onboarding process.

# WSL


You can run the following commmands:

```
mkdir -p ~/ft && cd ~/ft
git clone https://github.com/FT-Autonomous/ft-ubuntu-bootstrap
sudo bash ft-ubuntu-bootstrap/get-prerequisites
sudo bash ft-ubuntu-bootstrap/get-ros
sudo bash ft-ubuntu-bootstrap/get-gazebo
bash ft-ubuntu-bootstrap/get-eufs
bash ft-ubuntu-bootstrap/get-rosdeps
```

After that, start a new terminal:

```
. /opt/ros/$ROSDISTRO/setup.bash
colcon build --symlink-install
```

Clone this private repository.

```
colcon build --symlink-install
```

## Specific Provisions for WSL 2

You need to run the simulator with the `LIBGL_ALWAYS_SOFTWARE` environment variable set to `1`.
This looks like:

```
LIBGL_ALWAYS_SOFTWARE=1 ros2 launch eufs_launcher eufs_launcher.launch.py
```

# Docker

Build the base image:

```
docker build -t ft/base -f base.Dockerfile .
```

Build the vnc image:

```
docker build -t ft/vnc vnc.Dockerfile .
```

Run the VNC image:

```
docker run --name ft --rm -it -p 6900:6900 -v "$HOME:$HOME" -w "$HOME" ft/vnc \
    --home "$HOME" \
    --user "$(whoami)" \
    --shell "$SHELL" \
    --uid "$(id -u)"
```

Then open `localhost:6900` in your web browser.
This will provide a linux environment in which you can run `rviz2`, `gazebo` and `eufs`.
You can also compile your code there.
To open a terminal in the docker container while it is running, use the command:

```
docker exec -it ft -u $(whoami) "$SHELL"
```
