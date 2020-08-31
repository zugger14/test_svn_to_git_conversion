IF NOT EXISTS (SELECT 1 FROM application_security_role WHERE role_name = 'Priority SaaS User')
BEGIN
	INSERT INTO application_security_role (
		  role_name
		, role_description
		, role_type_value_id
	)
	VALUES (
		  'Priority SaaS User'
		, 'User who will be able to login even when concurrent login has been exceeded'
		, 23
	)
END