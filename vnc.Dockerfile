FROM ft/base AS base
RUN apt-get -y install x11vnc icewm xvfb
RUN git clone --depth 1 'https://github.com/novnc/noVNC.git' && \
    git clone --depth 1 'https://github.com/novnc/websockify.git' noVNC/utils/websockify
RUN touch noVNC/COLCON_IGNORE
COPY vnc.bash .
ENTRYPOINT [ "/root/vnc.bash" ]
