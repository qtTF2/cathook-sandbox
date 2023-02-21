#!/usr/bin/env bash

#original script credits
# Thank you LWSS
# https://github.com/LWSS/Fuzion/commit/a53b6c634cde0ed47b08dd587ba40a3806adf3fe
clear # better output jesus fucking christ
[[ ! -z "$SUDO_USER" ]] && RUNUSER="$SUDO_USER" || RUNUSER="$LOGNAME"
RUNCMD="sudo -u $RUNUSER"

#credit: nullworks
if [ ! "$(id -u)" -eq 0 ]; then
  echo -e "[\033[1;31mERROR\033[0m] This script must be ran as root!\033[0m"
  exit 1
fi

line=$(pgrep -u "$RUNUSER" hl2_linux)
arr=($line)
if [ $# == 1 ]; then
    proc=$1
else
    if [ ${#arr[@]} == 0 ]; then
        echo -e "[\033[1;31mERROR\033[0m] TF2 is not running."
        exit
    fi

    if [ ${#arr[@]} == 1 ]; then
        echo -e "[\033[0;32mOK\033[0m] Skipping choice. There is only one TF2 instance to inject cathook into."
        proc=${arr[0]}
        else         if [ ${#arr[@]} > 2 ]; then
        echo "Which TF2 instance would you like to inject into?"
        tf2_inst=${#arr[@]}
        for (( i=0; i<${tf2_inst}; i++ ));
        do
        echo -e "[\033[1;34m$i\033[0m]: \033[1;34m${arr[$i]}\033[0m"
        done
        echo -n "Please enter a number from the list above: "
        read num

        proc=${arr[$num]}
        fi
    fi
    
    fi 

echo -e "[\033[1;33mWAIT\033[0m] Attaching \033[1;34mcathook\033[0m to \033[1;34m$proc\033[0m"

# Get a Random name from the build_names file.
FILENAME=$(shuf -n 1 build_names)

# Create directory if it doesn't exist
if [ ! -d "/lib/i386-linux-gnu/" ]; then
    mkdir /lib/i386-linux-gnu/
fi

# In case this file exists, get another one. ( checked it works )
while [ -f "/lib/i386-linux-gnu/${FILENAME}" ]; do
    FILENAME=$(shuf -n 1 build_names)
done

# echo $FILENAME > build_id # For detaching

sudo cp "bin/libcathook.so" "/lib/i386-linux-gnu/${FILENAME}"

echo -e "[\033[1;33mWAIT\033[0m] Loading \033[1;34m"$FILENAME"\033[0m to \033[1;34m"$proc"\033[0m"

gdbbin="gdb"
$gdbbin -n -q -batch                                                                                \
    -ex "attach $proc"                                                                          \
    -ex "echo \033[1mCalling dlopen\033[0m\n"                                                   \
    -ex "call ((void*(*)(const char*, int))dlopen)(\"/lib/i386-linux-gnu/$FILENAME\", 1)"       \
    -ex "echo \033[1mCalling dlerror\033[0m\n"                                                  \
    -ex "call ((char*(*)(void))dlerror)()"                                                      \
    -ex "detach"                                                                                \
    -ex "quit"

sudo rm "/lib/i386-linux-gnu/${FILENAME}"
clear
echo -e "[\033[0;32mOK\033[0m] There is now a cat in $proc. (cathook injected successfully :])"
echo "Thank you LWSS (https://github.com/LWSS/Fuzion/commit/a53b6c634cde0ed47b08dd587ba40a3806adf3fe)"
