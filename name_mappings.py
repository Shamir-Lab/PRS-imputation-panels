import seaborn as sns

d_prs_names={

        # BCAC
        'D_bca_michailidou_2017':'D_bca_michailidou_2017' ,
        'UKB_bc_eur':'UKB_bc_eur',
        'bcac_onco_eur':'BCAC_eur',
        'bcac_onco_eur-minus-outliers':'BCAC_eur-minus-outliers',
        'bcac_onco_eur-1pcs':'BCAC_eur-1pcs',
        'bcac_onco_eur-2pcs':'BCAC_eur-2pcs',
        'bcac_onco_eur-3pcs':'BCAC_eur-3pcs',
        'bcac_onco_eur-4pcs':'BCAC_eur-4pcs',
        'bcac_onco_eur-5pcs':'BCAC_eur-5pcs',
        'bcac_onco_eur-6pcs':'BCAC_eur-6pcs',
        'bcac_onco_eur-6pcs':'BCAC_eur-3pcs2',

        # UKB
       'D2_chol_willer_2013':'Cholesterol',
       'D2_sysp_evangelou_2018':'Systolic BP',
       'D2_dias_evangelou_2018':'Diastolic BP',
       'D2_asth_zhu_2019':'Asthma',
       'D_t2d_mahajan_2018':'Type 2 Diabetes (old)',
       'D2_ldlp_willer_2013':'LDL levels',
       'D2_hdlp_willer_2013':'HDL levels',
       'D2_t2di_mahajan_2018':'Type 2 Diabetes',
       'D2_gerx_an_2019':'Reflux',
       'D2_madd_howard_2019':'Depression',
       'GC_utfi_morton_2019':'Uterine Fibroid',
       'UKB_t2d_eur':'Type 2 Diabetes (EUR-UKB)',
       'UKB_osar_eur':'Osteoarthritis (EUR-UKB)',
       'UKB_hfvr_eur':'Hay fever (EUR-UKB)',
       'UKB_chol_eur':'Cholesterol levels (EUR-UKB)',
       'UKB_ht_eur':'Hypertension (EUR-UKB)',
       'UKB_ast_eur':'Asthma (EUR-UKB)',
       'UKB_hyty_eur':'Hypotyroidism (EUR-UKB)',
       'UKB_gerx_eur':'Reflux (EUR-UKB)',
       'UKB_madd_eur':'Depression (EUR-UKB)',
       'UKB_angna_eur':'Angina (EUR-UKB)',
       'UKB_utfi_eur':'Uterine fibroilds (EUR-UKB)',
       'UKB_ctrt_eur':'Cataract (EUR-UKB)',
       'UKB_t2d_gbr':'Type 2 Diabetes (GBR-UKB)',
       'UKB_osar_gbr':'Osteoarthritis (GBR-UKB)',
       'UKB_hfvr_gbr':'Hay fever (GBR-UKB)',
       'UKB_chol_gbr':'Cholesterol levels (GBR-UKB)',
       'UKB_ht_gbr':'Hypertension (GBR-UKB)',
       'UKB_ast_gbr':'Asthma (GBR-UKB)',
       'UKB_hyty_gbr':'Hypotyroidism (GBR-UKB)',
       'UKB_gerx_gbr':'Reflux (GBR-UKB)',
       'UKB_madd_gbr':'Depression (GBR-UKB)',
       'UKB_angna_gbr':'Angina (GBR-UKB)',
       'UKB_utfi_gbr':'Uterine fibroilds (GBR-UKB)',
       'UKB_ctrt_gbr':'Cataract (GBR-UKB)'
 }


d_imp_names={
        'original':'No imputation',

        #AJ
        'impute2_1kg_afr2':'African',
        'impute2_1kg_sas2':'South-Asian',
        'impute2_1kg_eas2':'East-Asian',
        'impute2_1kg_eur2':'European',
        'impute2_ajkg14_t101':'AJ',

        'impute2_1kg_ceu2':'USA',
        'impute2_1kg_gbr2':'Britain',
        'impute2_1kg_fin2':'Finland',
        'impute2_1kg_tsi2':'Italy',
        'impute2_1kg_ibs2':'Spain',
        'impute2_1kg_eur-ajkg14-t101-merged': "European\n+AJ",

        #BCAC
        'impX': "impX",
        'impX_new': "impX_new",
        'impX_313': "impX_313",
        'impX2': "impX2",

        #UKB
        'impute2_1kg_afr':'African',
        'impute2_1kg_sas':'South-Asian',
        'impute2_1kg_eur':'European', #  (500)',
        'impute2_1kg_gbr':'Britain',
        'impute2_1kg_ibs':'Spain',
        'impute2_1kg_eur-minus-gbr':'European-without-British (400)',
        'impute2_1kg_eur100-minus-gbr':'European-without-British (100)',
        'impute2_1kg_eur100':'European (100)',
        'imputeX_new':'UKB',


        #GAIN
        'PGC2_noAJ':'PGC2_noAJ',
        'D_scz_ripke_2011':'Ripke 2011',
        'D_scz_ripke_2014':'Ripke 2014',
        'D_scz_pardinas_2018':'Pardinas 2018'
}

d_target_names={
        'bcac_onco_aj':'AJ',

        'ukbb_afr':'African',
        'ukbb_sas':'South-Asian',
        'ukbb_eur':'European',
        'ukbb_gbr':'Britian'
}

eur_pops=["ceu", "gbr", "fin", "tsi", "ibs"]
l_imps=["impute2_1kg_eur2", "impute2_1kg_eas2", "impute2_1kg_afr2", "impute2_ajkg14_t101"] +\
        [f"impute2_1kg_{a}2" for a in eur_pops] + ["impute2_1kg_ceu-gbr2", "impute2_1kg_kdv2"] +\
        [f"impute2_1kg_eur-minus-{a}2" for a in eur_pops] +\
        [f"impute2_1kg_{a}-ajkg14-t101-merged" for a in eur_pops] +\
        [f"impute2_1kg_eur-minus-{a}-ajkg14-t101-merged" for a in eur_pops] +["impute2_1kg_eur-ajkg14-t101-merged"] +\
        ["impX", "impX_new"] + \
        ["imputeX_new" , "impute2_1kg_eur", "impute2_1kg_sas", "impute2_1kg_afr", "impute2_1kg_gbr", "impute2_1kg_ibs", "impute2_1kg_eur-minus-gbr", "impute2_1kg_eur100", "impute2_1kg_eur100-minus-gbr"]

d_methods={
        'pt':'P+T old (EUR LD)',
        'pt3':'P+T (EUR LD)',
        'pt2':'P+T (target set LD)',
        'ls':'Lassosum',
        'ld':'LDpred2'
}

d_metrics={
        'all':'OR per 1SD',
        'or.all':'OR per 1SD',
        '99':'top 90% OR'
}

d_phenos_public_to_ukb={
    "sysp": "ht",
    "dias": "ht",
    "t2di": "t2d",
    "asth": "ast",
    "hdlp": "chol",
    "ldlp": "chol"

}


cs = (list(sns.color_palette("bright")) + list(sns.color_palette("pastel"))) * 10
