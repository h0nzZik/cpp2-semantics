# https://stackoverflow.com/a/64068109/6209703
makeFileDir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

TEMP_DIR=${makeFileDir}/.tmp
$(shell mkdir -p ${TEMP_DIR})

KCPP2 ?= kcpp2
KCPP2FLAGS ?= --verbose
KCPP2_COMMAND := ${KCPP2} --temp-dir ${TEMP_DIR} ${KCPP2FLAGS}
CHECK := diff -U3

default: all

all: smoke-test parse-tests translate-tests execute-tests

clean:
	rm -rf ${TEMP_DIR}

.PHONY: all smoke-test clean parse-tests translate-tests execute-tests

########### Parse tests

PARSE_TESTS := $(wildcard ./*.test-parse.cpp2)
PARSE_TESTS_OUT := $(addprefix ${TEMP_DIR}/, ${PARSE_TESTS:.cpp2=.parser.out})
PARSE_TESTS_CMP := $(addprefix ${TEMP_DIR}/, ${PARSE_TESTS:.cpp2=.cmp})

parse-tests: ${PARSE_TESTS_CMP}

${PARSE_TESTS_OUT} : ${TEMP_DIR}/%.test-parse.parser.out : %.test-parse.cpp2
	${KCPP2_COMMAND} --upto disambiguate $< --output-file $@

${PARSE_TESTS_CMP} : ${TEMP_DIR}/%.test-parse.cmp : ${TEMP_DIR}/%.test-parse.parser.out %.test-parse.parsed.ref
	${CHECK} $^ > $@ || (cat $@; false)

############ Translation tests

TRANSLATE_TESTS := $(wildcard ./*.test-translate.cpp2)
TRANSLATE_TESTS_OUT := $(addprefix ${TEMP_DIR}/, ${TRANSLATE_TESTS:.cpp2=.translation.out})
TRANSLATE_TESTS_CMP := $(addprefix ${TEMP_DIR}/, ${TRANSLATE_TESTS:.cpp2=.cmp})

translate-tests: ${TRANSLATE_TESTS_CMP}

${TRANSLATE_TESTS_OUT} : ${TEMP_DIR}/%.test-translate.translation.out : %.test-translate.cpp2
	${KCPP2_COMMAND} --upto translate $< --result-format kore --output-file $@

${TRANSLATE_TESTS_CMP} : ${TEMP_DIR}/%.test-translate.cmp : ${TEMP_DIR}/%.test-translate.translation.out %.test-translate.translation.ref
	${CHECK} $^ > $@ || (cat $@; false)


############ Execution tests

EXECUTE_TESTS := $(wildcard ./*.test-execute.cpp2)
EXECUTE_TESTS_OUT := $(addprefix ${TEMP_DIR}/, ${EXECUTE_TESTS:.cpp2=.execution.out})
EXECUTE_TESTS_CMP := $(addprefix ${TEMP_DIR}/, ${EXECUTE_TESTS:.cpp2=.cmp})

execute-tests: ${EXECUTE_TESTS_CMP}

${EXECUTE_TESTS_OUT} : ${TEMP_DIR}/%.test-execute.execution.out : %.test-execute.cpp2
	${KCPP2_COMMAND} $< --output-file $@

${EXECUTE_TESTS_CMP} : ${TEMP_DIR}/%.test-execute.cmp : ${TEMP_DIR}/%.test-execute.execution.out %.test-execute.execution.ref
	${CHECK} $^ > $@ || (cat $@; false)

############# Other tests


smoke-test: main-return-42.test-smoke.cpp2
	${KCPP2_COMMAND} $< ; test "$$?" -eq 42


nested-calls: nested-calls.cpp2
	${KCPP2_COMMAND} nested-calls.cpp2

local-variables-parse: ${PARSER_TIMESTAMP} local-variables.cpp2
	${KCPP2_COMMAND} local-variables.cpp2

# TODO we have to wrap this
properties: properties/spec.k ${TIMESTAMP}
	kprove --directory ${KOMPILED_DIR} properties/spec.k

#TEST_KORE := ${TESTS:.c=.kcc.executable.kore}
