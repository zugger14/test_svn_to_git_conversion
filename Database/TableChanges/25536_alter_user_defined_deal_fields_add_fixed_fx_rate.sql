IF COL_LENGTH('user_defined_deal_fields','fixed_fx_rate') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields
	ADD fixed_fx_rate VARCHAR(50)
END
ELSE
BEGIN
	PRINT 'Column fixed_fx_rate Already Exist'
END
