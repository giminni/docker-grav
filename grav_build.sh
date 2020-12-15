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
source ${PWD}/libgrav

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")

   local _RC=0
   local _CMD=$(basename ${0})

   # Enter latest or testing
   local _GRAV_USER="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav-admin"}"
   local _GRAV_TAG="${_ARGV[3]:-"latest"}"
   local _GRAV_PASS="${_ARGV[4]:-"${PWD}/grav_pass.key"}"
   local _GRAV_PRIV="${_ARGV[5]:-"${PWD}/grav_rsa"}"
   local _GRAV_PUB="${_ARGV[6]:-"${PWD}/grav_rsa.pub"}"
   local _GRAV_DIST=".buster"
   local _GRAV_ARCH=".amd64"
   local _GRAV_FILE="Dockerfile${_GRAV_DIST}${_GRAV_ARCH}"
   local _GRAV_VER=="latest"
   local _GRAV_KIND="core"
   local _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_TAG}.zip"
   local _GRAV_URL="https://getgrav.org/download/${_GRAV_KIND}/${_GRAV_NAME}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_kind [grav_user] [grav_imgname] [grav_tagname] [grav_passfile] [grav_privfile] [grav_pubfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     [grav_user]: any|(#)         - (#=grav)"
   local _GRAV_ARG2="ARG2:  [grav_imgname]: grav-admin|grav - (*=grav-admin)"
   local _GRAV_ARG3="ARG3:  [grav_tagname]: latest|testing  - (*=latest)"
   local _GRAV_ARG4="ARG4: [grav_passfile]: any|(*)         - (*=<current-dir>/grav_pass.key)"
   local _GRAV_ARG5="ARG5: [grav_privfile]: any|(*)         - (*=<current-dir>/grav_rsa)"
   local _GRAV_ARG6="ARG6:  [grav_pubfile]: any|(*)         - (*=<current-dir>/grav_rsa.pub)"
   local _GRAV_INFO="INFO: ${_CMD} grav grav-admin latest ${PWD}/grav_pass.key ${PWD}/grav_rsa ${PWD}/grav_rsa.pub"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}" "${_GRAV_ARG5}" "${_GRAV_ARG6}"; fi

   if [ ! -f ${PWD}/.context.pass ] || [ ! -f $(cat ${PWD}/.context.pass | cut -d'=' -f2) ]; then usage 2 "FAIL: User and password not provided! Please run grav_mkpass.sh first...";
      elif [ ! -f ${PWD}/.context.ssh ] || [ ! -f $(cat ${PWD}/.context.ssh | cut -d'=' -f2) ]; then usage 2 "FAIL: SSH files not provided! Please run grav_mkssh.sh first...";
      elif [ ! -f ${PWD}/.context.cache ] || [ ! -d $(cat ${PWD}/.context.cache | cut -d'=' -f2) ]; then usage 2 "FAIL: Cache directory not provided! Please run grav_mkcache.sh first...";
   fi

   # Define core or skeleton package for download
   if [ "${_GRAV_NAME:0:13}" == "grav-skeleton" ]; then _GRAV_KIND="skeleton"; fi

   # If a ? char exists remove it and resave variables
   if [[ "${_GRAV_TAG}" =~ "?" ]]; then
      _GRAV_VER="$(echo ${_GRAV_TAG} | cut -d'?' -f2)"
      _GRAV_TAG="$(echo ${_GRAV_TAG} | cut -d'?' -f1)"
      _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_TAG}?${_GRAV_VER}.zip"
      _GRAV_URL="${_GRAV_URL}"/"${_GRAV_TAG}"?"${_GRAV_VER}"
   else
      _GRAV_URLFILE="${_GRAV_NAME}-${_GRAV_TAG}.zip"
      _GRAV_URL="${_GRAV_URL}"/"${_GRAV_TAG}"
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
      "${_GRAV_VER}" \
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
