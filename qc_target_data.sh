set -e
source parse_args.sh "$@"
source constants_.sh

if [[ -z ${imp}  ]]; then imp="original"; fi
if [[ -z ${memory}  ]]; then memory="600000"; fi
if [[ -z ${threads}  ]]; then threads="80"; fi
if [[ -z ${maf}  ]]; then maf="0.05"; fi
if [[ -z ${geno}  ]]; then geno="0.1"; fi
if [[ -z ${mind}  ]]; then mind="0.1"; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [[ ${pop} != "" ]]; then
	pop=_${pop}
fi

discovery_path=${GWASs_path}${discovery}'/'
target_path=${datasets_path}${target}"/${imp}/"
prs_path=${PRSs_path}${discovery}_${target}"/${imp}/"


if [[ ${stage} -le 1 ]]; then

echo '### QC ###'

echo "." > ${target_path}ds.dupvar
cat ${target_path}ds.bim | cut -f 2 | sort | uniq -d >> ${target_path}ds.dupvar

plink \
    --bfile ${target_path}ds \
    --exclude ${target_path}ds.dupvar \
    --keep ${datasets_path}${target}/pop${pop}.panel \
    --out ${target_path}ds${pop}.QC \
    --maf ${maf} \
    --hwe 1e-6 \
    --geno ${geno} \
    --mind ${mind} \
    --make-bed 

fi

if [[ ${stage} -le 2 ]]; then

echo '### perform prunning ###'
plink \
	--bfile ${target_path}ds${pop}.QC \
	--indep-pairwise 200 50 0.25 \
	--out ${target_path}ds${pop}

fi
if [[ ${stage} -le 3 ]]; then
echo '### calculate the first 6 PCs ###'
plink \
	--bfile ${target_path}ds${pop}.QC \
	--extract ${target_path}ds${pop}.prune.in \
	--pca 6 \
	--mind 1 \
	--out ${target_path}ds${pop} \
	--geno 1

fi
