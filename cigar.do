drop _all
set mem 300m
set more off

cd "D:\Desktop\Problem Sets\Spring 2020\Metrics\PSET2"
capture log close
log using ps2.log, replace


import excel using cigar_new, case(lower) first clear
sort state year
tsset state year

**************************************************************
*      Part (a)                                              *
* Stata adjustments for the degree of freedom Automatically  *
**************************************************************
eststo: reg lnc L1.lnc lnp lny lnpn, r
outreg2 using "220Cpset2tabs.tex", replace nocons


**************************************************************
*      Part (b)                                              *
**************************************************************
quiet tabulate year, generate (yeard)  
                              /*generate the year dummies */

eststo: reg lnc L1.lnc lnp lny lnpn yeard3-yeard30, r
outreg2 using "220Cpset2tabs.tex", nocons drop(yeard3-yeard30)

***************** or use the following ****************
//xi: reg lnc L1.lnc lnp lny lnpn i.year,r

**************************************************************
*      Part (c)                                              *
**************************************************************
by state: gen lnc1=lnc[_n-1]
eststo: xtreg lnc L1.lnc lnp lny lnpn, fe
outreg2 using "220Cpset2tabs.tex", nocons 

**************************************************************
*      Part (d)                                              *
**************************************************************

xtreg lnc L1.lnc lnp lny lnpn yeard3-yeard30, fe 
outreg2 using "220Cpset2tabs.tex", nocons drop(yeard3-yeard30)
testparm yeard*

*---------------- or use the following -------------
//xi: xtreg lnc lnc1 lnp lny lnpn i.year, fe
//outreg2 using "220Cpset2tabs.tex", nocons drop(_Iyear*)
//testparm _Iyear* 
//
*---------------------------------------------------


**************************************************************
*      Part (e)                                              *
**************************************************************

gen Dlnc=D.lnc
eststo: ivreg D.lnc (L1.Dlnc = L2.lnc) D.lnp D.lny D.lnpn  yeard3-yeard30
outreg2 using "220Cpset2tabs.tex", nocons drop(yeard3-yeard30)



**************************************************************
*      Part (g)                                              *
**************************************************************

*******g.i **********
eststo: xtabond lnc lnp lny lnpn yeard2-yeard30, lags(1)
outreg2 using "220Cpset2tabs2.tex", replace nocons drop(yeard3-yeard30)
*or
 //xi: xtabond lnc lnp lny lnpn i.year, lags(1)

*******g.ii **********
xtabond lnc lnp lny lnpn yeard2-yeard30, lags(1) maxldep(3)
outreg2 using "220Cpset2tabs2.tex", nocons drop(yeard3-yeard30)
* or
//xi: xtabond lnc lnp lny lnpn i.year, lags(1) maxldep(3)


*******g.iii **********
xtabond lnc lnp lny lnpn yeard2-yeard30, lags(1) maxldep(1)
outreg2 using "220Cpset2tabs2.tex", nocons drop(yeard3-yeard30)
*or 
//xi: xtabond lnc lnp lny lnpn i.year, lags(1) maxldep(1)


