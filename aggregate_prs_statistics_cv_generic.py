import os

import pandas as pd

import constants
import utils
import itertools


def fetch_n_snps(discovery, method, pheno, cv_suffix, hp, path):
    if method == 'ls':
        n_snps = 0
        # snp_file=os.path.join(path, 'lasso',f'prs.cv.{method}___{cv_suffix}.{hp}.weights')
        # # print(snp_file)
        # weights = pd.read_csv(snp_file, header=None, sep='\t')
        # # print(weights.iloc[:, -1])
        # weights = weights.loc[weights.iloc[:, -1] > 0]
        # n_snps=len(weights)
    elif method == 'ld':
        n_snps = 0
        # snp_file=os.path.join(path, 'ldpred',f'prs.cv.{method}___{cv_suffix}.{hp}.weights')
        # weights=pd.read_csv(snp_file, header=None, sep='\t')
        # weights=weights.loc[weights.iloc[:,-1]>0]
        # n_snps=len(weights)
    elif method == 'pt3':
        n_snps = 0
        # snp_pvalue_file=os.path.join(constants.GWASS_PATH, discovery, 'SNP.pvalue')
        # df_snp_pvalue=pd.read_csv(snp_pvalue_file, sep=' ', index_col=0)
        # snp_file=os.path.join(path, f'prs.cv.{method}{"" if pheno=="" else "_"+pheno}__eas_ld.valid.snp') # eur
        # df_snp=pd.read_csv(snp_file, header=None)
        # df_relevant_snps=df_snp_pvalue.reindex(df_snp.iloc[:,0])
        # n_snps=len(df_relevant_snps.loc[df_relevant_snps.iloc[:,0]<=float(hp)])
    elif method == 'pt2':
        n_snps = 0
        # snp_pvalue_file=os.path.join(constants.GWASS_PATH, discovery, 'SNP.pvalue')
        # df_snp_pvalue=pd.read_csv(snp_pvalue_file, sep=' ', index_col=0)
        # snp_file=os.path.join(path, f'prs.cv.{method}{"" if pheno=="" else "_"+pheno}__{cv_suffix}.valid.snp') # eur
        # df_snp=pd.read_csv(snp_file, header=None)
        # df_relevant_snps=df_snp_pvalue.reindex(df_snp.iloc[:,0])
        # n_snps=len(df_relevant_snps.loc[df_relevant_snps.iloc[:,0]<=float(hp)])

    else:
        raise ValueError(f"Cannot count # of SNPs for method {method}")

    # print(f'discovery={discovery}, method={method}, pheno={pheno}, cv_suffix={cv_suffix}, hp={hp} n_snps: {n_snps}')

    return n_snps


def aggregate_statistics_cv_mp(args):
    discoveries, targets, imps, method, hyperparameters, cv_folds, rep, suffix = args
    aggregate_statistics_cv(discoveries, targets, imps, method, hyperparameters, cv_folds, rep, suffix)


