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
   local _GRAV_VOL="${_ARGV[4]:-"grav_data"}"
   
   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_user [grav_imgname=grav] [grav_imgtag=latest] [grav_volname=grav_data]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:      grav_user: any|(*) - (*=current-user,#=grav)"
   local _GRAV_ARG2="ARG2: [grav_imgname|: any|(*) - (*=grav)"
   local _GRAV_ARG3="ARG3:  [grav_imgtag|: any|(*) - (*=latest)"
   local _GRAV_ARG4="ARG4: [grav_volname]: any|(*) - (*=grav_data)"
   local _GRAV_INFO="INFO: ${_CMD} grav grav latest grav_data"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}" "${_GRAV_ARG3}" "${_GRAV_ARG4}"; fi

   # Check if keys and volume are available
   if [ ! -f ${PWD}/.context.secs ]; then usage 2 "FAIL: User and password not provided! Please run grav_mkpwd.sh first.";
      elif [ ! -f ${PWD}/.context.ssh ]; then usage 2 "FAIL: SSH files not provided! Please run grav_mkssh.sh first.";
      elif [ ! -f ${PWD}/.context.vol ]; then usage 2 "FAIL: Data volume not provided! Please run grav_dovol.sh first."; 
   fi

   run "${_GRAV_USER}" "${_GRAV_NAME}" "${_GRAV_TAG}" "${_GRAV_VOL}"

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
