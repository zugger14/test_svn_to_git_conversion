IF COL_LENGTH('company_catalog', 'company_server_name') IS NULL
BEGIN
    ALTER TABLE company_catalog ADD company_server_name VARCHAR(256)
	PRINT 'Column company_server_name added in table company_catalog. '
END
ELSE
BEGIN
	PRINT 'Column company_server_name already exists in table company_catalog.'
END