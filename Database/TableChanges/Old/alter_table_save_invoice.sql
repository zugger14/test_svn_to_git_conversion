
IF COL_LENGTH('save_invoice', 'status') IS NOT NULL
BEGIN
	UPDATE save_invoice SET [status] = NULL
    ALTER TABLE save_invoice ALTER COLUMN [status] INT NULL
    UPDATE save_invoice SET [status] = 20700
END
ELSE
	PRINT 'Column status does not exists table save_invoice'
GO