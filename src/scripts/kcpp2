#!/usr/bin/env bash

set -euo pipefail

kcpp2_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
kcpp2_install_prefix=$(realpath "$kcpp2_script_dir/..")
kcpp2_parser_dir="$kcpp2_install_prefix/lib/kcpp2/parser/parsing-kompiled"
kcpp2_semantics_dir="$kcpp2_install_prefix/lib/kcpp2/semantics/cpp2-kompiled"
extract_translation_result="$kcpp2_install_prefix/libexec/kcpp2/extract-translation-result.py"

error() { echo "$@" ; exit 1; }

verbose_echo() {
    ! "$verbose" || echo "$@";
}

execute_command() {
    verbose_echo "$@"
    $@
}

parse() {
    local input_file="$1";
    local output_file="$2";

    verbose_echo "Parsing '$input_file' into '$output_file'"
    execute_command kparse --definition "$kcpp2_parser_dir" --output-file "$output_file" "$input_file";
}

disambiguate() {
    local input_file="$1";
    local output_file="$2";
    local depth="$3";

    verbose_echo "Disambiguating '$input_file' into '$output_file'"
    local krun_args=(--definition "$kcpp2_parser_dir" --output kore --output-file "$output_file")
    krun_args+=( --depth "$depth" )
    krun_args+=(--parser cat "$input_file")
    execute_command krun "${krun_args[@]}";
}

run_phase() {
    local phase="$1"; shift
    local input_file="$1"; shift
    local output_file="$1"; shift
    local depth="$1"; shift
    local krun_args=()
    krun_args+=(--definition "$kcpp2_semantics_dir" --parser cat)
    krun_args+=(--output kore --output-file "$output_file")
    krun_args+=("-cPHASE=$phase")
    if [ "$depth" != "-1" ]; then
        krun_args+=(--depth "$depth")
    fi
    krun_args+=("$input_file")
    execute_command krun --no-exc-wrap "${krun_args[@]}" 2>/dev/null;
}

run_translation() {
    local input_file="$1"; shift
    local output_file="$1"; shift
    local depth="$1"; shift
    verbose_echo "Translating '$input_file' into '$output_file'"
    run_phase "TranslationPhase()" "$input_file" "$output_file" "$depth"
}

run_execution() {
    local input_file="$1"; shift
    local output_file="$1"; shift
    local depth="$1"; shift
    verbose_echo "Executing '$input_file' into '$output_file'"
    run_phase "ExecutionPhase()" "$input_file" "$output_file" "$depth"
}

pretty_print() {
    local semantics_dir="$1"; shift
    local input_kore_file="$1"; shift
    local output_file="$1"; shift
    verbose_echo "Pretty printing '$input_kore_file' into '$output_file'"
    local args=( --definition "$semantics_dir" "$input_kore_file" "${result_format[@]}")
    if [ -n "$output_file" ]; then
        args+=(--output-file "$output_file")
    fi
    execute_command kore-print "${args[@]}"
}

extract_parsed_translation_unit() {
    local input_file="$1";
    local output_file="$2";

    # TODO: Move this script to pyk?
    prefix="Lbl'-LT-'generatedTop'-GT-'{}(Lbl'-LT-'T'-GT-'{}(Lbl'-LT-'k'-GT-'{}(kseq{}(inj{SortDeclarations{}, SortKItem{}}("
    string=$(cat "$input_file")
    foo=${string#"$prefix"}
    # Remove suffix of the shape suffix="),dotk{}()))),Lbl'-LT-'generatedCounter'-GT-'{}(\dv{SortInt{}}(\"$SOMETHING\")))"
    # where $SOMETHING is something.
    # First, remove the last three closing parentheses and the closing '"'.
    suffix1="\")))"
    foo=${foo%"$suffix1"}
    # Now, remove a number from the end.
    foo=$(echo "$foo" | sed -E 's/(.*)([0-9]+)/\1/')
    # Now, remove the generated counter.
    suffix2=",Lbl'-LT-'generatedCounter'-GT-'{}(\dv{SortInt{}}(\""
    foo=${foo%"$suffix2"}
    # Now. remove the rest
    suffix3="),dotk{}())))"
    foo=${foo%"$suffix3"}
    echo "inj{SortDeclarations{}, SortKItem{}}(${foo})" > "$output_file"
}


# Main
# ====

verbose=false
result_format=()
upto="exec" # also: "transl" "disambig"
depth="-1"
input_file=
output_file=
while [[ $# -gt 0 ]]; do
    arg="$1"; shift
	case "$arg" in
        '--output-file')               output_file="$1"; shift; continue ;;
        '--result-format')             result_format=(--output "$1"); shift; continue ;;
        '--upto')                      upto="$1"; shift; continue ;;
        '--depth')                     depth="$1"; shift; continue ;;
        '--verbose')                   verbose=true; continue ;;
        *)  [[ -z "$input_file" ]] || error "Too many arguments."
            input_file="$arg"; continue ;;
	esac
done
[[ -n "$input_file" ]] || { error "Input file not specified." ; }


tmp_dir="${KCPP2_TMP:-$(mktemp -d)}"
basename="${tmp_dir}/$(basename ${input_file})"

#### Parsing phase
parse "$input_file" "$basename".kore
phase_depth="-1"
if [ "$upto" = "disambig" ]; then
    phase_depth="$depth"
fi
disambiguate "$basename".kore "$basename".disambiguated.kore "$phase_depth"
if [ "$upto" = "disambig" ]; then
    pretty_print "$kcpp2_parser_dir" "$basename".disambiguated.kore "$output_file" ;
    exit ;
fi
extract_parsed_translation_unit "$basename".disambiguated.kore "$basename".stripped.kore

#### Translation phase
phase_depth="-1"
if [ "$upto" = "transl" ]; then
    phase_depth="$depth"
fi
run_translation "$basename".stripped.kore "$basename".translated.kore "$phase_depth" || {
    retcode="$?"
    verbose_echo "Translation failed with code '$retcode'"
    if [ -f "$basename".translated.kore ]; then
        pretty_print "$kcpp2_semantics_dir" "$basename".translated.kore "$output_file" ;
    fi
    exit "$retcode"
}
if [ "$upto" = "transl" ]; then
    pretty_print "$kcpp2_semantics_dir" "$basename".translated.kore "$output_file" ;
    exit ;
fi


#### Execution phase
execute_command "$extract_translation_result" \
  --input-configuration "$basename".translated.kore \
  --output-file "$basename".translation-result.kore

rm -f "$basename".executed.kore
run_execution "$basename".translation-result.kore "$basename".executed.kore "$depth" || {
    retcode="$?"
    verbose_echo "Execution failed with code '$retcode'."
    if [ -f "$basename".executed.kore ]; then
        pretty_print "$kcpp2_semantics_dir" "$basename".executed.kore "$output_file" ;
    fi
    exit "$retcode"
}
pretty_print "$kcpp2_semantics_dir" "$basename".executed.kore "$output_file" ;
