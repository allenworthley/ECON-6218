%let data_dir=H:\ECON 6218\Capstone Project;

proc import datafile="&data_dir\Data.xlsx"
			out     =data replace;
            sheet   =Summary_Values;
            range   ="A1:AZ195";
			getnames=yes;
			
run;

proc sort data=data; by date;run;

*=======================================================================================;
* Initial Auto Regressive model;
* Yule-Walker Estimates 1 lag SBC:-698.13682;
* 2 lags SBC:-690.79127;

*=======================================================================================;
* The DF-GLS Test;
/*
Proc Autoreg Data=data;
Model FX = / STATIONARITY=(ERS) ;
Run;
quit;

Proc Autoreg Data=data;
Model us_eu_bnd = / STATIONARITY=(ERS) ;
Run;quit;

Proc Autoreg Data=data;
Model us_eu_trBal = / STATIONARITY=(ERS) ;
Run;quit;

Proc Autoreg Data=data;
Model d_us_eu_trBal = / STATIONARITY=(ERS) ;
Run;quit;

Proc Autoreg Data=data;
Model us_eu_bnd = / STATIONARITY=(ERS) ;
Run;quit;

Proc Autoreg Data=data;
Model d_us_eu_bnd = / STATIONARITY=(ERS) ;
Run;quit;

Proc Autoreg Data=data;
Model us_eu_m3 = / STATIONARITY=(ERS) ;
Run;quit;

Proc Autoreg Data=data;
Model d_us_eu_m3 = / STATIONARITY=(ERS) ;
Run;quit;

*/

*=======================================================================================;



Proc Autoreg Data=data;

Model FX = cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal/ nlag=1;

Run;quit;

proc autoreg data=data;
	model FX = cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal / nlag=1 method=ml;
	output out=p p=yhat pm=ytrend
	lcl=lcl ucl=ucl;
run;quit;

*Estimating Correlation Coeff;
proc corr data=data;
var FX cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal;
run;quit;

*Granger-Causality Test;
proc varmax data=data;
model FX cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal/ p=1;
	causal group1=(FX) group2=(cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal);
	causal group1=(cpi_hcpi) group2=(FX us_eu_m3 us_eu_bnd us_bal d_eu_bal);
	causal group1=(us_eu_m3) group2=(FX cpi_hcpi us_eu_bnd us_bal d_eu_bal);
	causal group1=(us_eu_bnd) group2=(FX cpi_hcpi us_eu_m3 us_bal d_eu_bal);
	causal group1=(us_bal) group2=(FX cpi_hcpi us_eu_m3 us_eu_bnd d_eu_bal);
	causal group1=(d_eu_bal) group2=(FX cpi_hcpi us_eu_m3 us_eu_bnd us_bal );
run;

*=========================================================;
*The Breusch-Godfrey (BG) Test;
*=========================================================;



proc autoreg data= data;

model FX = cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal / Godfrey=9;

run;
quit;


*Step 1;
*=============================;
* Choosing the VAR Model;
*==============================;
* Full Model ;

proc varmax data=data;

model FX cpi_hcpi us_eu_m3 us_eu_bnd us_bal d_eu_bal/ p=1 ;*  SBC=7023.187;
	
run;quit;

*PPP Model;

proc varmax data=data;

model FX cpi_hcpi/ p=1 ;*  SBC=-2679.93; 
	
run;quit;

* PPP including M3 ;

proc varmax data=data;

model FX cpi_hcpi us_eu_m3/ p=1 ;*  SBC=842.2268;

run;quit;


* PPP, m3, Bond ;

proc varmax data=data;

model FX cpi_hcpi us_eu_m3 us_eu_bnd/ p=1; *SBC=184.9072;

run;quit;


* PPP, Bond ;

proc varmax data=data;

model FX cpi_hcpi us_eu_bnd/ p=1; *SBC=-3320.9;

run;quit;

* m3, Bond, Bal ;

proc varmax data=data;

model FX us_eu_m3 us_eu_bnd us_bal eu_bal/ p=1; *SBC=8518.778;

run;
quit;
						
*Step 2;
*=========================;
* How many lags? ;
*=========================;


* Lag-Order Selection ;

* Lag 1 ;

proc varmax data=data;

model FX cpi_hcpi us_eu_bnd/ p=1 ;*  SBC= -2698.82;*Preferred mode -3320.9 * Choosen Model;
	
run;
quit;

*Lag 2;

proc varmax data=data;

model FX cpi_hcpi us_eu_bnd/ p=2 ;*  SBC= -3279.67;  
	
run;
quit;

*Lag 3;

proc varmax data=data;

model FX cpi_hcpi us_eu_bnd/ p=3;*  SBC=-3242.17;
	
run;
quit;


*=====================================;
*Forecasting with VAR modeling        ;
*=====================================;

proc varmax data=data;

model FX cpi_hcpi us_eu_bnd / p=1;

id date interval=month;
     output lead=24 out=forecast;	

run;
quit;


*=======================================================================================;
* Bench Marking Forecasts
*=======================================================================================;
*AR(1)*;
proc arima data= data;

identify var= FX noprint;

estimate p=1 method=cls;

forecast lead=24 interval=month id=date out=AR1;

run;
quit;

*=======================================================================================;

*ARIMA Model;

*Idennifying ARIMA (p,d,q) for SP500 Plots of ACFS and PACFS; 
proc arima data=data;
identify var = FX;
run;
quit;

*Idennifying ARIMA (p,d,q) for SP500 SCAN; 
proc arima data=data;
identify var = d_FX SCAN;
run;
quit;						

*Forecasting ARIMA;
	* Level \ SBC p=2,q=0: -818.848;
	*SBC p=1,q=1: -819.99;
	*dif \ SBC p=0,q=1:    -822.214 ;
	*SBC \ p=1,q=0:  -821.005  ;

proc arima data=data;
identify var = d_FX noprint;
estimate p=1 q=0;
forecast lead=24 interval=month id=Date out=Forecast_ARIMA;
run;
quit;


*Forecasting ARIMA;
proc arima data=data;
identify var = FX noprint;
estimate p=0 q=1;
forecast lead=24 interval=month id=Date out=Forecast_ARIMA;
run;
quit;
