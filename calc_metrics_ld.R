# .libPaths(c('../R-env/prs-R',.libPaths()))
source('constants.R')
source('utils.R')
source('calc_metrics_generic.R')

method="ld"
grid.ids.default<-c(1:102)
args <- commandArgs(trailing = TRUE)
parse.args(args, grid.ids.default, method)

calc.metrics(target.path, imp.name, prs.rep.path, sub, grid.ids, prs.prefix, cv.test.suffix)
