#!/bin/bash
loc=$(pwd)
USER_INSTANCE=$(dirname $0)
INTERFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}')  
steam_user=$(cat accounts.txt | cut -z accounts.txt -f1 -d ":" )
steam_pass=$(cut -z accounts.txt -f2 -d ":" | tr '\0' '\r')
user="$USER"
DISPLAY=$(echo $DISPLAY)
if ! [ -d "./user_instances" ]; then
	echo "(!) You need to run install first."
	exit
fi
sudo mkdir -p /opt/steamapps
mountpoint -q /opt/steamapps || sudo mount --bind ~/.steam/steam/steamapps/ /opt/steamapps

if [ -x "$(command -v pulseaudio)" ]; then
    echo "(!) Setting up Pulseaudio socket..."
    pulse=$(pgrep -u "$USER" pulseaudio);
    ([ ! -z "$pulse" ]) && pulseaudio --start &>/dev/null &
    pactl load-module module-native-protocol-unix auth-anonymous=1 socket=/tmp/pulse.sock > /tmp/pulsemodule.id
fi

echo "(!) Creating audio source for mic spamming..."
pactl load-module module-null-sink sink_name=Source
pactl load-module module-virtual-source source_name=VirtualMic master=Source.monitor


#magic :)
if [ -e $loc/db/2.txt ]; then
    count=$(cat $loc/db/2.txt)
else
    count=-1
fi


((count++))
echo ${count} > $loc/db/2.txt

echo "(!) Fix steamapps not syncing properly"
echo "(!) Ignore failed to create symbolic link error if it is your first time starting the script."
sudo $loc/scripts/ns-inet ${count}
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=cathookns${count} --noprofile --private=$loc/user_instances/b${count} --name=b${count} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=$DISPLAY bash -c /opt/symlink.sh && echo symlink success && exit

echo "sandbox debugging"
echo "useful for reporting bugs or issues"
echo "LOC: $loc"
echo "ID: ${count}"
echo "NETWORK SPACE: cathookns${count}"
echo "STEAM (isSTEAM?): $(cat $loc/db/steam_alive-bot${count}.txt)"
echo "TF2 (isTF2?): $(cat $loc/db/tf2_alive-bot${count}.txt)"
echo "IPC: not_supported"


echo yes > $loc/db/steam_alive-cat${count}.txt
echo no > $loc/db/tf2_alive-bot${count}.txt
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=cathookns${count} --noprofile --private=$loc/user_instances/b${count} --name=b${count} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=$DISPLAY steam -login $steam_user -password $steam_pass && firejail --join=b0 bash -c cd /home/$user/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH="$(~/".local/share/Steam/ubuntu12_32/steam-runtime/run.sh" printenv LD_LIBRARY_PATH):./bin" DISPLAY=$DISPLAY PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -w 640 -h 480 -steam -secure -novid


#keep track of sandbox and if down remove any trace.
to_rem=$(cat $loc/db/2.txt)
((to_rem--))
echo $to_rem > $loc/db/2.txt 
sudo $loc/scripts/ns-delete ${count}
rm -rf $loc/db/steam_alive-cat${count}.txt
echo "(-) Cathook Sandbox ${count} is now down."
