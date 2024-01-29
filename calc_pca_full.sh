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
if [[ -z ${stage} ]]; then stage=2; fi

# Start pipeline
if [[ ${stage} -le 1 ]]; then
	echo '### QC ###'
	plink \
		--bfile ${target_dataset}ds \
		--keep "${datasets_path}${target}/pop.panel" \
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
	echo '### calculate the first 6 PCs ###'
	plink \
		--bfile ${target_dataset}ds.QC \
		--out ${target_dataset}ds \
		--memory ${memory} \
		--threads ${threads} \
		--extract ${target_dataset}ds.prune.in \
		--pca 200
fi
 
