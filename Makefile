.PHONY: build run

all: build run

build:
	@echo "Building..."
	@nasm -f bin src/boot.asm -o src/boot.bin
	@echo "Build finished."

run:
	@echo "Running..."
	@qemu-system-x86_64 src/boot.bin