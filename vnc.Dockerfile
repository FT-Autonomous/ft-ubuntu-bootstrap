FROM ft/base AS base
RUN apt-get -y install x11vnc icewm xvfb zsh neovim
RUN git clone --depth 1 'https://github.com/novnc/noVNC.git' /usr/local/share/noVNC && \
    git clone --depth 1 'https://github.com/novnc/websockify.git' /usr/local/share/noVNC/utils/websockify
RUN ln -s /usr/local/share/noVNC/utils/novnc_proxy /usr/local/bin/
COPY vnc.bash rootless.bash /usr/local/bin/
ENTRYPOINT [ "/usr/local/bin/rootless.bash" ]
