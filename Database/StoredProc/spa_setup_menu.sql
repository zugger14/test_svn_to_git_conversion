
IF OBJECT_ID(N'[dbo].[spa_setup_menu]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_setup_menu
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	CRUD operations for table setup_menu
 
	Parameters
	@flag : Operation flag
	@pre_flag : Function ID
	@setup_menu_id : Setup Menu ID
	@function_id : Function ID
	@display_name : Display Name
	@menu_image : Default Parameters
	@hide_show : Hide-Show, 0(hide) / 1(show)
	@hide_show_ids : List of Setup Menu IDs to be hidden	
	@parent_menu_id : Parent Menu ID
	@product_category : Product Category
	@menu_order : Menu Order
	@window_name : Window Name
	@delete_ids : List of Setup Menu IDs to be deleted
	@menu_type : Menu Type, 1(menu) / 0(menu_item)
	@xml : Menu/Menus Details
	@login_id : User login id.	
	@role_id : Role id.
	@filter_text : Filter condition to filter data.
	@show_all : Show all data.
	@role_user_: User rlog lfag. 'u' for user and 'r' for role.
	@module_type : Module type.	
*/

CREATE PROCEDURE [dbo].spa_setup_menu
	@flag CHAR(1),
	@pre_flag CHAR(1) = NULL,
	@setup_menu_id INT = NULL,
	@function_id INT = NULL,
	@display_name VARCHAR(200) = NULL,
	@menu_image VARCHAR(5000) = NULL,
	@hide_show BIT = NULL,                   -- 0(hide) / 1(show)
	@hide_show_ids VARCHAR(8000) = NULL,    
	@parent_menu_id INT = NULL,
	@product_category INT = 10000000,
	@menu_order INT = NULL,
	@window_name VARCHAR(100) = NULL,
	@delete_ids VARCHAR(8000) = NULL,
	@menu_type BIT = NULL,	
	@filter_role INT = NULL,
	@filter_menu INT = NULL,				 -- 1(menu) / 0(menu_item)
	@xml VARCHAR (MAX) = NULL,		
	@login_id VARCHAR(50) = NULL,	
	@role_id INT = NULL,
	@filter_text VARCHAR(200) = NULL,
	@show_all BIT = 0,
	@role_user_flag CHAR(1) = NULL,
	@module_type CHAR(5) = NULL	
AS

/****************************************************************
DECLARE @flag CHAR(1),
		@pre_flag CHAR(1) = NULL,
		@setup_menu_id INT = NULL,
		@function_id INT = NULL,
		@display_name VARCHAR(200) = NULL,
		@menu_image VARCHAR(5000) = NULL,
		@hide_show BIT = NULL,                   -- 0(hide) / 1(show)
		@hide_show_ids VARCHAR(8000) = NULL,    
		@parent_menu_id INT = NULL,
		@product_category INT = 10000000,
		@menu_order INT = NULL,
		@window_name VARCHAR(100) = NULL,
		@delete_ids VARCHAR(8000) = NULL,
		@menu_type BIT = NULL,	
		@filter_role INT = NULL,
		@filter_menu INT = NULL,				 -- 1(menu) / 0(menu_item)
		@xml VARCHAR (MAX) = NULL,		
		@login_id VARCHAR(50) = NULL,	
		@role_id INT = NULL,
		@filter_text VARCHAR(200) = NULL,
		@show_all BIT = 0,
		@role_user_flag CHAR(1) = NULL,
		@module_type CHAR(5) = NULL	

SELECT  @flag='k', @pre_flag='s', @product_category=10000000
--**************************************************************/

SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX)
DECLARE @user_login_id VARCHAR(100)

