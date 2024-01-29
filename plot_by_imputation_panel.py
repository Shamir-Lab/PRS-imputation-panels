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

def plot_or_by_imputation(file_name_format, prs_names, discoveries, targets, imps, methods=['ls'], cols=3, metric="or.all", suffix=""): # 'pt3', 'pt2',

    in_file_full_path=os.path.join(constants.OUTPUT_PATH, file_name_format)
    print(f'read data from the file {in_file_full_path}')
    df_all=pd.read_csv(in_file_full_path, sep='\t')

    if imps is None:
        imps=df_all.loc[:,"imp"].unique()
        imps.sort()

    fig, axs = plt.subplots(2, 2,figsize=(35,30))
    df_all=df_all.loc[df_all.loc[:,"imp"].isin(imps),:]

    if not targets is None and not discoveries is None:
        df_all=df_all.loc[df_all.loc[:,'prs_name'].apply(lambda a :  a in [f'{d}_{t}' for d in discoveries for t in targets]),:]
    else:
        if not targets is None:
            df_all=df_all.loc[df_all.loc[:,'prs_name'].apply(lambda a : any([a.endswith(t) for t in targets])),:]
        if not discoveries is None:
            df_all=df_all.loc[df_all.loc[:,'prs_name'].apply(lambda a : any([a.startswith(d) for d in discoveries])),:]

    print(discoveries,targets)
    print(df_all)
    df_agg=pd.DataFrame()
    for i, method in enumerate(methods):
        df=df_all[df_all.loc[:,'method']==method]
        df['order']=df['imp'].apply(lambda a: imps.index(a))
        df=df.sort_values(by='order')
        ax=axs[i//2][i%2]

        ## X axis position defined by percentile intervals: e.g., converting string "20-30" to (20+30)/2
        df.loc[:,'x_values']=df.apply(lambda a: ",\n".join([d_imp_names[f'impute2_1kg_{b.split("_")[-1]}'] for b in targets]) if any([a["imp"].split("_")[-1] in t for t in targets]) else d_imp_names.get(a['imp'], a['imp']), axis=1)
        errors=np.hstack((df.loc[:,[f"{metric}_se_outer"]].values,df.loc[:,[f"{metric}_se_outer"]].values)).T
        baseline=df.loc[:,f'{metric}_mean_outer']
        # baseline[baseline<1.0]=np.nan
        df.loc[:,f'{metric}_mean_outer']=baseline
        df_agg=pd.concat((df_agg,df))
        # bar_order=[]
        # if "original" in df.loc[:,'x_values']:
        #     bar_order.append(d_imp_names['original'])
        # if "impute2_1kg_eur" in df.loc[:,'x_values']:
        #     bar_order.append(d_imp_names['impute2_1kg_eur'])
        # for a in df.loc[:,'x_values'].unique():
        #     if a not in bar_order:
        #         bar_order.append(a)

        if len(df.loc[:,'x_values'].unique()) == len(df.loc[:,"x_values"]):
            ax.errorbar(df.loc[:,'x_values'], df.loc[:,f"{metric}_mean_outer"], yerr=errors, capsize=10, fmt='-o', linestyle="None", marker='o', markersize=12)
            ax.set_xlim(ax.get_xlim()[0]-0.5,ax.get_xlim()[1]+0.5)
        else:
            # print(f"bar order: {bar_order}")
            sns.boxplot(x='x_values', y=f"{metric}_mean_outer", data=df, ax=ax, color=sns.color_palette('pastel')[0],  showfliers=False, showmeans=True, meanprops={"markersize":"14", "markerfacecolor": "red", "markeredgecolor": "red", "zorder": 10}) # , fmt='-o', linestyle="None", marker='o', markersize=12)
            sns.stripplot(x='x_values', y=f"{metric}_mean_outer", data=df, ax=ax, color='blue', s=12) # , fmt='-o', linestyle="None", marker='o', markersize=12)

            ax.set_ylim(ax.get_ylim()[0],df.loc[:,f'{metric}_mean_outer'].max()+0.1)
            i=0

            vals1=df.loc[df.loc[:,'imp'].values==df.loc[:,'prs_name'].apply(lambda a: f"impute2_1kg_{a.split('_')[-1]}").values]
            vals1.index=vals1.loc[:,'prs_name']
            vals1=vals1.loc[:,f'{metric}_mean_outer']

            for imp in imps:
                if imp.split("_")[-1] in [b.split("_")[-1] for b in targets]:
                    continue
                vals2=df.loc[df.loc[:,'imp']==imp]
                vals2.index=vals2.loc[:,'prs_name']
                vals2=vals2.loc[:,f'{metric}_mean_outer']

                df_diff=(vals1-vals2).dropna()
                if len(df_diff)!=0:
                    print(imp, vals1, vals2, sp.stats.wilcoxon(df_diff, alternative='greater').pvalue)
                    pval=sp.stats.wilcoxon(df_diff, alternative='greater').pvalue
                    # pval=sp.stats.binom_test(x=len([a for a in df_diff if a >0]), n=len(df_diff))
                    ax.text(i-0.25,df.loc[:,f'{metric}_mean_outer'].max()+0.05, f'{pval:.2e}')
                    i+=1


        plt.setp(ax.get_xticklabels(), rotation=35)
        ax.set_xlabel("imputation panels")
        ax.set_ylabel(d_metrics.get(metric,metric))
        ax.set_title(d_methods.get(method,method))
        # ax.legend()

    ####################
    if ax!=axs[-1][-1]:
        ax=axs[-1][-1]
        sns.boxplot(x='x_values', y=f"{metric}_mean_outer", data=df_agg, ax=ax, color=sns.color_palette('pastel')[0],  showfliers=False, showmeans=True, meanprops={"markersize":"14", "markerfacecolor": "red", "markeredgecolor": "red", "zorder": 10}) # , fmt='-o', linestyle="None", marker='o', markersize=12)
        sns.stripplot(x='x_values', y=f"{metric}_mean_outer", data=df_agg, ax=ax, color='blue', s=12) # , fmt='-o', linestyle="None", marker='o', markersize=12)
        mx=df_agg.loc[:,f'{metric}_mean_outer'].max()
        ax.set_ylim(ax.get_ylim()[0],0 if pd.isna(mx) else mx+0.1)
        ax.plot([-1,len(imps)-len(targets)], [0,0], linestyle='dashed', color='black') # , fmt='-o', linestyle="None", marker='o', markersize=12)


        vals1=df_agg.loc[df_agg.loc[:,'imp'].values==df_agg.loc[:,'prs_name'].apply(lambda a: f"impute2_1kg_{a.split('_')[-1]}").values]
        vals1.index=vals1.loc[:,'prs_name'] +"_"+ vals1.loc[:,'method']
        vals1=vals1.loc[:,f'{metric}_mean_outer']
        i=0
        for imp in imps[:-len(targets)]:
            if imp.split("_")[-1] in [b.split("_")[-1] for b in targets]:
                    continue
            vals2=df_agg.loc[df_agg.loc[:,'imp']==imp]
            vals2.index=vals2.loc[:,'prs_name'] +"_"+ vals2.loc[:,'method']
            vals2=vals2.loc[:,f'{metric}_mean_outer']
            df_diff=(vals1-vals2).dropna()
            if len(df_diff)!=0:
                pval=sp.stats.wilcoxon(df_diff, alternative='greater').pvalue
                # pval=sp.stats.binom_test(x=len([a for a in df_diff if a >0]), n=len(df_diff))
                print(pval)
                ax.text(i-0.25,df_agg.loc[:,f'{metric}_mean_outer'].max()+0.05, f'{pval:.2e}')
                i+=1
        plt.setp(ax.get_xticklabels(), rotation=35)
        ax.set_xlabel("imputation panels")
        ax.set_ylabel(d_metrics.get(metric,metric))
        ax.set_title('Combined')

    ##########

    plt.tight_layout() # subplots_adjust(right=0.7)

    # ax.legend() # (loc=(0.95,0))
    plt.savefig(os.path.join(constants.FIGURES_PATH, f"or_by_panel_{metric}_{suffix}.png"))

if __name__=='__main__':


    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-p', '--prs_names', dest='prs_names', help="", default="")
    parser.add_argument('-i', '--imps', dest='imps', help="", default="")
    parser.add_argument('-m', '--metric_name', dest='metric_name', help="", default="OR")
    parser.add_argument('-fn', '--file_name_format', dest='file_name_format', help="", default="prs.cv.choose_params_{}_{}.tsv") # prs.statistics_summary_{}.tsv
    parser.add_argument('-su', '--suffix', dest='suffix', help="", default="scz") # prs.statistics_summary_{}.tsv
    parser.add_argument('-b', '--base_rep', dest='base_rep', help="", default='105')
    parser.add_argument('-s', '--rep_start', dest='rep_start', help='', default='1')
    parser.add_argument('-e', '--rep_end', dest='rep_end', help="", default='6')

    args = parser.parse_args()
    prs_names=args.prs_names.split(',')
    imps=args.imps.split(',')
    metric_name = args.metric_name
    suffix = args.suffix
    base_rep = args.base_rep
    rep_start = args.rep_start
    rep_end = args.rep_end
    file_name_format = args.file_name_format
    field_name=metric_name


    # ### BC AJ
    # suffix="bc_aj"
    # discovery="bcac_onco_eur-5pcs"
    # target="bcac_onco_aj"
    # imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt','pt2','ls'], prs_names=prs_names, discoveries=[discovery], targets=[target], imps=imps_super_pop, suffix=suffix)
    #
    # ### EAS BC AJ
    # suffix="bc_aj_eas"
    # discovery="GC_bc_sakaue_2020"
    # target="bcac_onco_aj"
    # imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt','pt2','ls'], prs_names=prs_names, discoveries=[discovery], targets=[target], imps=imps_super_pop, suffix=suffix)
    #
    # ### EAS BC AJ LS
    # suffix_out="bc_aj_eas_ls"
    # discovery="GC_bc_sakaue_2020_LS"
    # target="bcac_onco_aj"
    # imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['ls'], prs_names=prs_names, discoveries=[discovery], targets=[target], imps=imps_super_pop, suffix=suffix_out)
    #
    # ### SCZ AJ
    # suffix="scz_aj"
    # discovery="PGC2_noAJ"
    # target="dbg-scz19"
    # imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    # plot_or_by_imputation(file_name_format.format("scz", f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt','pt2','ls'], prs_names=prs_names, discoveries=[discovery], targets=[target], imps=imps_super_pop, suffix=suffix)
    #
    # ### EAS SCZ AJ
    # suffix="scz_aj_eas"
    # discovery="LH_PGC-SCZ-EAS"
    # target="dbg-scz19"
    # imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt','pt2','ls'], prs_names=prs_names, discoveries=[discovery], targets=[target], imps=imps_super_pop, suffix=suffix)
    #
    # ### EAS SCZ AJ LS
    # suffix_out="scz_aj_eas_ls"
    # discovery="LH_PGC-SCZ-EAS_LS"
    # target="dbg-scz19"
    # imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['ls'], prs_names=prs_names, discoveries=[discovery], targets=[target], imps=imps_super_pop, suffix=suffix_out)




    ### SCZ
    suffix="scz"
    discovery="PGC2_noAJ"
    target="dbg-scz19"
    imps_super_pop=["impute2_ajkg14_t101", "impute2_1kg_eur2", "impute2_1kg_eur-ajkg14-t101-merged", "impute2_1kg_eas2", "impute2_1kg_afr2"]
    imps_pop=["impute2_ajkg14_t101",  "impute2_1kg_ceu2", "impute2_1kg_gbr2", "impute2_1kg_tsi2", "impute2_1kg_ibs2", "impute2_1kg_fin2"] # , "impute2_1kg_eur2" , "impute2_1kg_eur-ajkg14-t101-merged"
    imps_comp=["impute2_ajkg14_t101",  "impute2_1kg_eur2", "impute2_1kg_eur-ajkg14-t101-merged"]

    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt','pt2','ls','ld'], prs_names=prs_names, discoveries=[discovery], targets=['dbg-scz19'], imps=imps_super_pop, suffix="scz_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt3','pt2','ls', 'ld'], prs_names=prs_names, discoveries=[discovery],  targets=['dbg-scz19'], imps=imps_pop, suffix="scz_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), methods=['pt','pt2','ls'], prs_names=prs_names, discoveries=[discovery],  targets=['dbg-scz19'], imps=imps_comp, suffix="scz_comp")

    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, targets=['dbg-scz19'], imps=imps_super_pop, metric="99", suffix="super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, targets=['dbg-scz19'], imps=imps_pop, metric="99", suffix="pop")


    # ### SCZ GAIN
    # suffix="scz_gain"
    # target="gain_afr"
    # discoveries=["PGC2_noAJ"]
    # imps_super_pop=["impute2_1kg_eur", "impute2_1kg_afr"]
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, suffix="super_pop")
    # # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, targets=[target], imps=imps_super_pop, metric="99", suffix="super_pop")


    ### UKB: public_GWAS
    suffix="public_gwas"
    discoveries=["D2_t2di_mahajan_2018", "D2_sysp_evangelou_2018", "D2_chol_willer_2013"  ,"D2_gerx_an_2019" ,"D2_madd_howard_2019"] # , "D2_t2di_mahajan_2018" ,"D2_gerx_an_2019","D2_madd_howard_2019", "D2_chol_willer_2013", "D2_sysp_evangelou_2018"]# "D2_asth_zhu_2019" , "D2_sysp_evangelou_2018", "D2_dias_evangelou_2018"]  ,"D2_ldlp_willer_2013"

    target="ukbb_afr"
    imps_super_pop=["original", "impute2_1kg_eur", "impute2_1kg_afr"] # , "imputeX_new"
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, suffix=f"{target}_{suffix}_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries,targets=[target], imps=imps_super_pop, metric="99", suffix=f"{target}_{suffix}_super_pop")

    target="ukbb_sas"
    imps_super_pop=["original", "impute2_1kg_eur", "impute2_1kg_sas"] # , "imputeX_new"
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries,targets=[target], imps=imps_super_pop, suffix=f"{target}_{suffix}_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries,targets=[target], imps=imps_super_pop, metric="99", suffix=f"{target}_{suffix}_super_pop")

    targets=["ukbb_sas", "ukbb_afr"]
    imps_super_pop=["original", "impute2_1kg_eur", "impute2_1kg_sas", "impute2_1kg_afr"] # , "imputeX_new"
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries,targets=targets, imps=imps_super_pop, suffix=f"all_{suffix}_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries,targets=[target], imps=imps_super_pop, metric="99", suffix=f"all_pop_{suffix}_super_pop")
    
    # ### UKB: UKB GWAS
    # suffix="ukb_gwas"
    # discoveries=["UKB_ht_eur","UKB_chol_eur","UKB_hfvr_eur","UKB_hyty_eur","UKB_madd_eur","UKB_osar_eur","UKB_t2d_eur","UKB_utfi_eur","UKB_gerx_eur","UKB_angna_eur","UKB_ast_eur","UKB_ctrt_eur"]
    #
    # target="ukbb_afr"
    # imps_super_pop=["original", "impute2_1kg_eur", "impute2_1kg_afr"] # , "imputeX_new"
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, suffix=f"{target}_{suffix}_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, metric="99", suffix=f"{target}_{suffix}_super_pop")
    #
    # target="ukbb_sas"
    # imps_super_pop=["original", "impute2_1kg_eur", "impute2_1kg_sas"] # , "imputeX_new"
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, suffix=f"{target}_{suffix}_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, metric="99", suffix=f"{target}_{suffix}_super_pop")
    #
    # targets=["ukbb_sas", "ukbb_afr"]
    # imps_super_pop=["original", "impute2_1kg_eur", "impute2_1kg_sas", "impute2_1kg_afr"] #
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=targets, imps=imps_super_pop, suffix=f"all_{suffix}_super_pop")
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, metric="99", suffix=f"{target}_{suffix}_super_pop")

    # discoveries = ["GC_sysp_sakaue_2021", "GC_gerx_sakaue_2021", "GC_hyty_sakaue_2021", "GC_ctrt_sakaue_2021",
    #                "GC_hfvr_sakaue_2021", "GC_t2d_sakaue_2021", "GC_chol_sakaue_2021", "GC_ast_sakaue_2021",
    #                "GC_madd_sakaue_2021", "GC_angna_sakaue_2021"] # , "GC_utfi_sakaue_2021" , "GC_osar_sakaue_2021"

    discoveries = ["UKB_ht_eur", "UKB_chol_eur", "UKB_hfvr_eur", "UKB_hyty_eur", "UKB_madd_eur", "UKB_osar_eur",
                   "UKB_t2d_eur", "UKB_utfi_eur", "UKB_gerx_eur", "UKB_angna_eur", "UKB_ast_eur", "UKB_ctrt_eur"]


    # target = "ukbb_afr" # , "ukbb_sas"] # "ukbb_sas",
    # imps_super_pop = ["original", "impute2_1kg_eur", "impute2_1kg_afr"]  # , "imputeX_new"
    # suffix = "gc_eas"
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, methods=['pt2', 'pt3', 'ls'], suffix=f"{target}_{suffix}_super_pop")

    # target = "ukbb_sas" # "ukbb_sas",
    # imps_super_pop = ["original", "impute2_1kg_eur", "impute2_1kg_sas"] # ["impute2_1kg_eur", "impute2_1kg_eur100"] # ["original", "impute2_1kg_eur", "impute2_1kg_eur100", "impute2_1kg_sas"]  # , "imputeX_new"
    # suffix = "ukb_eur"
    # methods=['ld'] # ['pt2', 'pt3', 'ls']
    # plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, methods=methods, suffix=f"{target}_{suffix}_super_pop")

    target = "ukbb_sas" # "ukbb_sas",
    imps_super_pop = ["original", "impute2_1kg_eur", "impute2_1kg_sas"] # ["impute2_1kg_eur", "impute2_1kg_eur100"] # ["original", "impute2_1kg_eur", "impute2_1kg_eur100", "impute2_1kg_sas"]  # , "imputeX_new"
    suffix = "ukb_eur_ld"
    methods = ['ld'] # ['pt2', 'pt3', 'ls']
    base_rep = 102 # 105
    rep_start = 1
    rep_end = 3 # 6
    plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'), prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop, methods=methods, suffix=f"{target}_{suffix}_super_pop")

    target = "ukbb_afr"  # "ukbb_sas",
    imps_super_pop = ["original", "impute2_1kg_eur", "impute2_1kg_afr"]  # ["impute2_1kg_eur", "impute2_1kg_eur100"] # ["original", "impute2_1kg_eur", "impute2_1kg_eur100", "impute2_1kg_sas"]  # , "imputeX_new"
    suffix = "ukb_eur"
    methods = ['pt2', 'pt3', 'ls']
    base_rep = 105
    rep_start = 1
    rep_end = 6
    plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'),
                          prs_names=prs_names, discoveries=discoveries, targets=[target], imps=imps_super_pop,
                          methods=methods, suffix=f"{target}_{suffix}_super_pop")

    targets = ["ukbb_afr", "ukbb_sas"] # "ukbb_sas",
    imps_super_pop = ["original", "impute2_1kg_eur", "impute2_1kg_afr", "impute2_1kg_sas"]  # , "imputeX_new"
    suffix = "ukb_eur"
    methods = ['pt2', 'pt3', 'ls']
    base_rep = 105
    rep_start = 1
    rep_end = 6
    plot_or_by_imputation(file_name_format.format(suffix, f'{base_rep}_{rep_start}_{base_rep}_{rep_end}'),
                          prs_names=prs_names, discoveries=discoveries, targets=targets, imps=imps_super_pop,
                          methods=methods, suffix=f"all_{suffix}_super_pop")
