#!/bin/bash
set -e
source constants_.sh
source parse_chrs.sh
eval $(parse_chrs $chrs)

for a in "${chrs[@]}"; do
    echo $a
    cat ${reference_path}1000G_${src_pop}/chr${a}.vcf | awk '{(!a[$1, $2]++ && !b[$3]++)}' > ${reference_path}1000G_${dest_pop}/chr${a}.vcf
    echo 'done chr'${a}
done


