BUILD_ROOT := ../.build
KOMPILED_DIR := ${BUILD_ROOT}/lib/kcpp2/semantics/
TIMESTAMP := ${KOMPILED_DIR}/cpp2-kompiled/timestamp

PARSER_KOMPILED_DIR := ${BUILD_ROOT}/lib/kcpp2/parser/
PARSER_TIMESTAMP := ${PARSER_KOMPILED_DIR}/parsing-kompiled/timestamp

default: all

.PHONY: parser main clean install

all: parser main glue

parser: ${PARSER_TIMESTAMP}
main: ${TIMESTAMP}

glue: ${BUILD_ROOT}/bin/kcpp2 ${BUILD_ROOT}/libexec/kcpp2/extract-translation-result.py

${BUILD_ROOT}/bin/kcpp2: scripts/kcpp2
	mkdir -p ${BUILD_ROOT}/bin
	cp $< $@

${BUILD_ROOT}/libexec/kcpp2/extract-translation-result.py: scripts/extract-translation-result.py
	mkdir -p ${BUILD_ROOT}/libexec/kcpp2/
	cp $< $@

clean:
	rm -rf ${KOMPILED_DIR} ${PARSER_KOMPILED_DIR}

${PARSER_TIMESTAMP}: semantics/parsing.k semantics/syntax.k
	mkdir -p ${PARSER_KOMPILED_DIR}
	kompile --backend llvm --gen-glr-bison-parser --syntax-module CPP2-SYNTAX --directory ${PARSER_KOMPILED_DIR} $<

${TIMESTAMP}: semantics/cpp2.k semantics/syntax.k
	mkdir -p ${KOMPILED_DIR}
	kompile --backend haskell --directory ${KOMPILED_DIR} $<

PREFIX ?= /usr

install: parser main scripts/kcpp2
	mkdir -p ${PREFIX}
	mkdir -p ${PREFIX}/bin
	mkdir -p ${PREFIX}/lib/kcpp2
	mkdir -p ${PREFIX}/libexec/kcpp2
	cp ${BUILD_ROOT}/bin/kcpp2 ${PREFIX}/bin/
	cp ${BUILD_ROOT}/libexec/kcpp2/extract-translation-result.py ${PREFIX}/libexec/kcpp2/
	rm -rf ${PREFIX}/lib/kcpp2
	cp -R ${BUILD_ROOT}/lib/kcpp2 ${PREFIX}/lib/kcpp2