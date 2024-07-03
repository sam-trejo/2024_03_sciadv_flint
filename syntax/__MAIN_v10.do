***********************************************************************************
*** SETUP
***********************************************************************************

clear all
set more off, perm
set matsize 5000
pause on
capture postutil close
set scheme burd
graph set window fontface "Calibri Light"
*set trace on
*capture log close

***********************************************************************************
*** SET DIRECTORY GLOBALS
***********************************************************************************

***set home folder

cd ..
global flint "`c(pwd)'"

***set files path globals
global data "${flint}\data"
global syntax "${flint}\syntax"
global table "${flint}\tables"
global figure "${flint}\figures"

***********************************************************************************
*** SET DATA GLOBALS
***********************************************************************************

***set dataset globals

***non-fixed control districts, no subgroups
global non_fix "${data}\mi_geodist_panel_dy_nonfixed_55districts.dta"

***fixed, no subgroups
global fix "${data}\mi_geodist_panel_dy_fixed_55districts.dta"

***all districts, no subgroups
global all "${data}\mi_geodist_panel_dy_all.dta"

***non-fixed control districts, by gender
global gen "${data}\mi_geodist_panel_dygender_nonfixed_55districts.dta"

***non-fixed control districts, by dichotomous grade
global grd_hilo "${data}\mi_geodist_panel_dygradehighlow_nonfixed_55districts"

***FLINT ONLY FILES

***non-fixed control districts, by administrative
global pipe "${data}\mi_geodist_panel_dypipes_nonfixed_55districts"

global ses2 "${data}\mi_geodist_panel_dyses2impute_nonfixed_55districts.dta"

global enf "${data}\mi_geodist_panel_dyevernf_nonfixed_55districts"

***********************************************************************************
*** RUN DOFILES
***********************************************************************************

***clean data files
do "${syntax}\A_clean_v7.do"

***clean heterogeneity data files
do "${syntax}\AA_clean_hetero_v4.do"

***export csv data for augsynth in R
do "${syntax}\B_export_augsynth_v4.do"

***FIGURE 2: Connected Scatterplots (Mean)
do "${syntax}\C_figure_2_v7.do"

***FIGURE 3: Control Sample Selection
do "${syntax}\D_figure_3_v4.do"

***FIGURE 4: Synthetic Control Plots
rscript using Z_figure_3_v4.R

***FIGURE 5: Synthetic Control Robustness Figure
do "${syntax}\E_figure_5_v5.do"

***FIGURE 6: Lead/Copper Connected Scatterplots
do "${syntax}\F_figure_6_v1.do"

***TABLE 1: Summary Statistics
do "${syntax}\G_table_1_v2.do"

***TABLE 2: Synthetic Control Weights & Estimates
rscript using Y_augsynth_60_v10.R
do "${syntax}\GG_get_weights_v1.do"

***TABLE 3: Synthetic Control Robustness
rscript using Y_augsynth_60_v10.R

***TABLE 4: Synthetic Control Decomposition
do "${syntax}\H_table_4_v4.do"
do "${syntax}\HH_delta_p_v1.do"

***FIGURE S1: Connected Scatterplots (Tested/Mobility)
do "${syntax}\I_figure_S1_v5.do"

***TABLE S3: Time Invariant District Descriptives
do "${syntax}\J_table_S3_v1"

***TABLE S4: Synthetic Control Robustness Weights
do "${syntax}\K_table_S4_v2"
