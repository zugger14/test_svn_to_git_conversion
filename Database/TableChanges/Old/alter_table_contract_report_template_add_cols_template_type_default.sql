IF COL_LENGTH('contract_report_template', 'template_type') IS NULL
BEGIN
	ALTER TABLE contract_report_template ADD [template_type] INT
	PRINT 'template_type column added.'
END
ELSE 
BEGIN
	PRINT 'template_type column already exists.'
END

GO
IF COL_LENGTH('contract_report_template', 'default') IS NULL
BEGIN
	ALTER TABLE contract_report_template ADD [default] BIT DEFAULT 0
	PRINT 'default column added.'
END
ELSE 
BEGIN
	PRINT 'default column already exists.'
END