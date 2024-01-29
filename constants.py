import os

PUBLIC_BASE_PATH = '/specific/elkon/hagailevi/PRS/'
PRIVATE_BASE_PATH = '/specific/netapp5/gaga/gaga-pd/prs_data'
GWASS_PATH = os.path.join(PUBLIC_BASE_PATH, 'GWASs/')
DATASETS_PATH = os.path.join(PRIVATE_BASE_PATH, "datasets", "dec")
PRSS_PATH = os.path.join(PRIVATE_BASE_PATH, 'PRSs/')
OUTPUT_PATH = os.path.join(PRIVATE_BASE_PATH, 'output/')
FIGURES_PATH = os.path.join(OUTPUT_PATH, 'figures/')

gwas_to_pheno={'D2_hght_yengo_2018':'height',
               'D2_ldlp_willer_2013':'chol',
               'D2_hdlp_willer_2013':'chol',
               'D2_chol_willer_2013':'chol',
               'D2_sysp_evangelou_2018':'ht',
                'D2_dias_evangelou_2018':'ht',
               'D2_asth_zhu_2019':'ast',
               'D2_t2di_mahajan_2018':'t2d',
               'D2_gerx_an_2019':'gerx',
               'D2_madd_howard_2019':'madd',
               'UKB_ctrt_eur':'ctrt',
               'UKB_angna_eur':'angna',
               'UKB_utfi_eur':'utfi',
               'UKB_t2d_eur':'t2d',
               'UKB_osar_eur':'osar',
               'UKB_hfvr_eur':'hfvr',
               'UKB_hght_eur':'hght',
               'UKB_chol_eur':'chol',
               'UKB_ht_eur':'ht',
               'UKB_ast_eur':'ast',
               'UKB_hyty_eur':'hyty',
               'UKB_gerx_eur':'gerx',
               'UKB_madd_eur':'madd',
               'GC_ctrt_sakaue_2021': 'ctrt',
               'GC_angna_sakaue_2021': 'angna',
               'GC_utfi_sakaue_2021': 'utfi',
               'GC_t2d_sakaue_2021': 't2d',
               'GC_osar_sakaue_2021': 'osar',
               'GC_hfvr_sakaue_2021': 'hfvr',
               'GC_hght_sakaue_2021': 'hght',
               'GC_chol_sakaue_2021': 'chol',
               'GC_sysp_sakaue_2021': 'ht',
               'GC_ast_sakaue_2021': 'ast',
               'GC_hyty_sakaue_2021': 'hyty',
               'GC_gerx_sakaue_2021': 'gerx',
               'GC_madd_sakaue_2021': 'madd'
               } # ['D2_hdlp_willer_2013']='chol' ['D_t2d_mahajan_2018']='t2d'

