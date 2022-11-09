host_string=("-p 22  pzl97@apt103.apt.emulab.net" "-p 22 pzl97@apt117.apt.emulab.net" "-p 22 pzl97@apt106.apt.emulab.net" "-p 22 pzl97@apt096.apt.emulab.net")
echo ${#host_string[@]}
for i in $( seq 0 `expr ${#host_string[@]} - 1 ` )
do
  val=`expr $i + 1`
  echo "start node${i}!"
  

done