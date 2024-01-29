# .libPaths(c('/specific/elkon/hagailevi/PRS/R-env/prs-R',.libPaths()))
library(readr)  # Read CSVs nicely
library(dplyr)
library(fmsb)
library(epitools)
library(performance)
library(pROC)
library(DescTools)
library(genpwr)
library(WebPower)
library(epiR)
source('constants.R')
library(dplyr)  # Data frame manipulation
library(broom)  # Convert models to data frames



# install.packages('readr')  # Read CSVs nicely
# install.packages('dplyr')
# install.packages('fmsb')
# install.packages('epitools')
# install.packages('performance')
# install.packages('pROC')
# install.packages('DescTools')
# install.packages('genpwr')
# install.packages('WebPower')
# install.packages('epiR')
# install.packages(dplyr)  # Data frame manipulation
# install.packages(broom)  # Convert models to data frames

basic.metrics <- function(prs.model) {
    print('get coefficient, p-value, beta, se')
    prs.coef <- summary(prs.model)$coeff["SCORE",]
    prs.beta <- as.numeric(prs.coef[1])
    prs.se <- as.numeric(prs.coef[2])
    prs.p <- as.numeric(prs.coef[4])
    return(data.frame(beta=prs.beta, se=prs.se, pval=prs.p))
}

ngk.r2.metric <- function(prs.model, pheno){
  print('Calculates ngk R2')
  prs.ngk.r2 <- PseudoR2(prs.model, which = 'Nagelkerke')
  return(prs.ngk.r2)
}

auroc.metric <- function(prs.model, pheno.prs){
  print('Calculate AUROC')
  prs.prediction <- predict(prs.model,pheno.prs)
  prs.auroc.obj <- roc(pheno.prs[,'label'], prs.prediction)
  prs.auroc <- auc(prs.auroc.obj)
  return(prs.auroc)
}

or.per.1.sd <- function(pheno.prs){

  # Scaling w.r.t to control arm
  mn<-mean(filter(pheno.prs, label==0)[,'SCORE'])
  std<-sd(filter(pheno.prs, label==0)[,'SCORE'])
  pheno.prs[,'SCORE']= (pheno.prs[,'SCORE']-mn)/std # scale(pheno.prs[,a])

  ### LEGACY: Scaling according w.r.t the entire cohort
  # pheno.prs[,'SCORE']=scale(pheno.prs[,'SCORE'])
  ###

  # Run GLM
  or.glm <- glm(label ~ . , data=pheno.prs[,!colnames(pheno.prs)%in%c("FID")] , family=binomial(link="logit"))

  # Attach CI to log(OR)/ceof
  df.or.all.log <- cbind(coef(or.glm), confint.default(or.glm)) #confint(OR.glm) 

  # Convert values to OR (coef)
  df.or.all <- exp(df.or.all.log)

  # Calculate SE
  or.se<-get.or.se(or.glm)

  # Attach SE to OR
  df.or.all <- cbind(df.or.all, or.se)
  return(data.frame(df.or.all))
}

get.or.se <- function(model) {
  res <-  broom::tidy(model) %>%
    mutate(or = exp(estimate),
           var.diag = sqrt(diag(vcov(model))),
           or.se = or * var.diag) #  %>% select(or.se) %>% unlist
  return(res[,'or.se'])
}

