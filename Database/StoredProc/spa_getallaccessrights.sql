
IF OBJECT_ID('dbo.spa_getallaccessrights','p') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_getallaccessrights]
GO 

CREATE PROCEDURE [dbo].[spa_getallaccessrights]
	@flag CHAR(1),
	@role_id INT = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@product_id INT = 10000000
AS

DECLARE @rw_function_id INT
DECLARE @rm_function_id INT
--DECLARE @deal_template_function_id INT
	
SET @rw_function_id = 10201012 --function id for Report Writer View
SET @rm_function_id = 10201633 --function id for Report Manager View
--SET spa_AccessRights = 10101410 --deal template function id

IF @flag = 's' AND @role_id IS NOT NULL 
BEGIN
	SELECT PrivilegeID [Privilege ID], ViewID, report_manager_view_id, [Entity Type], Entity, [Function Name]  
	FROM (SELECT	a.function_id, a.functional_users_id AS AppFuncID, -1 AS ViewID, -1 AS report_manager_view_id, a.functional_users_id AS PrivilegeID, 
					CASE WHEN c.entity_name IS NULL THEN 'Subsidiary\\Strategy\\Book' 
					ELSE CASE hierarchy_level WHEN 0 THEN 'Book' WHEN 1 THEN 'Strategy' WHEN 2 THEN 'Subsidiary' END 
					END 'Entity Type',			
					CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity, 
					(cast(b.function_id as varchar) + ': ' + b.function_name) AS [Function Name]
		FROM application_functional_users a 
		INNER JOIN application_functions b ON a.function_id = b.function_id 
		LEFT JOIN portfolio_hierarchy c ON a.entity_id = c.entity_id
		WHERE ((b.function_id <> @rw_function_id ) OR (b.function_id <> @rm_function_id ))
			AND a.role_id = @role_id 		

		UNION ALL

		SELECT  a.function_id, -1 AS AppFuncID, a.functional_users_id AS ViewID, -1 AS report_manager_view_id, -1 AS PrivilegeID,
			CASE WHEN c.entity_name IS NULL THEN 'Subsidiary\\Strategy\\Book' 
					ELSE CASE hierarchy_level WHEN 0 THEN 'Book' WHEN 1 THEN 'Strategy' WHEN 2 THEN 'Subsidiary' END 
			END 'Entity Type',			
			CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity,
		CAST(@rw_function_id AS varchar) + ' : Report Writer View=>' + (CASE WHEN LTRIM(RTRIM(ISNULL(rw.table_alias, ''))) = '' THEN table_name ELSE table_alias END)
		FROM  report_writer_view_users a 
		LEFT  JOIN portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN report_writer_table rw ON rw.id = a.function_id
		WHERE (a.role_id = @role_id)
		
		--for report manager view privileges
		UNION ALL

		SELECT  a.data_source_id, -1 AS AppFuncID, -1 AS ViewID, a.functional_users_id AS report_manager_view_id, -1 AS PrivilegeID,
			CASE WHEN c.entity_name IS NULL THEN 'Subsidiary\\Strategy\\Book' 
					ELSE CASE hierarchy_level WHEN 0 THEN 'Book' WHEN 1 THEN 'Strategy' WHEN 2 THEN 'Subsidiary' END 
			END 'Entity Type',			
			CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity,
		CAST(@rm_function_id AS varchar) + ' : Report Manager View=>' + (CASE WHEN LTRIM(RTRIM(ISNULL(ds.alias, ''))) = '' THEN ds.name ELSE ds.alias END)
		FROM  report_manager_view_users a 
		LEFT  JOIN portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN data_source ds ON ds.data_source_id = a.data_source_id
		WHERE (a.role_id = @role_id)
		

	) f ORDER BY f.Entity, f.function_id, f.ViewID	
