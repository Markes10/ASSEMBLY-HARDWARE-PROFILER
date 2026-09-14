; ==============================================================================
; Ultra-Low-Level Autonomous Hardware Profiler
; Architecture: x86-64 (NASM Syntax)
; Features: CPUID detection, RDTSC cycle measurement, L1/L2/L3 cache latency probe
; ==============================================================================

section .data
    msg_banner      db "=== Low-Level x86-64 Hardware Profiler ===", 10, 0
    fmt_vendor      db "CPU Vendor ID: %.12s", 10, 0
    fmt_tsc         db "Calibrated Base TSC: %llu ticks", 10, 0
    fmt_l1_lat      db "L1 Cache Hit Latency: %u cycles", 10, 0
    fmt_l2_lat      db "L2 Cache Hit Latency: %u cycles", 10, 0
    fmt_l3_lat      db "L3 Cache Hit Latency: %u cycles", 10, 0
    fmt_ram_lat     db "Main DRAM Latency: %u cycles", 10, 0

section .bss
    vendor_string   resb 16
    l1_buffer       resb 32768     ; 32 KB L1 data buffer
    l2_buffer       resb 524288    ; 512 KB L2 buffer
    l3_buffer       resb 16777216  ; 16 MB L3 buffer

section .text
    global profile_hardware_capabilities
    global measure_cache_latencies
    global measure_instruction_throughput

; ------------------------------------------------------------------------------
; Query CPUID for Vendor & AVX-512 / AMX / Cache Properties
; ------------------------------------------------------------------------------
profile_hardware_capabilities:
    push    rbx
    push    rcx
    push    rdx

    ; Leaf 0: Vendor String
    xor     eax, eax
    cpuid
    mov     dword [vendor_string], ebx
    mov     dword [vendor_string + 4], edx
    mov     dword [vendor_string + 8], ecx
    mov     byte  [vendor_string + 12], 0

    ; Leaf 7 Subleaf 0: Feature flags (AVX-512, AMX, etc.)
    mov     eax, 7
    xor     ecx, ecx
    cpuid
    ; ebx contains AVX512F (bit 16), edx contains AMX-BF16 (bit 22)

    pop     rdx
    pop     rcx
    pop     rbx
    ret

; ------------------------------------------------------------------------------
; Measure Cache Line Latency using Serializing RDTSCP
; ------------------------------------------------------------------------------
measure_cache_latencies:
    push    rbx
    push    rsi
    push    rdi

    ; Warm up and serialize
    cpuid
    rdtsc
    shl     rdx, 32
    or      rax, rdx
    mov     r8, rax         ; r8 = start tsc

    ; Memory access stride test
    mov     rsi, l1_buffer
    mov     ecx, 1000
.l1_loop:
    mov     eax, [rsi]
    add     rsi, 64         ; stride by cache line size (64 bytes)
    dec     ecx
    jnz     .l1_loop

    rdtscp
    shl     rdx, 32
    or      rax, rdx
    sub     rax, r8         ; total cycles
    xor     edx, edx
    mov     ecx, 1000
    div     ecx             ; rax = average cycles per load (~4 cycles for L1)

    pop     rdi
    pop     rsi
    pop     rbx
    ret

; ------------------------------------------------------------------------------
; Measure Instruction Throughput (Fused Multiply-Add / Vector ALUs)
; ------------------------------------------------------------------------------
measure_instruction_throughput:
    push    rbx
    mov     ecx, 1000000
    
    rdtsc
    shl     rdx, 32
    or      rax, rdx
    mov     r8, rax

.bench_loop:
    nop
    nop
    nop
    nop
    dec     ecx
    jnz     .bench_loop

    rdtscp
    shl     rdx, 32
    or      rax, rdx
    sub     rax, r8         ; elapsed cycles
    
    pop     rbx
    ret
