IF COL_LENGTH('excel_sheet','document_template_id') IS NOT NULL
	ALTER TABLE excel_sheet 
	DROP COLUMN document_template_id
GO