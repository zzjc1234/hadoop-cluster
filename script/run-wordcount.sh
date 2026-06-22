#!/bin/bash
set -e

rm -rf input
mkdir input
echo "Hello Docker" >input/file2.txt
echo "Hello Hadoop" >input/file1.txt

hdfs dfs -rm -r -f input output
hadoop fs -mkdir -p input
hdfs dfs -put ./input/* input

EXAMPLES_JAR=$(ls "$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar | head -n 1)
hadoop jar "$EXAMPLES_JAR" wordcount input output

echo -e "\ninput file1.txt:"
hdfs dfs -cat input/file1.txt

echo -e "\ninput file2.txt:"
hdfs dfs -cat input/file2.txt

echo -e "\nwordcount output:"
hdfs dfs -cat output/part-r-00000
