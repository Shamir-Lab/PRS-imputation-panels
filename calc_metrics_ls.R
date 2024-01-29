# .libPaths(c('../R-env/prs-R',.libPaths()))
source('constants.R')
source('utils.R')
source('calc_metrics_generic.R')

method="ls"
grid.ids.default <- c(0.2,0.5,0.9,1)
grid.ids.full=c()
for(a in grid.ids.default){
    for(b in seq(1,20)){
        grid.ids.full <- paste(grid.ids.full, paste0(a,"-",b), sep= ",")
    }
}
grid.ids.full<- substring(grid.ids.full, 2)

args <- commandArgs(trailing = TRUE)
parse.args(args, grid.ids.full, method)

calc.metrics(target.path, imp, prs.path, sub, grid.ids, prs.prefix, test.suffix, rep, analysis.type)
# calc.metrics(target.path, imp.name, prs.rep.path, sub, grid.ids.full, prs.prefix, suffix, rep, analysis.type)


