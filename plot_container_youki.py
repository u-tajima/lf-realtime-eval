import re
import matplotlib.pyplot as plt

CPU_LOADS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

source_jitter_avg = []
dest_latency_avg = []
deadline_miss_rates = []
scheduler_latency_avg = []  # ← 追加

# パターン
pattern_source = re.compile(r"Source sends: \d+ at \d+ ns \(interval: (\d+) ns\)")
pattern_dest = re.compile(r"Destination receives msg.*send_time:\s*\d+\s*ns.*recv_time:\s*\d+\s*ns.*error:\s*(\-?\d+)\s*ns")
pattern_received = re.compile(r"Total received:\s*(\d+)")
pattern_misses = re.compile(r"Deadline misses:\s*(\d+)")
pattern_scheduler_latency = re.compile(r"Scheduler latency: (\d+) ns")  
pattern_cpu_usage = re.compile(r"Percent of CPU this job got:\s*(\d+)")

def parse_mpstat_avg(filename):
    usage_values = []
    with open(filename, "r") as f:
        for line in f:
            if re.search(r"\s+all\s+", line):
                tokens = line.split()
                cpu_idle = float(tokens[-1])
                cpu_usage = 100.0 - cpu_idle
                usage_values.append(cpu_usage)
    if usage_values:
        return sum(usage_values) / len(usage_values)
    else:
        return 0.0



cpu_usage_list = []
pc_cpu_usage_list = []

for N in CPU_LOADS:
    source_intervals = []
    dest_latencies = []
    scheduler_latencies = [] 
    total_received = 0
    deadline_misses = 0
    lf_cpu_usage = 0.0
    pc_cpu_usage = 0.0

    # LF log parse
    log_file = f"log_all/log_container_youki/lf_output_cpu{N}.log"
    time_file = f"log_all/log_container_youki/lf_time_cpu{N}.log"
    mpstat_file = f"log_all/log_container_youki/lf_mpstat_cpu{N}.log"

    with open(log_file, "r") as f:
        for line in f:
            match_source = pattern_source.search(line)
            if match_source:
                interval_ns = int(match_source.group(1))
                source_intervals.append(interval_ns / 1e6)  # ms

            match_dest = pattern_dest.search(line)
            if match_dest:
                error_ns = int(match_dest.group(1))
                dest_latencies.append(error_ns / 1e6)  # ms

            match_scheduler_latency = pattern_scheduler_latency.search(line)
            if match_scheduler_latency:
                latency_ns = int(match_scheduler_latency.group(1))
                scheduler_latencies.append(latency_ns / 1e6)  # ms  

            match_received = pattern_received.search(line)
            if match_received:
                total_received = int(match_received.group(1))

            match_misses = pattern_misses.search(line)
            if match_misses:
                deadline_misses = int(match_misses.group(1))


    # LF CPU usage parse
    with open(time_file, "r") as f:
        for line in f:
            match_cpu = pattern_cpu_usage.search(line)
            if match_cpu:
                lf_cpu_usage = float(match_cpu.group(1))

    # PC CPU usage parse
    pc_cpu_usage = parse_mpstat_avg(mpstat_file)

    # 計算
    source_avg = sum(source_intervals) / len(source_intervals) if source_intervals else 0
    dest_avg = sum(dest_latencies) / len(dest_latencies) if dest_latencies else 0
    scheduler_avg = sum(scheduler_latencies) / len(scheduler_latencies) if scheduler_latencies else 0
    miss_rate = (deadline_misses / total_received * 100) if total_received > 0 else 0

    # 保存
    source_jitter_avg.append(source_avg)
    dest_latency_avg.append(dest_avg)
    scheduler_latency_avg.append(scheduler_avg)
    deadline_miss_rates.append(miss_rate)
    cpu_usage_list.append(lf_cpu_usage)
    pc_cpu_usage_list.append(pc_cpu_usage)


# Plot ① Source周期ジッタ平均
plt.figure(figsize=(8,6))
plt.plot(CPU_LOADS, source_jitter_avg, marker='o')
plt.xlabel("CPU Load (number of stress-ng --cpu N)")
plt.ylabel("Source Period Jitter avg (ms)")
plt.ylim(2.9, 3.2)
plt.title("Source Period Jitter --container_youki--")
plt.ticklabel_format(axis='y', style='plain')
plt.grid(True)
plt.savefig("log_all/log_img/source_jitter_container_youki.png")

# Plot ② Destination latency平均
plt.figure(figsize=(8,6))
plt.plot(CPU_LOADS, dest_latency_avg, marker='o', color='green')
plt.xlabel("CPU Load (number of stress-ng --cpu N)")
plt.ylabel("Destination Latency avg (ms)")
plt.ylim(0, 0.015)
plt.title("Destination Latency --container_youki--")
plt.grid(True)
plt.savefig("log_all/log_img/dest_latency_container_youki.png")

# Plot ③ Scheduler latency平均 ← 追加
plt.figure(figsize=(8,6))
plt.plot(CPU_LOADS, scheduler_latency_avg, marker='o', color='purple')
plt.xlabel("CPU Load (number of stress-ng --cpu N)")
plt.ylabel("Scheduler Latency avg (ms)")
# plt.ylim(0, 3)
plt.title("Scheduler Latency --container_youki--")
plt.grid(True)
plt.savefig("log_all/log_img/scheduler_latency_container_youki.png")

# Plot ④ Deadline miss率
plt.figure(figsize=(8,6))
plt.plot(CPU_LOADS, deadline_miss_rates, marker='o', color='red')
plt.xlabel("CPU Load (number of stress-ng --cpu N)")
plt.ylabel("Deadline Miss Rate (%)")
plt.ylim(0, 50) 
plt.title("Deadline Miss Rate --container_youki--")
plt.grid(True)
plt.savefig("log_all/log_img/deadline_miss_container_youki.png")

# Plot CPU LF usage
plt.figure(figsize=(8,6))
plt.plot(CPU_LOADS, cpu_usage_list, marker='o', label='LF App CPU Usage (%)')
plt.xlabel("CPU Load (number of stress-ng --cpu N)")
plt.ylabel("CPU Usage (%)")
plt.ylim(0, 50)
plt.title("LF App CPU Usage --container_youki--")
plt.legend()
plt.grid(True)
plt.savefig("log_all/log_img/cpu_lf_usage_container_youki.png")

# Plot CPU Total usage
plt.figure(figsize=(8,6))
plt.plot(CPU_LOADS, pc_cpu_usage_list, marker='o', label='PC Total CPU Usage (%)')
plt.xlabel("CPU Load (number of stress-ng --cpu N)")
plt.ylabel("CPU Usage (%)")
plt.ylim(0, 110)
plt.title("PC Total CPU Usage --container_youki--")
plt.legend()
plt.grid(True)
plt.savefig("log_all/log_img/cpu_total_usage_container_youki.png")



print("Summary plots saved.")
