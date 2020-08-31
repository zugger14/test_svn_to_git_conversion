IF COL_LENGTH('calc_invoice_volume_variance', 'netting_calc_id') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD netting_calc_id INT NULL
END
ELSE
BEGIN
    PRINT 'netting_calc_id Already Exists.'
END 
GO
