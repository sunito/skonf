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
if  [ ! -z $(which pacman) ] ;then
  has_apt=""
  has_zyp=""
  has_pac=pac
else
  has_apt=$( if [ -z $(which zypper) ] ;then echo apt ;fi  )
  has_zyp=$( if [ ! -z $(which zypper) ] ;then echo zyp;fi  )
  has_pac=
fi

echo apt:$has_apt
echo pac:$has_pac
echo zyp:$has_zyp

function apt_install {
  sudo echo
  echo Installing $*
  logger SyveInstalling $*
  if [ $has_apt ] ;then
    sudo apt-get --yes install $*
  elif [ $has_pac ] ;then
    sudo pacman --sync --needed --noconfirm $*
  else
    #sudo zypper -n install $*
    sudo zypper install -y $*
  fi
}

function syve_user {
  sudo echo
  echo Adding $*
  logger SyveAdding $*
  u=$1
  id=$2
  fn=$3
  sudo useradd --uid $id -g users --create-home $u 
  sudo chfn -f "$fn" $u 
  sudo usermod -a -G wheel $u 
  sudo usermod -a -G sudo $u
  if [ $has_apt ] ;then
    echo
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

function apt_rpm_repo {
  url=$1
  basenam=$2
  if [ x$basenam == x ] ;then
    basenam=$($url/http*:/)
    basenam=$($basenam/\//_)
    basenam=$($basenam/__/_)
  fi
  if [ $has_zyp ] ;then
    repo_filenam=/etc/zypp/repos.d/$basenam
    if [ ! -f $repo_filenam ] ;then
      sudo wget $url -O $repo_filenam
    fi
  fi
}

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


  if [ $has_apt ] ;then
    echo NOT Repo basenam=$basenam repourl=$repourl
  else
    echo Repo basenam=$basenam repourl=$repourl
    logger SyveRepo basenam=$basenam args="$*"
    if [[ -z `zypper lr |grep $basenam` ]] ;then
      echo adding $repourl
      echo zypper addrepo --gpgcheck-allow-unsigned "$repourl" "$basenam"
      sudo zypper addrepo --gpgcheck-allow-unsigned "$repourl" "$basenam"  # Suse erlaubt vertrauen von Schlüsseln nur im interaktiven Modus
      sudo zypper refresh
    fi
  fi
}

function apt_ppa {
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


  if [ $has_apt ] ;then
    echo Repo basenam=$basenam repourl=$repourl
    logger SyveRepo basenam=$basenam args="$*"
    if [ -z `ls /etc/apt/sources.list.d |grep $basenam` ] ;then
      sudo add-apt-repository --yes $repourl
      sudo apt-get update
    fi
  else
    echo NOT Repo basenam=$basenam repourl=$repourl
  fi
}
