##
# Creates a subgroup of individuals by filter expression
#
##

import argparse
import json
import os

import pandas as pd

import constants

if __name__=="__main__":

    parser = argparse.ArgumentParser(description='Creates a subgroup of individuals by filter expression')
    parser.add_argument('-pop', '--pop_path', help='A pop file', default=os.path.join(constants.DATASETS_PATH, "dbg-drive","pop.panel"))
    parser.add_argument('-pheno', '--pheno_path', help="A pheno file", default=os.path.join(constants.DATASETS_PATH, "dbg-drive","pheno"))
    parser.add_argument('-f', '--filters', help='A filter a expression in a JSON format. e.g., {"super_pop": ["EUR"]}' , default='{"pop": ["Uganda"]}')   # UR,BEB,PJL,MSL,ASW,ACB,CEU
    parser.add_argument('-s', '--suffix', help='', default="UGD")  # UR,BEB,PJL,MSL,ASW,ACB,CEU
    parser.add_argument('-t', '--target', dest='target', default="dbg-drive", help='')   # UR,BEB,PJL,MSL,ASW,ACB,CEU

    args = parser.parse_args()
    pop_path=args.pop_path
    pheno_path = args.pheno_path
    suffix = args.suffix
    filters=json.loads(args.filters)
    target = args.target

    df_pop=pd.read_csv(pop_path, sep='\t', index_col=0)
    df_pheno=pd.read_csv(pheno_path, sep='\t', index_col=0)
    
 
    df_agg=pd.concat([df_pop, df_pheno], axis=1)
    auto_suffix=""
    for field, value_set in filters.items():
        df_agg=df_agg[df_agg.loc[:,field].isin(value_set)]
        auto_suffix+=f"{field}={value_set}&"
        df_agg=df_agg.dropna()

    suffix=(auto_suffix[:-1] if suffix is None else suffix)

    df_agg=df_agg.loc[:,~df_agg.columns.duplicated()] 
    df_agg.loc[:,["IID", "label"]].to_csv(os.path.join(constants.DATASETS_PATH, target, f"pheno_{suffix}"), sep='\t', index_label="FID")
    df_agg.loc[:, ["IID", "super_pop", "pop"]].to_csv(os.path.join(constants.DATASETS_PATH, target, f"pop_{suffix}.panel"), sep='\t', index_label="FID")


