#!/bin/bash
USER_INSTANCE=$(dirname $0)
INTERFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}') 
echo "(!) Launching TF2"
firejail --join=b0 bash -c cd ~/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH="$(~/".local/share/Steam/ubuntu12_32/steam-runtime/run.sh" printenv LD_LIBRARY_PATH):./bin" STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0 DISPLAY=:0.0 PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -w 640 -h 480 -steam -secure -novid

echo "(!) Injecting cathook into sandboxed TF2"
echo $USER_INSTANCE
firejail --join=b0 bash -c cd $USER_INSTANCE && sudo ./attach