IF @flag IN ('b', 'e')
BEGIN	
	IF OBJECT_ID(N'tempdb..#product_menu') IS NOT NULL 	DROP TABLE #product_menu
	IF OBJECT_ID(N'tempdb..#menu_list') IS NOT NULL 	DROP TABLE #menu_list
	IF OBJECT_ID(N'tempdb..#privilege') IS NOT NULL 	DROP TABLE #privilege
	
	SELECT * 
	INTO #product_menu 
	FROM setup_menu 
	WHERE product_category = @product_category 
		AND (hide_show = 1 OR parent_menu_id = 10202200)
		
	SELECT DISTINCT 
		af7.function_id AS [function_level_7], af7.display_name AS [function_name_7], af7.setup_menu_id [sm7], af7.menu_type [mt7],
		af6.function_id AS [function_level_6], af6.display_name AS [function_name_6], af6.setup_menu_id [sm6], af6.menu_type [mt6],
		af5.function_id AS [function_level_5], af5.display_name AS [function_name_5], af5.setup_menu_id [sm5], af5.menu_type [mt5],
		af4.function_id AS [function_level_4], af4.display_name AS [function_name_4], af4.setup_menu_id [sm4], af4.menu_type [mt4],
		af3.function_id AS [function_level_3], af3.display_name AS [function_name_3], af3.setup_menu_id [sm3], af3.menu_type [mt3],
		af2.function_id AS [function_level_2], af2.display_name AS [function_name_2], af2.setup_menu_id [sm2], af2.menu_type [mt2],
		af1.function_id AS [function_level_1], af1.display_name AS [function_name_1], af1.setup_menu_id [sm1], af1.menu_type [mt1]
	INTO #menu_list
	FROM dbo.FNAApplicationFunctionsHierarchy(@product_category) aft
	RIGHT JOIN #product_menu af1 ON aft.function_id = af1.function_id 
	RIGHT JOIN #product_menu af2 ON af1.parent_menu_id = af2.function_id
	RIGHT JOIN #product_menu af3 ON af2.parent_menu_id = af3.function_id 
	RIGHT JOIN #product_menu af4 ON af3.parent_menu_id = af4.function_id 
	RIGHT JOIN #product_menu af5 ON af4.parent_menu_id = af5.function_id
	RIGHT JOIN #product_menu af6 ON af5.parent_menu_id = af6.function_id
	RIGHT JOIN #product_menu af7 ON af6.parent_menu_id = af7.function_id
	WHERE af7.function_id = @product_category
	ORDER BY af6.function_id ,af5.function_id,af4.function_id,af3.function_id,af2.function_id, af1.function_id

	-- Delete those menu lists which is a First Level Menu Group but has no menu on it.
	-- Menu Group created with "Setup Menu" has same "function_id" and "setup_menu_id".
	DELETE FROM #menu_list
	WHERE sm4 = function_level_4
		AND mt4 = 1
		AND function_level_3 IS NULL

	-- Delete those menu lists which is a Second Level Menu Group but has no menu on it.
	-- Menu Group created with "Setup Menu" has same "function_id" and "setup_menu_id".
	DELETE FROM #menu_list
	WHERE sm3 = function_level_3
		AND mt3 = 1
		AND function_level_2 IS NULL

	CREATE TABLE #privilege
	(
		function_id1  int ,
		function_name1 VARCHAR(200) COLLATE DATABASE_DEFAULT,
		function_id2	int	,
		function_name2  VARCHAR(200) COLLATE DATABASE_DEFAULT,
		function_id3		int,
		function_name3  VARCHAR(200) COLLATE DATABASE_DEFAULT,
		function_id4		int,
		function_name4  VARCHAR(200) COLLATE DATABASE_DEFAULT,
		function_id5		int,
		function_name5  VARCHAR(200) COLLATE DATABASE_DEFAULT,
		function_id6		int,
		function_name6  VARCHAR(200) COLLATE DATABASE_DEFAULT,
		function_id7		int,
		function_name7  VARCHAR(200) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #privilege
	SELECT DISTINCT sm.function_level_7
		,sm.function_name_7
		, sm.function_level_6
		, sm.function_name_6
		, sm.function_level_5
		, sm.function_name_5
		, sm.function_level_4
		, sm.function_name_4
		, ISNULL(sm.function_level_3, af3.function_id) function_level_3
		, ISNULL(sm.function_name_3, af3.function_name) function_name_3
		, ISNULL(sm.function_level_2, af2.function_id) function_level_2
		, ISNULL(sm.function_name_2, af2.function_name) function_name_2
		, ISNULL(sm.function_level_1, af1.function_id) function_level_1
		, ISNULL(sm.function_name_1, af1.function_name) function_name_1
	FROM #menu_list sm
	LEFT JOIN application_functions af3 ON af3.func_ref_id = sm.function_level_4 AND sm.function_level_3 IS NULL --get child of function_name_4
	LEFT JOIN application_functions af2 ON af2.func_ref_id = COALESCE(sm.function_level_3, af3.function_id)	--get child of function_name_3
	LEFT JOIN application_functions af1 ON af1.func_ref_id = COALESCE(sm.function_level_2, af2.function_id)	--get child of function_name_2

END
 
/*******************************Shows list of both Hidden/Un-hidden or only Un-hidden menus***************************/
IF @flag = 's'
BEGIN --SELECT * FROM setup_menu
	SET @sql = 
        ';WITH CTE (function_id, 
				    setup_menu_id, 
				    parent_menu_id, 
				    display_name, 
				    menu_image,
				    hide_show,
				    menu_type, 
				    [level], 
				    sort_order,
					menu_order,
					product_category)
			AS
			(
				-- anchor:
				SELECT function_id [function_id], 
					   setup_menu_id [setup_menu_id],	
					   parent_menu_id [parent_menu_id], 
					   display_name [display_name],
					   menu_image [menu_image],
					   hide_show [hide_show],
					   menu_type [menu_type],
					   [level] = 0, 
					   CAST(RIGHT(''000'' + CAST(ROW_NUMBER() OVER(ORDER BY function_id) AS VARCHAR(20)),3) AS VARCHAR(200)),
					   menu_order,
					   product_category
				FROM setup_menu 				
				WHERE parent_menu_id LIKE ''%000000'' AND product_category = ' + CAST(@product_category AS VARCHAR(8))  				 
				
				IF (@function_id IS NOT NULL)
				BEGIN
					SET @sql = @sql + ' AND function_id = ' + CAST(@function_id AS VARCHAR(8)) 
				END
				
	SET @sql = @sql + ' UNION ALL
				
				-- recursive:
				SELECT sm.function_id, 
					   sm.setup_menu_id, 
					   sm.parent_menu_id, 
					   sm.display_name, 
					   sm.menu_image,
					   sm.hide_show, 
					   sm.menu_type,
					   [level] = CTE.[level] + 1, 
					   CAST(CTE.sort_order + ''/'' + RIGHT(''0000000000'' + CAST(ROW_NUMBER() OVER(ORDER BY sm.menu_order) AS VARCHAR(6)), 10) AS VARCHAR(200)),
					   sm.menu_order,
					   sm.product_category
				FROM setup_menu AS sm 
				INNER JOIN CTE 
				ON sm.parent_menu_id = CTE.function_id
				WHERE sm.product_category = CTE.product_category
			)
			
			SELECT cte.function_id,
			       cte.setup_menu_id,
			       cte.parent_menu_id,
			       cte.display_name,
			       cte.menu_image,
			       cte.hide_show,
			       cte.menu_type,
			       cte.[level],
			       cte.sort_order,
			       cte.menu_order,
			       cte.product_category,
			       CASE WHEN af.function_parameter IS NULL THEN af.file_path 
						ELSE af.file_path + ''?function_parameter='' + af.function_parameter END [file_path]
			FROM   CTE cte
			LEFT JOIN application_functions af ON cte.function_id = af.function_id
			WHERE  1 = 1
			AND CTE.product_category = ' + CAST(@product_category AS VARCHAR(8))  --include to display if each product can have unique menus 
	
	--Shows Only unhidden Menus
    IF @pre_flag = 's'
    BEGIN
    	SET @sql = @sql + ' AND CTE.hide_show = 1 ORDER BY  sort_order, menu_order'
    END
    
    --Shows both hidden and unhidden Menus
    ELSE   		
    BEGIN
		SET @sql = @sql + ' ORDER BY sort_order, menu_order' 	
    END
    
    --PRINT(@sql)
    EXEC(@sql) 
END

