CC ?= gcc
NASM ?= nasm
CFLAGS ?= -O2 -Wall -no-pie
NASMFLAGS ?= -f elf64

TARGET = hardware_profiler
SRC_C = src/main.c
SRC_ASM = src/hardware_profiler.asm
OBJ_ASM = src/hardware_profiler.o
OBJ_C = src/main.o

all: $(TARGET)

$(OBJ_ASM): $(SRC_ASM)
	$(NASM) $(NASMFLAGS) $< -o $@

$(OBJ_C): $(SRC_C)
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(OBJ_C) $(OBJ_ASM)
	$(CC) $(CFLAGS) -o $@ $^

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f src/*.o $(TARGET)

.PHONY: all test clean
