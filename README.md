# PRS-imputation-panels
This reposity contains the underlying source code for analysis in the paper [*The predictive capacity of polygenic risk scores for disease risk is only moderately influenced by imputation panels tailored to the target population*](https://academic.oup.com/bioinformatics/advance-article/doi/10.1093/bioinformatics/btae036/7587512) by Levi el al.

Below is the description of the main source files 

- QC data
  - `qc_discovery_data.sh`: QC of the discovery data
  - `qc_discovery_data.sh` : QC of the target data

- cross validation (CV) analysis:
  - `calc_prs_cv_<method>.sh`: calculates PRS
  - `calc_metrics_<method>`: calculates the performance of a specific fold 
  - `run_folds_<method>.sh`: executes nested CV

- Figures and tables generation:
  - Notebooks/aggregate_results.ipynb`: summarzies the data 
  - Notebooks/generate_figures_and_tables.ipynb`: Explains how to generate figures and plots
 

#### Note that the source files were tailored to the specific configuration of the development enviroment.
  
