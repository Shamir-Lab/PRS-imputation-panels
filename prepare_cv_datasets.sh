source constants_.sh
source parse_args.sh "$@"

source init_args_cv.sh

if [[ ! -f ${imp_path}ds_${pheno}_${pop}${train_suffix}.bed ]]; then
plink2 \
    --bfile ${base_imp_path}ds \
    --keep ${target_path}pheno_${pheno}_${pop}${train_suffix} \
    --maf 0.05 \
    --geno 0.1 \
    --mind 0.1 \
    --make-bed \
    --memory 20000 \
    --threads 5 \
    --out ${imp_path}ds_${pheno}_${pop}${train_suffix}
fi

if [[ ! -f ${imp_path}ds_${pheno}_${pop}${test_suffix}.bed ]]; then
plink2 \
    --bfile ${base_imp_path}ds \
    --keep ${target_path}pheno_${pheno}_${pop}${test_suffix} \
    --maf 0.05 \
    --geno 0.1 \
    --mind 0.1 \
    --make-bed \
    --memory 20000 \
    --threads 5 \
    --out ${imp_path}ds_${pheno}_${pop}${test_suffix}
fi

if [[ ! -f ${imp_path}ds_${pheno}_${pop}${train_suffix}.eigenvec ]]; then
echo '### calculate the first 6 PCs for train set###'
plink \
  --bfile ${imp_path}ds_${pheno}_${pop}${train_suffix} \
  --indep-pairwise 200 50 0.25 \
  --memory 20000 \
  --threads 5 \
  --out ${imp_path}ds_${pheno}_${pop}${train_suffix}

plink \
  --bfile ${imp_path}ds_${pheno}_${pop}${train_suffix} \
  --extract ${imp_path}ds_${pheno}_${pop}${train_suffix}.prune.in \
  --pca 6 \
  --mind 1 \
  --memory 20000 \
  --threads 5 \
  --out ${imp_path}ds_${pheno}_${pop}${train_suffix} \
  --geno 1
fi

if [[ ! -f ${imp_path}ds_${pheno}_${pop}${test_suffix}.eigenvec ]]; then
echo '### calculate the first 6 PCs for train set###'
plink \
  --bfile ${imp_path}ds_${pheno}_${pop}${test_suffix} \
  --indep-pairwise 200 50 0.25 \
  --memory 20000 \
  --threads 5 \
  --out ${imp_path}ds_${pheno}_${pop}${test_suffix}

plink \
  --bfile ${imp_path}ds_${pheno}_${pop}${test_suffix} \
  --extract ${imp_path}ds_${pheno}_${pop}${test_suffix}.prune.in \
  --pca 6 \
  --mind 1 \
  --out ${imp_path}ds_${pheno}_${pop}${test_suffix} \
  --geno 1 \
  --memory 20000 \
  --threads 5
fi