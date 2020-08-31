IF COL_LENGTH('application_users', 'menu_type_role_id') IS NULL
BEGIN
    ALTER TABLE application_users ADD menu_type_role_id INT
END
GO


--UPDATE application_users
--SET menu_type_role_id=65
--WHERE user_login_id = 'farrms_admin'
