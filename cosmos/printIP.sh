#!/bin/bash

host_string=("'root@20.220.200.72'" "'root@20.163.215.150'" "'root@20.163.221.185'" "'root@20.231.77.191'")
name="deploy-cosmos"
for i in $( seq 0 ${#host_string[@]} )

do
  echo "./earthd start --home=./workspace/earth/validator${i}" Enter
  val=`expr $i + 1`
  echo "start node${val}!"
  

done

