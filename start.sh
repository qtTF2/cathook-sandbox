#!/bin/bash
USER_INSTANCE=$(dirname $0)
INTERFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}')  
steam_user=$(cat accounts.txt | cut -z accounts.txt -f1 -d ":" )
steam_pass=$(cut -z accounts.txt -f2 -d ":" | tr '\0' '\r')
if ! [ -d "./user_instances" ]; then
	echo "(!) You need to run install first."
	exit
fi
clear
echo Cathook Sandbox
echo ---------------
echo -n "(!) Please enter how many bots you like to start now: "
read quota
echo $quota > $USER_INSTANCE/db/2.txt

for ((i = 0; i < quota; ++i)); do
echo
echo "(!) Spawning ${i} steam instance(s)..."
cd user_instances
mkdir b${i}
cd ..
echo "(!) Fix steamapps not syncing properly"
echo "(!) Ignore failed to create symbolic link error if it is your first time starting the script."
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=catbotns${i} --noprofile --private=$USER_INSTANCE/user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 bash -c /opt/symlink.sh && echo symlink success && exit

echo true > $USER_INSTANCE/db/steam_alive-bot${i}.txt
echo false > $USER_INSTANCE/db/tf2_alive-bot${i}.txt
sudo $USER_INSTANCE/scripts/ns-inet ${i}
#-nominidumps -nobreakpad -no-browser -nofriendsui
#firejail --join=b0 echo test
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=catbotns${i} --noprofile --private=$USER_INSTANCE/user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 steam -login $steam_user -password $steam_pass 
#-silent -sw -w 640 -h 480 -novid -nojoy -noshaderapi -nomouse -nomessagebox -nominidumps -nohltv -nobreakpad -particles 512 -snoforceformat -softparticlesdefaultoff -threads 1
#echo "(!) Starting TF2"
#cd /home/qt/.local/share/Steam/steamapps/common/Team\ Fortress\ 2/ && firejail --join=b0 bash -c cd ~/.local/share/Steam/steamapps/common/Team\ Fortress\ 2 && LD_LIBRARY_PATH="$(~/".local/share/Steam/ubuntu12_32/steam-runtime/run.sh" printenv LD_LIBRARY_PATH):./bin" STEAM_RUNTIME_PREFER_HOST_LIBRARIES=0 DISPLAY=:0.0 PULSE_SERVER="unix:/tmp/pulse.sock" ./hl2_linux -game tf -w 640 -h 480 -steam -secure -novid
done
echo $acc | cut -f1 -d " " 
echo $steam_user
echo $steam_pass
loc=$(pwd)
echo false > $loc/db/steam_alive-bot$((i-1)).txt
