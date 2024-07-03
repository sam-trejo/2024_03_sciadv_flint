
***********************************************************************************
*** 
***********************************************************************************

import delimited "C:\Users\trejo\Dropbox (Princeton)\shared\Flint Water Project\between_analysis\tables\weights_2023_11_25.csv", numericcols(_all) clear
tostring leaid*, replace
drop leaid_alternative* a_math_read_sped_attd_60 n_math_read_sped_attd_30
tempfile hold1
save `hold1', replace

import delimited "C:\Users\trejo\Dropbox (Princeton)\shared\Flint Water Project\between_analysis\tables\weights_2023_11_25.csv", numericcols(_all) clear

tostring leaid*, replace
keep leaid_alternative50 a_math_read_sped_attd_60
drop if leaid_alternative50=="" | leaid_alternative50=="."
tempfile hold2
save `hold2', replace

import delimited "C:\Users\trejo\Dropbox (Princeton)\shared\Flint Water Project\between_analysis\tables\weights_2023_11_25.csv", numericcols(_all) clear

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
			n_math_read_sped_attd_60 n_math_read_60 n_sped_attd_60  ///
		    n_attd_60 n_math_60 n_read_60 n_sped_60 

foreach var of global scm {
	replace `var' = round(`var',.001)
	preserve
		collapse (mean) math read sped attd fix_* [w=`var'], by(year)
		gen `var'=1
		tempfile t`var'
		save `t`var'', replace
	restore 
}

use `flint', clear
foreach var of global scm {
	append using `t`var''
}

foreach var of global scm {
	replace `var' = 0 if `var'==.
}

egen grp = group(${scm})

egen count = count(fix_math), by(grp)
drop if count==0
drop count

foreach var in math read sped attd fix_math fix_read fix_sped fix_attd {
	gen pre_`var' = `var' if inrange(year,2006,2014)
	egen m_pre_`var' = mean(pre_`var'), by(grp)
	replace `var' = `var' - m_pre_`var'

	gen flint_`var' = `var' if flint==1
	egen m_flint_`var' = max(flint_`var'), by(year)
	replace `var' = m_flint_`var' - `var' 
}


***********************************************************************************
*** MATH
***********************************************************************************

twoway connect math year if a_math_read_sped_attd_60==1 ///
			, lcolor(cranberry%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(S) /// 				  			  			  
			  mcolor(cranberry) ///
	   	   || ///
	   connect math year if n_math_read_60==1 ///
			, lcolor(lavender%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(lavender) ///			  
	   	   || ///
	   connect math year if n_math_60==1 ///
			, lcolor(midgreen%60) ///
			  lwidth(medium) /// 
			  msymbol(Oh) /// 				  			  			  
			  msize(small) /// 	
			  mcolor(midgreen) ///				  
	   	   || ///
	   connect fix_math year if f_math_read_sped_attd_60==1 ///
			, lcolor(ebblue%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(T) /// 				  			  
			  mcolor(ebblue) ///
		   || ///	   			  
	   connect math year if n_math_read_sped_attd_30==1 ///
			, lcolor(gold%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(gold) ///				  
			  || ///	   
	   line math year if n_math_read_sped_attd_60==1 ///
		    , lcolor("46 47 202") ///
			  lwidth(thick) ///
			  yline(0, lcolor(black) lpattern(dash)) ///
			  xline(2015, lcolor(black) lpattern(dash)) ///
			  xlabel(2006(4)2019) ///
			  ylabel(,format(%04.2f)) ///
			  title("A. Math Achievement") ///
			  xtitle(" ") ///	
			  ytitle(" ") ///
		  	  graphregion(margin(0 0 -5 0)) ///
			  legend(order(6 "Original" 1 "Alternative Controls I (∩75)" 3 "Single Outcome"  ///
						   4 "Invariant District Assignment" 5 "Alternative Controls II (∪95)" ///
						   2 "Double Outcome") ///
					 col(3) ///
					 size(small) ///
					 bmargin(tiny)) ///
			  saving("${figure}/temp/robustness_math_${date}.gph", replace) 					
			 
***********************************************************************************
*** READING
***********************************************************************************

twoway connect read year if a_math_read_sped_attd_60==1 ///
			, lcolor(cranberry%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(S) /// 				  			  			  
			  mcolor(cranberry) ///	   	   
			  || ///
	   connect read year if n_math_read_60==1 ///
			, lcolor(lavender%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(lavender) ///			   	   
			  || ///
	   connect read year if n_read_60==1 ///
			, lcolor(midgreen%60) ///
			  lwidth(medium) /// 
			  msymbol(Oh) /// 				  			  			  
			  msize(small) /// 	
			  mcolor(midgreen) ///		   	   
			  || ///
	   connect fix_read year if f_math_read_sped_attd_60==1 ///
			, lcolor(ebblue%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(T) /// 				  			  
			  mcolor(ebblue) ///		   
			  || ///	   			  
	   connect read year if n_math_read_sped_attd_30==1 ///
			, lcolor(gold%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(gold) ///		   
			  || ///	   
	   line read year if n_math_read_sped_attd_60==1 ///
		    , lcolor("46 47 202") ///
			  lwidth(thick) ///
			  yline(0, lcolor(black) lpattern(dash)) ///
			  xline(2015, lcolor(black) lpattern(dash)) ///
			  xlabel(2006(4)2019) ///
			  ylabel(,format(%04.2f)) ///
			  title("B. Reading Achievement") ///	
		  	  graphregion(margin(0 0 -5 0)) ///
			  xtitle(" ") ///	
			  ytitle(" ") ///	
			  legend(off) ///
			  saving("${figure}/temp/robustness_read_${date}.gph", replace) 					
			  
					 
***********************************************************************************
*** SPED
***********************************************************************************

twoway connect sped year if a_math_read_sped_attd_60==1 ///
			, lcolor(cranberry%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(S) /// 				  			  			  
			  mcolor(cranberry) ///	   	   
			  || ///
	   connect sped year if n_sped_attd_60==1 ///
			, lcolor(lavender%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(lavender) ///			   	 
			  || ///
	   connect sped year if n_sped_60==1 ///
			, lcolor(midgreen%60) ///
			  lwidth(medium) /// 
			  msymbol(Oh) /// 				  			  			  
			  msize(small) /// 	
			  mcolor(midgreen) ///	   	   
			  || ///
	   connect fix_sped year if f_math_read_sped_attd_60==1 ///
			, lcolor(ebblue%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(T) /// 				  			  
			  mcolor(ebblue) ///			  
			  || ///	   			  
	   connect sped year if n_math_read_sped_attd_30==1 ///
			, lcolor(gold%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(gold) ///		   
			  || ///	   
	   line sped year if n_math_read_sped_attd_60==1 ///
		    , lcolor("46 47 202") ///
			  lwidth(thick) ///
			  yline(0, lcolor(black) lpattern(dash)) ///
			  xline(2015, lcolor(black) lpattern(dash)) ///
			  xlabel(2006(4)2019) ///
			  ylabel(,format(%04.2f)) ///
		  	  graphregion(margin(0 0 0 -5)) ///			  
			  title("C. Special Needs") ///	
			  xtitle(" ") ///	
			  ytitle(" ") ///	
			  legend(off) ///
			  saving("${figure}/temp/robustness_sped_${date}.gph", replace) 					
			  
***********************************************************************************
*** ATTEND
***********************************************************************************

twoway connect attd year if a_math_read_sped_attd_60==1 ///
			, lcolor(cranberry%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(S) /// 				  			  			  
			  mcolor(cranberry) ///	   	   
			  || ///
	   connect attd year if n_sped_attd_60==1 ///
			, lcolor(lavender%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(lavender) ///			   	   
			  || ///
	   connect attd year if n_attd_60==1 ///
			, lcolor(midgreen%60) ///
			  lwidth(medium) /// 
			  msymbol(Oh) /// 				  			  			  
			  msize(small) /// 	
			  mcolor(midgreen) ///		   	   
			  || ///
	   connect fix_attd year if f_math_read_sped_attd_60==1 ///
			, lcolor(ebblue%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  msymbol(T) /// 				  			  
			  mcolor(ebblue) ///				   
			  || ///	   			  
	   connect attd year if n_math_read_sped_attd_30==1 ///
			, lcolor(gold%60) ///
			  lwidth(medium) /// 
			  msize(vsmall) /// 	
			  mcolor(gold) ///		   
			  || ///	   
	   line attd year if n_math_read_sped_attd_60==1 ///
		    , lcolor("46 47 202") ///
			  lwidth(thick) ///
			  yline(0, lcolor(black) lpattern(dash)) ///
			  xline(2015, lcolor(black) lpattern(dash)) ///
			  xlabel(2006(4)2019) ///
			  ylabel(,format(%04.2f)) ///
		  	  graphregion(margin(0 0 0 -5)) ///			  			  
			  title("D. Attendance") ///
			  xtitle(" ") ///	
			  ytitle(" ") ///			  			  
			  legend(off) ///
			  saving("${figure}/temp/robustness_attd_${date}.gph", replace) 					

***********************************************************************************
*** 
***********************************************************************************

grc1leg  ///
	  "$figure/temp/robustness_math_${date}.gph" ///
	  "$figure/temp/robustness_read_${date}.gph" ///
	  "$figure/temp/robustness_sped_${date}.gph" ///
	  "$figure/temp/robustness_attd_${date}.gph", ///
	  cols(2) ///
	  l1("Difference Between" "Flint & Synthetic Control") ///	  
	  b2("Year") ///
	  ysize(4) ///           
      xsize(7.25) ///  
	  xcommon ///
	  position(12) ///
	  plotregion(margin(-6 -2 -5 2))
	  
graph export "${figure}\robustness_combined_$date.png", replace width(3625) height(2000)	
