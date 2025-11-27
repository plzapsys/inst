
# eth0 - 192.168.33.x - external 
# eth1 - 192.168.30.x - only docker swarm
# -------------------------------------------------------------------------------------------------
# Example

# node1
docker swarm init \
  --data-path-addr 192.168.30.21 \
  --advertise-addr 192.168.30.21

# manager 
docker swarm join-token manager

# node2
docker swarm join \
  --token .....  \
  --data-path-addr 192.168.30.22 \
  --advertise-addr 192.168.30.22 \
  192.168.30.21:2377
 
# node3
docker swarm join \
  --token .....  \
  --data-path-addr 192.168.30.23 \
  --advertise-addr 192.168.30.23 \
  192.168.30.21:2377
  
# ---------------------------------------------------------------------------------------------------
# for worker 
	docker swarm join-token worker

# node4
docker swarm join \
  --token ..... \
  --data-path-addr 192.168.30.24 \
  --advertise-addr 192.168.30.24 \
  192.168.30.21:2377

# node5
docker swarm join \
  --token ..... \
  --data-path-addr 192.168.30.25 \
  --advertise-addr 192.168.30.25 \
  192.168.30.21:2377
# node6
docker swarm join \
  --token ..... \
  --data-path-addr 192.168.30.26 \
  --advertise-addr 192.168.30.26 \
  192.168.30.21:2377
# ----------------------------------------------------------------------------------------------

# check cluster 
docker node ls

# cerate networks 
docker network create --driver=overlay --attachable obs-net 
docker network create --driver=overlay --attachable proxy 
docker network create --driver=overlay --attachable redisnet
# check network 
docker network inspect obs-net
# docker service ls
# docker stack deploy -d=true -c {compose-file} {name}
# docker service update --force {service_name}
# docker service rm {service}

# -----------------------------------------------------------
# Init only one network eth0
docker swarm init --advertise-addr 192.168.23.71
# check
docker node ls
# get manager token 
docker swarm join-token manager
# manager node 
docker swarm join --token ...... 192.168.23.71:2377
# get token for worker on manager-1 node
docker swarm join-token worker
# work node
docker swarm join --token ..... 192.168.23.71:2377


# reset docker swarm 
docker stack rm <name-stack>

# on all nodes
docker swarm leave --force

sudo systemctl stop docker
sudo rm -rf /var/lib/docker/network/files/
sudo rm -rf /var/lib/docker/swarm/state.json
sudo rm -rf /var/lib/docker/swarm/certificates/
sudo systemctl start docker
docker ps -aq | xargs -r docker rm -f
docker volume prune -f

# ----------------------------------------------------------------------------------
