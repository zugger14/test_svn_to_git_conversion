IF COL_LENGTH('delete_source_deal_detail', 'pricing_type') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD pricing_type CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'pricing_period') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD pricing_period CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'event_defination') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD event_defination CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'apply_to_all_legs') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD apply_to_all_legs CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'source_deal_group_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD source_deal_group_id INT
END
GO
