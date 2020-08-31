IF COL_LENGTH(N'dbo.contract_report_template', N'excel_sheet_id') IS  NULL
BEGIN
    ALTER TABLE dbo.contract_report_template ADD excel_sheet_id INT 
END

GO
IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'contract_report_template'          
                    AND ccu.COLUMN_NAME = 'excel_sheet_id'        
)
BEGIN
	ALTER TABLE dbo.contract_report_template ADD CONSTRAINT FK_excel_sheet_id FOREIGN KEY (excel_sheet_id) 
		REFERENCES dbo.excel_sheet (excel_sheet_id) 
END
GO





