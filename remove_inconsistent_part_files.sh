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

echo "start checking for corrupted files"  
declare -a inconsistent_files=()
for a in "${chrs_range[@]}"; do 
    echo "check chr $a"
    for b in $(seq ${start_pos} ${end_pos}); do 
        if [[  -f ${folder}/chr${a}.${b}.legend ]]; then
            s1=$(tail -n 1 ${folder}/chr${a}.${b}.legend | awk '{print NF}'); s2=$(head -n 1 ${folder}/chr${a}.${b}.legend | awk '{print NF}'); 
            if [[ $s1 -ne $s2 ]]; then 
                echo "${folder}/chr${a}.${b}.legend $s1 $s2";
                inconsistent_files+=("${folder}/chr${a}.${b}.legend")
            fi; 
        fi; 
    done; 
done;

echo "found ${#inconsistent_files[@]} inconsistent files."

if [[ "${#inconsistent_files[@]}" -gt 0 ]]; then
    while true; do
        read -p "How do you wish to proceed? delete (d), write to file (w) or exit (q) : " choose1;  
        if [[ $choose1 == [dD] ]]; then
            for a in ${inconsistent_files[@]}; do
                rm $a;
            done;
            echo "Finished deleting inconsistent files"
            break;
        elif [[ $choose1 == [wW] ]]; then
            out_file="inconsistent_files.txt"
            echo "Try to write files to $out_file"
            while true; do
                if [[ -f $out_file ]]; then
                    read -p "The file $out_file already exists. How do you wish to proceed? overwrite (o), rename (r) : " choose2; 
                    if [[ $choose2 == [oO] ]]; then
                        rm $out_file
                        break;
                    elif [[ $choose2 == [rR] ]]; then
                        while true; do
                            read -p "Please enter an output file name : " out_file;
                            if [[ $out_file != "" ]]; then
                                break;
                            else
                                echo "enter a non-empty file name"
                            fi
                        done;
                    fi
                else
                    break;
                fi
            done
            for a in ${inconsistent_files[@]}; do
                echo $a >> $out_file
            done;
            echo "Finished writing inconsisnt files to $out_file"
            break;
        elif [[ $choose1 == [qQ] ]]; then
            echo "Goodbye!"
            exit 0
            break;
        fi
    done        
else
    echo "Did not find any inconsistent files. Horray!"
fi

