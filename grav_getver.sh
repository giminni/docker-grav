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
source "${PWD}"/grav_libs/libgrav_get

# ##### #
# FUNCS #
# ##### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0
   local _CMD=$(basename ${0})

   local _GRAV_VER="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav"}"
   local _GRAV_KIND="${_ARGV[3]:-"core"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_version grav_kind"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:    grav_version: prod|dev|X.Y.Z     - (#=prod)"
   local _GRAV_ARG2="ARG2:  [grav_imgname]: grav-admin|grav    - (*=grav-admin)"
   local _GRAV_ARG3="ARG3: [grav_kindname]: core|grav-skeleton - (*=core)"
   local _GRAV_INFO="INFO: ${_CMD} prod grav-admin"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}"; fi
   
   getver "${_GRAV_VER}" "${_GRAV_NAME}" "${_GRAV_KIND}"

   _RC=$?
   
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
