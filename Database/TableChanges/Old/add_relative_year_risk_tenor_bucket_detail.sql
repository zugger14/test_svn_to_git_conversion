IF COL_LENGTH('risk_tenor_bucket_detail', 'relative_year_from') IS NULL
BEGIN
alter TABLE [dbo].[risk_tenor_bucket_detail] add [relative_year_from] [int] NULL,[relative_year_to] [int] NULL
END
