FROM ubuntu:18.04
MAINTAINER Chris Morris

RUN apt update
RUN apt install -y default-jre wget bzip2 ca-certificates curl git iproute2

ADD spark-3.0.0-bin-hadoop2.7.tgz /usr/local/

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.8.2-Linux-x86_64.sh -O miniconda.sh && \
/bin/bash miniconda.sh -b -p /opt/conda

ENV PATH="/usr/local/spark-3.0.0-bin-hadoop2.7/bin:${PATH}"
ENV PATH="/usr/local/spark-3.0.0-bin-hadoop2.7/sbin:${PATH}"
ENV PATH="/opt/conda/bin:${PATH}"

COPY environment.yml .
RUN conda env create -f environment.yml

ENV PYSPARK_PYTHON="/opt/conda/envs/sparkenv/bin/python" \
    PYSPARK_DRIVER_PYTHON="/opt/conda/envs/sparkenv/bin/ipython"

# Spark UI port
EXPOSE 7077 8080 4040 20000-60000 

RUN apt-get install -y rsync
ADD hadoop-2.7.7 /usr/local/hadoop

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
