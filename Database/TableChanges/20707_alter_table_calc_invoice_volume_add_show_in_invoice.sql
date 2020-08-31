IF COL_LENGTH('calc_invoice_volume', 'show_in_invoice') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume ADD show_in_invoice CHAR(1)
END
GO