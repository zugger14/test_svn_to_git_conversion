IF COL_LENGTH('user_defined_deal_fields_template', 'leg') IS NULL
BEGIN
	ALTER TABLE user_defined_deal_fields_template ADD leg INT 
END
GO


