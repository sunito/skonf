#! /bin/bash
sudo service modemmanager stop
sudo killall modem-manager
sleep 1
sudo service modemmanager start
sleep 23
nmcli nm wwan on
echo WWAN angeschaltet
nmcli con up id E-Plus
echo Verbindung gestartet
sleep 10
