# .libPaths(c('../R-env/prs-R',.libPaths()))
source('constants.R')
source('utils.R')

library(dplyr)
library(lassosum)
# Prefer to work with data.table as it speeds up file reading
library(data.table)
library(methods)
library(magrittr)
# For multi-threading, you can use the parallel package and
# invoke cl which is then passed to lassosum.pipeline

library(parallel)


grid.ids.default <- "0.2,0.5,0.9,1"
method<-'ls'
args <- commandArgs(trailing = TRUE)
parse.args(args, grid.ids.default,method)


print("0. Prepare workspace")
# This will invoke multiple threads.
cl <- makeForkCluster(7)

# print("1. Read in the phenotype and covariate files")

print('Read in the phenotype file')
ds.train.file.name <- paste(imp.train.path, paste0(ds.prefix, train.suffix), sep="/")
ds.test.file.name <- paste(imp.test.path, paste0("ds", test.suffix), sep="/")
# pheno.test.file.name <- paste(imp.test.path, paste0("pheno", sub, test.suffix), sep="/")
# print(paste0("pheno file: ", pheno.test.file.name))
print(paste0("train bed file: ", ds.train.file.name))
print(paste0("test bed file: ", ds.test.file.name))
# phenotype <- read.table(pheno.test.file.name, header=T)
# print('Filter samples w/o phenotype')
# phenotype=phenotype[phenotype$label!=-1,]

# print("Calibrate label values")
# phenotype[,'label']<- phenotype[,'label']-1

# print('Read in the PCs')
# pcs <- read.table(paste(imp.test.path, paste0("ds", sub, test.suffix,".eigenvec"), sep="/"), header=F)
# pcs <- pcs[,1:8]

# print('rename columns')
# colnames(pcs) <- c("FID","IID", paste0("PC",1:6))
# print('generate required table')
# pheno <- merge(phenotype, covariate) %>%
#     merge(., pcs)
# pheno <- merge(phenotype,pcs)

if(ld=="eas"){
    ld="asn"
}

ld <- paste0(toupper(ld),".hg19") # "EUR.hg19" # read.table(paste(ds.path, paste0(ds.prefix,".ld.bed"), sep="/"), header=F)
print(paste0("ld: ",ld))

print("Read in the summary statistics")
sumstats <- read.table(paste(discovery.path, "gwas.QC.gz", sep="/"), header=T)

print("Remove P-value = 0, which causes problem in the transformation")
sumstats <- sumstats[!sumstats$P == 0,]
sumstats <- na.omit(sumstats) # [complete.cases(sumstats),]

print("Transform the P-values into correlation")
cor <- p2cor(p = sumstats$P, n = sumstats$N, sign = sumstats$OR)

print("Run the lassosum pipeline")

# The cluster parameter is used for multi-threading
# You can ignore that if you do not wish to perform multi-threaded processing
out <- lassosum.pipeline(
    cor = cor,
    chr = sumstats$CHR,
    pos = sumstats$BP,
    A1 = sumstats$A1,
    A2 = sumstats$A2,
    s = c(0.2, 0.5, 0.9, 1), # as.numeric(unlist(hp)),
    ref.bfile = ds.train.file.name,
    # test.bfile = ds.test.file.name,
    LDblocks = ld,
    cluster=cl
)

print('Writing PRS values to files')
bim <- fread(paste0(ds.train.file.name, ".bim"), header=F)
cols <- names(out$beta)
phase<-0
fnames<-c()
for (a in cols){
    res<-cbind(bim[out$test.extract, ], out$beta[[a]])
    colnames(res)<-as.character(1:ncol(res))
    for (b in c(1:dim(out$beta[[a]])[2])){
        output<-select(res,c(1,2,4,5,6,6+b))
        output.tmp <-output[as.vector(output[,6]!=0),]
        if(dim(output.tmp)[1]>0){
            output<-output.tmp
        } else {
            output<-output[c(1:100),]
        }
        fname<-paste0(prs.prefix, train.suffix,".",paste(a,b,sep="-"),".weights")
        print(paste0('out file: ',paste(prs.path,'lasso',fname, sep='/')))
        write.table(output, paste(prs.path,'lasso',fname, sep='/'), row.names = FALSE, col.names = FALSE, sep='\t', quote=FALSE)
        fnames<-c(fnames, fname)
    }
    phase <- phase+1
}
write(fnames, file = paste(prs.path,'lasso','all', sep='/'), sep='\n')



# print('Writing PRS values to files')
# cols <- names(out$pgs)
# phase<-0
# fam <- fread(paste0(ds.test.file.name, ".fam"), header=F)
# colnames(fam)[1] <-'FID'
# colnames(fam)[2] <-'IID'

# for (a in cols){
#     for (b in c(1:dim(out$pgs[[a]])[2])){
#         fam$SCORE <- out$pgs[[a]][,b]
#         write.table(fam[,c('FID','IID', 'SCORE')], paste(prs.path,paste0(prs.prefix, test.suffix,".",paste(a,b,sep="-"),".profile"), sep='/'), row.names = FALSE, sep='\t', quote=FALSE)
#     }
#     phase <- phase+1
# }

# print("Store the R2 results")
# target.res <- validate(out, pheno = phenotype, covar=as.data.frame(pheno), plot=F)

# print("Get the maximum R2")
# r2 <- max(target.res$validation.table$value)^2
# print(r2)

print("Done!")