percentile.or <- function(pheno.prs, resolution=0.1){

    df.or=data.frame()

    # Set percentile range
    if(resolution==0.1){
        quantiles=c(0.1,0.2,0.3,0.4,0.6,0.7,0.8,0.9,1)
        q_order= c(5,1:4,6:9)
    } else if (resolution==0.05){
        quantiles=c(0.05,0.1,0.2,0.3,0.4,0.6,0.7,0.8,0.9,0.95,1)
        q_order= c(6,1:5,7:11)
    } else if (resolution==0.01){
        quantiles=c(0.01,0.05,0.1,0.2,0.3,0.4,0.6,0.7,0.8,0.9,0.95,0.99,1)
        q_order=c(7,1:6,8:13)
    } else {
        print(paste0("Error: invalid resolution parameter was provided to precerntile.or: ", resolution))
        quit(status=1)
    }

    # Extract percentiles
    qtls<-quantile(pheno.prs[,'SCORE'],quantiles)

    # Split set cohort according to percentile range
    for(a_i in q_order){
        a=qtls[a_i]
        a=if (a_i==max(q_order)) max(pheno.prs[,'SCORE']) else qtls[a_i]
        a_prev=if (a_i-1==0) min(pheno.prs[,'SCORE'])-0.1 else qtls[a_i-1]
        n_control <- nrow(filter(pheno.prs, label==0 & SCORE>a_prev & SCORE <=a))
        n_case <- nrow(filter(pheno.prs, label==1 & SCORE>a_prev & SCORE <=a))
        df.or <-rbind(df.or, data.frame(n_control=n_control, n_case=n_case)) # qtl=a,
    }

    # Format and remove zeros
    df.or <- as.matrix(df.or)
    df.or[(df.or[,1]==0) | (df.or[,2]==0),]=1

    # Calculate OR by percentile
    or.fit <- oddsratio(df.or)

    # Format results
    rownames(or.fit$measure)<- paste0(c(0,quantiles)[q_order]*100,"-",quantiles[q_order]*100)
    colnames(or.fit$measure)<- c("OR", "CI min", "CI max")
    return(list("df.or"=df.or,"or.fit"=or.fit))
}

cox.regression <- function(pheno.prs, phenotype.file.name){
  pheno.age <- read.table(paste0(phenotype.file.name,"_age"), header=T)
  colnames(pheno.age)[3] <- "diagnosis_age"
  df.agg <- merge(pheno.prs, pheno.age, by.x = "FID",
                  by.y = "FID", all.x = TRUE, all.y = FALSE)
  print('Calculates cox')

  print('Standardize PRS scores')
  df.agg[,'SCORE_SCALE']=scale(df.agg[,'SCORE'])

  print('Calculates Cox with continuous PRS covariate')
  prs.model <- coxph(formula = Surv(diagnosis_age, label) ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + SCORE_SCALE,  data = df.agg)

  print('Get Cox coefficient, p-value, beta, se')
  summary <- data.frame(summary(prs.model)$coeff, exp(confint(prs.model)))
  prs.coef <- summary["SCORE_SCALE",]
  hr.exp.beta <- as.numeric(prs.coef[2])
  hr.se <- as.numeric(prs.coef[3])
  hr.pval <- as.numeric(prs.coef[5])
  hr.ci.min <- as.numeric(prs.coef[6])
  hr.ci.max <- as.numeric(prs.coef[7])
  return(data.frame(hr.exp.beta=hr.exp.beta, hr.se=hr.se, hr.pval=hr.pval, hr.ci.min=hr.ci.min, hr.ci.max=hr.ci.max))

}

