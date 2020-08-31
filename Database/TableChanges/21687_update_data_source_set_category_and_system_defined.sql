IF COL_LENGTH('data_source', 'category') IS NOT NULL
BEGIN
    ALTER TABLE [data_source] 
	ADD DEFAULT '106500' FOR category
END
IF COL_LENGTH('data_source', 'category') IS NOT NULL
BEGIN
   UPDATE data_source
   SET category = 106500
END

IF COL_LENGTH('data_source', 'system_defined') IS NOT NULL
BEGIN
    UPDATE data_source
    SET system_defined = 1
END
