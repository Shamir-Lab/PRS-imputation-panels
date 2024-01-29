# Parse input

source constants_.sh

if [[ -z ${discovery} ]]; then echo "discovery value is missing" && exit 1; fi

if [[ (-z ${target_train}  || -z ${target_test} ) && -z ${target} ]]; then echo "target values are missing" && exit 1; fi
if [[ -z ${target_train} ]]; then target_train=$target; fi
if [[ -z ${target_test} ]]; then target_test=$target; fi
target=$target_test


if [[ (-z ${imp_train}  || -z ${imp_test} ) && -z ${imp} ]]; then echo "imp values are missing" && exit 1; fi
if [[ -z ${imp_train} ]]; then imp_train=$imp; fi
if [[ -z ${imp_test} ]]; then imp_test=$imp; fi
imp=$imp_test

if [[ -z ${stage} ]]; then stage=1; fi
if [[ -z ${hp}  ]]; then hp=""; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [[ -z ${pheno}  ]]; then pheno=""; fi
if [[ -z ${continuous}  ]]; then continuous="false"; fi
if [[ ! -z ${pheno} ]]; then pheno_suffix=_${pheno}_; fi
if [[ -z ${ld} ]]; then ld="eur"; fi

sub=""

if [[ ! "${pheno}" == ""  ||  ! "${pop}" == "" ]]; then
	sub=_${pheno}_${pop}
fi

if [[ ! "${pheno}" == ""  ]]; then
        pheno=${pheno} # removed underscore prefix!
fi

if [[ ! "${pop}" == "" ]]; then
        pop=${pop} # removed underscore prefix!
fi

train_suffix=""
test_suffix=""
suffix=""

discovery_path=${GWASs_path}${discovery}'/'
target_train_path=${datasets_path}${target_train}'/'
target_test_path=${datasets_path}${target_test}'/'
target_path=${target_test_path}

imp_train_path=${target_train_path}${imp_train}'/'
imp_test_path=${target_test_path}${imp_test}'/'
imp_path=${imp_test_path}

prs_path=${PRSs_path}${discovery}_${target}"/${imp}/"
mkdir -p ${prs_path} || echo ""
