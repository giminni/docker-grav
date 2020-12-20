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

if [[ ! -e "${HOME_DIR}/.context" ]]; then echo -e "\nError: Context is not initialized! Please run '<PROJECT_HOME>/bin/grav-mkinit.sh init' first... "; exit 1; fi

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
source "${LIB_DIR}"/libgrav_docker

# ##### #
# FUNCS #
# ##### #
function main() {
   # Initialize context
   libgrav::init

   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0

   local _GRAV_USER="${_ARGV[1]-""}"
   local _GRAV_NAME="${_ARGV[2]:-"grav-admin"}"
   local _GRAV_TAG="${_ARGV[3]:-"latest"}"
   local _GRAV_DATA="${_ARGV[4]:-"data"}"
   
   local _GRAV_TEXT="Error: Arguments are not provided!"
   local _GRAV_ARGS=" Args: ${CMD} user-name [img-name] [tag-name] [vol-data]"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1:  user-name: any|(#) - (#=grav)"
   local _GRAV_ARG2=" Arg2: [img-name]: any|(*) - (*=grav-admin)"
   local _GRAV_ARG3=" Arg3: [tag-name]: any|(*) - (*=latest)"
   local _GRAV_ARG4=" Arg4: [vol-data]: any|(*) - (*=data)"
   local _GRAV_INFO=" Info: ${CMD} grav grav-admin latest data"
   local _GRAV_HELP=" Help: ${CMD}: Instantiate a docker container depending from some entered arguments. (See Note, Info and Args)"

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

   # Check if essential configuration files exists
   if [[ ! -f "${CFG_DIR}"/.config.pass ]] || [[ ! -f $(cat "${CFG_DIR}"/.config.pass | tr -d '"' | cut -d'=' -f2) ]]; then libgrav::error 2 "Error: User and password not provided. Please run '${BIN_DIR}'/grav-mkpass.sh first...";
      elif [[ ! -f "${CFG_DIR}"/.config.ssh ]] || [[ ! -f $(cat "${CFG_DIR}"/.config.ssh | tr -d '"' | cut -d'=' -f2) ]]; then libgrav::error 2 "Error: SSH files not provided. Please run '${BIN_DIR}'/grav-mkssh.sh first...";
      elif [[ ! -f "${CFG_DIR}"/.config.data ]] || [[ ! -d $(cat "${CFG_DIR}"/.config.data | tr -d '"' | cut -d'=' -f2) ]]; then libgrav::error 2 "Error: Data volume not provided. Please run '${BIN_DIR}'/grav-mkdata.sh first...";
   fi

   libgrav_docker::run \
      "${_GRAV_USER}" \
      "${_GRAV_NAME}" \
      "${_GRAV_TAG}" \
      "${_GRAV_DATA}"

   _RC=$?

   if [ ${_RC} -eq 125 ]; then
      # usage 3 "Error: Docker image does not exists! Execute grav-build.sh first..."
      "${BIN_DIR}"/grav-build.sh "${_GRAV_USER}" "${_GRAV_NAME}" "${_GRAV_TAG}"
      "${0}" "${_GRAV_USER}" "${_GRAV_NAME}" "${_GRAV_TAG}"
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
