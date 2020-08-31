IF COL_LENGTH('source_deal_detail_audit', 'formula_curve_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD formula_curve_id INT NULL
    PRINT 'Column source_deal_detail_audit.formula_curve_id added.'
END
GO