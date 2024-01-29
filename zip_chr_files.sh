source /specific/elkon/hagailevi/PRS/codebase/parse_args.sh $@
source /specific/elkon/hagailevi/PRS/codebase/parse_chrs.sh

if [[ -z $chrs ]]; then
    chrs_range=($(seq 1 22))
else
    eval $(parse_chrs $chrs)
fi

if [[ -z $target ]]; then echo "target param must be specified. Exiting"; exit 0; fi;

if [[ -z $imp ]]; then echo "imp param (imputation version) must be specified. Exiting"; exit 0; fi;

folder="$PRS_DATASETS/${target}/${imp}/raw/impute2/chrs"

echo "start gzipping chr files in ${folder}"  

for a in "${chrs_range[@]}"; do 
    echo "check chr $a"
    if [[  -f ${folder}/chr${a}.impute2 ]]; then
        echo "zipping ${folder}/chr${a}.impute2";
        gzip "${folder}/chr${a}.impute2"
    fi; 
done; 

echo "Finished zipping chr files in ${folder}"
