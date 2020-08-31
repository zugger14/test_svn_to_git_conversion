IF COL_LENGTH('company_catalog', 'app_name') IS NULL
BEGIN
    ALTER TABLE company_catalog ADD [app_name] VARCHAR(256)
	PRINT 'Column app_name added in table company_catalog. '
END
ELSE
BEGIN
	PRINT 'Column app_name already exists in table company_catalog.'
END