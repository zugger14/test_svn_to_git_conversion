IF COL_LENGTH('calc_invoice_volume_variance_estimates', 'invoice_lock') IS NULL
BEGIN
	ALTER TABLE calc_invoice_volume_variance_estimates ADD invoice_lock CHAR(1)
	PRINT 'Column invoice_lock added.'
END