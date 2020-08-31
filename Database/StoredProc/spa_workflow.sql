

IF OBJECT_ID(N'spa_workflow', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_workflow]
GO 
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2015-05-25
-- Description: Setups workflow.
 
-- Params:
-- @flag m CHAR(1) - merge
-- @flag t CHAR(1) - load workflow
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_workflow]
	@flag CHAR(1),
	@role_id INT = NULL,
	@product_category INT = NULL,
	@xml XML = NULL
AS
SET NOCOUNT ON

DECLARE @user_id VARCHAR(50)
DECLARE @max_menu_level TINYINT
DECLARE @menu_level TINYINT
DECLARE @err VARCHAR(1000)

SET @user_id = dbo.FNADBUser();

IF @role_id = 0 OR @role_id = '0' or @role_id = -200 OR @role_id = '-200'
	SET @role_id = NULL
ELSE 
	SET @user_id = NULL

CREATE TABLE #temp_inserted_menu (
		id  INT,
		menu_name VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
		function_id VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
		menu_level TINYINT
)	

IF @flag = 'm' 
BEGIN

	DECLARE @idoc INT
	DECLARE @duplicate_menus VARCHAR(1000)
	set @duplicate_menus = NULL

	CREATE TABLE #temp_menu (
		id INT IDENTITY(1, 1),	
		function_id VARCHAR(30) COLLATE DATABASE_DEFAULT  ,
		menu_name VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
		parent_id VARCHAR(30) COLLATE DATABASE_DEFAULT  ,
		parent_name VARCHAR(100) COLLATE DATABASE_DEFAULT  ,
		menu_level TINYINT, 
		menu_type BIT,
		product_category INT,
		user_data VARCHAR(100) COLLATE DATABASE_DEFAULT 
		
	)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	INSERT INTO #temp_menu (		
		function_id,
		menu_name,
		parent_id,
		parent_name,
		menu_level, 
		menu_type,
		user_data
	)
	SELECT 		
		function_id,
		menu_name,
		NULLIF(parent_id, 'NULL'),
		parent_name,
		menu_level,
		menu_type,
		user_data
	FROM OPENXML (@idoc, '/Root/PSRecordSet')
		 WITH ( 			
			function_id  VARCHAR(100),
			menu_name	VARCHAR(100),
			parent_id  VARCHAR(100),
			parent_name  VARCHAR(100),
			menu_level VARCHAR(100),
			menu_type VARCHAR(100),
			user_data VARCHAR(100)
		);
	

	SELECT @duplicate_menus = ISNULL(@duplicate_menus + ', ', '') + menu_name
	FROM #temp_menu 
	GROUP BY parent_id, menu_name, menu_level  
	HAVING COUNT(1) > 1

	IF @duplicate_menus IS NOT NULL
	BEGIN
		DECLARE @msg VARCHAR(1000)
		
		SET @msg ='There are following duplicate menus: "' + @duplicate_menus + '"';
		
		EXEC spa_ErrorHandler -1
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'DB Error'
				, @msg
				, ''
		RETURN;
	END
	

	EXEC sp_xml_removedocument @idoc

	SELECT @max_menu_level = MAX(menu_level) 
	FROM #temp_menu


	--SELECT *  
	BEGIN TRY
		BEGIN TRAN

		DELETE FROM setup_workflow  WHERE (user_id = ISNULL(@user_id, -1) OR role_id = ISNULL(@role_id, -1))
	
		DELETE wi
		FROM #temp_menu tm 
		INNER JOIN workflow_icons wi ON wi.workflow_menu_id = tm.function_id
		WHERE tm.user_data <> 'NULL'

		DECLARE menu_cur CURSOR FORWARD_ONLY READ_ONLY FOR
			SELECT n - 1 
			FROM seq 
			WHERE n <= @max_menu_level + 1 
		OPEN menu_cur
		FETCH NEXT FROM menu_cur INTO @menu_level
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO setup_workflow (
				menu_name,
				function_id,
				menu_level,
				parent_menu_id,
				role_id,
				user_id,
				sequence_order,                                                                                                              
				menu_type,
				product_category
			)
			OUTPUT INSERTED.menu_id, INSERTED.menu_name, inserted.function_id, INSERTED.menu_level INTO #temp_inserted_menu
			SELECT
				tm.menu_name,
				af.function_id function_id,
				tm.menu_level,
				COALESCE (tim_parent.id, NULLIF(CAST(tm.parent_id AS VARCHAR(8)), 'NULL'), NULL) parent_id,
				@role_id role_id,
				@user_id user_id,
				tm.id sequence_order,
				tm.menu_type,
				@product_category
			FROM #temp_menu tm
				LEFT JOIN #temp_inserted_menu tim_parent
					ON tm.parent_name  = tim_parent.menu_name
					AND (tm.menu_level -1) = tim_parent.menu_level			
				LEFT JOIN application_functions af
					ON  LEFT(tm.function_id, 8) = af.function_id
			WHERE tm.menu_level = @menu_level	
			ORDER BY tm.id

			FETCH NEXT FROM menu_cur INTO @menu_level
		END
		CLOSE menu_cur
		DEALLOCATE menu_cur

		UPDATE setup_workflow
			SET function_id = menu_id
		WHERE (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))
			AND function_id IS NULL
		
		INSERT INTO workflow_icons(workflow_menu_id
									, image_id
									, workflow_user)
		SELECT tim.id, tm.user_data, dbo.FNADBUser()
		FROM #temp_inserted_menu tim
		INNER JOIN #temp_menu tm ON tm.menu_name = tim.menu_name
			AND tm.user_data <> 'NULL'
		 


		EXEC spa_ErrorHandler 0
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'Success'
				, 'Changes has been saved successfully.'
				, ''

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		SET  @err = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'DB Error'
				, @err
				, ''
	END CATCH
	
