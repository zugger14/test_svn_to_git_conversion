
IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'offset_method') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD offset_method INT NULL
    PRINT 'Column ''offset_method'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''offset_method'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'interest_rate') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD interest_rate INT NULL
    PRINT 'Column ''interest_rate'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''interest_rate'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'interest_method') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD interest_method VARCHAR(200) NULL
    PRINT 'Column ''interest_method'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''interest_method'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO


IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'payment_days') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD payment_days INT NULL
    PRINT 'Column ''payment_days'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''payment_days'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'invoice_due_date') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD invoice_due_date INT NULL
    PRINT 'Column ''invoice_due_date'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''invoice_due_date'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'holiday_calendar_id') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD holiday_calendar_id INT NULL
    PRINT 'Column ''holiday_calendar_id'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''holiday_calendar_id'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'counterparty_trigger') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD counterparty_trigger INT NULL
    PRINT 'Column ''counterparty_trigger'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''counterparty_trigger'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[counterparty_contract_address]', N'company_trigger') IS NULL
BEGIN
    ALTER TABLE [dbo].[counterparty_contract_address]
    ADD company_trigger INT NULL
    PRINT 'Column ''company_trigger'' added on table ''[dbo].[counterparty_contract_address]''.'
END
ELSE
    PRINT 'Column ''company_trigger'' on table ''[dbo].[counterparty_contract_address]'' already exists.'
GO



