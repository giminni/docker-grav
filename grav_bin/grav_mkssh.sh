#!/usr/bin/env bash
# #### #
# INIT #
# #### #
set -e

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
ABS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${ABS_DIR%/*}"
DATA_DIR="${BASE_DIR}/grav_data"
ROOT_DIR="${BASE_DIR}/grav_rootfs"
BIN_DIR="${BASE_DIR}/grav_bin"
CFG_DIR="${BASE_DIR}/grav_config"
KEY_DIR="${BASE_DIR}/grav_keys"
LIB_DIR="${BASE_DIR}/grav_libs"

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav
source "${LIB_DIR}"/libgrav_mk

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_EMAIL="${_ARGV[1]}"
   local _GRAV_TYPE="${_ARGV[2]:-"rsa"}"
   local _GRAV_LEN="${_ARGV[3]:-4096}"
   local _GRAV_SSH="${_ARGV[4]:-${PWD}/grav_keys/grav_${_GRAV_TYPE}}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_email [grav_keytype] [grav_keylen] [grav_user] [grav_keyfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     grav_email: any|(#)"      - (#=own-email-address)
   local _GRAV_ARG2="ARG2: [grav_keytype]: rsa|dsa|ecdsa - (*=rsa)"
   local _GRAV_ARG3="ARG3:  [grav_keylen]: 2048-8192     - (*=4096)"
   local _GRAV_ARG4="ARG4:    [grav_user]: any|(*)       - (*=<current-user>)"
   local _GRAV_ARG5="ARG5: [grav_keyfile]: any|(*)       - (*=<current-dir>/grav_keys/grav_<grav-keytype>.key)"
   local _GRAV_INFO="INFO: ${CMD} grav@example.com rsa 4096 grav ${PWD}/grav_keys/grav_rsa.key"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}" "${_GRAV_ARG5}"; fi

   mkssh "${_GRAV_EMAIL}" "${_GRAV_TYPE}" "${_GRAV_LEN}" "${_GRAV_SSH}" <<< ""$'\n'"y" 2>&1 >/dev/null
   RC=$?

   chmod 400 "${_GRAV_SSH}"
   chmod 600 "${_GRAV_SSH}.pub"

   RC=$?

   echo "GRAV_SSH=${_GRAV_SSH}" > ${CFG_DIR}/.config.ssh

   return ${_RC}
}

# #### #
# MAIN #
# #### #
main ${ARGC} "${ARGV[@]}"

RC=$?

# #### #
# EXIT #
# #### #
exit ${RC}
