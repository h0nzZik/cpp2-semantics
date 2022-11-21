#!/usr/bin/env python3

import json
from argparse import ArgumentParser
from sys import stdin

from pyk.kore.syntax import (App)
from pyk.kore import parser as KoreParser


def main():
    parser = create_argument_parser()
    args = parser.parse_args()
    parser = KoreParser.KoreParser(open(args.input_configuration, "r").read())
    cfg = parser.pattern()
    match cfg:
        case App("Lbl'-LT-'generatedTop'-GT-'", _,
                (App("Lbl'-LT-'T'-GT-'", _,
                    (phaseCell, kCell, translationResultCell, statesCell, exitCodeCell)), counter)
        ):
            open(args.output_file, "w").write(translationResultCell.text)
        case _:
            print("The configuration has an unexpected shape")

def create_argument_parser() -> ArgumentParser:
    parser = ArgumentParser(description='Extracts the result of translation from the final configuration.')
    parser.add_argument('--input-configuration', type=str, help='Path to the configuration (Kore)')
    parser.add_argument('--output-file', type=str, help='Path to the output file')
    return parser

if __name__ == "__main__":
   main()
