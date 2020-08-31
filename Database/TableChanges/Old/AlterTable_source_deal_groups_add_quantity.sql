IF COL_LENGTH('source_deal_groups', 'quantity') IS NULL
BEGIN
    ALTER TABLE source_deal_groups ADD quantity FLOAT
END
GO


IF COL_LENGTH('delete_source_deal_groups', 'quantity') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_groups ADD quantity FLOAT
END
GO
