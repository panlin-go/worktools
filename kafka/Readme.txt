#!/bin/bash

# install
docker pull docker.io/wurstmeister/kafka
docker pull docker.io/wurstmeister/zookeeper

# run
docker run -d --name zookeeper -p 2181:2181 -t wurstmeister/zookeeper  
docker run -d --name kafka -e HOST_IP=localhost -e KAFKA_ADVERTISED_HOST_NAME=kafka -e KAFKA_ADVERTISED_PORT=9092 -e KAFKA_BROKER_ID=1 -e ZK=zk -p 9092:9092 --link zookeeper:zk -t wurstmeister/kafka  

docker exec -it containerid /bin/sh
cd /opt/kafka_2.12-1.0.0
# create topic
bin/kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1 --partitions 1 --topic mykafka

# create producer
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic mykafka 

# create consumer
bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic mykafka --from-beginning 

# using confluent-kafka-go 
git clone https://github.com/edenhill/librdkafka.git
cd librdkafka
./configure --prefix /usr
make
sudo make install

# set env
echo "export PKG_CONFIG_PATH=/usr/lib/pkgconfig" >> /etc/profile
source /etc/profile

# go-code
go get -u github.com/confluentinc/confluent-kafka-go/kafka
