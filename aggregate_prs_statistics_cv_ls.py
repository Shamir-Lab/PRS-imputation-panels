import argparse
from aggregate_prs_statistics_cv_generic import aggregate_statistics_cv

if __name__=="__main__":

    method="ls"

    discoveries=["GC_sysp_sakaue_2021"] # ["D_bca_michailidou_2017_bcac_onco_aj", "UKB_bc_eur_bcac_onco_aj", "bcac_onco_eur_bcac_onco_aj", "bcac_onco_eur-minus-outliers_bcac_onco_aj", "bcac_onco_eur-1pcs_bcac_onco_aj", "bcac_onco_eur-2pcs_bcac_onco_aj", "bcac_onco_eur-3pcs_bcac_onco_aj", "bcac_onco_eur-4pcs_bcac_onco_aj", "bcac_onco_eur-5pcs_bcac_onco_aj", "bcac_onco_eur-6pcs_bcac_onco_aj", "bcac_onco_eur-3pcs2_bcac_onco_aj" , "bcac_onco_eur-5pcs_ukbb_eur"]
    targets=["ukbb_afr"]
    imps=["original"] # , "imputeX_new"]

    hyperparameters=[f'{a}-{b}' for a in [0.2,0.5,0.9,1] for b in range(1,21)]

    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-d', '--discoveries', dest='discoveries', help="", default=",".join(discoveries))
    parser.add_argument('-t', '--targets', dest='targets', help="", default=",".join(targets))
    parser.add_argument('-i', '--imps', dest='imps', help="", default=",".join(imps))
    parser.add_argument('-hp', '--hyperparameters', dest='hyperparameters', help="", default=",".join(hyperparameters))
    parser.add_argument('-c', '--cv_folds', dest='cv_folds', help="", default="5")
    parser.add_argument('-r', '--rep', dest='rep', help="", default="105_1")
    parser.add_argument('-s', '--suffix', dest='suffix', help="", default="gc_eas")

    args = parser.parse_args()
    discoveries=args.discoveries.split(',')
    targets=args.targets.split(',')
    imps=args.imps.split(',')
    hyperparameters=args.hyperparameters.split(',')

    cv_folds=int(args.cv_folds)
    rep=args.rep
    suffix=args.suffix


    # aggregate_statistics_cv(discoveries, targets, imps, method, hyperparameters, cv_folds, 6, f'{suffix}_{rep}')

    for method in ["pt3"]: # , "pt3"]:
        for cur_rep in range(1,6):
            rep=f"105_{cur_rep}"
            aggregate_statistics_cv(discoveries, targets, imps, method, hyperparameters, cv_folds, rep, f'{suffix}_{rep}')

