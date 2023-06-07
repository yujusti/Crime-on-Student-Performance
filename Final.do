clear all
set more off
* ssc install estout
* ssc install outreg2
* ssc install asdoc

/*** Global Directory Set Up ***/
global PATH "C:\Users\justi\Desktop\Uni\Year 3\semester 2\Eco 375\Project"
global output "$PATH\output"
log using "$output\Final Draft Log", replace

/*
Class			Eco375
Project:		Assignment 1
Date Created:	March 25, 2023
*/

* Data Loading
use "$PATH\AEA_Sub_Casey_Schiman_Wachala\CPS_CPD_Outcomes_Crime", clear


* Data Cleaning
drop if Math_WO ==.
drop if Violent_Crime_Before_dist_1 ==.

drop if Math_WO == -9
drop if Violent_Crime_Before_dist_1 == -9

foreach i in 1 2 3 5{
	label variable Violent_Crime_Before_dist_`i' "Violent Crimes within 0.`i' miles"
}

foreach i in 1 2 3 5{
	label variable Property_Crime_Before_dist_`i' "Property Crimes within 0.`i' miles"
}

label variable Math_WO "Prop Students in Warning Category"
label variable avg_hh_size "Average Household Size"
label variable med_age_pop "Median Age Population"
label variable med_inc_hh "Median Household Income"
label variable prop_below_pov "Proportion Below Poverty Line"
label variable unemp "Unemployment Rate"
label variable violent_pp_avg_R "Average Per Capita Crime Rate"
label variable prop_white "% White"
label variable prop_hisp "% Hispanic"
label variable Violent_Crime_dist_1 "Violent Crimes during ISAT"
label variable Violent_Crime_After_dist_1 "Violent Crimes after ISAT"

save "$output\CPS_CPD_Outcomes_Crime", replace
********************************************************************************
* Data Loading
use "$output\CPS_CPD_Outcomes_Crime", clear

********************************************************************************

***Table 1***

* Summary Statistics
outreg2 using "$output\summary.doc", replace sum(log) keep(Math_WO Violent_Crime_Before_dist_* ///
	Property_Crime_Before_dist_* avg_hh_size med_age_pop med_inc_hh prop_below_pov unemp ///
	violent_pp_avg_R prop_white prop_hisp) label title("Summary Statistics of Variables Used in Analysis") ///
addnote("{{\b\i Note:}} The unit of observation is school-year for 415 different Chicago schools from the years 2005 to 2013")


********************************************************************************

***Table 2***

* Running a Simple Regression (Math Scores and Violent Crime within a Distance of 0.1 miles of a School)
quietly reg Math_WO Violent_Crime_Before_dist_1 
outreg2 using "$output\tab2.doc", replace ctitle(" ") ///
	title("Proportion of Students in the Warning Performance Category","Panel Data, Fixed Effects") ///
	addtext(Clustered Errors, NO, School FE, NO, Year FE, NO, Controls, NO) nonotes ///
	addnote("{{\b\i Note:}} The regression models in this table shows the building up and extension our simple regression model to a model which includes with multiple regressors and fixed effects to control for omitted variable biases. To account for model heteroscedasticity, standard errors are clustered at the school level.", "*** indicates a p-value of less than 0.01 significance level, ** indicates a p-value of less than 0.05 significance level, and * indicates a p-value of less than 0.1 significance level")

* Running a Simple Regression (Math Scores and Violent Crime within a Distance of 0.1 miles of a School) with Clustered Standard Errors
quietly reg Math_WO Violent_Crime_Before_dist_1, cluster(schoolid)
outreg2 using "$output\tab2.doc", append ctitle(" ") ///
	addtext(Clustered Errors, YES, School FE, NO, Year FE, NO, Controls, NO) 

* Running a Regression (Math Scores and Violent Crime within a Distance of 0.1 miles of a School) with Clustered Standard Errors and Fixed Effect
xtset schoolid
quietly xtreg Math_WO Violent_Crime_Before_dist_1, fe cluster(schoolid)
outreg2 using "$output\tab2.doc", append ctitle(" ") ///
	addtext(Clustered Errors, YES, School FE, YES, Year FE, NO, Controls, NO) noni

* Running a Regression (Math Scores and Violent Crime within a Distance of 0.1 miles of a School) with Clustered Standard Errors and Fixed Effects
xtset schoolid year
quietly xtreg Math_WO Violent_Crime_Before_dist_1, fe cluster(schoolid)
outreg2 using "$output\tab2.doc", append ctitle(" ") ///
	addtext(Clustered Errors, YES, School FE, YES, Year FE, YES, Controls, NO) noni

* Running a Regression (Math Scores and Violent Crime within a Distance of 0.1 miles of a School) with Clustered Standard Errors and Fixed Effects and Controls
xtset schoolid year
quietly xtreg Math_WO Violent_Crime_Before_dist_1 avg_hh_size med_age_pop med_inc_hh prop_below_pov unemp violent_pp_avg_R prop_white prop_hisp ///
	Violent_Crime_dist_1 Violent_Crime_After_dist_1, fe cluster(schoolid)
outreg2 using "$output\tab2.doc", ///
	append ctitle(" ") /// 
	addtext(Clustered Errors, YES, School FE, YES, Year FE, YES, Controls, YES) noni label

********************************************************************************

***Table 3***

* Creating a Correlation Matrix

