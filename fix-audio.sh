#!/bin/bash

# credits: https://stackoverflow.com/a/246128/4649594
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PATH=$DIR:$PATH
USER_PIN_PATH=$DIR/user_pin_configs

function stop_pulse {
    systemctl --user stop pipewire-pulse.socket
    systemctl --user stop pipewire.socket
}

function start_pulse {
    systemctl --user start pipewire.service
    systemctl --user start pipewire-pulse.service
}

systemctl --user status pipewire.service &>/dev/null
[ $? -eq 0 ] && WAS_PIPEWIRE_ON=true || WAS_PIPEWIRE_ON=false

if [ "$WAS_PIPEWIRE_ON" = true ]; then
    stop_pulse
    sudo "PATH=$PATH" bash -c "reconfig.sh $USER_PIN_PATH"
    start_pulse
else
    sudo "PATH=$PATH" bash -c "reconfig.sh $USER_PIN_PATH"
fi
