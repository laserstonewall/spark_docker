# Spark Docker

A project to experiment with Docker. Goal is to set up a local version of Spark, but which uses individual Docker containers as nodes in a Spark cluster.

## Notes

Currently starting up two containers: a master and worker.

Using the Spark standalone deployment.

## Downloads

In order to load Spark and Hadoop into the containers, you must download.

Spark:
```
wget https://archive.apache.org/dist/spark/spark-3.0.0/spark-3.0.0-bin-hadoop2.7.tgz
```
Hadoop:
```
wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
```

## Dockerfile

We start with the base Ubuntu 18.04 image. We run `apt update` to get the latest repository information, then add a few necessary dependencies like Java.

The compressed Spark binaries are moved to `/usr/local` in the image with the `ADD` command. This location is fairly arbitrary, as Spark doesn't assume any specific location, instead we'll need to add the location the image's `PATH` variable later. The Docker `ADD` command will automatically extract the compressed files to our specified location.

Since the goal of this project is to learn and practice creating interconnected Docker images, rather than start with the existing [Docker Miniconda image](https://hub.docker.com/r/continuumio/miniconda3), we pull and run the `miniconda` install shell script from Anaconda, installing to `/opt/conda`. The `-b` option prevents it from adding any path variables to `~/.bashrc`, as we'll add those manually next.

Next, we'll add the location of the Spark binaries, which live in `<path to Spark folder>/bin` and `<path to Spark folder>/sbin`, to the image's `PATH` variable. All the files here will need to be accessible by the system in order to start up master/worker nodes. Additionally, we add the `conda` location to `PATH` as well.

For the the Spark jobs using Python, we'll use a custom `conda` environment, that will be built the same on each node (master and workers). This will allow us to use any Python packages we want on all the nodes. We `COPY` an `environment.yml` file defining our required Python packages/conda environment into the container, then use it to create our Python environment by running 

```bash
conda env create -f environment.yml
```

We can then let Spark know that we want to use this particular Python environment when running PySpark by setting the `PYSPARK_PYTHON` and `PYSPARK_DRIVER_PYTHON` environment variables. These variables set the Python binary used to execute our PySpark processes on the worker and driver nodes, respectively. For the driver Python, we set the environment's `ipython`, which will give us a nicer Python terminal experience if we decide to run PySpark interactively.

In order for Spark to run all its services properly, it will need to have communication available on several ports. We use the `EXPOSE` command to allow these ports to communicate. By default, if the protocol is unspecific `TCP` is used.

**WRITE MORE ABOUT HADOOP PART WHEN YOU FIGURE IT OUT**

Finally, Spark needs the `JAVA_HOME` environment variable set in order to use the Java installation, which it turns out is at `/usr/lib/jvm/java-11-openjdk-amd64` for Ubuntu 18.04's `default-jre` installed above.
