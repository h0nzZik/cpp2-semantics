BUILD_ROOT := ./build
KOMPILED_DIR := ${BUILD_ROOT}/cpp2-kompiled
TIMESTAMP := ${KOMPILED_DIR}/cpp2-kompiled/timestamp

PARSER_KOMPILED_DIR := ${BUILD_ROOT}/cpp2-parser-kompiled
PARSER_TIMESTAMP := ${PARSER_KOMPILED_DIR}/parsing-kompiled/timestamp

KRUN_FLAGS :=

default: properties

.PHONY: clean

clean:
	rm -rf ${KOMPILED_DIR} ${PARSER_KOMPILED_DIR}

${PARSER_TIMESTAMP}: semantics/parsing.k semantics/syntax.k
	mkdir -p ${PARSER_KOMPILED_DIR}
	kompile --backend llvm --gen-glr-bison-parser --syntax-module CPP2-SYNTAX --directory ${PARSER_KOMPILED_DIR} $<

${TIMESTAMP}: semantics/cpp2.k semantics/syntax.k
	mkdir -p ${KOMPILED_DIR}
	kompile --backend haskell --directory ${KOMPILED_DIR} $<

smoke-test: ${TIMESTAMP} tests/main-return-42.cpp2
	krun ${KRUN_FLAGS} --directory ${KOMPILED_DIR} tests/main-return-42.cpp2

nested-calls: ${TIMESTAMP} tests/nested-calls.cpp2
	krun ${KRUN_FLAGS} --directory ${KOMPILED_DIR} tests/nested-calls.cpp2

local-variables: ${TIMESTAMP} tests/local-variables.cpp2
	krun ${KRUN_FLAGS} --directory ${KOMPILED_DIR} tests/local-variables.cpp2

local-variables-parse: ${PARSER_TIMESTAMP} tests/local-variables.cpp2
	krun ${KRUN_FLAGS} --directory ${PARSER_KOMPILED_DIR} tests/local-variables.cpp2

properties: properties/spec.k ${TIMESTAMP}
	kprove --directory ${KOMPILED_DIR} properties/spec.k

TESTS := $(wildcard ./tests/*.cpp2)
#TEST_KORE := ${TESTS:.c=.kcc.executable.kore}
