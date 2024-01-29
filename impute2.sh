#!/bin/bash
# P=0

source /specific/elkon/hagailevi/PRS/codebase/parse_args.sh $@
source /specific/elkon/hagailevi/PRS/codebase/parse_chrs.sh
eval $(parse_chrs $chrs)


if [[ -z $threads ]]; then threads=30; fi

if [[ -z $panel ]]; then panel='1kg_raw'; fi

if [[ -z $phased ]]; then phased='original'; fi

declare -a pid=()

recombination_map='/specific/elkon/hagailevi/data-scratch/imputation/maps/1000G_ALL_impute2/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt'

# # AJ panel

if [ $panel == 'aj_raw' ]; then
    haplotype=$PRS_RAW'/dec/gd_aj/Phase\ 2/Ref\ panel/${chr}.merged.snp_indel.hap.gz'
    legend=$PRS_DATASETS'/gd_aj/Phase\ 2/Ref\ panel/${chr}.merged.snp_indel.legend'
    phase=$PRS_DATASETS'/${target}/impute2_aj/raw/chr${chr}.phased.haps'
    genotype_to_impute=$PRS_DATASETS'/${target}/original/raw/chr${chr}.gen'
    output_file=$PRS_DATASETS'/${target}/impute2_aj/raw/chr${chr}.${chunk}.legend'

elif [ $panel == '1kg_raw' ]; then
    haplotype=$MY_SCRATCH'/imputation/maps/1000G_ALL_impute2/1000GP_Phase3/1000GP_Phase3_chr${chr}.hap.gz'
    legend=$MY_SCRATCH'/imputation/maps/1000G_ALL_impute2/1000GP_Phase3/1000GP_Phase3_chr${chr}.legend.gz'
    phase=$PRS_DATASETS'/${target}/impute2_1kg/raw/chr${chr}.phased.haps'
    genotype_to_impute=$PRS_DATASETS'/${target}/original/raw/chr${chr}.gen'
    output_file=$PRS_DATASETS'/${target}/impute2_1kg/raw/chr${chr}.${chunk}.legend'

else 


    haplotype=$PRS_DATASETS'/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.hap'
    legend=$PRS_DATASETS'/${panel%_*}/imputation_panels/${panel#*_}/chr${chr}.ref.legend.gz'
    phase=$PRS_DATASETS'/${target}/${phased}/raw/phased/chr${chr}.phased.haps'
    genotype_to_impute=$PRS_DATASETS'/${target}/${phased}/raw/gen/chr${chr}.gen'
   
    if [[ -z $panel2 ]]; then        
        mkdir -p "$PRS_DATASETS/${target}/impute2_${panel}/raw/impute2/parts" || echo ""
        output_file=$PRS_DATASETS'/${target}/impute2_${panel}/raw/impute2/parts/chr${chr}.${chunk}.legend'
    else
        mkdir -p "$PRS_DATASETS/${target}/impute2_${panel}_${panel2}/raw/impute2/parts" || echo ""
        haplotype2=$PRS_DATASETS'/${panel2%_*}/imputation_panels/${panel2#*_}/chr${chr}.ref.hap'
        legend2=$PRS_DATASETS'/${panel2%_*}/imputation_panels/${panel2#*_}/chr${chr}.ref.legend.gz'
        output_file=$PRS_DATASETS'/${target}/impute2_${panel}_${panel2}/raw/impute2/parts/chr${chr}.${chunk}.legend'
    fi

fi
 
for chr in "${chrs_range[@]}"; do
namefile="${chr}.phased";
maxPos=$(tail -n 1 /specific/elkon/hagailevi/data-scratch/imputation/maps/1000G_ALL_impute2/1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt | awk '{print $1}')
nrChunk=$(expr ${maxPos} "/" 500000)
nrChunk2=$(expr ${nrChunk} "+" 1)
start="0"

for chunk in $(seq 1 $nrChunk2); do

    endchr=$(expr $start "+" 500000)
    startchr=$(expr $start "+" 1)
    echo "start a new process"
      if [[ ! -f $(eval "echo $output_file") ]]; then
          # ((P+=1))
          if [[ -z $panel2 ]]; then
              cmd='impute2 \
                 -m "'$(eval "echo $recombination_map")'" \
                 -h "'$(eval "echo $haplotype")'" \
                 -l "'$(eval "echo $legend")'" \
                 -g "'$(eval "echo $genotype_to_impute")'" \
                 -known_haps_g "'$(eval "echo $phase")'" \
                 -int '"${startchr} ${endchr}"' \
                 -Ne 20000 \
                 -filt_rules_l '"'EUR<=0.01' 'AFR<=0.01' 'EAS<=0.01' 'SAS<=0.01' 'AMR<=0.01' 'ALL<=0.01'"' \
                 -allow_large_regions \
                 -o "'$(eval "echo $output_file")'"'
          else
               cmd='impute2 \
                 -m "'$(eval "echo $recombination_map")'" \
                 -h "'$(eval "echo $haplotype")'" "'$(eval "echo $haplotype2")'"\
                 -l "'$(eval "echo $legend")'" "'$(eval "echo $legend2")'"\
                 -g "'$(eval "echo $genotype_to_impute")'" \
                 -known_haps_g "'$(eval "echo $phase")'" \
                 -int '"${startchr} ${endchr}"' \
                 -Ne 20000 \
                 -filt_rules_l '"'EUR<=0.01' 'AFR<=0.01' 'EAS<=0.01' 'SAS<=0.01' 'AMR<=0.01' 'ALL<=0.01'"' \
                 -allow_large_regions \
                 -o "'$(eval "echo $output_file")'"'
          fi        

          echo $cmd

          (eval "$cmd" || true )  & pids+=($!);

          # -filt_rules_l 'EUR<0.01' 'AFR<=0.01' 'EAS<=0.01' 'SAS<=0.01' 'AMR<=0.01' 'ALL<=0.01' \
      else
          echo "legend file for  ${chr} ${startchr} ${endchr} already exists (file name: "$(eval "echo $output_file")"). skipping...";
      fi

      start=${endchr}
      while [[ ${#pids[@]}  -ge $threads ]]; do
          counter=-1
          for pid in "${pids[@]}"; do
              counter=$((counter+1))
              if  [[ $(kill -0 $pid  2>&1) ]]  ; then
                  echo "remove index $counter: ${pids[counter]}"
                  unset 'pids[counter]'
              fi
          done

          # The following block is for updating the length of pids array (arrays' length in bash do not update automatically after modifying it)    
          declare -a new_pids=()
          for i in "${pids[@]}"; do
              new_pids+=($i)
          done
          pids=(${new_pids[@]})
          unset new_pids
         
          echo "# of P: ${#pids[@]}" #  (" "${pids[@]}" ")"
          sleep 5
      done

      echo "end while"
      done
done
wait "${pids[@]}"
echo "done!"

