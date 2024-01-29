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

echo 'About to convert to bed files'
mkdir -p ${target_path}/raw/impute2/bed || echo ""
for a in "${chrs_range[@]}"; do
    plink --gen ${target_path}/raw/impute2/chrs/chr${a}.impute2 \
    --sample ${datasets_path}${target}/original/raw/phased/chr${a}.phased.sample \
    --oxford-single-chr ${a} --make-bed --threads 50 --out ${target_path}/raw/impute2/bed/ds${a};
    echo "Finished converting chr${a} it bed file"
done
