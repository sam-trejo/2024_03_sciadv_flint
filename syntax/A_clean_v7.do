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
	keep id name year flint treat fix all data_sub obs_sub sample_55 sample_27 ///
		 math read sped attd abst obs obs_math obs_read obs_sped obs_attd  ///
		 female white black hisp poor lep charter admin tested mobility	 
	order id name year flint treat fix all data_sub obs_sub sample_55 sample_27 ///
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
	label var fix "Fixed Data"
	label var all "All District Data"
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
gen fix=0
gen all=0

gen data_sub=0
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

gen obs_sub=.

*** run data clean program
mde_clean

save "${data}\non_fixed.dta", replace

/*
***********************************************************************************
*** NON-FIXED DATA, BY GENDER
***********************************************************************************

use "${gen}", clear

***label dataset
gen fix=0
gen all=0

gen data_sub=1
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

rename female obs_sub
gen female=obs_sub

*** run data clean program
mde_clean

save "${data}\by_gen.dta", replace

***********************************************************************************
*** NON-FIXED DATA, BY GRADE
***********************************************************************************

use "${grd}", clear

***label dataset
gen fix=0
gen all=0

gen data_sub=2
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

rename grade_highlow obs_sub

*** run data clean program
mde_clean

save "${data}\by_grd.dta", replace

***********************************************************************************
*** NON-FIXED DATA, BY ADMINISTRATIVE
***********************************************************************************

use "${adm}", clear

***label dataset
gen fix=0
gen all=0

gen data_sub=4
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

rename samedcode_lea obs_sub
gen flag_resdcode=obs_sub

*** run data clean program
mde_clean

save "${data}\by_adm.dta", replace
*/

***********************************************************************************
*** FIXED DATA, NO SUBGROUPS
***********************************************************************************

use "${fix}", clear

***label dataset
gen fix=1
gen all=0

gen data_sub=0
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

gen obs_sub=.

*** run data clean program
mde_clean

save "${data}\fixed.dta", replace


***********************************************************************************
*** All DISTRICTS DATA, JUST 2014, NO SUBGROUPS
***********************************************************************************

use "${all}", clear

***
gen samelea_prioryear=.

***label dataset
gen fix=0
gen all=1

gen data_sub=0
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

gen obs_sub=.

*** run data clean program
mde_clean

***restrict years
keep if year==2014

save "${data}\all_dist.dta", replace

***********************************************************************************
*** All DISTRICTS DATA, ALL YEARS, NO SUBGROUPS
***********************************************************************************

use "${all}", clear

***label dataset
gen fix=0
gen all=1

gen data_sub=0
label define subgroup 0 "None" 1 "Gender" 2 "Grade (Binary)" 3 "Grade (Binned)" 4 "Adminstrative", add
label values data_sub subgroup

gen obs_sub=.
gen mobility=.

*** run data clean program
mde_clean

save "${data}\all_dist_2006-2019.dta", replace
