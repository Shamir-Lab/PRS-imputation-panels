#!/bin/bash
set -e 

source constants_.sh
source parse_args.sh "$@"

# Parse input
if [[ -z ${chr} ]]; then echo "Please specify chr index"; exit 1; fi
if [[ -z ${panel} ]]; then echo "Please specify panel"; exit 1; fi
if [[ -z ${thread} ]]; then thread=30; fi


# shapeit -convert \
# --input-haps ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.haps ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.sample \
# --output-haps ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/phased/chr${chr}.phased \
# --thread ${thread}

echo shapeit -convert \
--input-haps ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/phased/chr${chr}.phased \
--output-ref ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.hap ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.legend.gz ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.sample \
--thread ${thread}

shapeit -convert \
--input-haps ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/phased/chr${chr}.phased \
--output-ref ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.hap ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.legend.gz ${PRS_DATASETS}/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.sample \
--thread ${thread}





