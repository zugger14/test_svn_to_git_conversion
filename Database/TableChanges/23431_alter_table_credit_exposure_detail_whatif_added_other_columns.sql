IF COL_LENGTH('credit_exposure_detail_whatif', 'other_ap_prior') IS NULL
BEGIN
	ALTER TABLE dbo.credit_exposure_detail_whatif ADD
		other_ap_prior FLOAT,	
		other_ap_current FLOAT,	
		other_ar_prior FLOAT,	
		other_ar_current FLOAT,	
		other_bom_exposure_to_us FLOAT,	
		other_bom_exposure_to_them FLOAT,	
		other_mtm_exposure_to_us FLOAT,	
		other_mtm_exposure_to_them FLOAT

	PRINT 'Columns are added.'
END
ELSE PRINT 'Columns are already exist.'