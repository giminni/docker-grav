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
source "${LIB_DIR}"/libgrav_docker

# ##### #
# FUNCS #
# ##### #
function main() {
   # Initialize context
   libgrav_common::init

   local _ARGC=${1}
   local _ARGV=("${@}")

   local _RC=0

   # Get Grav version strings from context files
   local _GRAV_DEV=""
   local _GRAV_PROD=""

   # Enter latest or testing
   local _GRAV_USER="${_ARGV[1]-""}"
   local _GRAV_NAME="${_ARGV[2]:-"grav-admin"}"
   local _GRAV_TAG="${_ARGV[3]:-"latest"}"
   local _GRAV_PASS="${_ARGV[4]:-"${KEY_DIR}/grav_pass.key"}"
   local _GRAV_PRIV="${_ARGV[5]:-"${KEY_DIR}/grav_rsa"}"
   local _GRAV_PUB="${_ARGV[6]:-"${KEY_DIR}/grav_rsa.pub"}"
   local _GRAV_OS="$(libgrav_common::os_type)"
   local _GRAV_ARCH="$(libgrav_common::machine_arch)"
   local _GRAV_FILE="Dockerfile"
   local _GRAV_KIND="core"
   local _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_TAG}.zip"
   local _GRAV_URL="https://getgrav.org/download/${_GRAV_KIND}/${_GRAV_NAME}"

   local _GRAV_TEXT="Error: Arguments are not provided!"
   local _GRAV_ARGS=" Args: ${CMD} user-name [img-name] [tag-name] [pass-file] [priv-file] [pub-file]"
   local _GRAV_NOTE=" Note: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1=" Arg1:   user-name: any|(#)         - (#=grav)"
   local _GRAV_ARG2=" Arg2:  [img-name]: grav|grav-admin - (*=grav)"
   local _GRAV_ARG3=" Arg3:  [tag-name]: latest|testing  - (*=latest)"
   local _GRAV_ARG4=" Arg4: [pass-file]: any|(*)         - (*=<PROJECT_HOME>/key/grav_pass.key)"
   local _GRAV_ARG5=" Arg5: [priv-file]: any|(*)         - (*=<PROJECT_HOME>/key/grav_rsa)"
   local _GRAV_ARG6=" Arg6:  [pub-file]: any|(*)         - (*=<PROJECT_HOME>/key/grav_rsa.pub)"
   local _GRAV_INFO=" Info: ${CMD} grav grav latest ${KEY_DIR}/grav_pass.key ${KEY_DIR}/grav_rsa ${KEY_DIR}/grav_rsa.pub"
   local _GRAV_HELP=" Help: ${CMD}: Builds the docker file from some entered arguments. (See Note, Info and Args)"

   if [ ${_ARGC} -lt 1 ]; then 
      libgrav_common::usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}" \
         "${_GRAV_ARG3}" \
         "${_GRAV_ARG4}" \
         "${_GRAV_ARG5}" \
         "${_GRAV_ARG6}"
   fi

   # Check if essential configuration settings are done
   if [[ ! -f "${CFG_DIR}"/.config.pass ]] || [[ ! -f $(cat "${CFG_DIR}"/.config.pass | tr -d '"' | cut -d'=' -f2) ]]; then libgrav_common::error 2 "Error: User and password not provided.\nPlease run ${BIN_DIR}/grav-mkpass.sh first..." "${NAME}";
      elif [[ ! -f "${CFG_DIR}"/.config.ssh ]] || [[ ! -f $(cat "${CFG_DIR}"/.config.ssh | tr -d '"' | cut -d'=' -f2) ]]; then libgrav_common::error 2 "Error: SSH files not provided.\nPlease run ${BIN_DIR}/grav-mkssh.sh first..." "${NAME}";
      elif [[ ! -f "${CFG_DIR}"/.config.cache ]] || [[ ! -d $(cat "${CFG_DIR}"/.config.cache | tr -d '"' | cut -d'=' -f2) ]]; then libgrav_common::error 2 "Error: Cache directory not provided.\nPlease run ${BIN_DIR}/grav-mkcache.sh first..." "${NAME}";
   fi

   # Define URLs using the predefined version string from above
   # Check if version string is set for development
   if [ "${_GRAV_TAG}" == "testing" ]; then
      if [[ ! -z "$(cat ${CFG_DIR}/.config.dev)" ]]; then _GRAV_DEV="$(cat ${CFG_DIR}/.config.dev | tr -d '"' | cut -d'=' -f2)"; fi
      if [[ ! -f "${CFG_DIR}"/.config.dev ]] || [[ ! -n $(cat "${CFG_DIR}"/.config.dev | tr -d '"' | cut -d'=' -f2) ]]; then libgrav_common::error 2 "Error: Grav dev version not provided!\nPlease run ${BIN_DIR}/grav-core.sh set first..." "${NAME}"; fi

      _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_DEV}?${_GRAV_TAG}.zip"
      _GRAV_URL="${_GRAV_URL}"/"${_GRAV_DEV}"?"${_GRAV_TAG}"
   elif [ "${_GRAV_TAG}" == "latest" ]; then
      if [[ ! -z "$(cat ${CFG_DIR}/.config.prod)" ]]; then _GRAV_PROD="$(cat ${CFG_DIR}/.config.prod | tr -d '"' | cut -d'=' -f2)"; fi
      if [[ ! -f "${CFG_DIR}"/.config.prod ]] || [[ ! -n $(cat "${CFG_DIR}"/.config.prod | tr -d '"' | cut -d'=' -f2) ]]; then libgrav_common::error 2 "Error: Grav prod version not provided!\nPlease run ${BIN_DIR}/grav-core.sh set first..." "${NAME}"; fi

      _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_PROD}.zip"
      _GRAV_URL="${_GRAV_URL}"/"${_GRAV_PROD}"
   fi

   libgrav_docker::build \
      "${_GRAV_USER}" \
      "${_GRAV_NAME}" \
      "${_GRAV_TAG}" \
      "${_GRAV_PASS}" \
      "${_GRAV_PRIV}" \
      "${_GRAV_PUB}" \
      "${_GRAV_OS}" \
      "${_GRAV_ARCH}" \
      "${_GRAV_FILE}" \
      "${_GRAV_KIND}" \
      "${_GRAV_URLFILE}" \
      "${_GRAV_URL}"

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
