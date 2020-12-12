#!/usr/bin/env bash
# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

GRAV_DEV="1.7.0-rc.19"

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
   local _GRAV_KIND="${_ARGV[1]}"
   local _GRAV_USER="${_ARGV[2]:-$(id -un)}"
   local _GRAV_NAME="${_ARGV[3]:-"grav"}"
   local _GRAV_TAG="${_ARGV[4]:-"latest"}"
   local _GRAV_SECS="${_ARGV[5]:-"${PWD}/grav_pwd.key"}"
   local _GRAV_PRIV="${_ARGV[6]:-"${PWD}/grav_rsa"}"
   local _GRAV_PUB="${_ARGV[7]:-"${PWD}/grav_rsa.pub"}"
   local _GRAV_DIST=".buster"
   local _GRAV_ARCH=".amd64"
   local _GRAV_FILE="Dockerfile${_GRAV_DIST}${_GRAV_ARCH}"
   local _GRAV_VER="${_GRAV_KIND}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_kind [grav_user] [grav_imgname] [grav_tagname] [grav_pwdfile] [grav_privfile] [grav_pubfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:       grav_kind: latest|testing"
   local _GRAV_ARG2="ARG2:     [grav_user]: any|(*) - (*=current-user,#=grav)"
   local _GRAV_ARG3="ARG3:  [grav_imgname]: any|(*) - (*=grav)"
   local _GRAV_ARG4="ARG4:  [grav_tagname]: any|(*) - (*=latest)"
   local _GRAV_ARG5="ARG5:  [grav_pwdfile]: any|(*) - (*=${PWD}/grav_pwd.key)"
   local _GRAV_ARG6="ARG6: [grav_privfile]: any|(*) - (*=${PWD}/grav_rsa)"
   local _GRAV_ARG7="ARG7:  [grav_pubfile]: any|(*) - (*=${PWD}/grav_rsa.pub)"
   local _GRAV_INFO="INFO: ${_CMD} latest grav grav latest ${PWD}/grav_pwd.key ${PWD}/grav_rsa ${PWD}/grav_rsa.pub"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}" "${_GRAV_ARG5}"  "${_GRAV_ARG6}" "${_GRAV_ARG7}"; fi

   if [ ! -f ${PWD}/.context.secs ]; then usage 2 "FAIL: User and password not provided! Please run grav_mkpwd.sh first.";
      elif [ ! -f ${PWD}/.context.ssh ]; then usage 2 "FAIL: SSH files not provided! Please run grav_mkssh.sh first.";
   fi

   if [ "${_GRAV_KIND}" == "testing" ]; then _GRAV_VER="${GRAV_DEV}?${_GRAV_KIND}"; fi

   build "${_GRAV_KIND}" "${_GRAV_USER}" "${_GRAV_NAME}" "${_GRAV_TAG}" "${_GRAV_SECS}" "${_GRAV_PRIV}" "${_GRAV_PUB}" "${_GRAV_DIST}" "${_GRAV_ARCH}" "${_GRAV_FILE}" "${_GRAV_VER}"

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
