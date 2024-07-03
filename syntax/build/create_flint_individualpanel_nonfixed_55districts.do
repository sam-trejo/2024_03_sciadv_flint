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
*Create a restricted set of districts based on ses and student enrollment
***********************************************************************************
***********************************************************************************

*Calling the EPI (formerly SRSD) data to create key variables (average count, black, poor) by residential LEA for 2014. 

use "${flint}\data\raw\k12_student.dta", clear
sort ric year grade_fnl bcode_weight dcode_weight isd_weight

keep if year == 2014
keep ric black povertyflag residentlea_weight
drop if residentlea_weight == .

rename povertyflag poor

collapse (count) obs=ric (mean) black poor, by(residentlea_weight) 
drop if obs < 1000 & !missing(obs)
drop if residentlea_weight == 61020 | residentlea_weight == 82070 | residentlea_weight == 82080 | residentlea_weight == 13010
*excluding two districts without a name for 2014 (61020 and 82080) and with 0% of students enrolled in the same reslea as district after 2013-14. 
*We looked for names for these two districts in MIschool data in 2013-14 and they do not have data for this year (as if they did not exist).
*for residentlea 82070, we do have a name for this district but MIschool data shows data only until 2011-12 and the percent of students attending
*this same district is zero after 2013. residentlea13010 (Albion) is not observed after 2017 (annexed into Marshall)

foreach x in black poor {
  xtile p_`x'=`x', nq(100) 
 
  gen top5_`x'=p_`x'>95
  label var top5_`x' "Top 5 % of `x'" 
  
   gen top10_`x'=p_`x'>90
  label var top10_`x' "Top 10% of `x'" 
}

***"54" district sample  
count if (top10_black==1 | top10_poor==1) 
generate sample_55 = 0
replace sample_55 = 1 if (top10_black==1 | top10_poor==1)
*N=54 (exluding Flint)

***"27" district sample
count if (top5_black==1 | top5_poor==1) 
generate sample_27 = 0
replace sample_27 = 1 if (top5_black==1 | top5_poor==1)
*N=26 (excluding Flint)

*dropping non-relevant districts
drop if sample_55 == 0

gen residentlea_weight_str = string(residentlea_weight,"%05.0f")
gen st_leaid = residentlea_weight_str

keep residentlea_weight top5_black top10_black top5_poor top10_poor sample_55 sample_27
order residentlea_weight top5_black top10_black top5_poor top10_poor sample_55 sample_27

save "${flint}\data\temp\residentlea_55.dta", replace

***********************************************************************************
*************************************Step 2****************************************
*Creating a master list of rics based on the 55 districts that we want to examine.
*Correcting for Detroit (dcode and residentlea changed after 2017)
***********************************************************************************
***********************************************************************************

use "${flint}\data\raw\k12_student.dta", clear

*Standardizing the Detroit dcode. Background: starting in 2016-17 school year, the Detroit city school district (DPS, district code 82010) was eliminated as an operational district and was replaced by the district code 82015. Currently our residential LEA file uses the dcode "82015" and so we are changing the 82010 before 2012 to 82015 for both the dcode_weight and residentlea_weight. This change ensures that we are capturing all rics that have a Detroit residentlea_weight.
replace dcode_weight = 82015 if dcode_weight == 82010 & year <= 2011 & !missing(year)
replace residentlea_weight = 82015 if residentlea_weight == 82010 & year <= 2011 & !missing(year)

merge m:1 residentlea_weight using "${flint}\data_temp\residentlea_55.dta"
keep if _merge == 3
keep if grade_fnl < 13 & year >= 2003
keep ric 
gduplicates drop

save "${flint}\data\temp\rics_basedon55.dta", replace
*this data has the rics that lived in one of the 55 resident leas that we care about (including Flint)

***********************************************************************************
*************************************Step 3****************************************
*Creating a basic demographic file with student-level information based on the
*rics that lived in one of the 55 residential LEAs that we created above.
***********************************************************************************
***********************************************************************************

use "${flint}\data\raw\k12_student.dta", clear

replace dcode_weight = 82015 if dcode_weight == 82010 & year <= 2011 & !missing(year)
replace residentlea_weight = 82015 if residentlea_weight == 82010 & year <= 2011 & !missing(year)

