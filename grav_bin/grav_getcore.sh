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
# Remove enclosing double quotes
CTX_DIR="$(cat ${HOME_DIR}/.context | tr -d '"' | cut -d'=' -f2)"
ROOT_DIR="$(cat ${CTX_DIR}/.config.root | tr -d '"' | cut -d'=' -f2)"
CACHE_DIR="$(cat ${CTX_DIR}/.config.cache | tr -d '"' | cut -d'=' -f2)"
DATA_DIR="$(cat ${CTX_DIR}/.config.data | tr -d '"' | cut -d'=' -f2)"
DOCK_DIR="$(cat ${CTX_DIR}/.config.docker | tr -d '"' | cut -d'=' -f2)"
BIN_DIR="$(cat ${CTX_DIR}/.config.bin | tr -d '"' | cut -d'=' -f2)"
KEY_DIR="$(cat ${CTX_DIR}/.config.key | tr -d '"' | cut -d'=' -f2)"
LIB_DIR="$(cat ${CTX_DIR}/.config.lib | tr -d '"' | cut -d'=' -f2)"

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav
source "${LIB_DIR}"/libgrav_get

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_CORE="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav"}"
   local _GRAV_KIND="${_ARGV[3]:-"core"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_core [grav_imgname] [grav_kindname]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:       grav_core: prod|dev|X.Y.Z  - (#=prod)"
   local _GRAV_ARG2="ARG2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)"
   local _GRAV_ARG3="ARG3: [grav_kindname]: core|skeletons  - (*=core)"
   local _GRAV_INFO="INFO: ${CMD} prod grav-admin"
   local _GRAV_HELP="HELP: ${CMD}: Download grav core packages depending from some entered arguments. (See NOTE, INFO and ARGS)"

   if [ ${_ARGC} -lt 1 ]; then 
      usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}" \
         "${_GRAV_ARG3}"
   fi

   getcore \
      "${_GRAV_CORE}" \
      "${_GRAV_NAME}" \
      "${_GRAV_KIND}"

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