percentile.hr <- function(pheno.prs, phenotype.file.name, resolution=0.1){
    df.or=data.frame()

    # Add age information
    pheno.age <- read.table(paste0(phenotype.file.name,"_age"), header=T)
    colnames(pheno.age)[3] <- "diagnosis_age"
    df.agg <- merge(pheno.prs, pheno.age, by.x = "FID",
             by.y = "FID", all.x = TRUE, all.y = FALSE)

    # Standardize PRS scores
    df.agg.unaffected<-df.agg[df.agg[,'label']==0,'SCORE']
    df.agg[,'SCORE_SCALE']=(df.agg[,'SCORE']-mean(df.agg.unaffected))/sd(df.agg.unaffected)

    # Set percentile range
    if(resolution==0.1){
        quantiles=c(0.1,0.2,0.3,0.4,0.6,0.7,0.8,0.9,1)
        q_order= c(5,1:4,6:9)
    } else if (resolution==0.05){
        quantiles=c(0.05,0.1,0.2,0.3,0.4,0.6,0.7,0.8,0.9,0.95,1)
        q_order= c(6,1:5,7:11)
    } else if (resolution==0.01){
        quantiles=c(0.01,0.05,0.1,0.2,0.3,0.4,0.6,0.7,0.8,0.9,0.95,0.99,1)
        q_order=c(7,1:6,8:13)
    } else {
        print(paste0("Error: invalid resolution parameter was provided to precerntile.or: ", resolution))
        quit(status=1)
    }

    # Extract percentiles
    qtls<-quantile(df.agg[,'SCORE_SCALE'],quantiles)

    # Set percentile covariate according to percentile range
    df.agg[,'SCORE_PERCENTILE']=0
    cur.cat.value=0
    for(a_i in q_order){
        a=if (a_i==max(q_order)) max(df.agg[,'SCORE_SCALE']) else qtls[a_i]
        a_prev=if (a_i==min(q_order)) min(df.agg[,'SCORE_SCALE'])-0.1 else qtls[a_i-1]
        cur.cat.value=cur.cat.value+1
        df.agg[df.agg[,'SCORE_SCALE']>a_prev & df.agg[,'SCORE_SCALE']<=a ,'SCORE_PERCENTILE']=cur.cat.value
    }
    print(paste0("Check that all individuls were assigned with percentile covariate value. Minimal value should be 1. Got ", min(df.agg[,'SCORE_PERCENTILE'])))
    df.agg[,'SCORE_PERCENTILE']=factor(df.agg[,'SCORE_PERCENTILE'])

    print('Calculates Cox with percentile covariate')
    prs.model <- coxph(formula = Surv(diagnosis_age, label) ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + SCORE_PERCENTILE,  data = df.agg)


    # Attach CI to log(OR)/ceof
    summary <- data.frame(summary(prs.model)$coeff, exp(confint(prs.model)))
    summary<-rbind(c(1,1,1),summary[7:nrow(summary),c(2,6,7)])

    if(length(q_order)==nrow(summary)){
        rownames(summary)<- paste0(c(0,quantiles)[q_order]*100,"-",quantiles[q_order]*100)
    }
    colnames(summary)<- c("HR", "CI min", "CI max")
    print('Get Cox coefficients')
    return(summary)
}

format.beta.by.percentile <- function(beta.by.percentile.results, resolution, prefix){
  if(resolution==0.1){
    percentile.t<-"90"
    percentile.ts<-"80"
    percentile.b<-"10"
    percentile.bs<-"20"

  } else if(resolution==0.05){
    percentile.t<-"95"
    percentile.ts<-"90"
    percentile.b<-"5"
    percentile.bs<-"10"

  } else if(resolution==0.01){
    percentile.t<-"99"
    percentile.ts<-"95"
    percentile.b<-"1"
    percentile.bs<-"5"
  }
  h.t<-paste(prefix,percentile.t, sep='.')
  h.t.min<-paste(prefix,percentile.t,"ci","min", sep='.')
  h.t.max<-paste(prefix,percentile.t,"ci","max", sep='.')
  h.ts<-paste(prefix,percentile.ts, sep='.')
  h.ts.min<-paste(prefix,percentile.ts,"ci","min", sep='.')
  h.ts.max<-paste(prefix,percentile.ts,"ci","max", sep='.')

  h.b<-paste(prefix,percentile.b, sep='.')
  h.b.min<-paste(prefix,percentile.b,"ci","min", sep='.')
  h.b.max<-paste(prefix,percentile.b,"ci","max", sep='.')
  h.bs<-paste(prefix,percentile.bs, sep='.')
  h.bs.min<-paste(prefix,percentile.bs,"ci","min", sep='.')
  h.bs.max<-paste(prefix,percentile.bs,"ci","max", sep='.')

  n.beta<-nrow(beta.by.percentile.results)
  beta.by.percentile.summary <- data.frame(
    beta.by.percentile.results[1,1], beta.by.percentile.results[1,2], beta.by.percentile.results[1,3],
    beta.by.percentile.results[2,1], beta.by.percentile.results[2,2], beta.by.percentile.results[2,3],
    beta.by.percentile.results[n.beta-1,1], beta.by.percentile.results[n.beta-1,2], beta.by.percentile.results[n.beta-1,3],
    beta.by.percentile.results[n.beta,1], beta.by.percentile.results[n.beta,2], beta.by.percentile.results[n.beta,3]
  )
  colnames(beta.by.percentile.summary)<-c(h.b,h.b.min,h.b.max,h.bs,h.bs.min,h.bs.max,h.ts,h.ts.min,h.ts.max,h.t,h.t.min,h.t.max)

  return(beta.by.percentile.summary)

}

