#!/bin/bash

chown -R 1000:1000 /home/linuxgsm

# start arma 3 server if already installed
if [ -e /home/linuxgsm/arma3server ] && [ -e /home/linuxgsm/serverfiles ]; then
    ~/arma3server start
else
    mkdir -p /home/linuxgsm/lgsm/config-lgsm/arma3server
    cat <<_EOF > /home/linuxgsm/lgsm/config-lgsm/arma3server/arma3server.cfg
steamuser="${STEAM_USER}"
steampass="${STEAM_PASS}"
_EOF
    # start the installation process
    cp /linuxgsm.sh ~/linuxgsm.sh
    echo 5 | ~/linuxgsm.sh install
    ~/arma3server auto-install
fi

/usr/bin/tmux set -g status off && /usr/bin/tmux attach 2> /dev/null

tail -f /dev/null

exit 0
