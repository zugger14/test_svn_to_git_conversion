SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (22, 1, 'Regulatory Submission', 'Regulatory Submission', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 22 - Regulatory Submission.'
END
ELSE
BEGIN
    PRINT 'Static data value 22 - Regulatory Submission already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS (SELECT 1 FROM application_security_role WHERE role_name = 'Regulatory Submission' AND role_type_value_id = 22)
BEGIN
	INSERT INTO application_security_role(role_name, role_description, role_type_value_id)
	SELECT 'Regulatory Submission', 'Regulatory Submission', 22
END
ELSE
BEGIN
    PRINT 'Role Type Regulatory Submission with Role type value id 22 already EXISTS.'
END