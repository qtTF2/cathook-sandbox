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
clear
echo Cathook Sandbox
echo ---------------
echo "(!) Creating global steamapps..."
sudo mkdir -p /opt/steamapps
mountpoint -q /opt/steamapps || sudo mount --bind ~/.steam/steam/steamapps/ /opt/steamapps

clear
echo Cathook Sandbox
echo ---------------
echo -n "(!) Please enter how many bots you like to start now: "
read quota
echo $quota > $loc/db/2.txt

for ((i = 0; i < quota; ++i)); do
echo
echo "(!) Spawning ${i} steam instance(s)..."
cd user_instances
mkdir b${i}
cd ..
echo
echo "(!) Fix steamapps not syncing properly"
echo "(!) Ignore failed to create symbolic link error if it is your first time starting the script."
sudo $loc/scripts/ns-inet ${i}
echo $USER_INSTANCE
echo $loc
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=catbotns${i} --noprofile --private=$loc/user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=$DISPLAY bash -c /opt/symlink.sh && echo symlink success && exit


echo yes > $loc/db/steam_alive-bot${i}.txt
echo no > $loc/db/tf2_alive-bot${i}.txt
#echo "(!) Starting TF2"
#firejail --dns=1.1.1.1 --net=$INTERFACE --netns=catbotns${i} --noprofile --private=$loc/user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 bash -c /home/$user/.local/share/Steam/ubuntu12_32/reaper SteamLaunch AppId=440 -- /home/$user/.local/share/Steam/ubuntu12_32/steam-launch-wrapper -- /home/$user/.local/share/Steam/steamapps/common/Team Fortress 2/hl2.sh -game tf -steam -secure -novid

firejail --dns=1.1.1.1 --net=$INTERFACE --netns=catbotns${i} --noprofile --private=$loc/user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=$DISPLAY steam -login $steam_user -password $steam_pass && firejail --join=b0 bash -c cd /home/$user/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH="$(~/".local/share/Steam/ubuntu12_32/steam-runtime/run.sh" printenv LD_LIBRARY_PATH):./bin" DISPLAY=$DISPLAY PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -w 640 -h 480 -steam -secure -novid

#if you wish to have everything slient:
#steam slient: -nominidumps -nobreakpad -no-browser -nofriendsui
#tf2 slient: -silent -sw -w 640 -h 480 -novid -nojoy -noshaderapi -nomouse -nomessagebox -nominidumps -nohltv -nobreakpad -particles 512 -snoforceformat -softparticlesdefaultoff -threads 1

done
echo $acc | cut -f1 -d " " 
# remove file instead of keeping it
rm -rf $loc/db/steam_alive-bot${i}.txt
echo "(-) Goodbye."
