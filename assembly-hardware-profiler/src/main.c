#include <stdio.h>
#include <stdint.h>

// External assembly routines defined in hardware_profiler.asm
extern void profile_hardware_capabilities(void);
extern uint64_t measure_cache_latencies(void);
extern uint64_t measure_instruction_throughput(void);

int main(void) {
    printf("====================================================================\n");
    printf("  Autonomous x86-64 Low-Level Hardware Profiler & Latency Benchmark\n");
    printf("====================================================================\n\n");

    printf("[1/3] Querying CPUID for microarchitecture and instruction extensions...\n");
    profile_hardware_capabilities();
    printf("      Microarchitecture features probed (CPUID leaf 0 & 7 executed).\n\n");

    printf("[2/3] Measuring serialized cache line latency using RDTSCP/CPUID...\n");
    uint64_t avg_l1_cycles = measure_cache_latencies();
    printf("      L1 Cache Access Latency: ~%llu CPU cycles / cache line (64-byte stride)\n\n", (unsigned long long)avg_l1_cycles);

    printf("[3/3] Measuring instruction pipeline throughput (1M loop cycles)...\n");
    uint64_t total_cycles = measure_instruction_throughput();
    printf("      1,000,000 Loop Iterations executed in %llu CPU clock cycles.\n", (unsigned long long)total_cycles);
    printf("      Throughput: %.2f cycles per iteration.\n\n", (double)total_cycles / 1000000.0);

    printf("[SUCCESS] Hardware profiler completed diagnostic run.\n");
    return 0;
}
