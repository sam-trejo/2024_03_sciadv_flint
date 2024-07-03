##############################################################################################################
### SETUP
##############################################################################################################

### clear everything
rm(list=ls())

### make sure R is up to date
# library(installr)
# updateR()

### install latest "augsynth"
# library(devtools)
# devtools::install_github("ebenmichael/augsynth")

### load "augsynth"
library(augsynth)
library(tidyverse)

### set working directory (in RStudio, this sets directory to the source file location)
setwd("flint_replication/data")

### date
date <- "YYYY_MM_DD"

nonfix_60_2006 <- read.csv(paste0("augsyn_nonfix_60_2006_", date, ".csv"))
nonfix_60_2007 <- read.csv(paste0("augsyn_nonfix_60_2007_", date, ".csv"))
nonfix_60_2009 <- read.csv(paste0("augsyn_nonfix_60_2009_", date, ".csv"))

### load geodist panel (FIXED) [60]
fix_60_2006 <- read.csv(paste0("augsyn_fix_60_2006_", date, ".csv"))

### load alternative geodist panel (NON-FIXED) [60]
nonfix_51_2006 <- read.csv(paste0("augsyn_nonfix_51_2006_", date, ".csv"))

### load old alternative geodist panel panel  (NON-FIXED) [30]
nonfix_30_2006 <- read.csv(paste0("augsyn_nonfix_30_2006_", date, ".csv"))

### change working directory to results folder
setwd("flint_replication/tables/temp")

##############################################################################################################
### RUN SCM MODELS (NON-FIXED) [60]
##############################################################################################################

n_math_60 <- augsynth(math ~ treat, leaid, year, nonfix_60_2007,
                    progfunc="None", fixedeff="TRUE", scm=T)

n_read_60 <- augsynth(read ~ treat, leaid, year,nonfix_60_2007,
                    progfunc="None", fixedeff="TRUE", scm=T)

n_sped_60 <- augsynth(sped ~ treat, leaid ,year,nonfix_60_2006,
                    progfunc="None", fixedeff="TRUE", scm=T)

n_attd_60 <- augsynth(attd ~ treat, leaid ,year,nonfix_60_2009,
                    progfunc="None", fixedeff="TRUE", scm=T)