asdoc corr Violent_Crime_Before_dist_*, replace abb(.) label save(correlation.doc)

********************************************************************************

* Categorizing Property and Violent Crimes into different distances occurring near a School

generate property_d_1 = Property_Crime_dist_1
generate property_d_2 = Property_Crime_dist_2 - Property_Crime_dist_1
generate property_d_3 = Property_Crime_dist_3 - Property_Crime_dist_2
generate property_d_5 = Property_Crime_dist_5 - Property_Crime_dist_3

generate property_a_1 = Property_Crime_After_dist_1
generate property_a_2 = Property_Crime_After_dist_2 - Property_Crime_After_dist_1
generate property_a_3 = Property_Crime_After_dist_3 - Property_Crime_After_dist_2
generate property_a_5 = Property_Crime_After_dist_5 - Property_Crime_After_dist_3

generate property_b_1 = Property_Crime_Before_dist_1
generate property_b_2 = Property_Crime_Before_dist_2 - Property_Crime_Before_dist_1
generate property_b_3 = Property_Crime_Before_dist_3 - Property_Crime_Before_dist_2
generate property_b_5 = Property_Crime_Before_dist_5 - Property_Crime_Before_dist_3

generate violent_b_1 = Violent_Crime_Before_dist_1 
generate violent_b_2 = Violent_Crime_Before_dist_2 - Violent_Crime_Before_dist_1
generate violent_b_3 = Violent_Crime_Before_dist_3 - Violent_Crime_Before_dist_2
generate violent_b_5 = Violent_Crime_Before_dist_5 - Violent_Crime_Before_dist_3

generate violent_d_1 = Violent_Crime_dist_1
generate violent_d_2 = Violent_Crime_dist_1 - Violent_Crime_dist_2
generate violent_d_3 = Violent_Crime_dist_3 - Violent_Crime_dist_2
generate violent_d_5 = Violent_Crime_dist_5 - Violent_Crime_dist_3

generate violent_a_1 = Violent_Crime_After_dist_1
generate violent_a_2 = Violent_Crime_After_dist_2 - Violent_Crime_After_dist_1
generate violent_a_3 = Violent_Crime_After_dist_3 - Violent_Crime_After_dist_2
generate violent_a_5 = Violent_Crime_After_dist_5 - Violent_Crime_After_dist_3

label variable violent_b_1 "Violent Crimes within 0-0.1 miles"
label variable violent_b_2 "Violent Crimes within 0.1-0.2 miles"
label variable violent_b_3 "Violent Crimes within 0.2-0.3 miles"
label variable violent_b_5 "Violent Crimes within 0.3-0.5 miles"


label variable property_b_1 "Property Crimes within 0-0.1 miles"
label variable property_b_2 "Property Crimes within 0.1-0.2 miles"
label variable property_b_3 "Property Crimes within 0.2-0.3 miles"
label variable property_b_5 "Property Crimes within 0.3-0.5 miles"

***Table 4***

* Setting up the controls
global property_controls prop_hisp property_d_* property_a_*

global violent_controls violent_d_* violent_a_*

global controls violent_d_* violent_a_* property_d_* property_a_*
	
* Running a Regression (Math Scores and Violent Crime at various distances 
* from a school) Controls are included clustered at school level
xtset schoolid year
xtreg Math_WO violent_b_1 violent_b_2 violent_b_3 violent_b_5 $violent_controls, fe cluster(schoolid)
outreg2 using "$output\tab4.doc", addstat(R-squared, e(r2_w)) ///
	replace ctitle(" ") noni nonotes ///
	title("OLS Estimation of The Proportion of Students in the Warning Performance Category","Panel Data, Fixed Effects") ///
	keep(violent_b_1 violent_b_2 violent_b_3 violent_b_5) label addtext(Controls, YES) ///
	addnote("{{\b\i Note:}} The count crimes were categorized based on their distance from a school, in order to reduce multicollinearity. Controls are also included in each regression model, and to account for model heteroscedasticity, standard errors are clustered at the school level.", "*** indicates a p-value of less than 0.01 significance level, ** indicates a p-value of less than 0.05 significance level, and * indicates a p-value of less than 0.1 significance level") 
	
* Running a Regression (Math Scores and Property Crime at various distances 
* from a school) Controls are included clustered school level

xtset schoolid year
xtreg Math_WO property_b_1 property_b_2 property_b_3 property_b_5 ///
	$property_controls, fe cluster(schoolid)
outreg2 using "$output\tab4.doc", addstat(R-squared, e(r2_w)) ///
	append ctitle(" ") noni  ///
	keep(property_b_1 property_b_2 property_b_3 property_b_5) label ///
	addtext(Controls, YES)

* Running a Regression (Math Scores, Violent and Property Crime at various distances 
* from a school) Controls are included clustered school level

xtset schoolid year
quietly xtreg Math_WO violent_b_1 violent_b_2 violent_b_3 violent_b_5 ///
	property_b_1 property_b_2 property_b_3 property_b_5 ///
	$controls, fe cluster(schoolid)
outreg2 using "$output\tab4.doc", addstat(R-squared, e(r2_w)) ///
	append ctitle(" ") noni  ///
	keep(property_b_1 property_b_2 property_b_3 property_b_5 violent_b_1 violent_b_2 violent_b_3 violent_b_5) label ///
	addtext(Controls, YES)

log close
