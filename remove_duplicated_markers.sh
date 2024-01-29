#!/bin/bash
set -e
source parse_args.sh "$@"
source constants_.sh

# Parse input
target_dataset=${datasets_path}${target}'/'

# Run pipeline
plink --bfile ${target_dataset}ds --list-duplicate-vars --out ${target_dataset}ds 
plink --bfile ${target_dataset}ds --exclude ${target_dataset}ds.dupvar --recode vcf-iid --out ${target_dataset}ds
