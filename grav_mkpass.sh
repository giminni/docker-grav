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

   local _GRAV_SECS="${_ARGV[1]}"
   local _GRAV_USER="${_ARGV[2]:-$(id -un)}"
   local _GRAV_PASS="${_ARGV[3]:-"${PWD}/grav_pass.key"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_pass [grav_user] [grav_passfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     grav_pass: any|(#) - (#=minimum 12 chars length)"
   local _GRAV_ARG2="ARG2:     grav_user: any|(*) - (*=<current-user>,#=grav)"
   local _GRAV_ARG3="ARG3: grav_passfile: any|(*) - (*=<current-dir>/grav_pass.key]"
   local _GRAV_INFO="INFO: ${_CMD} my-secret-pass grav ${PWD}/grav_pass.key"

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