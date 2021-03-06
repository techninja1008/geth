#!/bin/bash

command=$1
shift

if [ ! -f /data/init ]; then
    cat <<- EOF > /data/genesis.json
    {
      "config": {
            "chainId": 31,
            "homesteadBlock": 0,
            "eip155Block": 0,
            "eip158Block": 0
        },
      "alloc"      : {},
      "coinbase"   : "0x0000000000000000000000000000000000000000",
      "difficulty" : "0x20000",
      "extraData"  : "",
      "gasLimit"   : "0x2fefd8",
      "nonce"      : "$GENESIS_NONCE",
      "mixhash"    : "0x0000000000000000000000000000000000000000000000000000000000000000",
      "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
      "timestamp"  : "0x00"
    }
EOF
    mkdir -p /data/chain
    geth --datadir="/data/chain" -verbosity 6 --ipcdisable --rpcport 8101 init /data/genesis.json
    echo $STATIC_NODES > /data/chain/static-nodes.json
    touch /data/init
fi

case $command in
bootnodegen)
  bootnode -genkey /bootnodegen.key -writeaddress > /dev/null
  cat /bootnodegen.key
  ;;
bootnode)
  echo "-------------------------------"
  echo "--     Starting Bootnode     --"
  echo "-------------------------------"
  hexkey=$1
  shift
  exec bootnode -nodekeyhex $hexkey "$@"
  ;;
geth)
  echo "-------------------------------"
  echo "--       Starting Geth       --"
  echo "-------------------------------"
  exec geth --bootnodes="$BOOTNODES" --datadir="/data/chain" -verbosity 6 --ipcdisable --rpcport 8101 "$@"
  ;;
mine)
  echo "-------------------------------"
  echo "--      Starting Miner       --"
  echo "-------------------------------"
  etherbase=$1
  shift
  threads=${1:-1}
  shift
  exec geth --bootnodes="$BOOTNODES" --datadir="/data/chain" -verbosity 6 --ipcdisable --rpcport 8101 --mine --minerthreads=$threads --etherbase=$etherbase "$@"
  ;;
*)
  exec $command "$@"
  ;;
esac
