***load all geodists in 2014
use "${data}\all_dist.dta", clear
gen sample=1

***add 54 control districts
append using "${data}\all_dist.dta"
replace sample=2 if sample==.
drop if (sample_55==0 & sample==2) | flint

***add flint
append using "${data}\all_dist.dta"
replace sample=3 if sample==.
drop if !flint & sample==3

***generate number of districts variable
egen count=count(sample), by(sample)

***re-label vars
label var math "Math Achievement (SD)"
label var read "Reading Achievement (SD)"
label var sped "Fraction Special Needs"
label var attd "Fraction School Days Attended"
label var obs  "Enrollment"
label var count "Number of Districts"

***label values for tabstat
label define sam 1 "All Districts" 2 "Control Sample" 3 "Flint"
label values sample sam

***generate sum stats
estpost tabstat math read sped attd ///
				female black hisp poor lep charter admin ///
				obs count, ///
                by(sample) ///
				statistics(mean sd) ///
				columns(statistics) ///
				nototal 

***save out sum stats		
esttab /// 
	using "${table}\table_1_$date.csv", ///		
    main(mean %5.2f) aux(sd %5.2f) ///
	unstack nostar nogaps nonote noobs nomtitle nonumber ///
	label replace
