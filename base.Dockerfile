FROM ubuntu:jammy
WORKDIR /root/
COPY ./get-universe-repository .
RUN ./get-universe-repository

COPY ./get-prerequisites .
RUN ./get-prerequisites && rm -rf /var/lib/apt/lists/*

COPY ./detect-ros-distro .
COPY ./get-ros .
RUN ./get-ros && rm -fr /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y python3-colcon-common-extensions

COPY ./get-gazebo .

COPY ./detect-gazebo-installation-candidate .
RUN ./get-gazebo && rm -fr /var/lib/apt/lists/*

COPY ./diff.diff .
COPY ./get-eufs .
RUN ./get-eufs
  
COPY ./get-rosdeps .
RUN ./get-rosdeps && rm -rf /var/lib/apt/lists/*
RUN ./get-rosdeps

RUN apt-get update && apt-get install -y python3-colcon-common-extensions python3-colcon-ros python3-colcon-core python3-dev rsync screen ros-humble-catch-ros2

RUN apt update && apt install -y gedit