merge m:1 ric using "${flint}\data\temp\rics_basedon55.dta"
keep if _merge == 3
keep if grade_fnl < 13 & year >= 2003

rename povertyflag poor 

/* Aside: Fixing Attendance __________________________________________________*/
bysort year grade_fnl bcode_weight: egen grade_year_attend=mean(frac_attend)
bysort year bcode_weight: egen year_attend=mean(frac_attend)

*creating attendance flag based on <50% attendance
generate attend_flag_50 = .
replace attend_flag_50 = 1 if frac_attend < .50 & frac_attend != .
replace attend_flag_50 = 0 if frac_attend != . & attend_flag_50 != 1

*aggregate flag for attendance by building-year-grade
bysort year grade_fnl bcode_weight: egen flag_grade_bldg_year = mean(attend_flag_50)

*creating a flag combining flagged observations at the individual and at the classroom level
generate flag_combined = .
replace flag_combined = 1 if attend_flag_50 == 1 & flag_grade_bldg_year >= .40 & flag_grade_bldg_year != . 
replace flag_combined = 0 if attend_flag_50 == 0 | flag_grade_bldg_year < .40

*reversing frac_attend3 for those who meet the flag_combined criteria
*this criteria is detecting classroom-level mistakes
generate frac_attend_new = frac_attend
replace frac_attend_new = 1 - frac_attend if flag_combined == 1 

*update attendance flag after first set of corrections
drop attend_flag_50 

generate attend_flag_50 = .
replace attend_flag_50 = 1 if frac_attend_new < .50 & frac_attend_new != .
replace attend_flag_50 = 0 if frac_attend_new != . & attend_flag_50 != 1

*calculate median
bysort ric: egen ind_median_attend = median(frac_attend_new) if frac_attend_new != .

*calculating the number of flags per student across available years
bysort ric: egen flag_years = sum(attend_flag_50)

*generate an individual-level variable looking at the deviation from the median
generate dev_median = .
replace dev_median = frac_attend_new - ind_median_attend 

*recalculating the new frac_attend3_new variable based on individual-level characteristics
replace frac_attend_new = 1 - frac_attend if attend_flag_50 == 1 & flag_years <= 2 & dev_median <= -.2 

*update attendance flag after second set of corrections/updates
drop attend_flag_50 

generate attend_flag_50 = .
replace attend_flag_50 = 1 if frac_attend_new < .50 & frac_attend_new != .
replace attend_flag_50 = 0 if frac_attend_new != . & attend_flag_50 != 1

drop flag_years
bysort ric: egen flag_years = sum(attend_flag_50)

*creating a flag for those observations that were changed
generate flag_change_attend = .
replace flag_change_attend = 1 if frac_attend != frac_attend_new
replace flag_change_attend = 0 if frac_attend == frac_attend_new

/* Return/End of Aside _______________________________________________________*/

*Defining the time structure of the data set so we can use the lag (L.) function
tsset ric year
tsfill, full

*counting students enrolled in 3 to 8
gen count_3to8 = 0
replace count_3to8 = 1 if (grade_fnl >= 3 & grade_fnl <=8)

*Adding chronic abst
generate chronic_abs = .
replace chronic_abs = 1 if frac_attend_new <= .90 & !missing(frac_attend_new)
replace chronic_abs = 0 if frac_attend_new > .90 & !missing(frac_attend_new) 

*Creating lag variables
gen lag_frac_attend_new = L.frac_attend_new
gen lag_chronicabs = L.chronic_abs
gen lag_susp = L.suspended
gen lag_bcode_weight = L.bcode_weight
gen lag_dcode_weight = L.dcode_weight
gen lag_reslea_weight = L.residentlea_weight

*Creating attendence lag at the bcod*year level
egen lag_frac_attend_new_sy = mean(lag_frac_attend_new), by(bcode_weight year)
egen lag_susp_sy = mean(lag_susp), by(bcode_weight year)
egen lag_chronicabs_sy = mean(lag_chronicabs), by(bcode_weight year)

*Creating flag for samebcode from prior year
generate samebcode_prioryear = .
replace samebcode_prioryear = 1 if lag_bcode_weight == bcode_weight & !missing(lag_bcode_weight) & !missing(bcode_weight)
replace samebcode_prioryear = 0 if lag_bcode_weight != bcode_weight & !missing(lag_bcode_weight) & !missing(bcode_weight)

