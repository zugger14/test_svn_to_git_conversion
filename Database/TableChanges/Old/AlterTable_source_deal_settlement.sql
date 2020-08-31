-- Alter table source_deal_settlement 

IF COL_LENGTH('source_deal_settlement', 'volume_uom') IS NULL 
    AND COL_LENGTH('source_deal_settlement', 'fin_volume') IS NULL 
    AND COL_LENGTH('source_deal_settlement', 'fin_volume_uom') IS NULL
    AND COL_LENGTH('source_deal_settlement', 'float_Price') IS NULL
    AND COL_LENGTH('source_deal_settlement', 'deal_Price') IS NULL
    AND COL_LENGTH('source_deal_settlement', 'price_currency') IS NULL
BEGIN
    ALTER TABLE source_deal_settlement 
			ADD			volume_uom INT,
                        fin_volume FLOAT,
                        fin_volume_uom INT, 
                        float_Price FLOAT,
                        deal_Price FLOAT,
                        price_currency INT

    PRINT 'Column volume_uom,fin_volume, fin_volume_uom, float_Price, deal_Price, price_currency Added'
END