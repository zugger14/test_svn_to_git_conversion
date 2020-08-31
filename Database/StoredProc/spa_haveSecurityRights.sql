IF OBJECT_ID(N'spa_haveSecurityRights', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_haveSecurityRights]
 GO 

-- 

--EXEC spa_haveSecurityRights 81, 1

-- DROP  PROC spa_haveSecurityRights
-- EXEC spa_haveSecurityRights 79

--This procedure returns if the connected user has security rights for a given privilege
--input is function_id and sub_id
-- If returns is greater than 0 than the user has rights else no rights

CREATE PROCEDURE [dbo].[spa_haveSecurityRights]
	@function_id integer,
	 --	@sub_id int=NULL,
	@sub_id VARCHAR(100) = NULL,
	@license_func_id VARCHAR(500) = NULL
AS
	

DECLARE @id_count Integer
SET @id_count = 0
DECLARE @sql_stmt varchar(5000)

CREATE TABLE #count_user
(id_count Integer)

CREATE TABLE #count_role
(id_count Integer)


SET @sql_stmt = 'INSERT INTO #count_user  SELECT COUNT(application_functional_users.login_id) as id_count
FROM       application_users INNER JOIN
           application_functional_users ON application_users.user_login_id = application_functional_users.login_id
WHERE      application_functional_users.function_id = '  + cast(@function_id as varchar) + '
 AND 	   application_functional_users.role_user_flag = ''u''
 AND        application_users.user_login_id = ''' + dbo.FNADBUser() + ''''


If @sub_id IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND (application_functional_users.entity_id IS NULL OR application_functional_users.entity_id IN (' + @sub_id + '))'
--	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.entity_id = ' + CAST(@sub_id as varchar)
END
If @license_func_id IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.function_id not in ( ' +@license_func_id +')'
END

-- Else
-- BEGIN
-- 	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.entity_id IS NULL'
-- END

--SELECT @sql_stmt


exec(@sql_stmt)
--print(@sql_stmt)
--If @@ERROR <> 0
SELECT @id_count = id_count from #count_user

If @id_count > 0
BEGIN
  SELECT @id_count as id_count
END
Else 
BEGIN

SET @sql_stmt = 'INSERT INTO #count_role SELECT     COUNT(application_functional_users.role_id) AS role_id_count
FROM       application_users INNER JOIN
           application_role_user ON application_users.user_login_id = application_role_user.user_login_id INNER JOIN
           application_functional_users ON application_role_user.role_id = application_functional_users.role_id
WHERE      application_functional_users.role_user_flag = ''r''
 AND 	   application_users.user_login_id = ''' + dbo.FNADBUser() + '''' + '
 AND        application_functional_users.function_id = ' + cast(@function_id as varchar)

If @sub_id IS NOT NULL 
BEGIN
--	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.entity_id = ' + cast(@sub_id as varchar)
	SET @sql_stmt = @sql_stmt + ' AND (application_functional_users.entity_id IS NULL OR application_functional_users.entity_id IN (' + @sub_id + '))'
END
If @license_func_id IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.function_id not in ( ' +@license_func_id +')'
END
-- Else
-- BEGIN
-- 	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.entity_id IS NULL'
-- END

exec(@sql_stmt)
--print(@sql_stmt)
SELECT @id_count = id_count from #count_role

SELECT @id_count as id_count
END






