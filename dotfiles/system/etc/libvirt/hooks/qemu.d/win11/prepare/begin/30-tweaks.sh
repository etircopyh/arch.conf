#!/bin/sh
#

sysctl -w vm.transparent_hugepages=never
sysctl -w kernel.split_lock_mitigate=0
sysctl -w vm.stat_interval=10
sysctl -w kernel.sched_rt_runtime_us=-1
sysctl -w kernel.hung_task_timeout_secs=600
