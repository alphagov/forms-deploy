#!/usr/bin/env bash
set -eu

RED='\033[0;31m'
NO_COLOUR='\033[0m'

for file in "$@"; do
  DIRECTORY="$(dirname "$file")"
  FILENAME="$(basename "$file")"

  pushd "$DIRECTORY"

  lint=$(terraform fmt -write=false -diff=true -list=true "${FILENAME}");
  if [ -n "${lint}" ]; then
    echo -e "${RED}Your code is not in a canonical format:${NO_COLOUR}";
    echo ;
    echo "${lint}";
    echo ;
    echo -e "${RED}To apply these changes run the following command from the root of the forms-deploy repo:${NO_COLOUR}";
    echo "cd '${DIRECTORY}' && terraform fmt '${FILENAME}' && git add '${FILENAME}'; cd -";
    echo ;
    echo "---";
    echo ;
    exit 1;
  fi;

  popd
done
