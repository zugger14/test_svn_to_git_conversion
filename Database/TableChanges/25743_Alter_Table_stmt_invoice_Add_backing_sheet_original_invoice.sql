IF COL_LENGTH('stmt_invoice', 'backing_sheet_original_invoice') IS NULL
BEGIN
	ALTER TABLE
	/**
        Columns
        stmt_invoice : backing_sheet_original_invoice 
    */
	 stmt_invoice ADD backing_sheet_original_invoice INT NULL
END
ELSE 
	PRINT('Column backing_sheet_original_invoice already exists')	
GO