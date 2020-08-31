IF COL_LENGTH('contract_report_template', 'template_category') IS NULL
BEGIN
    ALTER TABLE contract_report_template ADD template_category INT NULL
END
ELSE
BEGIN
    PRINT 'template_category Already Exists.'
END 
GO