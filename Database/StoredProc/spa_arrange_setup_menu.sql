 IF OBJECT_ID(N'[dbo].[spa_arrange_setup_menu]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_arrange_setup_menu]
 GO
  
 SET ANSI_NULLS ON
 GO
  
 SET QUOTED_IDENTIFIER ON
 GO
 
 /***************************************************************************************
 
 Author: nkhadgi@pioneersolutions.global.com
 Create date: 2018-06-21
 Description: CRUD operation for table setup_menu and application_functions
 
 Params:
 @flag CHAR(1) - Operation flag (s) - Display tree grid
			   - Operation flag (i) - Update, show/hide menu after tab open and click on save
			   - Operation flag (g) - Insert/Update tree grid data with respective parent
			   - Operation flag (t) - Display tree for pop up screen
			   - Operation flag (n) - Returns max setup_menu_id for reference
			   - Operation flag (o) - Update menu order
 
 ****************************************************************************************/
 
 CREATE PROCEDURE [dbo].spa_arrange_setup_menu
 	@flag CHAR(1),
 	@xml XML = NULL,
 	@product_category INT = 10000000,
 	@hide_show BIT = 1
 AS
 
 SET NOCOUNT ON
 
 /*** TEST DATA********
 
 DECLARE @flag CHAR(1) = 'd',
		 @xml VARCHAR(MAX) = NULL,
		 @product_category INT
		
***/

DECLARE @sql VARCHAR(MAX)
DECLARE @idoc INT
DECLARE @desc VARCHAR(100)
DECLARE @call_from VARCHAR(50)

IF @flag ='s'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT,
	     @xml
      
	SELECT @product_category = product_category
	FROM   OPENXML(@idoc, '/FormXML', 1) 
	WITH (
	       product_category INT
	)
	
	-- Distinguish Administration, Front Office, Middle Office and Back Office
	IF OBJECT_ID('tempdb..#groups') IS NOT NULL DROP TABLE #groups
	
	CREATE TABLE #groups (
		group_id INT IDENTITY(1,1)
	  , group_name VARCHAR(50)
	  ,	child_id INT
	  ,	function_id INT
	  ,	hide_show BIT
	)

	INSERT INTO #groups
	(
		group_name
		, child_id
		, function_id
		, hide_show
	)
	SELECT sm.display_name + CASE WHEN sm.hide_show = 0 THEN '_-_' + CAST(sm.hide_show AS CHAR(1)) ELSE '' END [display_name]
			, module.function_id
			, sm.function_id
			, sm.hide_show
	FROM setup_menu sm
	INNER JOIN setup_menu module
		ON module.parent_menu_id = sm.function_id
		AND module.product_category = @product_category
	WHERE sm.parent_menu_id = @product_category
	AND sm.product_category = @product_category

	IF OBJECT_ID('tempdb..#modules') IS NOT NULL DROP TABLE #modules

	CREATE TABLE #modules (
		function_id INT
	  , display_name VARCHAR(100)
	  , parent_menu_id INT
	  ,	hide_show BIT
	  , menu_order INT
	)

	--Module
	IF @hide_show = 0
	BEGIN
		INSERT INTO #modules (
			function_id
		  , display_name
		  , parent_menu_id
		  , hide_show
		  , menu_order
		)
		SELECT sm.function_id
			 , sm.display_name + CASE WHEN sm.hide_show = 0 THEN '_-_' + CAST(sm.hide_show AS CHAR(1)) ELSE '' END [display_name]
			 , sm.parent_menu_id
			 , sm.hide_show
			 , sm.menu_order
		FROM setup_menu AS sm
		WHERE sm.parent_menu_id IN (SELECT function_id FROM setup_menu WHERE parent_menu_id = @product_category)
		AND sm.product_category = @product_category
	END
	ELSE
	BEGIN
		INSERT INTO #modules (
			function_id
		  , display_name
		  , parent_menu_id
		  , hide_show
		  , menu_order
		)
		SELECT sm.function_id
			 , sm.display_name
			 , sm.parent_menu_id
			 , sm.hide_show
			 , sm.menu_order
		FROM setup_menu AS sm
		WHERE sm.parent_menu_id IN (SELECT function_id FROM setup_menu WHERE parent_menu_id = @product_category)
		AND sm.product_category = @product_category
		AND ISNULL(sm.hide_show, 1) = @hide_show
	END
	

	IF OBJECT_ID('tempdb..#collected_lists') IS NOT NULL DROP TABLE #collected_lists

	CREATE TABLE #collected_lists (
		function_id_lvl_0 INT
	  , display_name_lvl_0 VARCHAR(100)
	  , menu_order_lvl_0 INT
	  , function_id_lvl_1 INT
	  , display_name_lvl_1 VARCHAR(100)
	  , menu_order_lvl_1 INT
	  , function_id_lvl_2 INT
	  , display_name_lvl_2 VARCHAR(100)
	  , menu_order_lvl_2 INT
	  , function_id_lvl_3 INT
	  , display_name_lvl_3 VARCHAR(100)
	  , menu_order_lvl_3 INT
	)
	
	IF @hide_show = 0
	BEGIN
		INSERT INTO #collected_lists (
			function_id_lvl_0
	      , display_name_lvl_0
		  , menu_order_lvl_0
	      , function_id_lvl_1
	      , display_name_lvl_1
		  , menu_order_lvl_1
	      , function_id_lvl_2
	      , display_name_lvl_2
		  , menu_order_lvl_2
	      , function_id_lvl_3
	      , display_name_lvl_3
		  , menu_order_lvl_3
		)
		SELECT mo.function_id function_id_lvl_0
			 , mo.display_name display_name_lvl_0
			 , mo.menu_order
			 , sm1.function_id function_id_lvl_1
			 , sm1.display_name + CASE WHEN sm1.hide_show = 0 THEN '_-_' + CAST(sm1.hide_show AS CHAR(1)) ELSE '' END display_name_lvl_1
			 , sm1.menu_order
			 , sm2.function_id function_id_lvl_2
			 , sm2.display_name + CASE WHEN sm2.hide_show = 0 THEN '_-_' + CAST(sm2.hide_show AS CHAR(1)) ELSE '' END display_name_lvl_2
			 , sm2.menu_order
			 , sm3.function_id function_id_lvl_3
			 , sm3.display_name + CASE WHEN sm3.hide_show = 0 THEN '_-_' + CAST(sm3.hide_show AS CHAR(1)) ELSE '' END display_name_lvl_3
			 , sm3.menu_order
		FROM #modules AS mo
		LEFT JOIN setup_menu sm1 
		ON sm1.parent_menu_id = mo.function_id 
		AND sm1.product_category = @product_category
		LEFT JOIN setup_menu sm2 
		ON sm2.parent_menu_id = sm1.function_id 
		AND sm2.product_category = @product_category
		LEFT JOIN setup_menu sm3 
		ON sm3.parent_menu_id = sm2.function_id 
		AND sm3.product_category = @product_category
	END
	ELSE
	BEGIN
		INSERT INTO #collected_lists (
			function_id_lvl_0
	      , display_name_lvl_0
		  , menu_order_lvl_0
	      , function_id_lvl_1
	      , display_name_lvl_1
		  , menu_order_lvl_1
	      , function_id_lvl_2
	      , display_name_lvl_2
		  , menu_order_lvl_2
	      , function_id_lvl_3
	      , display_name_lvl_3
		  , menu_order_lvl_3
		)
		SELECT mo.function_id function_id_lvl_0
			 , mo.display_name display_name_lvl_0
			 , mo.menu_order
			 , sm1.function_id function_id_lvl_1
			 , sm1.display_name display_name_lvl_1
			 , sm1.menu_order
			 , sm2.function_id function_id_lvl_2
			 , sm2.display_name display_name_lvl_2
			 , sm2.menu_order
			 , sm3.function_id function_id_lvl_3
			 , sm3.display_name display_name_lvl_3
			 , sm3.menu_order
		FROM #modules AS mo
		LEFT JOIN setup_menu sm1 
			ON sm1.parent_menu_id = mo.function_id 
			AND sm1.product_category = @product_category
			AND ISNULL(sm1.hide_show, 1) = @hide_show
		LEFT JOIN setup_menu sm2 
			ON sm2.parent_menu_id = sm1.function_id 
			AND sm2.product_category = @product_category
			AND ISNULL(sm2.hide_show, 1) = @hide_show
		LEFT JOIN setup_menu sm3 
			ON sm3.parent_menu_id = sm2.function_id 
			AND sm3.product_category = @product_category
			AND ISNULL(sm3.hide_show, 1) = @hide_show
	END
	
	IF @hide_show = 0
	BEGIN
		IF OBJECT_ID('tempdb..#final_lists_all') IS NOT NULL DROP TABLE #final_lists_all
		
		SELECT sm.setup_menu_id
			 , sm.parent_menu_id
			 , CASE WHEN af.function_id IS NOT NULL THEN 'Menu' ELSE 'Menu Group' END menu_type
			 , CASE WHEN sm.hide_show = 1 THEN 'No' ELSE 'Yes' END hide_show
			 , function_id_lvl_0 
			 , display_name_lvl_0
			 , menu_order_lvl_0
			 , function_id_lvl_1 
			 , display_name_lvl_1
			 , menu_order_lvl_1
			 , function_id_lvl_2 
			 , display_name_lvl_2
			 , menu_order_lvl_2
			 , function_id_lvl_3 
			 , display_name_lvl_3
			 , menu_order_lvl_3
			 , sm.menu_order
			 , sm.function_id [function_id]
		INTO #final_lists_all
		FROM #collected_lists cl
		INNER JOIN setup_menu sm 
			ON sm.function_id = ISNULL(cl.function_id_lvl_3, ISNULL(cl.function_id_lvl_2, cl.function_id_lvl_1))
			AND sm.product_category = @product_category
		LEFT JOIN application_functions AS af 
			ON af.function_id = sm.function_id
		WHERE sm.product_category = @product_category
		
		SELECT g.group_name
			 , fla.setup_menu_id
			 , fla.function_id
			 , fla.parent_menu_id
			 , fla.menu_type
			 , fla.hide_show
			 , fla.function_id_lvl_0
			 , fla.function_id_lvl_1
			 , fla.function_id_lvl_2
			 , fla.function_id_lvl_3
			 , g.function_id [group_function_id]
			 , fla.display_name_lvl_0
			 , fla.display_name_lvl_1
			 , fla.display_name_lvl_2
			 , fla.display_name_lvl_3
			 , fla.menu_order
		FROM #groups AS g
		INNER JOIN #final_lists_all fla 
			ON fla.function_id_lvl_0 = g.child_id
		ORDER BY fla.menu_order_lvl_0, fla.menu_order_lvl_1, fla.menu_order_lvl_2, fla.menu_order_lvl_3, fla.menu_order
	END
	ELSE
	BEGIN
		IF OBJECT_ID('tempdb..#final_lists') IS NOT NULL DROP TABLE #final_lists

		SELECT sm.setup_menu_id
			 , sm.parent_menu_id
			 , CASE WHEN af.function_id IS NOT NULL THEN 'Menu' ELSE 'Menu Group' END menu_type
			 , CASE WHEN sm.hide_show = 1 THEN 'No' ELSE 'Yes' END hide_show
			 , function_id_lvl_0 
			 , display_name_lvl_0
			 , menu_order_lvl_0
			 , function_id_lvl_1 
			 , display_name_lvl_1
			 , menu_order_lvl_1
			 , function_id_lvl_2 
			 , display_name_lvl_2
			 , menu_order_lvl_2
			 , function_id_lvl_3 
			 , display_name_lvl_3
			 , menu_order_lvl_3
			 , sm.menu_order
			 , sm.function_id [function_id]
		INTO #final_lists
		FROM #collected_lists cl
		INNER JOIN setup_menu sm 
			ON sm.function_id = ISNULL(cl.function_id_lvl_3, ISNULL(cl.function_id_lvl_2, cl.function_id_lvl_1))
			AND sm.product_category = @product_category
		LEFT JOIN application_functions AS af 
			ON af.function_id = sm.function_id
		WHERE sm.product_category = @product_category
			AND sm.hide_show = @hide_show

		SELECT g.group_name
			 , fl.setup_menu_id
			 , fl.function_id
			 , fl.parent_menu_id
			 , fl.menu_type
			 , fl.hide_show
			 , fl.function_id_lvl_0
			 , fl.function_id_lvl_1
			 , fl.function_id_lvl_2
			 , fl.function_id_lvl_3
			 , g.function_id [group_function_id]
			 , fl.display_name_lvl_0
			 , fl.display_name_lvl_1
			 , fl.display_name_lvl_2
			 , fl.display_name_lvl_3
			 , fl.menu_order
		FROM #groups AS g
		INNER JOIN #final_lists fl ON fl.function_id_lvl_0 = g.child_id
		AND g.hide_show = @hide_show
		ORDER BY fl.menu_order_lvl_0, fl.menu_order_lvl_1, fl.menu_order_lvl_2, fl.menu_order_lvl_3, fl.menu_order
	END
