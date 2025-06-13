#!/bin/bash

LF_BIN="/home/tajim/dev/DeadlineTest/bin/DeadlineTest"

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_all/log_cgroup

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
    mpstat 1 60 > log_all/log_cgroup/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1

    # LFをcgroupに入れて起動
    sudo bash -c "echo $$ > /sys/fs/cgroup/cpu/lf_test/cgroup.procs; exec /usr/bin/time -v timeout 60s $LF_BIN > log_all/log_cgroup/lf_output_cpu${N}.log 2> log_all/log_cgroup/lf_time_cpu${N}.log"

    # stress-ng停止
    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null

    # mpstat停止
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed cgroup --cpu $N"
done

#!/bin/bash

LF_BIN="/home/tajim/dev/DeadlineTest/bin/DeadlineTest"

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_all/log_baseline

for N in "${CPU_LOADS[@]}"; do
    echo "Running baseline with --cpu $N"

    stress-ng --cpu $N --timeout 60s &
    STRESS_PID=$!

    mpstat 1 60 > log_all/log_baseline/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1
    /usr/bin/time -v timeout 60s $LF_BIN > log_all/log_baseline/lf_output_cpu${N}.log 2> log_all/log_baseline/lf_time_cpu${N}.log

    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed baseline --cpu $N"
done

#!/bin/bash

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_all/log_container_runc

for N in "${CPU_LOADS[@]}"; do
    echo "Running container (isolated) with --cpu $N"

    # 1️⃣ stress-ng をホスト側でバックグラウンド起動
    stress-ng --cpu $N --timeout 60s > log_all/log_container_runc/stress_cpu${N}.log 2>&1 &
    STRESS_PID=$!

    # 2️⃣ mpstat でホスト側のCPU使用率も測定
    mpstat 1 60 > log_all/log_container_runc/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1  # stress-ng 起動安定待ち

    # 3️⃣ LFアプリをコンテナで実行
    docker run --rm \
        --runtime=runc \
        --cpus="${N}" \
        --entrypoint bash \
        -v "$(pwd)/log_all/log_container_runc:/mnt/host_log_all/log_container_runc" \
        lf-test \
        -c "/usr/bin/time -v /usr/local/bin/DeadlineTest" \
        > log_all/log_container_runc/lf_output_cpu${N}.log \
        2> log_all/log_container_runc/lf_time_cpu${N}.log

    # 4️⃣ cleanup
    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed container (isolated) --cpu $N"
done

echo "All isolated container experiments done."

#!/bin/bash

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_all/log_container_crun

for N in "${CPU_LOADS[@]}"; do
    echo "Running container (isolated) with --cpu $N"

    # 1️⃣ stress-ng をホスト側でバックグラウンド起動
    stress-ng --cpu $N --timeout 60s > log_all/log_container_crun/stress_cpu${N}.log 2>&1 &
    STRESS_PID=$!

    # 2️⃣ mpstat でホスト側のCPU使用率も測定
    mpstat 1 60 > log_all/log_container_crun/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1  # stress-ng 起動安定待ち

    # 3️⃣ LFアプリをコンテナで実行
    docker run --rm \
        --runtime=crun \
        --cpus="${N}" \
        --entrypoint bash \
        -v "$(pwd)/log_all/log_container_crun:/mnt/host_log_all/log_container_crun" \
        lf-test \
        -c "/usr/bin/time -v /usr/local/bin/DeadlineTest" \
        > log_all/log_container_crun/lf_output_cpu${N}.log \
        2> log_all/log_container_crun/lf_time_cpu${N}.log

    # 4️⃣ cleanup
    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed container (isolated) --cpu $N"
done

echo "All isolated container experiments done."

#!/bin/bash

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_all/log_container_youki

for N in "${CPU_LOADS[@]}"; do
    echo "Running container (isolated) with --cpu $N"

    # 1️⃣ stress-ng をホスト側でバックグラウンド起動
    stress-ng --cpu $N --timeout 60s > log_all/log_container_youki/stress_cpu${N}.log 2>&1 &
    STRESS_PID=$!

    # 2️⃣ mpstat でホスト側のCPU使用率も測定
    mpstat 1 60 > log_all/log_container_youki/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1  # stress-ng 起動安定待ち

    # 3️⃣ LFアプリをコンテナで実行
    docker run --rm \
        --runtime=youki \
        --cpus="${N}" \
        --entrypoint bash \
        -v "$(pwd)/log_all/log_container_youki:/mnt/host_log_all/log_container_youki" \
        lf-test \
        -c "/usr/bin/time -v /usr/local/bin/DeadlineTest" \
        > log_all/log_container_youki/lf_output_cpu${N}.log \
        2> log_all/log_container_youki/lf_time_cpu${N}.log

    # 4️⃣ cleanup
    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed container (isolated) --cpu $N"
done

echo "All isolated container experiments done."


