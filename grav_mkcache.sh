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
source ${PWD}/libs/libgrav
source ${PWD}/libs/libgrav_mk

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")

   local _RC=0
   local _CMD=$(basename ${0})

   local _GRAV_NAME="${_ARGV[1]}"
   local _GRAV_CACHE="${_ARGV[2]:-"${PWD}/.volumes/${_GRAV_NAME}"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_cachename [grav_cachefile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1: [grav_cachename]: any|(#) - (#=grav_cache)"
   local _GRAV_ARG2="ARG2: [grav_cachefile]: any|(*) - (*=<current-dir>/.volumes/<grav_cachename>)"
   local _GRAV_INFO="INFO: ${_CMD} grav_cache ${PWD}/.volumes/grav_cache"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}"; fi

   mkcache "${_GRAV_NAME}" "${_GRAV_CACHE}" <<< ""$'\n'"y" 2>&1 >/dev/null
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
