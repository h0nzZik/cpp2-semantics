
KRUN_FLAGS :=

default: properties

.PHONY: clean

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
