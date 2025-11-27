

# -------------------- dsw1 cluster ----------------------------------------------------------------------
# node1
docker swarm init \
  --data-path-addr 192.168.30.21 \
  --advertise-addr 192.168.30.21

docker network create --driver=overlay --attachable obs-net 
docker network create --driver=overlay --attachable proxy

# for manager 
docker swarm join-token manager

# node2
export SWARM_TOKEN="........"
docker swarm join \
  --token $SWARM_TOKEN  \
  --data-path-addr 192.168.30.22 \
  --advertise-addr 192.168.30.22 \
  192.168.30.21:2377
 
# node3
export SWARM_TOKEN="......."
docker swarm join \
  --token $SWARM_TOKEN  \
  --data-path-addr 192.168.30.23 \
  --advertise-addr 192.168.30.23 \
  192.168.30.21:2377
  
# ---------------------------------------------------------------------------------------------------
# for worker 
docker swarm join-token worker
# node4
export SWARM_TOKEN="........"
docker swarm join \
  --token $SWARM_TOKEN \
  --data-path-addr 192.168.30.24 \
  --advertise-addr 192.168.30.24 \
  192.168.30.21:2377
  
# node5
export SWARM_TOKEN="......"
docker swarm join \
  --token $SWARM_TOKEN\
  --data-path-addr 192.168.30.25 \
  --advertise-addr 192.168.30.25 \
  192.168.30.21:2377
  
# node6
export SWARM_TOKEN="......"
docker swarm join \
  --token $SWARM_TOKEN \
  --data-path-addr 192.168.30.26 \
  --advertise-addr 192.168.30.26 \
  192.168.30.21:2377
# ----------------------------------------------------------------------------------------------

 
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
  --data-path-addr 192.168.30.42 \
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


# -------------------- dsw3 cluster ----------------------------------------------------------------------
# node1
docker swarm init \
  --data-path-addr 192.168.30.31 \
  --advertise-addr 192.168.30.31

docker network create --driver=overlay --attachable obs-net 
docker network create --driver=overlay --attachable proxy

# for manager 
docker swarm join-token manager
# node2
export SWARM_TOKEN="........"
docker swarm join \
  --token $SWARM_TOKEN  \
  --data-path-addr 192.168.30.32 \
  --advertise-addr 192.168.30.32 \
  192.168.30.31:2377
 
# node3
export SWARM_TOKEN="......."
docker swarm join \
  --token $SWARM_TOKEN  \
  --data-path-addr 192.168.30.33 \
  --advertise-addr 192.168.30.33 \
  192.168.30.31:2377
  
# ---------------------------------------------------------------------------------------------------
# for worker 
docker swarm join-token worker
# node4
export SWARM_TOKEN="........"
docker swarm join \
  --token $SWARM_TOKEN \
  --data-path-addr 192.168.30.34 \
  --advertise-addr 192.168.30.34 \
  192.168.30.31:2377

# node5
export SWARM_TOKEN="......"
docker swarm join \
  --token $SWARM_TOKEN\
  --data-path-addr 192.168.30.35 \
  --advertise-addr 192.168.30.35 \
  192.168.30.31:2377
  
# node6
export SWARM_TOKEN="......"
docker swarm join \
  --token $SWARM_TOKEN \
  --data-path-addr 192.168.30.36 \
  --advertise-addr 192.168.30.36 \
  192.168.30.31:2377
# ----------------------------------------------------------------------------------------------
