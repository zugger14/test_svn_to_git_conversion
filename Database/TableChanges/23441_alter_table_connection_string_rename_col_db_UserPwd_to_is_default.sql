/**
	Rename column 'db_UserPwd' to 'is_default' in connection_string table.
*/
IF COL_LENGTH('dbo.connection_string', 'db_UserPwd') > 0
BEGIN
	EXEC sp_rename 'dbo.connection_string.db_UserPwd', 'is_default'; 
END
 
GO
