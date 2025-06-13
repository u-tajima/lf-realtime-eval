#!/bin/bash

LF_BIN="/home/tajim/dev/DeadlineTest/bin/DeadlineTest"

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_cgroup

# Cgroup setup
sudo mkdir -p /sys/fs/cgroup/cpu/lf_test

# CFS period固定
sudo bash -c "echo 100000 > /sys/fs/cgroup/cpu/lf_test/cpu.cfs_period_us"

for N in "${CPU_LOADS[@]}"; do
    echo "Running cgroup with --cpu $N"

    # CFSクォータをセット
    sudo bash -c "echo 50000 > /sys/fs/cgroup/cpu/lf_test/cpu.cfs_quota_us"

    # stress-ng起動
    stress-ng --cpu $N --timeout 60s &
    STRESS_PID=$!

    # stress-ngもcgroupに入れる
    sudo bash -c "echo $STRESS_PID > /sys/fs/cgroup/cpu/lf_test/cgroup.procs"

    # mpstat起動
    mpstat 1 60 > log_cgroup/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1

    # LFをcgroupに入れて起動
    sudo bash -c "echo $$ > /sys/fs/cgroup/cpu/lf_test/cgroup.procs; exec /usr/bin/time -v timeout 60s $LF_BIN > log_cgroup/lf_output_cpu${N}.log 2> log_cgroup/lf_time_cpu${N}.log"

    # stress-ng停止
    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null

    # mpstat停止
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed cgroup --cpu $N"
done
