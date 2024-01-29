#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

source init_args_cv.sh

# prs_prefix="prs.cv.ls_${pop}_${pheno}"
# ds_prefix="ds_${pop}_${pheno}"

prs_prefix="prs.cv.ls__${pop}"
prs_prefix_adapter="prs.cv.ls_${pheno}_${pop}"
ds_prefix="ds__${pop}"

if [[ -z ${override} ]]; then override="false"; fi

mkdir -p ${prs_path}lasso ||  true

if [[ ! -f ${imp_train_path}${ds_prefix}${train_suffix}.bim ]]; then
    echo "${imp_train_path}${ds_prefix}${train_suffix}.bim" does not exists. Skipping...
    exit 0
fi


if [[ ${stage} -le 1 ]]; then
    	    Rscript lassosum.R --discovery=${discovery} --target=${target} --imp=${imp} \
    	                       --train_suffix=${train_suffix} --test_suffix=${test_suffix} \
    	                       --rep=${rep} --analysis_type="cv" --ld=${ld};
fi


if [[ ${stage} -le 2 ]]; then
    if [[ ${hp} == "" ]]; then
        hp="0.2,0.5,0.9,1"
    fi
    hp_arr=(${hp//,/ })

    for cur_hp in ${hp_arr[@]}; do

        for hp2 in {1..20}; do

            if [[ ! -f ${prs_path}${prs_prefix_adapter}${test_suffix}.${cur_hp}-${hp2}.profile || ${override} = "true" ]]; then

                plink --bfile ${imp_test_path}${ds_prefix}${test_suffix}  \
                      --score ${prs_path}lasso/${prs_prefix}${train_suffix}.${cur_hp}-${hp2}.weights 2 4 6 \
                      --exclude ${imp_test_path}ds.dupvar \
                      --memory 20000 \
                      --threads 5 \
                      --out ${prs_path}${prs_prefix_adapter}${test_suffix}.${cur_hp}-${hp2} || true

                fi
        done
    done
fi


if [[ ${stage} -le 3 ]]; then
          echo "here"
     	    Rscript calc_metrics_cv_ls.R --discovery=${discovery} --target=${target} --imp=${imp} \
     	                                 --suffix=${test_suffix} --rep=${rep} --sub=${sub} --analysis_type="cv";
fi
