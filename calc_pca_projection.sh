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
if [[ -z ${stage} ]]; then stage=4; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [ ! ${pop} == "" ]; then
	pop=_${pop}
fi

if [[ -z ${cluster_names} ]]; then
	cluster_names=""
else
	if [[ ${cluster_names} -eq -1 ]]; then
    	cluster_names='EUR AFR EAS SAS AMR OCN1 OCN2'
    else
    	cluster_names=${cluster_names//,/ }
    fi
fi
if [[ -z ${n_samples} ]]; then
	n_samples=6
else
	if [[ ${n_samples} -eq -1 ]]; then
		n_samples="$(wc -l ${target_dataset}ds.fam | awk '{print $1}')"
	fi
	if [[ ${n} -ge 8000 ]]; then
		n_samples=8000
	fi
fi

discovery_path=${GWASs_path}${discovery}'/'
target_path=${datasets_path}${target}"/${imp}/"
prs_path=${PRSs_path}${discovery}_${target}"/${imp}/"


# Start pipeline
if [[ ${stage} -le 1 ]]; then
	echo '### QC ###'
	plink \
		--bfile ${target_path}ds \
		--out ${target_path}ds.QC \
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
		--bfile ${target_path}ds.QC \
		--out ${target_path}ds \
		--memory ${memory} \
		--threads ${threads} \
		--indep-pairwise 200 50 0.25
fi
if [[ ${stage} -le 3 ]]; then
	echo '### calculate the first 6 PCs ###'
	plink \
		--bfile ${target_path}ds.QC \
		--out ${target_path}ds \
		--extract ${target_path}ds.prune.in \
		--memory ${memory} \
		--threads ${threads} \
		--geno 0.1 \
		--mind 0.1 \
		--pca ${n_samples}  \
                --make-rel \
		--within ${datasets_path}${target}'/pop.panel' \
		--pca-cluster-names ${cluster_names}
fi
 
