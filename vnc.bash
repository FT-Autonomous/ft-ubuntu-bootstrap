#!/bin/bash
export DISPLAY=:1
trap 'for program in Xvfb x11vnc icewm novnc_proxy ; do kill %?$program ; done' EXIT TERM INT HUP
Xvfb $DISPLAY -screen 0 1920x1080x24 +extension GLX +render & sleep 1
icewm &
x11vnc -passwd '' -rfbport 5900 -noxdamage -forever -many &
./noVNC/utils/novnc_proxy --listen 6900 --vnc localhost:5900