*Create flag from samedcode from prior year
generate samedcode_prioryear = .
replace samedcode_prioryear = 1 if lag_dcode_weight == dcode_weight & !missing(lag_dcode_weight) & !missing(dcode_weight)
replace samedcode_prioryear = 0 if lag_dcode_weight != dcode_weight & !missing(lag_dcode_weight) & !missing(dcode_weight)

*Create flag from samereside lea from prior year
generate samelea_prioryear = .
replace samelea_prioryear = 1 if lag_reslea_weight == residentlea_weight & !missing(lag_reslea_weight) & !missing(residentlea_weight)
replace samelea_prioryear = 0 if lag_reslea_weight != residentlea_weight & !missing(lag_reslea_weight) & !missing(residentlea_weight)

*note that discipline variables are only available starting in 2012. Also, snap and tanf variables are only available for XX years.
keep ric year grade_fnl bcode_weight dcode_weight isd_weight fte_fall fte_spring fte_sped_fall fte_sped_spring zipcode_weight residentlea_weight birthdate female white black hisp asianamer amerin hawaiian poor speddummy sped_disability lep migrant frac_attend frac_attend_new chronic_abs lag_frac_attend_new lag_frac_attend_new_sy lag_susp lag_susp_sy lag_chronicabs lag_chronicabs_sy samebcode_prioryear samedcode_prioryear samelea_prioryear suspended suspended_insch suspended_outsch days_susp count_3to8

sort residentlea_weight
merge m:1 residentlea_weight using "${flint}\data\temp\residentlea_55.dta"

keep if _merge == 3
drop _merge

save "${flint}\data\temp\srds_restricted55.dta", replace

***********************************************************************************
*************************************Step 4****************************************
*Creating the assessment file based on the rics that lived in one of the 55 residential 
*LEAs that we created above.
***********************************************************************************
***********************************************************************************

use "${flint}\data\raw\assessment_standard_student_year.dta", clear

merge m:1 ric using "${flint}\data\temp\rics_basedon55.dta"
keep if _merge == 3

keep if year >= 2003 & grade < 13

*Get rid of invalid scores
replace readingstdss = . if readingvalid != 1
replace elastdss = . if elavalid != 1
replace mathstdss = . if mathvalid != 1

*Only keep elementary/middle school tests
replace readingstdss = . if !inrange(grade, 3, 8)
replace elastdss = . if !inrange(grade, 3, 8)
replace mathstdss = . if !inrange(grade, 3, 8)

*Drop 8th grade scores in -2019 onward (see PSAT below)
replace elastdss = . if year >= 2019 & grade == 8
replace mathstdss = . if year >= 2019 & grade == 8

*Take average if tested 2+ times
collapse (mean) readingstdss mathstdss elastdss, by(ric year)

*Creating a balanced panel so that all students have the same number of rows
tsset ric year
tsfill, full

*Generating literacy_std and numeracy_std variables
generate literacy_std = .
replace literacy_std = readingstdss if year < 2015 // MEAP ended in 2014
replace literacy_std = elastdss if year > 2014 & !missing(year) // MSTEP started in 2015

rename mathstdss numeracy_std // use math variable for everyone

merge 1:1 ric year using "${flint}\data\assessment_readiness_student_year.dta"
drop if _merge == 2

replace literacy_std = satreadingwritingstd if grade_sat == 8 & year >= 2019 // PSAT adminstered to 8th graders in 2019 on
replace numeracy_std = satmathstd if grade_sat == 8 & year >= 2019 // *PSAT for 8th graders starting 2019

gen has_any_assessment = 0 
replace has_any_assessment = 1 if !missing(literacy_std) | !missing(numeracy_std) 

***generate outcome variables (achievement and attendance)
egen mean_ach=rowmean(literacy_std numeracy_std)

gen has_assessment = 0
replace has_assessment = 1 if !missing(mean_ach)

keep ric year mean_ach literacy_std numeracy_std has_assessment has_any_assessment 

save "${flint}\data\temp\assessment_basedon55.dta", replace

***********************************************************************************
*************************************Step 5****************************************
*Merging school-level file by bcode and year 
*based on the srds file that only has the rics from the 55 residential LEAs
***********************************************************************************
***********************************************************************************

