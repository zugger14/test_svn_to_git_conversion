IF EXISTS(SELECT 1 
		FROM sys.objects
		WHERE OBJECT_NAME(parent_object_id) = 'admin_email_configuration'
			AND OBJECT_NAME(OBJECT_ID) = 'FK_admin_email_configuration_static_data_value')
BEGIN 
	ALTER TABLE admin_email_configuration
	DROP CONSTRAINT FK_admin_email_configuration_static_data_value
END

IF EXISTS(select 1 
			FROM sys.objects
			WHERE OBJECT_NAME(parent_object_id) = 'admin_email_configuration'
				AND OBJECT_NAME(OBJECT_ID) = 'PK_admin_email_configuration')
BEGIN 
	ALTER TABLE admin_email_configuration
	DROP CONSTRAINT PK_admin_email_configuration
END


IF COL_LENGTH('admin_email_configuration', 'cust_id') IS NOT NULL
BEGIN
    ALTER TABLE admin_email_configuration DROP COLUMN cust_id
	ALTER TABLE admin_email_configuration ADD admin_email_configuration_id INT IDENTITY(1, 1) NOT NULL
END
GO