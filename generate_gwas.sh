#!/bin/bash
set -e
source parse_args.sh "$@"
source constants_.sh

if [[ -z ${imp}  ]]; then imp="original"; fi
if [[ -z ${memory}  ]]; then memory="600000"; fi
if [[ -z ${threads}  ]]; then threads="80"; fi
if [[ -z ${maf}  ]]; then maf="0.05"; fi
if [[ -z ${geno}  ]]; then geno="0.1"; fi
if [[ -z ${stage}  ]]; then stage=1; fi
if [[ -z ${super_pop} ]]; then super_pop="EUR"; fi
if [[ -z ${N} ]]; then N=50000; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [[ -z ${continuous}  ]]; then continuous=""; fi
if [[ -z ${pheno}  ]]; then pheno=""; fi

sub=""


sub=_${pheno}_${pop}

echo $sub

if  [ ! "${pheno}"=="" ] ||  [ ! "${pop}"=="" ] ; then
        sub=_${pheno}_${pop}
fi

if [ ! ${pheno} == ""  ]; then
        pheno=_${pheno}
fi

if [ ! ${pop} == "" ]; then
        pop=_${pop}
fi



discovery_path=${GWASs_path}${discovery}'/'
target_path=${datasets_path}${target}"/${imp}/"
prs_path=${PRSs_path}${discovery}_${target}"/${imp}/"


if [[ ${stage} -le 1 ]]; then
	echo '### QC ###'
	plink \
    	--bfile ${target_path}ds \
	--keep ${datasets_path}${target}/pop${pop}.panel \
    	--out ${target_path}ds${pop}.QC \
    	--maf ${maf} \
    	--hwe 1e-6 \
    	--geno ${geno} \
    	--make-bed \
        --threads 40
fi

if [[ ${stage} -le 2 ]]; then
	if [[ ! -d ${discovery_path} ]]; then
		mkdir -p ${discovery_path}
	fi
	plink \
		--bfile ${target_path}ds${pop}.QC --assoc --pheno ${datasets_path}${target}/pheno${sub} --allow-no-sex --threads 40 --out ${discovery_path}gwas_raw.tsv
      
        if [[ "${continuous}"=="false" ]]; then
            mv ${discovery_path}gwas_raw.tsv.assoc ${discovery_path}gwas_raw.tsv
        else
            mv ${discovery_path}gwas_raw.tsv.qassoc ${discovery_path}gwas_raw.tsv
        fi
fi

if [[ ${stage} -le 3 ]]; then
        /specific/elkon/hagailevi/PRS/prs-python2/bin/python /specific/elkon/hagailevi/PRS/codebase/prepare_gwas.py --gwass ${discovery} --discovery_population ${super_pop} --N 50000
fi

if [[ ${stage} -le 4 ]]; then
	bash qc_discovery_data.sh --discovery ${discovery} --stage 1
fi
