#!/usr/bin/env bash
set -euo pipefail

make fmt CHANGED_FILES="${*}"
