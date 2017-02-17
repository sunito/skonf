skonf
=====

Systemverwaltungs-Script-Sammelsurium für die routinemaäßige Konfiguration von einiger Linux-Distributionen, vor allem openSuse und Kubuntu

    sudo apt-get --yes install firefox  
    
    sudo zypper install git
    
    sudo apt-get --yes install git ;git config --global push.default simple ;git config --global user.email $USER-$HOSTNAME@suska.org ;git config --global user.name "$USER $HOSTNAME" ;git config -l
    
    sudo apt-get --yes install git ;git config --global push.default simple ;git config --global user.email skonf-$HOSTNAME@suska.org ;git config --global user.name "$HOSTNAME" ;git config -l

    sudo zypper install git ;git config --global push.default simple ;git config --global user.email skonf-$HOSTNAME@suska.org ;git config --global user.name "$HOSTNAME" ;git config -l

    ssh-keygen ;cat $HOME/.ssh/id_rsa.pub
    

    mkdir $HOME/bin ;cd $HOME/bin

    sudo mkdir /wartung
    sudo chown sunito.users /wartung
    cd /wartung
    git clone git@github.com:sunito/skonf.git ;bash skonf/bin/sy-basiconf
    # pushbar, daher die Standardvariante

    mkdir $HOME/bin ;cd $HOME/bin
    git clone https://github.com/sunito/skonf.git ;bash skonf/bin/sy-basiconf
    # ohne key
    
