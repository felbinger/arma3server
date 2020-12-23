FROM gameservermanagers/linuxgsm-docker

USER root

# install libtbb2:i386 for arma 3 extdb3
RUN dpkg --add-architecture i386 \
  && apt-get update -y \
  && apt-get upgrade -y \
  && apt-get install -y libtbb2:i386 \
  && rm -rf /var/lib/apt/lists/*

# add custom entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER linuxgsm
