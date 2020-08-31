IF COL_LENGTH('company_catalog', 'db_user') IS NULL
BEGIN
    ALTER TABLE company_catalog ADD db_user VARCHAR(50)
	PRINT 'Column db_user added in table company_catalog. '
END
ELSE
BEGIN
	PRINT 'Column db_user already exists in table company_catalog.'
END

IF COL_LENGTH('company_catalog', 'db_pwd') IS NULL
BEGIN
    ALTER TABLE company_catalog ADD db_pwd VARBINARY(1000)
	PRINT 'Column db_pwd added in table company_catalog. '
END
ELSE
BEGIN
	PRINT 'Column db_pwd already exists in table company_catalog.'
END