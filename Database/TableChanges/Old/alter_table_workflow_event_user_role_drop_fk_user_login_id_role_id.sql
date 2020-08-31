DECLARE @constraint_name VARCHAR(100) = NULL, @sql VARCHAR(1000)

SELECT @constraint_name = constraint_name
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE table_name = 'workflow_event_user_role'
AND column_name = 'user_login_id'

IF @constraint_name IS NOT NULL
BEGIN
	SET @sql = 'IF EXISTS (
					SELECT 1
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N''' + @constraint_name + ''')
					AND parent_object_id = OBJECT_ID(N''dbo.workflow_event_user_role'')
				)
				BEGIN
					ALTER TABLE workflow_event_user_role
					DROP CONSTRAINT ' + @constraint_name + '
				END'
	EXEC(@sql)
END

SELECT @constraint_name = constraint_name
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE table_name = 'workflow_event_user_role'
AND column_name = 'role_id'

IF @constraint_name IS NOT NULL
BEGIN
	SET @sql = 'IF EXISTS (
					SELECT 1
					FROM sys.foreign_keys 
					WHERE object_id = OBJECT_ID(N''' + @constraint_name + ''')
					AND parent_object_id = OBJECT_ID(N''dbo.workflow_event_user_role'')
				)
				BEGIN
					ALTER TABLE workflow_event_user_role
					DROP CONSTRAINT ' + @constraint_name + '
				END'
	EXEC(@sql)
END