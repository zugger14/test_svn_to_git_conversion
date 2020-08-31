/**
* create table pfe_results_term_wise
* purpose: store pfe results in term wise basis.
* sligal
* 6/27/2013
**/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pfe_results_term_wise]', N'U') IS NULL
BEGIN
    CREATE TABLE pfe_results_term_wise(
		as_of_date DATETIME, 
		term_start DATETIME,
		counterparty_id INT,
		criteria_id INT,
		measurement_approach INT,
		confidence_interval INT,
		fixed_exposure FLOAT,
		current_exposure FLOAT,
		pfe FLOAT,
		total_future_exposure FLOAT
	)
END
ELSE
BEGIN
    PRINT 'Table pfe_results_term_wise EXISTS'
END
 
GO