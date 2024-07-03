***load 54 control districts
use "${data}\fixed.dta", clear

***
append using "${data}\non_fixed.dta"

***
keep if flint

***
gen sample=.
replace sample=1 if year==2010 & !fix
replace sample=2 if year==2010 & fix
replace sample=3 if year==2014 & !fix
replace sample=4 if year==2018 & !fix
replace sample=5 if year==2018 & fix

***generate number of districts variable
egen count=count(sample), by(sample)

***re-label vars
label var math "Math Achievement (SD)"
label var read "Reading Achievement (SD)"
label var sped "Fraction Special Needs"
label var attd "Fraction School Days Attended"
label var obs  "Number of Observations"

***label values for tabstat
label define sam 1 "Non-Fixed (2010)" 2 "Fixed (2010)" 3 "Both (2014)" 4 "Non-Fixed (2018)" 5 "Fixed (2018)"
label values sample sam

***generate sum stats
estpost tabstat math read sped attd ///
				female black hisp poor lep charter admin ///
				obs, ///
                by(sample) ///
				statistics(mean) ///
				columns(statistics)  ///
				nototal 

***save out sum stats		
esttab /// 
	using "${table}\table_S3_$date.csv", ///		
    main(mean %5.2f) ///
	unstack nostar nogaps nonote noobs nomtitle nonumber ///
	label replace
