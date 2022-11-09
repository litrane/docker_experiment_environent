#!/bin/sh

BINARY=marsd
BINARY_IMAGE=cosmoscontracts/juno:latest
CHAINID=mars
CHAINDIR=./workspace	

VALIDATOR='validator'
NODE='node'

KBT="--keyring-backend=test"
host_string=("10.10.1.5" "10.10.1.6" "10.10.1.7" "10.10.1.8")
echo "Creating $BINARY instance with home=$CHAINDIR chain-id=$CHAINID..."	

# Build genesis file incl account for passed address	
DENOM="coin"
MAXCOINS="1000000000000"$DENOM
COINS="90000000000"$DENOM	

clean_setup(){
    echo "rm -rf $CHAINDIR"
    echo "rm -f docker-compose.yaml"
    rm -rf $CHAINDIR
    rm -f docker-compose.yml
}

get_home() {
    dir="$CHAINDIR/$CHAINID/$1"
    echo $dir
}

# Initialize home directories
init_node_home () { 
    echo "init_node_home $1"
    home=$(get_home $1)
    $BINARY --home $home --chain-id $CHAINID init $1 &>/dev/null	
}

# Add some keys for funds
keys_add() {
    echo "keys_add $1"
    home=$(get_home $1)
    $BINARY --home $home keys add $1 $KBT &>> $home/config/account.txt	
}

# Add addresses to genesis
add_genesis_account() {
    echo "add_genesis_account $1"
    home=$(get_home $1)
    $BINARY --home $home add-genesis-account $($BINARY --home $home keys $KBT show $1 -a) $MAXCOINS  $KBT &>/dev/null	
    $BINARY --home $home0 add-genesis-account mars1vd39966gj72wzsvvltcspzvdu7a545gkgfrvem $MAXCOINS  $KBT &>/dev/null	
    $BINARY --home $home0 add-genesis-account mars146cqc4sf4zscfwrd2c9z6mvcz5kmf9kh5mupfj $MAXCOINS  $KBT &>/dev/null
}

# Create gentx file
gentx() {
    echo "gentx: $1"
    home=$(get_home $1)
    $BINARY --home $home gentx $1 $COINS  --chain-id $CHAINID $KBT &>/dev/null	
}

add_genesis_account_to_node0() {
    echo "add_genesis_account_to_node0: $1"
    home=$(get_home $1)
    home0=$(get_home ${VALIDATOR}0)
    $BINARY --home $home0 add-genesis-account $($BINARY --home $home keys $KBT show $1 -a) $MAXCOINS  $KBT &>/dev/null	
    $BINARY --home $home0 add-genesis-account mars1vd39966gj72wzsvvltcspzvdu7a545gkgfrvem $MAXCOINS  $KBT &>/dev/null	
    $BINARY --home $home0 add-genesis-account mars146cqc4sf4zscfwrd2c9z6mvcz5kmf9kh5mupfj $MAXCOINS  $KBT &>/dev/null
}

