#!/bin/bash

function syve_section {
  skonf_section "$*"
}

function skonf_section {
  echo
  echo
  echo "    ############  $*  ############    "
  echo
  logger skonf_section $*
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
  

  opt_kandidat=$1
  opt=""
  while [ ${opt_kandidat:0:1} == "-" ] ;do   # dann ist es eine Optionsangabe, Optionen müssen am Anfang stehen!!
    #@=("$($@:1}")

    if [ $opt ] ;then
      opt=$opt,
    fi
    opt=$opt${opt_kandidat:1}

    shift
    opt_kandidat=${1:=end}
    echo "Neu: >>$opt_kandidat<<"
  done

  if [ $opt ] ;then
    echo -n "For: $opt "
  else
    opt="all"
  fi
  
  logger "SyveInstalling $* for $opt"

  cmd="echo Ignoriert: "
  if [ $has_apt ] ;then
    if [[ $opt == "all"  ||  $opt == *"deb"* ]] ;then
      cmd="apt-get --yes install"
    fi
  elif [ $has_pac ] ;then
    if [[ $opt == "all"  || $opt == *"pac"* ]] ;then
      cmd="pacman --sync --needed --noconfirm"
    fi
  else
    if [[ $opt == "all"  ||  $opt == *"zyp"* ]] ;then
      #sudo zypper -n install $*
      cmd="zypper install -y"
    fi
  fi
  
  if [[ ! $cmd =~ echo.* ]] ;then
    echo
    echo installing $*
    echo $cmd $*
    
    sudo $cmd $*
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

# Was macht diese Funktion? <2021-Jul, Sv>
function apt_rpm_repo {
  url=$1
  basenam=$2
  if [ x$basenam == x ] ;then
  # hat das jemals funktioniert? <2021-Jul, Sven>
  #  basenam=$($url/http*:/)
    basenam=${url/http*:/}
    basenam=${basenam//\//_}
    basenam=${basenam//__/_}
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
#   if [ $has_apt ] ;then
#     repourl=$main_repourl
#   else
    repourl=${main_repourl%/}/  # always one slash at the end
    release_descr=$(lsb_release -ds)
    echo $release_descr
    release_id=${release_descr// /_}   # replace all (that's what the second slash is for) spaces by underscore
    
  if [[ ! -z `zypper lr -u |grep $repourl` ]] ;then return
  fi
  
    # Testen, ob die URL auf ".repo" endet und dann wohl vollständig ist:
    #echo x${main_repourl: -5}
    if [ x${main_repourl: -5} == x.repo ] ;then
      repourl=$main_repourl 
      basenam=""
    else
      repourl=$repourl${release_id//\"/}  # remove all (that's what the second slash is for) quotes
    fi
#  fi


  if [ $has_zyp ] ;then
    echo Repo basenam=$basenam repourl=$repourl
    logger SyveRepo basenam=$basenam args="$*"
    # Der Test erfolgt jetzt oben  <2021-Jul, Sven>
    #if [[ -z `zypper lr -u |grep $repourl` ]] ;then
      echo adding $repourl
    if [ x$basenam == x ] ;then # wir müssen das hier leider unterscheiden ("$basenam" würde im else-Pfad als anwesendes, aber leeres zweites Argument ausgewertet werden)
      sudo zypper addrepo --gpgcheck-allow-unsigned "$repourl"   # Suse erlaubt das Vertrauen von Schlüsseln nur im interaktiven Modus
    else
      echo zypper addrepo --gpgcheck-allow-unsigned "$repourl" "$basenam"
      sudo zypper addrepo --gpgcheck-allow-unsigned "$repourl" "$basenam"  # Suse erlaubt vertrauen von Schlüsseln nur im interaktiven Modus
      sudo zypper refresh
    fi
  else
    echo Ignoriere repo, da kein suse-System. basenam=$basenam repourl=$repourl
  fi
}

# https://stackoverflow.com/questions/12187859/create-new-file-but-add-number-if-filename-already-exists-in-bash
function ensure_nonexist() {
  fn="$1"

  if [[ -e "$fn"  || -L "$fn" ]] ; then

    # Extract the file extension (if any), with preceeding '.'
    if [[ "$fn" == *.* ]] ;then
      ext=".${fn##*.}"
    else
      ext=""
    fi

    fn_base="${fn%.*}";

    i=1
    while true ; do
      fn="$fn_base-$i$ext"
      if [[ -e "$fn" || -L "$fn" ]] ;then
        let i++
      else
        break
      fi
    done

  fi

  echo "$fn"
}


# @Erstellt: 2024-Mar, Sunito
function apt_repo_deb {
  deb_suite="$3"
  repo_url="$1"
  key_url="$2"
  #key_basename=${key_basename%.*}   # Extension entfernen
  repo_bn=${repo_url//[^[:alnum:]]/-}-
  repo_bn=${repo_bn//https-/-}
  repo_bn=${repo_bn//http-/-}
  repo_bn=${repo_bn//-apt-/-}
  repo_bn=${repo_bn//-app-/-}
  repo_bn=${repo_bn//-com-/-}
  repo_bn=${repo_bn//-deb-/-}
  repo_bn=${repo_bn//-debian-/-}
  repo_bn=${repo_bn//-desktop-/-}
  repo_bn=${repo_bn//-linux-/-}
  repo_bn=${repo_bn//-org-/-}
  repo_bn=${repo_bn//-updates-/-}
  repo_bn=${repo_bn//----------/-}
  repo_bn=${repo_bn//-----/-}
  repo_bn=${repo_bn//---/-}
  repo_bn=${repo_bn//--/-}
  repo_bn=${repo_bn/#-/}
  repo_bn=${repo_bn/%-/}
  repo_basename=$repo_bn

  key_basename="$repo_basename-$(basename $key_url)"

  source_datei="/etc/apt/sources.list.d/$repo_basename.sources"

  if [ ! $deb_suite ] ;then
    deb_suite=stable
  fi

  if [[ ! -f "$source_datei" ]] ;then
    #keyring_datei="$(ensure_nonexist "/usr/share/keyrings/$key_basename.gpg")"
    keyring_datei="$(ensure_nonexist "/usr/share/keyrings/$key_basename")"
    sudo curl -fsSLo $keyring_datei $key_url

    cat <<EOT |sudo tee $source_datei
Types: deb
URIs: $repo_url
Suites: $deb_suite
Components: main
signed-by: $keyring_datei
arch: amd64
EOT
    sudo apt-get update
  fi
}


# @Erstellt: vor 2022
function apt_ppa {
  main_repourl=$1
  basenam=$2
  sudo echo
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
    echo Ignoriere ppa, da kein deb-System. basenam=$basenam repourl=$repourl
  fi
}
