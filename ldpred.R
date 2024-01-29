.libPaths(c('../R-env/prs-R',.libPaths()))

source('constants.R')
source('utils.R')

library(bigsnpr)
library(data.table)
library(magrittr)
library(fmsb)
library(runonce)

grid.ids.default <- "0.5"
method<-'ld'
args <- commandArgs(trailing = TRUE)
parse.args(args, grid.ids.default,method)



print("0. Prepare workspace")
options(bigstatsr.check.parallel.blas = FALSE)
options(default.nproc.blas = NULL)

print("1. Read in the phenotype and covariate files")
# phenotype <- fread("EUR.height")
# covariate <- fread("EUR.cov")
# pcs <- fread("EUR.eigenvec")

print('Read in the phenotype file')
pheno.test.file.name <- paste(target.path, paste0("pheno", sub, test.suffix), sep="/") # ,sub
print(pheno.test.file.name)
phenotype <- read.table(pheno.test.file.name, header=T)
print('Filter samples w/o phenotype')
phenotype <- phenotype[phenotype$label!=-1,]
print('Calibrate label values')
phenotype[,'label']=phenotype[,'label']-1
print('Read in the PCs')
pca.test.file.name <- paste(imp.test.path, paste0("ds",sub,test.suffix,".eigenvec"), sep="/")
pcs <- read.table(pca.test.file.name, header=F)
pcs <- pcs[,1:8]

print('Rename columns')
colnames(pcs) <- c("FID","IID", paste0("PC",1:6))
print('Generate required table')
# pheno <- merge(phenotype, covariate) %>%
#     merge(., pcs)
pheno <- merge(phenotype,pcs)

sumstats.file.name <-paste(discovery.path , "sumstats.file.rds", sep="/")
if(file.exists(sumstats.file.name) && F){
    sumstats <- readRDS(sumstats.file.name)
} else {
    print("2. Obtain HapMap3 SNPs")
    info <- readRDS(runonce::download_file(
      "https://ndownloader.figshare.com/files/25503788",
      fname = "map_hm3_ldpred2.rds"))

    print("3. Load and transform the summary statistic file")

    print('Read in the summary statistic file')
    # sumstats <- bigreadr::fread2("Height.QC.gz")
    sumstats <- read.table(paste(discovery.path, paste0("gwas.QC.gz"), sep="/"), header=T)

    print('Rename header to follow LDpred 2 naming convension')
    names(sumstats) <- c("rsid", "chr", "pos", "a1", "a0", "MAF", "beta_se", "p", "n_eff", "INFO", "beta")

    # print('Transform the OR into log(OR)')'
    # sumstats$beta <- log(sumstats$OR)

    print('Filter out hapmap SNPs')
    sumstats <- sumstats[sumstats$rsid%in% info$rsid,]

    saveRDS(sumstats,sumstats.file.name)
}

print("3 (2). Calculate the LD matrix")

print("Get maximum amount of cores")
NCORES <- 40 # nb_cores()

print("Open a temporary file")
cache.folder <- paste(paste(prs.path, sep='/') ,"tmp-data", sep="/")
unlink(cache.folder, recursive=TRUE)
tmp <- tempfile(tmpdir = cache.folder)
on.exit(file.remove(paste0(tmp, ".sbk")), add = TRUE)

print("Initialize variables for storing the LD score and LD matrix")
corr <- NULL
ld <- NULL
fam.order <- NULL
print("We want to know the ordering of samples in the train bed file")

print("Read in the train bed file")
ds.train.file.name <- paste(imp.train.path, paste0(ds.prefix,train.suffix), sep="/")
ds.train.processed.rds.file.name=paste0(ds.train.file.name, ".rds")
ds.train.processed.bk.file.name=paste0(ds.train.file.name, ".bk")
if (!file.exists(ds.train.processed.rds.file.name) || !file.exists(ds.train.processed.bk.file.name)){
    if (file.exists(ds.train.processed.rds.file.name)) {
        print("Removing old (orphan) rds file")
        file.remove(ds.train.processed.rds.file.name)
    }
    if (file.exists(ds.train.processed.bk.file.name)) {
        print("Removing old (orphan) bk file")
        file.remove(ds.train.processed.bk.file.name)
    }
    print("preprocess the bed file (only need to do once for each data set)")
    snp_readBed(paste0(ds.train.file.name,".bed"))
}
print("now attach the train genotype object")
obj.bigSNP.train <- snp_attach(ds.train.processed.rds.file.name)

