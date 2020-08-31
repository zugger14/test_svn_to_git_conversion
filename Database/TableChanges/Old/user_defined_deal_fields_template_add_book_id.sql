IF NOT EXISTS(SELECT DISTINCT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'user_defined_deal_fields_template' AND COLUMN_NAME = 'book_id')
	BEGIN 
		ALTER TABLE [dbo].[user_defined_deal_fields_template] ADD
		[book_id] INT NULL
		PRINT 'Table user_defined_deal_fields_template ALTERED'
	END 