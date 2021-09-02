install.packages("copula")
library(copula)
install.packages("agop")
library(agop)

#### Generation of hypothetical population data for dependent risks   ####

set.seed(10000)
obj.cop <- tCopula(param = 0.25, dim=4, dispstr = "ex")
samples.cop <- rCopula(10000, obj.cop)
corr_std    <- diag(4)*0.75+0.25

pop.risk_life <- qnorm(    samples.cop[,1], mean=500, sd=1000)
pop.risk_pnc  <- qpareto2( samples.cop[,2], k=4     , s=1500)
pop.risk_cred <- qt(       samples.cop[,3], df=4)*1000+500
pop.risk_mkt  <- exp(qnorm(samples.cop[,4], mean=6, sd=0.47))
pop.risk_total <- pop.risk_life + pop.risk_pnc + pop.risk_cred + pop.risk_mkt

pop.var_true  <- quantile(pop.risk_total, probs=0.995)
hist(pop.risk_total, breaks = 100, freq=FALSE)
lines(density(pop.risk_total),col="red")
abline(v=pop.var_true , col="blue")

J=20 # To reduce randomness in calculation of VaR due to random seeds, 20 samples were extracted to compute VaR 


#### VaR estimation with sample size of 60 (one can replace 60 with any number, say, 120, 240, or 480)####

prd60.var_std <- 0
prd60.var_emp <- 0
prd60.var_int <- 0

for (i in 1:J) {
  set.seed(i+1000)
  sam60.cop <- rCopula(60, obj.cop)
  
  sam60.risk_life <- qnorm(    sam60.cop[,1], mean=500, sd=1000)
  sam60.risk_pnc  <- qpareto2( sam60.cop[,2], k=4     , s=1500)
  sam60.risk_cred <- qt(       sam60.cop[,3], df=4)*1000+500
  sam60.risk_mkt  <- exp(qnorm(sam60.cop[,4], mean=6, sd=0.47))
  sam60.risk_total <- sam60.risk_life + sam60.risk_pnc + sam60.risk_cred + sam60.risk_mkt
  
  est60.parm_life  <- c(mean(sam60.risk_life), sd(sam60.risk_life))
  
  pnc_alpha       <- max(3, 2/(1-mean(sam60.risk_pnc)^2/var(sam60.risk_pnc)))
  est60.parm_pnc  <- c(pnc_alpha, mean(sam60.risk_pnc)*(pnc_alpha-1))
  
  est60.parm_cred  <- c(mean(sam60.risk_cred), sd(sam60.risk_cred)/sqrt(2))
  
  est60.parm_mkt  <- c(log(mean(sam60.risk_mkt))-0.5*log(var(sam60.risk_mkt)/mean(sam60.risk_mkt)^2+1),
                        sqrt(log(var(sam60.risk_mkt)/mean(sam60.risk_mkt)^2+1)))
  
  prd60.var_marginal <- c(
    qnorm(    0.995, sd   =est60.parm_life[2], mean=est60.parm_life[1]),
    qpareto2( 0.995, s    =est60.parm_pnc[ 2], k   =est60.parm_pnc[ 1]),
    qt(       0.995, df=4)*est60.parm_cred[2]      +est60.parm_cred[1] ,
    exp(qnorm(0.995, sd   =est60.parm_mkt[ 2], mean=est60.parm_mkt[ 1])))
  
  psd60.cop <- cbind(
    pnorm(      sam60.risk_life, mean=est60.parm_life[1], sd =est60.parm_life[2]),
    ppareto2(   sam60.risk_pnc , k   =est60.parm_pnc[ 1], s  =est60.parm_pnc[ 2]),
    pt(df=4, q=(sam60.risk_cred     - est60.parm_cred[1])  /  est60.parm_cred[2]),
    pnorm( (log(sam60.risk_mkt)     - est60.parm_mkt[ 1])  /  est60.parm_mkt[ 2]))
  
  prd60.copfit <- fitCopula(tCopula(dim=4, dispstr = "ex"), psd60.cop, method="mpl")
  prd60.cop <- rCopula(20000, prd60.copfit@copula)
  
  prd60.risk_life <- qnorm(    prd60.cop[,1], sd   =est60.parm_life[2], mean=est60.parm_life[1])
  prd60.risk_pnc  <- qpareto2( prd60.cop[,2], s    =est60.parm_pnc[ 2], k   =est60.parm_pnc[ 1])
  prd60.risk_cred <- qt(       prd60.cop[,3], df=4)*est60.parm_cred[2]      +est60.parm_cred[1] 
  prd60.risk_mkt  <- exp(qnorm(prd60.cop[,4], sd   =est60.parm_mkt[ 2], mean=est60.parm_mkt[ 1]))
  prd60.risk_total <- prd60.risk_life + prd60.risk_pnc + prd60.risk_cred + prd60.risk_mkt
  
  prd60.var_std  <- prd60.var_std + sqrt(prd60.var_marginal %*% corr_std %*% prd60.var_marginal)/J
  prd60.var_emp  <- prd60.var_emp + quantile(sam60.risk_total, probs=0.995)/J
  prd60.var_int  <- prd60.var_int + quantile(prd60.risk_total, probs=0.995)/J }


c(prd60.var_std, prd60.var_emp, prd60.var_int)
c(prd60.var_std, prd60.var_emp, prd60.var_int) - pop.var_true
