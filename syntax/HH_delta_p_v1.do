
***********************************************************************************
*** PREP SYNTH CONTROL DATA
***********************************************************************************

use "${data}\hetero_flint_only.dta", clear

tempfile hold
save `hold', replace

preserve
	keep if data_sub==0 & year<=2014
	sum obs
	local pre_tot=`r(mean)'
restore 

preserve
	keep if data_sub==0 & year>2014
	sum obs
	local post_tot=`r(mean)'
restore 	
	
	display `pre_tot'
	display `post_tot'
	
preserve
	keep if data_sub==1
	replace female = obs_sub==1
	egen p_pre = mean(obs) if female & year<=2014
	egen p_post = mean(obs) if female & year>2014
	sum p_pre 
	local pre_n = `r(mean)'

	display "*************FEMALE*************"
	display "PRE=" round(`pre_n'/`pre_tot',.001)
	sum p_post
	local post_n = `r(mean)'

	display "POST=" round(`post_n'/`post_tot',.001)
	display "POST-PRE=" round(`post_n'/`post_tot',.001) - round(`pre_n'/`pre_tot',.001)
restore	

preserve
	keep if data_sub==2
	replace hi = obs_sub==1
	egen p_pre = mean(obs) if hi & year<=2014
	egen p_post = mean(obs) if hi & year>2014
	sum p_pre 
	local pre_n = `r(mean)'

	display "*************HIGH GRADE*************"
	display "PRE=" round(`pre_n'/`pre_tot',.001)
	sum p_post
	local post_n = `r(mean)'

	display "POST=" round(`post_n'/`post_tot',.001)
	display "POST-PRE=" round(`post_n'/`post_tot',.001) - round(`pre_n'/`pre_tot',.001)
restore 

preserve
	keep if data_sub==5
	gen copp = obs_sub==0
	egen p_pre = mean(obs) if copp & year<=2014
	egen p_post = mean(obs) if copp & year>2014
	sum p_pre 
	local pre_n = `r(mean)'

	display "*************COPPER*************"
	display "PRE=" round(`pre_n'/`pre_tot',.001)
	sum p_post
	local post_n = `r(mean)'

	display "POST=" round(`post_n'/`post_tot',.001)
	display "POST-PRE=" round(`post_n'/`post_tot',.001) - round(`pre_n'/`pre_tot',.001)
restore 

preserve
	keep if data_sub==9
	gen hi = obs_sub==1 
	egen p_pre = mean(obs) if hi & year<=2014
	egen p_post = mean(obs) if hi & year>2014
	sum p_pre 
	local pre_n = `r(mean)'

	display "*************SES*************"
	display "PRE=" round(`pre_n'/`pre_tot',.001)
	sum p_post
	local post_n = `r(mean)'

	display "POST=" round(`post_n'/`post_tot',.001)
	display "POST-PRE=" round(`post_n'/`post_tot',.001) - round(`pre_n'/`pre_tot',.001)
restore 



preserve
	keep if data_sub==7
	gen mobile = obs_sub==1
	egen p_pre = mean(obs) if mobile & year<=2014
	egen p_post = mean(obs) if mobile & year>2014
	sum p_pre 
	local pre_n = `r(mean)'

	display "*************MOBILE*************"
	display "PRE=" round(`pre_n'/`pre_tot',.001)
	sum p_post
	local post_n = `r(mean)'

	display "POST=" round(`post_n'/`post_tot',.001)
	display "POST-PRE=" round(`post_n'/`post_tot',.001) - round(`pre_n'/`pre_tot',.001)
restore 






