FROM ubuntu:focal
WORKDIR /root/
COPY ./get-universe-repository .
RUN ./get-universe-repository

RUN apt-get -y update

COPY ./get-prerequisites .
RUN ./get-prerequisites

COPY ./get-ros .
RUN ./get-ros

COPY ./get-gazebo .
RUN ./get-gazebo

COPY ./get-eufs .
RUN ./get-eufs

COPY ./get-rosdeps .
RUN ./get-rosdeps