ELSE IF @flag IN ('g', 'k')
BEGIN --SELECT * FROM setup_menu

	DECLARE @temp_tbl VARCHAR(4000) = ''

	IF @flag = 'g' SET @temp_tbl = ' INTO #collect_all_menus '



	IF @pre_flag = 's'
    BEGIN
		
		SET @sql = ''

		SET @user_login_id = dbo.FNADBUser();

		
		IF dbo.FNAAppAdminRoleCheck(@user_login_id) = 0 AND dbo.FNAIsUserOnAdminGroup(@user_login_id, 0) = 0

		BEGIN
			SET @sql = @sql + '
			
			CREATE TABLE #temp_avail_function_id (	
				function_id INT 
			)

			INSERT INTO #temp_avail_function_id
			SELECT ' + CAST(@product_category AS VARCHAR(10)) + '
			UNION
			SELECT function_id
			FROM setup_menu 
			WHERE display_name = ''Maintain Users'' 
				AND product_category = ' + CAST(@product_category AS VARCHAR(10)) + '
			UNION
			SELECT function_id 
			FROM application_functional_users 	
			WHERE  login_id = ''' + @user_login_id + '''
			UNION				
			SELECT DISTINCT function_id 
			FROM application_functional_users afu 
			INNER JOIN application_role_user aru
				ON afu.role_id = aru.role_id
			WHERE aru.user_login_id = ''' + @user_login_id + '''
			UNION
			SELECT * FROM (SELECT 10111000 [Setup User] UNION ALL SELECT 10111100 [Setup Role] UNION ALL SELECT 10111200 [Setup Workflow]) a
			WHERE dbo.FNASecurityAdminRoleCheck(''' + @user_login_id + ''') = 1		
			UNION
			SELECT * FROM (SELECT 10201600 [Report Manager Old] UNION ALL SELECT 10202200 [View Report] UNION ALL SELECT 10202500 [Report Manager DHX] UNION ALL SELECT 10201800 [Report Group Manager] UNION ALL SELECT 10202600 [Excel Addin Report Manager]) rpt
			WHERE dbo.[FNAReportAdminRoleCheck](''' + @user_login_id + ''') = 1		
			UNION
			SELECT * FROM(SELECT 10101600 [View Scheduled Job] UNION ALL SELECT 10106300 [Data Import/Export New UI] UNION ALL SELECT 10201900 [Data Import/Export Audit Report] UNION ALL SELECT 10202100 [Message Board Log Report] UNION ALL SELECT 10201500 [Static Data Audit Report]) a
			WHERE dbo.FNAImportAdminRoleCheck(''' + @user_login_id + ''') = 1
			
			SELECT sm.* 
			INTO #temp_avail_menu
			FROM #temp_avail_function_id tafi
				LEFT JOIN setup_menu sm 
					ON tafi.function_id = sm.function_id
			WHERE sm.function_id IS NOT NULL
				AND sm.product_category = ' + CAST(@product_category AS VARCHAR(10)) + '

			;WITH CTE1(function_id, parent_menu_id ) AS
			( SELECT function_id,
				   parent_menu_id
			FROM #temp_avail_menu

			WHERE product_category =  ' + CAST(@product_category AS VARCHAR(10)) + '
			UNION ALL SELECT sm.function_id,
							sm.parent_menu_id
			FROM setup_menu AS sm
			INNER JOIN CTE1 ON sm.function_id = CTE1.parent_menu_id
			WHERE sm.product_category =  ' + CAST(@product_category AS VARCHAR(10)) + ' )

			SELECT DISTINCT function_id INTO #temp_cte1 FROM CTE1
			
			'
		END		
    END
	
	SET @sql = @sql +
        ';WITH CTE (function_id, 
				    setup_menu_id, 
				    parent_menu_id, 
				    display_name, 
				    menu_image,
				    hide_show,
				    menu_type, 
				    [level], 
				    sort_order,
					menu_order,
					product_category)
			AS
			(
				-- anchor:
				SELECT sm.function_id [function_id], 
					   sm.setup_menu_id [setup_menu_id],	
					   sm.parent_menu_id [parent_menu_id], 
					   sm.display_name [display_name],
					   sm.menu_image [menu_image],
					   sm.hide_show [hide_show],
					   sm.menu_type [menu_type],
					   [level] = 0, 
					   CAST(RIGHT(''000'' + CAST(ROW_NUMBER() OVER(ORDER BY sm.function_id) AS VARCHAR(20)),3) AS VARCHAR(500)),
					   sm.menu_order,
					   sm.product_category
				FROM setup_menu sm		
				WHERE parent_menu_id = ' + CAST(@product_category AS VARCHAR(8)) + 'AND product_category = ' + CAST(@product_category AS VARCHAR(8))  				 
				
				IF (@function_id IS NOT NULL)
				BEGIN
					SET @sql = @sql + ' AND function_id = ' + CAST(@function_id AS VARCHAR(8)) 
				END
				
	SET @sql = @sql + ' UNION ALL
				
				-- recursive:
				SELECT sm.function_id, 
					   sm.setup_menu_id, 
					   sm.parent_menu_id, 
					   sm.display_name, 
					   sm.menu_image,
					   sm.hide_show, 
					   sm.menu_type,
					   [level] = CTE.[level] + 1, 
					   CAST(CTE.sort_order + ''/'' + RIGHT(''0000000000'' + CAST(ROW_NUMBER() OVER(ORDER BY sm.menu_order) AS VARCHAR(6)), 10) AS VARCHAR(500)),
					   sm.menu_order,
					   sm.product_category
				FROM setup_menu AS sm 
				INNER JOIN CTE 
				ON sm.parent_menu_id = CTE.function_id
				WHERE sm.product_category = CTE.product_category
				AND (	sm.function_id IN (SELECT parent_menu_id FROM setup_menu WHERE product_category = ' + CAST(@product_category AS VARCHAR(8)) + ')
						OR
						sm.function_id IN (SELECT function_id FROM application_functions)
				)
			) '


	

			
	SET @sql = @sql + '		SELECT cte.function_id,
			       cte.setup_menu_id,
			       cte.parent_menu_id,
			       cte.display_name,
			       cte.menu_image,
			       cte.hide_show,
			       cte.menu_type,
			       cte.[level],
			       cte.sort_order,
			       cte.menu_order,
			       cte.product_category,
			       CASE WHEN af.function_parameter IS NULL THEN af.file_path 
						ELSE af.file_path + ''?function_parameter='' + af.function_parameter END [file_path],
			       i.window_name [window_name]
				   '
				   + @temp_tbl +
				   '
			FROM   CTE cte
			LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = cte.function_id	
			LEFT JOIN application_functions af ON cte.function_id = af.function_id
			and CTE.product_category = ' + CAST(@product_category AS VARCHAR(8))  --include to display if each product can have unique menus 
	
	--Shows Only unhidden Menus
    IF @pre_flag = 's'
    BEGIN
    	
		IF dbo.FNAAppAdminRoleCheck(@user_login_id) = 0 AND dbo.FNAIsUserOnAdminGroup(@user_login_id, 0) = 0
		BEGIN

			SET @sql = @sql + '  INNER JOIN #temp_cte1 tam 
									ON tam.function_id = cte.function_id
			
			'

		END 
		SET @sql = @sql + ' WHERE CTE.hide_show = 1 '
		
		DECLARE @is_admin BIT
		SELECT @is_admin = CASE WHEN [dbo].[FNAAppAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
							WHEN [dbo].[FNASecurityAdminRoleCheck](dbo.FNADBUser()) = 1 THEN 1
							ELSE 0 
						END

		-- Hide SaaS Administrative forms privilege for all users except for Application Admin
		IF @is_admin <> 1 
		BEGIN
			SET @sql += ' AND cte.function_id NOT IN (SELECT function_id FROM application_functions WHERE is_sensitive = 1) '
		END

		-- Hide menu which should not be accessible to read-only user
		IF EXISTS( SELECT 1
				   FROM application_users
				   WHERE user_login_id = @user_login_id
				   AND read_only_user = 'y' )
		BEGIN
			SET @sql += ' AND cte.function_id NOT IN (SELECT function_id FROM application_functions WHERE deny_privilege_to_read_only_user = 1) '
		END

		SET @sql = @sql + 'ORDER BY menu_order'		
    END
    
    --Shows both hidden and unhidden Menus
    ELSE   		
    BEGIN
		SET @sql = @sql + ' ORDER BY cte.menu_order' 	
    END
    
	IF @flag = 'g' 
	BEGIN
		SET @sql = @sql + ' SELECT c1.function_id parent_id, c1.display_name parent_name
						, c2.function_id child_id, c2.display_name child_name
						, c3.function_id sub_child_id, c3.display_name sub_child_name
					FROM #collect_all_menus c1
					left join #collect_all_menus c2 on c2.parent_menu_id = c1.function_id
					left join #collect_all_menus c3 on c3.parent_menu_id = c2.function_id
					where c2.function_id is not null
					ORDER BY c1.sort_order, c1.menu_order '
	END
	
    --PRINT(@sql)
    EXEC(@sql) 
END

/************************************************ Shows list of Products ******************************************/
ELSE IF @flag = 'a'
BEGIN
	SELECT sm.product_category, sm.display_name
	FROM setup_menu sm 
	WHERE sm.function_id LIKE '%__000000' order BY sm.product_category 
END

/************************************************ Inserts a new Menu ******************************************/
ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT * FROM setup_menu WHERE function_id = @function_id AND product_category = @product_category)
	BEGIN
		EXEC spa_ErrorHandler 1,
			 'Setup Menu',
			 'spa_setup_menu',
			 'DB Error',
			 'Function ID already exists.',
			 ''	
		RETURN
	END
	ELSE IF EXISTS (SELECT 1 FROM setup_menu WHERE display_name = @display_name AND product_category = @product_category)
	BEGIN
		EXEC spa_ErrorHandler 1,
			 'Setup Menu',
			 'spa_setup_menu',
			 'DB Error',
			 'Display Name already exists.',
			 ''
		RETURN
	END
	
	-- window_name column is removed from system. [FNAGetAppWindowName] function is used for window name. This function returns win_<function_id> as window name.
	INSERT INTO setup_menu (
		function_id,
		display_name,
		menu_image,
		hide_show,
		product_category,
		menu_order,
		menu_type 
	)
	VALUES (
		@function_id,
		@display_name,
		@menu_image,
		@hide_show,
		@product_category,
		@menu_order,
		@menu_type  
	)
	
	DECLARE @menu_id AS INT
    SET @menu_id = SCOPE_IDENTITY()

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 
				'Setup Menu', 
				'spa_setup_menu', 
				'DB Error', 
				'Failed to insert the menu.', 
				''
	END
		
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 
				'Setup Menu', 
				'spa_setup_menu', 
				'Success', 
				'Menu inserted successfully.', 
				@menu_id
	END	
