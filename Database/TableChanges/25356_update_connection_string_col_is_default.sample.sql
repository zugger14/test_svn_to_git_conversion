/**
	Update is_default with 1 for db_username 'trm_release_db_user'
*/
IF COL_LENGTH('dbo.connection_string', 'is_default') > 0
BEGIN
	UPDATE dbo.connection_string SET is_default = 1 WHERE db_username='trm_release_db_user' 
END
GO