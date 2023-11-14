#!/bin/bash

mydir=$(realpath $(dirname $0))
root=$mydir/..

username=${USER}
#CUDA_FLAG="--use_cuda=0"
CUDA_FLAG=""
DURATION=20

if [ "$#" -ne "4" ]; then
    echo "Usage: $0 <remote host> <remote interface> <local host> <local interface>"
    echo "Example $0 adev-mtvr-02 mlx5_2 adev-mtvr-01 mlx5_2"
    exit 1
fi

remote_host=$1
remote_ifc=$2
local_host=$3
local_ifc=$4

function run_cmd()
{

    if [ "$#" -lt "2" ]; then
        echo "function usage: run_cmd <hostname> <interface> [server-name]"
        return
    fi
    host=$1
    ifc=$2
    cmd="ssh ${username}@${host} nohup $root/ib_write_bw -d $ifc \
    -p 11000 --connection=RC -q1 -D $DURATION --report_gbits --tclass=96 --CPU-freq -x 3 ${CUDA_FLAG}" 

    if [ "$#" -ge "3" ]; then
        $cmd $3
    else
        $cmd &
    fi
}

run_cmd $remote_host $remote_ifc
sleep 2
run_cmd $local_host $local_ifc $remote_host

