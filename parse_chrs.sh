#!/bin/bash

function parse_chrs() {
     
     echo 'parsing '$1 > /dev/tty
     
     if [[ $1 == *'-'* ]]; then     
        chrs_range=(${1//-/ })
        chrs_range=($(seq ${chrs_range[0]} ${chrs_range[1]})) 
     else
        chrs_range=(${1//,/ })
     
     fi
 
     declare -p chrs_range

}