END 
ELSE IF @flag = 't' 
BEGIN

	SELECT l1.function_id l1_id, l1.menu_name l1_name
		,l2.function_id l2_id, l2.menu_name l2_name
		,l3.function_id l3_id, l3.menu_name l3_name
		,l4.function_id l4_id, l4.menu_name l4_name
		,l5.function_id l5_id, l5.menu_name l5_name
		,l6.function_id l6_id, l6.menu_name l6_name
	FROM 
		(SELECT function_id, menu_id, menu_name, parent_menu_id FROM setup_workflow WHERE menu_level = 0 AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))) l1
		LEFT JOIN (SELECT function_id, menu_id, menu_name, parent_menu_id FROM setup_workflow WHERE menu_level = 1 AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))) l2 ON l2.parent_menu_id = l1.menu_id
		LEFT JOIN (SELECT function_id, menu_id, menu_name, parent_menu_id FROM setup_workflow WHERE menu_level = 2 AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))) l3 ON l3.parent_menu_id = l2.menu_id
		LEFT JOIN (SELECT function_id, menu_id, menu_name, parent_menu_id FROM setup_workflow WHERE menu_level = 3 AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))) l4 ON l4.parent_menu_id = l3.menu_id
		LEFT JOIN (SELECT function_id, menu_id, menu_name, parent_menu_id FROM setup_workflow WHERE menu_level = 4 AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))) l5 ON l5.parent_menu_id = l4.menu_id
		LEFT JOIN (SELECT function_id, menu_id, menu_name, parent_menu_id FROM setup_workflow WHERE menu_level = 5 AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))) l6 ON l6.parent_menu_id = l5.menu_id
		
END 
ELSE IF @flag = 'c' 
BEGIN
	SET @user_id = dbo.FNADBUser();
	
	BEGIN TRY
		BEGIN TRAN

		DELETE FROM setup_workflow WHERE USER_ID = @user_id

		SELECT @max_menu_level = MAX(menu_level) 
		FROM setup_workflow 
		WHERE role_id = @role_id

		DECLARE menu_copy_cur CURSOR FORWARD_ONLY READ_ONLY FOR
				SELECT n - 1 
				FROM seq 
				WHERE n <= @max_menu_level + 1
			OPEN menu_copy_cur
			FETCH NEXT FROM menu_copy_cur INTO @menu_level
			WHILE @@FETCH_STATUS = 0
			BEGIN
			--NULLIF(CAST(tm.parent_id AS VARCHAR(8)), 'NULL'),
		
				INSERT INTO setup_workflow (
					menu_name,
					function_id,
					menu_level,
					parent_menu_id,
					user_id,
					sequence_order,
					menu_type,
					product_category
				)
				OUTPUT INSERTED.menu_id, INSERTED.menu_name, inserted.function_id, INSERTED.menu_level INTO #temp_inserted_menu
				SELECT 
					sw.menu_name,
					sw.function_id,
					sw.menu_level,
					tim_parent.id parent_id,
					@user_id role_id,
					sw.sequence_order,
					sw.menu_type,
					sw.product_category
				FROM setup_workflow sw
				LEFT JOIN setup_workflow sw_parent
					ON sw.parent_menu_id = sw_parent.menu_id
				
				LEFT JOIN #temp_inserted_menu tim_parent
					ON (sw.menu_level -1) = tim_parent.menu_level	
					and sw_parent.menu_name = tim_parent.menu_name
				
				WHERE sw.menu_level = @menu_level and sw.role_id = @role_id
				

				FETCH NEXT FROM menu_copy_cur INTO @menu_level
			END
		CLOSE menu_copy_cur
		DEALLOCATE menu_copy_cur
		
		UPDATE sw 
		SET sw.function_id = sw.menu_id
		FROM setup_workflow sw
			INNER JOIN setup_workflow sw1 
				ON sw.menu_name = sw1.menu_name
		WHERE sw.user_id = @user_id
			AND sw1.menu_id = sw1.function_id AND sw1.role_id = @role_id

		EXEC spa_ErrorHandler 0
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'Success'
				, 'Workflow Copied Successfully.'
				, ''

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		SET  @err = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'DB Error'
				, @err
				, ''
	END CATCH		

