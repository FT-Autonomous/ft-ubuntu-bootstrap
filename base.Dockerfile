FROM ubuntu:jammy
WORKDIR /root/
COPY ./get-universe-repository .
RUN ./get-universe-repository

COPY ./get-prerequisites .
RUN ./get-prerequisites && rm -rf /var/lib/apt/lists/*

COPY ./detect-ros-distro .
COPY ./get-ros .
RUN ./get-ros && rm -fr /var/lib/apt/lists/*

COPY ./get-gazebo .

COPY ./detect-gazebo-installation-candidate .
RUN ./get-gazebo && rm -fr /var/lib/apt/lists/*

COPY ./diff.diff .
COPY ./get-eufs .
RUN ./get-eufs
  
COPY ./get-rosdeps .
RUN ./get-rosdeps && rm -rf /var/lib/apt/lists/*
