IF COL_LENGTH('calc_invoice_volume', 'apply_cash_calc_detail_id') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume ADD apply_cash_calc_detail_id INT NULL
END
GO