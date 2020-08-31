IF COL_LENGTH('netting_group','internal_counterparty') IS NULL
BEGIN
	ALTER TABLE netting_group ADD internal_counterparty INT NULL
END
ELSE 
	PRINT 'Column internal_counterparty Already Exists.'