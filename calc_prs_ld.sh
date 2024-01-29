#!/bin/bash

source constants_.sh
source parse_args.sh "$@"
source init_args_prs.sh

prs_prefix="prs.mono.ld${sub}"
ds_prefix="ds${sub}"

echo "Start pipeline"
mkdir -p $prs_path || echo ""
mkdir -p ${prs_path}ldpred || true

if [[ ${stage} -le 1 ]]; then
            Rscript ldpred.R --discovery=${discovery} --target=${target} --imp=${imp} --analysis_type="mono";
fi


if [[ ${stage} -le 2 ]]; then
    for cur_hp in {1..102}; do
        if [[ -f ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights ]]; then
            plink --bfile ${imp_test_path}${ds_prefix}${test_suffix}  \
                  --score ${prs_path}ldpred/${prs_prefix}${train_suffix}.${cur_hp}.weights 2 5 6 \
                  --exclude ${imp_test_path}ds.dupvar \
                  --out ${prs_path}${prs_prefix}${test_suffix}.${cur_hp}
        fi
    done
fi


if [[ ${stage} -le 3 ]]; then
            Rscript calc_metrics_ls.R --discovery=${discovery} --target=${target} --imp=${imp}  --sub=${sub} --analysis_type="mono";

fi

