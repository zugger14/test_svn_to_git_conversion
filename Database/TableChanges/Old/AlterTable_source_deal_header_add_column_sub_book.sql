IF COL_LENGTH('source_deal_header', 'sub_book') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD sub_book INT NULL
END
GO