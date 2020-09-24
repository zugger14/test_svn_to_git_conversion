IF COL_LENGTH('stmt_checkout', 'is_backing_sheet') IS  NULL
BEGIN
	ALTER TABLE 
	/**
	Columns 
	aggressor_initiator: aggressor_initiator
	*/
	stmt_checkout ADD is_backing_sheet NCHAR(1)
END

