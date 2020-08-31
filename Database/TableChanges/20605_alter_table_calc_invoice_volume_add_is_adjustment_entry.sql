IF COL_LENGTH('calc_invoice_volume', 'is_adjustment_entry') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume ADD is_adjustment_entry CHAR(1) NULL
END
GO