END

/************************************************ Updates the selected Menu **************************************/
ELSE IF @flag = 'u'
BEGIN
	DECLARE @parent_id INT
	DECLARE @hidden BIT
	
	--To check whether the Menu's parent is hidden or not
	SELECT @parent_id = parent_menu_id 
	FROM setup_menu 
	WHERE function_id = @function_id AND product_category = @product_category
	
	SELECT @hidden = hide_show 
	FROM setup_menu 
	WHERE function_id = @parent_id AND product_category = @product_category
	
	IF (@hidden = 0)
	BEGIN
		EXEC spa_ErrorHandler -1,
				'Setup Menu', 
				'spa_setup_menu', 
				'DB Error', 
				'Failed to update the Menu Item as its Parent Menu is hidden.', 
				''
		RETURN
	END
	
	--To update a Menu
	UPDATE setup_menu 
	SET
		display_name = @display_name,
		--function_id = @function_id,
		menu_image = @menu_image,
		menu_type = @menu_type,
		hide_show = @hide_show 
	WHERE setup_menu_id = @setup_menu_id 
	 
	--To hide-unhide the Child-Menus
	;WITH CTE (setup_menu_id, function_id, [level])
	AS 
	(
		SELECT sm.setup_menu_id, sm.function_id, [level] = 0  
		FROM setup_menu sm 
		WHERE sm.setup_menu_id = @setup_menu_id 
		AND sm.product_category = @product_category
		
		UNION ALL
		
		SELECT sm.setup_menu_id, sm.function_id ,[level]= cte.[level] + 1 	
		FROM setup_menu AS sm 
		INNER JOIN CTE
		ON sm.parent_menu_id = CTE.function_id WHERE sm.product_category = @product_category
	)
	UPDATE setup_menu 
	SET hide_show = @hide_show 
	WHERE setup_menu_id IN (SELECT setup_menu_id FROM CTE)
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR, 
				'Setup Menu', 
				'spa_setup_menu', 
				'DB Error', 
				'Failed to update the menu.', 
				''
	END
		
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 
				'Setup Menu', 
				'spa_setup_menu', 
				'Success', 
				'Menu updated successfully.', 
				''
	END
END

/******************************************* Deletes Menu and its Child-Menus ***************************************/
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			CREATE TABLE #tmp_delete_menu 
			(
				setup_menu_ids VARCHAR(8000) COLLATE DATABASE_DEFAULT
			)

			INSERT into #tmp_delete_menu(setup_menu_ids) SELECT item FROM dbo.fnasplit(@delete_ids, ',')

			;WITH CTE (setup_menu_id, function_id, [level])
			AS 
			(
				SELECT sm.setup_menu_id, sm.function_id, [level] = 0  
				FROM setup_menu sm 
				INNER JOIN #tmp_delete_menu t 
				ON sm.setup_menu_id = t.setup_menu_ids 
				WHERE sm.product_category = @product_category
				
				UNION ALL
				
				SELECT sm.setup_menu_id, sm.function_id ,[level]= cte.[level] + 1 	
				FROM setup_menu AS sm 
				INNER JOIN CTE
				ON sm.parent_menu_id = CTE.function_id WHERE sm.product_category = @product_category
			)
			DELETE FROM setup_menu 
			WHERE setup_menu_id IN (SELECT setup_menu_id FROM CTE)  
			 
		COMMIT
			EXEC spa_ErrorHandler 0,
				 'Setup Menu',
				 'spa_setup_menu',
				 'Success',
				 'The Menu is successfully deleted.',
				 ''
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
			 'Setup Menu',
			 'spa_setup_menu',
			 'DB Error',
			 'Error in deleting the menu.',
			 ''
	END CATCH	   
END

/********************************************** Shows list of Hidden Menus ******************************************/
ELSE IF @flag = 'f'
BEGIN
	SELECT * FROM setup_menu WHERE hide_show = 0 AND product_category = @product_category
END

