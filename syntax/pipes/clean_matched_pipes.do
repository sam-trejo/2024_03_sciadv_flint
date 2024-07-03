clear all
set more off
cap log close
set trace off
pause on
capture postutil closecd ..

cd ..
cd ..
global flint "`c(pwd)'"

** Data returned from MEDC should be a .csv file. It may have multiple observations per student,
** if students are in Flint in both years or if MEDC draws on more than one annual address collection
** (e.g., in the fall and in the spring).  
import delimited using "${flint}\data\raw\pipes_data\matched_pipes.csv", clear 

format %20.0g primaryric 
rename primaryric ric

*recode dangerous
generate dangerous_num = .
replace dangerous_num = 0 if dangerous == "False"
replace dangerous_num = 1 if dangerous == "True"

drop dangerous
rename dangerous_num dangerous

label define truefalse 0 "False" 1 "True"
label values dangerous truefalse

*sl_private_type
tabulate sl_private_type, generate(sl_private_)
rename sl_private_1 sl_private_copper 
rename sl_private_2 sl_private_galvanized
rename sl_private_3 sl_private_lead
rename sl_private_4 sl_private_nan
rename sl_private_5 sl_private_noncopper
rename sl_private_6 sl_private_plastic
rename sl_private_7 sl_private_unknown

drop if sl_private_plastic == 1 /*6 cases*/
drop sl_private_plastic

*sl_public_type
tabulate sl_public_type, generate(sl_public_)
rename sl_public_1 sl_public_copper
rename sl_public_2 sl_public_galvanized
rename sl_public_3 sl_public_declined
rename sl_public_4 sl_public_lead
rename sl_public_5 sl_public_nan
rename sl_public_6 sl_public_noncopper
rename sl_public_7 sl_public_none
rename sl_public_8 sl_public_unknown

drop if sl_public_none == 1 | sl_public_declined == 3 /*8 cases*/
drop sl_public_none sl_public_declined

*rename dangerous to lead
rename dangerous lead1 

*This is the baseline measure of dangerous which includes lead, galvanized or unknown. 
bysort lead1: tab sl_private_type sl_public_type , m 

*Now create a narrower definition. Dangerous = lead or galvanized in either public or private, and non-dangerous is only Copper or NAN.  
gen lead2=. 
replace lead2=1 if inlist(sl_private_type,"LEAD","GALVANIZED")|inlist(sl_public_type,"LEAD","GALVANIZED")
replace lead2=0 if inlist(sl_private_type,"COPPER","NAN") & inlist(sl_public_type,"COPPER","NAN")
bysort lead2: tab sl_private_type sl_public_type , m 

*Now even narrower - lead is dangerous and copper is safe. 
gen lead3=. 
replace lead3=1 if inlist(sl_private_type,"LEAD")|inlist(sl_public_type,"LEAD")
replace lead3=0 if inlist(sl_private_type,"COPPER")&inlist(sl_public_type,"COPPER") 
bysort lead3: tab sl_private_type sl_public_type , m 

*interaction term with post dummy
gen year_temp = .
replace year_temp = 2014 if regexm(collection, "Fall 2013") | regexm(collection, "Spring 2014") | regexm(collection, "EOY 2014") | year == 2014
replace year_temp = 2015 if regexm(collection, "Fall 2014") | regexm(collection, "Spring 2015") | regexm(collection, "EOY 2015") | year == 2015

gen post = 0
replace post = 1 if year_temp > 2014

foreach x in 1 2 3 {
	  gen lead`x'xpost=lead`x'*post 
}

*collapse to student level, keeping any exposure to lead across variables
gcollapse (max) lead1 lead2 lead3 lead*post, by(ric)

** lead1 is the variable used in all preferred analyses; lead2 and lead3 offer
** more narrow operationalizations, and lead*xpost all only operationalize lead
** exposure as having occurred only in the 2014-2015 school year

save "${flint}\data\matched_pipes_clean.dta", replace  
