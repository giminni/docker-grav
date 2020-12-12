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

# #### #
# MAIN #
# #### #
main() {
   local _ARGC=${1}
   local _ARGV=("${@}")
   
   local _RC=0
   local _CMD=$(basename ${0})

   local _GRAV_SHELL="${_ARGV[1]:-"bash"}"
   local _GRAV_NAME="${_ARGV[2]:-"grav"}"
   
   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${0} grav_shell [grav_imgname]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:     grav_shell: sh|ash|bash - (#=bash)"
   local _GRAV_ARG2="ARG2: [grav_imgname]: any|(*)     - (*=grav)"
   local _GRAV_INFO="INFO: ${_CMD} bash grav"
 
   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}"; fi

   shell "${_GRAV_NAME}" "${_GRAV_SHELL}"

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
