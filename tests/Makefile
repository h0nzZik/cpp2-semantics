TEMP_DIR=../.build

KCPP2 ?= kcpp2
KCPP2FLAGS ?=
CHECK := diff -U3

.PHONY: smoke-test

${TEMP_DIR}/%.parser.out: %.cpp2
	${KCPP2} ${KCPP2FLAGS} --stop-after-disambiguation $< > $@

%.test-parse: ${TEMP_DIR}/%.parser.out %.parsed
	${CHECK} $^

smoke-test: main-return-42.test-parse

local-variables: local-variables.cpp2
	${KCPP2} ${KCPP2FLAGS} --stop-after-disambiguation $<

nested-calls: nested-calls.cpp2
	${KCPP2} ${KCPP2FLAGS} nested-calls.cpp2

local-variables-parse: ${PARSER_TIMESTAMP} local-variables.cpp2
	${KCPP2} ${KCPP2FLAGS} local-variables.cpp2

# TODO we have to wrap this
properties: properties/spec.k ${TIMESTAMP}
	kprove --directory ${KOMPILED_DIR} properties/spec.k

TESTS := $(wildcard ./tests/*.cpp2)
#TEST_KORE := ${TESTS:.c=.kcc.executable.kore}
