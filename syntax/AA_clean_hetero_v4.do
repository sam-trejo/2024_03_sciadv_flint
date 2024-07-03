***********************************************************************************
*** DEFINE DATA CLEAN PROGRAM
***********************************************************************************

capture program drop mde_clean
program define mde_clean
	***rename variables
	rename residentlea_weight id
	rename residentlea_weight_name name
	rename numeracy_std math
	rename literacy_std read
	rename speddummy sped
	rename frac_attend3_new attd
	rename chronic_abs abst
	rename frac_tested_trad tested
	rename flag_resdcode admin
	capture rename samelea_prioryear mobility

	***change id to string
	tostring id, force replace format(%05.0f)

	***generate flint indicator
	gen flint=id=="25010"

	***generate treatment indicator
	gen treat=flint & year>=2015

	***sort, keep and order variables
	sort id year
	keep id name year flint treat data_sub obs_sub sample_55 sample_27 ///
		 math read sped attd abst obs obs_math obs_read obs_sped obs_attd  ///
		 female white black hisp poor lep charter admin tested mobility	 
	order id name year flint treat data_sub obs_sub sample_55 sample_27 ///
		 math read sped attd abst obs obs_math obs_read obs_sped obs_attd  ///
		 female white black hisp poor lep charter admin tested mobility
		 
	***restrict years
	keep if inrange(year, 2006, 2019)

	***remove bad outcome years
	replace attd=. if year<2009
	replace abs=. if year<2009
	replace math=. if year<2007
	replace read=. if year<2007

	***format sped
	format sped %5.2g
	format black %5.2g
	format poor %5.2g

	***label variables
	label var id "Geographic District ID"
	label var name "Geographic District Name"
	label var year "School Year (Spring)"
	label var flint "Flint"
	label var treat "Flint * Post-2014"
	label var data_sub "Subgroup of Data"
	label var data_sub "Subgroup of Observation"
	label var sample_55 "55 Control District Sample"
	label var sample_27 "27 Control District Sample"
	label var math "Math Achievement"
	label var read "Reading Achievement"
	label var sped "Special Needs"
	label var attd "Attendance"
	label var abst "Chronic Absenteeism"
	label var obs "Number of Observations"
	label var obs_math "Math Achievement Observations"
	label var obs_read "Reading Achievement Observations"
	label var obs_sped "Special Needs Observations"
	label var obs_attd "Attendance Observations"
	label var female "Fraction Female"
	label var white "Fraction White"
	label var black "Fraction Black"
	label var hisp "Fraction Hispanic"
	label var poor "Fraction Economically Disadvantaged "
	label var lep "Fraction Limited English Proficiency"
	label var charter "Fraction Attending Charter Schools"
	label var admin "Fraction Attending Administrative District"
	label var tested "Fraction Tested"
	label var mobility "Fraction Same District t-1"
end

***********************************************************************************
*** NON-FIXED DATA, NO SUBGROUPS
***********************************************************************************

use "${non_fix}", clear

***label dataset
gen data_sub=0

gen obs_sub=0

*** run data clean program
mde_clean

keep if flint

tempfile hold1
save `hold1', replace

***********************************************************************************
*** NON-FIXED DATA, BY GENDER
***********************************************************************************

use "${gen}", clear

***label dataset
gen data_sub=1

rename female obs_sub
gen female=obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold2
save `hold2', replace

***********************************************************************************
*** NON-FIXED DATA, BY GRADE (BINARY)
***********************************************************************************

use "${grd_hilo}", clear

***label dataset
gen data_sub=2

rename grade_highlow obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold3
save `hold3', replace


***********************************************************************************
*** NON-FIXED DATA, BY GRADE (BLOCKS)
***********************************************************************************
/*
use "${grd_2blk}", clear

***label dataset
gen data_sub=8

rename grade_2blocks obs_sub

*** run data clean program
mde_clean

keep if flint

label define grade_2blk 1 "K-2" 2 "3-4" 3 "5-6" 4 "7-8" 5 "9-10" 6 "11-12"
label values obs_sub grade_2blk

tempfile hold8
save `hold8', replace
*/
***********************************************************************************
*** NON-FIXED DATA, BY GRADE (BLOCKS)
***********************************************************************************
/*
use "${grd_blk}", clear

***label dataset
gen data_sub=3

rename grade_blocks obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold4
save `hold4', replace
*/

***********************************************************************************
*** NON-FIXED DATA, BY ADMINISTRATIVE
***********************************************************************************
/*
use "${adm}", clear

***label dataset
gen data_sub=4

rename samedcode_lea obs_sub
gen flag_resdcode=obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold5
save `hold5', replace
*/
***********************************************************************************
*** NON-FIXED DATA, BY PIPES
***********************************************************************************

use "${pipe}", clear

***label dataset
gen data_sub=5

rename lead1 obs_sub
gen lead1 = obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold6
save `hold6', replace

/*
***********************************************************************************
*** NON-FIXED DATA, BY SES
***********************************************************************************

use "${ses}", clear

***label dataset
gen data_sub=6

rename ses_pc_qtile3 obs_sub
gen ses_pc_qtile3=obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold7
save `hold7', replace
*/

***********************************************************************************
*** NON-FIXED DATA, BY SES2
***********************************************************************************

use "${ses2}", clear

***label dataset
gen data_sub=9

rename ses_pc_qtile2 obs_sub
gen ses_pc_qtile2=obs_sub

*** run data clean program
mde_clean

keep if flint

tempfile hold9
save `hold9', replace


***********************************************************************************
*** NON-FIXED DATA, BY EVER NOT FLINT
***********************************************************************************

use "${enf}", clear

***label dataset
gen data_sub=7

rename ever_not_flint obs_sub
gen ever_not_flint=obs_sub

*** run data clean program
mde_clean

keep if flint

***********************************************************************************
*** COMBINE
***********************************************************************************


foreach i in 1 2 3 6 9 {
	append using `hold`i''
}

label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative" 5 "Pipes" 6 "SES" 7 "Ever Not Flint" 8 "Grade (Blocks of Two)" 9 "SES (Dichotomous)", add
label values data_sub subgroup

sort data_sub

save "${data}\hetero_flint_only.dta", replace
