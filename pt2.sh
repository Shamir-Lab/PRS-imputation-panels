#!/bin/bash

source constants_.sh
source parse_args.sh "$@"


if [[ -z ${__init_args_pt__} ]]; then
    source init_args_pt.sh
fi

if [[ ! -f ${imp_train_path}${ds_prefix}${train_suffix}.bim ]]; then
    echo "${imp_train_path}". Skipping...
    exit 0
fi


if [[ ${stage} -le 1 ]]; then
    if [[ ! -f ${imp_train_path}/ds.dupvar ]]; then
        touch ${imp_train_path}/ds.dupvar
    fi
    echo clumping
    plink \
    	--bfile ${imp_train_path}${ds_prefix}${train_suffix} \
      --clump-p1 1 \
      --clump-p2 1 \
      --clump-r2 0.2 \
      --clump-kb 500 \
      --clump ${discovery_path}gwas.QC.Transformed \
      --clump-snp-field SNP \
      --clump-field P \
      --out ${prs_path}${prs_prefix}${sub}${train_suffix} \
      --memory ${memory} \
      --threads ${threads} \
      --exclude ${imp_train_path}ds.dupvar
fi

if [[ ${stage} -le 1 ]]; then
    echo filter by clumping
    awk 'NR!=1{print $3}' ${prs_path}${prs_prefix}${sub}${train_suffix}.clumped >  ${prs_path}${prs_prefix}${sub}${train_suffix}.valid.snp
fi

if [[ ${stage} -le 2 ]]; then

    echo pvalue inclusion criteria
    echo "0.00000005 0 0.00000005" >> ${prs_path}range_list
    echo "0.0000001 0 0.0000001" >> ${prs_path}range_list
    echo "0.000001 0 0.000001" >> ${prs_path}range_list
    echo "0.00001 0 0.00001" >> ${prs_path}range_list
    echo "0.0001 0 0.0001" >> ${prs_path}range_list
    echo "0.001 0 0.001" >> ${prs_path}range_list
    echo "0.005 0 0.005" >> ${prs_path}range_list
    echo "0.01 0 0.01" >> ${prs_path}range_list
    echo "0.05 0 0.05" >> ${prs_path}range_list
    echo "0.1 0 0.1" >> ${prs_path}range_list
    echo "0.2 0 0.2" >> ${prs_path}range_list
    echo "0.3 0 0.3" >> ${prs_path}range_list
    echo "0.4 0 0.4" >> ${prs_path}range_list
    echo "0.5 0 0.5" >> ${prs_path}range_list
    echo "1.0 0 1.0" >> ${prs_path}range_list

    echo calculate PRS
    plink \
    	--bfile ${imp_test_path}${ds_prefix}${sub}${test_suffix} \
    	--score ${discovery_path}gwas.QC.Transformed 1 4 11 header \
    	--q-score-range ${prs_path}range_list ${discovery_path}SNP.pvalue \
    	--extract ${prs_path}${prs_prefix}${sub}${train_suffix}.valid.snp \
    	--memory ${memory} \
    	--threads ${threads} \
    	--out ${prs_path}${prs_prefix}${sub}${test_suffix}
fi