END 
ELSE IF @flag = 'w'
BEGIN
	--Changed window name as 'win_10201010' to prevent opening same page in multiple window.			
	SELECT 			
		sw.menu_name [display_name], i.window_name, 
		CASE WHEN af.function_parameter IS NULL THEN af.file_path ELSE af.file_path + '?function_parameter=' + af.function_parameter END [file_path],
		sw.sequence_order, sw.menu_type, sw.menu_level,
		SUBSTRING(ISNULL('|' + RIGHT( '000000' + CAST(sw5.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw4.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw3.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw2.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw1.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw.sequence_order AS VARCHAR(6)),  6), ''), 2, 6) 
		group_order
		,
		ISNULL('|' + RIGHT('000000' + CAST(sw5.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw4.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw3.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw2.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw1.sequence_order AS VARCHAR(6)),  6), '') +
		ISNULL('|' + RIGHT('000000' + CAST(sw.sequence_order AS VARCHAR(6)),  6), '') 
		seq,
		sw.function_id,
		sdv.code image_name,
		COALESCE(sw.parent_menu_id, sw1.parent_menu_id, sw2.parent_menu_id, sw3.parent_menu_id, sw4.parent_menu_id, sw5.parent_menu_id) parent_menu_id
	FROM setup_workflow sw
		LEFT JOIN setup_workflow sw1 
			ON sw.parent_menu_id = sw1.menu_id	
		LEFT JOIN setup_workflow sw2 
			ON sw1.parent_menu_id = sw2.menu_id	
		LEFT JOIN setup_workflow sw3 
			ON sw2.parent_menu_id = sw3.menu_id	
		LEFT JOIN setup_workflow sw4 
			ON sw3.parent_menu_id = sw4.menu_id		
		LEFT JOIN setup_workflow sw5 
			ON sw4.parent_menu_id = sw5.menu_id
		LEFT JOIN application_functions af 
			ON af.function_id = sw.function_id
LEFT JOIN workflow_icons wi ON wi.workflow_menu_id = sw.menu_id
	LEFT JOIN static_data_value sdv On sdv.value_id = wi.image_id
		LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = sw.function_id	
	WHERE (sw.user_id = ISNULL(@user_id, -1) or sw.role_id = ISNULL(@role_id, -1))
	 
	ORDER BY seq

