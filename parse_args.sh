#!/bin/sh

set -e

log() { printf '%s\n' "$*"; }
error() { log "ERROR: $*" >&2; }
usage_fatal() { echo 'usage_fatal: '$arg > /dev/tty; error "$*"; exit 1; }

function parse_args() {
     echo 'parsing parameters: '"$1" > /dev/tty
  
     while [[ "$#" -gt 0  ]]; do
         arg=$1
         case $1 in
             --*'='*) shift; set -- "${arg%%=*}" "${arg#*=}" "$@"; continue;;
             -*'='*) shift; set -- "${arg%%=*}" "${arg#*=}" "$@"; continue;;
             --*) arg_name="${arg#--}"; shift; eval ${arg_name}=$1; echo "${arg_name}=$(eval "echo $"$(echo ${arg_name}))";;
             -*) arg_name="${arg#-}"; shift; eval ${arg_name}=$1; echo "${arg_name}=$(eval "echo $"$(echo ${arg_name}))";;
             *) usage_fatal "Unrecognized argument: ${arg}. Did you missed a flag sign? (-/--)"; break;;
         esac
         shift || usage_fatal "option '${arg}' requires a value"
     done     
   
    echo "done parsing parameters."
}

parse_args "$@"
