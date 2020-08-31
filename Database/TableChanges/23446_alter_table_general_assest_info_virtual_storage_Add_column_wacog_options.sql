IF COL_LENGTH(N'general_assest_info_virtual_storage', 'wacog_option') IS NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		wacog_option : WACOG Option
	*/
	general_assest_info_virtual_storage ADD wacog_option INT

	PRINT 'Added columns wacog_option.'
END
GO