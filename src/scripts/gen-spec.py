#!/usr/bin/env python3

import json
from argparse import ArgumentParser
from sys import stdin

from pyk.kore import parser as KoreParser


def main():
    parser = create_argument_parser()
    args = parser.parse_args()
    print("Hello, world")

def create_argument_parser() -> ArgumentParser:
    parser = ArgumentParser(description='Generate a specification from a processed program')
    parser.add_argument('--input-configuration', type=str, help='Path to the Kore result of translation')
    return parser

if __name__ == "__main__":
   main()
