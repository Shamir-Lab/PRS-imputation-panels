import itertools
import os

import matplotlib

import constants

matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
pd.options.mode.chained_assignment = None
from name_mappings import *
cs = sns.color_palette("bright") + sns.color_palette("pastel")
font = {'size': 30}
matplotlib.rc('font', **font)
import utils


def aggregate_folds_cv_multi_test(fname, field_names, discoveries, targets, imps, out_suffix, rep_start, rep_end):

    df=pd.DataFrame()
    df_test=pd.DataFrame(columns=['prs_name', 'imp', 'hp'])
    start=int(rep_start.split("_")[1] if "_" in rep_start else rep_start)
    end=int(rep_end.split("_")[1] if "_" in rep_end else rep_end)
    for rep in range(start,end+1):

        suffix=("_"+rep_start.split("_")[0]+"_"+str(rep) if "_" in rep_start else "_"+str(rep))
        print("fetch aggregated rep file: ", fname.format("",suffix))
        cur_df=pd.read_csv(os.path.join(constants.OUTPUT_PATH, fname.format("",suffix)), sep='\t') #.ctrl 1st arg
        cur_df['rep'] = rep
        df=pd.concat((df,cur_df))
        cur_df_test=pd.read_csv(os.path.join(constants.OUTPUT_PATH, fname.format(".test",suffix)), sep='\t') #.ctrl
        cur_df_test['rep'] = rep
        df_test=pd.concat((df_test,cur_df_test))


    out_file_name=f"{'.'.join(fname.format('','').split('.')[:3])}_{out_suffix}_{rep_start}_{rep_end}" # ctrl 1st arg
    prs_names=[f'{a}_{b}' for a, b in itertools.product(discoveries, targets)]
    aggregate_folds_cv_test(field_names, prs_names, imps, df, df_test, out_file_name)


def aggregate_folds_cv_single_test(fname, field_names, discoveries, targets, imps, out_suffix, rep_start, rep_end, hyperparameters):

    print("fetch aggregated file: ", os.path.join(constants.OUTPUT_PATH, fname.format("",""))) # .ctrl (1st arg)

    df=pd.read_csv(os.path.join(constants.OUTPUT_PATH, fname.format("","")), sep='\t') # .ctrl (1st arg)
    df_test=pd.read_csv(os.path.join(constants.OUTPUT_PATH, fname.format(".test","")), sep='\t') # .ctrl 1st arg suffix

    out_file_name=f"{'.'.join(fname.format('','').split('.')[:2])}_{out_suffix}" # ctrl (1st arg)
    prs_names=[f'{a}_{b}' for a, b in itertools.product(discoveries, targets)]
    aggregate_folds_cv_test(field_names, prs_names, imps, rep_start, rep_end, hyperparameters, df, df_test, out_file_name)

def aggregate_folds_cv_test(field_names, prs_names, imps, df, df_test, out_file_name, folds=5):

    if imps is None:
        imps=df.loc[:,"imp"].unique()
        imps.sort()

    if prs_names is None:
        prs_names=df.loc[:,"prs_name"].unique()
        prs_names.sort()

    if len(df_test)>0:
        df_test.index=np.arange(len(df_test))
        df_test=df_test.sort_values(by='hp')
        df_test.loc[:,'test_type']='test'

    df_all=pd.DataFrame()
    for i, prs_name in enumerate(prs_names):
        for j, imp in enumerate(imps):
            cur_df=df.loc[(df.loc[:,'prs_name']==prs_name) & (df.loc[:,'imp']==imp)]
            for field_name in field_names:
                cur_df[field_name]=cur_df[field_name].astype(float)
            print(prs_name, imp, cur_df.shape)
            grp_by_hp=cur_df.groupby(['rep', 'hp'])
            aggs=[]
            for field_name in field_names:
                aggs.append(grp_by_hp[field_name].mean().rename(f'{field_name}_mean'))
                aggs.append(grp_by_hp[field_name].median().rename(f'{field_name}_median'))
                aggs.append(grp_by_hp[field_name].std().rename(f'{field_name}_sd') / np.sqrt(folds))
            aggs.append(grp_by_hp[field_names[0]].count().rename(f'n_{field_names[0]}'))
            n_snps_mns=grp_by_hp['n_snps'].mean().rename('n_snps_mean')
            n_snps_sd=grp_by_hp['n_snps'].std().rename('n_snps_sd')/np.sqrt(folds)

            cur_all=pd.concat(aggs + [n_snps_mns, n_snps_sd], axis=1)
            if len(cur_df)==0:
                continue

            cur_df.loc[:,'test_type']='validation'
            cur_df.loc[:,'prs_name']=prs_name

            cur_df.loc[:,'imp']=imp
            if len(df_test)!=0:
                cur_df_test=df_test.loc[(df_test.loc[:,'prs_name']==prs_name) &(df_test.loc[:,'imp']==imp)]
                grp_by_hp = cur_df_test.groupby(['rep', 'hp'])
                aggs_test=[]
                for field_name in field_names: # .reindex(mns.index)
                    aggs_test.append(grp_by_hp[field_name].mean().rename(f'{field_name}_test'))
                n_snps_mns_test = grp_by_hp['n_snps'].mean().rename('n_snps_test')

                cur_df=pd.concat(aggs+[n_snps_mns, n_snps_sd]+aggs_test+[n_snps_mns_test], axis=1)
            else:
                cur_df=cur_all

            cur_df['prs_name']=prs_name
            cur_df['imp']=imp
            df_all=pd.concat((df_all, cur_df))

    df_all['rep']=df_all.index.get_level_values(0)
    df_all['hp'] = df_all.index.get_level_values(1)
    df_all.index=df_all['rep'].astype(str)+"_"+ df_all['hp'].astype(str)

    df_all.to_csv(os.path.join(constants.OUTPUT_PATH, f"{out_file_name}.tsv"), sep='\t')