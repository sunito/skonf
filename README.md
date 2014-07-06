syver
=====

SystemverwaltungsScriptSammelsurium für die Installation von Kubuntu-Derivaten

    sudo apt-get --yes install firefox
    
    sudo apt-get --yes install git
    git config --global push.default simple
    git config --local  user email $USER@$HOSTNAME.suska.org

    mkdir $HOME/bin
    cd $HOME/bin

    git clone https://github.com/sunito/syver.git
    bash syver/bin/sy-basiconf
