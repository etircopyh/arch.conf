#!/usr/bin/env bash
#awk 'int($NF) > 0'
STATIC_HP=$(< /proc/sys/vm/nr_hugepages)

if (( $STATIC_HP > 0 )); then
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
else
    echo always > /sys/kernel/mm/transparent_hugepage/enabled
    echo defer+madvise > /sys/kernel/mm/transparent_hugepage/defrag
fi
