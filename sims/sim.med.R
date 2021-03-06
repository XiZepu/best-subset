## Low-dimensional simulation, n=100 and p=10
library(bestsubset)

# Set some overall simulation parameters
n = 500; p = 100 # Size of training set, and number of predictors
nval = n # Size of validation and testing sets
nrep = 10 # Number of repetitions for a given setting
seed = 0 # Random number generator seed
type.vec = c(1:3,5) # Simulation settings to consider
rho.vec = c(0,0.35,0.7) # Pairwise predictor correlations
snr.vec = exp(seq(log(0.05),log(6),length=10)) # Signal-to-noise ratios 
stem = paste0("sim.n",n,".p",p)

# Regression functions: lasso, forward stepwise, and best subset selection
reg.funs = list()
reg.funs[["Lasso"]] = function(x,y) lasso(x,y,intercept=FALSE,nlam=50)
reg.funs[["Stepwise"]] = function(x,y) fs(x,y,intercept=FALSE,max=50)
reg.funs[["Best subset"]] = function(x,y) bs(x,y,intercept=FALSE,k=1:50,
                                             time.limit=3600)
reg.funs[["Relaxed lasso"]] = function(x,y) lasso(x,y,intercept=FALSE,
                                                  nrelax=10,nlam=50)

file.list = c() # Vector of files for the saved rds files
file.name = c() # Vector of file names for the plots 
for (beta.type in type.vec) {
  for (rho in rho.vec) {
    name = paste0(stem, ".beta", beta.type, sprintf(".rho%0.2f", rho))
    for (snr in snr.vec) {
      file = paste0("rds/", name, ".snr", round(snr,2), ".rds")
      cat("..... NEW SIMULATION .....\n")
      cat("--------------------------\n")
      cat(paste0("File: ", file, "\n\n"))
      
      sim.master(n, p, nval, reg.funs=reg.funs, nrep=nrep, seed=seed,           
                 verbose=TRUE, file=file, rho=rho, beta.type=beta.type, snr=snr)
      
      file.list = c(file.list, file)
      cat("\n")
    }
    file.name = c(file.name, name)
  }
}

grouping = rep(as.numeric(outer(1:length(rho.vec),10*1:length(type.vec),"+")),
               each=length(snr.vec))
main = paste0(rep(paste0("Setting ", type.vec), each=length(rho.vec)),
              rep(paste0(", rho = ", rho.vec), times=length(type.vec)))
save(list=ls(), file=paste0("rds/",stem,".rda"))

##############################
# Run the code below to reproduce the figures without rerunning the sims

library(bestsubset)
load(file="rds/sim.n500.p100.rda")

# Validation tuning
plot.many.sims(file.list, grouping, snr.vec=snr.vec, what="err",  tuning="val",
               fig.dir="fig/val", file.name=file.name, main=main, tex.dir="tex")
plot.many.sims(file.list, grouping, snr.vec=snr.vec, what="non",  tuning="val",
               fig.dir="fig/val", file.name=file.name, main=main, tex.dir="tex")

# Oracle tuning
plot.many.sims(file.list, grouping, snr.vec=snr.vec, what="err", tuning="ora",
               fig.dir="fig/ora", file.name=file.name, main=main, tex.dir="tex")
plot.many.sims(file.list, grouping, snr.vec=snr.vec, what="non", tuning="ora",
               fig.dir="fig/ora", file.name=file.name, main=main, tex.dir="tex")
