source /specific/elkon/hagailevi/PRS/codebase/parse_args.sh $@
source /specific/elkon/hagailevi/PRS/codebase/parse_chrs.sh

if [[ -z $chrs ]]; then
    chrs_range=($(seq 1 22))
else
    eval $(parse_chrs $chrs)
fi

if [[ -z $start_pos ]]; then start_pos=0; fi

if [[ -z $end_pos ]]; then end_pos=500; fi

if [[ -z $target ]]; then echo "target param must be specified. Exiting"; exit 0; fi;

if [[ -z $imp ]]; then echo "imp param (imputation version) must be specified. Exiting"; exit 0; fi;

folder="$PRS_DATASETS/${target}/${imp}/raw/impute2/parts"

echo "start gzipping part files in ${folder}"  

for a in "${chrs_range[@]}"; do 
    echo "check chr $a"
    for b in $(seq ${start_pos} ${end_pos}); do 
        if [[  -f ${folder}/chr${a}.${b}.legend ]]; then
            echo "zipping ${folder}/chr${a}.${b}.legend";
            gzip "${folder}/chr${a}.${b}.legend"
            fi; 
    done; 
done;

echo "Finished zipping part file in ${folder}"
