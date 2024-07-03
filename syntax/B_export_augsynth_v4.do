/*************************************************************************
Goal: This code takes non-fixed and fixed panel of all geographic district years
and preps and exports the data to be used in the "augsynth" package in R.

Date created: 06/8/2019
Data modified: 05/01/2020;

Created by: Sam Trejo
**************************************************************************/

***********************************************************************************
*** LOAD & PREP NON-FIXED DATA
***********************************************************************************

***load data
use "${data}\non_fixed.dta", clear

***rename id
rename id leaid

***export 60 district sample, 2006 on
export delimited using "$data\augsyn_nonfix_60_2006_$date.csv", replace

***export 60 district sample, 2007 on
preserve
keep if year>=2007
export delimited using "$data\augsyn_nonfix_60_2007_$date.csv", replace
restore 

***export 60 district sample, 2009 on
preserve
keep if year>=2009
export delimited using "$data\augsyn_nonfix_60_2009_$date.csv", replace
restore 

***restrict to 30 district sample
keep if sample_27

***export 30 district sample, all years
export delimited using "$data\augsyn_nonfix_30_2006_$date.csv", replace

***export 30 district sample, 2007 on
preserve
keep if year>=2007
export delimited using "$data\augsyn_nonfix_30_2007_$date.csv", replace
restore 

***export 30 district sample, 2009 on
preserve
keep if year>=2009
export delimited using "$data\augsyn_nonfix_30_2009_$date.csv", replace
restore 

***********************************************************************************
*** LOAD & PREP FIXED DATA
***********************************************************************************

***load data
use "${data}\fixed.dta", clear

***rename id
rename id leaid

***export 60 district sample, all years
export delimited using "$data\augsyn_fix_60_2006_$date.csv", replace

***export 60 district sample, 2007 on
preserve
keep if year>=2007
export delimited using "$data\augsyn_fix_60_2007_$date.csv", replace
restore 

***export 60 district sample, 2006 on
preserve
keep if year>=2009
export delimited using "$data\augsyn_fix_60_2009_$date.csv", replace
restore 

***restrict to 30 district sample
keep if sample_27

***export 30 district sample, 2006 on
export delimited using "$data\augsyn_fix_30_2006_$date.csv", replace

***export 30 district sample, 2007 on
preserve
keep if year>=2007
export delimited using "$data\augsyn_fix_30_2007_$date.csv", replace
restore 

***export 30 district sample, 2009 on
preserve
keep if year>=2009
export delimited using "$data\augsyn_fix_30_2009_$date.csv", replace
restore 


***********************************************************************************
*** LOAD & PREP NON-FIXED UNION52 DATA
***********************************************************************************

***load data
use "${data}\all_dist_2006-2019.dta", clear

drop lep
drop mobility
drop obs_sub

preserve
	keep if year==2014

	centile black, centile(75)
	local black81 = `r(c_1)'

	centile poor, centile(75)
	local poor81 = `r(c_1)'

	keep if black>=`black81' & poor>=`poor81'
	codebook id
	
	keep id
	gen sample_alt51=1
	
	tempfile hold
	save `hold', replace
restore

merge m:1 id using `hold', keep(3) nogenerate

***rename id
rename id leaid

***export 60 district sample, 2006 on
export delimited using "$data\augsyn_nonfix_51_2006_$date.csv", replace

***export 60 district sample, 2007 on
preserve
keep if year>=2007
export delimited using "$data\augsyn_nonfix_51_2007_$date.csv", replace
restore 

***export 60 district sample, 2009 on
*preserve
keep if year>=2009
export delimited using "$data\augsyn_nonfix_51_2009_$date.csv", replace
*restore 