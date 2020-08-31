IF COL_LENGTH('source_deal_header', 'reference_detail_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD reference_detail_id INT
END
GO