copy_all_gentx_and_add_genesis_account_to_node0(){
    echo "copy_all_gentx_and_add_genesis_account_to_node0"
    dir0=$(get_home ${VALIDATOR}0)
    n=1
    while ((n < $1)); do
        nodeName="${VALIDATOR}$n"
        dir=$(get_home $nodeName)
        cp $dir/config/gentx/*  $dir0/config/gentx 
        add_genesis_account_to_node0 $nodeName
        let n=n+1
    done
}

# create genesis file. node0 needs to execute this cmd
collect_gentxs_from_validator0(){
    echo "collect_gentxs_from_validator0"
    home=$(get_home ${VALIDATOR}0)
    $BINARY --home $home collect-gentxs &>/dev/null	
    echo "$home/config/genesis.json"
}


# $1 = number of node
# $2 = node type (VALIDATOR|NODE)
copy_genesis_json_from_node0_to_other_node(){
    echo "copy_genesis_json_from_node0_to_other_node"
    home0=$(get_home ${VALIDATOR}0)
    # throw an error if home0 does not exist
    n=0
    while ((n < $1)); do
        nodeName="$2$n"
        home=$(get_home $nodeName)
        cp $home0/config/genesis.json  $home/config/
        let n=n+1
    done
}

replace_stake_denomination(){
    echo "replace denomination in genesis: stake->$DENOM"
    home0=$(get_home ${VALIDATOR}0)
    sed -i "s/\"stake\"/\"$DENOM\"/g" $home0/config/genesis.json
}


# $1 = number of validators
# $2 = number of nodes
# $3 = the number of the current node
# $4 = current node type (VALIDATOR|NODE)
set_persistent_peers(){
    echo "set_persistent_peers $1 $2 $3 $4"
    currentNodeName="$4$3"
    currentNodeHome=$(get_home $currentNodeName)
    
    persistent_peers=""
    n=0
    ip_nr=0
    # validator loop
    while ((n < $1)); do
        nodeName="$VALIDATOR$n"
        ipAddress=${host_string[$ip_nr]}  #"192.168.10.$ip_nr"
        if [ "$n" != "$3"  ] || [ "$4" != "$VALIDATOR" ]; then
            home=$(get_home $nodeName)
            peer="$($BINARY --home $home tendermint show-node-id)@${ipAddress}:26656"
            if [ "$persistent_peers" != "" ]; then 
                persistent_peers=$persistent_peers","$peer ;
            else
                persistent_peers=$peer
            fi 
        fi 

        let n=n+1
        let ip_nr=ip_nr+1
    done

    # nodes loop
    let n=0
    ip_nr=$1
    while ((n < $2)); do
        nodeName="$NODE$n"
        ipAddress="192.168.10.$ip_nr"
        if [ "$n" != "$3" ] || [ "$4" != "$NODE" ]; then
            home=$(get_home $nodeName)
            peer="$($BINARY --home $home tendermint show-node-id)@${ipAddress}:26656"
            if [ "$persistent_peers" != "" ]; then 
                persistent_peers=$persistent_peers","$peer ;
            else
                persistent_peers=$peer
            fi 
        fi 

        let n=n+1
        let ip_nr=ip_nr+1
    done

   echo $currentNodeHome
   echo $persistent_peers
   sed -i "s/^persistent_peers *=.*/persistent_peers = \"$persistent_peers\"/" $currentNodeHome/config/config.toml
   
}

# $1 = number of validators
# $2 = number of nodes
set_persistent_peers_all_nodes() {
    echo "set_persistent_peers_all_nodes"
    node=0
    # validator
    while ((node < $1)); do
        set_persistent_peers $1 $2 $node $VALIDATOR 
        let node=node+1
    done

    let node=0
     # validator
    while ((node < $2)); do
        set_persistent_peers $1 $2 $node $NODE 
        let node=node+1
    done
}


# $1 = the number of the current node
# $2 = current node type (VALIDATOR|NODE)
enable_rpc_api_rosetta(){
    currentNodeName="$2$1"
    currentNodeHome=$(get_home $currentNodeName)
    
    # enable rpc
    sed -i "s/laddr = \"tcp:\/\/127.0.0.1:26657\"/laddr = \"tcp:\/\/0.0.0.0:26657\"/" $currentNodeHome/config/config.toml

    # enable api/rosetta
    sed -i "s/enable = false/enable = true/" $currentNodeHome/config/app.toml
}
 
# $1 = number of validators
# $2 = number of nodes
enable_rpc_api_rosetta_all_nodes() {
    echo "enable_rpc_api_rosetta_all_nodes"
    node=0
    # validator
    while ((node < $1)); do
        enable_rpc_api_rosetta $node $VALIDATOR 
        let node=node+1
    done

    let node=0
     # validator
    while ((node < $2)); do
        enable_rpc_api_rosetta $node $NODE 
        let node=node+1
    done
}

