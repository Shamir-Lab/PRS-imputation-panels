# PRS-imputation-panels
This reposity contains scripts used in the study [*"The predictive capacity of polygenic risk scores for disease risk is only moderately influenced by imputation panels tailored to the target population"*, by Levi, Elkon and Shamir (Bioinformatics 2024, DOI: 10.1093/bioinformatics/btae036)](https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/btae036/7587512).

Below is the description of the main source files 

- QC data
  - `qc_discovery_data.sh`: QC of the discovery data
  - `qc_discovery_data.sh` : QC of the target data

- cross validation (CV) analysis. Note that method can be one of the following strings: pt2 (P+T target set LD),pt3 (P+T EUR/EAS LD),ls (Lassosum),ld (LDpred):
  - `calc_prs_cv_<method>.sh`: calculates PRS
  - `calc_metrics_<method>`: calculates the performance of a specific fold 
  - `run_folds_<method>.sh`: executes nested CV

- Figures and tables generation:
  - `Notebooks/aggregate_results.ipynb`: summarzies the data 
  - `Notebooks/generate_figures_and_tables.ipynb`: explains how to generate figures and plots
 

#### Note that the source files were tailored to the specific configuration of the development enviroment.
  
