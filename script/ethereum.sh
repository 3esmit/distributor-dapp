export _V=0

log () {
    if [ $_V -eq 1 ]; then
        echo "$@"
    fi
}

load_env(){
    log "loading env from $1"
    if [ -d $1 ]; then
        env_file="$1/.env"
    else
        env_file=$1
    fi
    if [ -f $env_file ]; then
        export $(grep -v '^#' $env_file | xargs) 
    else
        echo "Error: .env file not defined. $env_file"
        exit 1
    fi
}

generate_password(){
    if [ -f $DEPLOY_PASSWORD_FILE ]; then
        echo "Warning: File Already Exists. Will not overwrite. $DEPLOY_PASSWORD_FILE"
    elif [ -d $DEPLOY_PASSWORD_FILE ]; then
        echo "Error: Is a directory: $DEPLOY_PASSWORD_FILE"
        exit 1
    else
        < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32} > $DEPLOY_PASSWORD_FILE
    fi
}

print_enode() {
    if [ -S $IPC_FILE ]; then
        enode=`$NODE_BIN attach $IPC_FILE --exec "admin.nodeInfo.enode"`
    else
        enode=`$NODE_BIN attach ws://$ETH_RPC_WS_ADDRESS:$ETH_RPC_WS_PORT --exec "admin.nodeInfo.enode"`
    fi
    echo $enode
}

# read account address
eth_get_account() {
    if [ -S $IPC_FILE ]; then
        run_cmd="$NODE_BIN --ipcpath=$IPC_FILE account list"
    else
        run_cmd="$NODE_BIN --keystore=$KEYSTORE_DIR/$ETH_NETWORK_NAME account list"
    fi
    log "executing: $run_cmd"
    echo `$run_cmd 2>> /dev/null | egrep -o "^Account #[0-9]: {[0-9a-fA-F]{40,40}}" | egrep -o "[0-9a-fA-F]{40,40}" | sed 's/^/0x/'`
}

# read account address
eth_set_account() {
    if [ -S $IPC_FILE ]; then
        run_cmd="$NODE_BIN --ipcpath=$IPC_FILE account list"
    else
        run_cmd="$NODE_BIN --keystore=$KEYSTORE_DIR/$ETH_NETWORK_NAME account list"
    fi
    log "executing: $run_cmd"
    set_account=`$run_cmd 2>> /dev/null | egrep -o "^Account #$1: {[0-9a-fA-F]{40,40}}" | egrep -o "[0-9a-fA-F]{40,40}" | sed 's/^/0x/'`
    export ETH_DEPLOY_ADDRESS=$set_account
    echo "Deploy account set to $set_account"
}

eth_new_account() {
    if [ -S $IPC_FILE ]; then
        run_cmd="$NODE_BIN --ipcpath=$IPC_FILE account new"
    else
        run_cmd="$NODE_BIN --keystore=$KEYSTORE_DIR/$ETH_NETWORK_NAME --password=$DEPLOY_PASSWORD_FILE account new"
    fi
    log "executing: $run_cmd"

    new_account=`$run_cmd 2>> /dev/null | egrep -o "^Public address of the key:   0x[0-9a-fA-F]{40,40}" | egrep -o "0x[0-9a-fA-F]{40,40}"`
    echo "Created account $new_account and "
    

}

