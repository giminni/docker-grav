#!/usr/bin/env bash
# #### #
# INIT #
# #### #
set -euo pipefail

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

# Preset directories
ROOT_DIR="${HOME_DIR}/rootfs"
CACHE_DIR="${HOME_DIR}/cache"
DATA_DIR="${HOME_DIR}/data"
DOCK_DIR="${HOME_DIR}/docker"
BIN_DIR="${HOME_DIR}/bin"
CFG_DIR="${HOME_DIR}/cfg"
KEY_DIR="${HOME_DIR}/key"
LIB_DIR="${HOME_DIR}/lib"

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav
source "${LIB_DIR}"/libgrav_mk

# ##### #
# FUNCS #
# ##### #
function main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_CMD="${_ARGV[1]-""}"

   local _GRAV_TEXT="Error: Arguments are not provided!"
   local _GRAV_ARGS=" Args: ${CMD} grav-cmd"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1: grav-cmd: init - (#=init)"
   local _GRAV_INFO=" Info: ${CMD} init"
   local _GRAV_HELP=" Help: ${CMD}: Use the 'init' command to initialize the project environment with context files under the ${CFG_DIR} directory. (See Note, Info and Args)"

   if [ ${_ARGC} -lt 1 ]; then 
      libgrav::usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}"
   fi
   
   libgrav_mk::mk_init \
      "${_GRAV_CMD}" \
      "${HOME_DIR}" \
      "${ROOT_DIR}" \
      "${CACHE_DIR}" \
      "${DATA_DIR}" \
      "${DOCK_DIR}" \
      "${BIN_DIR}" \
      "${CFG_DIR}" \
      "${KEY_DIR}" \
      "${LIB_DIR}"

   _RC=$?
   
   if [ ${_RC} -eq 0 ]; then libgrav::help " Info: Reload bash from the command line with 'source \${HOME}/.bashrc'"; fi

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
