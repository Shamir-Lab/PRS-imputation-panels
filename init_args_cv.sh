# Parse input

source init_args_prs.sh

if [[ -z ${cv} ]]; then echo "please provide cv value" && exit 1; fi
if [[ -z ${rep} ]]; then echo "please provide rep value" && exit 1; fi

if [[ ! -z "${cv}" ]]; then
        if [[ ${cv} == *@* ]]; then
            echo "perform customized test"
            train_suffix=_${cv%@*}
            echo "train_suffix: ${train_suffix}"
            test_suffix=_${cv#*@}
            echo "test_suffix: ${test_suffix}"
        elif [[ ${cv} == *_* ]]; then
            echo "perform cross-validation"
            train_suffix=_${cv}_train
            echo "train_suffix: ${train_suffix}"
            test_suffix=_${cv}_validation
            echo "test_suffix: ${test_suffix}"
        else
            echo "test against a hold-out set"
            train_suffix=_${cv}_both
            echo "train_suffix: ${train_suffix}"
            test_suffix=_${cv}_test
            echo "test_suffix: ${test_suffix}"
        fi
fi
if [[ "${train_suffix}" == "" || -z "${train_suffix}" ]]; then
    train_suffix=${suffix}
    test_suffix=${suffix}
fi
suffix=${test_suffix}

target_train_path=${PRS_DATASETS}/${target_train}"/rep_${rep}/"
target_test_path=${target_train_path}
target_path=${target_train_path}

imp_train_path=${PRS_DATASETS}/${target_train}"/rep_${rep}/${imp}/"
imp_test_path=${imp_train_path}
imp_path=${imp_train_path}
base_imp_path=${PRS_DATASETS}/${target_train}/${imp}"/"


prs_path=${prs_path}"rep_${rep}/"


mkdir -p ${imp_path} || echo ""
mkdir -p ${prs_path} || echo ""