/***************************************** Shows details of a particular Menu ****************************************/
ELSE IF @flag = 't'
BEGIN
	SELECT sm.display_name, 
		   i.window_name, 
		   sm.menu_image, 
		   sm.function_id, 
		   sm.hide_show, 
		   sm.product_category 	
	FROM setup_menu sm 
	LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = sm.function_id	
	WHERE sm.function_id = @function_id AND product_category = @product_category
END

/************************************* Displays Menus and their details in Export Toolbar ******************************/
IF @flag = 'l'
BEGIN
	SET @sql = 
        ';WITH CTE (function_id, 
				    setup_menu_id, 
				    parent_menu_id, 
				    display_name, 
				    menu_image,
				    hide_show,
				    menu_type, 
				    [level], 
				    sort_order,
					menu_order,
					product_category)
			AS
			(
				-- anchor:
				SELECT function_id [function_id], 
					   setup_menu_id [setup_menu_id],	
					   parent_menu_id [parent_menu_id], 
					   display_name [display_name],
					   menu_image [menu_image],
					   hide_show [hide_show],
					   menu_type [menu_type],
					   [level] = 0, 
					   CAST(RIGHT(''000'' + CAST(ROW_NUMBER() OVER(ORDER BY function_id) AS VARCHAR(20)),3) AS VARCHAR(20)),
					   menu_order,
					   product_category
				FROM setup_menu 
				WHERE parent_menu_id LIKE ''%000000'' AND product_category = ' + CAST(@product_category AS VARCHAR(8))  				 
				
				IF (@function_id IS NOT NULL)
				BEGIN
					SET @sql = @sql + ' AND function_id = ' + CAST(@function_id AS VARCHAR(8)) 
				END 
				 
				
	SET @sql = @sql + ' UNION ALL
				
				-- recursive:
				SELECT sm.function_id, 
					   sm.setup_menu_id, 
					   sm.parent_menu_id, 
					   sm.display_name, 
					   sm.menu_image,
					   sm.hide_show, 
					   sm.menu_type,
					   [level] = CTE.[level] + 1, 
					   CAST(CTE.sort_order + ''/'' + RIGHT(''0000000000'' + CAST(ROW_NUMBER() OVER(ORDER BY sm.menu_order) AS VARCHAR(6)), 10) AS VARCHAR(20)),
					   sm.menu_order,
					   sm.product_category
				FROM setup_menu AS sm 
				INNER JOIN CTE 
				ON sm.parent_menu_id = CTE.function_id 
				WHERE sm.product_category = CTE.product_category
			)
			
			SELECT function_id [Function ID],
			       parent_menu_id [Parent Menu ID],
			       REPLICATE(''&nbsp&nbsp&nbsp&nbsp&nbsp'', [level]) + display_name [Display Name],
			       menu_image [Default Parameter],
			       menu_type [Menu Type]
			FROM   CTE
			WHERE  1 = 1
			AND CTE.product_category = ' + CAST(@product_category AS VARCHAR(8))  --include to display if each product can have unique menus  
	
	--Shows only unhidden Menus
    IF @pre_flag = 's'
    BEGIN
    	SET @sql = @sql + ' AND CTE.hide_show = 1 ORDER BY sort_order, menu_order'
    END
    
    --Shows both hidden and unhidden Menus
    ELSE   		
    BEGIN
		SET @sql = @sql + ' ORDER BY sort_order, menu_order' 	
    END
    
    --PRINT(@sql)
    EXEC(@sql) 