print("extract the SNP information from the genotype")
map <- obj.bigSNP.train$map[-3]
names(map) <- c("chr", "rsid", "pos", "a1", "a0")
print("perform SNP matching")
info_snp <- snp_match(sumstats, map, join_by_pos = FALSE)
print("Assign the genotype to a variable for easier downstream analysis")
genotype.train <- obj.bigSNP.train$genotypes

print("Read in the test bed file")
ds.test.file.name <- paste(imp.test.path, paste0(ds.prefix,test.suffix), sep="/")
ds.test.processed.rds.file.name=paste0(ds.test.file.name, ".rds")
ds.test.processed.bk.file.name=paste0(ds.test.file.name, ".bk")
if (!file.exists(ds.test.processed.rds.file.name) || !file.exists(ds.test.processed.bk.file.name)){
    if (file.exists(ds.test.processed.rds.file.name)) {
        print("Removing old (orphan) rds file")
        file.remove(ds.test.processed.rds.file.name)
    }
    if (file.exists(ds.test.processed.bk.file.name)) {
        print("Removing old (orphan) bk file")
        file.remove(ds.test.processed.bk.file.name)
    }
    print("preprocess the bed file (only need to do once for each data set)")
    snp_readBed(paste0(ds.test.file.name,".bed"))
}

print("now attach the test genotype object")
obj.bigSNP.test <- snp_attach(ds.test.processed.rds.file.name)

# if(!file.exists("test.file")){

print("Rename the data structures")
ld.file.name<-paste(imp.train.path ,"ld.RData", sep="/")
corr.file.name<-paste(imp.train.path ,"corr.RData", sep="/")

# } ## END COMMENT

if (file.exists(ld.file.name) && file.exists(corr.file.name) && F){
    load(ld.file.name)
    load(corr.file.name)
    # ld <- readRDS(ld.file.name)
    # corr <- readRDS(corr.file.name)
} else {
    CHR <- map$chr
    POS <- map$pos
    dir <- "/specific/elkon/hagailevi/data-scratch/1kg_cm_ldpred"
    print("get the CM information from 1000 Genome")
    print(paste0("will download the 1000G file to", dir))
    POS2 <- snp_asGeneticPos(CHR, POS, dir = dir)
    print('calculate LD')
    for (chr in 1:22) {
        print("Extract SNPs that are included in the chromosome")
        ind.chr <- which(info_snp$chr == chr)
        ind.chr2 <- info_snp$`_NUM_ID_`[ind.chr]
        print(paste0("Calculate the LD for chromosome ",chr))
        corr0 <- snp_cor(
                genotype.train,
                ind.col = ind.chr2,
                ncores = NCORES,
                infos.pos = POS2[ind.chr2],
                size = 3 / 1000
            )
        if (sum(is.na(corr0))!=0){
            print (paste0("found NA in chr",chr, "(n=", sum(is.na(corr0)),")"))
            corr0[is.na(corr0)]<-1
        } else{
            print (paste("no NA in chr",chr))
        }
        if (chr == 1) {
            ld <- Matrix::colSums(corr0^2)
            corr <- as_SFBM(corr0, tmp)
        } else {
            ld <- c(ld, Matrix::colSums(corr0^2))
            corr$add_columns(corr0, nrow(corr))
        }
    }
#     save(ld, file=ld.file.name)
#     save(corr, file=corr.file.name)
}

print("We assume the fam order is the same across different chromosomes")
fam.order <- as.data.table(obj.bigSNP.test$fam)
print("Rename fam order")
setnames(fam.order,
        c("family.ID", "sample.ID"),
        c("FID", "IID"))

print("4. Perform LD score regression")

df_beta <- info_snp[,c("beta", "beta_se", "n_eff", "_NUM_ID_")]
ldsc <- snp_ldsc(   ld,
                    length(ld),
                    chi2 = (df_beta$beta / df_beta$beta_se)^2,
                    sample_size = df_beta$n_eff,
                    blocks = NULL)
h2_est <- ldsc[["h2"]]

