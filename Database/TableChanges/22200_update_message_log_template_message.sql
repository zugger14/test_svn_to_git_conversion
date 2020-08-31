IF OBJECT_ID(N'message_log_template', N'U') IS NOT NULL AND COL_LENGTH('message_log_template', 'message') IS NOT NULL
BEGIN
    UPDATE message_log_template
	SET message = 'Data error for <column_name> : <column_value>.'
	WHERE message_number = 10016
END
GO

IF OBJECT_ID(N'message_log_template', N'U') IS NOT NULL AND COL_LENGTH('message_log_template', 'message') IS NOT NULL
BEGIN
    UPDATE message_log_template
	SET message = 'Data error for <column_name> : <column_value> (<column_name1>: <column_value1> for <column_name> : <column_value> is not mapped).'
	WHERE message_number IN (10011, 10015)
END
GO


