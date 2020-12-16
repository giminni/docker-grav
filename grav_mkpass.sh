#!/usr/bin/env bash
# #### #
# INIT #
# #### #
set -e

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

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
source "${PWD}"/grav_libs/libgrav_mk

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0
   local _GRAV_CMD=$(basename ${0})

   local _GRAV_SECS="${_ARGV[1]}"
   local _GRAV_USER="${_ARGV[2]:-$(id -un)}"
   local _GRAV_PASS="${_ARGV[3]:-"${PWD}/grav_keys/grav_pass.key"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_GRAV_CMD} grav_pass [grav_user] [grav_passfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     grav_pass: any|(#) - (#=minimum 12 chars length)"
   local _GRAV_ARG2="ARG2:     grav_user: any|(*) - (*=<current-user>,#=grav)"
   local _GRAV_ARG3="ARG3: grav_passfile: any|(*) - (*=<current-dir>/grav_keys/grav_pass.key]"
   local _GRAV_INFO="INFO: ${_GRAV_CMD} my-secret-pass grav ${PWD}/grav_keys/grav_pass.key"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}"; fi

   mkpass "${_GRAV_SECS}" "${_GRAV_USER}" "${_GRAV_PASS}"

   echo "GRAV_USER=${_GRAV_USER}" > ${PWD}/.context.user
   echo "GRAV_PASS=${_GRAV_PASS}" > ${PWD}/.context.pass
   
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
