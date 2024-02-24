#!/bin/bash

# sudo passwd root
# ubuntu 18
 sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# ubuntu 16
# sudo sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config
 sudo service ssh restart
 sudo apt-get update -y
 sudo apt-get upgrade -y
 sudo apt-get dist-upgrade -y
 sudo apt-get install mc git htop atop git rsync nano vim sshpass open-vm-tools net-tools -y



