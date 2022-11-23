#!/usr/bin/env python3

import json
from argparse import ArgumentParser
import tempfile
import os.path
import pathlib
from sys import stdin

from pyk.kore.syntax import (App)
from pyk.kore import parser as KoreParser
  
class Kcpp2Error(Error): ...


def create_argument_parser() -> ArgumentParser:
    parser = ArgumentParser(description='Extracts the result of translation from the final configuration.')
    parser.add_argument('input-file', type=str, help='Path to the *.cpp2 file')
    parser.add_argument('--output-file', type=str, help='Path to file where to write the resulting configuration')
    parser.add_argument('--upto', choices=['disambiguate','translate','execute'], default='exec')
    parser.add_argument('--depth', type=int, default=-1)
    parser.add_argument('-v', '--verbose', action='store_true')
    parser.add_argument('--temp-dir', type=str, help='A directory for storing temporary files', default="")
    return parser

verbose = False

kcpp2_script_dir = pathlib.Path( __file__ ).parent.absolute()
kcpp2_install_prefix = os.path.realpath(os.path.join(kcpp2_script_dir, '..'))
kcpp2_parser_dir = os.path.abspath(os.path.join(kcpp2_install_prefix, 'lib/kcpp2/parser/parsing-kompiled'))
kcpp2_semantics_dir = os.path.abspath(os.path.join(kcpp2_install_prefix, 'lib/kcpp2/semantics/cpp2-kompiled'))
# We will not need this, because we will perform the task in-script
# extract_translation_result="$kcpp2_install_prefix/libexec/kcpp2/extract-translation-result.py"

def verbose_echo(text):
    if verbose:
        print(text)

def execute_command(command) -> int :
    verbose_echo(command)
    return os.system(command)

def parse(input_file, output_file) -> int:
    verbose_echo("Parsing '{}' into '{}'".format(input_file, output_file))
    return execute_command("kparse --definition {} --output-file {} {}".format(kcpp2_parser_dir, output_file, input_file))

def disambiguate(input_file, output_file, depth) -> int:
    verbose_echo("Disambiguating '{}' into '{}' with depth {}".format(input_file, output_file, depth))
    return execute_command("krun --definition {} --output kore --output-file {} --depth {} --parser cat {}".format(kcpp2_parser_dir, output_file, depth, input_file))

def run_phase(phase, input_file, output_file, depth) -> int:
    depth_str = ""
    if depth != -1:
        depth_str = "--depth {}".format(depth)
    return execute_command("krun --no-exc-wrap --definition {} --parser cat --output kore --output-file {} -cPHASE={} {} {} 2>/dev/null".format(
        kcpp2_semantics_dir, output_file, phase, depth_str, input_file
    ))

def run_translation(input_file, output_file, depth) -> int:
    verbose_echo("Translating '{}' into '{}'".format(input_file, output_file))
    return run_phase(phase="TranslationPhase()", input_file=input_file, output_file=output_file, depth=depth)

def run_execution(input_file, output_file, depth) -> int:
    verbose_echo("Executing '{}' into '{}'".format(input_file, output_file))
    return run_phase(phase="ExecutionPhase()", input_file=input_file, output_file=output_file, depth=depth)

def pretty_print(semantics_dir, input_kore_file, output_file, output_format="pretty"):
    verbose_echo("Pretty printing '{}' into '{}'".format(input_kore_file, output_file))
    output_file_str=""
    if output_file != "":
        output_file_str = "--output-file {}".format(output_file)
    result = execute_command("kore-print --definition {} --output {} {}".format(semantics_dir, output_format, output_file_str))
    if result != 0:
        raise Kcpp2Error

def getParsingResult(cfg):
    print(cfg)
    exit(1)

def getTranslationResult(cfg):
    match cfg:
        case App("Lbl'-LT-'generatedTop'-GT-'", _,
                (App("Lbl'-LT-'T'-GT-'", _,
                    (phaseCell, kCell, translationResultCell, statesCell, exitCodeCell)), counter)
        ):
            return translationResultCell

def extract_translation_result(input_file, output_file):
    parser = KoreParser.KoreParser(open(input_file, "r").read())
    cfg = parser.pattern()
    tr = getTranslationResult(cfg)
    with open(output_file, "w") as fw:
        fw.write(tr.text)

def depth_for_phase(args, phase):
    if phase == args.upto:
        return args.depth
    return -1 # the default depth

def main():
    parser = create_argument_parser()
    args = parser.parse_args()
    verbose = args.verbose
    temp_dir = args.temp_dir
    if temp_dir == "":
        temp_dir = tempfile.TemporaryDirectory()
    
    # Parse & disambiguate
    basename = os.path.join(temp_dir, os.path.basename(args.input_file))
    parse(args.input_file, (basename + ".kore"))
    result = disambiguate((basename + ".kore"), (basename + ".disambiguated.kore"), depth_for_phase("disambiguate"))
    if args.upto == "disambiguate" or result != 0:
        pretty_print(kcpp2_parser_dir, (basename + ".disambiguated.kore"), args.output_file)
    if result != 0:
        verbose_echo("Disambiguation failed with result: {}".format(result))
        exit(1)
    
    # Translate
    extract_parsed_translation_unit((basename + ".disambiguated.kore"), (basename + ".stripped.kore"))
    result = run_translation((basename + ".stripped.kore"), (basename + ".translated.kore"), depth)
    if args.upto == "translate" or result != 0:
        pretty_print(kcpp2_semantics_dir, (basename + ".translated.kore"), args.output_file)
    if result != 0:
        verbose_echo("Translation failed with result: {}".format(result))
        exit(1)
    
    # Execution
    extract_translation_result((basename + ".translated.kore"), (basename + ".translation-result.kore"))
    result = run_execution((basename + ".translation-result.kore"), (basename + ".executed.kore"), depth)
    pretty_print(kcpp2_semantics_dir, (basename + ".executed.kore"), args.output_file)
    if result != 0:
        verbose_echo("Execution failed with result: {}".format(result))
        exit(1)
    return

if __name__ == "__main__":
   main()
