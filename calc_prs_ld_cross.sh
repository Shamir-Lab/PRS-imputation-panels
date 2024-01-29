#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

# Parse input
if [[ -z ${maf} ]]; then maf=0.05; fi
if [[ -z ${geno} ]]; then geno=0.1; fi
if [[ -z ${imp} ]]; then imp="original"; fi
if [[ -z ${memory} ]]; then memory=500000; fi
if [[ -z ${threads} ]]; then threads=80; fi
if [[ -z ${stage} ]]; then stage=1; fi
if [[ -z ${hp}  ]]; then hp="0.1"; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [[ -z ${pheno}  ]]; then pheno=""; fi
if [[ -z ${continuous}  ]]; then continuous="false"; fi

sub=""

if [[ ! "${pheno}" == ""  ||  ! "${pop}" == "" ]]; then
	sub=_${pheno}_${pop}
fi

if [[ ! "${pheno}" == ""  ]]; then
        pheno=_${pheno}
fi

if [[ ! "${pop}" == "" ]]; then
        pop=_${pop}
fi

prs_prefix="prs.ld"

discovery_path=${GWASs_path}${discovery}'/'
target_path=${datasets_path}${target}"/${imp}/"
prs_path=${PRSs_path}${discovery}_${target}"/${imp}/"

# Start pipeline
echo $GWASs_path
mkdir -p $prs_path || echo ""


if [[ ${stage} -le 1 ]]; then
    	    Rscript ldpred.R ${discovery} ${target} ${imp} "${sub}" "${hp}" ${target_train} ${target_test} ${rep};
fi

if [[ ${stage} -le 2 ]]; then
    	    Rscript calc_metrics_cv_ld.R ${discovery} ${target} ${imp} "${sub}" "${hp}" "" ${target_test} ${rep};
fi
