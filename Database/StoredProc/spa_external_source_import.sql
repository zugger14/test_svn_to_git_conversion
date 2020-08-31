IF OBJECT_ID(N'spa_external_source_import', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_external_source_import]
 GO 

/*

[spa_external_source_import]	't'
select * from external_source_import
*/
CREATE PROC [dbo].[spa_external_source_import]
	@flag AS CHAR(1) = 's', 
	@source_system_id INT = NULL						
AS 
DECLARE @sql_select VARCHAR(5000)

--check for app admin role 1=true
DECLARE @app_admin_role_check INT
SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())

SET NOCOUNT ON;

IF @flag = 's' 
BEGIN
	SET @sql_select = 'SELECT a.esi_id, a.data_type_id, b.code, b.description 
	                   FROM external_source_import a 
	                   INNER JOIN static_data_value b ON a.data_type_id = b.value_id
	                   WHERE 1 = 1'
	
	IF @source_system_id IS NOT NULL
		SET @sql_select = @sql_select + ' AND a.source_system_id = ' + CAST(@source_system_id AS VARCHAR) 
END
--PRINT(@sql_select)
EXEC(@sql_select)

IF @flag = 't' --used in import data (exclude bulk time parameter)
BEGIN
	SELECT DISTINCT esi.esi_id, esi.data_type_id, sdv.code, sdv.[description], source_system_id
	FROM external_source_import esi
	INNER JOIN static_data_value sdv ON sdv.value_id = esi.data_type_id
	INNER JOIN application_functions af ON af.function_desc = sdv.[description] AND af.function_name LIKE '%Import from Source System%'
	LEFT JOIN application_role_user aru ON aru.user_login_id = dbo.FNADBUser()
	--check to top of hierarchy of function ids
	--10131300: Import Data
	--10131301: Import from Source System
	--10131302: Import from Source System - Book Attribute
	LEFT JOIN application_functional_users afu ON afu.function_id IN (af.function_id, 10131301, 10131300)
		AND (afu.role_id = aru.role_id	--check those functions are assigned to role 
				OR afu.login_id = dbo.FNADBUser()	--check those functions are assigned to user
				--RWE_DE gas concept of ApplicationAdmin role type. Use FNAAppAdminRoleCheck after that feature is merged. 
				---OR dbo.FNAAppAdminID() = dbo.FNADBUser()	--skip check if user is AppAdmin (currently farrms_admin)
				OR @app_admin_role_check = 1 -- check if user has app admin role assigned
		)
	WHERE afu.function_id IS NOT NULL
	ORDER BY esi.data_type_id
END

IF @flag = 'c'
BEGIN
	IF (@app_admin_role_check = 1)
	BEGIN
		SELECT  sdv.value_id, af.function_id
		FROM application_functions af
		INNER JOIN static_data_value sdv ON af.function_desc = sdv.[description] 
		WHERE sdv.value_id = @source_system_id
	END
	ELSE
	BEGIN
		SELECT sdv.value_id, afu.function_id 
		FROM application_functional_users afu
		INNER JOIN application_functions af ON afu.function_id IN (af.function_id, 10131761, 10131700)
		INNER JOIN static_data_value sdv ON sdv.[description] = af.function_desc 
			AND af.function_name LIKE 'Import from System File%' 
		LEFT JOIN application_role_user aru ON aru.role_id = afu.role_id
			
		WHERE sdv.value_id = @source_system_id
			AND (afu.login_id = dbo.FNADBUser() OR aru.user_login_id = dbo.FNADBUser())		
	END
END
