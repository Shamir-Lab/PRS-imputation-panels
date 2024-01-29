import os
import constants
import pandas as pd
import argparse

def aggregate_statistics(prs_names, imps, method, hyperparameters, suffix, type='mono', **kwargs):

    df_statistics_all=pd.DataFrame()
    df_or_all=pd.DataFrame()

    if type:
        type="."+type


    for prs_name in prs_names:
        for imp in imps:
            if type=="cross":
                path = os.path.join(constants.PRSS_PATH, prs_name, imp, f'cross_{kwargs["target_cross"]}', kwargs["imp_cross"])
            else:
                path = os.path.join(constants.PRSS_PATH, prs_name, imp)
            for hp in [hyperparameters[-1]]:
                fl_name=os.path.join(path,f"prs{type}.{method}.statistics.{hp}.tsv")
                if os.path.exists(fl_name):
                    df=pd.read_csv(fl_name, sep='\t')
                    df['imp']=imp
                    df['prs_name']=prs_name
                    df_statistics_all=pd.concat([df_statistics_all, df])
                else:
                    print(f'The file {fl_name} does not exist')


    for prs_name in prs_names:
        for imp in imps:
            if type=="cross":
                path = os.path.join(constants.PRSS_PATH, prs_name, imp, f'cross_{kwargs["target_cross"]}', kwargs["imp_cross"])
            else:
                path = os.path.join(constants.PRSS_PATH, prs_name, imp)
            for hp in hyperparameters:
                fl_name = os.path.join(path, f"prs{type}.{method}.or.summary.{hp}.tsv")
                if os.path.exists(fl_name):
                    df = pd.read_csv(fl_name, sep='\t')
                    df['imp'] = imp
                    df['prs_name']=prs_name
                    df_or_all = pd.concat([df_or_all, df])
                else:
                    print(f'The file {fl_name} does not exist')



    df_statistics_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs{type}.{method}.statistics_summary_{suffix}.tsv"), sep='\t')
    print(df_statistics_all)
    df_or_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"prs{type}.{method}.or_summary_{suffix}.tsv"), sep='\t')
    print(df_or_all)
