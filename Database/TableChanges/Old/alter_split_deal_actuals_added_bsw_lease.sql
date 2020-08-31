IF COL_LENGTH('split_deal_actuals', 'bsw') IS NULL
BEGIN 
	ALTER TABLE split_deal_actuals 
	ADD bsw NUMERIC(38,20)	
END

IF COL_LENGTH('split_deal_actuals', 'lease_measurement') IS NULL
BEGIN 
	ALTER TABLE split_deal_actuals 
	ADD lease_measurement INT	
END
