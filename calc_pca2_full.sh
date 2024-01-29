#!/bin/bash
set -e
source constants_.sh
source parse_args.sh "$@"

# Parse input
target_dataset="${datasets_path}${target}/${imp}/"

if [[ -z ${maf} ]]; then maf=0.05; fi
if [[ -z ${geno} ]]; then geno=0.1; fi
if [[ -z ${imp} ]]; then imp="original"; fi
if [[ -z ${memory} ]]; then memory=500000; fi
if [[ -z ${threads} ]]; then threads=80; fi
if [[ -z ${stage} ]]; then stage=3; fi

# Start pipeline
if [[ ${stage} -le 1 ]]; then
	echo '### QC ###'
	plink \
		--bfile ${target_dataset}ds \
		--out ${target_dataset}ds.QC \
		--memory ${memory} \
		--threads ${threads} \
		--maf ${maf} \
		--geno ${geno} \
		--hwe 1e-6 \
		--make-bed
fi
if [[ ${stage} -le 2 ]]; then
	echo '### perform prunning ###'
	plink \
		--bfile ${target_dataset}ds.QC \
		--out ${target_dataset}ds \
		--memory ${memory} \
		--threads ${threads} \
		--indep-pairwise 200 50 0.25
fi
if [[ ${stage} -le 3 ]]; then
	echo '### calc ref pca'
	plink2 \
		--bfile ${target_dataset}ds.QC \
		--out ${target_dataset}ds \
		--memory ${memory} \
		--threads ${threads} \
		--extract ${target_dataset}ds.prune.in \
                --make-rel \
		--pca allele-wts approx 6

fi

# if [[ ${stage} -le 4 ]]; then
#         echo  "calc target pca"
#         plink2 \
#                 --bfile ${target_dataset}ds.QC \
#                 --out ${target_dataset}ds.pca2 \
#                 --memory ${memory} \
#                 --threads ${threads} \
#                 --extract ${target_dataset}ds.prune.in \
#                 --geno 0.1 \
#                 --mind 0.1 \
#                 --read-freq ${target_dataset}ds.ref.acount \
#                 --score ${target_dataset}ds.ref.eigenvec.allele 2 5 header-read no-mean-imputation variance-standardize \
#                 --score-col-nums 6-11
# fi
# 
