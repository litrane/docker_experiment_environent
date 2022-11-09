#!/bin/bash

host_string=("-p 2205 root@127.0.0.1" "-p 2206 root@127.0.0.1" "-p 2207 root@127.0.0.1" "-p 2208 root@127.0.0.1")
name="deploy-cosmos2"

if [ "$1" == "connect" ]; then 
  tmux new-session -s $name -d
fi 

for i in $( seq 0 ${#host_string[@]} )

do
  tmux_name="$name:$i"
  #tmux neww -a -n "$client" -t $name
  if [ "$1" == "connect" ]; then 
  tmux new-window -n "$i" -t "$name" -d
  tmux send -t $tmux_name "ssh ${host_string[i]}" Enter
elif [ "$1" == "init" ]; then
  tmux send -t $tmux_name "git clone https://github.com/litrane/cosmos_experiment_file.git" Enter
  tmux send -t $tmux_name "cd cosmos_experiment_file" Enter
  tmux send -t $tmux_name "nohup ./marsd start --home=./workspace/mars/validator${i} > output 2>&1 & " Enter
elif [ "$1" == "start" ]; then
  tmux send -t $tmux_name "cd cosmos" Enter
  tmux send -t $tmux_name "./marsd start --home=./workspace/mars/validator${i} " Enter
elif [ "$1" == "update" ]; then
  #tmux send -t $tmux_name "cd theta_experiment_file" Enter
  tmux send -t $tmux_name "git clean -xfd" Enter
  tmux send -t $tmux_name "git pull" Enter
elif [ "$1" == "clean" ]; then
  tmux send -t $tmux_name "cd ~" Enter
  tmux send -t $tmux_name "rm -rf cosmos_experiment_file" Enter
fi
  val=`expr $i + 1`
  echo "start node${val}!"
  

done

