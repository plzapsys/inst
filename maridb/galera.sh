
# /etc/mysql/mariadb.conf.d/60-galera.cnf

[galera]
# --- Mandatory settings for Galera ---
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0
# --- Galera Provider Configuration ---
wsrep_on=ON
wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so
# --- Galera Cluster Configuration ---
# This name must be identical on all nodes
wsrep_cluster_name="VoIPmonitor_Cluster"
# List all nodes in the cluster. When starting, a node will try to connect to these to sync.
wsrep_cluster_address="gcomm://192.168.23.211,192.168.23.212,192.168.23.213"
# --- Galera Synchronization Method ---
# 'rsync' is a common and reliable choice for state transfers.
wsrep_sst_method=rsync
# --- INDIVIDUAL NODE Configuration ---
# THESE TWO LINES MUST BE UNIQUE ON EACH NODE!
wsrep_node_address="192.168.23.211"  # Use this node's own IP address
wsrep_node_name="Node-01"         # Give each node a unique name
# --- Galera Performance Tuning ---
# gcache stores the replication writeset. 10G is a good starting point.
wsrep_provider_options="gcache.size=10G;gcache.recover=yes;gcs.fc_limit=500000;"

#---------------------------------------------------------------------
# 3. On your first node (e.g., Node-01)
galera_new_cluster

# -4 On Node-02 and Node-03
systemctl start mariadb

# ---------- Monitoring Cluster Status ------------------------------------------
# Regularly monitor your Galera Cluster to ensure its health and consistency.

# Expected value: the total number of nodes configured (e.g., 3).
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size'"

# wsrep_local_state_comment / wsrep_local_state: The state of the current node.
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_local_state_comment'"
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_local_state'"
    # Synced (4): Node is fully synchronized and operational.
    # Donor/Desync (2): Node is transferring state to another node.
    # Joining (1): Node is in the process of joining the cluster.
    # Donor/Stalled (1): Node is stalled.

# wsrep_incoming_addresses: List of incoming connections from other cluster nodes.
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_incoming_addresses'"

# wsrep_cert_deps_distance: Indicates flow control. A high value suggests that this node is falling behind and flow control may activate.
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_cert_deps_distance'"

# wsrep_flow_control_paused: Percentage of time the node was paused due to flow control. High values indicate a bottleneck.
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_flow_control_paused'"

# wsrep_local_recv_queue / wsrep_local_send_queue: Size of the receive/send queue. Ideally, these should be close to 0. Sustained high values indicate replication lag or node issues.
mariadb -h 127.0.0.1 -u root -p -e "SHOW STATUS LIKE 'wsrep_local_recv_queue'"


# -------------- from Site MariaDB
# https://mariadb.com/docs/galera-cluster/galera-cluster-quickstart-guides/mariadb-galera-cluster-guide
[mysqld]
# Basic MariaDB settings
binlog_format=ROW
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0 # Binds to all network interfaces. Adjust if you have a specific private IP for cluster traffic.

# Galera Provider Configuration
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so # Adjust path if different (e.g., /usr/lib64/galera-4/libgalera_smm.so)

# Galera Cluster Configuration
wsrep_cluster_name="my_galera_cluster" # A unique name for your cluster

# IP addresses of ALL nodes in the cluster, comma-separated.
# Use private IPs if available for cluster communication.
wsrep_cluster_address="gcomm://node1_ip_address,node2_ip_address,node3_ip_address"

# This node's specific configuration
wsrep_node_name="node1" # Must be unique for each node (e.g., node1, node2, node3)
wsrep_node_address="node1_ip_address" # This node's own IP address


