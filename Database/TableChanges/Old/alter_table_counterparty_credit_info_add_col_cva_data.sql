/*
* alter table counterparty_credit_info, add col cva_data.
* sligal
* 03/28/2013
*/

IF COL_LENGTH('counterparty_credit_info', 'cva_data') IS NULL
BEGIN
    ALTER TABLE counterparty_credit_info ADD cva_data INT NULL
END
ELSE
	PRINT 'Column cva_data already exists in table counterparty_credit_info'
GO
