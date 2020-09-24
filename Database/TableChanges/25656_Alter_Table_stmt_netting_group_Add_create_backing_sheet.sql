IF COL_LENGTH('stmt_netting_group', 'create_backing_sheet') IS NULL 
BEGIN 
    ALTER TABLE stmt_netting_group ADD create_backing_sheet NCHAR(1) 
END 