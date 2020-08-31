IF COL_LENGTH('source_deal_detail', 'price_uom_id') IS NULL 
    AND COL_LENGTH('source_deal_detail', 'category') IS NULL 
    AND COL_LENGTH('source_deal_detail', 'profile_code') IS NULL
    AND COL_LENGTH('source_deal_detail', 'pv_party') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD price_uom_id INT, category INT, profile_code INT, pv_party INT
    PRINT 'Column source_deal_detail.price_uom_id, category, profile_code, pv_party added.'
END
ELSE
BEGIN
    PRINT 'Column source_deal_detail.price_uom_id, category, profile_code, pv_party already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'price_uom_id') IS NULL 
    AND COL_LENGTH('source_deal_detail_audit', 'category') IS NULL 
    AND COL_LENGTH('source_deal_detail_audit', 'profile_code') IS NULL
    AND COL_LENGTH('source_deal_detail_audit', 'pv_party') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD price_uom_id INT, category INT, profile_code INT, pv_party INT
    PRINT 'Column source_deal_detail_audit.price_uom_id, category, profile_code, pv_party added.'
END
ELSE
BEGIN
    PRINT 'Column source_deal_detail_audit.price_uom_id, category, profile_code, pv_party already exists.'
END
GO

IF COL_LENGTH('source_deal_detail_template', 'settlement_currency') IS NULL 
    AND COL_LENGTH('source_deal_detail_template', 'standard_yearly_volume') IS NULL 
    AND COL_LENGTH('source_deal_detail_template', 'price_uom_id') IS NULL
    AND COL_LENGTH('source_deal_detail_template', 'category') IS NULL
    AND COL_LENGTH('source_deal_detail_template', 'profile_code') IS NULL
    AND COL_LENGTH('source_deal_detail_template', 'pv_party') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD settlement_currency INT, standard_yearly_volume FLOAT, price_uom_id INT,
        category INT, profile_code INT, pv_party INT 
    PRINT 'Column source_deal_detail_template.settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party added.'
END
ELSE
BEGIN
    PRINT 'Column source_deal_detail_template.settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party already exists.'
END
GO