use "${flint}\data\raw\school_level.dta", clear
keep bcode year conum dcode dname d_name charter urbanicity magnet mobility3_pre mobility3_nex school_type per_fl per_hi per_bl per_wh per_as enroll schoolname_cleaned
*fix Detroit
replace dcode = 82015 if dcode == 82010 & year < 2017 & !missing(year)

rename bcode bcode_weight

tempfile school
save "`school'"

use "${flint}\data\temp\srds_restricted55.dta" 
sort bcode_weight year

merge m:1 bcode_weight year using `school' 
drop if _merge == 2
drop _merge

*Merging assessments and student-level variables
merge 1:1 ric year using "${flint}\data\temp\assessment_basedon55.dta"
drop _merge
merge 1:1 ric year using "${flint}\data\temp\srds_restricted55.dta"
keep if _merge == 3
drop _merge

merge m:1 residentlea_weight using "${flint}\data\temp\residentlea_55.dta"
keep if _merge == 3
drop _merge

save "${flint}\data\temp\databeforeflags.dta", replace

***********************************************************************************
*************************************Step 6****************************************
*Data processsing: missing flags and creating dummies for categorical variables
***********************************************************************************
***********************************************************************************
use "${flint}\data\temp\databeforeflags.dta", clear

*Creating lag variables
gsort ric year

gen lag_ach = L.mean_ach
gen lag_literacy = L.literacy
gen lag_numeracy = L.numeracy

*Aggregate lag variables by s-year
egen lag_ach_sy = mean(lag_ach), by(bcode year)
egen lag_literacy_sy = mean(lag_literacy), by(bcode year)
egen lag_numeracy_sy = mean(lag_numeracy), by(bcode year)

egen lag_ach_sy_res = mean(lag_ach), by(residentlea_weight year)
egen lag_literacy_sy_res = mean(lag_literacy), by(residentlea_weight year)
egen lag_numeracy_sy_res = mean(lag_numeracy), by(residentlea_weight year)
egen enroll_res = mean(enroll), by(residentlea_weight year)

*eligible for testing
generate eligible_test = 0
replace eligible_test = 1 if (grade >=3 & grade <=12) & (speddummy != 1)
generate tested = 0
replace tested = 1 if (grade >=3 & grade <=12) & !missing(mean_ach)
generate frac_tested = tested/eligible_test

*ssc install dummieslab
*here, the dummieslab code will create dummies using the value labels from urbanicity (City, Suburb, Town, Rural)
dummieslab urbanicity
*here, the dummieslab code will create dummies using the vaue labels from school_type (Regylar, SpecialEducation, Vocational, OtherAlternative, ProgramNewSince2008) 
dummieslab school_type

***********************************************************************************
*************************************Step 7****************************************
*Applying labels to student-level file
***********************************************************************************
***********************************************************************************
rename *frac_attend* *frac_attend3*

*keeping only the relevant variables (not flags for regressions)
generate STUDENT = "*"
generate SCHOOL = "*"
generate LAGS = "*"
generate OUTCOMES = "*"
generate SAMPLE_FLAGS = "*"

*ordering variables 

keep ric year grade_fnl bcode_weight dcode_weight isd_weight fte_fall fte_spring fte_sped_fall fte_sped_spring zipcode_weight residentlea_weight birthdate STUDENT female white black hisp asianamer poor speddummy sped_disability lep samebcode_prioryear samedcode_prioryear samelea_prioryear has_assessment has_any_assessment count_3to8 SCHOOL dcode dname d_name conum City Suburb Town Rural Regular SpecialEducation Vocational magnet charter enroll per_fl per_as per_hi per_bl per_wh mobility3_prev_yr mobility3_next_yr LAGS lag_frac_attend3_new lag_frac_attend3_new_sy lag_ach lag_literacy lag_numeracy lag_ach_sy lag_literacy_sy lag_numeracy_sy lag_chronicabs lag_chronicabs_sy OUTCOMES mean_ach literacy numeracy frac_attend3 frac_attend3_new chronic_abs suspended SAMPLE_FLAGS sample_55 sample_27

order ric year grade_fnl bcode_weight dcode_weight isd_weight fte_fall fte_spring fte_sped_fall fte_sped_spring zipcode_weight residentlea_weight birthdate STUDENT female white black hisp asianamer poor speddummy sped_disability lep samebcode_prioryear samedcode_prioryear samelea_prioryear has_assessment  has_any_assessment count_3to8 SCHOOL dcode dname d_name conum City Suburb Town Rural Regular SpecialEducation Vocational magnet charter enroll per_fl per_as per_hi per_bl per_wh mobility3_prev_yr mobility3_next_yr LAGS lag_frac_attend3_new lag_frac_attend3_new_sy lag_ach lag_literacy lag_numeracy lag_ach_sy lag_literacy_sy lag_numeracy_sy lag_chronicabs lag_chronicabs_sy OUTCOMES mean_ach literacy numeracy frac_attend3 frac_attend3_new chronic_abs suspended SAMPLE_FLAGS sample_55 sample_27

*creating labels for new vars
label variable STUDENT "STUDENT VARS START -->"
label variable SCHOOL "SCHOOL VARS START -->"
label variable LAGS "LAG VARS START -->"
label variable OUTCOMES "OUTCOME VARS START -->"
label variable samebcode_prioryear "Same school prior year?"
label variable samedcode_prioryear "Same district prior year?"
label variable lag_frac_attend3_new   "Lag y-1 attendance"
label variable lag_frac_attend3_new_sy "Lag y-1 attendance school*year"
label variable lag_ach "Lag y-1 achievement (Reading + Math)"
label variable lag_literacy "Lag y-1 reading"
label variable lag_numeracy "Lag y-1 math"
label variable lag_ach_sy "Lag y-1 achievement school*year"
label variable lag_literacy_sy "Lag y-1 reading school*year"
label variable lag_numeracy_sy "Lag y-1 math school*year"
label variable mean_ach "Achievement (math + reading)"
label variable literacy "Reading achievement"
label variable numeracy "Math achievement"
label variable has_assessment "Has a valid typical assessment (not MI-A or MEAP-Access)" 
label variable has_any_assessment "Has any assessment (A or non-A)"
label variable count_3to8 "Student is in 3-8 grade?"
label variable SAMPLE_FLAGS "SAMPLE FLAGS -->"
label variable sample_55 "Part of the 55 districts (incuding flint)"
label variable sample_27 "Part of the 28 districts (including flint)"
label variable chronic_abs "Chronic abs (>=10% absences as currently defined by CEPI)"
label variable lag_chronicabs "lag Chronic abs (>=10% absences as currently defined by CEPI)"
label variable lag_chronicabs_sy "lag Chronic abs school*year (>=10% absences as currently defined by CEPI)"
label variable samelea_prioryear "Same residential lea prior year"

*adding the variable level (i.e., student, school, etc) to the label  
global STUDENT female white black hisp asianamer poor speddummy sped_disability lep samebcode_prioryear samedcode_prioryear samelea_prioryear
global SCHOOL dcode dname d_name conum City Suburb Town Rural Regular SpecialEducation Vocational magnet charter enroll per_fl per_as per_hi per_bl per_wh mobility3_prev_yr mobility3_next_yr 
global LAGS lag_frac_attend3_new_ lag_frac_attend3_new_sy lag_chronicabs lag_chronicabs_sy lag_ach lag_literacy lag_numeracy lag_ach_sy lag_literacy_sy lag_numeracy_sy 
global OUTCOMES mean_ach literacy numeracy frac_attend3 frac_attend3_new suspended chronic_abs  


foreach var in $STUDENT {
local label = strtoname("`: variable label `var''")
label var `var' "STUDENT: `label'"
}

foreach var in $SCHOOL {
local label = strtoname("`: variable label `var''")
label var `var' "SCHOOL: `label'"
}

foreach var in $LAGS {
local label = strtoname("`: variable label `var''")
label var `var' "LAGS: `label'"
}

foreach var in $OUTCOMES {
local label = strtoname("`: variable label `var''")
label var `var' "OUTCOMES: `label'"
}

***********************************************************************************
*************************************Step 8****************************************
*Saving the final data set
***********************************************************************************
***********************************************************************************

save "${flint}\data\student_level_nonfixed_55districts.dta", replace

***********************************************************************************
***************************************END*****************************************
***********************************************************************************
