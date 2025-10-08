#!/usr/bin/env bash

FILE_DIR=$(dirname $(realpath "$0"))
MAKEFILE_DIR=$(realpath "${FILE_DIR}/../")
WORD_LIST=$(make -C "${MAKEFILE_DIR}" -f "${MAKEFILE_DIR}/Makefile" generate-completion-word-list)

_forms_makefile_completions()
{
    if [[ "$(pwd)" == "${MAKEFILE_DIR}" ]]; then
        COMPREPLY=($(compgen -W "${WORD_LIST}" "${COMP_WORDS[1]}"))
    fi
}

complete -F _forms_makefile_completions make
