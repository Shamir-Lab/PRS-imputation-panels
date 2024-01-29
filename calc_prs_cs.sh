#!/bin/bash

source constants_.sh
source parse_args.sh "$@"

# Parse input
if [[ -z ${maf} ]]; then maf=0.05; fi
if [[ -z ${geno} ]]; then geno=0.1; fi
if [[ -z ${imp} ]]; then imp="original"; fi
if [[ -z ${memory} ]]; then memory=500000; fi
if [[ -z ${threads} ]]; then threads=80; fi
if [[ -z ${stage} ]]; then stage=1; fi
if [[ -z ${hp}  ]]; then hp="0.1"; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [[ -z ${pheno}  ]]; then pheno=""; fi
if [[ -z ${continuous}  ]]; then continuous="false"; fi

sub=""

if [[ ! "${pheno}" == ""  ||  ! "${pop}" == "" ]]; then
	sub=_${pheno}_${pop}
fi

if [[ ! "${pheno}" == ""  ]]; then
        pheno=_${pheno}
fi

if [[ ! "${pop}" == "" ]]; then
        pop=_${pop}
fi

prs_prefix="prs.cs"

discovery_path=${GWASs_path}${discovery}'/'
target_path=${datasets_path}${target}"/${imp}/"
prs_path=${PRSs_path}${discovery}_${target}"/${imp}/"

# Start pipeline
mkdir -p $prs_path || echo ""

if [[ ${stage} -le 1 ]]; then
    echo -e "SNP\tA1\tA2\tP\tBETA" > $discovery_path/gwas_cs.tsv
    tail -n +2 $discovery_path/gwas.tsv | awk '{print $1"\t"$4"\t"$5"\t"$8"\t"$11}' >> $discovery_path/gwas_cs.tsv
fi


# if [[ ${stage} -le 2 ]]; then
# 
#     mkdir -p $prs_path/prscs/ || echo ""
# 
#     $PRS_CODEBASE/../prs-python2/bin/python PRScs.py \
#       --ref_dir=$ELKON_SCRATCH/PRScs_LD/ldblk_1kg_eur \
#       --bim_prefix=$target_path/ds.QC \
#       --sst_file=$discovery_path//gwas_cs.tsv \
#       --n_gwas=100000 \
#       --out_dir=$prs_path/prscs/out
# fi



if [[ ${stage} -le 3 ]]; then
    rm $prs_path/prscs/out_all 
    ls -tr $prs_path/prscs/out* | xargs -n 100 cat > $prs_path/prscs/out_all
fi


if [[ ${stage} -le 4 ]]; then
            plink --bfile $target_path/ds.QC  --score $prs_path/prscs/out_all 2 4 6 --out $prs_path/{prs_prefix}.${hp}
fi


if [[ ${stage} -le 5 ]]; then
    	    Rscript calc_metrics_cs.R ${discovery} ${target} ${imp};
fi
