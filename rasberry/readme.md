# Setup Rasberry Pi

## Install Raspbian
ref. [here](https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview) or [here](https://itsfoss.com/install-ubuntu-server-raspberry-pi/)

## Install Wifi
ref. [here](https://itsfoss.com/connect-wifi-terminal-ubuntu/)
open file `50-cloud-init.yaml` and change like this
```shell
O sudo nano /etc/netplan/50-cloud-init.yaml

network:
    ethernets:
        eth0:
            dhcp4: true
            optional: true
    version: 2
    wifis:
        wlan0:
            dhcp4: true
            optional: true
            access-points:
                "Luxoft":
                     password: "1"
```

and then run
```shell
sudo netplan generate
sudo netplan apply
```

## SSH from other machine
ref. [here](https://www.raspberrypi.org/documentation/remote-access/ssh/)
add `~/.ssh/id_rsa.pub` from machine into rasberry pi server `~/.ssh/authorized_keys`
In rasberry run:
```shell
ip addr
```
copy ip `inet` in `wlan0` and ssh from local machine
```shell
ssh ubuntu@192.168.1.13
```

## Install package
```shell
sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev \
libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git \
gcc docker-compose

```
## Install pyenv
```shell
curl https://pyenv.run | bash
```
add to `~/.bashrc`
```shell
export PATH="/home/pi/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```
## Install python
```shell
pyenv install 3.9.15
pyenv global 3.9.15
```
## Install pip
```shell
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
```

## Setup SSH
ref. [here](https://dev.to/zduey/how-to-set-up-an-ssh-server-on-a-home-computer)
