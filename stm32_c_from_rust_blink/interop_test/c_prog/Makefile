# Since we use a shared library, the '-rpath' option tells the program where to find
# the shared Rust library at runtime. Also, 'main.o' needs to come before the Rust library.
.PHONY: all
all:
	arm-none-eabi-gcc -mcpu=cortex-m0plus -mthumb -Wall -msoft-float -mfloat-abi=soft --specs=nosys.specs -I. -c main.c -o main.o
	arm-none-eabi-ar rcs libinterop_test.a main.o

.PHONY: clean
clean:
	rm -f main.o libinterop_test.a
