IF COL_LENGTH(N'[dbo].[company_info]', N'company_code') IS NULL
BEGIN
    ALTER TABLE [dbo].[company_info] ADD company_code VARCHAR(64) NOT NULL DEFAULT 'TRMTRACKER'
	PRINT 'company_code column added'
END

IF COL_LENGTH(N'[dbo].[company_info]', N'number_format') IS NULL
BEGIN
    ALTER TABLE [dbo].[company_info] ADD number_format VARCHAR(16) NOT NULL DEFAULT '0,000.00'
	PRINT 'number_format column added'
END

IF COL_LENGTH(N'[dbo].[company_info]', N'price_format') IS NULL
BEGIN
    ALTER TABLE [dbo].[company_info] ADD price_format VARCHAR(16) NOT NULL DEFAULT '$0,000.00'
	PRINT 'price_format column added'
END

IF COL_LENGTH(N'[dbo].[company_info]', N'phone_format') IS NULL
BEGIN
    ALTER TABLE [dbo].[company_info] ADD phone_format CHAR(1) NOT NULL DEFAULT '0'
	PRINT 'phone_format column added'
END

IF COL_LENGTH(N'[dbo].[company_info]', N'decimal_separator') IS NULL
BEGIN
    ALTER TABLE [dbo].[company_info] ADD decimal_separator CHAR(1) NOT NULL DEFAULT '.'
	PRINT 'decimal_separator column added'
END

IF COL_LENGTH(N'[dbo].[company_info]', N'group_separator') IS NULL
BEGIN
    ALTER TABLE [dbo].[company_info] ADD group_separator CHAR(1) NOT NULL DEFAULT ','
	PRINT 'group_separator column added'
END