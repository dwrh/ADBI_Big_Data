******************************************************************************************************
****************************************** REPLICATION DATA ******************************************
******************************************************************************************************
************************************ Searching for a Better Life *************************************
****************** Predicting International Migration with Online Search Keywords ********************
******************************************************************************************************
**************************** Marcus Böhme, Tobias Stöhr, Andre Gröger ******************************** 
******************************************************************************************************

* Dataset compatible with Stata v12+, code written and tested in Stata 14/15

log close _all
set more off
clear
set seed 123456

* Install required Stata packages (activate before first run)
*ssc install lars a2group center distinct tuples regxfe crossfold

global ReplicationData "specify your path"
global EXPORT "specify your path"

cd "$ReplicationData"

******************************************************************************************************
********************************* REPLICATION OF UNILATERAL RESULTS **********************************
******************************************************************************************************

set more off 
* First, we replicate the results from the unilateral analysis
log using "$EXPORT\logfile_unilateral_analyses.log", replace

use "$ReplicationData\replication_unilateral.dta", clear

global basic="o_log_gdp o_log_pop"
global extended="o_log_gdp o_log_pop o_sl_uem_totl_zs o_sp_pop_0014_to_zs sfi_sfi pol4_autoc o_IT_CEL_SETS_P2 o_IT_NET_USER_P2 o_number_weather o_number_nonweather"
global GTI="GTI1 GTI2 GTI3 GTI4 GTI5 GTI6 GTI7 GTI8 GTI9 GTI10 GTI11 GTI12 GTI13 GTI14 GTI15 GTI16 GTI17 GTI18 GTI19 GTI20 GTI21 GTI22 GTI23 GTI24 GTI25 GTI26 GTI27 GTI28 GTI29 GTI30 GTI31 GTI32 GTI33 GTI34 GTI35 GTI36 GTI37 GTI38 GTI39 GTI40 GTI41 GTI42 GTI43 GTI44 GTI45 GTI46 GTI47 GTI48 GTI49 GTI50 GTI51 GTI52 GTI53 GTI54 GTI55 GTI56 GTI57 GTI58 GTI59 GTI60 GTI61 GTI62 GTI63 GTI64 GTI65 GTI66 GTI67"

* Generate fixed effects since some commands cannot cope with f./c./i. Stata operators

xtset iso3n_o year

************
* FIGURE 1 *
************

reg fwd_log_uni_mig $basic i.iso3n_o
predict fitted_basic 
reg fwd_log_uni_mig $basic GTI1-GTI67 i.iso3n_o
predict fitted_gti
lab var fwd_log_uni_mig "Next year's emigration flow to OECD"
lab var fitted_basic "Fitted values (basic model)"
lab var fitted_gti "Fitted values (GTI model)"
twoway (tsline fwd_log_uni_mig) (tsline fitted_basic) (tsline fitted_gti) if source_country=="Algeria"|source_country=="Australia"|source_country=="Chile"|source_country=="Pakistan"|source_country=="Spain"|source_country=="Togo", by(source_country, yrescale) graphregion(color(white))
graph export "$EXPORT\replication_Figure1.png", as(png) replace
graph save Graph "$EXPORT\replication_Figure1.gph", replace

***********
* TABLE 1 *
***********
descr GTI1-GTI67

***********
* TABLE 4 *
***********

