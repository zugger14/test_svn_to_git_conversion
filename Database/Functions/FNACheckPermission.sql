IF OBJECT_ID(N'dbo.FNACheckPermission') IS NOT NULL
    DROP FUNCTION dbo.FNACheckPermission
GO

-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2015-04-10
-- Description: Parse xml to json.
 
-- Params:
-- @function_id VARCHAR(20) Application Funcion ID 
-- SELECT dbo.FNACheckPermission(10201610)
-- ===============================================================================================================

CREATE FUNCTION dbo.FNACheckPermission (
	@function_id  VARCHAR(20)
)
RETURNS NCHAR(1)
WITH 
EXECUTE AS CALLER
AS
BEGIN
	DECLARE @user_name VARCHAR(500) = dbo.FNADBUser()
	DECLARE @has_permission NCHAR(1) = 'n'
	DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_name, 1)
	DECLARE @check_security_admin_role INT = ISNULL(dbo.FNASecurityAdminRoleCheck(@user_name), 0)
	DECLARE @check_report_admin_role INT = ISNULL(dbo.FNAReportAdminRoleCheck(@user_name), 0)
	DECLARE @check_import_admin_role INT = ISNULL([dbo].[FNAImportAdminRoleCheck](@user_name), 0)
	
	DECLARE @current_rights TABLE(
		function_id INT 
	)
	
	DECLARE @current_report_rights INT
	
	IF @check_security_admin_role = 1 --By default security admin role should have full privilege. 
	BEGIN
		INSERT INTO @current_rights  
		SELECT 10111000			    --Maintain Users 
		UNION ALL SELECT 10111011	--User Add
		UNION ALL SELECT 10111012	--User Save
		UNION ALL SELECT 10111013	--User Change Password
		UNION ALL SELECT 10111014	--User Delete
		UNION ALL SELECT 10111015	--User Role
		UNION ALL SELECT 10111016	--Add User Role
		UNION ALL SELECT 10111017	--Delete User Role
		UNION ALL SELECT 10111030	--User Privilege
		UNION ALL SELECT 10111031	--Add User Privilege
		UNION ALL SELECT 10111032	--Delete User Privilege
		UNION ALL SELECT 10111200	--Setup Workflow(Customize Menu)
		UNION ALL SELECT 10111211	--Add/Save/Delete Setup Workflow(Customize Menu)
		UNION ALL SELECT 10111100	--Setup Role
		UNION ALL SELECT 10111110	--Setup Role Add/save
		UNION ALL SELECT 10111111	--Setup Role Delete
		UNION ALL SELECT 10111115	--Role User
		UNION ALL SELECT 10111116   --Role User Add/Save
		UNION ALL SELECT 10111117	--Role User Delete
		UNION ALL SELECT 10111130	--Role Privilege
		UNION ALL SELECT 10111131	--Role Privilege Add/Save
		UNION ALL SELECT 10111132	--Role Privilege Delete
	END	
	
	IF @check_import_admin_role = 1 --Added for import admin
	BEGIN
		INSERT INTO @current_rights  	
		SELECT 10201900 UNION ALL	--Data Import/Export Audit Report
		SELECT 10202100 UNION ALL	--Message Board Log Report
		SELECT 10201500 UNION ALL	--Static Data Audit Report
		SELECT 10104810 UNION ALL	--Data Import Add/Save
		SELECT 10104811 UNION ALL	--Data Import Delete
		SELECT 10104812 UNION ALL	--Data Import Run
		SELECT 10106300 UNION ALL	--Data Import View
		SELECT 10101610 UNION ALL	--View Scheduled Job Delete
		SELECT 10101601 UNION ALL	--View Scheduled Job Edit
		SELECT 10101611 UNION ALL	--View Scheduled Job Run
		SELECT 10101600				--View Scheduled Job View
	END	

	IF @check_report_admin_role = 1 --By default report admin role should have full privilege. 
	BEGIN
    	
		;WITH List (function_id, func_ref_id, Lvl)
			AS
			(
				SELECT a.function_id, a.func_ref_id,1 AS Lvl
				FROM application_functions a WHERE function_id = @function_id
				UNION all
				SELECT a.function_id, a.func_ref_id,Lvl + 1
				FROM application_functions a 
				INNER JOIN List l ON  a.function_id = l.func_ref_id 
			)
		
		 --10201600 [Report Manager Old] 
		 --10202200 [View Report]
		 --10202500 [Report Manager DHX]
		 --10201800 [Report Group Manager]
		 --10202600 [Excel Addin Report Manager]
		SELECT @current_report_rights = function_id FROM List WHERE function_id IN (10201600,10202200,10202500,10201800,10202600)
	END	
						
	IF @is_admin = 1 OR  EXISTS (SELECT 1 FROM @current_rights WHERE function_id = @function_id ) OR @current_report_rights IS NOT NULL
	BEGIN
		SET @has_permission = 'y'
	END
	ELSE
	BEGIN
		SELECT @has_permission = CASE WHEN afu.functional_users_id IS NOT NULL THEN 'y' ELSE 'n' END
		FROM   application_users au
		INNER JOIN application_functional_users afu 
			ON  afu.login_id = au.user_login_id
			AND afu.function_id = @function_id
		WHERE  au.user_login_id = @user_name
	
		IF @has_permission = 'n'
		BEGIN
			IF EXISTS (
				SELECT 1 
				FROM application_users au
				INNER JOIN application_role_user aru ON aru.user_login_id = au.user_login_id
				INNER JOIN application_functional_users afu ON afu.role_id = aru.role_id AND afu.function_id = @function_id
				WHERE au.user_login_id = @user_name
			)
			BEGIN
				SET @has_permission = 'y'
			END
		END
	END	

	-- Remove permission if user is read-only and the menu/privilege is not read-only
	IF @is_admin <> 1
	AND EXISTS( SELECT 1
				FROM application_functions
				WHERE function_id = @function_id
					AND deny_privilege_to_read_only_user = 1 )
	BEGIN
		SET @has_permission = 'n'
	END
	
	RETURN @has_permission
END