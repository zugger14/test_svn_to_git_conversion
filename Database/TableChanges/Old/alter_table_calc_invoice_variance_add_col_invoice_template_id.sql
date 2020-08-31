IF COL_LENGTH('calc_invoice_volume_variance', 'invoice_template_id') IS NULL
BEGIN
    ALTER TABLE calc_invoice_volume_variance ADD invoice_template_id INT
END
GO