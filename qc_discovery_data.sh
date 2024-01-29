#!/bin/bash
set -e
source constants_.sh
source parse_args.sh "$@"

# Parse input
GWAS_path=${GWASs_path}${discovery}'/'

# Run pipeline
echo filter low-quality SNPs
cat ${GWAS_path}gwas.tsv |\
awk 'NR==1 || ($6 > 0.01) && ($8 < 1.0) && ($10 > 0.8) {print}' |\
gzip  > ${GWAS_path}gwas.quality.gz

echo filter ambiguous SNPS
gunzip -c ${GWAS_path}gwas.quality.gz |\
awk '!( ($4=="A" && $5=="T") || \
		($4=="T" && $5=="A") || \
		($4=="G" && $5=="C") || \
		($4=="C" && $5=="G")) {print}' |\
	gzip > ${GWAS_path}gwas.noambig.gz

echo get duplicated SNPs
echo "dups" > ${GWAS_path}duplicated.snp
gunzip -c ${GWAS_path}gwas.noambig.gz |\
awk '{ print $1}' |\
sort |\
uniq -d >> ${GWAS_path}duplicated.snp

echo remove duplicated SNPs
awk '{if(NR==FNR) {c[$1]++; next;} if (c[$1]==0){print $0}}' <(cat ${GWAS_path}duplicated.snp) <(gunzip -c ${GWAS_path}gwas.noambig.gz) |\
gzip - > ${GWAS_path}gwas.QC.gz

# awk  grep -vf ${GWAS_path}duplicated.snp |\

gunzip -c ${GWAS_path}gwas.QC.gz > ${GWAS_path}gwas.QC.Transformed

echo extract SNP p-value
awk '{print $1,$8}' ${GWAS_path}gwas.QC.Transformed > ${GWAS_path}SNP.pvalue




