# Parse input
if [[ -z ${maf} ]]; then maf=0.05; fi
if [[ -z ${geno} ]]; then geno=0.1; fi
if [[ -z ${imp} ]]; then imp="original"; fi
if [[ -z ${memory} ]]; then memory=500000; fi
if [[ -z ${threads} ]]; then threads=80; fi
if [[ -z ${stage} ]]; then stage=1; fi
if [[ -z ${hp}  ]]; then hp=""; fi
if [[ -z ${pop}  ]]; then pop=""; fi
if [[ -z ${pheno}  ]]; then pheno=""; fi
if [[ -z ${continuous}  ]]; then continuous="false"; fi
if [[ -z ${cv} ]]; then cv=""; fi
if [[ -z ${rep} ]]; then echo "please provide rep value" && exit 1; fi

sub=""

if [[ ! "${pheno}" == ""  ||  ! "${pop}" == "" ]]; then
	sub=_${pheno}_${pop}
fi

if [[ ! "${pheno}" == ""  ]]; then
        pheno=_${pheno}
fi

if [[ ! "${pop}" == "" ]]; then
        pop=_${pop}
fi