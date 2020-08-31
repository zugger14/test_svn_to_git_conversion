IF COL_LENGTH('master_deal_view', 'UDF') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD [UDF] VARCHAR(MAX) NULL
END
GO
IF COL_LENGTH('master_deal_view', 'deal_date_varchar') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD deal_date_varchar VARCHAR(100) NULL
END
GO
IF COL_LENGTH('master_deal_view', 'entire_term_start_varchar') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD entire_term_start_varchar VARCHAR(100) NULL
END
GO
IF COL_LENGTH('master_deal_view', 'entire_term_end_varchar') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD entire_term_end_varchar VARCHAR(100) NULL
END
GO