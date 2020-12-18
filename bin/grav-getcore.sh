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
source "${LIB_DIR}"/libgrav_get

# ##### #
# FUNCS #
# ##### #
function main() {
   # Initialize context
   libgrav::init

   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_CORE="${_ARGV[1]-""}"
   local _GRAV_NAME="${_ARGV[2]:-"grav"}"
   local _GRAV_KIND="${_ARGV[3]:-"core"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} core-ver img-name [kind-name]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:    core-ver: all|prod|dev|X.Y.Z - (#=all)"
   local _GRAV_ARG2="ARG2:    img-name: grav-admin|grav    - (*=grav-admin)"
   local _GRAV_ARG3="ARG3: [kind-name]: core|skeletons     - (*=core)"
   local _GRAV_INFO="INFO: ${CMD} prod grav-admin"
   local _GRAV_HELP="HELP: ${CMD}: Download grav core packages depending from some entered arguments. (See NOTE, INFO and ARGS)"

   if [ ${_ARGC} -lt 2 ]; then 
      libgrav::usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}" \
         "${_GRAV_ARG3}"
   fi

   if  [ "${_GRAV_CORE}" == "dev" ]; then
      # Check if essential configuration settings are done
      if [[ ! -f "${CFG_DIR}"/.config.dev ]] || [[ ! -n $(cat "${CFG_DIR}"/.config.dev | tr -d '"' | cut -d'=' -f2) ]]; then libgrav::error 2 "FAIL: Core development package not provided. Please run ${BIN_DIR}/grav-setcore.sh first..."; fi
   fi

   if  [ "${_GRAV_CORE}" == "prod" ]; then
      # Check if essential configuration settings are done
      if [[ ! -f "${CFG_DIR}"/.config.prod ]] || [[ ! -n $(cat "${CFG_DIR}"/.config.prod | tr -d '"' | cut -d'=' -f2) ]]; then libgrav::error 2 "FAIL: Core production package not provided. Please run ${BIN_DIR}/grav-setcore.sh first..."; fi
   fi

   libgrav_get::get_core \
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
