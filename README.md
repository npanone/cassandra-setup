# cassandra-setup

## Virtual Box - Ubuntu 16.04 Server

* Create a new virtual machine with 2Gb of ram and 32Gb of Disk Space
* Set Network Adapter 1 to Nat Service  [Nat Service needs to be configured ahead of time](https://www.virtualbox.org/manual/ch06.html#network_nat_service)
* Set Network Adapter 2 to Host-only  [Host-only network needs to be configured ahead of time](https://www.virtualbox.org/manual/ch06.html#network_hostonly)
* Install Ubuntu 16.04 Server from ISO 
* Edit /etc/network/interfaces and enable the second adapter _(for testing dhcp should be fine)_
* Shutdown the VM
* Clone the VM and give it a unique name
* Start the Clone
* Change the hostname, also don't forget to change the hostname in /etc/hosts as well
* Pull down the script ex. curl -O https://raw.githubusercontent.com/npanone/cassandra-setup/master/script.sh
* Modify the script variables
* Make the script executable
* Execute the script with root permissions ;)

## Modifying the Script Variables - Example

Let's assume we're making a three node cluster.  Eth0 on all of our machines is our gateway to the outside world and Eth1 is our internal network.  We're going to call our cluster **Amazing**, and our DataCenter is named **Super** and the rack is called **Bob**.

Node 1: 
Eth0: 10.0.0.2 
Eth1: 172.31.254.2

Node 2: 
Eth0: 10.0.0.3
Eth1: 172.31.254.3

Node 3: 
Eth0: 10.0.0.4
Eth1: 172.31.254.4

The first server we configure will need to be our seed node. It's configuration would look like 

**Node 1**
```
SEEDS=10.0.0.2
LISTEN_ADDRESS=10.0.0.2
RPC_ADDRESS=172.31.254.2
CLUSTER_NAME="Amazing"
DATACENTER_NAME="Super"
RACK_NAME="Bob"
```

The other nodes will look to Node 1, as Node 1 is a chatterbox that knows all the juicy details of the data network configuration.  Let's configure the other two nodes.

**Node 2**
```
SEEDS=10.0.0.2
LISTEN_ADDRESS=10.0.0.3
RPC_ADDRESS=172.31.254.3
CLUSTER_NAME="Amazing"
DATACENTER_NAME="Super"
RACK_NAME="Bob"
```
**Node 3**
```
SEEDS=10.0.0.2
LISTEN_ADDRESS=10.0.0.4
RPC_ADDRESS=172.31.254.4
CLUSTER_NAME="Amazing"
DATACENTER_NAME="Super"
RACK_NAME="Bob"
```

## To Infinity and Beyond...
When executing the script on a server that'll join an existing cluster, anything with 2 or more servers, you'll need to add the ```auto_bootstrap: false``` line to the cassandra.yaml file.  
