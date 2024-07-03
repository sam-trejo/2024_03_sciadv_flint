
***********************************************************************************
***
***********************************************************************************


***load non-fixed geodist panel
use "${data}\all_dist.dta", clear

***make flint its own category in grouping variable
replace sample_55=2 if flint

***separate plot outcome
separate black, by(sample_55)

***create legend labels
sum black0
label var black0 "Other Large Michigan Districts (N=`r(N)')"
sum black1
label var black1 "Preferred Control District Sample (N=`r(N)')"
label var black2 "Flint"

***scatter
twoway scatter black0 poor [aw=obs], ///
				mfcolor(gray%05) mlcolor(gray%50) msymbol(O) ///
				|| ///			
	   scatter black1 poor [aw=obs], ///
				mfcolor(ebblue%10) mlcolor(ebblue%75) msymbol(O) ///			
				|| ///
	   scatter black2 poor [aw=obs], ///
				mfcolor(midgreen%50) mlcolor(midgreen) msymbol(O) ///
					xline(.73, lpattern(shortdash) lcolor(black)) ///
					yline(.31, lpattern(shortdash) lcolor(black)) ///
					xlabel(,format(%04.2f)) ///
					ylabel(,format(%04.2f)) ///					
	     			title("A. Original (∪90)", size(medium)) ///
					ytitle(" ") ///
					xtitle(" ") ///
					legend(order(3 2 1) textwidth(*.1) ring(0) bmargin(medium) cols(1) position(11) size(small)) ///
					saving("${figure}\temp\55", replace)

***********************************************************************************
***
***********************************************************************************
									
***load non-fixed geodist panel
use "${data}\all_dist.dta", clear

***load non-fixed geodist panel

***make flint its own category in grouping variable
replace sample_27=2 if flint

***separate plot outcome
separate black, by(sample_27)

***create legend labels
sum black0
label var black0 "Other Large Michigan Districts (N=`r(N)')"
sum black1
label var black1 "Restricted Control District Sample (N=`r(N)')"
label var black2 "Flint"

***scatter
twoway scatter black0 poor [aw=obs], ///
				mfcolor(gray%05) mlcolor(gray%50) msymbol(O) ///
				|| ///			
	   scatter black1 poor [aw=obs], ///
				mfcolor(cranberry%10) mlcolor(cranberry%75) msymbol(O) ///
					xline(.798, lpattern(shortdash) lcolor(black)) ///
					yline(.538, lpattern(shortdash) lcolor(black)) ///
				|| ///				
	   scatter black2 poor [aw=obs], ///
				mfcolor(midgreen%50) mlcolor(midgreen) msymbol(O) ///
	     			title("C. Alternative II (∪95)", size(medium)) ///
					xlabel(,format(%04.2f)) ///
					ylabel(,format(%04.2f)) ///							
					ytitle(" ") ///
					xtitle(" ") ///
					legend(order(3 2 1) textwidth(*.1) ring(0) bmargin(medium) cols(1) position(11) size(small)) ///
					saving("${figure}\temp\27", replace)

***********************************************************************************
***
***********************************************************************************


***load non-fixed geodist panel
use "${data}\all_dist.dta", clear

***

centile black, centile(75)
local black = `r(c_1)'
centile poor, centile(75)
local poor = `r(c_1)'

gen sample_52 = black>`black' & poor>`poor'

***make flint its own category in grouping variable
replace sample_52=2 if flint

***separate plot outcome
separate black, by(sample_52)

***create legend labels
sum black0
label var black0 "Other Large Michigan Districts (N=`r(N)')"
sum black1
label var black1 "Restricted Control District Sample (N=`r(N)')"
label var black2 "Flint"

***scatter
twoway scatter black0 poor [aw=obs], ///
				mfcolor(gray%05) mlcolor(gray%50) msymbol(O) ///
				|| ///			
	   scatter black1 poor [aw=obs], ///
				mfcolor(lavender%10) mlcolor(lavender%75) msymbol(O) ///
					xline(`poor', lpattern(shortdash) lcolor(black)) ///
					yline(`black', lpattern(shortdash) lcolor(black)) ///
				|| ///				
	   scatter black2 poor [aw=obs], ///
				mfcolor(midgreen%50) mlcolor(midgreen) msymbol(O) ///
	     			title("B. Alternative I (∩75)", size(medium)) ///
					xlabel(,format(%04.2f)) ///
					ylabel(,format(%04.2f)) ///							
					ytitle(" ") ///
					xtitle(" ") ///
					legend(order(3 2 1) textwidth(*.1) ring(0) bmargin(medium) cols(1) position(11) size(small)) ///
					saving("${figure}\temp\52", replace)

				
				
				
*********************************************************************************************************************************************

***combine and export all figures
graph combine ///
	  "${figure}\temp\55.gph" ///
	  "${figure}\temp\52.gph" ///	  
	  "${figure}\temp\27.gph", ///
	  cols(1) ycommon ///
	  b1("Fraction Economically Disadvantaged", size(small)) ///
	  l1("Fraction Black", size(small)) ///
	  imargin(tiny)

graph export "${figure}\scatter_control_combined_$date.png", replace width(1775) height(3550)	

