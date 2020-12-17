#!/usr/bin/env bash
# #### #
# INIT #
# #### #
set -e

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

if [ ! -e "${HOME_DIR}/.context" ]; then echo -e "\nFAIL: Context is not initialized! Please run '<PROJECT_HOME>/grav_bin/grav_mkinit.sh init' first... "; exit 1; fi

# Remove enclosing double quotes
CTX_DIR="$(cat ${HOME_DIR}/.context | tr -d '"' | cut -d'=' -f2)"
LIB_DIR="$(cat ${CTX_DIR}/.config.lib | tr -d '"' | cut -d'=' -f2)"

# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav
source "${LIB_DIR}"/libgrav_mk

# ##### #
# FUNCS #
# ##### #
main() {
   # Initialize context
   init

   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_SECS="${_ARGV[1]}"
   local _GRAV_USER="${_ARGV[2]:-$(id -un)}"
   local _GRAV_PASS="${_ARGV[3]:-"${KEY_DIR}/grav_pass.key"}"

   local _GRAV_LEN=11

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_pass [grav_user] [grav_passfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:       grav_pass: any|(#) - (#=minimum 11 chars length)"
   local _GRAV_ARG2="ARG2:     [grav_user]: any|(*) - (*=<current-user>,#=grav)"
   local _GRAV_ARG3="ARG3: [grav_passfile]: any|(*) - (*=${KEY_DIR}/grav_pass.key]"
   local _GRAV_INFO="INFO: ${CMD} my-secret-pass grav ${KEY_DIR}/grav_pass.key"
   local _GRAV_HELP="HELP: ${CMD}: Create the required user password depending from some entered arguments. (See NOTE, INFO and ARGS)"

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

   if [ ${#_GRAV_SECS} -lt ${_GRAV_LEN} ]; then error 2 "FAIL: Password must contain at least ${_GRAV_LEN} chars!"; fi

   mkpass \
      "${_GRAV_SECS}" \
      "${_GRAV_USER}" \
      "${_GRAV_PASS}"

   RC=$?

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
