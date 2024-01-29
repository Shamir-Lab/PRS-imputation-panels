import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import constants
import seaborn as sns
sns.set_style('white')
sns.set_style('ticks')
import os
import argparse
import functools
import matplotlib
matplotlib.rcParams["xtick.labelsize"]=22
matplotlib.rcParams["ytick.labelsize"]=22
matplotlib.use('Agg') 
if __name__=='__main__':    
  
    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-t', '--target', dest='targets',  default="hadassa", help='')
    parser.add_argument('-r', '--ref_dataset', dest='ref_dataset',  default="bcac_onco_eur/impX_new", help='')
    parser.add_argument('-p', '--pop_type', dest='pop_type', default="pop", help='')    
    parser.add_argument('-i', '--imp', dest='imp', default="impute2_1kg_eur-multi", help='')
    parser.add_argument('-ep', '--excluded_pop', dest='excluded_pop', default="", help='')   # UR,BEB,PJL,MSL,ASW,ACB,CEU
    parser.add_argument('-ip', '--included_pop', dest='included_pop', default="", help='')   # UR,BEB,PJL,MSL,ASW,ACB,CEU 
    parser.add_argument('-es', '--excluded_samples', dest='excluded_samples', default="", help='')   # UR,BEB,PJL,MSL,ASW,ACB,CEU
    parser.add_argument('-is', '--included_samples', dest='included_samples', default="", help='')   # UR,BEB,PJL,MSL,ASW,ACB,CEU 
    parser.add_argument('-pv', '--print_var', dest='print_var', default="true", help='')

    args = parser.parse_args()
    pop_type=args.pop_type
    ref_dataset=args.ref_dataset
    imp=args.imp
    targets=args.targets.split(',')
    print_var=args.print_var=='true'
    excluded_populations=args.excluded_pop.split(',') if args.excluded_pop != "" else []
    included_populations=args.included_pop.split(',') if args.included_pop != "" else []
    excluded_samples=pd.read_csv(args.excluded_samples, sep='\t', index_col=0).iloc[:,0].values if args.excluded_samples != "" else []
    included_samples=pd.read_csv(args.included_samples, sep='\t', index_col=0).iloc[:,0].values if args.included_samples != "" else []

    for target in targets:
        fig, axs = plt.subplots(2,3,figsize=(70,30))
        axs=axs.flatten()
        fig3d= plt.figure(figsize=(30,15))
        ax3d_1 = fig3d.add_subplot(121, projection='3d')
        ax3d_2 = fig3d.add_subplot(122, projection='3d')
        axs3d=[ax3d_1, ax3d_2]
        pca2_file_name="ds.pca.sscore" # "ds.ref.eigenvec"
        pca1_fname="ds.eigenvec"
        if os.path.exists(os.path.join(constants.DATASETS_PATH, target, imp, pca2_file_name)):
            print("plot pca2")
            df1=pd.read_csv(os.path.join(constants.DATASETS_PATH, ref_dataset, pca2_file_name), index_col=1, delim_whitespace=True)
            df2=pd.read_csv(os.path.join(constants.DATASETS_PATH, target, imp, pca2_file_name), index_col=1, delim_whitespace=True)
            # df1.iloc[:, 1:]=-df1.iloc[:, 1:]
            df=pd.concat((df1,df2))
            # print(df1.shape)
            # print(df2.shape)
            print(df.shape)
            # df=df.loc[:,[f'PC{a}_AVG' for a in range(1,7)]]
            df=df.iloc[:,3:]
            print(df.columns)
            print(df)
            eigenvals=open(os.path.join(constants.DATASETS_PATH, ref_dataset, 'ds.ref.eigenval'), 'r').readlines()
            if os.path.exists(os.path.join(constants.DATASETS_PATH, ref_dataset, 'ds.ref.rel2')):
                total_var=open(os.path.join(constants.DATASETS_PATH, ref_dataset, 'ds.ref.rel'), 'r').readlines()
            else:
                total_var=open(os.path.join(constants.DATASETS_PATH, ref_dataset, 'ds.ref.eigenval'), 'r').readlines()

            pop_panel_path=os.path.join(constants.DATASETS_PATH,target, 'pop.panel')
            df_samples_md_1=pd.read_csv(pop_panel_path, sep='\t', index_col=1)
            df_samples_md_1=df_samples_md_1[~df_samples_md_1.index.duplicated(keep='first')]

            pop_panel_path=os.path.join(constants.DATASETS_PATH,ref_dataset.split('/')[0], 'pop.panel')
            df_samples_md_2=pd.read_csv(pop_panel_path, sep='\t', index_col=1)
            df_samples_md_2=df_samples_md_2[~df_samples_md_2.index.duplicated(keep='first')]

            df_samples_md=pd.concat((df_samples_md_1,df_samples_md_2))

            print("projecting eigen-vector using sscore file")
            print(df.shape)
        else:
            print("plot pca1")
            df=pd.read_csv(os.path.join(constants.DATASETS_PATH, target, imp, 'ds.eigenvec'), index_col=1, delim_whitespace=True, header=None)
            df=df.iloc[:,1:]
            print(df.columns)
            eigenvals=open(os.path.join(constants.DATASETS_PATH, target, imp, 'ds.eigenval'), 'r').readlines()
            total_var=eigenvals
            print("calculaute eigen-vectors from eigenvec file ")

            df_samples_md=pd.read_csv(os.path.join(constants.DATASETS_PATH,target, imp, 'ds.QC.fam'), delim_whitespace=True, header=None)
            df_samples_md.index=df_samples_md.iloc[:,1]
            df_samples_md.loc[:,'super_pop']=target
            df_samples_md.loc[:,'pop']=target
            pop_panel_path=os.path.join(constants.DATASETS_PATH,target, 'pop.panel')
            if os.path.exists(pop_panel_path):
                df_samples_md=pd.read_csv(pop_panel_path, sep='\t', index_col=1)
                df_samples_md=df_samples_md[~df_samples_md.index.duplicated(keep='first')]

        if len(included_populations):
            df=df.reindex(df_samples_md.loc[:,'pop'][df_samples_md.loc[:,'pop'].isin(included_populations)].index.values).dropna()

        df=df.reindex(df_samples_md.loc[:,'pop'][~df_samples_md.loc[:,'pop'].isin(excluded_populations)].index.values)

        if len(included_samples):
            df=df.reindex(included_samples).dropna()
        super_populations=df_samples_md.loc[df.index, 'super_pop']
        super_populations=super_populations[~super_populations.index.duplicated(keep='first')]
        populations=df_samples_md.loc[df.index, 'pop']
        populations=populations[~populations.index.duplicated(keep='first')]
        labels=(populations if pop_type=='pop' else super_populations)
        populations_unique=np.unique(populations)
        super_populations_unique=np.unique(super_populations)
        color_palette_dict={}
        super_to_pop={}
        pop_to_super={}
        color_palettes=['hsv_0_1', 'hsv_0_1'] #  ['PiYG_0_0.4',  'PiYG_0.6_1', 'PuOr_0_0.4', 'PuOr_0.6_1', 'bwr_0_0.4', 'bwr_0.6_1', 'spring_0_0.4', 'spring_0.6_1', 'cool_0_0.4', 'cool_0.6_1', 'RdGy_0_0.4', 'RdGy_0.6_1', 'bone_0_0.4', 'bone_0.6_1', 'pink_0_0.4', 'pink_0.6_1', 'summer_0_0.4', 'summer_0.6_1', 'copper_0_0.4', 'copper_0.6_1', 'Blues_0_0.4', 'Blues_0.6_1', 'Greens_0_0.4', 'Greens_0.6_1', 'Oranges_0_0.4', 'Oranges_0.6_1', 'Greens_0_0.4', 'Greens_0.6_1', 'Greens_0_0.4', 'Greens_0.6_1']

        for i, sp in enumerate(super_populations_unique):
            color_palette_dict[sp]=color_palettes[i]
            super_to_pop[sp]=[]

        for i, pop in enumerate(populations_unique):
             super_pop=df_samples_md[df_samples_md.loc[:,'pop']==pop].iloc[0].loc['super_pop']
             super_to_pop[super_pop].append(pop)
             pop_to_super[pop]=super_pop

        populations_unique=functools.reduce(lambda q,w: q+w, [a for a in super_to_pop.values()])
        ax_i=0
        jewish_pop=['IL', 'IL1', 'IL2', 'ZAJ14', 'ZAJ18', 'ZAJ_SCZ', 'ZAJ_HEALTHY', 'Jew', 'Israel']
        labels=labels.loc[df.index]
        for i in np.arange(4):
            for j in np.arange(i+1, 4):
                print(df.columns[i], df.columns[j])
                ax=axs[ax_i]
                ax_i+=1
                for pop in np.sort(populations_unique)[::-1]:
                    is_jewish_per_category=[a in str(pop) for a in jewish_pop]
                    is_jewish_pop=any(is_jewish_per_category)
                    if is_jewish_pop:
                        c='gray'
                        s=is_jewish_per_category.index(True)/(1.0+len(is_jewish_per_category))
                        e=(is_jewish_per_category.index(True)+1)/(1.0+len(is_jewish_per_category))
                    else:
                        c=(color_palette_dict[pop_to_super[pop]].split('_')[0])
                        s=float(color_palette_dict[pop_to_super[pop]].split('_')[1])*1
                        e=float(color_palette_dict[pop_to_super[pop]].split('_')[2])*1

                    color=matplotlib.cm.get_cmap(c)(s+(e-s)*super_to_pop[pop_to_super[pop]].index(pop)/float(len(super_to_pop[pop_to_super[pop]])))
                    mask=(labels==pop)


                    ax.plot(df[mask].iloc[:,i].astype(np.float), df[mask].iloc[:,j].astype(np.float), marker='o', linestyle=' ', markersize=6, mec=('red' if is_jewish_pop else 'black'), mew=(.5 if is_jewish_pop else .13), markerfacecolor=color, label=f'{pop} (n={np.sum(mask)})', zorder=(2 if is_jewish_pop else 1))# , alpha=0.5)
                spacer='\t'
                ax.set_xlabel(f"PC {i+1}", fontsize=30) # {'' if not print_var else '(var='+str(round(100*(float(eigenvals[i])/sum([float(a.split(spacer)[-1]) for a in total_var])),2))+'%)'}", fontsize=30)
                ax.set_ylabel(f"PC {j+1}", fontsize=30) # {'' if not print_var else '(var='+str(round(100*(float(eigenvals[j])/sum([float(a.split(spacer)[-1]) for a in total_var])),2))+'%)'}", fontsize=30)

        lgd=ax.legend(loc=(1.05,-0.05), ncol=1, fontsize=30, markerscale=6)
        fig.savefig(os.path.join(constants.FIGURES_PATH, f'pca_plink_{target}_{pop_type}_{imp}.png'))

        # for i, ax3d in enumerate(axs3d):
        #     for pop in populations_unique:
        #         c=color_palette_dict[pop_to_super[pop]].split('_')[0]
        #         s=float(color_palette_dict[pop_to_super[pop]].split('_')[1])*1
        #         e=float(color_palette_dict[pop_to_super[pop]].split('_')[2])*1
        #         color=matplotlib.cm.get_cmap(c)(s+(e-s)*super_to_pop[pop_to_super[pop]].index(pop)/float(len(super_to_pop[pop_to_super[pop]])))
        #         mask=(labels==pop)
        #         ax3d.plot(df[mask].iloc[:,i*3+1].astype(np.float), df[mask].iloc[:,i*3+2].astype(np.float), df[mask].iloc[:,i*3+3].astype(np.float), label=pop, marker='o', linestyle=' ', markersize=6, mec='k', mew=.5, color=color)
        #
        #     ax3d.set_xlabel(i*3+1, fontsize=30)
        #     ax3d.set_ylabel(i*3+2, fontsize=30)
        #     ax3d.set_zlabel(i*3+3, fontsize=30)
        # fig3d.legend()
