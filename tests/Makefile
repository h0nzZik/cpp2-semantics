KCPP2 ?= kcpp2
KCPP2FLAGS ?= --verbose

.PHONY: smoke-test

smoke-test: main-return-42.cpp2
	${KCPP2} ${KCPP2FLAGS} --stop-after-disambiguation $<

local-variables: local-variables.cpp2
	${KCPP2} ${KCPP2FLAGS} --stop-after-disambiguation $<

nested-calls: nested-calls.cpp2
	${KCPP2} ${KCPP2FLAGS} nested-calls.cpp2

parse-local-variable: ${PARSER_TIMESTAMP} parse-local-variable.cpp2
	${KCPP2} ${KCPP2FLAGS} --stop-after-disambiguation parse-local-variable.cpp2

# TODO we have to wrap this
properties: properties/spec.k ${TIMESTAMP}
	kprove --directory ${KOMPILED_DIR} properties/spec.k

TESTS := $(wildcard ./tests/*.cpp2)
#TEST_KORE := ${TESTS:.c=.kcc.executable.kore}
