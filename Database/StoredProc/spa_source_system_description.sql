IF OBJECT_ID(N'spa_source_system_description', N'P') IS NOT NULL
    DROP PROCEDURE spa_source_system_description
 GO
 
CREATE PROC [dbo].[spa_source_system_description]
	@flag AS CHAR(1),
	@function_id VARCHAR(100) = NULL
						
AS 
DECLARE @Sql_Select     VARCHAR(5000)
DECLARE @user_login_id  VARCHAR(100)


SET @user_login_id = dbo.FNAdbuser()

--check for app admin role 1=true
DECLARE @app_admin_role_check INT
SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@user_login_id)

IF @function_id IS NOT NULL
   AND @app_admin_role_check <> 1
BEGIN
    CREATE TABLE #temp_function (
    	function_id       INT,
    	source_system_id  INT
    ) 
    -- first populate all the privileges where entity id is null		
    INSERT INTO #temp_function(function_id, source_system_id)
    SELECT DISTINCT function_id,
           source_system_id
    FROM   (
               SELECT afu.function_id,
                      fs.source_system_id
               FROM   application_functional_users afu
               FULL OUTER JOIN portfolio_hierarchy ph
                   ON  ph.hierarchy_level = 2
                   AND ph.entity_id <> -1
               LEFT OUTER JOIN application_role_user aru
                   ON  aru.role_id = afu.role_id
                   AND afu.role_user_flag = 'r'
               LEFT OUTER JOIN portfolio_hierarchy ph1
                   ON  ph1.parent_entity_id = ph.entity_id
                   AND ph1.hierarchy_level = 1
               LEFT OUTER JOIN fas_strategy fs ON  fs.fas_strategy_id = ph1.entity_id
               WHERE  function_id = @function_id
                      AND afu.entity_id IS NULL
                      AND ISNULL(afu.login_id, aru.user_login_id) = @user_login_id
               
               UNION
               SELECT afu.function_id,
                      fs.source_system_id
               FROM   application_functional_users afu
                      LEFT OUTER JOIN portfolio_hierarchy ph
                           ON  ph.entity_id = afu.entity_id
                           AND ph.hierarchy_level = 2
                      LEFT OUTER JOIN portfolio_hierarchy ph1
                           ON  ph1.parent_entity_id = ph.entity_id
                           AND ph1.hierarchy_level = 1
                      LEFT OUTER JOIN application_role_user aru
                           ON  aru.role_id = afu.role_id
                           AND afu.role_user_flag = 'r'
                      LEFT OUTER JOIN fas_strategy fs
                           ON  fs.fas_strategy_id = ph1.entity_id
               WHERE  function_id = @function_id
                      AND afu.entity_id IS NOT NULL
                      AND ISNULL(afu.login_id, aru.user_login_id) = @user_login_id
           ) a
    
    SELECT ssd.source_system_id,
           ssd.source_system_name
    FROM   #temp_function tmp
    INNER JOIN source_system_description ssd ON  tmp.source_system_id = ssd.source_system_id
END
ELSE
BEGIN
    SET @Sql_Select = 'SELECT source_system_id,
                              source_system_name
                       FROM   source_system_description
                       ORDER BY source_system_id DESC
				'
    EXEC (@Sql_Select)
END

