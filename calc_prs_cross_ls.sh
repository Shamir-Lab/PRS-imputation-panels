#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

source init_args_cross.sh

method="ls"

prs_prefix="prs.cross.${method}${sub}"
ds_prefix="ds${sub}"

mkdir -p ${prs_path}lasso ||  true

if [[ ${stage} -le 1 ]]; then
    	    Rscript lassosum.R --discovery=${discovery} \
    	    --target_train=${target_train} --imp_train=${imp_train} \
    	    --target_test=${target_test} --imp_test=${imp_test} \
    	    --suffix=${suffix} --rep=${rep} --analysis_type="cross";
fi

if [[ ${stage} -le 2 ]]; then
    if [[ ${hp} == "" ]]; then
        hp="0.2,0.5,0.9,1"
    fi
    hp_arr=(${hp//,/ })

    for cur_hp in ${hp_arr[@]}; do

        for hp2 in {1..20}; do # {1..20}

            plink --bfile ${imp_test_path}${ds_prefix}${test_suffix}  \
                  --score ${prs_path}lasso/${prs_prefix}${train_suffix}.${cur_hp}-${hp2}.weights 2 4 6 \
                  --exclude ${imp_test_path}ds.dupvar \
                  --out ${prs_path}${prs_prefix}${test_suffix}.${cur_hp}-${hp2}
        done
    done
fi

if [[ ${stage} -le 3 ]]; then
     	    Rscript calc_metrics_cross_${method}.R --discovery=${discovery} \
    	    --target_train=${target_train} --imp_train=${imp_train} \
    	    --target_test=${target_test} --imp_test=${imp_test} \
    	    --suffix=${suffix} --rep=${rep} --analysis_type="cross";

fi
