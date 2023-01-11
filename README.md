# ECON-6218
Advanced Business and Economic Forecasting

Forecasting EUR/USD Final Project 
- Compared multiple timeseries models (AR, ARIMA, and VAR) in SAS to forecast EUR/USD rate using 
monthly macro-economic indicators including the relative money aggregates, trade balances, and purchasing 
power between economies from 2000 – 2017.

- Data Selection: Determined the unit root and corresponding stationarity of transformed variables using the 
Augmented Dickey Fuller test. Selected variables with the highest predictive power using granger causality. 

- ARIMA Estimation: Chose AR and MA parameters using SAS’s scan functionality and found that AR(2) model 
had the lowest SBC. 

- VAR Estimation: As granger causality tests signaled causal relationships, VAR was chosen as the model 
potentially was more representative of the underlying relationships between macro-economic factors. Selected 
lag order based on lowest SBC.

- Compared performance of ARIMA and VAR model forecast error to simple challenger AR(1) model without 
economic variables and observed that the ARIMA model had lowest forecast error.
