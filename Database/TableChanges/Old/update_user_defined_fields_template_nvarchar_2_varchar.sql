IF EXISTS (SELECT 1 FROM user_defined_fields_template WHERE data_type IN ('nvarchar(MAX)','nvarchar(50)'))
BEGIN
	UPDATE user_defined_fields_template SET data_type='varchar(150)' WHERE data_type IN ('nvarchar(MAX)','nvarchar(50)')
END