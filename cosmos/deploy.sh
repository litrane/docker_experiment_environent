#!/bin/bash

#host_string=("-p 22  pzl97@apt187.apt.emulab.net" "-p 22 pzl97@apt173.apt.emulab.net" "-p 22 pzl97@apt167.apt.emulab.net" "-p 22 pzl97@apt169.apt.emulab.net")
host_string=(" root@10.10.1.1" " root@10.10.1.2" " root@10.10.1.3" " root@10.10.1.4")
name="deploy-cosmos1"

if [ "$1" == "connect" ]; then 
  tmux new-session -s $name -d
fi 

for i in $( seq 0 `expr ${#host_string[@]} - 1 ` )

do
  tmux_name="$name:$i"
  #tmux neww -a -n "$client" -t $name
  if [ "$1" == "connect" ]; then 
  tmux new-window -n "$i" -t "$name" -d
  tmux send -t $tmux_name "ssh ${host_string[i]}" Enter
elif [ "$1" == "init" ]; then
  # tmux send -t $tmux_name "git clone -b cloud  https://github.com/litrane/docker_experiment_environent.git" Enter
  # tmux send -t $tmux_name "cd docker_experiment_environent" Enter
  #tmux send -t $tmux_name "nohup ./earthd start --home=./workspace/earth/validator${i} > output 2>&1 & " Enter
  tmux send -t $tmux_name "scp ./cosmos.zip ${host_string[i]}:/root/" Enter
elif [ "$1" == "start" ]; then
  #tmux send -t $tmux_name "cd ~/docker_experiment_environent/cosmos" Enter
  tmux send -t $tmux_name "cd ~/cosmos" Enter
  tmux send -t $tmux_name "nohup ./earthd start --home=./workspace/earth/validator${i}  > ./output.log 2>&1 & " Enter
elif [ "$1" == "update" ]; then
  #tmux send -t $tmux_name "cd theta_experiment_file" Enter
  tmux send -t $tmux_name "git clean -xfd" Enter
  tmux send -t $tmux_name "git pull" Enter
elif [ "$1" == "clean" ]; then
  tmux send -t $tmux_name "cd ~" Enter
  tmux send -t $tmux_name "rm -rf docker_experiment_environent" Enter
fi
  val=`expr $i + 1`
  echo "start node${val}!"
  

done

