
***load non-fixed geodist panel
use "${data}\non_fixed.dta", clear

***keep on flint
keep if flint

***math figure
twoway connect math year if fix==0, ///
			   saving("${figure}\temp\connect_math", replace) ///
			   xlin(2015, lcolor(black)) ///
      		   legend(off) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///		
			   yscale(range(-.5  -.8)) ///   
			   ylabel(-.5(-.1)-.8, format(%04.2f)) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("A. `: var label math'", size(medium)) ///
			   xtitle(" ") ///
   			   ytitle(" ") ///

***read figure
twoway connect read year if fix==0, ///
			   saving("${figure}\temp\connect_read", replace) ///
			   xlin(2015, lcolor(black)) ///
			   legend(off) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///		
			   yscale(range(-.5  -.8)) /// 
			   ylabel(-.5(-.1)-.8, format(%04.2f)) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("B. `: var label read'", size(medium)) ///
			   xtitle(" ") ///
   			   ytitle(" ") ///
			   
   

***sped figure
twoway connect sped year if fix==0, ///
			   saving("${figure}\temp\connect_sped", replace) ///
			   xlin(2015, lcolor(black)) ///
      		   legend(off) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///					   
			   ylabel(,format(%04.2f)) ///
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("C. `: var label sped'", size(medium)) ///
			   xtitle(" ") ///
   			   ytitle(" ") ///

***attd figure
twoway connect attd year if fix==0, ///
			   saving("${figure}\temp\connect_attd", replace) ///
			   xlin(2015, lcolor(black)) ///
      		   legend(off) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///					  
			   ylabel(,format(%04.2f)) ///			   
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("D. `: var label attd'", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle(" ") ///			   
			   

***combine and export all figures
graph combine ///
	  "${figure}\temp\connect_math.gph" ///
	  "${figure}\temp\connect_read.gph" ///
	  "${figure}\temp\connect_sped.gph" ///
	  "${figure}\temp\connect_attd.gph", ///
	  cols(2) xcommon ///
	  b1("Year") ///
	  imargin(tiny)
	  
graph export "${figure}\connect_ach_$date.png", replace width(1500) height(1160)	  
	  
/*
***mobility figure
twoway connect mobility year if fix==0, ///
			   saving("${figure}\temp\mobility", replace) ///
			   xlin(2014.3, lcolor(black)) ///
			   xscale(range(2006 2018)) /// 
			   xlabel(2006(4)2018, tlength(*1) tlcolor(black)) ///	
			   xtick(2006(1)2019, tlength(*.5) tlcolor(black)) ///		
			   yscale(range(.7 1)) ///   
			   ylabel(.7(.1)1) ///
       		   legend(order(1 "Traditional Sample" 2 "Fixed Sample") ///
					  col(1) ring(0) position(8) region(fcolor(none)) bmargin(small) size(small) rowgap(*.1)) /// 
			   msymbol(oh) ///
   			   mcolor(ebblue) ///
			   lcolor(ebblue) ///
			   title("G) Same District T-1", size(medium)) ///
   			   xtitle(" ") ///
   			   ytitle(" ") ///
			   
graph combine ///

	  "${figure}\temp\enroll" ///
	  "${figure}\temp\mobility.gph", ///
	  cols(2) xcommon ///
	  title("Mean Educational Outcomes in Flint", ///
		    position(12)) ///
	  b1("Year") ///
	  imargin(tiny)	  
	  
graph export "${figure}\connect_edu_$date.png", replace width(1300) height(1500)	  
			   
