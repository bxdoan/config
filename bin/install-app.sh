#!/usr/bin/env bash

#Install basic app
sudo apt-get install -y git

# Install dictionary offline
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"

sudo apt-get install -y dict dictd

# Installing English dictionary databeses (gcide, wn, devil, thesaurus):

sudo apt-get install -y dict-gcide
#sudo apt-get install dict-wn
#sudo apt-get install dict-devil
#sudo apt-get install -y dict-moby-thesaurus

# aftermath
dict --verison