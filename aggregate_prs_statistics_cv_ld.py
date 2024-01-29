import argparse
from aggregate_prs_statistics_cv_generic import aggregate_statistics_cv

if __name__=="__main__":


    method="ld"

    discoveries=["bcac_onco_eur-5pcs-country"] # ["D_bca_michailidou_2017_bcac_onco_aj", "UKB_bc_eur_bcac_onco_aj", "bcac_onco_eur_bcac_onco_aj", "bcac_onco_eur-minus-outliers_bcac_onco_aj", "bcac_onco_eur-1pcs_bcac_onco_aj", "bcac_onco_eur-2pcs_bcac_onco_aj", "bcac_onco_eur-3pcs_bcac_onco_aj", "bcac_onco_eur-4pcs_bcac_onco_aj", "bcac_onco_eur-5pcs_bcac_onco_aj", "bcac_onco_eur-6pcs_bcac_onco_aj", "bcac_onco_eur-3pcs2_bcac_onco_aj" , "bcac_onco_eur-5pcs_ukbb_eur"]
    targets=["bcac_onco_aj"]
    imps=["impX_new"] # , "imputeX_new"]

    hyperparameters=[str(a) for a in range(1,103)]

    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-d', '--discoveries', dest='discoveries', help="", default=",".join(discoveries))
    parser.add_argument('-t', '--targets', dest='targets', help="", default=",".join(targets))
    parser.add_argument('-i', '--imps', dest='imps', help="", default=",".join(imps))
    parser.add_argument('-hp', '--hyperparameters', dest='hyperparameters', help="", default=",".join(hyperparameters))
    parser.add_argument('-c', '--cv_folds', dest='cv_folds', help="", default="5")
    parser.add_argument('-r', '--rep', dest='rep', help="", default="10")
    parser.add_argument('-s', '--suffix', dest='suffix', help="", default="")

    args = parser.parse_args()
    discoveries=args.discoveries.split(',')
    targets=args.targets.split(',')
    imps=args.imps.split(',')
    hyperparameters=args.hyperparameters.split(',')
    prs_names=[f'{a}_{b}' for a, b in zip(discoveries, targets)]

    cv_folds=int(args.cv_folds)
    rep=args.rep
    suffix=args.suffix

    aggregate_statistics_cv(discoveries, targets, imps, method, hyperparameters, cv_folds, rep, f'{suffix}_{rep}')