print("5. (a) Reformat the phenotype file such that y is of the same order as the sample ordering in the genotype file")
# y <- pheno[fam.order, on = c("FID", "IID")]
y <- pheno[order(fam.order[,1], fam.order[,2]),]

print('5. (b) Generate regression model W/O PRS and calculate null R2')

# null.model <- paste("PC", 1:6, sep = "", collapse = "+") %>% # paste0("Height~Sex+", .) %>%
#     as.formula %>%
#     glm(., data = y, family=binomial) %>%
#     summary
print('Generate GLM')
null.model <- glm(label~.,data=pheno[,!colnames(pheno)%in%c("FID", "IID")], family=binomial(link="logit"))

print('Calculate NagelkerkeR2')
null.r2 <- fmsb::NagelkerkeR2(null.model)$R2


print("Prepare data for grid model")
beta.grid.file.name <- paste(imp.train.path ,"beta.grid.rds", sep="/")
if (file.exists(beta.grid.file.name) && F){
    readRDS(beta.grid.file.name)
} else {
    p_seq <- signif(seq_log(1e-4, 1, length.out = 17), 2)
    h2_seq <- round(h2_est * c(0.7, 1, 1.4), 4)
    grid.param <-
        expand.grid(p = p_seq,
                h2 = h2_seq,
                sparse = c(FALSE, TRUE))

    print("Get adjusted beta from grid model")
    beta_grid <-
        snp_ldpred2_grid(corr, df_beta, grid.param, ncores = NCORES)
#     saveRDS(beta_grid, beta.grid.file.name)
}



# saveRDS(beta_grid, "test.file")
# }
# beta_grid <- readRDS("test.file")

print("7. Obtain model PRS")

print("Impute missing values")
genotype.file.name <- paste(imp.train.path ,"genotype.rds", sep="/")
if (file.exists(genotype.file.name) && F){
    readRDS(genotype.file.name)
} else {
    genotype.test <- obj.bigSNP.test$genotypes
    # genotype.test <- snp_fastImputeSimple(genotype.test)
    # saveRDS(genotype.test, genotype.file.name)
}




print("Save beta weights to disk")

fnames<-c()
for(a in 1:ncol(beta_grid)){
    if(!is.na(beta_grid[,a])){
        output<-cbind(info_snp[,c("chr","rsid","pos","a0","a1")],beta_grid[,a])
        fname<-paste0(prs.prefix, train.suffix,".",a,".weights")
        print(paste0('out file: ',paste(prs.path,'ldpred',fname, sep='/')))
        write.table(output, paste(prs.path,'ldpred',fname, sep='/'), row.names = FALSE, col.names = FALSE, sep='\t', quote=FALSE)
        fnames<-c(fnames, fname)
    }
}
write(fnames, file = paste(prs.path,'ldpred','all', sep='/'), sep='\n')


# print("calc PRS")
# pred_grid <- big_prodMat(genotype.test, beta_grid, ind.col = info_snp$`_NUM_ID_`)

# print('Generate regression model WITH PRS and calculate real R2')
# print(y[,!colnames(y)%in%c("FID", "IID")])
# reg.formula <- paste("PC", 1:6, sep = "", collapse = "+") %>%
#     paste0("Height~PRS+Sex+", .) %>%
#    as.formula
# reg.dat <- y
# grid.model <- glm(label~., dat=reg.dat, family=binomial) %>%
#     summary

# max.r2 <- 0

# for(i in 1:ncol(pred_grid)){
#     y$SCORE <- pred_grid[,i]
#     if (is.na(pred_grid[1,i])){
#         next
#     }
#     print('Prepare data format')
#     write.table(y[,c('FID','IID', 'SCORE')], paste(prs.path, paste0(prs.prefix,test.suffix,".",i,".profile"), sep='/'), row.names = FALSE, sep='\t', quote=FALSE)
#     print('generate GLM')
#     grid.model <- glm(label~.,data=y[,!colnames(y)%in%c("FID", "IID")], family=binomial(link="logit"))
#     print('Calculate NagelkerkeR2')
#     cur.r2 <-fmsb::NagelkerkeR2(grid.model)

#     if(max.r2 < cur.r2$R2){
#         max.r2 <- cur.r2$R2
#     }
# }
# result <- data.table(
#     grid = max.r2 - null.r2,
#     null = null.r2,
#     full = max.r2
# )

# print(result)
