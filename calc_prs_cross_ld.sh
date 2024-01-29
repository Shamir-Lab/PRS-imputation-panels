#!/bin/bash
source constants_.sh
source parse_args.sh "$@"

source init_args_cross.sh

method="ld"

prs_prefix="prs.cross.${method}${sub}"
ds_prefix="ds${sub}"
#ds_prefix="ds_flipped${sub}"

mkdir -p ${prs_path}ldpred ||  true

if [[ ${stage} -le 1 ]]; then
    	    Rscript ldpred.R --discovery=${discovery} \
    	    --target_train=${target_train} --imp_train=${imp_train} \
    	    --target_test=${target_test} --imp_test=${imp_test} \
    	    --suffix=${suffix} --rep=${rep} --analysis_type="cross";
fi

if [[ ${stage} -le 2 ]]; then
    for cur_hp in {1..102}; do
        if [[ -f ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights ]]; then
            plink --bfile ${imp_test_path}${ds_prefix}${test_suffix}  \
                  --score  ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights 2 5 6 \
                  --exclude ${imp_test_path}ds.dupvar \
                  --out ${prs_path}${prs_prefix}${test_suffix}.${cur_hp} # ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights 2 5 6 \ $PRS_PRSS/bcac_onco_eur-5pcs_bcac_onco_aj/impX_new/rep_75/ldpred/prs.cv.ld___1_5_train.1500.weights 1 5 6 \
        fi
    done
fi

if [[ ${stage} -le 3 ]]; then
     	    Rscript calc_metrics_cross_${method}.R --discovery=${discovery} \
    	    --target_train=${target_train} --imp_train=${imp_train} \
    	    --target_test=${target_test} --imp_test=${imp_test} \
    	    --suffix=${suffix} --rep=${rep} --analysis_type="cross";

fi