power.or <- function(pheno.prs, df.or.all){
    total.healthy.n <- nrow(filter(pheno.prs, label==0))
    total.case.n <- nrow(filter(pheno.prs, label==1))
    p0 <- total.case.n/(total.case.n+total.healthy.n)
    p0.or <- total.case.n/total.healthy.n
    p1.or <- df.or.all[nrow(df.or.all),1]
    p1 <- (p0.or*p1.or)/(1+p0.or*p1.or)
    return(wp.logistic(n = nrow(pheno.prs), p0 = p0 , p1 = p1 , family='normal', alpha = 0.05)['power'])
}

percentile.or.power <- function(pheno.prs, df.or, or.fit){

  # for (a in seq(nrow(df.or))){
  #     p.per <- df.or[a,'n_control']/(df.or[1,'n_control']+df.or[a,'n_control'])
  #     n.per <- df.or[1,'n_case'] + df.or[1,'n_control'] + df.or[a,'n_case'] + df.or[a,'n_control']
  #     r.per <- (df.or[1,'n_control'] + df.or[a,'n_control'])/(df.or[1,'n_case'] + df.or[a,'n_case'])
  #     res.per <- epi.sscc(OR=or.fit$measure[a], p0=p.per, n=n.per, power=NA, r=r.per, rho.cc = 0, design = 1, sided.test = 2, nfractional = FALSE, conf.level = 0.95, method = "unmatched", fleiss = FALSE)
  #     print(paste("cur OR", quantiles[a], quantiles[a+1] ,res.per))
  # }

  p0.95 <- df.or[nrow(df.or)-1,'n_control']/(df.or[1,'n_control']+df.or[nrow(df.or)-1,'n_control'])
  n.95 <- df.or[1,'n_case'] + df.or[1,'n_control'] + df.or[nrow(df.or)-1,'n_case'] + df.or[nrow(df.or)-1,'n_control']
  r.95 <- (df.or[1,'n_control'] + df.or[nrow(df.or)-1,'n_control'])/(df.or[1,'n_case'] + df.or[nrow(df.or)-1,'n_case'])
  res.95 <- epi.sscc(OR=or.fit$measure[nrow(or.fit$measure)-1], p0=p0.95, n=n.95, power=NA, r=r.95, rho.cc = 0, design = 1, sided.test = 2, nfractional = FALSE, conf.level = 0.95, method = "unmatched", fleiss = FALSE)
  res.95 <- epi.sscc(OR=or.fit$measure[nrow(or.fit$measure)-1], p0=p0.95, n=n.95, power=NA, r=r.95, rho.cc = 0, design = 1, sided.test = 2, nfractional = FALSE, conf.level = 0.95, method = "unmatched", fleiss = FALSE)

  p0.99 <- df.or[nrow(df.or),'n_control']/(df.or[1,'n_control']+df.or[nrow(df.or),'n_control'])
  n.99 <- df.or[1,'n_case'] + df.or[1,'n_control'] + df.or[nrow(df.or),'n_case'] + df.or[nrow(df.or),'n_control']
  r.99 <- (df.or[1,'n_control'] + df.or[nrow(df.or),'n_control'])/(df.or[1,'n_case'] + df.or[nrow(df.or),'n_case'])
  res.99 <- epi.sscc(OR=or.fit$measure[nrow(or.fit$measure)], p0=p0.99, n=n.99, power=NA, r=r.99, rho.cc = 0, design = 1, sided.test = 2, nfractional = FALSE, conf.level = 0.95, method = "unmatched", fleiss = FALSE)
  res.99 <- epi.sscc(OR=or.fit$measure[nrow(or.fit$measure)], p0=p0.99, n=n.99, power=NA, r=r.99, rho.cc = 0, design = 1, sided.test = 2, nfractional = FALSE, conf.level = 0.95, method = "unmatched", fleiss = FALSE)

  return(list("res.95"=res.95, "res.99"=res.99))
}


