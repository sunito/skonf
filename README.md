syver
=====

SystemverwaltungsScriptSammelsurium für die Installation von Kubuntu-Derivaten

    sudo apt-get --yes install firefox
    
    sudo zypper install git
    sudo apt-get --yes install git
    git config --global push.default simple
    git config --global user.email $USER-$HOSTNAME@suska.org
    git config --global user.name "$USER $HOSTNAME"

    mkdir $HOME/bin
    cd $HOME/bin

    ssh-keygen
    cat .ssh/id_rsa.pub

    git clone git@github.com:sunito/syver.git
    bash syver/bin/sy-basiconf

    git clone https://github.com/sunito/syver.git
    bash syver/bin/sy-basiconf
    