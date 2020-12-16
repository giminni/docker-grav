#!/usr/bin/env bash
# #### #
# INIT #
# #### #
set -e

if [ "$(set | grep xtrace)" -o ${DEBUG:-0} -ne 0 ]; then DEBUG=1; set -x; else DEBUG=0; set +x; fi

CMD="$(basename ${0})"
NAME=$(echo ${CMD} | cut -d'.' -f1)
CUR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${CUR_DIR%/*}"
# Remove enclosing double quotes
CTX_DIR="$(cat ${HOME_DIR}/.context | tr -d '"' | cut -d'=' -f2)"
LIB_DIR="$(cat ${CTX_DIR}/.config.lib | tr -d '"' | cut -d'=' -f2)"

# #### #
# VARS #
# #### #
ARGC=$#
ARGV=("$@")
RC=0

# #### #
# LIBS #
# #### #
source "${LIB_DIR}"/libgrav
source "${LIB_DIR}"/libgrav_mk

# ##### #
# FUNCS #
# ##### #
main() {
   # Initialize context
   init

   local _ARGC=${1}
   local _ARGV=("${@}")

   local _RC=0

   local _GRAV_NAME="${_ARGV[1]}"
   local _GRAV_CACHE="${_ARGV[2]:-"${CACHE_DIR}/${_GRAV_NAME}"}"

   local _GRAV_TEXT="FAIL: Arguments are not provided!"
   local _GRAV_ARGS="ARGS: ${CMD} grav_cachename [grav_cachefile]"
   local _GRAV_NOTE="NOTE: (*) are default values, (#) are recommended values"
   local _GRAV_ARG1="ARG1:   grav_cachename: any|(#) - (#=grav_cache)"
   local _GRAV_ARG2="ARG2: [grav_cachefile]: any|(*) - (*=${CACHE_DIR}/<grav_cachename>)"
   local _GRAV_INFO="INFO: ${CMD} grav_cache ${CACHE_DIR}"
   local _GRAV_HELP="HELP: ${CMD}: Create the required cache directory depending from some entered arguments. (See NOTE, INFO and ARGS)"

   if [ ${_ARGC} -lt 1 ]; then 
      usage 1 \
         "${_GRAV_TEXT}" \
         "${_GRAV_ARGS}" \
         "${_GRAV_NOTE}" \
         "${_GRAV_INFO}" \
         "${_GRAV_HELP}" \
         "${_GRAV_ARG1}" \
         "${_GRAV_ARG2}"
   fi

   mkcache \
      "${_GRAV_NAME}" \
      "${_GRAV_CACHE}"

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
