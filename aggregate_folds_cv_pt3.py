import argparse

from aggregate_folds_cv_generic import aggregate_folds_cv_multi_test

if __name__=='__main__':

    discoveries=["GC_sysp_sakaue_2021"] # ["D_bca_michailidou_2017_bcac_onco_aj", "UKB_bc_eur_bcac_onco_aj", "bcac_onco_eur_bcac_onco_aj", "bcac_onco_eur-minus-outliers_bcac_onco_aj", "bcac_onco_eur-1pcs_bcac_onco_aj", "bcac_onco_eur-2pcs_bcac_onco_aj", "bcac_onco_eur-3pcs_bcac_onco_aj", "bcac_onco_eur-4pcs_bcac_onco_aj", "bcac_onco_eur-5pcs_bcac_onco_aj", "bcac_onco_eur-6pcs_bcac_onco_aj", "bcac_onco_eur-3pcs2_bcac_onco_aj" , "bcac_onco_eur-5pcs_ukbb_eur"]
    targets=["ukbb_afr"]
    imps=["original"] # , "imputeX_new"]
    hyperparameters=["0.00000005", "0.0000001", "0.000001", "0.00001", "0.0001", "0.001", "0.005", "0.01", "0.05", "0.1", "0.2", "0.3", "0.4", "0.5"]

    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-s', '--rep_start', dest='rep_start', help='', default='105_1')
    parser.add_argument('-e', '--rep_end', dest='rep_end', help="", default='105_6')
    parser.add_argument('-d', '--discoveries', dest='discoveries', help="", default=",".join(discoveries))
    parser.add_argument('-t', '--targets', dest='targets', help="", default=",".join(targets))
    parser.add_argument('-i', '--imps', dest='imps', help="", default=",".join(imps))
    parser.add_argument('-hp', '--hyperparameters', dest='hyperparameters', help="", default=",".join(hyperparameters))
    parser.add_argument('-m', '--metric_names', dest='metric_names', help="", default="or.all,or.90")
    parser.add_argument('-fn', '--file_name_format', dest='file_name_format', help="", default="prs.cv.pt3{{}}.statistics_summary_{}{{}}.tsv")
    parser.add_argument('-su', '--suffix', dest='suffix', help="", default="ukb_eur")

    args = parser.parse_args()
    rep_start = args.rep_start
    rep_end = args.rep_end

    discoveries=args.discoveries.split(',')
    targets=args.targets.split(',')
    imps=args.imps.split(',')
    hyperparameters=args.hyperparameters.split(',')

    metric_names = args.metric_names
    file_name_format = args.file_name_format
    field_names=metric_names.split(',')
    suffix=args.suffix

    # discoveries = ["GC_sysp_sakaue_2021", "GC_gerx_sakaue_2021", "GC_hyty_sakaue_2021", "GC_ctrt_sakaue_2021",
    #                "GC_hfvr_sakaue_2021", "GC_t2d_sakaue_2021", "GC_chol_sakaue_2021", "GC_ast_sakaue_2021",
    #                "GC_madd_sakaue_2021", "GC_utfi_sakaue_2021", "GC_osar_sakaue_2021", "GC_angna_sakaue_2021"]
    discoveries = ["UKB_ht_eur", "UKB_chol_eur", "UKB_hfvr_eur", "UKB_hyty_eur", "UKB_madd_eur", "UKB_osar_eur",
                   "UKB_t2d_eur", "UKB_utfi_eur", "UKB_gerx_eur", "UKB_angna_eur", "UKB_ast_eur", "UKB_ctrt_eur"]
    # discoveries = ["UKB_ht_eur", "UKB_chol_eur", "UKB_hfvr_eur", "UKB_osar_eur", "UKB_t2d_eur", "UKB_ast_eur"]

    targets=['ukbb_sas' , 'ukbb_afr']
    imps = "original,impute2_1kg_eur,impute2_1kg_sas,impute2_1kg_afr".split(",") # ,impute2_1kg_afr ,impute2_1kg_eur100,impute2_1kg_afr
    for cur_file_name_format in ["prs.cv.ld{{}}.statistics_summary_{}{{}}.tsv"]: # ["prs.cv.pt2{{}}.statistics_summary_{}{{}}.tsv", "prs.cv.pt3{{}}.statistics_summary_{}{{}}.tsv", "prs.cv.ls{{}}.statistics_summary_{}{{}}.tsv", "prs.cv.ld{{}}.statistics_summary_{}{{}}.tsv"]:
        rep_start = '105_1'
        rep_end = '105_6'
        if ".ld" in cur_file_name_format:
            rep_start = '102_1'
            rep_end = '102_3'
        aggregate_folds_cv_multi_test(cur_file_name_format.format(suffix), field_names, discoveries, targets, imps=imps, out_suffix=suffix, rep_start=rep_start, rep_end=rep_end)
   
