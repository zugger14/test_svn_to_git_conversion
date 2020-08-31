IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_haveMultipleSecurityRights]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_haveMultipleSecurityRights]
GO

-- DROP PROC spa_haveMultipleSecurityRights
-- EXEC spa_haveMultipleSecurityRights '80, 79, 27, 78',NULL,'80,79,101,121,100,111,123'

--This procedure returns if the connected user has security rights for a given privilege
--input is function_id and sub_id
-- If returns is greater than 0 than the user has rights else no rights

CREATE PROC [dbo].[spa_haveMultipleSecurityRights] 	
	@function_id VARCHAR(MAX),
	@sub_id INT = NULL,
	@license_function_id VARCHAR(500) = NULL
AS 

DECLARE @id_count INTEGER
SET @id_count = 0
DECLARE @sql_stmt VARCHAR(MAX)

CREATE TABLE #current_rights(function_id INTEGER)

SET @sql_stmt = 'INSERT INTO #current_rights  
				SELECT distinct application_functional_users.function_id AS function_id
				FROM application_users 
				INNER JOIN application_functional_users ON application_users.user_login_id = application_functional_users.login_id
				WHERE application_functional_users.function_id in ('  + @function_id  + ') 
					AND application_functional_users.role_user_flag = ''u''
					AND application_users.user_login_id = ''' + dbo.FNADBUser() + ''''

IF @sub_id IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.entity_id = ' + @sub_id
END


EXEC(@sql_stmt)
EXEC spa_print @sql_stmt

SET @sql_stmt = 'INSERT INTO #current_rights 
				SELECT distinct application_functional_users.function_id AS function_id
                FROM application_users 
                INNER JOIN application_role_user ON application_users.user_login_id = application_role_user.user_login_id 
                INNER JOIN application_functional_users ON application_role_user.role_id = application_functional_users.role_id
				WHERE application_functional_users.role_user_flag = ''r''
					AND application_users.user_login_id = ''' + dbo.FNADBUser() + '''' + '
					AND application_functional_users.function_id in (' + @function_id + ')' 

IF @sub_id IS NOT NULL 
BEGIN
	SET @sql_stmt = @sql_stmt + ' AND application_functional_users.entity_id = ' + @sub_id
END

EXEC(@sql_stmt)
EXEC spa_print @sql_stmt

--Check License Function
DECLARE @AppAdmin_func VARCHAR(50)
SET @AppAdmin_func = ' af.function_id'

DECLARE @check_admin_role INT
SELECT @check_admin_role = ISNULL(dbo.FNAAppAdminRoleCheck(dbo.FNADBUser()), 0)

DECLARE @check_report_admin_role INT
SELECT @check_report_admin_role = ISNULL(dbo.FNAReportAdminRoleCheck(dbo.FNADBUser()), 0)

DECLARE @check_security_admin_role INT
SELECT @check_security_admin_role = ISNULL(dbo.FNASecurityAdminRoleCheck(dbo.FNADBUser()), 0)

IF @license_function_id IS NOT NULL AND @license_function_id <> ' '
BEGIN
	IF (@check_admin_role = 1) --role based privilege check
	BEGIN
		TRUNCATE TABLE #current_rights
		SET @sql_stmt = 'INSERT INTO #current_rights  
						SELECT function_id 
						FROM application_functions WHERE function_id NOT IN ('  + @license_function_id  + ')'
		SET @AppAdmin_func = '0'
	END
	ELSE
	BEGIN
		SET @sql_stmt = 'UPDATE #current_rights 
						SET function_id = null 
		                WHERE function_id  IN (' + @license_function_id + ')'
	END
	EXEC(@sql_stmt)
END

IF (@check_admin_role = 1) --role based privilege check
BEGIN
	SET @sql_stmt = 'SELECT  DISTINCT af.function_id, ISNULL(cr.function_id,'+@AppAdmin_func +') AS have_rights 
					FROM application_functions af 
					LEFT OUTER JOIN #current_rights cr on cr.function_id = af.function_id 
					WHERE af.function_id IN (' + @function_id + ') '
					
