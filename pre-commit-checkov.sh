#!/usr/bin/env bash
set -euo pipefail

make checkov CHANGED_FILES="${*}"
