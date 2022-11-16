BUILD_ROOT := ./build
KOMPILED_DIR := ${BUILD_ROOT}/cpp2-kompiled
TIMESTAMP := ${KOMPILED_DIR}/cpp2-kompiled/timestamp

PARSER_KOMPILED_DIR := ${BUILD_ROOT}/cpp2-parser-kompiled
PARSER_TIMESTAMP := ${PARSER_KOMPILED_DIR}/parsing-kompiled/timestamp

default: parser main

.PHONY: parser main clean install

parser: ${PARSER_TIMESTAMP}
main: ${TIMESTAMP}

clean:
	rm -rf ${KOMPILED_DIR} ${PARSER_KOMPILED_DIR}

${PARSER_TIMESTAMP}: semantics/parsing.k semantics/syntax.k
	mkdir -p ${PARSER_KOMPILED_DIR}
	kompile --backend llvm --gen-glr-bison-parser --syntax-module CPP2-SYNTAX --directory ${PARSER_KOMPILED_DIR} $<

${TIMESTAMP}: semantics/cpp2.k semantics/syntax.k
	mkdir -p ${KOMPILED_DIR}
	kompile --backend haskell --directory ${KOMPILED_DIR} $<

INSTALL_PREFIX ?= /usr

install: parser main scripts/kcpp2
	mkdir -p ${INSTALL_PREFIX}/bin
	mkdir -p ${INSTALL_PREFIX}/lib/kcpp2
	cp scripts/kcpp2 ${INSTALL_PREFIX}/bin
	cp -R ${PARSER_KOMPILED_DIR} ${INSTALL_PREFIX}/lib/kcpp2
	cp -R ${KOMPILED_DIR} ${INSTALL_PREFIX}/lib/kcpp2
