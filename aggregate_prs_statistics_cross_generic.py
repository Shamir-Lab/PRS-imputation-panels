import os

import pandas as pd

import constants
import utils


def aggregate_statistics_cross(prs_names, imps, method, hyperparameters, cv_folds, rep, suffix):
    df_statistics_all=pd.DataFrame()
    df_statistics_test=pd.DataFrame()
    df_or_all=pd.DataFrame()
    df_or_test=pd.DataFrame()

    cv_ids=[f"{a}_{cv_folds}_validation" for a in range(1,cv_folds+1)]

    for prs_name in prs_names:
        for imp in imps:
            path = os.path.join(constants.PRSS_PATH, prs_name, imp, f"rep_{rep}")
            for hp in hyperparameters:
                fl_name=os.path.join(path,f"prs.cv.{method}___{cv_folds}_test.statistics.{hp}.tsv")
                if os.path.exists(fl_name):
                    df=pd.read_csv(fl_name, sep='\t')
                    df['imp']=imp
                    df['prs_name']=prs_name
                    df_statistics_test=pd.concat([df_statistics_test, utils.fix_table(df)])

                for cv_suffix in cv_ids:
                    fl_name=os.path.join(path,f"prs.cv.{method}___{cv_suffix}.statistics.{hp}.tsv")
                    if os.path.exists(fl_name):
                        df=pd.read_csv(fl_name, sep='\t')
                        df['imp']=imp
                        df['prs_name']=prs_name
                        df_statistics_all=pd.concat([df_statistics_all, utils.fix_table(df)])


    for prs_name in prs_names:
        for imp in imps:
            path = os.path.join(constants.PRSS_PATH, prs_name, imp, f"rep_{rep}")
            for hp in hyperparameters:
                fl_name = os.path.join(path, f"prs.cv.{method}___{cv_folds}_test.or.summary.{hp}.tsv")
                if os.path.exists(fl_name):
                    df = pd.read_csv(fl_name, sep='\t')
                    df['imp'] = imp
                    df['prs_name']=prs_name
                    df_or_test = pd.concat([df_or_test, utils.fix_table(df)])

                for cv_suffix in cv_ids:
                    fl_name = os.path.join(path, f"prs.cv.{method}___{cv_suffix}.or.summary.{hp}.tsv")
                    if os.path.exists(fl_name):
                        df = pd.read_csv(fl_name, sep='\t')
                        df['imp'] = imp
                        df['prs_name']=prs_name
                        df_or_all = pd.concat([df_or_all, utils.fix_table(df)])


    df_statistics_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.statistics_summary_{suffix}.tsv"), sep='\t')
    df_or_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.or_summary_{suffix}.tsv"), sep='\t')
    df_statistics_test.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.test.statistics_summary_{suffix}.tsv"), sep='\t')
    df_or_test.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs.cv.{method}.test.or_summary_{suffix}.tsv"), sep='\t')


    print(df_statistics_all)
    print(df_or_all)

