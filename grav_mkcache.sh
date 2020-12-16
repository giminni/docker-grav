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

   local _GRAV_NAME="${_ARGV[1]}"
   local _GRAV_CACHE="${_ARGV[2]:-"${PWD}/${_GRAV_NAME}"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_GRAV_CMD} grav_cachename [grav_cachefile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1: [grav_cachename]: any|(#) - (#=grav_cache)"
   local _GRAV_ARG2="ARG2: [grav_cachefile]: any|(*) - (*=<current-dir>/<grav_cachename>)"
   local _GRAV_INFO="INFO: ${_GRAV_CMD} grav_cache ${PWD}/grav_cache"

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
