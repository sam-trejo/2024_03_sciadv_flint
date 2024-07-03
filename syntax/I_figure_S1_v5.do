***load non-fixed geodist panel
use "${data}\non_fixed.dta", clear

***append fixed geodist panel
append using "${data}\fixed.dta"

***keep on flint
keep if flint

***math obs
twoway connect obs_math year if fix==0, ///
			   saving("${figure}\temp\connect_obs_math", replace) ///
			   xlin(2014.3, lcolor(black)) ///
      		   legend(off) ///
			   yscale(range(2000 16000)) ///   
			   ylabel(2000(3000)16000) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///					   
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("A) `: var label math'", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("N", orientation(vertical))						   
			   
***read obs
twoway connect obs_read year if fix==0, ///
			   saving("${figure}\temp\connect_obs_read", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///		
			   yscale(range(2000 16000)) ///   
			   ylabel(2000(3000)16000) ///
       		   legend(order(1 "Traditional Sample" 2 "Fixed Sample") ///
					  col(1) ring(0) position(11) region(fcolor(none)) bmargin(none) size(small) rowgap(*.1)) /// 
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("B) `: var label read'", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("N", orientation(vertical))						   

***sped obs
twoway connect obs_sped year if fix==0, ///
			   saving("${figure}\temp\connect_obs_sped", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///		
      		   legend(off) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("C) `: var label sped'", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("N", orientation(vertical))						   

***attd figure
twoway connect obs_attd year if fix==0, ///
			   saving("${figure}\temp\connect_obs_attd", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///					   
      		   legend(off) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("D) `: var label attd'", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("N", orientation(vertical))						   

***enrollment
twoway connect obs year if fix==0, ///
			   saving("${figure}\temp\enroll", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///				   
			   /// yscale(range(.7 1)) ///   
			   /// ylabel(.7(.05)1) ///
			   legend(off) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("E) Enrollment", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("N", orientation(vertical))						   
			   
***fraction tested
twoway connect tested year if fix==0, ///
			   saving("${figure}\temp\tested", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///				   
			   yscale(range(.8 1)) ///   
			   ylabel(.8(.05)1) ///
			   legend(off) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("F) Tested", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("Fraction" "Tested", orientation(vertical))		

***fraction admin
twoway connect admin year if fix==0, ///
			   saving("${figure}\temp\admin", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
/// 			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
/// 			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///				   
/// 			   yscale(range(.8 1)) ///   
/// 			   ylabel(.8(.05)1) ///
			   legend(off) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("G) Flint Community Schools", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle("Fraction" "Administrative District" " " " ", orientation(vertical))	
			   
***combine and export all four figures
graph combine ///
	  "${figure}\temp\connect_obs_math.gph" ///
	  "${figure}\temp\connect_obs_read.gph" ///
	  "${figure}\temp\connect_obs_sped.gph" ///
	  "${figure}\temp\connect_obs_attd.gph" ///
	  "${figure}\temp\enroll.gph" ///
	  "${figure}\temp\tested.gph" ///
	  "${figure}\temp\admin.gph", ///
	  cols(4) xcommon ///
	  title("Observations of Educational Outcomes Over Time in Flint", ///
		    position(12)) ///
	  b1("Year")

graph export "${figure}\connect_N_$date.png", replace width(2500) height(1160)	
