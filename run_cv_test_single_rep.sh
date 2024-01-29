source constants_.sh
source parse_args.sh "$@"

if [[ -z ${discovery} ]]; then echo "must provide discovery value. Terminating..."; exit 1 ; fi
if [[ -z ${target} ]]; then echo "must provide target value. Terminating..."; exit 1 ; fi
if [[ -z ${imp} ]]; then echo "must provide imp value. Terminating..."; exit 1 ; fi
if [[ -z ${method} ]]; then echo "must provide method value. Terminating..."; exit 1 ; fi
if [[ -z ${rep} ]]; then echo "must provide rep value. Terminating..."; exit 1 ; fi
if [[ -z ${fold_start}  ]]; then fold_start=1; fi
if [[ -z ${folds} ]]; then  folds=5; fi
if [[ -z ${stage} ]]; then stage=1; fi

bash calc_prs_cv_${method}.sh --discovery ${discovery} --target ${target} --imp ${imp} --cv 5 --stage ${stage} --rep ${rep}
