*************************************************************
*** MAIN OUTCOME FIGURES
*************************************************************

use "${data}\hetero_flint_only.dta", clear

	keep if data_sub==5
	drop if obs_sub==.

sort obs_sub year
	
keep if year>=2010	
	
quietly { 
    
	***math figure
	twoway connect math year if obs_sub==1, ///
				   saving("${figure}\temp\math", replace) ///
				   xlin(2015, lcolor(black)) ///
				   xscale(range(2010 2019)) /// 
				   xlabel(2010(2)2019, tlength(*1) tlcolor(black)) ///	
				   xtick(2010(1)2019, tlength(*.5) tlcolor(black)) ///		
				   yscale(range(-.5  -.8)) ///   
				   ylabel(-.5(-.1)-.8, format(%04.2f)) ///
				   msymbol(o) ///
				   mcolor(cranberry) ///
				   lcolor(cranberry) ///
			   title("A. `: var label math'") ///
				   xtitle(" ") ///
				   ytitle(" ") ///
				   || ///		   
				   connect math year if obs_sub==0, ///
				   msymbol(Oh) ///
				   mcolor(ebblue) ///
				   lcolor(ebblue) ///
				   legend(order(1 "Dangerous" 2 "Not Dangerous") ///
					  col(1) ring(0) position(2) region(fcolor(none)) ///
					  bmargin(small) size(small) rowgap(*.1))
					  
	***read figure
	twoway connect read year if obs_sub==1, ///
				   saving("${figure}\temp\read", replace) ///
				   xlin(2015, lcolor(black)) ///
				   legend(off) ///
				   xscale(range(2010 2019)) /// 
				   xlabel(2010(2)2019, tlength(*1) tlcolor(black)) ///	
				   xtick(2010(1)2019, tlength(*.5) tlcolor(black)) ///		
				   yscale(range(-.5  -.8)) ///   
				   ylabel(-.5(-.1)-.8, format(%04.2f)) ///
				   msymbol(o) ///
				   mcolor(cranberry) ///
				   lcolor(cranberry) ///
			   title("B. `: var label read'") ///
				   xtitle(" ") ///
				   ytitle(" ") ///
				   || ///		   
		   connect read year if obs_sub==0, ///
				   msymbol(Oh) ///
				   mcolor(ebblue) ///
				   lcolor(ebblue) ///

	***sped figure
	twoway connect sped year if obs_sub==1, ///
				   saving("${figure}\temp\sped", replace) ///
				   xlin(2015, lcolor(black)) ///
				   legend(off) ///
				   xscale(range(2010 2019)) /// 
				   xlabel(2010(2)2019, tlength(*1) tlcolor(black)) ///	
				   xtick(2010(1)2019, tlength(*.5) tlcolor(black)) ///	
				   ylabel(, format(%04.2f)) ///
				   msymbol(o) ///
				   mcolor(cranberry) ///
				   lcolor(cranberry) ///
			   title("C. `: var label sped'") ///
				   xtitle(" ") ///
				   ytitle(" ") ///
				   || ///		   
		   connect sped year if obs_sub==0, ///
				   msymbol(Oh) ///
				   mcolor(ebblue) ///
				   lcolor(ebblue) ///			   
				   
	***attend figure
	twoway connect attd year if obs_sub==1, ///
				   saving("${figure}\temp\attd", replace) ///
				   xlin(2015, lcolor(black)) ///
				   legend(off) ///
				   xscale(range(2010 2019)) /// 
				   xlabel(2010(2)2019, tlength(*1) tlcolor(black)) ///	
				   xtick(2010(1)2019, tlength(*.5) tlcolor(black)) ///
				   ylabel(.87(.02).95, format(%04.2f)) ///			   
				   msymbol(o) ///
				   mcolor(cranberry) ///
				   lcolor(cranberry) ///
			   title("D. `: var label attd'") ///
				   xtitle(" ") ///
				   ytitle(" ") ///
				   || ///		   
		   connect attd year if obs_sub==0, ///
				   msymbol(Oh) ///
				   mcolor(ebblue) ///
				   lcolor(ebblue)
}
				   
				   
graph combine ///
	  "${figure}\temp\math.gph" ///
	  "${figure}\temp\read.gph" ///
	  "${figure}\temp\sped.gph" ///
	  "${figure}\temp\attd.gph", ///
	  cols(2) xcommon ///
	  b1("Year") ///
	  imargin(tiny)	    

graph export "${figure}\connect1_lead-copper_$date.png", replace width(2000) height(1300)	  

