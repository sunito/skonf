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

# todo: verwende: kde4-config --localprefix
kde_dir=$HOME/.kde4
if [[ -f $kde_dir/share/config//kwinrc ]] ;then
  echo §kde_dir
else
  kde_dir=$HOME/.kde
fi

config_dir="$HOME/.config"

function apt_repo {
  sudo echo
  main_repourl=$1
  basenam=$2
  if [ x$basenam == x ] ;then
    basenam=$(basename $main_repourl)
  fi
  if [ $has_apt ] ;then
    repourl=$main_repourl
  else
    main_repourl=${main_repourl%/}/  # always one slash at the end
    release_descr=$(lsb_release -ds)
    echo $release_descr
    release_id=${release_descr// /_}   # replace all (that's what the second slash is for) spaces by underscore
    repourl=$main_repourl${release_id//\"/}  # remove all (that's what the second slash is for) quotes 
  fi
    
  echo Repo basenam=$basenam repourl=$repourl
  echo args="$*"
  
  logger SyveRepo basenam=$basenam args="$*"
  
  if [ $has_apt ] ;then
    if [ -z `ls /etc/apt/sources.list.d |grep $basenam` ] ;then
      sudo add-apt-repository --yes $repourl
      sudo apt-get update
    fi
  else
    if [[ -z `zypper lr |grep $basenam` ]] ;then
      sudo zypper addrepo --gpgcheck-allow-unsigned "$repourl" "$basenam"
      sudo zypper refresh
    fi
  fi  
}

