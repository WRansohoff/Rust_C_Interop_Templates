# Since we use a shared library, the '-rpath' option tells the program where to find
# the shared Rust library at runtime. Also, 'main.o' needs to come before the Rust library.
.PHONY: all
all:
	gcc -I. -c main.c -o main.o
	gcc main.o -L../target/debug -Wl,-rpath=$(CURDIR)/../target/debug -linterop_test -o main

.PHONY: clean
clean:
	rm -f main.o main
