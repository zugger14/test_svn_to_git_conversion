IF COL_LENGTH('EDI_Error_definition','err_critical') IS NULL
BEGIN
	Alter table EDI_Error_definition
		ADD err_critical CHAR(1)  NOT NULL DEFAULT 'n'
END
ELSE 
	PRINT 'Column Already Exists.'