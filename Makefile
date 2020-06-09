
all: clean bforth
	@echo "OK"

bforth: nucleus-linux.asm
	nasm -f elf -o $@.o $<
	ld -m elf_i386 $@.o -o $@

run:
	cat bforth.f $(PROG) - | ./bforth

clean:
	rm -f bforth.o bforth

.PHONY: clean bforth
