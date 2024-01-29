# .libPaths(c('../R-env/prs-R',.libPaths()))
source('constants.R')
source('utils.R')
source('calc_metrics_generic.R')

method="ld"
grid.ids.default <- paste(c(1:102),sep=",")
args <- commandArgs(trailing = TRUE)
parse.args(args, grid.ids.default, method)

calc.metrics(target.path, imp, prs.path, sub, grid.ids, prs.prefix, suffix, rep)