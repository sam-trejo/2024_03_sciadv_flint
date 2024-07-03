clear all
set more off
cap log close
set trace off
pause on
capture postutil closecd ..

cd ..
cd ..
global flint "`c(pwd)'"

*** Create Lead Pipe Data File for Matching *** 

use "${flint}\data\raw\parcel_inspections.dta", clear

keep pidnodash dangerous sl_private_type sl_public_type goog_address ///
	 propertyaddress propertyzipcode
	 
*if dangerous is missing, then no valid inspection conducted
gen has_inspection=dangerous!=""

*some places have no address data 
drop if goog_address==""

*there are some places that do not have street numbers so appear as duplicates 
duplicates tag goog_address, gen(dupe)
tab dupe, m
gen stnum=word(goog_address,1)
destring stnum, gen(stnum_num) force

*these obs have a street num that is not a street number
drop if stnum_num==. 

*there are a few remaining duplicates 
*it looks like the Google API changed the street direction in these case. 
*to be safe, I will keep both records. 

*in 1 cases, looks like a pure dupe. not sure why. will drop one
/*
2702 Terrace Dr, Flint, MI 48507, USA    2702 TERRACE DR      48507   Residential       COPPER       COPPER |
2702 Terrace Dr, Flint, MI 48507, USA    2702 TERRACE DR      48507   Residential       COPPER       COPPER |
*/
duplicates tag goog_address propertyaddress propertyzipcode sl_public_type sl_private_type, gen(dupe2) 
tab dupe2, m 
duplicates drop goog_address propertyaddress propertyzipcode sl_public_type sl_private_type, force 

gen w1=word(propertyaddress,1)
gen lengthw1=length(w1)
tab lengthw1, m 
gen w2=word(propertyaddress,2)

*few weird cases
drop if lengthw1>4 

drop dupe2 dupe 
duplicates tag goog_address, gen(dupe)
tab dupe, m
sort goog_address 
count if dupe>0 

*non dupe cases 
preserve
  keep if dupe==0
  tempfile tmp0
  save `tmp0', replace
restore

*These are all multi-unit buildings and the duplicates are coming from apartment numbers. Just keep one obs for each address.
preserve
  keep if dupe==34
  keep if _n==1
  tempfile tmp1
  save `tmp1', replace
restore

preserve
  keep if dupe==5
  keep if _n==1
  tempfile tmp2
  save `tmp2', replace 
restore

preserve
  keep if dupe==2
  keep if _n==1
  tempfile tmp3
  save `tmp3', replace 
restore

*There are some cases where one of the 2 records has inspection data but the other doesn't; keep the cases with inspection data  
preserve 
  keep if dupe==1
  gen tmp=sl_private_type!=""
  egen tmp2=sum(tmp), by(goog_address)
  keep if tmp2==1
  drop if sl_private_type==""
  drop tmp tmp2 
  tempfile tmp4
  save `tmp4', replace 
restore
  
*street direction mixed up
preserve 
	keep if dupe==1
	gen tmp=sl_private_type!=""
	egen tmp2=sum(tmp), by(goog_address)
	keep if tmp2!=1 
	drop tmp tmp2 
  
	gen tmp1=substr(goog_address,1,4) 
	gen tmp2=substr(goog_address,6,.)

	gen goog_address2=goog_address
	replace goog_address2=tmp1+w2+tmp2 if lengthw1==3 

	drop tmp1 tmp2 

	gen tmp1=substr(goog_address,1,5) 
	gen tmp2=substr(goog_address,7,.)

	replace goog_address2=tmp1+w2+tmp2 if lengthw1==4 

	drop tmp1 tmp2 

	set linesize 120
	list goog_address goog_address2 sl_private_type sl_public_type
	*based on manual review - see list below 
	drop if inlist(_n,71,69,65,54,35,12,9,7)

	tempfile tmp5
	save `tmp5', replace 
restore 

use `tmp0', clear
foreach x in 1 2 3 4 5 {
  append using `tmp`x''
  }
  
replace goog_address2=goog_address if goog_address2=="" 

duplicates tag goog_address2, gen(dupe2) 
tab dupe2, m 
drop goog_address 
drop w1 lengthw1 w2 dupe dupe2 stnum stnum_num 

compress 
d, f

save "${flint}\data\temp\flint_pipes_data_for_matching.dta", replace
