IF COL_LENGTH('excel_sheet','document_template_id') IS NULL
	ALTER TABLE excel_sheet ADD document_template_id INT
GO