# run ethereum node
eth_run() {
    [ -d $ETH_TEMP ] || mkdir $ETH_TEMP
    if [ -z "$ETH_DEPLOY_ADDRESS" ]; then
        echo "Must define -a [acc_pos] or ETH_DEPLOY_ADDRESS in environment" 1>&2
        exit 1
    fi
    if [ ! -f "$DEPLOY_PASSWORD_FILE" ]; then
        echo "Password file not found"
        exit 1
    fi
    if [ ! "$ETH_RPC_HTTP_ADDRESS" = "localhost" ]; then
        echo "ETH_RPC_HTTP_ADDRESS must be localhost" 1>&2
        exit 1
    fi

    if [ ! "$ETH_RPC_WS_ADDRESS" = "localhost" ]; then
        echo "ETH_RPC_WS_ADDRESS must be localhost" 1>&2
        exit 1
    fi
    network_param="--$ETH_NETWORK_NAME"
    filesystem_param="--datadir=$DATA_DIR --ipcpath=$IPC_FILE"
    account_param="--keystore=$KEYSTORE_DIR/$ETH_NETWORK_NAME --password=$DEPLOY_PASSWORD_FILE --unlock=$ETH_DEPLOY_ADDRESS --allow-insecure-unlock"
    sync_param="--syncmode=light --gcmode=archive "
    p2p_param="--port=$ETH_P2P_PORT --maxpeers=$ETH_P2P_MAX_PEERS"
    ws_param="--ws --ws.port=$ETH_RPC_WS_PORT --ws.addr=$ETH_RPC_WS_ADDRESS --ws.origins=$ETH_RPC_ALLOWED_ORIGINS --ws.api=$ETH_RPC_API"
    rpc_param="--http --http.port=$ETH_RPC_HTTP_PORT --http.addr=$ETH_RPC_HTTP_ADDRESS --http.corsdomain=$ETH_RPC_ALLOWED_ORIGINS --http.api=$ETH_RPC_API"
    run_cmd="$NODE_BIN $network_param $filesystem_param $sync_param $p2p_param $ws_param $rpc_param $extra_param $account_param $ETH_EXTRA_PARAMS" 
    if [ -S $IPC_FILE ]; then
        echo "Warning: eth already running eth node"
    else
        log "executing: $run_cmd"
        $run_cmd 2>> $ETH_LOG_FILE &
        while [ ! -S $IPC_FILE ]; 
        do
            sleep 1
        done
    fi
}

## open interactive shell with Geth
eth_attach() {
    log "executing: $attach_cmd"
    $attach_cmd
}

wait_sync() {
    while [ `$attach_cmd --exec "net.peerCount != 0 && eth.blockNumber != 0 ? 1 : 0"` -eq 0 ] ; 
    do 
        echo "Searching for peers..."
        tail -n 2 $ETH_LOG_FILE
        sleep 10
    done
    while [ `$attach_cmd --exec "net.peerCount != 0 && eth.syncing === false ? 1 : 0"` -eq 0 ] ; 
    do 
        echo "Sync in progress..."
        tail -n 1 $ETH_LOG_FILE
        sleep 10
    done
}

wait_deposit() {
    wait_sync
    while [ `$attach_cmd --exec "eth.getBalance('$ETH_DEPLOY_ADDRESS')"` -eq 0 ];
    do 
        echo "Waiting deposit of gas at $ETH_DEPLOY_ADDRESS for deployment."
        sleep 30
    done
}

usage()
{
    echo "usage: ethereum [flags] <function> <params>"
    echo "-i, --enode"
    echo "-S, --wait-sync"
    echo "-L, --list-accounts"
    echo "-e, --env-file"
    echo "-D, --wait-deposit"
    echo "-N, --new-account"
    echo "-a, --use-acc-at-pos"
    echo "-P, --random-password"
    echo "attach"
    echo "run"
    echo "-h, --help"
}

main()
{
    while [ "$1" != "" ]; do
        case $1 in
            -v | --verbose )        _V=1
                                    ;;
            -e | --env-file )       shift 
                                    load_env $1
                                    ;;
            -i | --enode )          enode=1
                                    ;;
            -S | --wait-sync )      waits=1
                                    ;;
            -D | --wait-deposit )   waitd=1
                                    ;;
            -L | --list-accounts )  acc_list=1
                                    ;;
            -N | --new-account )         acc_new=1
                                    ;;
            -a | --use-acc-at-pos ) shift
                                    set_acc=1
                                    set_acc_pos=$1
                                    ;;
            -P | --random-password ) generate_password=1
                                    ;;
            attach )                attach=1
                                    ;;
            run )                   start_eth=1
                                    ;;
            -h | --help )           usage
                                    exit
                                    ;;
            * )                     usage
                                    exit 1
        esac
        shift
    done

    if [ -S $IPC_FILE ]; then
        attach_cmd="$NODE_BIN attach $IPC_FILE"
    else
        attach_cmd="$NODE_BIN attach ws://$ETH_RPC_WS_ADDRESS:$ETH_RPC_WS_PORT"
    fi
    export attach_cmd

    if [ $generate_password ]; then
        generate_password
    fi

    if [ $acc_new ]; then
        eth_new_account
    fi

    if [ $acc_list ]; then
        eth_get_account
    fi

    if [ $set_acc ]; then
        eth_set_account $set_acc_pos
    fi

    if [ $start_eth ]; then
        eth_run
    fi

    if [ $enode ]; then
        print_enode
    fi

    if [ $waits ]; then
        wait_sync
    fi

    if [ $waitd ]; then
        wait_deposit
    fi

    if [ $attach ]; then
        eth_attach
    fi
}

main $*