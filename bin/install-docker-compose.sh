#!/usr/bin/env bash
#!/usr/bin/env bash
# applied for Ubuntu 16 only
# install docker ref. https://docs.docker.com/engine/installation/linux/ubuntu/#set-up-the-repository
  # remove previous version if any
  sudo apt -y remove docker docker-engine docker.io

  # set up apt repository
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - ; sudo apt-key fingerprint 0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  # install docker (CE version)
  sudo apt update; sudo apt install -y docker.io

  # aftermath check
  sudo docker --version
  sudo docker run hello-world


  # setup so that no sudo when use docker ref. https://docs.docker.com/engine/installation/linux/linux-postinstall/#manage-docker-as-a-non-root-user
    sudo groupadd docker; sudo usermod -aG docker "$USER" # create user group docker and add current user to it

    # prompt to log out and log in again
    echo "
      #Please log out and log in again!
      sudo reboot

      #After that, verify we can call docker without sudo as
      docker --version
      docker run hello-world
    "

# install docker-compose command ref. https://stackoverflow.com/a/36689427/248616 -> original guide https://docs.docker.com/compose/install/
  note="
    retrieve latest version
    1) grep with regex showing matched part only ref. https://stackoverflow.com/a/3423809/248616,
    2) curl without progress ref. https://stackoverflow.com/a/7373922/248616
  "
  latestUrl=`curl -s https://github.com/docker/compose/releases/latest | grep -Eo "(http[^\"]+)"` #sample result of this command https://github.com/docker/compose/releases/tag/1.17.1
  version=`echo "$latestUrl" | cut -d '/' -f8` #bash split string and get nth element ref. https://unix.stackexchange.com/a/312281/17671
  echo $version

  curl -L "https://github.com/docker/compose/releases/download/$version/docker-compose-`uname -s`-`uname -m`" > ./docker-compose
  sudo mv ./docker-compose /usr/bin/docker-compose
  sudo chmod +x /usr/bin/docker-compose

  echo; docker-compose -v

# refresh docker service
sudo systemctl start docker
sudo systemctl --no-pager status docker