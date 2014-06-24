#!/bin/bash

function syve_section {
  echo
  echo "    ######  $*  #####    "
  echo
  logger syve_section $*
}

function apt_install {
  echo
  echo Installing $*
  logger SyveInstalling $*
  sudo apt-get --yes install $*
}

