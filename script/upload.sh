#!/bin/bash

NETWORK="--goerli"
DOMAIN_BASE="dapt.status.eth"
CONTRACT_DAPTGET="0x146BD768397f1F15C480E851ecCd0898Be5b094D"
CONTRACT_ENS="0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
CONTRACT_RESOLVER="0x4b1488b7a6b320d2d721406204abc3eeaa9ad329"

usage()
{
    echo "usage: upload [flags]"
    echo "-h, --help"
}

ipfs_upload()
{
    ipfs upload $1
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
    NAMEHASH=`node ./ens-namehash.js $1`
    npx eth contract:send $NETWORK publicresolver@resolver 'setContenthash('$NAMEHASH', '$2')'
}

key_type=0

main()
{
    while [ "$1" != "" ]; do
        case $1 in
            -v | --verbose )        _V=1
                                    ;;
            -k | --key )            shift 
                                    key=$1
                                    ;;
            -d | --domain )         shift 
                                    domain=$1
                                    ;;
            -f | --file )           shift 
                                    file=$1
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
}


main $*