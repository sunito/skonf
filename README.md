syver
=====

SystemverwaltungsScriptSammelsurium für die Installation von Kubuntu-Derivaten

    sudo apt-get --yes install firefox
    
    sudo apt-get --yes install git
    git config --global push.default simple
<<<<<<< HEAD
    git config --local  user.email $USER@$HOSTNAME.suska.org
=======
    git config --local  user email $USER@$HOSTNAME.suska.org
>>>>>>> 3240c633bbfadf9ffcaf3527ebea135cb188579d

    mkdir $HOME/bin
    cd $HOME/bin

    git clone https://github.com/sunito/syver.git
    bash syver/bin/sy-basiconf