# $1 = number of node
# $2 = node type (VALIDATOR|NODE)
init_node () {
    n=0
    while ((n < $1)); do
        nodeName="$2$n"
        echo "########## $nodeName ###############" 
        init_node_home $nodeName
        keys_add $nodeName
        if  [ "$2" = "$VALIDATOR" ]; then
            add_genesis_account $nodeName
            gentx $nodeName
        fi 
        let n=n+1
    done

    echo "########## generate genesis.json ###############"
     if  [ "$2" = "$VALIDATOR" ]; then
            copy_all_gentx_and_add_genesis_account_to_node0 $1 
            collect_gentxs_from_validator0
            replace_stake_denomination
     fi 
    copy_genesis_json_from_node0_to_other_node $1 $2
} 


# $1 = number validators
# $2 = number of nodes
generate_docker_compose_file(){
    echo -e "version: '3'\n"
    echo -e "services:"

    n=0
    portStart=26656
    portEnd=26657
    portApi=1317
    # validator config
    while ((n < $1)); do
        nodeName="$VALIDATOR$n"
        echo " $nodeName:"
        echo "   container_name: $nodeName"
        echo "   image: $BINARY_IMAGE"
        echo "   ports:"
        echo "   - \"$portStart-$portEnd:26656-26657\""
        echo "   - \"$portApi:1317\""
        echo "   volumes:"
        echo "   - ./workspace:/workspace"
        echo "   command: /bin/sh -c 'junod start --home /workspace/test-chain-id/$nodeName'"
        echo "   networks:"
        echo "     localnet:"
        echo -e "       ipv4_address: 192.168.10.$n\n"
    
        let n=n+1
        let portStart=portEnd+1
        let portEnd=portStart+1
        let portApi=portApi+1
    done

    # validator config
    let n=0
    ip_nr=$1
    while ((n < $2)); do
        nodeName="$NODE$n"
       
        echo " $nodeName:"
        echo "   container_name: $nodeName"
        echo "   image: $BINARY_IMAGE"
        echo "   ports:"
        echo "   - \"$portStart-$portEnd:26656-26657\""
        echo "   - \"$portApi:1317\""
        echo "   volumes:"
        echo "   - ./workspace:/workspace"
        echo "   command: /bin/sh -c 'junod start --home /workspace/test-chain-id/$nodeName'"
        echo "   networks:"
        echo "     localnet:"
        echo -e "       ipv4_address: 192.168.10.$ip_nr\n"
    
        let n=n+1
        let ip_nr=ip_nr+1
        let portStart=portEnd+1
        let portEnd=portStart+1
        let portApi=portApi+1
    done

    echo "networks:"
    echo "  localnet:"
    echo "    driver: bridge"
    echo "    ipam:"
    echo "      driver: default"
    echo "      config:"
    echo "      -"
    echo "        subnet: 192.168.10.0/16"

}

# $1 = number validators
# $2 = number node
setup_nodes(){
    clean_setup
    init_node $1 $VALIDATOR
    init_node $2 $NODE
    set_persistent_peers_all_nodes $1 $2
    enable_rpc_api_rosetta_all_nodes  $1 $2
    echo "generate_docker_compose_file"
    generate_docker_compose_file $1 $2 &> docker-compose.yml
}


repl() {
PS3='Please enter your choice: '
options=("setup nodes"  "init validator" "init nodes" "clean setup" "docker compose file" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "setup nodes")
            read -p "number of validators: " valNr
            read -p "number of nodes: " nodeNr
            setup_nodes $valNr $nodeNr
            ;;
        "init validator")
            read -p "number of validators: " valNr
            init_node $valNr $VALIDATOR
            set_persistent_peers_all_nodes $valNr 0
            ;;
        "init nodes")
            read -p "number of nodes: " nodeNr
            init_node $nodeNr $NODE
            set_persistent_peers_all_nodes 0 $nodeNr
            ;;
        "clean setup")
           clean_setup
            ;;
        "docker compose file")
            read -p "number of validators: " valNr
            read -p "number of nodes: " nodeNr
            generate_docker_compose_file $valNr $nodeNr &> docker-compose.yml
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

}

"$@"
