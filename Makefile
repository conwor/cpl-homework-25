# =============================================================================
# Variables

# Build tools and options
GCC = gcc
MAIN_FLAGS = -std=c99 -m32 -g -O0
WARNINGS_FLAGS = -Wall -Wextra -Wpedantic -Wduplicated-branches -Wduplicated-cond -Wcast-qual -Wconversion -Wsign-conversion -Wlogical-op -Werror
SANITIZER_FLAGS = -fsanitize=address -fsanitize=pointer-compare -fsanitize=pointer-subtract -fsanitize=leak -fsanitize=undefined -fsanitize-address-use-after-scope
FLAGS = $(MAIN_FLAGS) $(WARNINGS_FLAGS) $(SANITIZER_FLAGS)

# Sources and headers
SOURCES = $(wildcard ./*.c)
HEADERS = $(wildcard ./*.h)
FORMATTED_FILES = $(SOURCES:.c=.c.formatted) $(HEADERS:.h=.h.formatted)

# Targets
EXE = main

# Tests
IN = $(wildcard tests/*-input.txt)
ACT = $(IN:-input.txt=-actual.txt)
PASS = $(IN:-input.txt=.passed)


# =============================================================================
# Tasks

all: clean-before test clean-after

$(FORMATTED_FILES): %.formatted: %
	@clang-format --style=file $* > $*.formatted
	diff $* $*.formatted

$(EXE): $(FORMATTED_FILES)
	@rm -f $(FORMATTED_FILES)
	$(GCC) $(FLAGS) $(SOURCES) -o $@

$(PASS): %.passed: %-input.txt %-expected.txt $(EXE)
	@echo "Running test $*..."
	@rm -f $@
	./$(EXE) < $*-input.txt 1> $*-actual.txt 2>&1
	diff $*-expected.txt $*-actual.txt
	@touch $@

test: $(PASS)
	@echo "All tests passed"

clean-before:
	rm -f $(FORMATTED_FILES) $(EXE)

clean-after:
	rm -f $(ACT) $(PASS)

.PHONY: all test clean
