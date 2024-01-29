import argparse
import os

import numpy as np
import pandas as pd

import constants

if __name__=="__main__":
    constants.DATASETS_PATH=constants.DATASETS_PATH 
    parser = argparse.ArgumentParser(description='args')
    parser.add_argument('-d', '--dataset', dest='dataset', help='', default='ukbb_afr')
    parser.add_argument('-p', '--population', dest='population', help="", default='')
    parser.add_argument('-ph', '--phenotype', dest='phenotype', help="", default="")
    parser.add_argument('-f', '--folds', dest='folds', help="", default="2")
    parser.add_argument('-r', '--rep', dest='rep', help="", default="102")

    args = parser.parse_args()
    dataset=args.dataset
    population = args.population
    folds = int(args.folds)
    phenotype=args.phenotype
    rep=args.rep
    if rep:
        pheno_folder=f'rep_{rep}'

    f_name="pheno"
    if phenotype!="" or population!="":
        f_name+=f'{phenotype}_{population}'

    all_path = os.path.join(constants.DATASETS_PATH, dataset, f_name)


    df_all=pd.read_csv(all_path, sep='\t') # , index_col=0)
    print(df_all.shape)
    # r=np.arange(len(df_all))
    # np.random.shuffle(r)
    # df_all=df_all.loc[r]
    df_all=df_all.sample(frac=1)
    fold_size = int(len(df_all.index) / (folds+1))


#     test_cv.loc[:, "IID"] = test_cv.index
#     test_cv.loc[:, "label"] = test_cv.loc[test_cv.index,"label"]


    for outer_fold in np.arange(int(folds + 1)):

        try:
            os.mkdir(os.path.join(constants.DATASETS_PATH, dataset, f'{pheno_folder}_{outer_fold + 1}'))
        except OSError:
            pass

        test_cv= df_all.iloc[outer_fold * fold_size:(outer_fold + 1) * fold_size].copy()
        df_train=pd.concat([df_all.iloc[:outer_fold * fold_size], df_all.iloc[(outer_fold + 1) * fold_size:]])


        test_path = os.path.join(constants.DATASETS_PATH, dataset, f'{pheno_folder}_{outer_fold + 1}', f'pheno_{phenotype}_{population}_{int(folds)}_test')
        test_cv.to_csv(test_path, sep='\t', index=None)

        both_path = os.path.join(constants.DATASETS_PATH, dataset, f'{pheno_folder}_{outer_fold + 1}', f'pheno_{phenotype}_{population}_{int(folds)}_both')
        df_train.to_csv(both_path, sep='\t', index=None)

        for inner_fold in np.arange(int(folds)):

            validation_cv= df_train.iloc[inner_fold * fold_size:(inner_fold + 1) * fold_size].copy()
            train_cv=pd.concat([df_train.iloc[:inner_fold * fold_size].copy(), df_train.iloc[(inner_fold + 1) * fold_size:].copy()])

    #         train_cv.loc[:, "IID"] = train_cv.index
    #         train_cv.loc[:, "label"] = train_cv.loc[train_cv.index,"label"]
    #         validation_cv.loc[:, "IID"] = validation_cv.index
    #         validation_cv.loc[:, "label"] = validation_cv.loc[validation_cv.index, "label"]

            train_path = os.path.join(constants.DATASETS_PATH, dataset, f'{pheno_folder}_{outer_fold + 1}', f'pheno_{phenotype}_{population}_{int(inner_fold + 1)}_{int(folds)}_train')
            validation_path = os.path.join(constants.DATASETS_PATH, dataset, f'{pheno_folder}_{outer_fold + 1}', f'pheno_{phenotype}_{population}_{int(inner_fold + 1)}_{int(folds)}_validation')
            train_cv.to_csv(train_path, sep='\t', index=None)
            validation_cv.to_csv(validation_path, sep='\t', index=None)

     
