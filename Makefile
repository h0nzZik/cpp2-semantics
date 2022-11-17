# This toplevel Makefile first calls src/Makefile in order to install [kcpp2] to ${IROOT},
# then runs the individual tests with [kcpp2].

IROOT := $(abspath ./iroot)
KCPP2 := ${IROOT}/bin/kcpp2

.PHONY: kcpp2
kcpp2: src/Makefile
	$(MAKE) -C ./src INSTALL_PREFIX=${IROOT} install

default: properties

.PHONY: clean

clean:
	$(MAKE) -C ./src clean
	rm -rf ${IROOT}

smoke-test: tests/main-return-42.cpp2 kcpp2
	${KCPP2} --stop-after-disambiguation tests/main-return-42.cpp2

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
