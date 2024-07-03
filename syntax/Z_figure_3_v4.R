##############################################################################################################
### SETUP
##############################################################################################################

### clear everything
rm(list=ls())

### make sure R is up to date
# library(installr)
# updateR()

### install latest "augsynth"
library(devtools)
devtools::install_github("ebenmichael/augsynth")

### load "augsynth"
library(augsynth)
library(tidyverse)

### set working directory (in RStudio, this sets directory to the source file location)
setwd("C:/Users/trejo/Dropbox (Princeton)/shared/Flint Water Project/between_analysis/data")

### date
date <- "2023_11_21"

### load geodist panel  (NON-FIXED) [60]
nonfix_60_2006 <- read.csv(paste0("augsyn_nonfix_60_2006_", date, ".csv"))

### change working directory to results folder
setwd("C:/Users/trejo/Dropbox (Princeton)/shared/Flint Water Project/between_analysis/tables/temp")

##############################################################################################################
### RUN SCM MODELS (NON-FIXED) [60]
##############################################################################################################

n_math_read_sped_attd_60 <- augsynth(math + read + sped + attd ~ treat, leaid ,year,nonfix_60_2006,
                                     progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

##############################################################################################################
### PLOT RESULTS
##############################################################################################################

m <- summary(n_math_read_sped_attd_60, inf_type = "jackknife")
att <- m$att %>%
  mutate(Outcome = as_factor(Outcome),
         Outcome = fct_relevel(Outcome, c('math', 'read', 'sped', 'attd')),
         Outcome = fct_recode(Outcome,
                              `A. Math Achievement` = 'math',
                              `B. Reading Achievement`='read',
                              `C. Special Needs`='sped',
                              `D. Attendance`='attd'))

att <- att%>% filter(att$Outcome!='Average')

# att$Outcome <- factor(att$Outcome, levels=c("A. Math Achievement", "B. Reading Achievement", "Special Needs", "Attendance"))

plot <-ggplot(att, aes(x=Time, y=Estimate)) +
  geom_ribbon(aes(ymin=Estimate-2*Std.Error,
                  ymax=Estimate+2*Std.Error),
              alpha=0.2) +
  geom_line(color="blue", size=2) +
  geom_vline(xintercept=m$t_int, lty=2) +
  geom_hline(yintercept=0, lty=2) +
  facet_wrap(vars(Outcome), scales="free") +
  labs(x = "Year",
       y = "Difference Between \n Flint & Synthetic Control") +
  theme_classic()

bounds <- read.table(header=TRUE,
                     text=
                       "Outcome ymin ymax
                     A. Math        -.325  .15
                     B. Reading     -.325  .15
                     C. Special     -.01 .04
                     D. Attendance  -.02 .04",
                     stringsAsFactors=FALSE)

bounds$Outcome <- c("A. Math Achievement", "B. Reading Achievement", "C. Special Needs", "D. Attendance")

ff <- with(bounds,
           data.frame(Estimate=c(ymin,ymax),
                      Outcome=c(Outcome,Outcome)))

plot + geom_point(data=ff,x=NA)