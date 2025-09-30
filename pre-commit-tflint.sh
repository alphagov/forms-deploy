#!/usr/bin/env bash
tflint --init
make -j4 -k tflint CHANGED_FILES="${*}"
