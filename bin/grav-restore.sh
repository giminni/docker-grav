#!/usr/bin/env bash
set -euo pipefail

GRAV_FILE="${1-"Undefined"}"
GRAV_HOST="${2:-"172.17.0.1"}"
GRAV_PATH="${3:-"/Users/de067018/Shared/Documents/Bea/WG29/Website/Baselines"}"
GRAV_PORT="${4:-22}"
GRAV_USER="${5:-"de067018"}"

GRAV_BACK="${GRAV_FILE##*/}"
GRAV_ROOT="/var/www"
GRAV_HOME="${GRAV_ROOT}/grav-admin"
GRAV_LINK="${GRAV_ROOT}/html"

if [ "${GRAV_FILE}" == "Undefined" ]; then
        echo "  Error: Filename not found!"
        echo "  Usage: ${0} <file_name> [host_name=${GRAV_HOST}] [file_path=${GRAV_PATH}] [host_port=${GRAV_PORT}] [user_name=${GRAV_USER}]"
        echo "Example: ${0} *20210311* ${GRAV_HOST} ${GRAV_PATH} ${GRAV_PORT} ${GRAV_USER}"
        exit
fi

if [ -e "${GRAV_ROOT}/${GRAV_BACK}".zip ]; then
        GRAV_FILE="$(ls ${GRAV_ROOT}/${GRAV_BACK} | sed -r 's/^.+\///')"
else
        GRAV_FILE="${GRAV_BACK}".zip
fi

echo "Start restore operation..."

if [ ! -e ${GRAV_ROOT}/${GRAV_FILE} ]; then
   if [ $(ls "${GRAV_ROOT}"/*.zip 2>/dev/null | head -n 1) ]; then
      echo "Cleanup old zip files..."
      find "${GRAV_ROOT}" -name *.zip -exec rm -f {} \;
   else
      echo "No zip files found to cleanup..."
   fi
fi

if [ ! -e ${GRAV_ROOT}/${GRAV_FILE} ]; then
   echo "Download ${GRAV_ROOT}/${GRAV_FILE} file..."
   scp -P ${GRAV_PORT} -i "${HOME}/.ssh/id_rsa" "${GRAV_USER}@${GRAV_HOST}:${GRAV_PATH}/${GRAV_FILE}" "${GRAV_ROOT}"
else
   echo "Zip file ${GRAV_ROOT}/${GRAV_FILE} file exists..."
fi

echo "Remove content from ${GRAV_HOME} directory..."
find "${GRAV_HOME}" -xdev -depth -mindepth 1 -exec rm -Rf {} \;

cd "${GRAV_HOME}"
echo "Unzip ${GRAV_FILE} file..."
unzip -q ../"${GRAV_FILE}"
echo "Change directory permissions to 750..."
find ./ -type d -exec chmod 750 {} \;
echo "Change file permissions to 660..."
find ./ -type f -exec chmod 660 {} \;
echo "Set execute flag in ${GRAV_HOME}/bin directory..."
chmod +x "${GRAV_HOME}"/bin/*

if [ ! -h "${GRAV_LINK}" ]; then
   echo "Link ${GRAV_LINK} added..."
   ln -s "${GRAV_HOME}" "${GRAV_LINK}"
else
   if [ ! -e "${GRAV_LINK}/user/config/site.yaml" ]; then
     echo "Link ${GRAV_LINK} readded..."
     rm -rf "${GRAV_LINK}"
     ln -s "${GRAV_HOME}" "${GRAV_LINK}"
   else
     echo "Link ${GRAV_LINK} exists..."
  fi
fi

echo "... restore operation done!"
