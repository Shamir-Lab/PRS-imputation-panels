#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

source init_args_cv.sh

prs_prefix="prs.cv.ld__${pop}"
prs_prefix_adapter="prs.cv.ld_${pheno}_${pop}"
ds_prefix="ds__${pop}"

mkdir -p ${prs_path}ldpred || true

if [[ ! -f ${imp_train_path}${ds_prefix}${train_suffix}.bim ]]; then
    echo "${imp_train_path}${ds_prefix}${train_suffix}.bim" does not exists. Skipping...
    exit 0
fi

if [[ ${stage} -le 1 ]]; then
          echo "Rscript ldpred.R --discovery=${discovery} --target=${target} --imp=${imp} --train_suffix=${train_suffix} --test_suffix=${test_suffix} --rep=${rep} --analysis_type="cv";"
    	    ( Rscript ldpred.R --discovery=${discovery} --target=${target} --imp=${imp} \
    	                     --train_suffix=${train_suffix} --test_suffix=${test_suffix} \
    	                     --rep=${rep} --analysis_type="cv"; ) || true
fi


if [[ ${stage} -le 2 ]]; then
    if [[ ! -f ${imp_test_path}ds.dupvar ]]; then
        touch ${imp_test_path}ds.dupvar
    fi
    for cur_hp in {1..102}; do
        if [[ -f ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights ]]; then
            plink --bfile ${imp_test_path}${ds_prefix}${test_suffix}  \
                  --score ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights 2 5 6 \
                  --exclude ${imp_test_path}ds.dupvar \
                  --out ${prs_path}${prs_prefix_adapter}${test_suffix}.${cur_hp}
        else
          echo "${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights does not exists. skipping..."
        fi
    done
fi

if [[ ${stage} -le 3 ]]; then
     	    Rscript calc_metrics_cv_ld.R --discovery=${discovery} --target=${target} --imp=${imp} \
     	                                 --suffix=${test_suffix} --rep=${rep} --sub=${sub} --analysis_type="cv";

fi
