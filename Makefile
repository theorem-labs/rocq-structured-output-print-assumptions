.PHONY: all build tests clean

all: build

build:
	dune build

tests: build

clean:
	dune clean
