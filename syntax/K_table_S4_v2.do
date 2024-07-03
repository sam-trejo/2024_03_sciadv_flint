
***********************************************************************************
*** 
***********************************************************************************

import delimited "${data}\weights_2023_11_25.csv", numericcols(_all) clear
tostring leaid*, replace
drop leaid_alternative* a_math_read_sped_attd_60 n_math_read_sped_attd_30
tempfile hold1
save `hold1', replace

import delimited "${data}\weights_2023_11_25.csv", numericcols(_all) clear

tostring leaid*, replace
keep leaid_alternative50 a_math_read_sped_attd_60
drop if leaid_alternative50=="" | leaid_alternative50=="."
tempfile hold2
save `hold2', replace

import delimited "${data}\weights_2023_11_25.csv", numericcols(_all) clear

tostring leaid*, replace
keep leaid_alternative30 n_math_read_sped_attd_30
drop if leaid_alternative30=="" | leaid_alternative30=="."
tempfile hold3
save `hold3', replace

use "${data}\fixed.dta", clear

foreach var in math read sped attd {
	rename `var' fix_`var'
}
keep id year fix_*
tempfile hold4
save `hold4', replace

***********************************************************************************
*** 
***********************************************************************************

use "${data}\all_dist_2006-2019.dta", clear

rename id leaid_preferred
merge m:1 leaid_preferred using `hold1', generate(_merge1)

rename leaid_preferred leaid_alternative50
merge m:1 leaid_alternative50 using `hold2', generate(_merge2)

rename leaid_alternative50 leaid_alternative30
merge m:1 leaid_alternative30 using `hold3', generate(_merge3)

rename leaid_alternative30 id 
merge 1:1 id year using `hold4', keep(1 3) nogenerate

keep if _merge1==3 | _merge2==3 | _merge3==3 | flint
tempfile hold5
save `hold5', replace

keep if flint
keep math read sped attd id flint year
merge 1:1 id year using `hold5', keep(3) nogenerate
tempfile flint
save `flint', replace

***********************************************************************************
*** 
***********************************************************************************

use `hold5', clear

global scm	a_math_read_sped_attd_60 f_math_read_sped_attd_60 n_math_read_sped_attd_30  ///
			n_math_read_sped_attd_60

foreach var of global scm {
	*replace `var' = 0 if `var'==.
	replace `var' = round(`var',.01)
}
	
keep if year==2014

egen max = rowmax(${scm})
tab max
keep if max>.01 | flint

keep obs poor black math read sped attd fix_* id flint year ${scm}
gsort - n_math_read_sped_attd_60
order id n_math_read_sped_attd_60 f_math_read_sped_attd_60 a_math_read_sped_attd_60 n_math_read_sped_attd_30 obs black poor 	
			
export excel using "${table}\table_S4_${date}.xls", firstrow(varl) replace