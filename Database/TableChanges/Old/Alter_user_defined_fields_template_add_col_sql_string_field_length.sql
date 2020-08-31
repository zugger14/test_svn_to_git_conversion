IF (Select max_length FROM sys.tables t	INNER JOIN sys.columns c On c.object_id = t.object_id
 WHERE t.name = 'user_defined_fields_template' AND c.name = 'sql_string') <>1000
 BEGIN
 	ALTER TABLE user_defined_fields_template 
	ALTER column sql_string varchar(1000)
END
ELSE PRINT 'sql string column is already modified.'