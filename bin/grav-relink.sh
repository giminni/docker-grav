#!/usr/bin/env bash
RC=0

SOURCE_ARG="${1:-""}"
TARGET_ARG="${2:-""}"

ROOT_DIR="/var/www/html"
SOURCE_DIR="../../../pages"
TARGET_DIR="user/images/g5_anacron"

SOURCE_PATH="${ROOT_DIR}/${TARGET_DIR}/${TARGET_ARG}/${SOURCE_DIR}/${SOURCE_ARG}.${TARGET_ARG}/images"
TARGET_PATH="${ROOT_DIR}/${TARGET_DIR}/${TARGET_ARG}"

if [ -z "${SOURCE_ARG}" ]; then
        echo "FAIL: Not enough arguments entered!"
        echo "INFO: ${0} <page-index> <page-name>"
        echo "HELP: ${0} 01 home"
        RC=1
fi

if [ ${RC} -eq 0 ]; then
        find "${SOURCE_PATH}" -type f -name "*" -print0 | while read -d $'\0' FILE; do
                FILE_NAME="${FILE##*/}"
                cd "${TARGET_PATH}"
                if [ -e "${FILE_NAME}" ]; then rm "${FILE_NAME}"; fi
                ln -s ${SOURCE_DIR}/${SOURCE_ARG}.${TARGET_ARG}/images/"${FILE_NAME}" "${FILE_NAME}"
        done
fi

exit ${RC}
