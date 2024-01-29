# .libPaths(c('../R-env/prs-R',.libPaths()))
source('constants.R')
source('utils.R')
library(readr)
source('calc_metrics_generic.R')

method="pt3"
grid.ids.default <- "0.00000005,0.0000001,0.000001,0.00001,0.0001,0.001,0.005,0.01,0.05,0.1,0.2,0.3,0.4,0.5"
args <- commandArgs(trailing = TRUE)
parse.args(args, grid.ids.default, method)

calc.metrics(target.path, imp, prs.path, sub, grid.ids, prs.prefix, test.suffix, rep, analysis.type)
