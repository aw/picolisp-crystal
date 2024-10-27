# Makefile to build the lib and test it

.PHONY: all

all: clean build check

build: libpil.so

clean:
		rm -vf libpil.so

libpil.so:
		crystal build --release --no-debug --single-module -o libpil.so pil.cr --link-flags "-Wl,-fPIC -shared"

check:	libpil.so
		./extract.l