END
ELSE IF @flag='s' and @user_login_id IS NOT NULL 
BEGIN
	--SELECT role_id FROM dbo.FNAGetUserRole(@user_login_id)
	SELECT PrivilegeID [Privilege ID], ViewID [View ID], report_manager_view_id [Report Manager View ID], [Entity Type], Entity, [Role], [Function Name]
	FROM (SELECT	DISTINCT a.function_id, a.functional_users_id AS AppFuncID, -1 AS ViewID, -1 AS report_manager_view_id, a.functional_users_id AS PrivilegeID,
					CASE WHEN c.entity_name IS NULL THEN 'Subsidiary\\Strategy\\Book' 
						ELSE CASE hierarchy_level WHEN 0 THEN 'Book' WHEN 1 THEN 'Strategy' WHEN 2 THEN 'Subsidiary' END 
					END 'Entity Type', 
					CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity, 
					CAST(b.function_id AS VARCHAR(8)) + ' : ' + SUBSTRING(b.function_path, CHARINDEX('=>', b.function_path) + 2, LEN(b.function_path)) AS [Function Name]
					, CASE WHEN asr.role_name IS NULL THEN 'User' ELSE asr.role_name END AS [Role]
		FROM        application_functional_users a 
		--INNER JOIN application_functions_trm b ON a.function_id = b.function_id 
		INNER JOIN  [dbo].FNAApplicationFunctionsHierarchy(@product_id) b ON a.function_id = b.function_id
		LEFT JOIN  portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN application_security_role asr ON asr.role_id = a.role_id
		WHERE b.function_id <> @rw_function_id 
			AND a.login_id = @user_login_id OR a.role_id IN(SELECT role_id FROM dbo.FNAGetUserRole(@user_login_id))		

		UNION  ALL
			
		SELECT  DISTINCT a.function_id, -1 AS AppFuncID, a.functional_users_id AS ViewID, -1 AS report_manager_view_id, -1 AS PrivilegeID,
				CASE WHEN c.entity_name IS NULL THEN 'Subsidiary\\Strategy\\Book' 
				ELSE CASE hierarchy_level WHEN 0 THEN 'Book' WHEN 1 THEN 'Strategy' WHEN 2 THEN 'Subsidiary' END 
				END 'Entity Type',
				CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity,   
				CAST(@rw_function_id AS varchar) + ' : Report Writer View=>' + (CASE WHEN LTRIM(RTRIM(ISNULL(rw.table_alias, ''))) = '' THEN table_name ELSE table_alias END)
				, CASE WHEN asr.role_name IS NULL THEN 'User' ELSE asr.role_name END AS [Role]
		FROM  report_writer_view_users a 
		LEFT  JOIN portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN report_writer_table rw ON rw.id = a.function_id
		LEFT JOIN application_security_role asr ON asr.role_id = a.role_id
		WHERE a.login_id = @user_login_id OR a.role_id IN(SELECT role_id FROM dbo.FNAGetUserRole(@user_login_id))
		
		--for report manager view users
		UNION  ALL
			
		SELECT  DISTINCT a.data_source_id, -1 AS AppFuncID, -1 AS ViewID, a.functional_users_id AS report_manager_view_id, -1 AS PrivilegeID,
				CASE WHEN c.entity_name IS NULL THEN 'Subsidiary\\Strategy\\Book' 
				ELSE CASE hierarchy_level WHEN 0 THEN 'Book' WHEN 1 THEN 'Strategy' WHEN 2 THEN 'Subsidiary' END 
				END 'Entity Type',
				CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity,   
				CAST(@rm_function_id AS varchar) + ' : Report Manager View=>' + (CASE WHEN LTRIM(RTRIM(ISNULL(ds.alias, ''))) = '' THEN ds.name ELSE ds.alias END)
				, CASE WHEN asr.role_name IS NULL THEN 'User' ELSE asr.role_name END AS [Role]
		FROM  report_manager_view_users a 
		LEFT  JOIN portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN data_source ds ON ds.data_source_id = a.data_source_id
		LEFT JOIN application_security_role asr ON asr.role_id = a.role_id
		WHERE a.login_id = @user_login_id OR a.role_id IN(SELECT role_id FROM dbo.FNAGetUserRole(@user_login_id))
		
	) f ORDER BY f.Entity, f.function_id, f.ViewID


	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, 'Functional Rights', 
					'spa_getallaccessrights', 'DB Error', 
					'Failed to select all access rights for the User/Role.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'All Entities', 
					'spa_getallaccessrights', 'Success', 
					'Function access rights sucessfully selected.', ''	
