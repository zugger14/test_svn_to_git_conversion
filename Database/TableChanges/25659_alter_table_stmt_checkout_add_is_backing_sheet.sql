IF COL_LENGTH('stmt_checkout', 'is_backing_sheet') IS  NULL
BEGIN
	ALTER TABLE 
	/**
	Columns 
	is_backing_sheet: is_backing_sheet
	*/
	stmt_checkout ADD is_backing_sheet NCHAR(1)
END
