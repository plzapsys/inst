
 
# -------------------- dsw2 cluster ----------------------------------------------------------------------
# node1
docker swarm init \
  --data-path-addr 192.168.30.41 \
  --advertise-addr 192.168.30.41

docker network create --driver=overlay --attachable obs-net 
docker network create --driver=overlay --attachable proxy
  
# for manager 
docker swarm join-token manager
# node2
export SWARM_TOKEN="......."
docker swarm join \
  --token $SWARM_TOKEN  \
  --data-path-addr 192.168.40.42 \
  --advertise-addr 192.168.30.42 \
  192.168.30.41:2377
# node3
export SWARM_TOKEN="......."
docker swarm join \
  --token $SWARM_TOKEN  \
  --data-path-addr 192.168.30.43 \
  --advertise-addr 192.168.30.43 \
  192.168.30.41:2377
# ---------------------------------------------------------------------------------------------------
# for worker 
docker swarm join-token worker
# node4
export SWARM_TOKEN="........"
docker swarm join \
  --token $SWARM_TOKEN \
  --data-path-addr 192.168.30.44 \
  --advertise-addr 192.168.30.44 \
  192.168.30.41:2377
# node5
export SWARM_TOKEN="......"
docker swarm join \
  --token $SWARM_TOKEN\
  --data-path-addr 192.168.30.45 \
  --advertise-addr 192.168.30.45 \
  192.168.30.41:2377
# node6
export SWARM_TOKEN="......"
docker swarm join \
  --token $SWARM_TOKEN \
  --data-path-addr 192.168.30.46 \
  --advertise-addr 192.168.30.46 \
  192.168.30.41:2377
# ----------------------------------------------------------------------------------------------


