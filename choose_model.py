import os

import numpy as np
import pandas as pd

import constants


def choose_model(methods, rep_start, rep_end, metrics, suffix):

    df_metrics=pd.DataFrame()

    output_fname=f"prs.cv.choose_params_{'' if suffix=='' else suffix+'_'}{rep_start}_{rep_end}.tsv"
    base_rep=rep_start.split("_")[0]
    rep_start=int(rep_start.split("_")[1])
    rep_end=int(rep_end.split("_")[1])

    for method in methods:
        df_method=pd.DataFrame()
        fl_name = os.path.join(constants.OUTPUT_PATH, f'prs.cv.{method}_{suffix}_{base_rep}_{rep_start}_{base_rep}_{rep_end}.tsv')
        # fl_name_or_99 = os.path.join(constants.OUTPUT_PATH, f'prs.cv.{method}_or_99_{suffix}_{base_rep}_{cur_rep}_{base_rep}_{cur_rep}.tsv')
        print(f'fl_name_or: {fl_name}')
        if os.path.exists(fl_name):
            df_all = pd.read_csv(fl_name, sep='\t', index_col=0)
            print("exists: ", fl_name)

            for cur_rep in range(rep_start, rep_end+1):

                sets=df_all.groupby(['prs_name','imp','rep']).count().index

                for prs_name,imp,rep in sets:
                    df_filtered=df_all[(df_all.loc[:,'prs_name']==prs_name) & (df_all.loc[:,'imp']==imp) & (df_all.loc[:,'rep']==rep)]
                    df_filtered.index = df_filtered.apply(lambda a: f"{method}_{cur_rep}_{a['hp']}_{a['prs_name']}_{a['imp']}", axis=1)
                    df_filtered=df_filtered.sort_values(by=[f"{metrics[0]}_mean"], ascending=False)
                    df_filtered.loc[:,f'{metrics[0]}_order']=np.arange(1,df_filtered.shape[0]+1) * 0.99
                    df_filtered=df_filtered.sort_values(by=[f"{metrics[1]}_mean"], ascending=False)
                    df_filtered.loc[:,f'{metrics[1]}_order']=np.arange(1,df_filtered.shape[0]+1)
                    idx=(df_filtered.loc[:,f'{metrics[0]}_order'] +df_filtered.loc[:,f'{metrics[1]}_order']).idxmin() # +df_99_filtered.loc[:,'order']
                    # df_all.loc[idx]
                    # df_99.loc[idx]
                    print(df_filtered.loc[idx].to_frame().T)
                    df_method = pd.concat((df_method,  df_filtered.loc[idx].to_frame().T),axis=0)
                    # print(df_method_or_99)
                    # print(df_99.loc[idx])



            print(fl_name)
        aggs=[]
        for metric in metrics:
            df_method.loc[:,f'{metric}_mean']=df_method.loc[:,f'{metric}_mean'].astype(float)
            df_method.loc[:,f'{metric}_test']=df_method.loc[:,f'{metric}_test'].astype(float)
            aggs.append(df_method.groupby(['prs_name','imp'])[f"{metric}_mean"].mean().rename(f"{metric}_mean_inner"))
            aggs.append(df_method.groupby(['prs_name','imp'])[f"{metric}_mean"].std().rename(f"{metric}_se_inner"))
            aggs.append(df_method.groupby(['prs_name', 'imp'])[f"{metric}_mean"].count().rename(f"{metric}_n"))

            aggs.append(df_method.groupby(['prs_name','imp'])[f"{metric}_test"].mean().rename(f"{metric}_mean_outer"))
            aggs.append((df_method.groupby(['prs_name','imp'])[f"{metric}_test"].std()/np.sqrt(rep_end-rep_start)).rename(f"{metric}_se_outer"))
            aggs.append(df_method.groupby(['prs_name','imp'])[f"{metric}_test"].count().rename(f"{metric}_n"))
            # n_snps_mean_outer_all=df_method_or_all.groupby(['prs_name','imp'])["n_snps_mean_test"].mean().rename("n_snps_mean_outer_all")
            # n_snps_median_outer_all=df_method_or_all.groupby(['prs_name','imp'])["n_snps_mean_test"].median().rename("n_snps_median_outer_all")
            # n_snps_se_outer_all=(df_method_or_all.groupby(['prs_name','imp'])["n_snps_mean_test"].std()/np.sqrt(rep_end-rep_start)).rename("n_snps_se_outer_all")
            #df_cur_or_all=pd.concat([mean_inner_all, se_inner_all, n_snps_mean_inner_all, n_snps_se_inner_all, n_snps_median_inner_all, mean_outer_all, se_outer_all, n_snps_mean_outer_all, n_snps_se_outer_all, n_snps_median_outer_all], axis=1)
        df_cur_metrics=pd.concat(aggs, axis=1)
        df_cur_metrics.loc[:,'method']=method
        df_metrics=pd.concat([df_metrics, df_cur_metrics])

            # df_method_or_99.loc[:,'mean']=df_method_or_99.loc[:,'mean'].astype(float)
            # df_method_or_99.loc[:,'mean_test']=df_method_or_99.loc[:,'mean_test'].astype(float)
            #
            # mean_inner_99=df_method_or_99.groupby(['prs_name','imp'])["mean"].mean().rename("mean_inner_99")
            # se_inner_99=df_method_or_99.groupby(['prs_name','imp'])["mean"].std().rename("se_inner_99")
            # mean_outer_99=df_method_or_99.groupby(['prs_name','imp'])["mean_test"].mean().rename("mean_outer_99")
            # se_outer_99=(df_method_or_99.groupby(['prs_name','imp'])["mean_test"].std()/np.sqrt(rep_end-rep_start)).rename("se_outer_99")
            # # print(rep_end-rep_start)
            # df_cur_or_99=pd.concat([mean_inner_99, se_inner_99, mean_outer_99, se_outer_99], axis=1)
            # df_cur_or_99.loc[:,'method']=method
            # df_or_99=pd.concat([df_or_99, df_cur_or_99])

    # df_or_all.loc[:,'prs_name']=[a[0] for a in df_or_all.index]
    # df_or_all.loc[:,'imp']=[a[1] for a in df_or_all.index]
    # df_or_99.loc[:,'prs_name']=[a[0] for a in df_or_99.index]
    # df_or_99.loc[:,'imp']=[a[1] for a in df_or_99.index]

    output_fname_full_path=os.path.join(constants.OUTPUT_PATH, output_fname)
    df_metrics.to_csv(os.path.join(constants.OUTPUT_PATH, output_fname), sep='\t')
    print(f'results are saved in {output_fname_full_path}')

if __name__=='__main__':
    methods=["ld"] # ["pt2", "pt3", "ls", "ld"] #"pt2","ls","ld"]
    rep_start="102_1"
    rep_end="102_3"
    suffix="ukb_eur" # "bcac_minus_pl_pl_ctrl"
    metrics=['or.all','or.90']
    choose_model(methods, rep_start, rep_end, metrics, suffix)