END
/*********************************************** Hides Menu and its Child-Menus ******************************************/
ELSE IF @flag = 'h'
BEGIN
	CREATE TABLE #tmp_hide_menu 
	(
		setup_menu_ids VARCHAR(8000) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #tmp_hide_menu(setup_menu_ids) SELECT item FROM dbo.fnasplit(@hide_show_ids, ',')

	;WITH CTE (setup_menu_id, function_id, [level])
	AS 
	(
		SELECT sm.setup_menu_id, sm.function_id, [level] = 0  
		FROM setup_menu sm 
		INNER JOIN #tmp_hide_menu t 
		ON sm.setup_menu_id = t.setup_menu_ids 
		WHERE sm.product_category = @product_category
		
		UNION ALL
		
		SELECT sm.setup_menu_id, sm.function_id ,[level]= cte.[level] + 1 	
		FROM setup_menu AS sm 
		INNER JOIN CTE
		ON sm.parent_menu_id = CTE.function_id WHERE sm.product_category = @product_category
	)
	UPDATE setup_menu 
	SET hide_show = '0' 
	WHERE setup_menu_id IN (SELECT setup_menu_id FROM CTE)

END

/*************************************************** Shows list of Modules *********************************************/
ELSE IF @flag = 'm'
BEGIN
	SELECT function_id, 
     display_name
	FROM setup_menu sp
	WHERE sp.hide_show = '1'  AND sp.product_category =  @product_category and menu_type = 1
		and function_id <> @product_category
		 
	ORDER BY function_id
END


/*************************************************** Shows list of Modules depth 2 *********************************************/
ELSE IF @flag = 'o'
BEGIN
	SELECT  sm.function_id , sm.display_name FROM setup_menu sm 
	LEFT JOIN dbo.FNAApplicationFunctionsHierarchy(@product_category) aft ON aft.function_id = sm.function_id 
	WHERE sm.hide_show = '1'  AND sm.product_category = @product_category 
		AND aft.Depth = 2 ORDER BY sm.display_name	
END

/************************************************* Updates the Menu Hierarchy ******************************************/
ELSE IF @flag = 'n'
BEGIN
	IF @xml IS NOT NULL
	BEGIN
		DECLARE @sm_doc INT
				
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @sm_doc OUTPUT, @xml

		--Create temp table to store the menu lists
		IF OBJECT_ID('tempdb..#setup_menu_list') IS NOT NULL
			DROP TABLE #setup_menu_list
		
			
		IF OBJECT_ID('tempdb..#parent_hide_show_detail') IS NOT NULL
			DROP TABLE #parent_hide_show_detail

		--Execute a INSERT-SELECT statement that uses the OPENXML rowset provider.
			SELECT function_id,
		       parent_menu_id,
		       menu_order
		INTO #setup_menu_list		       
		FROM OPENXML(@sm_doc, '/Root/PSRecordset', 1)
		WITH (
			   function_id INT,
		       parent_menu_id INT,
		       menu_order INT
		)
	
		CREATE TABLE #parent_hide_show_detail
		(
			function_id INT,
			menu_function_id INT,
			parent_func_id INT,
			hide_show_parent BIT
		)
		
		INSERT INTO #parent_hide_show_detail
		(
			function_id,
			menu_function_id,
			parent_func_id,
			hide_show_parent 
		)	
		SELECT					
				sml.function_id,
				sm.setup_menu_id,
				sm.function_id,
			   sm.hide_show 
		FROM setup_menu sm
		INNER JOIN #setup_menu_list sml
		ON sm.setup_menu_id = sml.parent_menu_id

		--Updates the Parents of the Menus
				
		UPDATE sm
		SET    sm.product_category = @product_category
		FROM   setup_menu sm
		INNER JOIN #parent_hide_show_detail phsd
		ON sm.setup_menu_id = phsd.function_id
		
		
		UPDATE sm
		SET    sm.parent_menu_id = phsd.parent_func_id,
		       sm.menu_order = sml.menu_order,
		       sm.product_category = @product_category
		FROM   setup_menu sm
		INNER JOIN #parent_hide_show_detail phsd
		ON sm.setup_menu_id = phsd.function_id
		INNER JOIN #setup_menu_list sml
		ON sm.setup_menu_id = sml.function_id 
		WHERE sm.product_category = @product_category
		
		;WITH CTE (setup_menu_id, function_id, [level], hide_show)
		AS 
		(
			SELECT sm.setup_menu_id, sm.function_id, [level] = 0, sm.hide_show
			FROM setup_menu sm 
			INNER JOIN #parent_hide_show_detail phsd 
			ON sm.setup_menu_id = phsd.function_id
			WHERE phsd.hide_show_parent = '0' AND sm.product_category = @product_category
			
			UNION ALL
			
			SELECT sm.setup_menu_id, sm.function_id, [level] = cte.[level] + 1, sm.hide_show
			FROM setup_menu AS sm 
			INNER JOIN CTE
			ON sm.parent_menu_id = CTE.function_id where sm.product_category = @product_category
		)
		UPDATE setup_menu 
		SET hide_show = '0' 
		WHERE setup_menu_id IN (SELECT setup_menu_id FROM CTE)
		
		EXEC sp_xml_removedocument @sm_doc
	
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR,
				'Setup Menu',
				'spa_setup_menu',
				'DB Error',
				'Error on updating the menu hierarchy.',
				''
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
				'Setup Menu',
				'spa_setup_menu',
				'Success',
				'Successfully updated the menu hierarchy.',
				''
		END
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler -1,
				'Setup Menu',
				'spa_setup_menu',
				'DB Error',
				'XML Not Supplied.',
				''
	END	
END

ELSE IF @flag = 'b'
BEGIN
	--set @filter_role = 1263
	
	--IF OBJECT_ID('tempdb..#privilege') IS NOT NULL
	--DROP TABLE #privilege
	

	--SELECT  * FROM #privilege 

	--Collect effective privilege
	--IF OBJECT_ID(N'tempdb..#effective_privilege') IS NOT NULL
	--DROP TABLE #effective_privilege

	CREATE TABLE #effective_privilege(function_id  INT)

	IF NULLIF(@role_id, '') IS NOT NULL 
	BEGIN		
		INSERT INTO #effective_privilege(function_id)
		SELECT afu.function_id
		FROM application_functional_users afu 
		WHERE afu.role_id = @role_id 
		
	END
	ELSE IF NULLIF(@login_id, '') IS NOT NULL
	BEGIN
		INSERT INTO #effective_privilege(function_id)
		SELECT afu.function_id 
		FROM application_users au 
		LEFT JOIN application_role_user aru ON aru.user_login_id = au.user_login_id
		LEFT JOIN application_functional_users afu ON afu.login_id = au.user_login_id OR (afu.role_id = aru.role_id)
		WHERE au.user_login_id = @login_id

	END
		
	--SELECT  * FROM #privilege 	
	SELECT function_id1 function_level_7, function_name1 function_name_7, 
		function_id2 function_level_6, function_name2 function_name_6,
		function_id3 function_level_5, function_name3 function_name_5,
		function_id4 function_level_4, function_name4 function_name_4,
		function_id5 function_level_3, function_name5 function_name_3,
		function_id6 function_level_2, function_name6 function_name_2,
		function_id7  function_level_1,function_name7 function_name_1 
	INTO #final_output
	FROM #privilege 
	UNION ALL 
	SELECT MIN(function_id1), MIN(function_name1), 
			function_id2, MIN(function_name2), 
			function_id2 function_id3, MIN('View') function_name3 , 
			NULL, NULL, 
			NULL, NULL, 
			NULL, NULL,
			NULL,NULL
	FROM #privilege p
	INNER JOIN setup_menu AS sm ON sm.function_id = p.function_id2 AND sm.menu_type = 0  
	WHERE function_name4 IS null 
	GROUP BY function_id2
	UNION ALL 
	SELECT MIN(function_id1), MIN(function_name1), 
		MIN(function_id2), MIN(function_name2), 
		function_id3, MIN(function_name3),
		function_id3, MIN('View'),
		NULL, NULL,
		NULL, NULL,
		NULL,NULL
	FROM #privilege p
	INNER JOIN setup_menu AS sm ON sm.function_id = p.function_id3 AND sm.menu_type = 0  
	WHERE function_name4 IS NOT NULL AND  function_name5 IS null 
	GROUP BY function_id3
	UNION ALL 
	SELECT MIN(function_id1), MIN(function_name1), 
		MIN(function_id2), MIN(function_name2), 
		MIN(function_id3), MIN(function_name3),
		function_id4, MIN(function_name4),
		function_id4, MIN('View'),
		NULL, NULL,
		NULL,NULL
	FROM #privilege p
	INNER JOIN setup_menu AS sm ON sm.function_id = p.function_id4 AND sm.menu_type = 0 
	WHERE function_name4 IS NOT NULL AND  function_name5 IS NOT NULL AND function_name6 IS  null 
	GROUP BY function_id4
	UNION ALL 
	SELECT MIN(function_id1), MIN(function_name1), 
		MIN(function_id2), MIN(function_name2), 
		MIN(function_id3), MIN(function_name3),
		MIN(function_id4), MIN(function_name4),
		function_id5, MIN(function_name5),
		function_id5, MIN('View'),
		NULL,NULL
	FROM #privilege p
	INNER JOIN setup_menu AS sm ON sm.function_id = p.function_id5 AND sm.menu_type = 0
	LEFT JOIN #effective_privilege afu ON afu.function_id = function_id5
	WHERE function_name4 IS NOT NULL AND  function_name5 IS NOT NULL AND function_name6 IS NOT NULL -- AND afu.function_id IS  NULL
	GROUP BY function_id5
	ORDER BY function_id1,
		function_id2,
		function_id3,
		function_id4,
		function_id5,
		function_id6,
		function_id7

	SET @sql = 'SELECT * FROM #final_output fo	'

	IF @show_all = 0 --Exclude those function ids which are mapped to given role/user
	BEGIN
		DELETE aft
		FROM #final_output aft	
		INNER JOIN #effective_privilege afu ON afu.function_id = COALESCE(aft.function_level_1, aft.function_level_2, aft.function_level_3, aft.function_level_4, aft.function_level_5)
		WHERE ISNULL(aft.function_level_3,1) <> 10201633
	END

	-- Hide SaaS Administrative forms privilege for all users except for Application Admin
	DELETE aft
	FROM #final_output aft
	WHERE COALESCE(aft.function_level_1, aft.function_level_2, aft.function_level_3, aft.function_level_4, aft.function_level_5) IN ( 
		SELECT function_id FROM application_functions WHERE is_sensitive = 1
		UNION
		SELECT function_id FROM application_functions WHERE func_ref_id IN (SELECT function_id FROM application_functions WHERE is_sensitive = 1)
	)

	-- Hide write privilege and only list read-only privileges for read-only users
	IF EXISTS( SELECT 1
			   FROM application_users
			   WHERE user_login_id = @login_id
					AND read_only_user = 'y' )
	BEGIN
		DELETE aft
		FROM #final_output aft
		WHERE COALESCE(aft.function_level_1, aft.function_level_2, aft.function_level_3, aft.function_level_4, aft.function_level_5) IN ( 
			SELECT function_id FROM application_functions WHERE deny_privilege_to_read_only_user = 1
		)
	END


	IF NULLIF(@filter_role, '') IS NOT NULL 
	BEGIN
		IF OBJECT_ID(N'tempdb..#assigned_privileges') IS NOT NULL 
		DROP TABLE #assigned_privileges

		CREATE TABLE #assigned_privileges
			(function_id INT,
			)
		INSERT INTO #assigned_privileges 
		SELECT DISTINCT function_id FROM application_functional_users WHERE role_id = @filter_role

		SET @sql = @sql + 'INNER JOIN #assigned_privileges ap ON ap.function_id = COALESCE(fo.function_level_1, fo.function_level_2, fo.function_level_3, fo.function_level_4, fo.function_level_5) '
	END

	SET @sql = @sql + ' WHERE 1 = 1 
						AND (ISNULL(fo.function_level_1, 1) NOT IN (10105897, 10105896)) -- remove meter indicidual add save delete privelege
						'
				+ CASE WHEN NULLIF(@filter_menu, '') IS NOT NULL THEN 'AND fo.function_level_5 = ' + CAST(@filter_menu AS VARCHAR) ELSE '' END
				+	CASE WHEN NULLIF(@filter_text, '') IS NOT NULL 
						THEN ' AND (fo.function_name_4 like ''%' + CAST(@filter_text AS VARCHAR)+ '%'' OR fo.function_name_3 like''%' + CAST(@filter_text AS VARCHAR)+ '%'' OR fo.function_name_2 like''%' + CAST(@filter_text AS VARCHAR)+ '%'' OR fo.function_name_1 like''%' + CAST(@filter_text AS VARCHAR)+ '%'')' 
						ELSE '' 
					END
				+ ' ORDER BY fo.function_level_6,
							fo.function_level_5,
							fo.function_level_4,
							fo.function_level_3,
							fo.function_level_2,
							fo.function_level_1'

							

	--print @sql
	EXEC(@sql)

	 
END

ELSE IF @flag = 'e'
BEGIN
		
	--CREATE TABLE #Temp_roles
	--	(function_id_temp INT,
	--	)
	--INSERT INTO #Temp_roles 
	--SELECT distinct function_id FROM application_functional_users WHERE role_id = @filter_role
	
	DECLARE @function_id_list VARCHAR(MAX)
	SELECT  @function_id_list =  COALESCE(@function_id_list + ', ', '') + CAST(function_id AS VARCHAR(10)) 
    FROM application_functional_users
    WHERE role_id = @filter_role
    GROUP BY function_id 
    
	/*
	IF @filter_menu  is not null
		SET @sql = @sql + ' AND af5.function_id = ' + CAST(@filter_menu AS VARCHAR)
	exec (@sql)
	*/
	
	SET @sql = 'SELECT 
					af.function_id1 AS [function_level_6], af.function_name1 AS [function_name_6], 
					af.function_id2 AS [function_level_5], af.function_name2 AS [function_name_5], 
					af.function_id3 AS [function_level_4], af.function_name3 AS [function_name_4], 
					af.function_id4 AS [function_level_3], af.function_name4 AS [function_name_3], 
					af.function_id5 AS [function_level_2], af.function_name5 AS [function_name_2], 
					af.function_id6 AS [function_level_1], af.function_name6 AS [function_name_1] 
				FROM #privilege af WHERE 1 = 1 '

	IF @filter_role <> ''
		SET @sql = @sql + ' AND (af.function_id2 IN (' + @function_id_list + ') 
								OR af.function_id3 IN (' + @function_id_list + ') 
								OR  af.function_id4 IN (' + @function_id_list + ')
								OR  af.function_id5 IN(' + @function_id_list + ') 
								OR  af.function_id6 IN (' + @function_id_list + '))'
		
	IF @filter_menu <> ''
		SET @sql = @sql + ' AND af.function_id2 = ' + CAST(@filter_menu AS VARCHAR)
	exec (@sql)
