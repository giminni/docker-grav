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
source "${LIB_DIR}"/libgrav_core

# ##### #
# FUNCS #
# ##### #
function main() {
   # Initialize context
   libgrav_common::init

   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_CMD="${_ARGV[1]-""}"
   local _GRAV_CORE="${_ARGV[2]-"prod"}"
   local _GRAV_NAME="${_ARGV[3]:-"grav"}"

   local _GRAV_TEXT="Error: Arguments are not provided!"
   local _GRAV_ARGS=" Args: ${CMD} core-cmd [core-ver] [img-name]"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1: core-cmd: set|get"
   local _GRAV_ARG2=" Arg2: [core-ver]: all|prod|dev|X.Y.Z|(*) - (*=prod)"
   local _GRAV_ARG3=" Arg3: [img-name]: grav-admin|grav|(*)    - (*=grav)"
   local _GRAV_INFO=" Info: ${CMD} set prod grav"
   local _GRAV_HELP=" Help: ${CMD}: Set or download grav core packages depending from some entered arguments. (See Note, Info and Args)"

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

   case "${_GRAV_CMD}" in
      "set")
         libgrav_core::set_core \
            "${_GRAV_CMD}" \
            "${_GRAV_CORE}" \
            "${_GRAV_NAME}"
      ;;

      "get")
         if  [ "${_GRAV_CORE}" == "dev" ]; then
            # Check if essential configuration settings are done
            if [[ ! -f "${CFG_DIR}"/.config.dev ]] || [[ ! -n $(cat "${CFG_DIR}"/.config.dev | tr -d '"' | cut -d'=' -f2) ]]; then 
               libgrav_common::error 2 "Error: Core development package not provided.\nPlease run ${BIN_DIR}/grav-core.sh set first..." "${NAME}";
            fi
         fi
         
         if  [ "${_GRAV_CORE}" == "prod" ]; then
            # Check if essential configuration settings are done
            if [[ ! -f "${CFG_DIR}"/.config.prod ]] || [[ ! -n $(cat "${CFG_DIR}"/.config.prod | tr -d '"' | cut -d'=' -f2) ]]; then 
               libgrav_common::error 2 "Error: Core production package not provided.\nPlease run ${BIN_DIR}/grav-core.sh set first..." "${NAME}"; 
            fi
         fi
         libgrav_core::get_core \
            "${_GRAV_CMD}" \
            "${_GRAV_CORE}" \
            "${_GRAV_NAME}"
      ;;

      *)
      ;;
   esac

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
