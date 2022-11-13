BUILD_ROOT := ./build
KOMPILED_DIR := ${BUILD_ROOT}/cpp2-kompiled
TIMESTAMP := ${KOMPILED_DIR}/cpp2-kompiled/timestamp

default: properties

${TIMESTAMP}: semantics/cpp2.k
	mkdir -p ${KOMPILED_DIR}
	kompile --backend haskell --directory ${KOMPILED_DIR} $<

smoke-test: ${TIMESTAMP}
	krun --directory ${KOMPILED_DIR} tests/main-return-42.cpp2

nested-calls: ${TIMESTAMP}
	krun --directory ${KOMPILED_DIR} tests/nested-calls.cpp2

properties: properties/spec.k ${TIMESTAMP}
	kprove --directory ${KOMPILED_DIR} properties/spec.k

TESTS := $(wildcard ./tests/*.cpp2)
#TEST_KORE := ${TESTS:.c=.kcc.executable.kore}
