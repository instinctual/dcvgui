#!/usr/bin/env bash

# Check if the current user ID is not 0 (root has a UID of 0)
if [[ $(id -u) -ne 0 ]]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

mkdir -p /opt/instinctual/bin/
/usr/bin/install -m 655 dcvgui.sh /opt/instinctual/bin/

#install shortcut
/usr/bin/install -m 744 dcvgui.desktop /usr/share/applications/
/usr/bin/install -m 644 dcvgui.png /opt/instinctual

echo "DCVgui installed."