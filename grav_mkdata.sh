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

   local _GRAV_NAME="${_ARGV[1]}"
   local _GRAV_DATA="${_ARGV[2]:-"${PWD}/.volumes/${_GRAV_NAME}"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_volname [grav_voldata]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1: [grav_volname]: any|(#) - (#=grav_data)"
   local _GRAV_ARG2="ARG2: [grav_voldata]: any|(*) - (*=<current-dir>/.volumes/<grav_volname>)"
   local _GRAV_INFO="INFO: ${_CMD} grav_data ${PWD}/.volumes/grav_data"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}"; fi

   mkdata "${_GRAV_NAME}" "${_GRAV_DATA}" <<< ""$'\n'"y" 2>&1 >/dev/null
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