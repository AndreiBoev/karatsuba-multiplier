CC = g++

all:
	$(CC) karatsuba_gen.cpp -o karatsuba_gen

clean:
	rm -f karatsuba_gen