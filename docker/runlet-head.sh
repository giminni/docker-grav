set -euo pipefail
#set -x # Debug flag

if [[ ! -n "${BUILDPLATFORM-""}" ]]; then 
    echo "Error: ${0}: Not running inside a buildx context."
    exit 1 
fi

declare STAGE_NAME="$(basename ${0})"
declare STAGE_CMD="$(echo ${0} | cut -d'-' -f2)"
declare STAGE_SUB="$(echo ${0} | cut -d'-' -f3 | cut -d'.' -f1)"
declare STAGE_ARG="${1:-"exec"}"

if [ "${STAGE_ARG}" == "noexec" ]; then 
    echo "[${STAGE_NAME}] ${STAGE_CMD} ${STAGE_SUB} not executed..."
    exit 0
else
    echo "[${STAGE_NAME}] ${STAGE_CMD} ${STAGE_SUB}..."
fi

echo "------------------------------------------------------------------------------"
