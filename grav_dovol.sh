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

   local _GRAV_CMD="${_ARGV[1]}"
   local _GRAV_NAME="${_ARGV[2]:-"grav_data"}"
   local _GRAV_VOL="${_ARGV[3]:-"${PWD}/.volumes/${_GRAV_NAME}"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${_CMD} grav_volcmd [grav_volname] [grav_volfile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:    grav_volcmd: mkvol|rmvol|mkccache|rmccache"
   local _GRAV_ARG2="ARG2: [grav_volname]: any|(*) - (*=grav_data)"
   local _GRAV_ARG3="ARG3: [grav_volfile]: any|(*) - (*=<current-dir>/.volumes/<grav_volname>)"
   local _GRAV_INFO="INFO: ${_CMD} mkvol grav_data ${PWD}/.volumes/${_GRAV_NAME}"

   if [ ${_ARGC} -lt 1 ]; then usage 1 "${_GRAV_TEXT}" "${_GRAV_ARGS}" "${_GRAV_NOTE}" "${_GRAV_INFO}" "${_GRAV_ARG1}" "${_GRAV_ARG2}"  "${_GRAV_ARG3}"; fi

   dovol "${_GRAV_CMD}" "${_GRAV_NAME}" "${_GRAV_VOL}" <<< ""$'\n'"y" 2>&1 >/dev/null
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
