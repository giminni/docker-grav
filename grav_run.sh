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

   local _GRAV_USER="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav"}"
   local _GRAV_TAG="${_ARGV[3]:-"latest"}"
   local _GRAV_DATA="${_ARGV[4]:-"grav_data"}"
   
   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_user [grav_imgname=grav] [grav_imgtag=latest] [grav_voldata=grav_data]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:      grav_user: any|(*) - (*=<current-user>,#=grav)"
   local _GRAV_ARG2="ARG2: [grav_imgname|: any|(*) - (*=grav)"
   local _GRAV_ARG3="ARG3:  [grav_imgtag|: any|(*) - (*=latest)"
   local _GRAV_ARG4="ARG4: [grav_voldata]: any|(*) - (*=grav_data)"
   local _GRAV_INFO="INFO: ${_CMD} grav grav latest grav_data"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}"; fi

   # Check if keys and volumes are available
   if [ ! -f ${PWD}/.context.pass ] || [ ! -f $(cat ${PWD}/.context.pass | cut -d'=' -f2) ]; then usage 2 "FAIL: User and password not provided! Please run grav_mkpass.sh first...";
      elif [ ! -f ${PWD}/.context.ssh ] || [ ! -f $(cat ${PWD}/.context.ssh | cut -d'=' -f2) ]; then usage 2 "FAIL: SSH files not provided! Please run grav_mkssh.sh first...";
      elif [ ! -f ${PWD}/.context.data ] || [ ! -d $(cat ${PWD}/.context.data | cut -d'=' -f2) ]; then usage 2 "FAIL: Data volume not provided! Please run grav_mkdata.sh first...";
   fi

   run "${_GRAV_USER}" "${_GRAV_NAME}" "${_GRAV_TAG}" "${_GRAV_DATA}"

   _RC=$?

   if [ ${_RC} -eq 125 ]; then
#   	usage 3 "FAIL: Docker image does not exists! Execute grav-build.sh first..."
      ${PWD}/grav_build.sh testing grav
      $0 grav
   fi

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
