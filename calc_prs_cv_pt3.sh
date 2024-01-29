#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

source init_args_pt.sh
source init_args_cv.sh

prs_prefix="prs.cv.pt3_${pheno}_${pop}"
ds_prefix="ds__" # ds_${pheno}_${pop}"

if [[ ${stage} -le 1 ]]; then
    sub_tmp=${sub}
    sub=""
    source pt3.sh
    sub=${sub_tmp}
fi

if [[ ${stage} -le 3 ]]; then
    if [[ -f "${datasets_path}${target}/pheno${sub}" ]]; then
        if [[ ${continuous} == "false" ]]; then

     	    echo Finding the best-fit PRS with binary phenotypes
    	    Rscript calc_metrics_cv_pt3.R --discovery=${discovery} --target=${target} --imp=${imp} \
    	                                 --suffix=${test_suffix} --rep=${rep} --sub=${sub} --analysis_type="cv";
       else
            echo Finding the best-fit PRS with continuous phenotypes
            Rscript best_fit_prs_continuous.R ${discovery} ${target} ${imp} ${hp} ${sub};
        fi
    else
        echo "No pheno named pheno${sub} was found under ${target}"
    fi
fi
