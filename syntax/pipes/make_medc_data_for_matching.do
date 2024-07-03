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

********************************************************************************
*************************************Step 1*************************************
*Restrict to rics with reslea == Flint in any 2013-2014 or 2014-2015 collection
********************************************************************************
********************************************************************************

*Calling the SRDS data 

use "${flint}\data\raw\k12_student.dta", clear
keep if year == 2014 | year == 2015

*Formating the length of the ric variable 
format ric %20.0f

generate resleamissing_weight14 = 1 if missing(residentlea_weight) & year == 2014
replace resleamissing_weight14 = 0 if !missing(residentlea_weight) & year == 2014

generate resleamissing_weight15 = 1 if missing(residentlea_weight) & year == 2015
replace resleamissing_weight15 = 0 if !missing(residentlea_weight) & year == 2015

generate flint2014 = 1 if (residentlea_weight == 25010) & (year == 2014)
generate flint2015 = 1 if (residentlea_weight == 25010) & (year == 2015)

*Create a data set that includes all RICs that have a Flint residential LEA in in the school *years 2014 or 2015. 
keep if flint2014 == 1 | flint2015 == 1
keep ric year

save "${flint}\data\temp\FlintResidentLEAS2014_and_2015.dta", replace
