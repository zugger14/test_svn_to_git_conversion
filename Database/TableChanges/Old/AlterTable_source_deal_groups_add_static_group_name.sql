IF COL_LENGTH('source_deal_groups', 'static_group_name') IS NULL
BEGIN
    ALTER TABLE source_deal_groups ADD static_group_name VARCHAR(200)
END
GO

IF COL_LENGTH('delete_source_deal_groups', 'static_group_name') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_groups ADD static_group_name VARCHAR(200)
END
GO

