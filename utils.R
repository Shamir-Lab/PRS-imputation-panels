# .libPaths(c('../R-env/prs-R',.libPaths()))
options(gsubfn.engine = "R")
library(gsubfn)
library(hash)
source('constants.R')

parse.sub <- function(sub, analysis.type){
    print(sub)
    if (is.na(sub) || is.null(sub) || sub=="" || is.function(sub)){
        sub=""
        if(analysis.type=="cv"){
            sub="__"
        }
        pop=""
        pheno.name=""
    } else {
        s=unlist(strsplit(sub, "_"))

        if (is.na(s[2])){
            pheno.name<-""
        } else {
            pheno.name<-paste0("_",s[2])
        }

        if (is.na(s[3])){
            pop<-""
        } else {
            pop<-paste0("_",s[3])
        }
    }
    return(c(sub, pop, pheno.name))
}

parse.rep <- function(rep, method, sub, analysis.type){
    if (analysis.type=='cv'){
        rep.folder <- paste0("rep_",rep)
        prs.prefix<-paste0("prs.cv.",method,sub)
        ds.prefix<-paste0("ds",sub)
    } else if (analysis.type=='cross'){
        rep.folder <- ""
        prs.prefix<-paste0("prs.cross.",method,sub)
        ds.prefix<-paste0("ds.QC",sub) # .QC
    }
    else if (analysis.type=='mono'){
        rep.folder <- ""
        prs.prefix<-paste0("prs.mono.",method,sub)
        ds.prefix<-paste0("ds",sub)
    } else {
        rep.folder <- ""
        prs.prefix<-paste0("prs.",method,sub)
        ds.prefix<-paste0("ds",sub)
    }

    return(c(rep.folder, prs.prefix, ds.prefix))
}

parse.grid.ids <- function(grid.ids,grid.ids.default){

    print(grid.ids)
    print(grid.ids.default)
    if (is.null(grid.ids) || is.na(grid.ids) || grid.ids=="") {
         grid.ids<-grid.ids.default
    }

    grid.ids<-unlist(strsplit(grid.ids, ","))
    lst<-list()
    i<-1
    for(a in grid.ids){
        lst[[i]]<-as.numeric(unlist(strsplit(a, "-")))
        i<-i+1
    }
    hp <- lst

    print(hp)
    print(grid.ids)
    return(list(hp, grid.ids))
}


