IF COL_LENGTH('calc_invoice_volume_variance_estimates', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance_estimates ADD settlement_date datetime
END
GO

IF COL_LENGTH('calc_invoice_volume_variance_estimates', 'invoice_type') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance_estimates ADD invoice_type varchar(10)
END
GO