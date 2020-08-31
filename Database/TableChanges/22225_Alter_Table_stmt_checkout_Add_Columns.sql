IF COL_LENGTH('stmt_checkout', 'accounting_month') IS NULL
BEGIN
	ALTER TABLE stmt_checkout ADD accounting_month DATETIME
END

IF COL_LENGTH(N'[dbo].[stmt_checkout]', N'is_ignore') IS NULL
BEGIN 
	ALTER TABLE stmt_checkout ADD  is_ignore BIT 
END

IF COL_LENGTH(N'[dbo].[stmt_checkout]', N'reversal_stmt_checkout_id') IS NULL
BEGIN 
	ALTER TABLE stmt_checkout ADD  reversal_stmt_checkout_id INT 
END

IF COL_LENGTH(N'[dbo].[stmt_checkout]', N'is_reversal_required') IS NULL
BEGIN 
	ALTER TABLE stmt_checkout ADD  is_reversal_required CHAR(1)
END

IF COL_LENGTH(N'[dbo].[stmt_checkout]', N'is_reversal_required') IS NOT NULL
BEGIN 
	ALTER TABLE stmt_checkout ALTER COLUMN  is_reversal_required CHAR(1)
END


