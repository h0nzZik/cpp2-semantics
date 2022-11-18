TEMP_DIR=../.build/tests

KCPP2 ?= KCPP2_TMP=${TEMP_DIR}/ kcpp2
KCPP2FLAGS ?=
CHECK := diff -U3

.PHONY: smoke-test

${TEMP_DIR}/%.parser.out: %.cpp2

%.test-parse:
	${KCPP2} ${KCPP2FLAGS} --stop-after-disambiguation $*.cpp2 > ${TEMP_DIR}/$*.parser.out
	${CHECK} ${TEMP_DIR}/$*.parser.out $*.parsed

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