END	
ELSE IF @flag='a' and @user_login_id IS NOT NULL 
BEGIN
	DECLARE @sql VARCHAR(8000)
	
	IF OBJECT_ID('tempdb..#app_func') IS NOT NULL 
	BEGIN 
		DROP TABLE #app_func
	END

	CREATE TABLE #app_func(display_name VARCHAR(MAX) COLLATE DATABASE_DEFAULT, function_path VARCHAR(MAX) COLLATE DATABASE_DEFAULT, depth INT, function_id INT, menu_order VARCHAR(MAX) COLLATE DATABASE_DEFAULT, parent_menu_id INT)

	IF OBJECT_ID('tempdb..#get_parent_id_menu_order') IS NOT NULL 
	BEGIN 
		DROP TABLE #get_parent_id_menu_order
	END


	CREATE TABLE #get_parent_id_menu_order(parent_id INT, new_order VARCHAR(MAX) COLLATE DATABASE_DEFAULT, function_id INT, depth INT)

	INSERT INTO #app_func
	SELECT a.display_name,function_path, depth, a.function_id, CAST(menu_order as varchar(100)), sm.parent_menu_id
	--FROM [dbo].[application_functions_trm] a
	FROM [dbo].FNAApplicationFunctionsHierarchy(@product_id) a
	LEFT JOIN setup_menu sm on sm.function_id = a.function_id
		AND product_category = @product_id
	ORDER BY menu_order

	--/*
	DECLARE @depth INT
	DECLARE @af_depth CURSOR
	SET @af_depth = CURSOR FOR
	SELECT DISTINCT depth
	FROM #app_func
	WHERE depth > 2
		AND menu_order IS NULL 
		ORDER BY depth 
	OPEN @af_depth
	FETCH NEXT
	FROM @af_depth INTO @depth
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #get_parent_id_menu_order
		SELECT CASE WHEN a.parent_menu_id IS NULL THEN af.func_ref_id ELSE   a.parent_menu_id END parent_id,
			  CAST(b.menu_order AS VARCHAR(1000)) + '.' +  CAST(ROW_NUMBER() OVER(ORDER BY a.function_id) AS VARCHAR(2000)) new_order,
			  a.function_id,
			  @depth
		FROM #app_func a
		INNER JOIN application_functions af ON af.function_id = a.function_id
		INNER JOIN #app_func b on b.function_id = af.func_ref_id
		WHERE a.menu_order IS NULL 
			AND a.depth = @depth
			AND a.function_id not like '12______'
			--select @depth
	
		UPDATE a
		SET a.menu_order = b.new_order,
			a.parent_menu_id = b.parent_id
		FROM #app_func a
		INNER join #get_parent_id_menu_order b On b.function_id = a.function_id
	FETCH NEXT
	FROM @af_depth INTO @depth
	END
	CLOSE @af_depth
	DEALLOCATE @af_depth

	--collect privileges
	SET @rw_function_id = 10201012 --function id for Report Writer View
	SET @rm_function_id = 10201633 --function id for Report Manager View

	IF OBJECT_ID('tempdb..#user_privilege') IS NOT NULL 
	BEGIN 
		DROP TABLE #user_privilege
	END

	CREATE TABLE #user_privilege(function_id INT, entity VARCHAR(100) COLLATE DATABASE_DEFAULT, hierarchy_level INT,	[Role] VARCHAR(100) COLLATE DATABASE_DEFAULT, login_id VARCHAR(100) COLLATE DATABASE_DEFAULT)

	INSERT INTO #user_privilege
	SELECT function_id, entity, hierarchy_level,	Role,	login_id
	FROM (
		SELECT a.function_id, 
				CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity, 
				hierarchy_level,
				CASE WHEN asr.role_name IS NULL THEN 'User' ELSE asr.role_name END AS [Role],
				login_id
		FROM application_functional_users a
		LEFT JOIN  portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN application_security_role asr ON asr.role_id = a.role_id
		WHERE 1 = 1 
			AND a.function_id <> @rw_function_id 
			AND a.login_id = @user_login_id OR a.role_id IN(SELECT role_id FROM dbo.FNAGetUserRole(@user_login_id))	
	
		UNION ALL
	
		SELECT a.function_id, 
				CASE WHEN c.entity_name IS NULL THEN 'All' ELSE c.entity_name END AS Entity, 
				hierarchy_level,
				CASE WHEN asr.role_name IS NULL THEN 'User' ELSE asr.role_name END AS [Role],
				login_id
		FROM  report_writer_view_users a 
		LEFT  JOIN portfolio_hierarchy c ON a.entity_id = c.entity_id
		LEFT JOIN report_writer_table rw ON rw.id = a.function_id
		LEFT JOIN application_security_role asr ON asr.role_id = a.role_id
		WHERE a.login_id = @user_login_id OR a.role_id IN(SELECT role_id FROM dbo.FNAGetUserRole(@user_login_id))

	) a

	--pivot to get hierarchy
	IF OBJECT_ID('tempdb..#user_privilege_pivot') IS NOT NULL 
	BEGIN 
		DROP TABLE #user_privilege_pivot
	END

	CREATE TABLE #user_privilege_pivot([sub] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [stra] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [book] VARCHAR(1000) COLLATE DATABASE_DEFAULT,	[Role] VARCHAR(100) COLLATE DATABASE_DEFAULT, [login_id] VARCHAR(100) COLLATE DATABASE_DEFAULT, [function_id] INT)

	INSERT INTO #user_privilege_pivot
	SELECT  [0] [sub], [1] [stra], [2] [book], [Role], [login_id], [function_id]
	FROM (SELECT hierarchy_level,
			STUFF((SELECT ', ' + entity
				FROM #user_privilege 
				WHERE (hierarchy_level = Results.hierarchy_level) 
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)'), 1, 2, '') AS entity
			, MAX(function_id) function_id
			, MAX(Role) [role]
			, MAX(login_id) login_id
		FROM #user_privilege Results
		GROUP BY hierarchy_level, [function_id]) p
	PIVOT
	(MIN (entity) FOR hierarchy_level IN ([0], [1], [2])) AS pvt;

	SELECT [Function],  Subsidiary,  Strategy,  Book, Role, menu_order
	FROM (
	SELECT af.display_name [Function], 
			CASE WHEN af.depth = 1 THEN '' ELSE CASE WHEN upp.sub IS NULL THEN 'All' ELSE upp.sub END END Subsidiary, 
			CASE WHEN af.depth = 1 THEN '' ELSE CASE WHEN upp.stra IS NULL THEN 'All' ELSE upp.stra END END Strategy, 
			CASE WHEN af.depth = 1 THEN '' ELSE CASE WHEN upp.book IS NULL THEN 'All' ELSE upp.book END END Book, 
			upp.Role, 
			menu_order,
			af.function_id
	FROM #app_func af
	INNER JOIN #user_privilege_pivot upp ON upp.function_id = af.function_id
	WHERE (upp.role IS NOT NULL)
			and upp.function_id NOT LIKE '12______'

	UNION ALL 

	SELECT display_name [Function], '' Subsidiary, '' Strategy, '' Book,'' Role, menu_order, function_id
	FROM #app_func
	WHERE depth = 2
		AND menu_order IS NOT NULL) a order by menu_order
END

-- Added for Privillege Grid Table in maintain users UI
ELSE IF @flag='t'
BEGIN
	SELECT TOP 10 function_id AS function_id, function_name AS function_name, function_desc AS function_desc
	FROM application_functions af
END
