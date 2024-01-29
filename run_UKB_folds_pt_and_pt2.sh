source constants_.sh
source parse_args.sh "$@"

# discoveries="D2_sysp_evangelou_2018" # "D2_sysp_evangelou_2018,D2_dias_evangelou_2018,D2_asth_zhu_2019,D2_chol_willer_2013,D2_ldlp_willer_2013,D2_t2di_mahajan_2018,D2_gerx_an_2019,D2_madd_howard_2019" # "D2_sysp_evangelou_2018,D2_dias_evangelou_2018,D2_asth_zhu_2019,D2_chol_willer_2013,D2_hdlp_willer_2013,D2_ldlp_willer_2013,D2_t2di_mahajan_2018,D2_gerx_an_2019,D2_madd_howard_2019" # "D2_sysp_evangelou_2018" D2_hdlp_willer_2013
# discoveries="UKB_ht_eur,UKB_chol_eur,UKB_hfvr_eur,UKB_hyty_eur,UKB_madd_eur,UKB_osar_eur,UKB_t2d_eur,UKB_utfi_eur,UKB_gerx_eur,UKB_angna_eur,UKB_ast_eur,UKB_ctrt_eur"
discoveries=${discoveries//,/ }
# targets="ukbb_sas,ukbb_afr" # "ukbb_${pop}"
targets=${targets//,/ }
# imps="impX_new" # "impute2_1kg_gbr,impute2_1kg_eur,impute2_1kg_${pop}" # ,impute2_1kg_afr" # ,impute2_1kg_sas "impute2_1kg_ceu2"
imps=${imps//,/ }
method=${method}
base_rep=105
folds=5
complete_missing=true

if [[ -z ${ld} ]]; then ld="eur"; fi


counter=0
min_n_profiles=9
echo "start with discoveries=${discoveries}, targets=${targets}, imps=${imps}"
for discovery in ${discoveries[@]}; do
    if [[ -z  ${pheno} ]]; then pheno=${gwas_to_pheno[${discovery}]}; fi
    if [[ ! -z  ${pheno} ]]; then pheno_param="--pheno ${pheno}"; fi
    for target in ${targets[@]}; do
        for imp in ${imps[@]}; do
            for cur_rep in {1..6}; do
                for fold in {1..5}; do
                    res1=$(ls -1 /specific/netapp5/gaga/gaga-pd/prs_data/PRSs//${discovery}_${target}/${imp}/rep_${base_rep}_${cur_rep}/prs.cv.${method}_${pheno}__${fold}_${folds}_validation.*.profile 2>/dev/null| wc -l ) ;
                    res3=$(ls -1 /specific/netapp5/gaga/gaga-pd/prs_data/PRSs//${discovery}_${target}/${imp}/rep_${base_rep}_${cur_rep}/prs.cv.${method}_${pheno}__${fold}_${folds}_validation.or.percentile.*.tsv 2>/dev/null | wc -l );
                    stage=3 # -1
                    if [[ ${res3} -lt ${min_n_profiles} ]]; then
                        stage=3
                    fi
                    if [[ ${res1} -lt ${min_n_profiles} || ${override} == "true" ]]; then
                        stage=1
                    fi
                    echo "Discovery: ${discovery}, Target: ${target}, imp: ${imp}, rep: ${cur_rep}, fold: ${fold}: res validation: stage 1 - ${res1}, stage 3 - ${res3}"
                    if [[ ${stage} -ne -1 ]]; then
                        if [[ ${complete_missing} = true ]]; then
                           bash calc_prs_cv_${method}.sh --discovery ${discovery} --target ${target} --imp ${imp} --cv ${fold}_${folds} --rep ${base_rep}_${cur_rep} --ld=${ld} --stage ${stage} ${pheno_param};
                        fi
                        echo "Discovery: ${discovery}, Target: ${target}, imp: ${imp}, rep: ${cur_rep}, fold: ${fold}: res validation: stage 1 - ${res1}, stage 3 - ${res3}"
                        counter=$((${counter}+1))
                    fi
                done;
                res1=$(ls -1 /specific/netapp5/gaga/gaga-pd/prs_data/PRSs//${discovery}_${target}/${imp}/rep_${base_rep}_${cur_rep}/prs.cv.${method}_${pheno}__${fold}_test.*.profile 2>/dev/null | wc -l);
                res3=$(ls -1 /specific/netapp5/gaga/gaga-pd/prs_data/PRSs//${discovery}_${target}/${imp}/rep_${base_rep}_${cur_rep}/prs.cv.${method}_${pheno}__${fold}_test.or.percentile.*.tsv 2>/dev/null | wc -l );
                # echo "Discovery: ${discovery}, Target: ${target}, imp: ${imp}, rep: ${cur_rep}, fold: ${fold}: res test: stage 1 - ${res1}, stage 3 - ${res3}"
                stage=3 # -1
                if [[ ${res3} -lt ${min_n_profiles} ]]; then
                    stage=3
                fi
                if [[ ${res1} -lt ${min_n_profiles} || ${override} == "true" ]]; then
                    stage=1
                fi
                if [[ ${stage} -ne -1 ]]; then
                    if [[ ${complete_missing} = true ]]; then
                        bash calc_prs_cv_${method}.sh --discovery ${discovery} --target ${target} --imp ${imp} --cv 5 --rep ${base_rep}_${cur_rep} --ld=${ld} --stage ${stage} ${pheno_param};
                    fi
                    echo "Discovery: ${discovery}, Target: ${target}, imp: ${imp}, rep: ${cur_rep}, fold: ${fold}: res test: stage 1 - ${res1}, stage 3 - ${res3}"
                    counter=$((${counter}+1))
                fi
            done
        done
    done
done

echo "counter: ${counter}"

