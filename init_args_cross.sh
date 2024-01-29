# Parse input

source init_args_prs.sh

prs_path="${PRSs_path}${discovery}_${target_test}/${imp_test}/cross_${target_train}/${imp_train}/"
mkdir -p ${prs_path} || echo ""
