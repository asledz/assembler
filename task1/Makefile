all: simulation_make

simulation_make: simulation_main.c simulation.o
	gcc -g -no-pie -o simulation simulation_main.c simulation.o


.SECONDARY:

%.o: %.asm
	nasm -f elf64 -F dwarf -g $<

%: %.o
	ld $< -o $@ -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2

clean:
	rm -f *.o && rm -f simulation && rm -f simulation_students
