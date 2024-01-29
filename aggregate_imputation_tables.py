import argparse
import os

import matplotlib
import constants
import scipy as sp

matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
pd.options.mode.chained_assignment = None
import seaborn as sns
cs = sns.color_palette("bright") + sns.color_palette("pastel")
font = {'size' : 40}
matplotlib.rc('font', **font)
from name_mappings import *


def aggregate_tables(df_names):
    df_agg=pd.DataFrame()
    for df_name in df_names:
        df=pd.read_csv(os.path.join(constants.OUTPUT_PATH, df_name),sep='\t')
        df["OR per 1SD"]=df.apply(lambda row: f'{round(row["mean"],2)}+-{round(row["se"],3)}', axis=1)
        df['Target set']=df_name[len('or_by_panel_all_'):].split('_public')[0]
        df_agg=pd.concat((df_agg,df))

    print(os.path.join(constants.OUTPUT_PATH, f"or_by_panel_all.tsv"))
    df_agg['method']=df['method'].apply(lambda a: d_methods[a])
    df_agg['Target set']=df_agg['Target set'].apply(lambda a: d_target_names[a])
    df_agg['x_values']=df_agg['x_values'].apply(lambda a: a.replace('\n', ' '))
    df_agg=df_agg.rename(columns={'x_values':'Imputation panel', 'method': 'Method'})
    df_agg.loc[:,['Method','Imputation panel','Target set','OR per 1SD']].to_csv(os.path.join(constants.OUTPUT_PATH, f"or_by_panel_all.tsv"),sep='\t', index=False) 



if __name__=='__main__':
    df_names=['or_by_panel_all_all_public_gwas_super_pop.tsv', 'or_by_panel_all_ukbb_sas_public_gwas_super_pop.tsv', 'or_by_panel_all_ukbb_afr_public_gwas_super_pop.tsv']
    aggregate_tables(df_names)

