***********************************************************************************
*** SETUP
***********************************************************************************

clear all
set more off
cap log close
set trace off
pause on
capture postutil close

cd ..
cd ..
global flint "`c(pwd)'"

***********************************************************************************
*************************************Step 1****************************************
*Call the student level data file 
***********************************************************************************
***********************************************************************************

use "${flint}\data\student_level_nonfixed_55districts_2024_05_20.dta", clear

***********************************************************************************
*************************************Step 2****************************************
*Light cleaning and variable generation
***********************************************************************************
***********************************************************************************

***creating flag for those students who attend the same district as the residentlea*year
gen flag_resdcode = 0 if (!missing(residentlea_weight) & !missing(dcode_weight))
replace flag_resdcode = 1 if residentlea_weight == dcode_weight & (!missing(residentlea_weight) & !missing(dcode_weight))

***gen observation count variables
gen obs=1
gen obs_ach=mean_ach !=.
gen obs_read=literacy !=.
gen obs_math=numeracy !=.
gen obs_attd=frac_attend3 !=.
gen obs_sped=speddummy !=.


*use has_assessment has_any_assessment count_3to8
gen frac_tested_trad = has_assessment/count_3to8
gen frac_tested_all = has_any_assessment/count_3to8


***Setting the scores outside grades 3-8 to missing
foreach v of varlist mean_ach literacy numeracy { 
	replace `v' = . if (grade_fnl < 3 | grade_fnl > 8) & !missing(grade_fnl)
}

**Destring LEP
gen lep2 = lep == "Y" if !missing(lep)
drop lep
rename lep2 lep

***********************************************************************************
*************************************Step 3****************************************
*Collapse data to the district-year level 
***********************************************************************************
***********************************************************************************

***collapse student level data to geodist-by-year
collapse (rawsum) obs* (firstnm) sample_55 sample_27 (mean) frac_tested_trad frac_tested_all flag_resdcode charter female white black hisp poor speddummy lep samebcode_prioryear samedcode_prioryear samelea_prioryear mean_ach literacy numeracy frac_attend3 frac_attend3_new suspended chronic_abs, by(residentlea_weight year) 

label variable frac_tested_trad "fraction tested (traditionally tested/count grades 3 to 8)"
label variable frac_tested_all "fraction tested (all tested/count grades 3 to 8)"
label variable obs "Number of Observations"
label variable obs_ach "Number of Observations w/Achievement"
label variable obs_read "Number of Observations w/Reading"
label variable obs_math "Number of Observations w/Math"
label variable obs_attd "Number of Observations w/Attendance"
label variable obs_sped "Number of Observations w/Sped"
label variable year "Year"
label variable residentlea_weight "Residential LEA"
label variable flag_resdcode "Proportion of students with same dcode and same residentlea"
label variable charter "Charter"
label variable female "Female"
label variable white  "White"
label variable black "Black"
label variable hisp "Hispanic"
label variable poor "Economically disadvantaged"
label variable speddummy "Recieved Special Education"
label variable lep "Limited English Proficient"
label variable samebcode_prioryear  "Same school the prior year"
label variable samedcode_prioryear "Same district the prior year"
label variable samelea_prioryear "Same lea the prior year"
label variable mean_ach "Mean achievement - Readign + Math"
label variable literacy "Reading"
label variable numeracy "Math"
label variable frac_attend3 "Attendance"
label variable frac_attend3_new "Attendance fixed"
label variable chronic_abs "Chronic absenteeism (>= 10%)"
label variable suspended "Suspension"
label variable sample_55 "Part of the 55 districts (incuding flint)"
label variable sample_27 "Part of the 27 districts (including flint)"

save "${flint}/data/mi_geodist_panel_dy_nonfixed_55districts.dta", replace	