END
/*IF @flag = 'm' 
BEGIN

	DECLARE @idoc INT

	CREATE TABLE #temp_menu (
		id INT IDENTITY(1, 1),	
		function_id VARCHAR(30) COLLATE DATABASE_DEFAULT  ,
		menu_name VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		parent_id VARCHAR(30) COLLATE DATABASE_DEFAULT  ,
		parent_name VARCHAR(50) COLLATE DATABASE_DEFAULT  ,
		menu_level TINYINT
		
	)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	INSERT INTO #temp_menu (		
		function_id,
		menu_name,
		parent_id,
		parent_name,
		menu_level	
	)
	SELECT 		
		function_id,
		menu_name,
		NULLIF(parent_id, 'NULL'),
		parent_name,
		menu_level	
	FROM OPENXML (@idoc, '/Root/PSRecordSet')
		 WITH ( 			
			function_id  VARCHAR(100),
			menu_name	VARCHAR(100),
			parent_id  VARCHAR(100),
			parent_name  VARCHAR(100),
			menu_level VARCHAR(100)
		);
	

		
	EXEC sp_xml_removedocument @idoc

	SELECT @max_menu_level = MAX(menu_level) 
	FROM #temp_menu

	BEGIN TRY
		BEGIN TRAN
		DECLARE menu_cur CURSOR FORWARD_ONLY READ_ONLY FOR
			SELECT n - 1 
			FROM seq 
			WHERE n <= @max_menu_level + 1
		OPEN menu_cur
		FETCH NEXT FROM menu_cur INTO @menu_level
		WHILE @@FETCH_STATUS = 0
		BEGIN
		--NULLIF(CAST(tm.parent_id AS VARCHAR(8)), 'NULL'),
		
			INSERT INTO setup_workflow (
				menu_name,
				function_id,
				menu_level,
				parent_menu_id,
				role_id,
				user_id,
				sequence_order
			)
			OUTPUT INSERTED.menu_id, INSERTED.menu_name, inserted.function_id, INSERTED.menu_level INTO #temp_inserted_menu
			SELECT 
			--CAST(sw.parent_menu_id AS VARCHAR(8)) , CAST(tm.parent_id AS VARCHAR(8)) ,
				tm.menu_name,
				af.function_id function_id,
				tm.menu_level,
				COALESCE (tim_parent.id,NULLIF(CAST(tm.parent_id AS VARCHAR(8)), 'NULL'), NULL) parent_id,
				@role_id role_id,
				@user_id user_id,
				tm.id sequence_order
			FROM #temp_menu tm
				LEFT JOIN #temp_inserted_menu tim_parent
					ON tm.parent_name = tim_parent.menu_name
					AND (tm.menu_level -1) = tim_parent.menu_level			
				LEFT JOIN application_functions af
					ON  LEFT(tm.function_id, 8) = af.function_id
				LEFT JOIN setup_workflow sw
					ON CAST(sw.function_id AS VARCHAR(8)) = CAST(tm.function_id AS VARCHAR(8))
					--AND CAST(ISNULL(sw.parent_menu_id, -1) AS VARCHAR(8)) = CAST(ISNULL(tm.parent_id, -1) AS VARCHAR(8)) 
					AND (sw.user_id = ISNULL(@user_id, -1) OR sw.role_id = ISNULL(@role_id, -1))
			WHERE tm.menu_level = @menu_level
				AND sw.menu_name IS NULL
				
					

			FETCH NEXT FROM menu_cur INTO @menu_level
		END
		CLOSE menu_cur
		DEALLOCATE menu_cur
		
		UPDATE sw1
			SET sw1.parent_menu_id = sw.menu_id
		--select sw1.parent_menu_id, sw.function_id,sw.menu_id
		FROM setup_workflow sw
			INNER JOIN setup_workflow sw1
				ON sw.menu_level = (sw1.menu_level - 1)
				AND sw1.parent_menu_id = sw.function_id
		WHERE (sw.user_id = ISNULL(@user_id, -1) or sw.role_id = ISNULL(@role_id, -1))

		UPDATE setup_workflow
			SET function_id = menu_id
		WHERE (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))
			AND function_id IS NULL

		UPDATE sw
			SET sw.menu_name = tm.menu_name
		FROM #temp_menu tm
			INNER  JOIN setup_workflow sw
				ON CAST(sw.function_id AS VARCHAR(8)) = CAST(tm.function_id AS VARCHAR(8))
		WHERE (sw.user_id = ISNULL(@user_id, -1) OR sw.role_id = ISNULL(@role_id, -1))
			AND sw.menu_level = tm.menu_level
			AND sw.menu_name <> tm.menu_name 

		UPDATE #temp_inserted_menu
		SET function_id = id
		WHERE function_id IS NULL

	--select * FROM setup_workflow
		--select * FROM #temp_inserted_menu
		--select * FROM #temp_menu

		--DELETE sw
		----select CAST(ISNULL(sw.function_id, sw.menu_id) AS VARCHAR(100)) , CAST(ISNULL(tim.function_id, tim.id) AS VARCHAR(100))
		--FROM setup_workflow sw  
		--	LEFT JOIN #temp_inserted_menu tim			 
		--		ON CAST(sw.function_id AS VARCHAR(100)) = CAST(tim.function_id AS VARCHAR(100))
		--WHERE tim.menu_name IS NULL AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))
	
		--DELETE sw
		select CAST(ISNULL(sw.function_id, sw.menu_id) AS VARCHAR(100)) , CAST(ISNULL(tim.function_id, tim.id) AS VARCHAR(100))
		FROM setup_workflow sw  
			LEFT JOIN #temp_menu tm			 
				ON CAST(sw.function_id AS VARCHAR(100)) = CAST(tm.function_id AS VARCHAR(100))
			LEFT JOIN #temp_inserted_menu tim
				ON CAST(sw.function_id AS VARCHAR(100)) = CAST(tim.function_id AS VARCHAR(100))
		WHERE tm.menu_name IS NULL AND (user_id = ISNULL(@user_id, -1) or role_id = ISNULL(@role_id, -1))
		AND tim.menu_name IS NULL 
		
		EXEC spa_ErrorHandler 0
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'Success'
				, 'Workflow Saved Successfully.'
				, ''



		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		SET  @err = ERROR_MESSAGE()

		EXEC spa_ErrorHandler -1
				, 'Setup Workflow'
				, 'spa_workflow'
				, 'DB Error'
				, @err
				, ''
	END CATCH
	
END */	
