FROM ubuntu:jammy
WORKDIR /root/
COPY ./get-universe-repository .
RUN ./get-universe-repository

RUN apt-get -y update

COPY ./get-prerequisites .
RUN ./get-prerequisites

COPY ./detect-ros-distro .
COPY ./get-ros .
RUN ./get-ros

COPY ./get-gazebo .

COPY ./detect-gazebo-installation-candidate .
RUN ./get-gazebo

COPY ./diff.diff .
COPY ./get-eufs .
RUN ./get-eufs
  
COPY ./get-rosdeps .
RUN ./get-rosdeps
