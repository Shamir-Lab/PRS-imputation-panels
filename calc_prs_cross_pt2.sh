#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

source init_args_cross.sh

prs_prefix="prs.cross.pt2${sub}"
ds_prefix="ds${sub}"

if [[ ${stage} -le 1 ]]; then
    source pt2.sh
fi

if [[ ${stage} -le 3 ]]; then
    if [[ -f "${datasets_path}${target}/pheno${sub}" ]]; then
        if [[ ${continuous} == "false" ]]; then

     	    echo Finding the best-fit PRS with binary phenotypes
    	    Rscript calc_metrics_cross_pt2.R --discovery=${discovery} \
    	    --target_train=${target_train} --imp_train=${imp_train} \
    	    --target_test=${target_test} --imp_test=${imp_test} \
    	    --suffix=${suffix} --rep=${rep} --analysis_type="cross";
       else
            echo Finding the best-fit PRS with continuous phenotypes
            Rscript best_fit_prs_continuous.R ${discovery} ${target} ${imp} ${hp} ${sub};
        fi
    else
        echo "No pheno named pheno${sub} was found under ${target}"
    fi
fi
