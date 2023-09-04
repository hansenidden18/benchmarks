#! /bin/bash

set -e

DEV=$1
DEV_CAP=$(nvme zns report-zones /dev/nvme0n1 -d 1 | grep -o 'Cap:.*$' | awk '{print strtonum($2)}')
DEV_ZONE_SIZE=$(cat /sys/block/nvme0n1/queue/chunk_sectors)
DEV_ZONES=$(cat /sys/block/nvme0n1/queue/nr_zones)
DEV_MAX_ACTIVE_ZONES=$(cat /sys/block/nvme0n1/queue/max_active_zones)
DEV_SECT_SIZE=$(cat /sys/block/nvme0n1/queue/hw_sector_size)
DEV_SCHEDULER=$(cat /sys/block/nvme0n1/queue/scheduler | awk '{print $1}')
DEV_NUMA_NODE=$(cat /sys/block/nvme0n1/device/numa_node)

echo "Zone capacity (in 512B Sectors): $DEV_CAP"
echo "Zone size (in 512B Sectors): $DEV_ZONE_SIZE"
echo "Nr. of zones: $DEV_ZONES"
echo "Max. active zones: $DEV_MAX_ACTIVE_ZONES"
echo "Sector size: $DEV_SECT_SIZE"
echo "Scheduler: $DEV_SCHEDULER"
echo "Device NUMA Node: $DEV_NUMA_NODE"
