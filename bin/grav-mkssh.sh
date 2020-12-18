#!/usr/bin/env bash
# #### #
# INIT #
# #### #
set -euo pipefail

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"

if [[ ! -e "${HOME_DIR}/.context" ]]; then echo -e "\nFAIL: Context is not initialized! Please run '<PROJECT_HOME>/bin/grav-mkinit.sh init' first... "; exit 1; fi

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
function main() {
   # Initialize context
   libgrav::init

   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_EMAIL="${_ARGV[1]-""}"
   local _GRAV_TYPE="${_ARGV[2]:-"rsa"}"
   local _GRAV_LEN="${_ARGV[3]:-4096}"
   local _GRAV_SSH="${_ARGV[4]:-${KEY_DIR}/grav_${_GRAV_TYPE}}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} user_email [key-type] [key-len] [key-file]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1: user-email: any|(#)       - (#=email-address)"
   local _GRAV_ARG2="ARG2: [key-type]: rsa|dsa|ecdsa - (*=rsa)"
   local _GRAV_ARG3="ARG3:  [key-len]: 2048-8192     - (*=4096)"
   local _GRAV_ARG4="ARG4: [key-file]: any|(*)       - (*=${KEY_DIR}/grav_<grav-keytype>)"
   local _GRAV_INFO="INFO: ${CMD} grav@example.com rsa 4096 ${KEY_DIR}/grav_rsa"
   local _GRAV_HELP="HELP: ${CMD}: Create the required user SSH keys depending from some entered arguments. (See NOTE, INFO and ARGS)"

   if [ ${_ARGC} -lt 1 ]; then 
      libgrav::usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}" \
         "${_GRAV_ARG3}" \
         "${_GRAV_ARG4}"
   fi

   libgrav_mk::mk_ssh \
      "${_GRAV_EMAIL}" \
      "${_GRAV_TYPE}" \
      "${_GRAV_LEN}" \
      "${_GRAV_SSH}"
      
   RC=$?

   # Adjust ACL
   chmod 400 "${_GRAV_SSH}"
   chmod 600 "${_GRAV_SSH}.pub"

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
