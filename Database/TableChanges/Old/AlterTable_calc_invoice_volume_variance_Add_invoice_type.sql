IF COL_LENGTH('calc_invoice_volume_variance', 'invoice_type') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD invoice_type CHAR(1)
END
GO

IF COL_LENGTH('calc_invoice_volume_variance', 'netting_group_id') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD netting_group_id INT
END
GO

IF COL_LENGTH('calc_invoice_volume_variance', 'prod_date_to') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD prod_date_to DATETIME
END
GO

IF COL_LENGTH('calc_invoice_volume_variance', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD settlement_date DATETIME
END
GO