END
ELSE IF @flag ='i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT,
			 @xml
	    
	    -- COLLECT DATA TO UPDATE
		IF OBJECT_ID('tempdb..#temp_data') IS NOT NULL
			DROP TABLE #temp_data
      
		SELECT setup_menu_id,
			   function_id,
			   display_name,
			   function_name,
			   hide_show
			   --NULLIF(product_category, '') product_category
		INTO #temp_data
		FROM   OPENXML(@idoc, '/Root/FormXML', 1) 
		WITH (
			   setup_menu_id INT,
			   function_id INT,
			   display_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
			   function_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
			   hide_show CHAR(1)
		)
		
		UPDATE sm
		SET display_name = td.display_name,
			hide_show = CASE WHEN td.hide_show = 'y' THEN 0 ELSE 1 END
		FROM setup_menu sm
		INNER JOIN #temp_data td
		ON td.setup_menu_id = sm.setup_menu_id
		
		EXEC spa_ErrorHandler @@ERROR,
			 'Setup Menu',
			 'spa_arrange_setup_menu',
			 'Success',
			 'Changes have been saved successfully.',
			 ''
			 
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @desc = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1,
			 'Setup Menu',
			 'spa_arrange_setup_menu',
			 'Error'
			 ,@desc
			 , NULL
	END CATCH
