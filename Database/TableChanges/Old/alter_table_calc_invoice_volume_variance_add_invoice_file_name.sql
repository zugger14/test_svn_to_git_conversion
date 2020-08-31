IF COL_LENGTH('calc_invoice_volume_variance', 'invoice_file_name') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD invoice_file_name VARCHAR(200) NULL
END
ELSE
BEGIN
    PRINT 'invoice_file_name Already Exists.'
END 
GO
