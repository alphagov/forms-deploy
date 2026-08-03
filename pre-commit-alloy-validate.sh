#!/usr/bin/env bash
set -euo pipefail

make alloy_validate CHANGED_FILES="${*}"