order $GTI
regxfe fwd_log_uni_mig $basic, fe(year iso3n_o) cluster(iso3n_o) 
outreg2 using "$EXPORT\replication_Table4.xls", replace label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_uni_mig $basic GTI1-GTI67, fe(year iso3n_o) cluster(iso3n_o)
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $GTI
regxfe fwd_log_uni_mig $extended, fe(year iso3n_o) cluster(iso3n_o) 
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_uni_mig $extended GTI1-GTI67, fe(year iso3n_o) cluster(iso3n_o)
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $GTI
regxfe fwd_log_uni_mig $basic if (o_English>.5|o_French>.5|o_Spanish>.5), fe(year iso3n_o) cluster(iso3n_o) 
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_uni_mig $basic GTI1-GTI67 if (o_English>.5|o_French>.5|o_Spanish>.5), fe(year iso3n_o) cluster(iso3n_o)
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $GTI
regxfe fwd_log_uni_mig $basic if o_IT_NET_USER_P2>=10, fe(year iso3n_o) cluster(iso3n_o) 
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_uni_mig $basic GTI1-GTI67 if o_IT_NET_USER_P2>=10, fe(year iso3n_o) cluster(iso3n_o)
outreg2 using "$EXPORT\replication_Table4.xls", append label excel tex ctitle("Benchmark") adds(Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $GTI


*************
* FIGURE A1 *
*************
preserve
sort iso3n_o year

* Demean variables to have OOS-proxy of within-R2
* NB: Demeaned setup brings us very close to the xtreg within r2, but not exactly to it. The way the crossfold validation calculates the R2, this is a reasonably good approximation.
local othervars="log_uni_mig fwd_log_uni_mig $basic year_fx1 year_fx2 year_fx3 year_fx4 year_fx5 year_fx6 year_fx7 year_fx8 year_fx9 year_fx10 year_fx11 year_fx12 $GTI"
foreach var in `othervars'  {
bysort iso3n_o: egen varmean=mean(`var')
gen dm_`var'=`var'-varmean
drop varmean
bysort year: egen varmean=mean(dm_`var')
gen dm_dm_`var'=dm_`var'-varmean
drop varmean
}

* Use this specification also to run least-angle regression. The commands do not support "f."-syntax, hence create new variable.
sort iso3n_o year
gen fwd_dm_dm_log_uni_mig=f.dm_dm_log_uni_mig
lars fwd_dm_dm_log_uni_mig dm_dm_o_log_pop dm_dm_o_log_gdp dm_dm_GTI*, a(lasso) // optimal vector according to Lasso retains 51 GTI

* Set up matrices for export of OOS results
capture matrix drop OOSR2
matrix define OOSR2 = J(10,3,.)
matrix colnames OOSR2 = "Basic"   "ALL_GTI"  
matrix rownames OOSR2 = "est1" "est2" "est3" "est4" "est5" "est6" "est7" "est8" "est9" "est10"
capture matrix drop RMSE
matrix define RMSE = J(10,3,.)
matrix colnames RMSE = "Basic"  "ALL_GTI"  
matrix rownames RMSE = "est1" "est2" "est3" "est4" "est5" "est6" "est7" "est8" "est9" "est10"

sort iso3n_o year
* Calculate OOS-R2
crossfold: reg f.dm_dm_log_uni_mig dm_dm_o_log_pop dm_dm_o_log_gdp, k(10) r2
matrix OOSR2=r(est)
crossfold: reg f.dm_dm_log_uni_mig dm_dm_o_log_pop dm_dm_o_log_gdp dm_dm_GTI*, k(10) r2
matrix OOSR2=OOSR2,r(est)
* Calculate OOS-RMSE
crossfold: reg f.dm_dm_log_uni_mig dm_dm_o_log_pop dm_dm_o_log_gdp, k(10)
matrix RMSE=r(est)
crossfold: reg f.dm_dm_log_uni_mig dm_dm_o_log_pop dm_dm_o_log_gdp dm_dm_GTI*, k(10)
matrix RMSE=RMSE,r(est)

* Reshape and plot OOS-Results
mat li OOSR2, format(%4.3f)
mat li RMSE, format(%4.3f)
svmat OOSR2, names(OOSR2_)
svmat RMSE, names(RMSE_)
gen reshape_id=_n
drop if OOSR2_1==.
keep OOS* RMSE* reshape_id*
reshape long OOSR2 RMSE, i(reshape_id) j(estimator) string

gen model=. 
forval i=1/2{
replace model=`i' if estimator=="_`i'"
local i=`i'+1
}

lab define model 1 "No GTI" 2 "GTI" 
lab values model model

graph box OOSR2, over(model, label(labsize(small))) marker(1, msize(small)) scheme(s2color) scale(0.6) graphregion(color(white)) 
graph export "$EXPORT\replication_FigureA1.png", replace
graph save Graph "$EXPORT\replication_FigureA1.gph", replace
log close
****************************** END OF REPLICATION OF UNILATERAL RESULTS ******************************
******************************************************************************************************



******************************************************************************************************
********************************* REPLICATION OF BILATERAL RESULTS **********************************
******************************************************************************************************
set more off
log using "$EXPORT\logfile_bilateral_analyses.log", replace
use "$ReplicationData\replication_bilateral.dta", replace

global basic="o_log_gdp o_log_pop d_log_gdp d_log_pop" 

global sample1 "fwd_log_mig!=. & GTI_bil_1!=. & GTI1!=.  &  o_log_gdp!=. &  o_log_pop!=. &  d_log_gdp!=. & d_log_pop!=."	
count if $sample1 
bys year: count if $sample1

global gti "GTI_bil_0 GTI_bil_1 GTI_bil_2 GTI_bil_3 GTI_bil_4 GTI_bil_5 GTI_bil_6 GTI_bil_7 GTI_bil_8 GTI_bil_9 GTI_bil_10 GTI_bil_11 GTI_bil_12 GTI_bil_13 GTI_bil_14 GTI_bil_15 GTI_bil_16 GTI_bil_17 GTI_bil_18 GTI_bil_19 GTI_bil_20 GTI_bil_21 GTI_bil_22 GTI_bil_23 GTI_bil_24 GTI_bil_25 GTI_bil_26 GTI_bil_27 GTI_bil_28 GTI_bil_29 GTI_bil_30 GTI_bil_31 GTI_bil_32 GTI_bil_33 GTI_bil_34 GTI_bil_35 GTI_bil_36 GTI_bil_37 GTI_bil_38 GTI_bil_39 GTI_bil_40 GTI_bil_41 GTI_bil_42 GTI_bil_43 GTI_bil_44 GTI_bil_45 GTI_bil_46 GTI_bil_47 GTI_bil_48 GTI_bil_49 GTI_bil_50 GTI_bil_51 GTI_bil_52 GTI_bil_53 GTI_bil_54 GTI_bil_55 GTI_bil_56 GTI_bil_57 GTI_bil_58 GTI_bil_59 GTI_bil_60 GTI_bil_61 GTI_bil_62 GTI_bil_63 GTI_bil_64 GTI_bil_65 GTI_bil_66 GTI_bil_67 c.GTI_bil_0#c.o_migration1 c.GTI_bil_0#c.o_migration2 c.GTI_bil_0#c.o_migration3 c.GTI_bil_0#c.o_migration4 c.GTI_bil_0#c.o_migration5 c.GTI_bil_0#c.o_migration6 c.GTI_bil_0#c.o_migration7 c.GTI_bil_0#c.o_migration8 c.GTI_bil_0#c.o_migration9 c.GTI_bil_0#c.o_migration10 c.GTI_bil_0#c.o_migration11 c.GTI_bil_0#c.o_migration12 c.GTI_bil_0#c.o_migration13 c.GTI_bil_0#c.o_migration14  c.GTI_bil_0#c.o_migration15 c.GTI_bil_0#c.o_migration16 c.GTI_bil_0#c.o_migration17 c.GTI_bil_0#c.o_migration18 c.GTI_bil_0#c.o_migration19 c.GTI_bil_0#c.o_migration20 c.GTI_bil_0#c.o_migration21  c.GTI_bil_0#c.o_migration22 c.GTI_bil_0#c.o_migration23 c.GTI_bil_0#c.o_migration24 c.GTI_bil_0#c.o_migration25 c.GTI_bil_0#c.o_migration26 c.GTI_bil_0#c.o_migration27 c.GTI_bil_0#c.o_migration28 c.GTI_bil_0#c.o_migration29 c.GTI_bil_0#c.o_migration30 c.GTI_bil_0#c.o_migration31 c.GTI_bil_0#c.o_migration32 c.GTI_bil_0#c.o_migration33 c.GTI_bil_0#c.o_migration34 c.GTI_bil_0#c.o_migration35 c.GTI_bil_0#c.o_migration36 c.GTI_bil_0#c.o_migration37 c.GTI_bil_0#c.o_migration38 c.GTI_bil_0#c.o_migration39 c.GTI_bil_0#c.o_migration40 c.GTI_bil_0#c.o_migration41 c.GTI_bil_0#c.o_migration42 c.GTI_bil_0#c.o_migration43 c.GTI_bil_0#c.o_migration44 c.GTI_bil_0#c.o_migration45 c.GTI_bil_0#c.o_migration46 c.GTI_bil_0#c.o_migration47 c.GTI_bil_0#c.o_migration48 c.GTI_bil_0#c.o_migration49 c.GTI_bil_0#c.o_migration50 c.GTI_bil_0#c.o_migration51 c.GTI_bil_0#c.o_migration52 c.GTI_bil_0#c.o_migration53 c.GTI_bil_0#c.o_migration54 c.GTI_bil_0#c.o_migration55 c.GTI_bil_0#c.o_migration56 c.GTI_bil_0#c.o_migration57 c.GTI_bil_0#c.o_migration58 c.GTI_bil_0#c.o_migration59 c.GTI_bil_0#c.o_migration60 c.GTI_bil_0#c.o_migration61 c.GTI_bil_0#c.o_migration62 c.GTI_bil_0#c.o_migration63 c.GTI_bil_0#c.o_migration64 c.GTI_bil_0#c.o_migration65 c.GTI_bil_0#c.o_migration66 c.GTI_bil_0#c.o_migration67"

sort pair_id year

***********
* TABLE 2 *
***********
tab iso3n_d
codebook iso3_o iso3_d if $sample1 

***********
* TABLE 3 *
***********
estpost sum fwd_tot_mig GTI_bil_0 d_GDP d_pop o_GDP o_pop o_sl_uem_totl_zs o_sp_pop_0014_to_zs sfi_sfi pol4_autoc o_IT_CEL_SETS_P2 o_IT_NET_USER_P2 o_number_weather o_number_nonweather if $sample1
esttab using "$EXPORT\replication_Table3.tex", cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(0))") tex nomtitle nonumber label replace

***********
* TABLE 5 *
***********

global bil_GTI_spec="GTI_bil_0 GTI_bil_1 GTI_bil_2 GTI_bil_3 GTI_bil_4 GTI_bil_5 GTI_bil_6 GTI_bil_7 GTI_bil_8 GTI_bil_9 GTI_bil_10 GTI_bil_12 GTI_bil_13 GTI_bil_14 GTI_bil_15 GTI_bil_16 GTI_bil_17 GTI_bil_18 GTI_bil_19 GTI_bil_20 GTI_bil_21 GTI_bil_22 GTI_bil_23 GTI_bil_24 GTI_bil_25 GTI_bil_26 GTI_bil_27 GTI_bil_28 GTI_bil_29 GTI_bil_30 GTI_bil_31 GTI_bil_32 GTI_bil_33 GTI_bil_34 GTI_bil_35 GTI_bil_36 GTI_bil_37 GTI_bil_38 GTI_bil_39 GTI_bil_40 GTI_bil_41 GTI_bil_42 GTI_bil_43 GTI_bil_44 GTI_bil_45 GTI_bil_46 GTI_bil_47 GTI_bil_48 GTI_bil_49 GTI_bil_50 GTI_bil_51 GTI_bil_52 GTI_bil_53 GTI_bil_54 GTI_bil_55 GTI_bil_56 GTI_bil_57 GTI_bil_58 GTI_bil_59 GTI_bil_60 GTI_bil_61 GTI_bil_62 GTI_bil_63 GTI_bil_64 GTI_bil_65 GTI_bil_66 GTI_bil_67 GTI_bil0_uni1 GTI_bil0_uni2 GTI_bil0_uni3 GTI_bil0_uni4 GTI_bil0_uni5 GTI_bil0_uni6 GTI_bil0_uni7 GTI_bil0_uni8 GTI_bil0_uni9 GTI_bil0_uni10 GTI_bil0_uni11 GTI_bil0_uni12 GTI_bil0_uni13 GTI_bil0_uni14 GTI_bil0_uni15 GTI_bil0_uni16 GTI_bil0_uni17 GTI_bil0_uni18 GTI_bil0_uni19 GTI_bil0_uni20 GTI_bil0_uni21 GTI_bil0_uni22 GTI_bil0_uni23 GTI_bil0_uni24 GTI_bil0_uni25 GTI_bil0_uni26 GTI_bil0_uni27 GTI_bil0_uni28 GTI_bil0_uni29 GTI_bil0_uni30 GTI_bil0_uni31 GTI_bil0_uni32 GTI_bil0_uni33 GTI_bil0_uni34 GTI_bil0_uni35 GTI_bil0_uni36 GTI_bil0_uni37 GTI_bil0_uni38 GTI_bil0_uni39 GTI_bil0_uni40 GTI_bil0_uni41 GTI_bil0_uni42 GTI_bil0_uni43 GTI_bil0_uni44 GTI_bil0_uni45 GTI_bil0_uni46 GTI_bil0_uni47 GTI_bil0_uni48 GTI_bil0_uni49 GTI_bil0_uni50 GTI_bil0_uni51 GTI_bil0_uni52 GTI_bil0_uni53 GTI_bil0_uni54 GTI_bil0_uni55 GTI_bil0_uni56 GTI_bil0_uni57 GTI_bil0_uni58 GTI_bil0_uni59 GTI_bil0_uni60 GTI_bil0_uni61 GTI_bil0_uni62 GTI_bil0_uni63 GTI_bil0_uni64 GTI_bil0_uni65 GTI_bil0_uni66 GTI_bil0_uni67"

* regxfe does not accept "c."-syntax, hence create GTI_bil0*GTI_uni1-67 interactions explicitly
forval i=1/67{
	gen GTI_bil0_uni`i'=GTI_bil_0*GTI`i'
	}	

//destination, origin, and year FEs (a la Mayda 2009)
regxfe fwd_log_mig $basic if $sample1, fe(iso3n_o iso3n_d year)  cluster(pair_id)  
outreg2 using "$EXPORT\replication_Table5.xls", replace label excel tex ctitle("Benchmark, Mayda") adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 $basic if $sample1, fe(iso3n_o iso3n_d year)  cluster(pair_id)
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("GTI, Mayda")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec
												
//originXyear and destination FEs (multilateral resistance Ortega and Peri 2013)
regxfe fwd_log_mig d_log_gdp d_log_pop  if $sample1, fe(iso3n_oXyear iso3n_d) cluster(pair_id)
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("Benchmark, OP")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 if $sample1, fe(iso3n_oXyear iso3n_d) cluster(pair_id)
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("GTI, OP")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

//originXyear and destinationXyear FEs (trade spec)
regxfe fwd_log_mig d_log_gdp d_log_pop  if $sample1, fe(iso3n_oXyear iso3n_dXyear) cluster(pair_id)
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("Benchmark, origin/destinationXyear")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 if $sample1, fe(iso3n_oXyear iso3n_dXyear) cluster(pair_id)
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("all GTI, origin/destinationXyear")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

//originXyear and pair FEs
regxfe fwd_log_mig d_log_gdp d_log_pop  if $sample1, fe(pair_id  iso3n_oXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("Benchmark, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 if $sample1, fe(pair_id  iso3n_oXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("all GTI, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

*originXyear, destinationXyear and pair FEs 
regxfe fwd_log_mig d_log_gdp d_log_pop  if $sample1, fe(pair_id iso3n_oXyear  iso3n_dXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("Benchmark, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 if $sample1, fe(pair_id iso3n_oXyear  iso3n_dXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_Table5.xls", append label excel tex ctitle("all GTI, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

************
* TABLE A1 *
************

estpost sum GTI_bil_1 GTI_bil_1 GTI_bil_2 GTI_bil_3 GTI_bil_4 GTI_bil_5 GTI_bil_6 GTI_bil_7 GTI_bil_8 GTI_bil_9 GTI_bil_10 GTI_bil_11 GTI_bil_12 GTI_bil_13 GTI_bil_14 GTI_bil_15 GTI_bil_16 GTI_bil_17 GTI_bil_18 GTI_bil_19 GTI_bil_20 GTI_bil_21 GTI_bil_22 GTI_bil_23 GTI_bil_24 GTI_bil_25 GTI_bil_26 GTI_bil_27 GTI_bil_28 GTI_bil_29 GTI_bil_30 GTI_bil_31 GTI_bil_32 GTI_bil_33 GTI_bil_34 GTI_bil_35 GTI_bil_36 GTI_bil_37 GTI_bil_38 GTI_bil_39 GTI_bil_40 GTI_bil_41 GTI_bil_42 GTI_bil_43 GTI_bil_44 GTI_bil_45 GTI_bil_46 GTI_bil_47 GTI_bil_48 GTI_bil_49 GTI_bil_50 GTI_bil_51 GTI_bil_52 GTI_bil_53 GTI_bil_54 GTI_bil_55 GTI_bil_56 GTI_bil_57 GTI_bil_58 GTI_bil_59 GTI_bil_60 GTI_bil_61 GTI_bil_62 GTI_bil_63 GTI_bil_64 GTI_bil_65 GTI_bil_66 GTI_bil_67 if $sample1
esttab using "$EXPORT\replication_TableA1.tex", cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(0))") tex nomtitle nonumber label replace
 
************
* TABLE A2 *
************

global bil_GTI_spec="GTI_bil_0 GTI_bil_2 GTI_bil_3 GTI_bil_4 GTI_bil_5 GTI_bil_6 GTI_bil_7 GTI_bil_8 GTI_bil_9 GTI_bil_10 GTI_bil_12 GTI_bil_13 GTI_bil_14 GTI_bil_15 GTI_bil_16 GTI_bil_17 GTI_bil_18 GTI_bil_19 GTI_bil_20 GTI_bil_21 GTI_bil_22 GTI_bil_23 GTI_bil_24 GTI_bil_25 GTI_bil_26 GTI_bil_27 GTI_bil_28 GTI_bil_29 GTI_bil_30 GTI_bil_31 GTI_bil_32 GTI_bil_33 GTI_bil_34 GTI_bil_36 GTI_bil_37 GTI_bil_38 GTI_bil_39 GTI_bil_40 GTI_bil_41 GTI_bil_43 GTI_bil_44 GTI_bil_45 GTI_bil_46 GTI_bil_47 GTI_bil_48 GTI_bil_49 GTI_bil_50 GTI_bil_51 GTI_bil_52 GTI_bil_53 GTI_bil_54 GTI_bil_55 GTI_bil_56 GTI_bil_57 GTI_bil_58 GTI_bil_59 GTI_bil_60 GTI_bil_61 GTI_bil_62 GTI_bil_63 GTI_bil_64 GTI_bil_65 GTI_bil_66 GTI_bil_67 GTI_bil0_uni1 GTI_bil0_uni2 GTI_bil0_uni3 GTI_bil0_uni4 GTI_bil0_uni5 GTI_bil0_uni6 GTI_bil0_uni7 GTI_bil0_uni8 GTI_bil0_uni9 GTI_bil0_uni10 GTI_bil0_uni11 GTI_bil0_uni12 GTI_bil0_uni13 GTI_bil0_uni14 GTI_bil0_uni15 GTI_bil0_uni16 GTI_bil0_uni17 GTI_bil0_uni18 GTI_bil0_uni19 GTI_bil0_uni20 GTI_bil0_uni21 GTI_bil0_uni22 GTI_bil0_uni23 GTI_bil0_uni24 GTI_bil0_uni25 GTI_bil0_uni26 GTI_bil0_uni27 GTI_bil0_uni28 GTI_bil0_uni29 GTI_bil0_uni30 GTI_bil0_uni31 GTI_bil0_uni32 GTI_bil0_uni33 GTI_bil0_uni34 GTI_bil0_uni35 GTI_bil0_uni36 GTI_bil0_uni37 GTI_bil0_uni38 GTI_bil0_uni39 GTI_bil0_uni40 GTI_bil0_uni41 GTI_bil0_uni42 GTI_bil0_uni43 GTI_bil0_uni44 GTI_bil0_uni45 GTI_bil0_uni46 GTI_bil0_uni47 GTI_bil0_uni48 GTI_bil0_uni49 GTI_bil0_uni50 GTI_bil0_uni51 GTI_bil0_uni52 GTI_bil0_uni53 GTI_bil0_uni54 GTI_bil0_uni55 GTI_bil0_uni56 GTI_bil0_uni57 GTI_bil0_uni58 GTI_bil0_uni59 GTI_bil0_uni60 GTI_bil0_uni61 GTI_bil0_uni62 GTI_bil0_uni63 GTI_bil0_uni64 GTI_bil0_uni65 GTI_bil0_uni66 GTI_bil0_uni67"

//destination, origin, and year FEs (a la Mayda 2009)
regxfe fwd_log_mig $basic log_mig_stock if $sample1, fe(iso3n_o iso3n_d year)  cluster(pair_id)  
outreg2 using "$EXPORT\replication_TableA2.xls", replace label excel tex ctitle("Benchmark, Mayda") adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 $basic  if $sample1, fe(iso3n_o iso3n_d year)  cluster(pair_id)
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("GTI, Mayda")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec
												
//originXyear and destination FEs (multilateral resistance Ortega and Peri 2013)
regxfe fwd_log_mig d_log_gdp d_log_pop  log_mig_stock if $sample1, fe(iso3n_oXyear iso3n_d) cluster(pair_id)
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("Benchmark, OP")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 log_mig_stock if $sample1, fe(iso3n_oXyear iso3n_d) cluster(pair_id)
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("GTI, OP")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

//originXyear and destinationXyear FEs (trade spec)
regxfe fwd_log_mig d_log_gdp d_log_pop  log_mig_stock if $sample1, fe(iso3n_oXyear iso3n_dXyear) cluster(pair_id)
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("Benchmark, origin/destinationXyear")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 log_mig_stock if $sample1, fe(iso3n_oXyear iso3n_dXyear) cluster(pair_id)
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("all GTI, origin/destinationXyear")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

//originXyear and pair FEs
regxfe fwd_log_mig d_log_gdp d_log_pop  log_mig_stock if $sample1, fe(pair_id  iso3n_oXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("Benchmark, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 log_mig_stock if $sample1, fe(pair_id  iso3n_oXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("all GTI, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec

*originXyear, destinationXyear and pair FEs 
regxfe fwd_log_mig d_log_gdp d_log_pop  log_mig_stock if $sample1, fe(pair_id iso3n_oXyear  iso3n_dXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("Benchmark, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
regxfe fwd_log_mig d_log_gdp d_log_pop GTI_bil_0-GTI_bil_67 GTI_bil0_uni1-GTI_bil0_uni67 log_mig_stock if $sample1, fe(pair_id iso3n_oXyear  iso3n_dXyear) cluster(pair_id)  
outreg2 using "$EXPORT\replication_TableA2.xls", append label excel tex ctitle("all GTI, OP pair FE")  adds(Adjusted R2, e(r2_a), Within-R2, e(r2w), Unadjusted R2, e(r2o))
test $bil_GTI_spec 
 
*********************************************************************************************************
* For copyright reasons, we are not allowed to share the Gallup World Poll data. 
* Tables 6, A3, and A4 are thus replicated in the log file which is provided with this replication data.
*********************************************************************************************************
log close
****************************** END OF REPLICATION OF BILATERAL RESULTS **********************************
*********************************************************************************************************


 