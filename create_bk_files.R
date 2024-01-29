source('constants.R')
library('bigsnpr')
library(hash)

snp_readBed_1_stage <- function(bedfile, backingfile = sub_bed(bedfile)) {

  print('Check if backingfile already exists')
  backingfile <- path.expand(backingfile)
  #bigsnpr:::assert_noexist(paste0(backingfile, ".bk"))

  print('Get other files')
  bimfile <- bigsnpr:::sub_bed(bedfile, ".bim")
  famfile <- bigsnpr:::sub_bed(bedfile, ".fam")
  # Check if all three files exist
  # sapply(c(bedfile, bimfile, famfile), bigsnpr:::assert_exist)

  print('Read map and family files')
  fam <- bigreadr::fread2(famfile, col.names = bigsnpr:::NAMES.FAM, nThread = 1)
  bim <- bigreadr::fread2(bimfile, col.names = bigsnpr:::NAMES.MAP, nThread = 1)

  print('Prepare Filebacked Big Matrix')
  bigGeno <- FBM.code256(
    nrow = nrow(fam),
    ncol = nrow(bim),
    code = CODE_012,
    backingfile = backingfile,
    init = NULL,
    create_bk = TRUE
  )

  print('Fill the FBM from bedfile')
  reach.eof <- bigsnpr:::readbina(path.expand(bedfile), bigGeno, bigsnpr:::getCode())
  # tryCatch({
  # reach.eof <- withTimeout(bigsnpr:::readbina(path.expand(bedfile), bigGeno, bigsnpr:::getCode()), timeout=10)}, TimeoutException = function(ex) {
  # message("Timeout. Skipping.")
  # })

  if (!reach.eof) warning("EOF of bedfile has not been reached.")

  print('Create the bigSNP object')
  snp.list <- structure(list(genotypes = bigGeno, fam = fam, map = bim),
                        class = "bigSNP")

  print('save it and return the path of the saved object')
  rds <- sub_bk(bigGeno$backingfile, ".rds")
  saveRDS(snp.list, rds)
  rds
}

snp_readBed_2_stage <- function(bedfile, backingfile = sub_bed(bedfile)) {

  print('Check if backingfile already exists')
  backingfile <- path.expand(backingfile)
  #bigsnpr:::assert_noexist(paste0(backingfile, ".bk"))

  print('Get other files')
  bimfile <- bigsnpr:::sub_bed(bedfile, ".bim")
  famfile <- bigsnpr:::sub_bed(bedfile, ".fam")
  # Check if all three files exist
  # sapply(c(bedfile, bimfile, famfile), bigsnpr:::assert_exist)

  print('Read map and family files')
  fam <- bigreadr::fread2(famfile, col.names = bigsnpr:::NAMES.FAM, nThread = 1)
  bim <- bigreadr::fread2(bimfile, col.names = bigsnpr:::NAMES.MAP, nThread = 1)

  print('Prepare Filebacked Big Matrix')
  bigGeno <- FBM.code256(
    nrow = nrow(fam),
    ncol = nrow(bim),
    code = CODE_012,
    backingfile = backingfile,
    init = NULL,
    create_bk = FALSE
  )

  # print('Fill the FBM from bedfile')
  # tryCatch({
  # reach.eof <- withTimeout(bigsnpr:::readbina(path.expand(bedfile), bigGeno, bigsnpr:::getCode()), timeout=10)}, TimeoutException = function(ex) {
  # message("Timeout. Skipping.")
  # })

  # if (!reach.eof) warning("EOF of bedfile has not been reached.")

  print('Create the bigSNP object')
  snp.list <- structure(list(genotypes = bigGeno, fam = fam, map = bim),
                        class = "bigSNP")

  print('save it and return the path of the saved object')
  rds <- sub_bk(bigGeno$backingfile, ".rds")
  saveRDS(snp.list, rds)
  rds
}

# Raw args
params <- hash()

args <- commandArgs(trailing = TRUE)
arg.pos <-1
cur.arg <- args[arg.pos]
while(!is.na(cur.arg)){
    print(cur.arg)
    cur.arg<-substring(cur.arg,3)
    cur.arg <- unlist(strsplit(cur.arg, '='))
    params[[cur.arg[1]]] <- cur.arg[2]
    arg.pos <- arg.pos+1
    cur.arg <- args[arg.pos]
}


for(cur.key in keys(params)){
    print(paste0(cur.key,": ", params[[cur.key]]))
    assign(cur.key, params[[cur.key]], envir=.GlobalEnv)
}

rds.file.name<-paste0(file.name,'.rds')
bed.file.name<-paste0(file.name,'.bed')
bk.file.name<-paste0(file.name,'.bk')
if(!file.exists(rds.file.name) || !file.exists(bk.file.name)){
    if (file.exists(rds.file.name)) {
        if(!file.exists(bk.file.name)){
            print("Removing old (orphan) rds file")
            file.remove(rds.file.name)
        }
        print("Running 1st stage")
        snp_readBed_1_stage(bed.file.name)
    } else if (file.exists(bk.file.name)) {
        print("Running 2nd stage")
        snp_readBed_2_stage(bed.file.name)
    } else {
        print("Running 1st stage")
        snp_readBed_1_stage(bed.file.name)
    }
} else {
    print(paste0('Both rds and bk exists. Skipping ', bed.file.name))
}
