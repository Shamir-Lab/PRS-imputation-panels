#!/bin/bash
# set -e

public_base_path='/specific/elkon/hagailevi/PRS/'
base_path='/specific/netapp5/gaga/gaga-pd/prs_data/'
# private_base_path=${base_path}'datasets/dec2/'
codebase_path=${public_base_path}'/codebase/'
datasets_path=${base_path}'datasets/dec/'
PRSs_path=${base_path}'PRSs/'
GWASs_path=${public_base_path}'GWASs/'
reference_path='/specific/elkon/hagailevi/data-scratch/'
beagle_path='/specific/elkon/hagailevi/PRS/tools/beagle/'

declare -A gwas_to_pheno=(['D2_hg_yengo_2018']='height' ['D2_ldlp_willer_2013']='chol' ['D2_hdlp_willer_2013']='chol' ['D2_chol_willer_2013']='chol'  ['D2_sysp_evangelou_2018']='ht' ['D2_dias_evangelou_2018']='ht' ['D2_asth_zhu_2019']='ast' ['D2_t2di_mahajan_2018']='t2d' ['D2_madd_howard_2019']='madd' ['D2_gerx_an_2019']='gerx' ['D2_hdlp_willer_2013']='chol' ['D_t2d_mahajan_2018']='t2d' ['UKB_ht_eur']='ht' ['UKB_chol_eur']='chol' ['UKB_hfvr_eur']='hfvr' ['UKB_hyty_eur']='hyty'  ['UKB_madd_eur']='madd' ['UKB_osar_eur']='osar' ['UKB_t2d_eur']='t2d' ['UKB_utfi_eur']='utfi' ['UKB_gerx_eur']='gerx' ['UKB_angna_eur']='angna' ['UKB_ast_eur']='ast' ['UKB_ctrt_eur']='ctrt' ['GC_sysp_sakaue_2021']='ht' ['GC_chol_sakaue_2021']='chol' ['GC_hfvr_sakaue_2021']='hfvr' ['GC_hyty_sakaue_2021']='hyty'  ['GC_madd_sakaue_2021']='madd' ['GC_osar_sakaue_2021']='osar' ['GC_t2d_sakaue_2021']='t2d' ['GC_utfi_sakaue_2021']='utfi' ['GC_gerx_sakaue_2021']='gerx' ['GC_angna_sakaue_2021']='angna' ['GC_ast_sakaue_2021']='ast' ['GC_ctrt_sakaue_2021']='ctrt')

echo "gtp: ${gwas_to_pheno}"