END
	
ELSE IF @flag = 'p'
BEGIN
	SELECT ds.data_source_id, ds.name , ds.alias 
	FROM data_source ds
	LEFT JOIN report_manager_view_users AS rmvu 
		ON ds.data_source_id = rmvu.data_source_id  
			AND ISNULL(role_id, -1) = (IIF(@role_user_flag = 'r', @role_id, ISNULL(role_id, -1)))
			AND ISNULL(login_id, '-1') = (IIF(@role_user_flag = 'u', @login_id, ISNULL(login_id, '-1')))
	WHERE ds.type_id = 1
	AND rmvu.functional_users_id IS NULL
	ORDER BY ds.name
END
ELSE IF @flag = 'w'
BEGIN
	DECLARE @i INT
	DECLARE @user_name VARCHAR(100),
			@role INT
		
	SET @i = 0
	SET @user_name = dbo.FNADBUser()

	CREATE TABLE #temp_avail_function_id (	
		function_id INT 
	)

	SET @role = (SELECT role_type_value_id FROM application_security_role WHERE role_id = @filter_role)
	IF @role IN ('1','7','8') -- To display privelage of Application Admin Role,Report Admin Role and Security Admin Role in setup workflow
	BEGIN
		IF @role = '7'
		BEGIN
			INSERT INTO #temp_avail_function_id
			SELECT distinct  sm.function_id 
			FROM setup_menu sm
			WHERE product_category = @product_category
		END
		ELSE IF @role = '8'
		BEGIN
			INSERT INTO #temp_avail_function_id
			SELECT 10201600 function_id  UNION
			SELECT 10202200 UNION
			SELECT 10202500 UNION
			SELECT 10201800 UNION
			SELECT 10202600
		END
		ELSE IF @role = '1'
		BEGIN
		INSERT INTO #temp_avail_function_id
			SELECT 10111000 function_id  UNION
			SELECT 10111100 UNION
			SELECT 10111200
		END 			
	END
	ELSE IF @filter_role = 0 -- My Workflow
	BEGIN
			
		IF dbo.FNAAppAdminRoleCheck(@user_name) = 1 or dbo.FNAIsUserOnAdminGroup(@user_name, 0) = 1 OR dbo.FNASecurityAdminRoleCheck(@user_name) = 1
		BEGIN 
			INSERT INTO #temp_avail_function_id
			SELECT distinct  function_id 
			FROM setup_menu
			WHERE product_category = @product_category
		END
		ELSE 
		BEGIN
			INSERT INTO #temp_avail_function_id
			SELECT @product_category
			UNION
			SELECT function_id
			FROM setup_menu 
			WHERE display_name = 'Maintain Users' 
				AND product_category = @product_category
			UNION
			SELECT function_id 
			FROM application_functional_users 	
			WHERE  login_id = @user_name
			UNION 			
			SELECT DISTINCT function_id 
			FROM application_functional_users afu 
			INNER JOIN application_role_user aru
				ON afu.role_id = aru.role_id
			WHERE aru.user_login_id = @user_name
				
		END

	END 
	ELSE --Role Work Flow
	BEGIN
		
		IF EXISTS (
			SELECT 1 FROM application_security_role 
			WHERE role_type_value_id = 7
			AND role_id = @filter_role
		) 
		--Application Admin Group
		BEGIN
			INSERT INTO #temp_avail_function_id
				SELECT distinct  function_id 
				FROM setup_menu
				WHERE product_category = @product_category		
		END 
		ELSE 
		BEGIN
			INSERT INTO #temp_avail_function_id
			SELECT @product_category
			UNION ALL
			SELECT DISTINCT function_id 
			FROM application_functional_users afu 			
			WHERE afu.role_id = @filter_role
		END			
	END  
	
	SELECT sm.* 
	INTO #temp_avail_menu
	FROM #temp_avail_function_id tafi
		LEFT JOIN setup_menu sm 
			ON tafi.function_id = sm.function_id
	WHERE sm.function_id IS NOT NULL
		AND sm.product_category = @product_category
		AND sm.hide_show = 1
	--select * from #temp_avail_menu

	SELECT 
	RIGHT('000000' + CAST(t1.menu_order AS VARCHAR(6)),  6) +
			ISNULL('|' + RIGHT('000000' + CAST(sw1.menu_order AS VARCHAR(6)),  6), '') +
			ISNULL('|' + RIGHT('000000' + CAST(sw2.menu_order AS VARCHAR(6)),  6), '') +
			ISNULL('|' + RIGHT('000000' + CAST(sw3.menu_order AS VARCHAR(6)),  6), '') +
			ISNULL('|' + RIGHT('000000' + CAST(sw4.menu_order AS VARCHAR(6)),  6), '') +
			ISNULL('|' + RIGHT('000000' + CAST(sw5.menu_order AS VARCHAR(6)),  6), '')  seq,
		sw5.function_id l1_id , sw5.display_name l1_name
		, sw4.function_id l2_id, sw4.display_name l2_name
		, sw3.function_id l3_id, sw3.display_name l3_name
		, sw2.function_id l4_id, sw2.display_name l4_name
		, sw1.function_id l5_id, sw1.display_name l5_name
		, t1.function_id l6_id, t1.display_name l6_name
	INTO #temp_for_tree
	FROM #temp_avail_menu t1	
		INNER JOIN application_functions af
			ON t1.function_id = af.function_id
		LEFT JOIN setup_menu sw1
			ON sw1.function_id = t1.parent_menu_id	
			AND t1.product_category = @product_category 
			AND sw1.product_category = @product_category 
		LEFT JOIN setup_menu sw2
			ON sw2.function_id = sw1.parent_menu_id
			AND sw1.product_category = @product_category 
			AND sw2.product_category = @product_category 
		LEFT JOIN setup_menu sw3
			ON sw3.function_id = sw2.parent_menu_id
			AND sw2.product_category = @product_category 
			AND sw3.product_category = @product_category
		LEFT JOIN setup_menu sw4
			ON sw4.function_id = sw3.parent_menu_id
			AND sw3.product_category = @product_category 
			AND sw4.product_category = @product_category 
		LEFT JOIN setup_menu sw5
			ON sw5.function_id = sw4.parent_menu_id
			AND sw4.product_category = @product_category 
			AND sw5.product_category = @product_category 

	WHILE @i < 5	
	BEGIN		
		UPDATE t
			SET l1_id = l2_id,
				l1_name = l2_name,
				l2_id = l3_id,
				l2_name = l3_name,
				l3_id = l4_id,
				l3_name = l4_name,
				l4_id = l5_id,
				l4_name = l5_name,
				l5_id = l6_id,
				l5_name = l6_name,
				l6_id = NULL,
				l6_name = NULL 
		FROM #temp_for_tree t 	
		WHERE 
			l1_id IS NULL
		
		SET @i = @i + 1
	END

	SELECT 
			l1_id, l1_name,
			l2_id, l2_name,
			l3_id, l3_name,
			l4_id, l4_name,
			l5_id, l5_name,
			l6_id, l6_name
	FROM #temp_for_tree
	ORDER BY seq
		