n_math_read_60 <- augsynth(math + read ~ treat, leaid ,year,nonfix_60_2007,
                         progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

n_sped_attd_60 <- augsynth(sped + attd ~ treat, leaid ,year,nonfix_60_2006,
                         progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

n_math_read_sped_attd_60 <- augsynth(math + read + sped + attd ~ treat, leaid ,year,nonfix_60_2006,
                                   progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

##############################################################################################################
### RUN SCM MODELS (FIXED) [60]
##############################################################################################################

f_math_read_sped_attd_60 <- augsynth(math + read + sped + attd ~ treat, leaid ,year,fix_60_2006,
                                   progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

##############################################################################################################
### RUN SCM MODELS (NON_FIXED ALTERNATIVE) [60]
##############################################################################################################

a_math_read_sped_attd_60 <- augsynth(math + read + sped + attd ~ treat, leaid ,year,nonfix_51_2006,
                                     progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

##############################################################################################################
### RUN SCM MODELS (NON_FIXED ALTERNATIVE) [30]
##############################################################################################################

n_math_read_sped_attd_30 <- augsynth(math + read + sped + attd ~ treat, leaid ,year,nonfix_30_2006,
                                     progfunc="None", fixedeff="TRUE", scm=T, combine_method="concat")

##############################################################################################################
### EXPORT STORED RESULTS
##############################################################################################################


#=========================#
# ==== prep models ====
#=========================#
# put all the model objects into a list. This will make it easier to operate on
# all the models without typing the same thing a bunch. I would  put the results in a list from 
# the begining, but it will be easy enough to make a list right now. 
# start by initializing a list to store the objects in
model_objects <- list()

# loop over all objects in the global enviorment 
for(object_i in ls()){
  # if that object is an augsynth class
  if(any(class(get(object_i)) == "augsynth")){
    # put it into our list. 
    model_objects[[object_i]] <- get(object_i)
  }
}

#=========================#
# ==== make reg table ====
#=========================#

# write a function to extract what we need from the model objects 
# takes the model object and the name of the model 
res_extractor <- function(in_model_object, in_model_name){
  
  # make the summary object 
  sum_obj <- summary(in_model_object,  inf_type = "jackknife")
  
  # grab out each thing we need 
  ave_att <- sum_obj[["average_att"]]
  l2_imb   <- sum_obj[["l2_imbalance"]]
  l2_imb_scaled   <- sum_obj[["scaled_l2_imbalance"]]
  
  # make the table to ouput using dplyer by adding in the l2 stuff 
  out_tab <- ave_att %>% 
    mutate(L2_imbalance_unscaled = l2_imb,
           L2_imbalance_scaled = l2_imb_scaled,
           model = in_model_name)
  
  # return our table 
  return(out_tab)
  
}

# now we are going to run that function over all of our models and model names 
# mapply takes a function and lists. It runs the functions with the i'th object in each list i times
# basically a loop of the function over the lists 
res_tab_list <- mapply(res_extractor, model_objects, names(model_objects), SIMPLIFY = FALSE)

# stack up the tables 
res_tab <- bind_rows(res_tab_list)

# now models with only one input are missing the outcome variable. Lets fix that 
res_tab <- res_tab %>% 
  # in the case where outcome is NA, full it in with model but remove extra components 
  mutate(Outcome = case_when(is.na(Outcome) ~ str_remove_all(model, "_60|n_|f_"),
                             TRUE ~ Outcome)) %>% 
  # rename outcome to subject 
  rename(subject = Outcome)

# Now we just need to reshape the data 
# first make it longer, 
long_reg_tab <- pivot_longer(res_tab,
                             cols = c("Estimate", "Std.Error", "L2_imbalance_unscaled", "L2_imbalance_scaled"),
                             names_to = "statistic")

# now make it wide again, but how we want it 
wide_reg_tab <- pivot_wider(long_reg_tab, 
                            id_cols = c("subject", "statistic"), 
                            names_from = "model", 
                            values_from = "value")

#============================#
# ==== make weight table ====
#============================#

# write function to extact weights 
weight_extractor <- function(in_model_object, in_model_name){
  
  # grab weignt, add model name, add a temporary id 
  out_weight <- data.frame(weight = in_model_object[["weights"]]) %>% 
    mutate(model = in_model_name,
           id     = 1:nrow(.))
  
  return(out_weight)
}

# run this on our list, bind the rsults, make it wide 
res_weight_list <- mapply(weight_extractor, model_objects, names(model_objects), SIMPLIFY = FALSE)
res_weight_long <- bind_rows(res_weight_list)
res_weight_wide <- pivot_wider(res_weight_long, 
                               id_cols = id, 
                               names_from = model,
                               values_from = weight)

# get values to merge to ID's 
# get the treated id 
treated_id <- nonfix_60_2007 %>% 
  filter(treat == 1) %>% 
  pull(leaid) %>% 
  unique() # get unique values 

# get unique ids that aren't treated 
id_vals <- nonfix_60_2007 %>% 
  filter(leaid != treated_id) %>%  # remove the treated id 
  pull(leaid) %>% # grab this vector 
  unique() # get unique values 

# sort from low to high 
id_vals <- sort(id_vals)

# add it onto the weight table 
res_weight_wide <- res_weight_wide %>% 
  mutate(LEAID = id_vals) %>%  # add new id
  select(-id) # remove old id 

# reorder the columns 
res_weight_wide <- res_weight_wide %>% 
  select(LEAID, everything())

#====================#
# ==== save them ====
#====================#

write.csv(long_reg_tab, "reg_results_long_60.csv", row.names = FALSE)
write.csv(wide_reg_tab, "reg_results_wide_60.csv", row.names = FALSE)
write.csv(res_weight_wide, "reg_weights_60.csv", row.names = FALSE)

# sum<-summary(n_math_read_sped_attd_60)
# write.csv(sum[["att"]], "att.csv", row.names = FALSE)