IF COL_LENGTH('split_deal_actuals', 'issued_year') IS NULL
BEGIN 
	ALTER TABLE split_deal_actuals 
	ADD issued_year SMALLINT	
END


