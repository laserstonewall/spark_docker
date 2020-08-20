#/bin/bash

docker build -t ubuntu_spark:latest .

docker run \
	--name spark-master \
	--hostname sparkdockermaster \
	--add-host sparkworker1:172.17.0.3 \
	-v ~/docker/spark/data:/data \
	--cpus 2 \
	-p 8080:8080 \
	-p 4040:4040 \
	--mount source=mastervol,target=/volume \
	-dit \
	ubuntu_spark

docker exec -ti spark-master bash -c "start-master.sh -h sparkdockermaster"

docker run \
	--name spark-worker1 \
	--hostname sparkworker1 \
	--add-host sparkdockermaster:172.17.0.2 \
	--cpus 2 \
	--expose 9001 \
	-p 8081:8081 \
	--mount source=worker1vol,target=/volume \
	-dit \
	ubuntu_spark
docker exec -ti spark-worker1 start-slave.sh spark://172.17.0.2:7077 -p 9001 -h sparkworker1

# docker run --name staging -dit ubuntu_spark

docker attach spark-master
