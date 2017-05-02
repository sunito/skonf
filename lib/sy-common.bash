#!/bin/bash

function syve_section {
  echo
  echo "    ######  $*  #####    "
  echo
  logger syve_section $*
}

# 2016-Apr, Sv: bei 42.1 ist auch apt-get vorhanden, also umgekehrt:
# ziemlich umständlich, aber funktioniert erstmal
#has_apt=[ ! $(which zypper) ]
has_apt=$( if [ -z $(which zypper) ] ;then echo apt ;fi  ) 

function apt_install {
  sudo echo
  echo Installing $*
  logger SyveInstalling $*
  if [ $has_apt ] ;then
    sudo apt-get --yes install $*
  else
    #sudo zypper -n install $* 
    sudo zypper install -y $*
  fi  
}

kde_dir=$HOME/.kde4
if [[ -f $kde_dir/share/config//kwinrc ]] ;then
  echo §kde_dir
else
  kde_dir=$HOME/.kde
fi

config_dir="$HOME/.config"
