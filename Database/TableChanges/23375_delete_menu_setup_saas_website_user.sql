/* Delete menu Setup SaaS Website User */

SET NOCOUNT ON

-- Delete foreign key and add cascade delete first
DECLARE @constraint_name NVARCHAR(200)

SELECT @constraint_name = [name]
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('favourites_menu')
	AND OBJECT_NAME(referenced_object_id) = 'application_functions'

IF NOT EXISTS ( 
	SELECT 1
	FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
	WHERE constraint_name = @constraint_name
		AND DELETE_RULE = 'CASCADE'
)
BEGIN
	EXEC ('
		ALTER TABLE favourites_menu
		DROP CONSTRAINT ' + @constraint_name
	)

	ALTER TABLE favourites_menu
	ADD CONSTRAINT FK_application_functions_function_id
	FOREIGN KEY (function_id)
	REFERENCES application_functions (function_id)
	ON DELETE CASCADE
END

-- Delete Application UI Template
EXEC spa_application_ui_template @flag = 'd', @application_function_id = '20011300'

-- Delete Privilege
IF EXISTS (SELECT 1 FROM application_functional_users WHERE function_id = 20011300)
BEGIN
	DELETE FROM application_functional_users
	WHERE function_id IN (
		SELECT function_id
		FROM application_functions 
		WHERE function_id = 20011300 
			OR func_ref_id = 20011300
	)
END

-- Delete Application Functions
IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 20011300 OR func_ref_id = 20011300)
BEGIN
	DELETE FROM application_functions
	WHERE func_ref_id = 20011300

	DELETE FROM application_functions
	WHERE function_id = 20011300
END


-- Setup Menu
IF EXISTS (SELECT 1 FROM setup_menu WHERE function_id = 20011300)
BEGIN
	DELETE FROM setup_menu
	WHERE function_id = 20011300
END