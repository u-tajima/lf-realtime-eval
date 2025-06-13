#!/bin/bash

LF_BIN="/home/tajim/dev/DeadlineTest/bin/DeadlineTest"

CPU_LOADS=(1 2 3 4 5 6 7 8 9 10)

mkdir -p log_baseline

for N in "${CPU_LOADS[@]}"; do
    echo "Running baseline with --cpu $N"

    stress-ng --cpu $N --timeout 60s &
    STRESS_PID=$!

    mpstat 1 60 > log_baseline/lf_mpstat_cpu${N}.log &
    MPSTAT_PID=$!

    sleep 1
    /usr/bin/time -v timeout 60s $LF_BIN > log_baseline/lf_output_cpu${N}.log 2> log_baseline/lf_time_cpu${N}.log

    kill $STRESS_PID
    wait $STRESS_PID 2>/dev/null
    kill $MPSTAT_PID
    wait $MPSTAT_PID 2>/dev/null

    echo "Completed baseline --cpu $N"
done
