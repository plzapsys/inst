
# Install on Rocky Linux

sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf -y install docker-ce docker-ce-cli containerd.io 
# docker-compose-plugin

sudo systemctl --now enable docker

usermod -aG docker $USER
newgrp docker


docker -v

docker compose version

