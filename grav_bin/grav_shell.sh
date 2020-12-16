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
source "${LIB_DIR}"/libgrav_docker

# ##### #
# FUNCS #
# ##### #

# #### #
# MAIN #
# #### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_SHELL="${_ARGV[1]:-"bash"}"
   local _GRAV_NAME="${_ARGV[2]:-"grav"}"
   
   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_shell [grav_imgname]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     grav_shell: sh|ash|bash - (#=bash)"
   local _GRAV_ARG2="ARG2: [grav_imgname]: any|(*)     - (*=grav-admin)"
   local _GRAV_INFO="INFO: ${CMD} bash grav"
 
   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}"; fi

   shell "${_GRAV_NAME}" "${_GRAV_SHELL}"

   _RC=$?

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
