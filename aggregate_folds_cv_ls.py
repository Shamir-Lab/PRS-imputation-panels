import argparse
from aggregate_folds_cv_generic import aggregate_folds_cv_multi_test

if __name__=='__main__':

    discoveries=["GC_sysp_sakaue_2021"] # ["D_bca_michailidou_2017_bcac_onco_aj", "UKB_bc_eur_bcac_onco_aj", "bcac_onco_eur_bcac_onco_aj", "bcac_onco_eur-minus-outliers_bcac_onco_aj", "bcac_onco_eur-1pcs_bcac_onco_aj", "bcac_onco_eur-2pcs_bcac_onco_aj", "bcac_onco_eur-3pcs_bcac_onco_aj", "bcac_onco_eur-4pcs_bcac_onco_aj", "bcac_onco_eur-5pcs_bcac_onco_aj", "bcac_onco_eur-6pcs_bcac_onco_aj", "bcac_onco_eur-3pcs2_bcac_onco_aj" , "bcac_onco_eur-5pcs_ukbb_eur"]
    targets=["ukbb_afr"]
    imps=["original"] # , "imputeX_new"]
    hyperparameters=[f'{a}-{b}' for a in [0.2,0.5,0.9,1] for b in range(1,21)]

    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-s', '--rep_start', dest='rep_start', help='', default='105_1')
    parser.add_argument('-e', '--rep_end', dest='rep_end', help="", default='105_2')
    parser.add_argument('-d', '--discoveries', dest='discoveries', help="", default=",".join(discoveries))
    parser.add_argument('-t', '--targets', dest='targets', help="", default=",".join(targets))
    parser.add_argument('-i', '--imps', dest='imps', help="", default=",".join(imps))
    parser.add_argument('-hp', '--hyperparameters', dest='hyperparameters', help="", default=",".join(hyperparameters))
    parser.add_argument('-m', '--metric_names', dest='metric_names', help="", default="or.all,or.90")
    parser.add_argument('-fn', '--file_name_format', dest='file_name_format', help="", default="prs.cv.ls{{}}.statistics_summary_{}{{}}.tsv")
    parser.add_argument('-su', '--suffix', dest='suffix', help="", default="gc_eas")

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

    aggregate_folds_cv_multi_test(file_name_format.format(suffix), field_names, discoveries, targets, imps=imps, out_suffix=suffix, rep_start=rep_start, rep_end=rep_end)
   
