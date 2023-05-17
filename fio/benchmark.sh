#!/bin/bash

set -e

SOURCE="${BASH_SOURCE[0]}"
TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

DIR=$TOPDIR/result
NUMJOBS=(1 2 4 8 16 32 64 128)
#BLOCK_SIZE=("4k" "16k" "64k" "256k")
BLOCK_SIZE=("4k")

DEV_INFO=($(./get_zoned_device_info.sh | awk 'NF{ print $NF }'))

DEV_ZONE_CAP=${DEV_INFO[0]}
DEV_ZONE_SIZE=${DEV_INFO[1]}
DEV_ZONES=${DEV_INFO[2]}
DEV_MAX_ACTIVE_ZONES=${DEV_INFO[3]}
DEV_SECT_SIZE=${DEV_INFO[4]}
DEV_SCHEDULER=${DEV_INFO[5]}
DEV_NUMA_NODE=${DEV_INFO[6]}
ZONED=1
MQ_SIZE=$(echo "scale=0;$DEV_ZONE_SIZE*$DEV_SECT_SIZE*$DEV_ZONES" | bc)

mkdir -p $DIR
cd $DIR

blkzone reset /dev/nvme0n1

echo mq-deadline | tee /sys/block/nvme0n1/queue/scheduler > /dev/null
echo "Filling entire namespace for read benchs"
fio --name=zns-fio --filename=/dev/nvme0n1 --direct=1 --size=$MQ_SIZE --ioengine=libaio --iodepth=4 --rw=write --bs=512K --zonemode=zbd > /dev/null

for job in ${NUMJOBS[@]}; do
    echo "Running benchmarks with number of q-depths: $job"
    
    # none scheduler
    echo none | tee /sys/block/nvme0n1/queue/scheduler > /dev/null

    sudo fio --name=$(echo "none_iodepth_${job}") --filename=/dev/nvme0n1 --direct=1 --size=1z --offset_increment=1z --ioengine=psync --zonemode=zbd --runtime=60 --numa_cpu_nodes=$DEV_NUMA_NODE --rw=randread --numjobs=$job --bs=$BLOCK_SIZE --time_based=1 --randrepeat=0 --norandommap=1 --group_reporting --per_job_logs=0 --stonewall --number_ios=1000 --max_open_zones=1 --write_lat_log=seq_read_lat_${job}.log > $DIR/zns_output_${job}.txt
done
