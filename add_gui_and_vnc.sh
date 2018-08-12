#!/bin/bash
if [ $(id -u) -eq 0 ]; then
    read -p "Enter username : " USER
    read -s -p "Enter password : " PASS

    apt update
    apt upgrade -y -q --force-yes

    useradd -m -p $(openssl passwd -1 $PASS) $USER
    usermod -aG sudo $USER

    apt install ubuntu-desktop ubuntu-gnome-desktop gnome-core tightvncserver -y -q

    echo '[Unit]'                                                       >> /etc/systemd/system/vncserver.service
    echo 'Description=Start TightVNC server at startup'                 >> /etc/systemd/system/vncserver.service
    echo 'After=syslog.target network.target'                           >> /etc/systemd/system/vncserver.service
    echo ''                                                             >> /etc/systemd/system/vncserver.service
    echo '[Service]'                                                    >> /etc/systemd/system/vncserver.service
    echo 'Type=forking'                                                 >> /etc/systemd/system/vncserver.service
    echo "User=$USER"                                                   >> /etc/systemd/system/vncserver.service
    echo 'PAMName=login'                                                >> /etc/systemd/system/vncserver.service
    echo "PIDFile=/home/$USER/.vnc/%H:1.pid"                            >> /etc/systemd/system/vncserver.service
    echo 'ExecStartPre=-/usr/bin/vncserver -kill :1 > /dev/null 2>&1'   >> /etc/systemd/system/vncserver.service
    echo 'ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :1' >> /etc/systemd/system/vncserver.service
    echo 'ExecStop=/usr/bin/vncserver -kill :1'                         >> /etc/systemd/system/vncserver.service
    echo ''                                                             >> /etc/systemd/system/vncserver.service
    echo '[Install]'                                                    >> /etc/systemd/system/vncserver.service
    echo 'WantedBy=multi-user.target'                                   >> /etc/systemd/system/vncserver.service

    systemctl daemon-reload
    systemctl enable vncserver.service
else
    echo "Only root may add a user to the system"
    exit 2
fi
