
***********************************************************************************
*** PREP SYNTH CONTROL DATA
***********************************************************************************

use "${data}\weights_2023_11_25.dta", clear
keep leaid_preferred n_math_read_sped_attd_60
rename leaid_preferred id
rename n_math_read_sped_attd_60 wgt 
replace wgt = round(wgt,.001)
keep if inrange(wgt,.001,1)
tempfile wgts
save `wgts', replace

use "${data}\non_fixed.dta", clear
destring id, replace
merge m:1 id using `wgts'
keep if _merge==3
drop _merge

collapse (mean) flint treat math read sped attd [w=wgt], by(year)
gen obs_sub=99

tempfile hold
save `hold', replace

***********************************************************************************
*** GENDER
***********************************************************************************

use "${data}\hetero_flint_only.dta", clear

estimates clear

preserve
	keep if data_sub==0
	sum obs
	local tot=`r(mean)'
restore 
	
preserve
	keep if data_sub==1
	append using `hold'

	sort obs_sub year
	xtset obs_sub year	

	gen male = obs_sub==0 
	replace male = male * treat
	
	sum obs if obs_sub==0
	local p0 = round(`r(mean)'/`tot',.01)
	label var male "Male [p=`p0']"
	
	replace female = obs_sub==1
	replace female = female * treat
	
	sum obs if obs_sub==1
	local p1 = round(`r(mean)'/`tot',.01)
	label var female "Female [p=`p1']"
	
	foreach var in math sped { // read attd 
		quietly {
			
			eststo: reg `var' male i.year ib99.obs_sub if flint==0 | obs_sub==0
			
			local b0=_b[male]
			local v0= e(V)[1,1]
			
			eststo: reg `var' female i.year ib99.obs_sub if flint==0 | obs_sub==1  
			
			local b1=_b[female]
			local v1= e(V)[1,1]
			
			local z=abs((`b0'-`b1')/((`v0'+`v1')^.5))
			local p =round((1-normal(`z'))*2,.001)
			
			estadd local pval "0`p'", replace			

		}
	}
	
	esttab  ///
		using "${table}\table_4_${date}.csv", ///
	    se label nostar nogaps noobs compress replace  ///
	    title("A. Gender") ///
	    keep(male female) ///
	    stat(pval, label("p-value")) ///
		nonotes addnotes(" ")

restore
	
***********************************************************************************
*** GRADE (BINARY)
***********************************************************************************

estimates clear
preserve
	keep if data_sub==2
	append using `hold'

	sort obs_sub year
	xtset obs_sub year	

	gen lo = obs_sub==0 
	replace lo = lo * treat
	
	sum obs if obs_sub==0
	local p0 = round(`r(mean)'/`tot',.01)
	label var lo "Grade 5 [p=`p0']"
	
	gen hi = obs_sub==1
	replace hi = hi * treat
	
	sum obs if obs_sub==1
	local p1 = round(`r(mean)'/`tot',.01)
	label var hi "Grade 6 [p=`p1']"
	
	foreach var in math sped { // read attd
		quietly {
			eststo: reg `var' lo i.year ib99.obs_sub if flint==0 | obs_sub==0
			
			local b0=_b[lo]
			local v0= e(V)[1,1]
			
			eststo: reg `var' hi i.year ib99.obs_sub if flint==0 | obs_sub==1  
			
			local b1=_b[hi]
			local v1= e(V)[1,1]
			
			local z=abs((`b0'-`b1')/((`v0'+`v1')^.5))
			local p =round((1-normal(`z'))*2,.001)
			
			estadd local pval "0`p'", replace			
		}
	}
	
	esttab  ///
		using "${table}\table_4_${date}.csv", ///
	    se label nostar nogaps noobs nomtitles nonumber compress append  ///
	    title("B. Grade") ///
	    keep(lo hi) ///
	    stat(pval, label("p-value")) ///
		nonotes addnotes(" ") 	
restore

***********************************************************************************
*** SES
***********************************************************************************

estimates clear
preserve
	keep if data_sub==9
	append using `hold'
	
	sort obs_sub year
	xtset obs_sub year	

	gen hi = obs_sub==1 
	replace hi = hi * treat
	sum obs if obs_sub==1
	local p1 = round(`r(mean)'/`tot',.01)
	label var hi "Above Median [p=`p1']"
	
	gen lo = obs_sub==2
	replace lo = lo * treat
	sum obs if obs_sub==2
	local p2 = round(`r(mean)'/`tot',.01)
	label var lo "Below Medium [p=`p2']"
	
	foreach var in math sped  { // read attd
		quietly {
			eststo: reg `var' lo i.year ib99.obs_sub if flint==0 | obs_sub==2
			
			local b0=_b[lo]
			local v0= e(V)[1,1]
			
			eststo: reg `var' hi i.year ib99.obs_sub if flint==0 | obs_sub==1  
			
			local b1=_b[hi]
			local v1= e(V)[1,1]
			
			local z=abs((`b0'-`b1')/((`v0'+`v1')^.5))
			local p =round((1-normal(`z'))*2,.001)
			
			estadd local pval "0`p'", replace			
		}
	}

	esttab  ///
		using "${table}\table_4_${date}.csv", ///
	    se label nostar nogaps noobs nomtitles nonumber compress append  ///
	    title("C. Socioeconomic Status") ///
	    keep(lo hi) ///
	    stat(pval, label("p-value")) ///
		nonotes addnotes(" ") 	
restore		

***********************************************************************************
*** SERVICE LINE
***********************************************************************************

estimates clear
preserve
	keep if data_sub==5
	append using `hold'

	*replace obs_sub = 3 if obs_sub==.
	
	egen tot_obs = total(obs) if inrange(obs_sub,0,1), by(year)
	sum tot_obs
	local tot_pipes=`r(mean)'
	
	sort obs_sub year
	xtset obs_sub year	

	gen lead = obs_sub==1 
	replace lead = lead * treat
	sum obs if obs_sub==1
	local p1 = round(`r(mean)'/`tot_pipes',.01)
	label var lead "Lead [p=`p1']"

	gen copp = obs_sub==0
	replace copp = copp * treat
	sum obs if obs_sub==0
	local p2 = round(`r(mean)'/`tot_pipes',.01)
	label var copp "Copper  [p=`p2']"	
	
	foreach var in math  sped  { // read attd
		quietly {
			eststo: reg `var' copp i.year ib99.obs_sub if flint==0 | obs_sub==0
			
			local b0=_b[copp]
			local v0= e(V)[1,1]
			
			eststo: reg `var' lead i.year ib99.obs_sub if flint==0 | obs_sub==1  
			
			local b1=_b[lead]
			local v1= e(V)[1,1]
			
			local z=abs((`b0'-`b1')/((`v0'+`v1')^.5))
			local p =round((1-normal(`z'))*2,.001)
			
			estadd local pval "0`p'", replace		
		}
	}
	
	esttab ///
		using "${table}\table_4_${date}.csv", ///
	    se label nostar nogaps noobs nomtitles nonumber compress append  ///
	    title("D. Service Line Material") ///
	    keep(lead copp) ///
	    stat(pval, label("p-value")) ///
		nonotes addnotes(" ") 		
restore			
	
	
***********************************************************************************
*** EVER NOT FLINT
***********************************************************************************

estimates clear
preserve
	keep if data_sub==7
	append using `hold'

	sort obs_sub year
	xtset obs_sub year	

	gen immobile = obs_sub==0 
	replace immobile = immobile * treat
	
	sum obs if obs_sub==0
	local p0 = round(`r(mean)'/`tot',.01)
	label var immobile "Immobile [p=`p0']"
	
	gen mobile = obs_sub==1
	replace mobile = mobile * treat
	
	sum obs if obs_sub==1
	local p1 = round(`r(mean)'/`tot',.01)
	label var mobile "Mobile [p=`p1']"
	
	foreach var in math sped { // read attd
		quietly {
			eststo: reg `var' immobile i.year ib99.obs_sub if flint==0 | obs_sub==0
			
			local b0=_b[immobile]
			local v0= e(V)[1,1]
			
			eststo: reg `var' mobile i.year ib99.obs_sub if flint==0 | obs_sub==1  
			
			local b1=_b[mobile]
			local v1= e(V)[1,1]
			
			local z=abs((`b0'-`b1')/((`v0'+`v1')^.5))
			local p =round((1-normal(`z'))*2,.001)
			
			estadd local pval "0`p'", replace			
		}
	}
	
	esttab  ///
		using "${table}\table_4_${date}.csv", ///
	    se label nostar nogaps noobs nomtitles nonumber compress append  ///
	    title("E. District Mobility") ///
	    keep(immobile mobile) ///
	    stat(pval, label("p-value")) ///
		nonotes addnotes(" ") 
restore




