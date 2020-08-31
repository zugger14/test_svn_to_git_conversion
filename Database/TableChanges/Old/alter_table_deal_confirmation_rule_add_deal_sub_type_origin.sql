IF COL_LENGTH(N'[dbo].[deal_confirmation_rule]', N'deal_sub_type') IS NULL
BEGIN
    ALTER TABLE [dbo].[deal_confirmation_rule]
    ADD deal_sub_type INT NULL
    PRINT 'Column ''deal_sub_type'' added on table ''[dbo].[deal_confirmation_rule]''.'
END
ELSE
    PRINT 'Column ''deal_sub_type'' on table ''[dbo].[deal_confirmation_rule]'' already exists.'
GO

IF COL_LENGTH(N'[dbo].[deal_confirmation_rule]', N'origin') IS NULL
BEGIN
    ALTER TABLE [dbo].[deal_confirmation_rule]
    ADD origin INT NULL
    PRINT 'Column ''origin'' added on table ''[dbo].[deal_confirmation_rule]''.'
END
ELSE
    PRINT 'Column ''origin'' on table ''[dbo].[deal_confirmation_rule]'' already exists.'
GO