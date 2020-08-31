IF COL_LENGTH('source_deal_detail_hour', 'schedule_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_hour ADD schedule_volume NUMERIC(38, 20)
END
GO

IF COL_LENGTH('source_deal_detail_hour', 'actual_volume') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_hour ADD actual_volume NUMERIC(38, 20)
END
GO
