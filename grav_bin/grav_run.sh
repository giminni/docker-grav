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
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_USER="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav-admin"}"
   local _GRAV_TAG="${_ARGV[3]:-"latest"}"
   local _GRAV_DATA="${_ARGV[4]:-"grav_data"}"
   
   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_user [grav_imgname=grav] [grav_imgtag=latest] [grav_voldata=grav_data]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:      grav_user: any|(#) - (#=grav)"
   local _GRAV_ARG2="ARG2: [grav_imgname|: any|(*) - (*=grav-admin)"
   local _GRAV_ARG3="ARG3:  [grav_imgtag|: any|(*) - (*=latest)"
   local _GRAV_ARG4="ARG4: [grav_voldata]: any|(*) - (*=grav_data)"
   local _GRAV_INFO="INFO: ${CMD} grav grav latest grav_data"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}"; fi

   # Check if keys and volumes are available
   if [ ! -f ${CFG_DIR}/.config.pass ] || [ ! -f $(cat ${CFG_DIR}/.config.pass | cut -d'=' -f2) ]; then usage 2 "FAIL: User and password not provided! Please run grav_mkpass.sh first...";
      elif [ ! -f ${CFG_DIR}/.config.ssh ] || [ ! -f $(cat ${CFG_DIR}/.config.ssh | cut -d'=' -f2) ]; then usage 2 "FAIL: SSH files not provided! Please run grav_mkssh.sh first...";
      elif [ ! -f ${CFG_DIR}/.config.data ] || [ ! -d $(cat ${CFG_DIR}/.config.data | cut -d'=' -f2) ]; then usage 2 "FAIL: Data volume not provided! Please run grav_mkdata.sh first...";
   fi

   run "${_GRAV_USER}" "${_GRAV_NAME}" "${_GRAV_TAG}" "${_GRAV_DATA}"

   _RC=$?

   if [ ${_RC} -eq 125 ]; then
#   	usage 3 "FAIL: Docker image does not exists! Execute grav-build.sh first..."
      ${PWD}/grav_build.sh testing grav
      $0 grav
   fi

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
