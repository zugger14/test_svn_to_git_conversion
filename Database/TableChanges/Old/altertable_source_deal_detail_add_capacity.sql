IF NOT EXISTS(SELECT 'X' FROM   information_schema.columns WHERE  TABLE_NAME = 'source_deal_detail' AND COLUMN_NAME = 'capacity')
BEGIN
    ALTER TABLE source_deal_detail
    ADD capacity FLOAT
END

