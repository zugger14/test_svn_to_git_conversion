/*
* alter table maintain_limit, alter column 'limit_uom' to int NULL
* sligal
* 11/27/2012
*/
IF COL_LENGTH('maintain_limit', 'limit_uom') IS NOT NULL
BEGIN
	ALTER TABLE maintain_limit ALTER COLUMN limit_uom INT NULL
END
ELSE
	PRINT 'Column limit_uom does not exists in table maintain_limit.'