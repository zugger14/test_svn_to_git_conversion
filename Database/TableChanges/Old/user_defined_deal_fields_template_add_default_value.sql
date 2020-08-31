IF NOT EXISTS(SELECT DISTINCT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'user_defined_deal_fields_template' AND COLUMN_NAME = 'default_value')
	BEGIN 
		ALTER TABLE [dbo].[user_defined_deal_fields_template] ADD
		[default_value] VARCHAR(500) NULL
		PRINT 'Table user_defined_deal_fields_template ALTERED'
	END 