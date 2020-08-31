IF COL_LENGTH('stmt_invoice', 'lock_status') IS NULL
BEGIN
	 /**
	  Add column lock_status
	*/
	 ALTER TABLE stmt_invoice ADD lock_status CHAR(1)
END
GO


