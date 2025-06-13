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


