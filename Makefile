BUILD_ROOT := ./build
KOMPILED_DIR := ${BUILD_ROOT}/cpp2-kompiled
TIMESTAMP := ${KOMPILED_DIR}/cpp2-kompiled/timestamp

default: properties

.PHONY: clean

clean:
	rm -rf ${KOMPILED_DIR}

${TIMESTAMP}: semantics/cpp2.k
	mkdir -p ${KOMPILED_DIR}
	kompile --backend haskell --gen-glr-bison-parser --directory ${KOMPILED_DIR} $<

smoke-test: ${TIMESTAMP} tests/main-return-42.cpp2
	krun --directory ${KOMPILED_DIR} tests/main-return-42.cpp2

nested-calls: ${TIMESTAMP} tests/nested-calls.cpp2
	krun --directory ${KOMPILED_DIR} tests/nested-calls.cpp2

local-variables: ${TIMESTAMP} tests/local-variables.cpp2
	krun --directory ${KOMPILED_DIR} tests/local-variables.cpp2

properties: properties/spec.k ${TIMESTAMP}
	kprove --directory ${KOMPILED_DIR} properties/spec.k

TESTS := $(wildcard ./tests/*.cpp2)
#TEST_KORE := ${TESTS:.c=.kcc.executable.kore}
