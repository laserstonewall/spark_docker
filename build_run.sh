#/bin/bash

# Build from the Dockerfile if changes have been made
docker pull ubuntu:18.04
docker build -t ubuntu_spark:latest .

# Start up the container that will function as the master node
docker run \
	--name spark-master \
	--hostname sparkdockermaster \
	-v ~/docker/spark/data:/data \
	--cpus 2 \
	-p 8080:8080 \
	-p 4040:4040 \
	--mount source=mastervol,target=/volume \
	-dit \
	ubuntu_spark
# Start up a spark master on this container
docker exec -ti spark-master bash -c "start-master.sh -h sparkdockermaster"

# Start up containers to be used as worker nodes
docker run \
	--name spark-worker1 \
	--hostname sparkworker1 \
	--cpus 2 \
	--expose 9001 \
	-p 8081:8081 \
	--mount source=worker1vol,target=/volume \
	-dit \
	ubuntu_spark

# Start up spark worker node
docker exec -ti spark-worker1 start-slave.sh spark://172.17.0.2:7077 -p 9001 -h sparkworker1

# Start the DNS server allowing workers to communicate
docker run --rm -d --hostname dns.mageddo --name dns-proxy-server -p 5380:5380 \                                 ✔ 
  -v /opt/dns-proxy-server/conf:/app/conf \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/resolv.conf:/etc/resolv.conf \
  defreitas/dns-proxy-server
# docker run --name staging -dit ubuntu_spark

# Hop into the master node to start
docker attach spark-master
