IF NOT EXISTS(SELECT 1 FROM ixp_tables where ixp_tables_name = 'ixp_calc_invoice_volume_variance')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		Values('ixp_calc_invoice_volume_variance','Calc Invoice Volume Variance','i')

END
ELSE 
	PRINT 'Table already exists'

