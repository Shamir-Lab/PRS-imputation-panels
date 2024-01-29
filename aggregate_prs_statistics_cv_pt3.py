import argparse
from multiprocessing import Pool
from aggregate_prs_statistics_cv_generic import aggregate_statistics_cv, aggregate_statistics_cv_mp

if __name__ == "__main__":

    method = "pt3"

    discoveries = [
        "GC_sysp_sakaue_2021"]  # ["D_bca_michailidou_2017_bcac_onco_aj", "UKB_bc_eur_bcac_onco_aj", "bcac_onco_eur_bcac_onco_aj", "bcac_onco_eur-minus-outliers_bcac_onco_aj", "bcac_onco_eur-1pcs_bcac_onco_aj", "bcac_onco_eur-2pcs_bcac_onco_aj", "bcac_onco_eur-3pcs_bcac_onco_aj", "bcac_onco_eur-4pcs_bcac_onco_aj", "bcac_onco_eur-5pcs_bcac_onco_aj", "bcac_onco_eur-6pcs_bcac_onco_aj", "bcac_onco_eur-3pcs2_bcac_onco_aj" , "bcac_onco_eur-5pcs_ukbb_eur"]
    targets = ["ukbb_afr"]
    imps = ["original"]  # , "imputeX_new"]

    hyperparameters = ["0.00000005", "0.0000001", "0.000001", "0.00001", "0.0001", "0.001", "0.005", "0.01", "0.05",
                       "0.1", "0.2", "0.3", "0.4", "0.5"]

    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-d', '--discoveries', dest='discoveries', help="", default=",".join(discoveries))
    parser.add_argument('-t', '--targets', dest='targets', help="", default=",".join(targets))
    parser.add_argument('-i', '--imps', dest='imps', help="", default=",".join(imps))
    parser.add_argument('-hp', '--hyperparameters', dest='hyperparameters', help="", default=",".join(hyperparameters))
    parser.add_argument('-c', '--cv_folds', dest='cv_folds', help="", default="5")
    parser.add_argument('-r', '--rep', dest='rep', help="", default="105_1")
    parser.add_argument('-s', '--suffix', dest='suffix', help="", default="ukb_eur")

    args = parser.parse_args()
    discoveries = args.discoveries.split(',')
    targets = args.targets.split(',')
    imps = args.imps.split(',')
    hyperparameters = args.hyperparameters.split(',')

    cv_folds = int(args.cv_folds)
    rep = args.rep
    suffix = args.suffix

    # aggregate_statistics_cv(discoveries, targets, imps, method, hyperparameters, cv_folds, 6, f'{suffix}_{rep}')
    # discoveries = ["GC_sysp_sakaue_2021", "GC_gerx_sakaue_2021", "GC_hyty_sakaue_2021", "GC_ctrt_sakaue_2021",
    #                "GC_hfvr_sakaue_2021", "GC_t2d_sakaue_2021", "GC_chol_sakaue_2021", "GC_ast_sakaue_2021",
    #                "GC_madd_sakaue_2021", "GC_utfi_sakaue_2021", "GC_osar_sakaue_2021", "GC_angna_sakaue_2021"]

    # discoveries = ["UKB_ht_eur", "UKB_chol_eur", "UKB_hfvr_eur", "UKB_hyty_eur", "UKB_madd_eur", "UKB_osar_eur",
    #                "UKB_t2d_eur", "UKB_utfi_eur", "UKB_gerx_eur", "UKB_angna_eur", "UKB_ast_eur", "UKB_ctrt_eur"]
    discoveries = ["UKB_ht_eur", "UKB_chol_eur", "UKB_hfvr_eur", "UKB_osar_eur", "UKB_t2d_eur", "UKB_ast_eur"]

    targets = ['ukbb_sas' , 'ukbb_afr'] #
    imps = "original,impute2_1kg_eur,impute2_1kg_sas,impute2_1kg_afr".split(",") #  ,impute2_1kg_afr  "original,impute2_1kg_afr,impute2_1kg_sas,impute2_1kg_eur100,impute2_1kg_eur".split(",")  # original,impute2_1kg_afr,impute2_1kg_sas

    aggregate_statistics_cv_params = []

    for method in ["ld"]: # ["pt2", "pt3", "ls", "ld"]:
        base_rep = 105
        n_reps = 6
        cv_folds=5
        if method == "ls":
            hyperparameters = [f'{a}-{b}' for a in [0.2, 0.5, 0.9, 1] for b in range(1, 21)]
        elif method == "ld":
            hyperparameters=[str(a) for a in range(1,103)]
            base_rep = 102
            cv_folds=2
            n_reps = 3
        else:
            hyperparameters = ["0.00000005", "0.00G00001", "0.000001", "0.00001", "0.0001", "0.001", "0.005", "0.01",
                               "0.05", "0.1", "0.2", "0.3", "0.4", "0.5"]

        for cur_rep in range(1, n_reps + 1):
            rep = f"{base_rep}_{cur_rep}"
            aggregate_statistics_cv_params.append(
                [discoveries, targets, imps, method, hyperparameters, cv_folds, rep, f'{suffix}_{rep}'])
            aggregate_statistics_cv_mp(
                [discoveries, targets, imps, method, hyperparameters, cv_folds, rep, f'{suffix}_{rep}'])

    # with Pool(50) as p:
    #     print(p.map(aggregate_statistics_cv_mp, aggregate_statistics_cv_params))
