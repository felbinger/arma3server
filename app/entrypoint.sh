#!/bin/bash

# start arma 3 server if already installed
if [ -e /home/linuxgsm/arma3server ] && [ -e /home/linuxgsm/serverfiles ]; then
    ~/arma3server start
else
    # start the installation process
    cp /linuxgsm.sh ~/linuxgsm.sh
    echo 5 | ~/linuxgsm.sh install
    ~/arma3server auto-install
fi

/usr/bin/tmux set -g status off && /usr/bin/tmux attach 2> /dev/null

tail -f /dev/null

exit 0