calc.metrics.for.hp <- function(i, res.path, prs.prefix,suffix, phenotype.file.name, pheno, resolution, null.ngk.r2, null.auroc) {
    print(paste0('=== Start analyzing hp: ',i, " ==="))
    print('Read PRS')
    if (i<0) {
      prs.file.name<-paste(res.path, paste0(prs.prefix,suffix,".profile"), sep='/')
    } else {
      prs.file.name<-paste(res.path, paste0(prs.prefix,suffix,".",i,".profile"), sep='/')
    }
    if (!file.exists(prs.file.name)){
      print(paste0("The file ", prs.file.name, " does not exist. Skipping..."))
      return(NULL) 
    } else{
      print(paste0("Found ", prs.file.name, ". Start processing..."))
    }

    prs<-read.table(prs.file.name, header=T)
    n.unique.prs<-length(unique(prs[,'SCORE']))
    n.prs<-nrow(prs)
    if(n.unique.prs<20 && n.prs>=20){
        print(paste0("Too few unique risk score values. Got ", n.unique.prs, " while # of risk scores is ", n.prs))
        return(NULL)
    }
    # print(paste('Total number of prs rows:',nrow(prs)))
    # print(paste('Total number of pheno rows:',nrow(pheno)))

    print('Merge the prs with the phenotype matrix')
    print(head(pheno))
    pheno.prs <-  merge(pheno, prs[,c("FID", "SCORE")], by=c("FID"))
    print(paste('Total number of phenotype rows after the merge:',nrow(pheno.prs)))

    print('Perform a logistic regression on (binary) phenotype with PRS and the covariates, including PCs (ignoring the FID and IID from our model)')
    prs.model <- glm(label~., data=pheno.prs[,!colnames(pheno.prs)%in%c("FID")], family=binomial(link="logit")) # binomial(link="logit")

    if (! ("SCORE" %in% rownames(summary(prs.model)$coeff))){
      print("Warning: Could not infer estimates for PRS score. This might happen if all values are identical (probably 0). Assign zeros to estimates")
      next;
    }

    print('Calculate basic GLM statistics')
    prs.result <- basic.metrics(prs.model)

    print('Calculate PRS Nagelkreke R2')
    cur.ngk.r2 <- ngk.r2.metric(prs.model)
    prs.result <- cbind(prs.result, data.frame("prs.ngk.r2"=cur.ngk.r2, "null.ngk.r2"=cur.ngk.r2, "all.ngk.r2"=cur.ngk.r2-null.ngk.r2))

    print('Calculate PRS AUROC')
    cur.auroc <- auroc.metric(prs.model, pheno.prs)
    prs.result <- cbind(prs.result, data.frame("prs.auroc"=cur.auroc, "null.auroc"=cur.auroc, "all.auroc"=cur.auroc-null.auroc))

    print('Calculate OR of logistic regression')
    df.or.all <- or.per.1.sd(pheno.prs)
    prs.result <- cbind(prs.result, data.frame(or.all=df.or.all['SCORE',1], or.all.se=df.or.all['SCORE',4], or.all.ci.min=df.or.all['SCORE',2], or.all.ci.max=df.or.all['SCORE',3]))
    # write.table(df.or.all, paste(res.path,paste0(prs.prefix,suffix,".or.all.",i,".tsv"), sep='/'), row.names = FALSE, sep='\t', quote = FALSE)

    # print ('Calculate power for OR of logistic regression')
    # res.wp <- power.or(pheno.prs, df.or.all)

    print('Calculate stratified OR (by percentiles)')
    res <- percentile.or(pheno.prs, resolution)
    df.or <- res$df.or
    or.fit <- res$or.fit

    print ('Save stratified OR (by percentiles)')
    write.table(or.fit$measure, paste(res.path,paste0(prs.prefix,suffix,".or.percentile.",i,".tsv"), sep='/'), col.names= NA, row.names = TRUE, sep='\t', quote = FALSE)
    write.table(or.fit$p.value, paste(res.path,paste0(prs.prefix,suffix,".or.p.value.",i,".tsv"), sep='/'), row.names = FALSE, sep='\t', quote = FALSE)

    print('Format OR by percentile results')
    res.or.analysis<-format.beta.by.percentile(or.fit$measure[7:nrow(or.fit$measure),], resolution, "or")
    prs.result<- cbind(prs.result, res.or.analysis)

    # print('Calculate power for stratified OR (by percentiles)')
    # powers <- percentile.or.power(pheno.prs, df.or, or.fit)

    # print("Calculate HR (Cox regression)")
    # cox.results <-  cox.regression(pheno.prs, phenotype.file.name)
    # prs.result<-cbind(prs.result, cox.results)

    # print('Calculate stratified HR (by percentiles)')
    # cox.by.percentile.results <- percentile.hr(pheno.prs, phenotype.file.name, resolution)

    # print('Format HR by percentile results')
    # write.table(cox.by.percentile.results, paste(res.path,paste0(prs.prefix,suffix,".hr.percentile.",i,".tsv"), sep='/'), col.names= NA, row.names = TRUE, sep='\t', quote = FALSE)
    # cox.by.percentile.summary<-format.beta.by.percentile(cox.by.percentile.results, resolution, "hr")
    # prs.result<-cbind(prs.result, cox.by.percentile.summary)

    print('Save statistics and metrics')
    prs.result<-cbind(data.frame(hp=i, stringsAsFactors = FALSE), prs.result)
    rownames(prs.result)=i
    # write.table(prs.result, paste(res.path,paste0(prs.prefix,suffix,".statistics.",i,".tsv"), sep='/'), row.names = FALSE, sep='\t', quote = FALSE)
    # print(prs.result)
    print(paste(res.path,paste0(prs.prefix,suffix,".statistics.",i,".tsv"), sep='/'))
    print(paste0('=== End analyzing hp: ',i, " ==="))

    return(prs.result)

}


