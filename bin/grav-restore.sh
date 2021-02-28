#!/usr/bin/env bash
set -euo pipefail

GRAV_ARG1="${1:-""}"
GRAV_BACK="${GRAV_ARG1##*/}"
GRAV_ROOT="/var/www"
GRAV_HOME="${GRAV_ROOT}/grav-admin"

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
   scp "${GRAV_ARG1}" "${GRAV_ROOT}"
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
echo "... restore operation done!"
