#!/bin/bash
## -p Westmere indicates we are using general partition.
##SBATCH -p general
## -N 4 means we are going to use 4 nodes to run Hadoop cluster
#SBATCH -N 4
## -c 12 means we are going to use 12 cores on each node.
#SBATCH -c 12
## --ntasks-per-node=1 means each node runs single datanode/namenode.
## When you write your own SLURM batch, you DON'T need to change ntasks-per-node or exclusive.
#SBATCH --ntasks-per-node=1
#SBATCH --exclusive

# where to store the temp configure files.
# make sure that the configure files are GLOBALLY ACCESSIBLE
export HADOOP_CONF_DIR=/apps2/myHadoop/Sep012015/scratch/${USER}_hadoop-conf.$SLURM_JOBID
#################NO CHANGE############################
export SPARK_CONF_DIR=$HADOOP_CONF_DIR

if [ "z$HADOOP_OLD_DIR" == "z" ]; then
  myhadoop-configure.sh
else
  myhadoop-configure.sh -p $HADOOP_OLD_DIR
fi

# test if the HADOOP_CONF_DIR is globally accessible
if ! srun ls -d $HADOOP_CONF_DIR; then
  echo "The configure files are not globally accessible.
       Please consider the the shared, home, or scratch directory to put your HADOOP_CONF_DIR.
       For example, export HADOOP_CONF_DIR=/scratch/scratch2/$USER_hadoop-conf.$SLURM_JOBID"
  myhadoop-cleanup.sh
  rm -rf $HADOOP_CONF_DIR
  exit 1
fi
$HADOOP_HOME/sbin/start-all.sh
sleep 5
hdfs dfs -ls /
$SPARK_HOME/sbin/start-all.sh

#################NO CHANGE END########################
# run spark
spark-shell -i enrollment.scala

# copy out the results
##hdfs dfs -ls /scala_outputs
##hdfs dfs -get /scala_outputs ./

#################NO CHANGE############################
$SPARK_HOME/sbin/stop-all.sh
$HADOOP_HOME/sbin/stop-all.sh
myhadoop-cleanup.sh
rm -rf $HADOOP_CONF_DIR