calc.metrics <- function(target.path, imp.name, res.path, sub, grid.ids, prs.prefix, suffix, rep, analysis.type, resolution=0.1){

    phenotype.file.name <- paste(target.path, paste0("pheno",sub,suffix), sep="/")
    print(paste('Read in the phenotype file', phenotype.file.name))
    phenotype <- read.table(phenotype.file.name, header=T)

    print('Filter samples w/o phenotype')
    phenotype=phenotype[phenotype$label!=-1,]
    print('Read in the PCs')
    if(analysis.type=="cv"){
        eigenvec.prefix<-"ds__"
    } else {
        eigenvec.prefix<-"ds"
    }
    pcs <- read.table(paste(target.path, imp.name, paste(paste0(eigenvec.prefix, suffix,".eigenvec")), sep="/"), header=F)
    pcs <- pcs[,1:8]

    # The default output from plink does not include a header. To make things simple, we will add the appropriate headers (1:6 because there are 6 PCs)
    colnames(pcs) <- c("FID", "IID", paste0("PC",1:6))

    print('Read in the covariates, if there is any (here, it is sex)')

    print('Merge PCs, covariates and phenotype')
    print(colnames(phenotype))
    print(colnames(pcs))
    print(paste0("Number of row in phenotype: ", nrow(phenotype)))
    print(paste0("Number of row in pcs: ", nrow(pcs)))
    # Note that pheno is global (<<-) to bypass Nagelkerke bug
    pheno <<-  merge(phenotype, pcs, by=c("FID"))
    print(paste0("Number of row in pheno: ", nrow(pheno)))
    print('Read covariates, if the file exists')
    print('Check if covariates file exists')
    print(paste(target.path, "cov", sep="/"))
    if (file.exists(paste(cov.path, "cov", sep="/"))){
        print('Read covariates file')
        covariate <- read.table(paste(cov.path, "cov", sep="/"), header=T)
        print('Merge covariates and phenotype')
        pheno <-  merge(pheno, covariate, by=c("FID"))
    }
    print(paste(cov.path, "pop.panel", sep="/"))
    if (file.exists(paste(cov.path, "pop.panel", sep="/"))){
        print('Read pop.panel file')
        pop.panel <- read.table(paste(cov.path, "pop.panel", sep="/"), header=T)
        print('Merge covariates and phenotype')
        # pheno <-  merge(pheno, pop.panel, by=c("FID"))
        # pheno <- pheno[,!colnames(pheno)%in%c("super_pop", "pop")]
    }
    print('Clean redundant colums')
    pheno <- pheno[,!colnames(pheno)%in%c("FID.1", "IID", "IID.x", "IID.y", "IID.y.1", "IID.x.1")]
    print('Adjust label values for GLM')
    pheno[,'label'] <- pheno[,'label']-1

    print("The null model (model with PRS) using a logistic regression against phenotype.")
    null.model <- glm(label~., data=pheno[,!colnames(pheno)%in%c("FID")], family=binomial(link="logit"))

    print('Calculate R2 of the null model')
    null.ngk.r2 <- ngk.r2.metric(null.model)

    print('Calculate AUROC of the null model')
    null.auroc <- auroc.metric(null.model, pheno[,!colnames(pheno)%in%c("FID")])

    print('Start looping grid.ids')
    all.prs.results <- data.frame()
    # Go through each p-value threshold
    res.paths=rep(res.path, length(grid.ids))
    prs.prefixes=rep(prs.prefix, length(grid.ids))
    suffixes=rep(suffix, length(grid.ids))
    phenotype.file.names=rep(phenotype.file.name, length(grid.ids))
    phenos=rep(list(pheno), length(grid.ids))
    resolutions=rep(resolution, length(grid.ids))
    null.ngk.r2s=rep(null.ngk.r2, length(grid.ids))
    null.aurocs=rep(null.auroc, length(grid.ids))

    prs.results=parallel::mcmapply(calc.metrics.for.hp, i=grid.ids, res.path = res.paths, prs.prefix = prs.prefixes, suffix=suffixes,
                       phenotype.file.name=phenotype.file.names, pheno=phenos, resolution=resolutions, null.ngk.r2=null.ngk.r2s, null.auroc=null.aurocs, mc.cores=20)

    if(class(prs.results)=='matrix'){
        prs.results<-t(prs.results)
    } else{
        prs.results<-as.data.frame(do.call(rbind,prs.results))
    }

    # Single-thread version
    # prs.results=c()
    # for(hp in grid.ids){
    #     prs.results<-rbind(prs.results, calc.metrics.for.hp(hp, res.path, prs.prefix, suffix, phenotype.file.name, pheno, resolution, null.ngk.r2, null.auroc))
    # }
    
    print(prs.results)
    print(paste("Saved full statistics in", paste(res.path,paste0(prs.prefix,suffix,".statistics.tsv"), sep='/')))
    write.table(prs.results, paste(res.path,paste0(prs.prefix,suffix,".statistics.tsv"), sep='/'), row.names = FALSE, sep='\t', quote = FALSE)


}

# target.path<-"/specific/netapp5/gaga/gaga-pd/prs_data/datasets/dec/cimba_eur_brca2_oncoarray"
# imp.name<-"impX_gen"
# res.path<-"/specific/netapp5/gaga/gaga-pd/prs_data/PRSs/bcac_onco_eur-5pcs_cimba_eur_brca2_oncoarray/impX_gen"
# sub<-""
# grid.ids<-c("0.2", "0.3")
# prs.prefix<-"prs.mono.pt3"
# suffix<-""
# rep<-""
# analysis.type<-"mono"
# cov.path<-"/specific/netapp5/gaga/gaga-pd/prs_data/datasets/dec/cimba_eur_brca2_oncoarray/cov"
# calc.metrics(target.path, imp.name, res.path, sub, grid.ids, prs.prefix, suffix, rep, analysis.type)
