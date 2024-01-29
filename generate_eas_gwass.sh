#!/bin/bash
set -e 

discovery=$1

cd $PRS_GWASS/$discovery

n_raw_files=$(ls *tsv.gz | wc -l)

if [[ $n_raw_files -ne 1 ]]; then
    echo "Incorrect n of raw files in dir $discovery: expected 1, got $n_raw_files"
    exit 1
fi

echo "Start processing $discovery"

echo "Extract $discovery"
gunzip GC*.tsv.gz
mv GC*.tsv gwas_raw_original.tsv

echo "Annotate snp ids"
tail -n +2 gwas_raw_original.tsv | awk '{print $1"\t"$2"\t"$2"\t"$1"_"$2}' > gwas_snp_pos
plink --bfile $PRS_DATASETS/1kg/original/ds --extract range gwas_snp_pos --make-just-bim --out gwas_snp_ids

echo "Assign annotation to raw GWAS"
python -c \
'import pandas as pd
df1=pd.read_csv("gwas_snp_ids.bim", sep="\t", header=None)
df2=pd.read_csv("gwas_raw_original.tsv", sep="\t")
df1.columns=df1.columns.astype(str)
df_merged=pd.merge(df1,df2, left_on=[df1.columns[0],df1.columns[3]], right_on=[df2.columns[0],df2.columns[1]])
df_merged_filtered=pd.concat((df_merged.iloc[:,1], df_merged.iloc[:,6:]), axis=1)
df_merged_filtered.rename(columns={"1":"snp"},inplace=True)
df_merged_filtered.drop("variant_id", axis=1, inplace=True)
df_merged_filtered.to_csv("gwas_raw.tsv", sep="\t", index=False)
'

echo "Generate final GWAS"
cd $PRS_CODEBASE
bash generate_gwas.sh --super_pop=EAS --discovery=$discovery --N=137000 --imp=impute2_1kg_eur --stage 3