parse.args <- function(input, grid.ids.default='', method=''){
    # Raw args
    args <- hash()

    # processed args
    params<- hash()

    arg.pos <-1
    cur.arg <- input[arg.pos]
    print(cur.arg)
    while(!is.na(cur.arg)){
        print(cur.arg)
        cur.arg<-substring(cur.arg,3)
        cur.arg <- unlist(strsplit(cur.arg, '='))
        args[[cur.arg[1]]] <- cur.arg[2]
        arg.pos <- arg.pos+1
        cur.arg <- input[arg.pos]
    }

    params[['discovery']] <- args[['discovery']]

    params[['target']] <- args[['target']]
    params[['target.train']] <- args[['target_train']]
    params[['target.test']] <- args[['target_test']]
    if(is.null(params[['target.train']])){
        params[['target.train']] <- args[['target']]
        params[['target.test']] <-  args[['target']]
    }
    params[['target']] <- params[['target.test']]

    params[['analysis.type']] <- args[['analysis_type']]
    if(is.null(params[['analysis.type']]) || params[['analysis.type']]=='' ){
        params[['analysis.type']]='mono'
    }
        if(is.null(params[['method']]) || params[['method']]=='' ){
        params[['method']]=''
    }

    params[['imp']] <- args[['imp']]
    params[['imp.train']] <- args[['imp_train']]
    params[['imp.test']] <- args[['imp_test']]
    if(is.null(params[['imp.train']])){
        params[['imp.train']] <- args[['imp']]
        params[['imp.test']] <-  args[['imp']]
    }
    params[['imp']] <- params[['imp.test']]

    params[['ld']] <- args[['ld']]

    params[['sub']] <- args[['sub']]

    params[['grid_ids']] <- args[['grid_ids']]

    params[['suffix']] <- args[['suffix']]
    if(is.null(args[['suffix']]) || is.na(args[['suffix']])){
        params[['suffix']] <- ""
    }
    params[['train.suffix']] <- args[['train_suffix']]
    params[['test.suffix']] <- args[['test_suffix']]
    print("here0")
    if(is.null(params[['train.suffix']]) || is.na(params[['train.suffix']])){
        print("here")
        print(params[['train.suffix']])
        params[['train.suffix']] <- params[['suffix']]
        params[['test.suffix']] <-  params[['suffix']]
    }
    params[['suffix']] <- params[['test.suffix']]

    params[['rep']] <- args[['rep']]

    params[['sample']] <- args[['sample']]
    if(! is.null(params[['sample']]) && ! is.na(params[['sample']])){
        print(args[['sample']])
        params[['sample.folder']] <- paste0("sample_",args[['sample']])
        params[['sample.train.folder']] <- paste0("sample_",unlist(strsplit(args[['sample']], "_"))[1])
    }

    list[params[['sub']], params[['pop']], params[['pheno.name']]] <- parse.sub(params[['sub']], params[['analysis.type']])


    list[params[['rep.folder']], params[['prs.prefix']], params[['ds.prefix']]] <- parse.rep(params[['rep']], method, params[['sub']], params[['analysis.type']])


    list[params[['hp']], params[['grid.ids']]] <- parse.grid.ids(params[['grid_ids']], grid.ids.default)

    for(cur.key in keys(params)){
        assign(cur.key, params[[cur.key]], envir=.GlobalEnv)
    }

    params[['discovery.path']] <-paste(GWASS_PATH, discovery, sep='/')

    params[['target.path']] <-paste(DATASETS_PATH, target, sep='/')
    params[['target.train.path']] <-paste(DATASETS_PATH, target.train, sep='/')
    params[['target.test.path']] <-paste(DATASETS_PATH, target.test, sep='/')

    params[['imp.path']] <-paste(DATASETS_PATH, target, sep='/')
    params[['imp.train.path']] <-paste(params[['target.train.path']], imp.train, sep='/')
    params[['imp.test.path']] <-paste(params[['target.test.path']], imp.test, sep='/')
    params[['prs.path']]<-paste(PRSS_PATH, paste(discovery, target, sep='_'), imp, sep='/')

    params[['cov.path']]<-paste(DATASETS_PATH, target, sep='/')
    if(params[['analysis.type']]=='cv'){
        params[['target.path']]<-paste(DATASETS_PATH, target, rep.folder, sep='/')
        params[['target.train.path']]<-params[['target.path']]
        params[['target.test.path']]<-params[['target.path']]

        params[['imp.path']]<-paste(DATASETS_PATH, target, rep.folder, imp, sep='/')
        params[['imp.train.path']]<-params[['imp.path']]
        params[['imp.test.path']]<-params[['imp.path']]

        params[['prs.path']] <-paste(PRSS_PATH, paste(discovery, target, sep='_'), imp, rep.folder, sep='/')
    } else if(params[['analysis.type']]=='sample'){
        params[['target.path']]<-paste(DATASETS_PATH, target, sample.folder, sep='/')
        params[['target.train.path']]<-paste(DATASETS_PATH, target, sample.train.folder, sep='/')
        params[['target.test.path']]<-paste(DATASETS_PATH, target, sample.folder, sep='/')

        params[['imp.path']]<-paste(DATASETS_PATH, target, sample.folder, imp, sep='/')
        params[['imp.train.path']]<-paste(DATASETS_PATH, target, sample.train.folder, imp, sep='/')
        params[['imp.test.path']]<-paste(DATASETS_PATH, target, sample.folder, imp, sep='/')

        params[['prs.path']] <-paste(PRSS_PATH, paste(discovery, target, sep='_'), imp, sample.folder, sep='/')
    } else if(params[['analysis.type']]=='cross'){
        params[["prs.path"]]<-paste(PRSS_PATH, paste(discovery,target,sep='_'), imp, paste0("cross_",target.train), imp.train, sep='/')
    }

    print("==========")
    for(cur.key in keys(params)){
        print(paste0(cur.key,": ", params[[cur.key]]))
        assign(cur.key, params[[cur.key]], envir=.GlobalEnv)
    }
    print("==========")

}
