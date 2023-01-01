#!/bin/bash
n=$1
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
    sleep 1
done

# install java
wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
sudo add-apt-repository 'deb https://apt.corretto.aws stable main' -y
sudo apt-get update -y; sudo apt-get install -y java-11-amazon-corretto-jdk

# download and install kafka 
wget https://archive.apache.org/dist/kafka/3.0.0/kafka_2.13-3.0.0.tgz
tar xzf kafka_2.13-3.0.0.tgz
sudo mkdir kafka_2.13-3.0.0/data
sudo chown -R ubuntu:ubuntu kafka_2.13-3.0.0
rm kafka_2.13-3.0.0/config/server.properties

# add zookeeper server id
myid_n=$(($n+ 1))
cat <<EOF >>kafka_2.13-3.0.0/data/myid
$myid_n
EOF

cat <<EOF >>kafka_2.13-3.0.0/config/server.properties
# svr=$( hostname | awk '{ print substr($0,length,1) }' )
############################# Server Basics #############################
# The id of the broker. This must be set to a unique integer for each broker.
broker.id=$( hostname | awk '{ print substr($0,length,1) }' )
############################# Socket Server Settings #############################
listeners=PLAINTEXT://kafka-$( hostname | awk '{ print substr($0,length,1) }' ):9092
advertised.listeners=PLAINTEXT://kafka-$( hostname | awk '{ print substr($0,length,1) }' ):9092
# The number of threads that the server uses for receiving requests from the network and sending responses to the network
num.network.threads=3
# The number of threads that the server uses for processing requests, which may include disk I/O
num.io.threads=8
# The send buffer (SO_SNDBUF) used by the socket server
socket.send.buffer.bytes=102400
# The receive buffer (SO_RCVBUF) used by the socket server
socket.receive.buffer.bytes=102400
# The maximum size of a request that the socket server will accept (protection against OOM)
socket.request.max.bytes=104857600
############################# Log Basics #############################
# A comma separated list of directories under which to store log files
log.dirs=/tmp/kafka-logs
num.partitions=3
# The number of threads per data directory to be used for log recovery at startup and flushing at shutdown.
# This value is recommended to be increased for installations with data dirs located in RAID array.
num.recovery.threads.per.data.dir=1
############################# Internal Topic Settings  #############################
# The replication factor for the group metadata internal topics "__consumer_offsets" and "__transaction_state"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
############################# Log Flush Policy #############################
# The maximum amount of time a message can sit in a log before we force a flush
#log.flush.interval.ms=1000
############################# Log Retention Policy #############################
# The minimum age of a log file to be eligible for deletion due to age
log.retention.hours=168
# The maximum size of a log segment file. When this size is reached a new log segment will be created.
log.segment.bytes=1073741824
# The interval at which log segments are checked to see if they can be deleted according
# to the retention policies
log.retention.check.interval.ms=300000
############################# Zookeeper #############################
zookeeper.connect=ip-172-31-80-10.ec2.internal:2181,ip-172-31-80-11.ec2.internal:2181,ip-172-31-80-12.ec2.internal:2181
# Timeout in ms for connecting to zookeeper
zookeeper.connection.timeout.ms=18000
############################# Group Coordinator Settings #############################
group.initial.rebalance.delay.ms=0
EOF

rm kafka_2.13-3.0.0/config/zookeeper.properties

cat <<EOF >>kafka_2.13-3.0.0/config/zookeeper.properties
# the location to store the in-memory database snapshots and, unless specified otherwise, the transaction log of updates to the database.
dataDir=/home/ubuntu/kafka_2.13-3.0.0/data
# the port at which the clients will connect
clientPort=2181
# disable the per-ip limit on the number of connections since this is a non-production config
maxClientCnxns=0
# the basic time unit in milliseconds used by ZooKeeper. It is used to do heartbeats and the minimum session timeout will be twice the tickTime.
tickTime=2000
# The number of ticks that the initial synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# zoo servers
# these hostnames such as zookeeper-1 come from the /etc/hosts file
server.1=ip-172-31-80-10.ec2.internal:2888:3888
server.2=ip-172-31-80-12.ec2.internal:2888:3888
server.3=ip-172-31-80-12.ec2.internal:2888:3888
EOF