END
ELSE IF @flag='g'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT,
				@xml
	    
	    -- collect data to add
		IF OBJECT_ID('tempdb..#add_grid') IS NOT NULL
			DROP TABLE #add_grid
      
		SELECT setup_menu_id
			 , display_name
			 , hide_show
			 , parent_menu_id
			 , product_category
			 , menu_order
		INTO #add_grid
		FROM   OPENXML(@idoc, '/GridGroup/GridAddRow', 1) 
		WITH (
				setup_menu_id INT
			  , display_name VARCHAR(100)
			  , hide_show BIT
			  , parent_menu_id INT
			  , product_category INT
			  , menu_order INT
		)
		
		IF EXISTS (SELECT 1 FROM #add_grid)
		BEGIN
			-- Insert new menu group as it is with suggested setup_menu_id as function_id
			INSERT INTO setup_menu (
				function_id
			  , display_name
			  , hide_show
			  , parent_menu_id
			  , product_category
			  , menu_order
			  , menu_type
			)
			SELECT setup_menu_id
				 , display_name
				 , hide_show
				 , parent_menu_id
				 , product_category
				 , menu_order
				 , 1
			FROM #add_grid
		
			-- Update function_id with actual setup_menu_id for newly created menu group
			UPDATE sm
			SET sm.function_id = sm.setup_menu_id
			FROM setup_menu sm
			INNER JOIN #add_grid ag
				ON ag.setup_menu_id = sm.function_id
				AND ag.parent_menu_id = sm.parent_menu_id
				AND ag.product_category = sm.product_category
		END

		-- collect rows to update parents
		IF OBJECT_ID('tempdb..#update_parents') IS NOT NULL
			DROP TABLE #update_parents
      
		SELECT function_id
			 , parent_menu_id
			 , product_category
		INTO #update_parents
		FROM   OPENXML(@idoc, '/GridGroup/GridUpdateParent', 1) 
		WITH (
				function_id INT
			  , parent_menu_id INT
			  , product_category INT
		)
		
		IF EXISTS (SELECT 1 FROM #update_parents)
		BEGIN
			UPDATE sm
			SET sm.parent_menu_id = up.parent_menu_id
			FROM setup_menu sm
			INNER JOIN #update_parents up
				ON up.function_id = sm.function_id
				AND up.product_category = sm.product_category
		END
		
		-- collect menu group names to update
		IF OBJECT_ID('tempdb..#update_display_names') IS NOT NULL
			DROP TABLE #update_display_names
      
		SELECT display_name
			 , function_id
			 , product_category
			 , hide_show
		INTO #update_display_names
		FROM   OPENXML(@idoc, '/GridGroup/GridUpdateName', 1) 
		WITH (
				display_name VARCHAR(100)
			  , function_id INT
			  , product_category INT
			  , hide_show BIT
		)

		IF EXISTS (SELECT 1 FROM #update_display_names)
		BEGIN		
			UPDATE sm
			SET sm.display_name = udn.display_name
			  , sm.hide_show = udn.hide_show
			FROM setup_menu sm
			INNER JOIN #update_display_names udn
				ON udn.function_id = sm.function_id
				AND udn.product_category = sm.product_category
		END
		
		-- collect data to delete
		IF OBJECT_ID('tempdb..#delete_grid') IS NOT NULL
			DROP TABLE #delete_grid
		
		SELECT function_id
			 , product_category
		INTO #delete_grid
		FROM   OPENXML(@idoc, '/GridGroup/GridDeleteRow', 1) 
		WITH (
			   function_id INT
			 , product_category INT
		)
		
		IF EXISTS (SELECT 1 FROM #delete_grid)
		BEGIN	
			DELETE sm
			FROM setup_menu sm
			INNER JOIN #delete_grid dg
				ON dg.function_id = sm.function_id 
				AND dg.product_category = sm.product_category
		END
		
		--SELECT * FROM #add_grid
		--SELECT * FROM #update_parents
		--SELECT * FROM #update_display_names
		--SELECT * FROM #delete_grid
		
		EXEC spa_ErrorHandler @@ERROR,
			 'Setup Menu',
			 'spa_arrange_setup_menu',
			 'Success',
			 'Changes have been saved successfully.',
			 ''			 
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @desc = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1,
			 'Setup Menu',
			 'spa_arrange_setup_menu',
			 'Error'
			 ,@desc
			 , NULL
	END CATCH
END
ELSE IF @flag = 'p'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT,
	     @xml
    
	DECLARE @display_name VARCHAR(100)

	SELECT @display_name = display_name
	FROM   OPENXML(@idoc, '/Data', 1) 
	WITH (
	       display_name VARCHAR(100)
	)

	SELECT function_id
	FROM setup_menu
	WHERE display_name = @display_name
	AND product_category = @product_category
END
ELSE IF @flag = 'n'
BEGIN
	SELECT MAX(setup_menu_id) + 1 id
	FROM setup_menu
END
ELSE IF @flag = 't'
BEGIN
	IF OBJECT_ID('tempdb..#grid_data') IS NOT NULL
			DROP TABLE #grid_data
	
	CREATE TABLE #grid_data (
		group_name			 VARCHAR(100)
	  , function_id			 INT	
	  , setup_menu_id		 INT
	  , parent_menu_id		 INT
	  , menu_type			 VARCHAR(100)
	  , hide_show			 VARCHAR(100)
	  , function_id_lvl_0	 INT
	  , function_id_lvl_1	 INT
	  , function_id_lvl_2	 INT
	  , function_id_lvl_3 	 INT
	  , group_function_id	 INT
	  , display_name_lvl_0	 VARCHAR(100)
	  , display_name_lvl_1	 VARCHAR(100)
	  , display_name_lvl_2	 VARCHAR(100)
	  , display_name_lvl_3	 VARCHAR(100)
	  , menu_order			 INT
	)
	
	INSERT INTO #grid_data
	EXEC spa_arrange_setup_menu @flag='s', @product_category=@product_category
	
	SELECT group_function_id 
		 , group_name
		 , function_id_lvl_0
		 , function_id_lvl_1
		 , function_id_lvl_2
		 , function_id_lvl_3
		 , display_name_lvl_0
		 , IIF( gd.menu_type = 'Menu' , display_name_lvl_1 , display_name_lvl_1 + '_-_' + CAST(1 AS CHAR(1)) ) display_name_lvl_1
		 , IIF( gd.menu_type = 'Menu' , display_name_lvl_2 , display_name_lvl_2 + '_-_' + CAST(1 AS CHAR(1)) ) display_name_lvl_2
		 , IIF( gd.menu_type = 'Menu' , display_name_lvl_3 , display_name_lvl_3 + '_-_' + CAST(1 AS CHAR(1)) ) display_name_lvl_3
	FROM #grid_data gd
END
ELSE IF @flag = 'o'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT,
				@xml
	    
	    -- collect data to update menu order
		IF OBJECT_ID('tempdb..#grid_menu_order') IS NOT NULL
			DROP TABLE #grid_menu_order
      
		SELECT function_id,
				parent_menu_id,
				product_category,
				menu_order
		INTO #grid_menu_order
		FROM   OPENXML(@idoc, '/GridGroup/GridItem', 1) 
		WITH (
				function_id INT,
				parent_menu_id INT,
				product_category INT,
				menu_order INT
		)
		
		UPDATE sm
		SET sm.menu_order = gmo.menu_order
		  , sm.parent_menu_id = gmo.parent_menu_id
		FROM setup_menu sm
		INNER JOIN #grid_menu_order gmo
		ON gmo.function_id = sm.function_id
		AND gmo.product_category = sm.product_category
		
		EXEC spa_ErrorHandler @@ERROR,
			 'Setup Menu',
			 'spa_arrange_setup_menu',
			 'Success',
			 'Changes have been saved successfully.',
			 ''
			 
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		SET @desc = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1,
			 'Setup Menu',
			 'spa_arrange_setup_menu',
			 'Error'
			 ,@desc
			 , NULL
	END CATCH
END
ELSE IF @flag = 'm'
BEGIN
	BEGIN TRY
		DECLARE @parent_menu_id INT
			  , @menu_name VARCHAR(100)
			  , @new_func_id INT
			  , @max_func_id INT
			  , @mode CHAR(1)
			  , @menu_order INT
			  , @app_function_id INT
			  , @tab_id INT
		
		EXEC sp_xml_preparedocument @idoc OUTPUT,
	    @xml
      
		SELECT @parent_menu_id = parent_menu_id
			 , @product_category = product_category
			 , @menu_order = menu_order
			 , @mode = mode
			 , @app_function_id = app_function_id
			 , @menu_name = menu_name
			 , @tab_id = tab_id
		FROM   OPENXML(@idoc, '/Root/TreeXML', 1) 
		WITH (
			   parent_menu_id INT,
			   product_category INT,
			   menu_order INT,
			   mode CHAR(1),
			   app_function_id INT,
			   menu_name VARCHAR(50),
			   tab_id INT
		)
		
		IF @menu_name IS NULL
		BEGIN
			EXEC spa_ErrorHandler -1
			 , 'Setup User Defined Table'
			 , 'spa_arrange_setup_menu'
			 , 'Error'
			 , 'Menu could not be added.'
			 , NULL
			RETURN
		END
		
		BEGIN TRAN
		IF @mode = 'i'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM setup_menu WHERE product_category = @product_category AND display_name = @menu_name)
			BEGIN
				SELECT @max_func_id = MAX(function_id) FROM setup_menu WHERE product_category = @product_category
			
				SET @new_func_id = CASE WHEN @max_func_id < 50000000 THEN 50000000 ELSE @max_func_id + 100 END
			
				INSERT INTO setup_menu
				(
					function_id
				  , display_name
				  , hide_show
				  , parent_menu_id
				  , product_category
				  , menu_order
				  , menu_type
				)
				SELECT @new_func_id
					 , @menu_name
					 , 1
					 , @parent_menu_id
					 , @product_category
					 , @menu_order
					 , 0
			
				IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_name = @menu_name)
				BEGIN									
					-- Insert menu
					INSERT INTO application_functions 
					(
						function_id
					  , function_name
					  , function_desc
					  , file_path
					)
					SELECT @new_func_id
						 , @menu_name
						 , function_name
						 , file_path + '?function_id=' + CAST(@new_func_id AS VARCHAR(10))
					FROM application_functions
					WHERE function_id = @app_function_id
					
					-- Insert Privilege
					SELECT IDENTITY (INT,1,1) new_id
						 , function_name
						 , function_desc
						 , @new_func_id func_ref_id
					INTO #temp_af
					FROM application_functions
					WHERE func_ref_id = @app_function_id
					
					INSERT INTO application_functions 
					(
						function_id
					  , function_name
					  , function_desc
					  , func_ref_id
					)
					SELECT (func_ref_id + new_id) function_id
						 , function_name
						 , function_desc
						 , func_ref_id
					FROM #temp_af
				END
			
				EXEC spa_ErrorHandler @@ERROR,
					 'Setup User Defined Table',
					 'spa_arrange_setup_menu',
					 'Success',
					 'Changes have been saved successfully.',
					 ''
			END
			ELSE
			BEGIN
				SET @desc = '''' + @menu_name + ''' menu already exists.'
				
				EXEC spa_ErrorHandler -1,
				 'Setup User Defined Table',
				 'spa_arrange_setup_menu',
				 'Error'
				 ,'Menu with same name already exists.'
				 ,''
			END
		END
		ELSE IF @mode = 'u'
		BEGIN
			-- Relocate menu
			UPDATE setup_menu
			SET parent_menu_id = @parent_menu_id
			  , menu_order = @menu_order
			WHERE display_name = @menu_name
			AND product_category = @product_category
			
			EXEC spa_ErrorHandler @@ERROR,
				 'Setup User Defined Table',
				 'spa_arrange_setup_menu',
				 'Success',
				 'Changes have been saved successfully.',
				 ''
		END
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
			
		SET @desc = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1,
			 'Setup User Defined Table',
			 'spa_arrange_setup_menu',
			 'Error'
			 ,@desc
			 , NULL
	END CATCH
END
ELSE IF @flag='a'
BEGIN
	DECLARE @function_id INT
	
	EXEC sp_xml_preparedocument @idoc OUTPUT,
	@xml
     
	SELECT @function_id = function_id
		 , @call_from = call_from
	FROM   OPENXML(@idoc, '/Root/Data', 1) 
	WITH (
			function_id INT,
			call_from VARCHAR(50)
	)
	
	IF @call_from = 'generic_mapping'
	BEGIN
		SELECT priv.function_name
			 , priv.function_id
			 , CASE WHEN gmh.mapping_name IS NOT NULL THEN gmh.mapping_table_id ELSE '' END active_tab_id
		FROM (
			SELECT function_name
				 , function_id
				 , func_ref_id
			FROM application_functions
			WHERE func_ref_id = @function_id	
		) priv
		LEFT JOIN application_functions af
			ON af.function_id = priv.func_ref_id
		LEFT JOIN generic_mapping_header gmh
			ON gmh.mapping_name = af.function_name 
	END
	ELSE IF @call_from = 'user_defined_table'
	BEGIN
		SELECT priv.function_name
			 , priv.function_id
			 , CASE WHEN udt.udt_descriptions IS NOT NULL THEN udt.udt_id ELSE '' END active_tab_id
		FROM (
			SELECT function_name
				 , function_id
				 , func_ref_id
			FROM application_functions
			WHERE func_ref_id = @function_id	
		) priv
		LEFT JOIN application_functions af
			ON af.function_id = priv.func_ref_id
		LEFT JOIN user_defined_tables udt
			ON udt.udt_descriptions = af.function_name
	END
END
ELSE IF @flag = 'd'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT,
	@xml
      
	SELECT @function_id = function_id
		 , @product_category = product_category
	FROM   OPENXML(@idoc, '/Root/Data', 1) 
	WITH (
		   function_id INT,
	       product_category INT
	)
		
	DELETE 
	FROM setup_menu
	WHERE function_id = @function_id
	AND product_category = @product_category
		
	IF NOT EXISTS (SELECT 1 FROM setup_menu AS sm WHERE sm.function_id = @function_id)
	BEGIN		
		DELETE 
		FROM application_functions
		WHERE function_id = @function_id
		OR func_ref_id = @function_id
	END
	
	EXEC spa_ErrorHandler @@ERROR,
		'Setup User Defined Table',
		'spa_user_defined_tables',
		'Success',
		'Changes have been saved successfully.',
		''
END