#!/usr/bin/env bash

set -euo pipefail
#set -x # Debug flag

#if [[ ! -n "${BUILDPLATFORM-""}" ]]; then 
#    echo "Error: ${0}: Not running inside a docker buildx context."
#    exit 1 
#fi

declare STAGE_NAME="$(basename ${0})"
declare STAGE_IDX="$(echo ${STAGE_NAME} | cut -d'-' -f1)"
declare STAGE_CMD="$(echo ${STAGE_NAME} | cut -d'-' -f3)"
declare STAGE_SUB="$(echo ${STAGE_NAME} | cut -d'-' -f4 | cut -d'.' -f1)"
declare STAGE_ARG="${1:-"exec"}"

if [ "${STAGE_ARG}" == "noexec" ]; then 
    echo "[STAGE: ${STAGE_IDX}] ${STAGE_CMD} ${STAGE_SUB} not executed..."
    exit 0
else
    echo "[STAGE: ${STAGE_IDX}] ${STAGE_CMD} ${STAGE_SUB}..."
fi

echo "------------------------------------------------------------------------------"
