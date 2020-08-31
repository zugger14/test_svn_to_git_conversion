-- SELECT  OBJECT_NAME(dc.parent_object_id) [TABLE],
--                OBJECT_NAME(dc.[object_id]) [Constraint],
--                col_name(dc.parent_object_id,dc.parent_column_id)
--        FROM    sys.sql_dependencies sd
--                LEFT JOIN sys.default_constraints dc ON sd.[object_id] = dc.[object_id]
--        WHERE   sd.referenced_major_id = OBJECT_ID('fnadbuser')
--                AND sd.class = 1
--dropping and adding the default constraints that binds to dbo.fnadbuser
DECLARE @dropconstraints VARCHAR(MAX)
DECLARE @addconstraints VARCHAR(MAX)

SET @dropconstraints = CAST('' AS VARCHAR(MAX))

SELECT @dropconstraints = @dropconstraints + 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.[' + OBJECT_NAME(dc.parent_object_id) + '] DROP CONSTRAINT [' + OBJECT_NAME(dc.[object_id]) + ']'
FROM sys.sql_dependencies sd
INNER JOIN sys.default_constraints dc
	ON sd.[object_id] = dc.[object_id]
INNER JOIN sys.tables t
	ON dc.parent_object_id = t.object_id
		AND t.type = 'U'
WHERE sd.referenced_major_id = OBJECT_ID('fnadbuser')
	AND sd.class = 1

SET @addconstraints = CAST('' AS VARCHAR(MAX))

SELECT @addconstraints = @addconstraints + 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.[' + OBJECT_NAME(dc.parent_object_id) + '] ADD CONSTRAINT [' + OBJECT_NAME(dc.[object_id]) + '] DEFAULT ([dbo].[FNADBUser]()) FOR [' + col_name(dc.parent_object_id, dc.parent_column_id) + ']'
FROM sys.sql_dependencies sd
INNER JOIN sys.default_constraints dc
	ON sd.[object_id] = dc.[object_id]
INNER JOIN sys.tables t
	ON dc.parent_object_id = t.object_id
		AND t.type = 'U'
WHERE sd.referenced_major_id = OBJECT_ID('fnadbuser')
	AND sd.class = 1

--drop default constraints that binds to dbo.fnadbuser
EXEC (@dropconstraints)

IF OBJECT_ID(N'FNADBUser', N'FN') IS NOT NULL
	DROP FUNCTION FNADBUser

EXEC (
	' 
	/**
		Returns context user id.
	*/
	CREATE FUNCTION dbo.FNADBUser()
	RETURNS VARCHAR(100) AS  
	BEGIN 
		DECLARE @user_login VARCHAR(100), @start_index INT
		SET @user_login = system_user
		SET @start_index = CHARINDEX(''\'', @user_login,1)
		SET @user_login = SUBSTRING(@user_login, @start_index + 1, LEN(@user_login) - @start_index + 1)
		SET @user_login = REPLACE(@user_login, '' '', ''_'')

		DECLARE @contextinfo VARCHAR(128)
		SELECT @contextinfo = CONVERT(VARCHAR(128), SESSION_CONTEXT(N''DB_USER''));
		--If Session Context is not used to set app user name, get it from context info as before
		IF (@contextinfo IS NULL) 
			SET @contextinfo = NULLIF(REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, ''''), '''')
		
		RETURN COALESCE(@contextinfo, @user_login)
	END
	'
)

--add original default constraints that binds to dbo.fnadbuser
EXEC (@addconstraints)
GO
