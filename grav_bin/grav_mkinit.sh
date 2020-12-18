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
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

# Preset directories
ROOT_DIR="${HOME_DIR}/grav_rootfs"
CACHE_DIR="${HOME_DIR}/grav_cache"
DATA_DIR="${HOME_DIR}/grav_data"
DOCK_DIR="${HOME_DIR}/grav_docker"
BIN_DIR="${HOME_DIR}/grav_bin"
CFG_DIR="${HOME_DIR}/grav_cfg"
KEY_DIR="${HOME_DIR}/grav_key"
LIB_DIR="${HOME_DIR}/grav_lib"

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

   local _GRAV_CMD="${_ARGV[1]}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_command"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1: grav_command: init - (#=init)"
   local _GRAV_INFO="INFO: ${CMD} init"
   local _GRAV_HELP="HELP: ${CMD}: Use the 'init' command to initialize the project environment with context files under the ${CFG_DIR} directory. (See NOTE, INFO and ARGS)"

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
   
   if [ ${_RC} -eq 0 ]; then libgrav::help "INFO: Reload bash from the command line with 'source \${HOME}/.bashrc'"; fi

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
