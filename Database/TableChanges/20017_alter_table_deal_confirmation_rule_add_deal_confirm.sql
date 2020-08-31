IF COL_LENGTH(N'[dbo].[deal_confirmation_rule]', N'deal_confirm') IS NULL
BEGIN
    ALTER TABLE [dbo].[deal_confirmation_rule]
    ADD deal_confirm INT NULL
    PRINT 'Column ''deal_confirm'' added on table ''[dbo].[deal_confirmation_rule]''.'
END
ELSE
    PRINT 'Column ''deal_confirm'' on table ''[dbo].[deal_confirmation_rule]'' already exists.'
GO