#!/usr/bin/env bash
# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

# #### #
# LIBS #
# #### #
source "${PWD}"/grav_libs/libgrav
source "${PWD}"/grav_libs/libgrav_docker

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")

   local _RC=0
   local _CMD=$(basename ${0})

   # Get Grav version strings from context files
   local _GRAV_DEV="$(cat ${PWD}/.context.dev | cut -d'=' -f2)"
   local _GRAV_PROD="$(cat ${PWD}/.context.prod | cut -d'=' -f2)"

   # Enter latest or testing
   local _GRAV_USER="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav-admin"}"
   local _GRAV_TAG="${_ARGV[3]:-"latest"}"
   local _GRAV_PASS="${_ARGV[4]:-"${PWD}/grav_keys/grav_pass.key"}"
   local _GRAV_PRIV="${_ARGV[5]:-"${PWD}/grav_keys/grav_rsa"}"
   local _GRAV_PUB="${_ARGV[6]:-"${PWD}/grav_keys/grav_rsa.pub"}"
   local _GRAV_DIST=".buster"
   local _GRAV_ARCH=".amd64"
   local _GRAV_FILE="Dockerfile"
   local _GRAV_KIND="core"
   local _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_TAG}.zip"
   local _GRAV_URL="https://getgrav.org/download/${_GRAV_KIND}/${_GRAV_NAME}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_user [grav_imgname] [grav_tagname] [grav_passfile] [grav_privfile] [grav_pubfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     [grav_user]: any|(#)         - (#=grav)"
   local _GRAV_ARG2="ARG2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)"
   local _GRAV_ARG3="ARG3:  [grav_tagname]: latest|testing  - (*=latest)"
   local _GRAV_ARG4="ARG4: [grav_passfile]: any|(*)         - (*=<current-dir>/grav_keys/grav_pass.key)"
   local _GRAV_ARG5="ARG5: [grav_privfile]: any|(*)         - (*=<current-dir>/grav_keys/grav_rsa)"
   local _GRAV_ARG6="ARG6:  [grav_pubfile]: any|(*)         - (*=<current-dir>/grav_keys/grav_rsa.pub)"
   local _GRAV_INFO="INFO: ${_CMD} grav grav-admin latest ${PWD}/grav_keys/grav_pass.key ${PWD}/grav_keys/grav_rsa ${PWD}/grav_keys/grav_rsa.pub"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}" "${_GRAV_ARG5}" "${_GRAV_ARG6}"; fi

   if [ ! -f ${PWD}/.context.pass ] || [ ! -f $(cat ${PWD}/.context.pass | cut -d'=' -f2) ]; then usage 2 "FAIL: User and password not provided! Please run grav_mkpass.sh first...";
      elif [ ! -f ${PWD}/.context.ssh ] || [ ! -f $(cat ${PWD}/.context.ssh | cut -d'=' -f2) ]; then usage 2 "FAIL: SSH files not provided! Please run grav_mkssh.sh first...";
      elif [ ! -f ${PWD}/.context.cache ] || [ ! -d $(cat ${PWD}/.context.cache | cut -d'=' -f2) ]; then usage 2 "FAIL: Cache directory not provided! Please run grav_mkcache.sh first...";
      elif [ ! -f ${PWD}/.context.dev ] || [ ! -n $(cat ${PWD}/.context.dev | cut -d'=' -f2) ]; then usage 2 "FAIL: Grav dev version not provided! Please run grav_getver.sh first...";
      elif [ ! -f ${PWD}/.context.prod ] || [ ! -n $(cat ${PWD}/.context.prod | cut -d'=' -f2) ]; then usage 2 "FAIL: Grav prod version not provided! Please run grav_getver.sh first...";
   fi

   # Define core or skeleton package for download
   if [ "${_GRAV_NAME:0:13}" == "grav-skeleton" ]; then _GRAV_KIND="skeleton"; fi

   # Define URLs using the predefined version string from above
   if [ "${_GRAV_TAG}" == "testing" ]; then
      _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_DEV}?${_GRAV_TAG}.zip"
      _GRAV_URL="${_GRAV_URL}"/"${_GRAV_DEV}"?"${_GRAV_TAG}"
   elif [ "${_GRAV_TAG}" == "latest" ]; then
      _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_PROD}.zip"
      _GRAV_URL="${_GRAV_URL}"/"${_GRAV_PROD}"
   fi

   build \
      "${_GRAV_USER}" \
      "${_GRAV_NAME}" \
      "${_GRAV_TAG}" \
      "${_GRAV_PASS}" \
      "${_GRAV_PRIV}" \
      "${_GRAV_PUB}" \
      "${_GRAV_DIST}" \
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
