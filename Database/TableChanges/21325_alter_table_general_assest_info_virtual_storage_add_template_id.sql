IF COL_LENGTH('general_assest_info_virtual_storage', 'template_id') IS NOT NULL
BEGIN
    
	EXEC('UPDATE general_assest_info_virtual_storage 
			SET template_id = NULL'
		)

	IF COL_LENGTH('general_assest_info_virtual_storage', 'injection_template_id') IS NULL
	BEGIN
		EXEC sp_rename 'dbo.general_assest_info_virtual_storage.template_id', 'injection_template_id', 'COLUMN';
	END	
	
	IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'general_assest_info_virtual_storage'           --table name
                    AND ccu.COLUMN_NAME = 'injection_template_id'          --column name where FK constaint is to be created
	)
	BEGIN
		ALTER TABLE dbo.general_assest_info_virtual_storage     
		ADD CONSTRAINT FK_general_assest_info_virtual_storage_injection FOREIGN KEY (injection_template_id)     
			REFERENCES dbo.[source_deal_header_template] (template_id)     
	END
  
END
GO

IF COL_LENGTH('general_assest_info_virtual_storage', 'withdrawal_template_id') IS NULL
BEGIN
    ALTER TABLE general_assest_info_virtual_storage ADD withdrawal_template_id INT NULL
	REFERENCES [dbo].[source_deal_header_template] (template_id)
END
GO


