import delimited using "${table}\temp\reg_weights_60.csv", clear

***round weights
foreach var of varlist a_math_read_sped_attd_60-n_sped_attd_30 {
replace `var'=round(`var',.01)
}

***save out weights for preferred model
save "$data\weights_${date}.dta", replace 
