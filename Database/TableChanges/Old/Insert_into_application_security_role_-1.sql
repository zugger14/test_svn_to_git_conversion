IF NOT EXISTS(SELECT 'X' FROM application_security_role WHERE role_id=-1)
BEGIN
	SET IDENTITY_INSERT application_security_role ON
	
	INSERT INTO application_security_role(role_id,role_name,role_description,role_type_value_id)
	SELECT -1,'All','All',4

	SET IDENTITY_INSERT application_security_role OFF
END