END 
ELSE IF @flag = 'c'
BEGIN
 	SELECT af.file_path, CASE WHEN CHARINDEX('win_', i.window_name) = 0 THEN 'win_' + i.window_name ELSE i.window_name END window_name, ISNULL(sm.display_name, af.function_desc) display_name
	FROM application_functions af
	LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = af.function_id	
	LEFT JOIN setup_menu sm ON af.function_id = sm.function_id
	WHERE af.function_id = @function_id
	AND (sm.product_category = @product_category OR sm.product_category IS NULL)
END
ELSE IF @flag = 'z'
BEGIN
	IF @module_type = 'trm'
		SET @product_category = 10000000
	ELSE IF @module_type = 'ems'
		SET @product_category = 12000000
	ELSE IF @module_type = 'fas'
		SET @product_category = 13000000
	ELSE IF @module_type = 'rec'
		SET @product_category = 14000000
	ELSE IF @module_type = 'set'
		SET @product_category = 15000000

	SELECT product_category
		 , display_name
		 , menu_image
	FROM setup_menu
	WHERE function_id = product_category
	AND product_category = @product_category
END
-- Get List of Manually created menu groups
ELSE IF @flag = 'x'
BEGIN
	SELECT TOP 1 STUFF(
		(
			SELECT ',' + CAST(function_id AS VARCHAR(100)) + ''
			FROM setup_menu sm
			WHERE sm.function_id = sm.setup_menu_id
			FOR XML PATH('')
		), 1, 1, '') [values]
	FROM setup_menu sm
	WHERE sm.function_id = sm.setup_menu_id
END

GO