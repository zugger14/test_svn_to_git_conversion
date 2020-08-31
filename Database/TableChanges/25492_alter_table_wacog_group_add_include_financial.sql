IF COL_LENGTH(N'wacog_group', N'include_financial') IS NULL
BEGIN
	ALTER TABLE 
	/**
		Columns
		include_financial : Include Financial
	*/
	wacog_group ADD include_financial CHAR(1)
END
GO