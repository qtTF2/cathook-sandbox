#!/usr/bin/env bash
loc=$(dirname $0)
INTERFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}') 
mkdir db
if [ ! -x "$(command -v pactl)" ]; then
    echo "(!) pactl doesn't exist, exiting..."
    exit
fi

if [ ! -x "$(command -v git)" ]; then
    echo "(!) git doesn't exist, exiting..."
    exit
fi


if [ ! -x "$(command -v firejail)" ]; then
    echo "(!) Firejail doesn't exist, exiting..."
    exit
fi
clear
echo Cathook Sandbox: Initial Setup 1 / 2
echo ------------------------------------
echo -n "(!) Please enter how many instance should I create for your multibox: "
read quota
echo $quota > $loc/db/1.txt

for ((i = 0; i < quota; ++i)); do
echo
echo "(!) Creating ${i} instance(s)..."
mkdir -p user_instances
cd $loc/user_instances
mkdir b${i}
cd ..
done

clear
echo Cathook Sandbox: Initial Setup 1 / 2
echo ------------------------------------
echo "(!) Creating audio source for mic spamming (${i} instance(s))..."
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=cathookns${i} --noprofile --private=./user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 pactl load-module module-null-sink sink_name=Source
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=cathookns${i} --noprofile --private=./user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 pactl load-module module-virtual-source source_name=VirtualMic master=Source.monitor

clear
echo Cathook Sandbox: Initial Setup 1 / 2
echo ------------------------------------
echo "(!) Creating files for global symlink fix script..."
echo "ln -s /opt/steamapps/ /home/$USER/.local/share/Steam/" > $loc/symlink.sh
sudo mv $loc/symlink.sh /opt/symlink.sh
sudo chmod 777 /opt/symlink.sh

# I assume u can setup follow bots instead of bots.
:'clear
echo Cathook Sandbox: Initial Setup 2 / 2
echo ------------------------------------
echo "(!) Copying nav mashes to ${i} instance(s)..."
firejail --dns=1.1.1.1 --net=$INTERFACE --netns=cathookns${i} --noprofile --private=./user_instances/b${i} --name=b${i} --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 git clone --recursive https://github.com/explowz/catbot-database;cd catbot-database;sudo cp -R nav\ meshes/* ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps;sudo chmod 755 -R ~/.steam/steam/steamapps/common/Team\ Fortress\ 2/tf/maps;cd ..;sudo rm -r catbot-database.
':

clear
echo Cathook Sandbox: Initial Setup 2 / 2
echo ------------------------------------
echo "(!) Cloning cathook..."
bash <(wget -qO- https://raw.githubusercontent.com/nullworks/One-in-all-cathook-install/master/install-all)


clear
echo Cathook Sandbox: Initial Setup 2 / 2
echo -------------------------------------
echo "(!) You can start steam to test your config or anything before starting the instances. Do not start TF2 or steam during when your instances are running."
echo
echo "(?) All you need to do is now ./start.sh!"
echo "(?) Create a list of steam accounts, and save them to accounts.txt in username:password format."
echo
echo "(?) If you are experiencing problems, it's because the instance is seperated from your system. "
echo "firejail --dns=1.1.1.1 --net=enp3s0 --netns=catbotns0 --noprofile --private=./user_instances/b0 --name=b0 --env=PULSE_SERVER=unix:/tmp/pulse.sock --env=DISPLAY=:0.0 bash"
echo "-- OR (if you have a bot sandbox ready) --"
echo "firejail --join=b0 bash"
echo
