#!/bin/bash
set -e 

source constants_.sh
source parse_args.sh "$@"

# Parse input
if [[ -z ${chr} ]]; then echo "Please specify chr index"; exit 1; fi
if [[ -z ${pop} ]]; then pop="all"; fi
if [[ -z ${thread} ]]; then thread=30; fi
if [[ -z ${vcf_path} ]]; then vcf_path='/specific/elkon/hagailevi/data-scratch/1000G_ALL'; fi
if [[ -z ${threads} ]]; then threads=30; fi
if [[ -z ${memory} ]]; then memory=500000; fi
if [[ -z ${stage} ]]; then stage=4; fi
if [[ -z ${target} ]]; then target="$PRS_DATASETS/1kg"; fi
if [[ -z ${force} ]]; then force=false; fi



echo "make dir ${vcf_path}/bi/${pop} (if not exists)"
mkdir -p ${vcf_path}/bi/${pop} || echo ""


if [[ ! -f ${vcf_path}/bi/chr${chr}.vcf.gz ]]; then 
        echo 'filter out multiallelic variants and indels (if not done yet)'
	bcftools view --min-alleles 2 --max-alleles 2 --exclude-types indels -Oz -o ${vcf_path}/bi/chr${chr}.vcf.gz ${vcf_path}/chr${chr}.vcf.gz
fi	

echo 'create a subset of individuals in a haps/legend/sample format'
if [[ ! -f ${vcf_path}/bi/${pop}/chr${chr} ]] || [[ ${force} ]]; then
    
    if [[ -z ${extract} ]]; then
        plink2 --vcf ${vcf_path}/bi/chr${chr}.vcf.gz --keep ${target}/pop.${pop}.panel --export haps --out ${vcf_path}/bi/${pop}/chr${chr}
    else
        plink2 --vcf ${vcf_path}/bi/chr${chr}.vcf.gz --keep ${target}/pop.${pop}.panel --extract ${target}/${extract} --export haps --out ${vcf_path}/bi/${pop}/chr${chr}
    fi
fi


# echo 'convert haps/legend/sample to haps/sample format'
# paste -d ' ' <(zcat chr${chr}.legend.gz | tail -n +2 -q) <(zcat chr${chr}.haps.gz) | awk '{ print 2" "$0 }' > chr2.21.shapeit.haps


echo 'create a reference panel using shapeit'
shapeit -convert --input-haps ${vcf_path}/bi/${pop}/chr${chr} --output-log ${vcf_path}/bi/${pop}/chr${chr}.log --output-ref ${vcf_path}/bi/${pop}/chr${chr}.ref.hap ${vcf_path}/bi/${pop}/chr${chr}.ref.legend.gz ${vcf_path}/bi/${pop}/chr${chr}.ref.sample --thread ${thread}