def aggregate_statistics_cv(discoveries, targets, imps, method, hyperparameters, cv_folds, rep, suffix):
    df_statistics_all = pd.DataFrame()
    df_statistics_test = pd.DataFrame()
    cv_ids = [f"{a}_{cv_folds}_validation" for a in range(1, cv_folds + 1)]

    for i, discovery in enumerate(discoveries):
        for target in targets:
            prs_name = f'{discovery}_{target}'
            pheno = constants.gwas_to_pheno.get(discoveries[i], "")
            for imp in imps:
                path = os.path.join(constants.PRSS_PATH, prs_name, imp, f"rep_{rep}")
                fl_name = os.path.join(path, f"prs.cv.{method}_{pheno}__{cv_folds}_test.statistics.tsv")  # .{hp} .ctrl
                if os.path.exists(fl_name):
                    if os.stat(fl_name).st_size < 2:
                        print(f'File {fl_name}  is empty. Removing..')
                        os.remove(fl_name)
                    else:
                        df = pd.read_csv(fl_name, sep='\t')
                        df['imp'] = imp
                        df['prs_name'] = prs_name
                        for hp in hyperparameters:
                            n_snps = fetch_n_snps(discovery, method, pheno, f'{cv_folds}_both', hp, path)
                            try:
                                df.loc[df['hp'] == hp, 'n_snps'] = n_snps
                            except Exception as e:
                                print(fl_name)
                                continue

                        df_statistics_test = pd.concat([df_statistics_test, df])

                    for cv_i, cv_suffix in enumerate(cv_ids):
                        fl_name = os.path.join(path,
                                               f"prs.cv.{method}_{pheno}__{cv_suffix}.statistics.tsv")  # .{hp} .ctrl
                        if os.path.exists(fl_name):
                            if os.stat(fl_name).st_size <= 1:
                                print(f'File {fl_name}  is empty. Removing..')
                                os.remove(fl_name)
                            else:
                                df = pd.read_csv(fl_name, sep='\t')
                                df['imp'] = imp
                                df['prs_name'] = prs_name
                                df['fold'] = cv_i + 1
                                for hp in hyperparameters:
                                    n_snps = fetch_n_snps(discovery, method, pheno,
                                                          cv_suffix.replace('validation', 'train'), hp, path)
                                    try:
                                        df.loc[df['hp'] == hp, 'n_snps'] = n_snps
                                    except Exception as e:
                                        print(fl_name)
                                        continue

                                df_statistics_all = pd.concat([df_statistics_all, df])
                        else:
                            print('warning:', fl_name, 'was not found')
                else:
                    print('warning:', fl_name, 'was not found')

    #     for i, discovery in enumerate(discoveries):
    #         for target in targets:
    #             prs_name= f'{discovery}_{target}'
    #             pheno=constants.gwas_to_pheno.get(discoveries[i],"")
    #             for imp in imps:
    #                 path = os.path.join(constants.PRSS_PATH, prs_name, imp, f"rep_{rep}")
    #                 for hp in hyperparameters:
    #                     fl_name = os.path.join(path, f"prs.cv.{method}_{pheno}__{cv_folds}_test.summary.tsv") # .ctrl .{hp}
    #                     if os.path.exists(fl_name):
    #                         if os.stat(fl_name).st_size == 0:
    #                             print(f'File {fl_name}  is empty. Removing..')
    #                             os.remove(fl_name)
    #                         else:
    #                             n_snps=fetch_n_snps(discovery, method, pheno, f'{cv_folds}_both', hp, path)
    #                             df = pd.read_csv(fl_name, sep='\t')
    #                             df['imp'] = imp
    #                             df['prs_name']=prs_name
    #                             df['n_snps']=n_snps
    #                             df_or_test = pd.concat([df_or_test, utils.fix_table(df)])
    # #                             print("or test")
    # #                             print(df_or_test)
    #                     else:
    #                             print('warning:', fl_name, 'was not found')
    #
    #                     for cv_i, cv_suffix in enumerate(cv_ids):
    #                         fl_name = os.path.join(path, f"prs.cv.{method}_{pheno}__{cv_suffix}.summary.tsv") # .or .ctrl .{hp}
    # #                         print(fl_name)
    #                         if os.path.exists(fl_name):
    #                             if os.stat(fl_name).st_size == 0:
    #                                 print(f'File {fl_name}  is empty. Removing..')
    #                                 os.remove(fl_name)
    #                             else:
    #                                 n_snps=fetch_n_snps(discovery, method, pheno, cv_suffix.replace('validation','train'), hp, path)
    #                                 df = pd.read_csv(fl_name, sep='\t')
    #                                 df['imp'] = imp
    #                                 df['prs_name']=prs_name
    #                                 df['fold']=cv_i+1
    #                                 df['n_snps']=n_snps
    #                                 df_or_all = pd.concat([df_or_all, utils.fix_table(df)])
    # #                                 print("or train")
    # #                                 print(df_or_all)
    #                         else:
    #                             print('warning:', fl_name, 'was not found')

    df_statistics_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.statistics_summary_{suffix}.tsv"),
                             sep='\t')  # .ctrl
    # df_or_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.or_summary_{suffix}.tsv"), sep='\t') # .ctrl
    df_statistics_test.to_csv(
        os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.test.statistics_summary_{suffix}.tsv"), sep='\t')  # .ctrl
    # df_or_test.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.test.or_summary_{suffix}.tsv"), sep='\t') # .ctrl

    print(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.or_summary_{suffix}.tsv"))
    print("df_statistics_all", df_statistics_all.shape)

    print(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.test.or_summary_{suffix}.tsv"))
    print("df_statistics_test", df_statistics_test.shape)
