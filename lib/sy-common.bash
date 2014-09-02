#!/bin/bash

function syve_section {
  echo
  echo "    ######  $*  #####    "
  echo
  logger syve_section $*
}

has_apt=$(which apt-get)

function apt_install {
  echo
  echo Installing $*
  logger SyveInstalling $*
  if [ $has_apt ] ;then
    sudo apt-get --yes install $*
  else
    sudo -n zypper install $*
  fi  
}
