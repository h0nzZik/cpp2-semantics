#!/usr/bin/env python3

import json
from argparse import ArgumentParser
import tempfile
import os.path
import pathlib
from sys import stdin

from pyk.kore.syntax import (App)
from pyk.kore import parser as KoreParser
  

def create_argument_parser() -> ArgumentParser:
    parser = ArgumentParser(description='Extracts the result of translation from the final configuration.')
    parser.add_argument('input-file', type=str, help='Path to the *.cpp2 file')
    parser.add_argument('--output-file', type=str, help='Path to file where to write the resulting configuration')
    parser.add_argument('--upto', choices=['disambig','transl','exec'], default='exec')
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

def execute_command(command):
    verbose_echo(command)
    os.system(command)

def parse(input_file, output_file):
    verbose_echo("Parsing '{}' into '{}'".format(input_file, output_file))
    execute_command("kparse --definition {} --output-file {} {}".format(kcpp2_parser_dir, output_file, input_file))

def disambiguate(input_file, output_file, depth):
    verbose_echo("Disambiguating '{}' into '{}' with depth {}".format(input_file, output_file, depth))
    execute_command("krun --definition {} --output kore --output-file {} --depth {} --parser cat {}".format(kcpp2_parser_dir, output_file, depth, input_file))

def run_phase(phase, input_file, output_file, depth):
    depth_str = ""
    if depth != -1:
        depth_str = "--depth {}".format(depth)
    execute_command("krun --no-exc-wrap --definition {} --parser cat --output kore --output-file {} -cPHASE={} {} {} 2>/dev/null".format(
        kcpp2_semantics_dir, output_file, phase, depth_str, input_file
    ))

def run_translation(input_file, output_file, depth):
    verbose_echo("Translating '{}' into '{}'".format(input_file, output_file))
    run_phase(phase="TranslationPhase()", input_file=input_file, output_file=output_file, depth=depth)

def run_execution(input_file, output_file, depth):
    verbose_echo("Executing '{}' into '{}'".format(input_file, output_file))
    run_phase(phase="ExecutionPhase()", input_file=input_file, output_file=output_file, depth=depth)

def pretty_print(semantics_dir, input_kore_file, output_file, output_format="pretty"):
    verbose_echo("Pretty printing '{}' into '{}'".format(input_kore_file, output_file))
    output_file_str=""
    if output_file != "":
        output_file_str = "--output-file {}".format(output_file)
    execute_command("kore-print --definition {} --output {} {}".format(semantics_dir, output_format, output_file_str))

def main():
    parser = create_argument_parser()
    args = parser.parse_args()
    verbose = args.verbose
    temp_dir = args.temp_dir
    if temp_dir == "":
        temp_dir = tempfile.TemporaryDirectory()
    
    basename = os.path.join(temp_dir, os.path.basename(args.input_file))
    parse(args.input_file, (basename + ".kore"))



if __name__ == "__main__":
   main()
