IF COL_LENGTH('stmt_invoice', 'is_backing_sheet') IS NULL 
BEGIN 
    ALTER TABLE stmt_invoice ADD is_backing_sheet NCHAR(1) 
END 