END
ELSE
BEGIN
	SET @sql_stmt = 'SELECT  DISTINCT af.function_id, ISNULL(cr.function_id, 0) AS have_rights 
					FROM application_functions af 
					LEFT OUTER JOIN #current_rights cr on cr.function_id = af.function_id 
					WHERE af.function_id in (' + @function_id + ') '
	
	IF @check_security_admin_role = 1 --check if user has security admin role
	BEGIN
		SET @sql_stmt = @sql_stmt + ' 
						UNION ALL SELECT 10111000, 10111000 --Maintain Users 
						UNION ALL SELECT 10111010, 10111010 --Maintain User Privilege
						UNION ALL SELECT 10111011, 10111011 --Insert Roles
						UNION ALL SELECT 10111012, 10111012 --Delete Roles
						UNION ALL SELECT 10111013, 10111013 --Change Password
						UNION ALL SELECT 10111016, 10111016 --Maintain User Insert
						UNION ALL SELECT 10111017, 10111017 --Maintain User Update
						UNION ALL SELECT 10111018, 10111018 --Delete User
						UNION ALL SELECT 10111100, 10111100 --Maintain Roles
						UNION ALL SELECT 10111110, 10111110 --Maintain Roles IU
						UNION ALL SELECT 10111111, 10111111 --Delete Role
						UNION ALL SELECT 10111112, 10111112 --Delete Role
						UNION ALL SELECT 10111014, 10111014 --Insert User Privilege
						UNION ALL SELECT 10111015, 10111015 --Delete User Privilege
						UNION ALL SELECT 10111113, 10111113 --Insert Role Privilege
						UNION ALL SELECT 10111114, 10111114 --Delete Role Privilege ' 
	END
	IF  @check_report_admin_role = 1 
	     BEGIN
	     	SET @sql_stmt = @sql_stmt + ' 
	     				UNION ALL SELECT 10201000, 10201000  --Report Writer 
	     				UNION ALL SELECT 10201010, 10201010 --Report Writer IU
						UNION ALL SELECT 10201011, 10201011 --Delete Report Writer
						UNION ALL SELECT 10201012, 10201012 --Report Writer View 		
						UNION ALL SELECT 10201013, 10201013 --Report Writer View IU
						UNION ALL SELECT 10201014, 10201014 --Report Writer Column IU						
						UNION ALL SELECT 10201015, 10201015 --Report Writer Privileges
						
						UNION ALL SELECT 10201800, 10201800 --Report Group Manager
						UNION ALL SELECT 10201810, 10201810 --Report Group Manager Name IU
						UNION ALL SELECT 10201811, 10201811 --Report Group Manager Name Delete
						UNION ALL SELECT 10201812, 10201812 --Report Group Manager IU
						UNION ALL SELECT 10201813, 10201813 --Report Group Manager Delete
						UNION ALL SELECT 10201814, 10201814 --Report Group Manager Parameter IU
						UNION ALL SELECT 10201815, 10201815 --Report Group Manager Parameter Delete
						
						UNION ALL SELECT 10201700, 10201700 --Run Report Group
						
						UNION ALL SELECT 10201612, 10201612 --Report Manager Privilege
						UNION ALL SELECT 10201600, 10201600 --Report Manager
						UNION ALL SELECT 10201610, 10201610	--Report Manager IU
						UNION ALL SELECT 10201611, 10201611	--Report Manager Delete
						UNION ALL SELECT 10201613, 10201613 --Report Manager Export Type
						UNION ALL SELECT 10201624, 10201624 --Report Manager Datasource List
						UNION ALL SELECT 10201633, 10201633 --Report Manager View
						UNION ALL SELECT 10201634, 10201634 --Report Manager View IU
						UNION ALL SELECT 10201635, 10201635 --Report Manager Writer Copy
						UNION ALL SELECT 10201638, 10201638 --Report Paramset Privilege
																																		
						UNION ALL SELECT 10201615, 10201615 --Report Maker Dataset IU
						UNION ALL SELECT 10201616, 10201616	--Report Maker Dataset Delete
						UNION ALL SELECT 10201617, 10201617	--Report Maker page IU
						UNION ALL SELECT 10201622, 10201622	--Report page Parameterset IU
						UNION ALL SELECT 10201623, 10201623	--Report page Parameterset Delete
						UNION ALL SELECT 10201629, 10201629	--Report Page Chart IU
						UNION ALL SELECT 10201630, 10201630	--Report Page Chart Delete
						UNION ALL SELECT 10201631, 10201631	--Report Page Tablix IU
						UNION ALL SELECT 10201632, 10201632	--Report Page Tablix Delete
						UNION ALL SELECT 10201618, 10201618	--Report Maker page Delete
						UNION ALL SELECT 10201619, 10201619 --Report Dataset IU save
						UNION ALL SELECT 10201620, 10201620 --Report Dataset IU
						UNION ALL SELECT 10201621, 10201621 --Report Dataset IU Delete
						UNION ALL SELECT 10201628, 10201628 --Report Dataset IU Relationship
						UNION ALL SELECT 10201636, 10201636 --Report Dataset IU Ok
						
						--UNION ALL SELECT 10111000, 10111000 --Maintain Users
						'	     	
	     END
	ELSE 
		SET @sql_stmt = @sql_stmt + '--UNION ALL SELECT 10111000, 1  --Maintain Users 
									UNION ALL SELECT 10111013, 10111013 --Change Password
									UNION ALL SELECT 10111017, 10111017 --Maintain User Update'
END

SET @sql_stmt = @sql_stmt + ' 
						UNION ALL 
						SELECT func_id,0 
						FROM application_functions_unique_id 
						WHERE func_id in (' + @function_id + ') 
							AND func_id NOT IN (SELECT function_id FROM application_functions)'
exec spa_print @sql_stmt

IF @function_id IS NULL
	SELECT  NULL function_id,  NULL have_rights 
ELSE
BEGIN
	EXEC spa_print @sql_stmt
	EXEC(@sql_stmt)
END