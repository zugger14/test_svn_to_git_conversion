IF COL_LENGTH('source_deal_header', 'description4') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD description4 VARCHAR(100)
END
GO

