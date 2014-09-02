syver
=====

SystemverwaltungsScriptSammelsurium für die Installation von Kubuntu-Derivaten

    sudo apt-get --yes install firefox
    
    sudo zypper install git
    sudo apt-get --yes install git
    git config --global push.default simple
    git config --global user.email $USER@$HOSTNAME.suska.org

    mkdir $HOME/bin
    cd $HOME/bin

    git clone https://github.com/sunito/syver.git
    bash syver/bin/sy-basiconf
