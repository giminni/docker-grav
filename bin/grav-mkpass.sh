#!/usr/bin/env bash
# ### #
# INIT #
# ### #
set -euo pipefail

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

if [[ ! -e "${HOME_DIR}/.context" ]]; then echo -e "\nError: Context is not initialized!\nPlease run '<PROJECT_HOME>/bin/grav-mkinit.sh init' first... "; exit 1; fi

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
source "${LIB_DIR}"/libgrav_common
source "${LIB_DIR}"/libgrav_mk

# ##### #
# FUNCS #
# ##### #
function main() {
   # Initialize context
   libgrav_common::init

   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_SECS="${_ARGV[1]-""}"
   local _GRAV_USER="${_ARGV[2]:-$(id -un)}"
   local _GRAV_PASS="${_ARGV[3]:-"${KEY_DIR}/grav_pass.key"}"

   local _GRAV_LEN=11

   local _GRAV_TEXT="Error: Arguments are not provided!"
   local _GRAV_ARGS=" Args: ${CMD} user-pass [user-name] [pass-file]"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1:   user-pass: any|(#) - (#=minimum length: 11 chars)"
   local _GRAV_ARG2=" Arg2: [user-name]: any|(*) - (*=<current-user>,#=grav)"
   local _GRAV_ARG3=" Arg3: [pass-file]: any|(*) - (*=${KEY_DIR}/grav_pass.key]"
   local _GRAV_INFO=" Info: ${CMD} my-secret-pass grav ${KEY_DIR}/grav_pass.key"
   local _GRAV_HELP=" Help: ${CMD}: Create the required user password depending from some entered arguments. (See Note, Info and Args)"

   if [ ${_ARGC} -lt 1 ]; then 
      libgrav_common::usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}" \
         "${_GRAV_ARG3}"
   fi

   if [ ${#_GRAV_SECS} -lt ${_GRAV_LEN} ]; then libgrav_common::error 2 "Error: Password must contain at least ${_GRAV_LEN} chars!" "${NAME}"; fi

   libgrav_mk::mk_pass \
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
