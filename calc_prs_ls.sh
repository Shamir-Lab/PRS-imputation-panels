#!/bin/bash

source constants_.sh
source parse_args.sh "$@"
source init_args_prs.sh

prs_prefix="prs.mono.ls${sub}"
ds_prefix="ds${sub}"

echo "Start pipeline"
mkdir -p $prs_path || echo ""
mkdir -p ${prs_path}lasso || true

if [[ ${stage} -le 1 ]]; then
    	    Rscript lassosum.R --discovery=${discovery} --target=${target} --imp=${imp} --analysis_type="mono";
fi


if [[ ${stage} -le 2 ]]; then
    if [[ ${hp} == "" ]]; then
        hp="0.2,0.5,0.9,1"
    fi
    hp_arr=(${hp//,/ })
    for cur_hp in "${hp_arr[@]}"; do
        for hp2 in {1..20}; do
            if [[ ! -f ${prs_path}${prs_prefix}${test_suffix}.${cur_hp}-${hp2}.profile || ${override} = "true" ]]; then
                plink --bfile ${imp_test_path}${ds_prefix}${test_suffix}  \
                      --score ${prs_path}lasso/${prs_prefix}${train_suffix}.${cur_hp}-${hp2}.weights 2 4 6 \
                      --exclude ${imp_test_path}ds.dupvar \
                      --memory 20000 \
                      --threads 5 \
                      --out ${prs_path}${prs_prefix}${test_suffix}.${cur_hp}-${hp2}
                fi
        done
    done
fi

if [[ ${stage} -le 3 ]]; then
     	    Rscript calc_metrics_ls.R --discovery=${discovery} --target=${target} --imp=${imp}  --sub=${sub} --analysis_type="mono";
            # Rscript calc_metrics_ls.R --discovery=${discovery} \
            # --target_train=${target_train} --imp_train=${imp_train} \
            # --target_test=${target_test} --imp_test=${imp_test} \
            # --sub=${pheno_suffix} --analysis_type="mono";

fi

