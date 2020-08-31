IF COL_LENGTH('dbo.connection_string', 'system_defined_password') IS NOT NULL
BEGIN
	UPDATE connection_string
	SET system_defined_password = 'piAJT49noFyT2' --Currently default used for testing purpose (Pioneer@123)
END
