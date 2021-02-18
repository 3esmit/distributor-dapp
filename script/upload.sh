#!/bin/bash

NETWORK="--goerli"
DOMAIN_BASE="dapt.status.eth"
CONTRACT_DAPTGET="0x146BD768397f1F15C480E851ecCd0898Be5b094D"
CONTRACT_ENS="0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
CONTRACT_RESOLVER="0x4B1488B7a6B320d2D721406204aBc3eeAa9AD329"

usage()
{
    echo "usage: upload [flags]"
    echo "-h, --help"
}

ipfs_upload()
{
    IPFSHASH=`ipfs add $1 | awk 'BEGIN{FS=" "} {print $2}'`
    export CONTENTHASH="0x`node ./ipfs-contenthash.js $IPFSHASH`"
}

ens_setup() 
{
    npx eth abi:add ensregistry ./abi/ENSRegistry.json
    npx eth abi:add publicresolver ./abi/PublicResolver.json
    npx eth abi:add daptget ./abi/DAptGet.json
    npx eth address:add daptget $CONTRACT_DAPTGET
    npx eth address:add ens $CONTRACT_ENS
    npx eth address:add resolver $CONTRACT_RESOLVER
}

add_app(){
    npx eth contract:send $NETWORK daptget@daptget 'createApp("'$1'")'
}

add_release()
{
    ipfs_upload $2
    FULLDOMAIN="$1.$DOMAIN_BASE"
    NAMEHASH=`node ./ens-namehash.js $FULLDOMAIN`
    if [ `npx eth contract:call $NETWORK ensregistry@ens 'resolver("'$NAMEHASH'")'` != $CONTRACT_RESOLVER ]; then
        npx eth contract:send $NETWORK ensregistry@ens 'setResolver("'$NAMEHASH'", "'$CONTRACT_RESOLVER'")'
    fi
    npx eth contract:send $NETWORK publicresolver@resolver 'setContenthash("'$NAMEHASH'", "'$CONTENTHASH'")'
}

key_type=0

main()
{
    while [ "$1" != "" ]; do
        case $1 in
            -v | --verbose )        _V=1
                                    ;;
            -k | --key )            shift 
                                    export ETH_CLI_PRIVATE_KEY=$1
                                    ;;
            -R | --register )       register=1
                                    ;;
            -d | --domain )         shift 
                                    domain=$1
                                    ;;
            -r | --set-release-file ) shift 
                                    release=$1
                                    ;;
            -kT | --key-type )      shift   
                                    key_type=$1
                                    ;;
            -h | --help )           usage
                                    exit
                                    ;;
            * )                     usage
                                    exit 1
        esac
        shift
    done

    if [ $register ]; then
        if [ -z "$domain" ]; then
            echo "Missing domain parameter"
            exit 1
        fi
        add_app $domain
    fi

    if [ ! -z "$release" ]; then
        if [ -z "$domain" ]; then
            echo "Missing domain parameter"
            exit 1
        fi
        if [ ! -f "$release" ]; then
            echo "$release does not exist."
            exit 1
        fi
        add_release $domain $release
    fi
}


main $*