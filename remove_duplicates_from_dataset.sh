#!/bin/bash
set -e
source constants_.sh
source parse_chrs.sh
eval $(parse_chrs $chrs)

cat ${datasets_path}${src}/ds.vcf | awk '{(!a[$1, $2]++ && !b[$3]++)}' > ${dataset_path}${dest}/ds.vcf
