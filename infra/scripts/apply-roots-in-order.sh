#! /usr/bin/env bash

set -euo pipefail

if [[ -z "${TARGET_DEPLOYMENT:-}" ]]; then
  echo "Error: TARGET_DEPLOYMENT is not set"
  exit 1
fi

ORDER=$(yq ".running-order.${TARGET_DEPLOYMENT}.layers[] | .phases[].roots[]" "./infra/deployments/running-order.yml")

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
LOG_PATH="./logs/${TIMESTAMP}"
mkdir -p "${LOG_PATH}"

CHECKPOINT_FILE="./logs/checkpoint-${TARGET_DEPLOYMENT}"
touch "${CHECKPOINT_FILE}"

RESUME_FROM_CHECKPOINT=${RESUME_FROM_CHECKPOINT:-false}
CHECKPOINT=$(cat "${CHECKPOINT_FILE}")
CHECKPOINT_DEFAULTED=false
if [[ -z "${CHECKPOINT}" ]]; then
  CHECKPOINT="$(echo "${ORDER}" | head -n1)"
  CHECKPOINT_DEFAULTED=true
fi

echo "========[Applying ${TARGET_DEPLOYMENT} Terraform]"
echo "=> Target environment:     ${TARGET_ENVIRONMENT}"
echo "=> Target deployment:      ${TARGET_DEPLOYMENT}"
echo "=> Log file path:          ${LOG_PATH}"

if [[ -n "${CHECKPOINT}" ]] && [[ "${RESUME_FROM_CHECKPOINT}" == true ]]; then
  echo -n "=> Resuming from:          ${CHECKPOINT}"
  if [[ "${CHECKPOINT_DEFAULTED}" == true ]]; then
    echo -n " (default; no previous checkpoint was found)"
  fi
  echo ""
fi

echo "=> Running order:"
echo "${ORDER}" | xargs printf "\t%s\n"
echo "========"

if [[ "${RESUME_FROM_CHECKPOINT}" == false ]]; then
  echo ""
  echo "TIP: Set environment variable RESUME_FROM_CHECKPOINT=true to start from where the last run finished."
fi

echo ""

I=0
HAS_RESUMED=false
for root in ${ORDER}; do
  I=$((I + 1))

  if [[ "${RESUME_FROM_CHECKPOINT}" == true ]] && [[ "${HAS_RESUMED}" == false ]]; then
    if [[ "${root}" == "${CHECKPOINT}" ]]; then
      HAS_RESUMED=true
    else
      echo "Skipping ${root} because it comes before the checkpoint (${CHECKPOINT})"
      continue
    fi
  fi

  LOG_FILE="${LOG_PATH}/$(printf "%02d" "${I}")-$(echo "${root}" | tr "/" "_")"
  touch "${LOG_FILE}"
  echo "${root}" >"${CHECKPOINT_FILE}"
  make "${TARGET_ENVIRONMENT}" "${root}" apply 2>&1 | tee >(sed -e 's/\x1b\[[0-9;]*[mGKHF]//g' >"${LOG_FILE}")
done

# we should removed the checkpoint if everything ran successfully
# so that future runs don't skip everything
rm "${CHECKPOINT_FILE}"
