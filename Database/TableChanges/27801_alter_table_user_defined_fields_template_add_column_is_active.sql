IF COL_LENGTH('user_defined_fields_template', 'is_active') IS  NULL
BEGIN
	ALTER TABLE 
	/**
	Columns 
	is_active: is_active
	*/
	user_defined_fields_template ADD is_active CHAR(1)
END




