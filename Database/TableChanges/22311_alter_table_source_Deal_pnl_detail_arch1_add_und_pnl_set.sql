IF COL_LENGTH('source_Deal_pnl_detail_arch1', 'und_pnl_deal') IS NULL
BEGIN
    ALTER TABLE dbo.source_Deal_pnl_detail_arch1 ADD und_pnl_deal FLOAT
END
ELSE
BEGIN
    PRINT 'Column:und_pnl_deal Already Exists.'
END
GO
IF COL_LENGTH('source_Deal_pnl_detail_arch1', 'und_pnl_inv') IS NULL
BEGIN
    ALTER TABLE dbo.source_Deal_pnl_detail_arch1 ADD und_pnl_inv FLOAT
END
ELSE
BEGIN
    PRINT 'Column:und_pnl_inv Already Exists.'
END
GO
IF COL_LENGTH('source_Deal_pnl_detail_arch1', 'deal_cur_id') IS NULL
BEGIN
    ALTER TABLE dbo.source_Deal_pnl_detail_arch1 ADD deal_cur_id FLOAT
END
ELSE
BEGIN
    PRINT 'Column:deal_cur_id Already Exists.'
END
GO
IF COL_LENGTH('source_Deal_pnl_detail_arch1', 'inv_cur_id') IS NULL
BEGIN
    ALTER TABLE dbo.source_Deal_pnl_detail_arch1 ADD inv_cur_id FLOAT
END
ELSE
BEGIN
    PRINT 'Column:inv_cur_id Already Exists.'
END
GO
IF COL_LENGTH('source_Deal_pnl_detail_arch1', 'mw_position') IS NULL
BEGIN
    ALTER TABLE dbo.source_Deal_pnl_detail_arch1 ADD mw_position FLOAT
END
ELSE
BEGIN
    PRINT 'Column:mw_position Already Exists.'
END