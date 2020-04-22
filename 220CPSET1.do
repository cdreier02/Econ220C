/* ECON 220C PROBLEM SET 1

Author: Cole Dreier
Last Updated: 4/19/2020
Purpose: Analyze effect of Shall Issue laws on crime rates


*/

cd 			"D:\Desktop\Problem Sets\Spring 2020\Metrics\PSET1"
capture 	log close
log 		using ECON220PSET1, replace

clear


set matsize 300
use handguns.dta
desc
summarize
gen log_vio=log(vio)
gen log_mur=log(mur)
gen log_rob=log(rob)
/************ Question 1 *******/
reg log_vio shall, r
reg log_mur shall, r
reg log_rob shall, r


/************ Question 2 *******/
reg log_vio incarc_rate density pop pm1029 avginc shall, r
reg log_mur incarc_rate density pop pm1029 avginc shall, r
reg log_rob incarc_rate density pop pm1029 avginc shall, r


/************ Question 4 *******/
quietly tab state, gen(statedummy)
quietly tab year, gen(yeardummy)
foreach var in log_vio log_mur log_rob{
	/* column 1 in the table */
	reg `var' shall incarc_rate density pop pm1029 avginc, r
	/* column 2 in the table */
	reg `var' shall incarc_rate density pop pm1029 avginc statedummy*, r
	testparm statedummy*
	reg `var' shall incarc_rate density pop pm1029 avginc statedummy* yeardummy*, r
	testparm statedummy* 
	testparm yeardummy*
	/* if you want to compute standard error that is robust to the time series
	correlation in uit, you can use the following commands. */
	reg `var' shall incarc_rate density pop pm1029 avginc statedummy* yeardummy*, cluster(state) r 
	/* you can also use xtreg here */
	testparm statedummy*
}