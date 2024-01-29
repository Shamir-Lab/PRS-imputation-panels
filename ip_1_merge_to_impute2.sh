#!/bin/bash
set -e

source constants_.sh
source parse_args.sh "$@"
source parse_chrs.sh
eval $(parse_chrs $chrs)

if [[ -z ${imp} ]]; then echo "imp argument is missing!"; exit 1; fi
if [[ -z ${target} ]]; then echo "target argument is missing!"; exit 1; fi
if [[ -z ${threads} ]]; then threads=22; fi
if [[ -z ${chrs_range} ]]; then chrs_range=($(seq 1 22)); fi

target_path=${datasets_path}${target}"/${imp}/"

echo 'About to merge impute2 chrs'
pids=()
mkdir -p ${target_path}/raw/impute2/chrs || echo ""
for a in "${chrs_range[@]}"; do 
    echo "start chr${a}" 
    ( ( ls -1v ${target_path}raw/impute2/parts/chr${a}.*.legend | xargs cat > ${target_path}/raw/impute2/chrs/chr${a}.impute2 ) && echo "done merging chr${a}" ); 
    echo "finished merging chr${a} to impute2 file"
done;