.PHONY: all build dist clean

all: build

build: levenshtein slimmer unwhitespace

dist: build
	zip slimmer.zip levenshtein slimmer unwhitespace

clean:
	rm -f slimmer unwhitespace levenshtein slimmer.zip

levenshtein: src/lev.cpp
	g++ --std=gnu++17 -o levenshtein src/lev.cpp

slimmer: src/slimmer.rb
	cp $< $@

unwhitespace: src/unwhitespace.sh
	cp $< $@
