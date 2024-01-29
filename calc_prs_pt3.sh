#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

source init_args_pt.sh
source init_args_prs.sh

prs_prefix="prs.mono.pt3" # ${sub}"
ds_prefix="ds" # ${sub}"
test_suffix=""
sub=""

if [[ ! -z $pheno ]]; then
    pheno_suffix="_${pheno}"
fi

if [[ ${stage} -le 1 ]]; then
    
    source pt3.sh
fi

if [[ ${stage} -le 3 ]]; then
    if [[ -f "${datasets_path}${target}/pheno${sub}" ]]; then
        if [[ ${continuous} == "false" ]]; then

     	    echo Finding the best-fit PRS with binary phenotypes
    	    Rscript calc_metrics_pt3.R --discovery=${discovery} \
    	    --target_train=${target_train} --imp_train=${imp_train} \
    	    --target_test=${target_test} --imp_test=${imp_test} \
    	    --sub=${pheno_suffix} --analysis_type="mono";
       else
            echo Finding the best-fit PRS with continuous phenotypes
            Rscript best_fit_prs_continuous.R ${discovery} ${target} ${imp} ${hp} ${sub};
        fi
    else
        echo "No pheno named pheno${sub} was found under ${target}"
    fi
fi
