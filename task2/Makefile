all:
	as -o coloring.o coloring.s
	gcc -g -o coloring coloring-main.c coloring.o

clean:
	rm -f coloring.o && rm -f coloring && rm -f result.pgm
