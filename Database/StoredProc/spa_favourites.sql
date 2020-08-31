

IF OBJECT_ID(N'[dbo].[spa_favourites]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_favourites]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_favourites]
    @flag CHAR(1),
    @function_id INT = NULL,
    @product_category INT = NULL,
    @group_id VARCHAR(500) = NULL,
    @group_name VARCHAR(100) = NULL,
    @menu_id VARCHAR(5000) = NULL,
    @xml XML = NULL
AS

SET NOCOUNT ON 
DECLARE @SQL VARCHAR(MAX)
DECLARE @nsql NVARCHAR(MAX)
DECLARE @param NVARCHAR(100)
DECLARE @seq_no INT
 
IF @flag = 's' OR @flag = 't'
BEGIN
	DECLARE @user_login_id VARCHAR(500)
	SET @user_login_id = dbo.FNADBUser()
	
	IF OBJECT_ID('tempdb..#temp_favourite_items') IS NOT NULL
		DROP TABLE #temp_favourite_items
		
	CREATE TABLE #temp_favourite_items (	
		group_id INT,
		favourites_group_name VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		favourites_menu_id INT,
		favourites_menu_name VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		function_id INT,
		file_path VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		group_seq_no INT,
		seq_no INT
	)
	    
    IF dbo.FNAAppAdminRoleCheck(@user_login_id) = 0
	BEGIN
		INSERT INTO #temp_favourite_items
		SELECT fm.group_id,
			   fg.favourites_group_name,
			   fm.favourites_menu_id,
			   fm.favourites_menu_name,
			   fm.function_id,
			   fm.file_path,
			   ISNULL(fg.seq_no, -1),
			   fm.seq_no
		FROM (
			SELECT fm.favourites_menu_id, fm.favourites_menu_name, fm.group_id, fm.function_id, fm.file_path, fm.seq_no
			FROM application_functional_users afu
			INNER JOIN favourites_menu fm ON fm.function_id = afu.function_id 
			WHERE login_id = @user_login_id AND fm.create_user = dbo.FNADBUser()
			UNION				
			SELECT fm.favourites_menu_id, fm.favourites_menu_name, fm.group_id, fm.function_id, fm.file_path, fm.seq_no 
			FROM application_functional_users afu 
			INNER JOIN favourites_menu fm ON fm.function_id = afu.function_id 
			INNER JOIN application_role_user aru ON afu.role_id = aru.role_id
			WHERE aru.user_login_id = @user_login_id AND fm.create_user = dbo.FNADBUser()			
		) fm 
		LEFT JOIN favourites_group fg ON fg.favourites_group_id = fm.group_id AND fg.create_user = @user_login_id
	END
	ELSE
	BEGIN
		INSERT INTO #temp_favourite_items
		SELECT fm.group_id,
			   fg.favourites_group_name,
			   fm.favourites_menu_id,
			   fm.favourites_menu_name,
			   fm.function_id,
			   fm.file_path,
			   ISNULL(fg.seq_no, -1),
			   fm.seq_no
		FROM favourites_menu fm
		LEFT JOIN favourites_group fg ON fg.favourites_group_id = fm.group_id AND fg.create_user = @user_login_id
		WHERE fm.create_user = @user_login_id
	END
	IF @flag = 't'
	BEGIN
		 IF NOT EXISTS(SELECT 1 FROM #temp_favourite_items WHERE group_id = -1) 
		 BEGIN
		 	INSERT INTO #temp_favourite_items ( group_id, favourites_group_name, group_seq_no)
		 	SELECT -1, '...', -1 
		 END
		 
		 SELECT group_id, favourites_group_name, favourites_menu_id, favourites_menu_name
		 FROM (
			 SELECT 'g_' + CAST(group_id AS varchar(20)) group_id,
					ISNULL(favourites_group_name, '...') favourites_group_name,
					'm_' + CAST(favourites_menu_id AS VARCHAR(20)) favourites_menu_id,
					favourites_menu_name,
					group_seq_no,
					seq_no
			 FROM #temp_favourite_items
			 UNION ALL
			 SELECT 'g_' + CAST(fg.favourites_group_id AS VARCHAR(10)) group_id, 
				fg.favourites_group_name,
				NULL favourites_menu_id,
				NULL favourites_menu_name,
				fg.seq_no group_seq_no,
				10000 seq_no
			FROM   favourites_group fg
			LEFT JOIN #temp_favourite_items temp 
		 	ON  fg.favourites_group_id = temp.group_id
			WHERE fg.create_user = dbo.FNADBUser()
			AND temp.group_id IS NULL
		 ) a
		 ORDER BY group_seq_no, seq_no
		RETURN
	END
	
	IF OBJECT_ID('tempdb..#temp_favourite_json') IS NOT NULL
		DROP TABLE #temp_favourite_json
	
	CREATE TABLE #temp_favourite_json (group_id INT, group_name VARCHAR(500) COLLATE DATABASE_DEFAULT , json VARCHAR(MAX) COLLATE DATABASE_DEFAULT , seq_no INT)
	
	DECLARE @json VARCHAR(MAX)
	DECLARE group_cursor CURSOR FORWARD_ONLY READ_ONLY 
	FOR
		SELECT group_id, favourites_group_name, group_seq_no      
		FROM #temp_favourite_items
		GROUP BY group_id, favourites_group_name, group_seq_no
		ORDER by group_seq_no
	OPEN group_cursor
	FETCH NEXT FROM group_cursor INTO @group_id, @group_name,@seq_no
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		SET @param = N'@xml XML OUTPUT';
	
		SET @nsql = ' SET @xml = (
							   SELECT 
							   favourites_menu_id,
							   favourites_menu_name,
							   menu.function_id,
							   i.window_name,
							   file_path								
						FROM #temp_favourite_items menu
						LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = menu.function_id	
						WHERE menu.group_id = ' + CAST(@group_id AS VARCHAR(20)) + '
						ORDER by seq_no
						FOR xml RAW(''menu''), ROOT(''root''), ELEMENTS)'
		EXECUTE sp_executesql @nsql, @param, @xml = @xml OUTPUT;
				
		SET @json = dbo.FNAFlattenedJSON(@xml)
		IF SUBSTRING(@json, 1, 1) <> '['
		BEGIN
			SET @json = '[' + @json + ']'
		END
		
		INSERT INTO #temp_favourite_json(group_id, group_name, json, seq_no)
		SELECT @group_id, @group_name, @json, @seq_no
		
		FETCH NEXT FROM group_cursor INTO @group_id, @group_name, @seq_no
	END
	CLOSE group_cursor
	DEALLOCATE group_cursor
	
	SELECT group_id, group_name, json
	FROM (
		SELECT group_id, group_name, json, temp.seq_no
		FROM #temp_favourite_json temp
		UNION ALL
		SELECT fg.favourites_group_id, fg.favourites_group_name, NULL json, 1000 seq_no
		FROM favourites_group fg
		LEFT JOIN #temp_favourite_json temp ON fg.favourites_group_id = temp.group_id
		WHERE fg.create_user = dbo.FNADBUser() AND temp.group_id IS NULL
	) a
	ORDER by seq_no
END
ELSE IF @flag = 'd'
BEGIN
	IF @function_id IS NOT NULL
	BEGIN
		DELETE FROM favourites_menu WHERE function_id = @function_id AND create_user = dbo.FNADBUser()
	END
	
	IF @menu_id IS NOT NULL
	BEGIN
		DELETE fm 
		FROM favourites_menu fm
		INNER JOIN dbo.SplitCommaSeperatedValues(@menu_id) scsv ON fm.favourites_menu_id = CAST(REPLACE(scsv.item, 'm_', '') AS INT)
	END
	
	IF @group_id IS NOT NULL
	BEGIN
		DELETE fm 
		FROM favourites_menu fm
		INNER JOIN dbo.SplitCommaSeperatedValues(@group_id) scsv ON fm.group_id = CAST(REPLACE(scsv.item, 'g_', '') AS INT)
		
		DELETE fg 
		FROM favourites_group fg
		INNER JOIN dbo.SplitCommaSeperatedValues(@group_id) scsv ON fg.favourites_group_id = CAST(REPLACE(scsv.item, 'g_', '') AS INT)
	END
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY	
		IF @group_id = 0
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM favourites_group WHERE favourites_group_name = @group_name)
			BEGIN
				SELECT @seq_no = ISNULL(MAX(seq_no), 0) + 1 FROM favourites_group
				INSERT INTO favourites_group (
					favourites_group_name,
					seq_no
				)
				SELECT @group_name, @seq_no
		
				SET @group_id = SCOPE_IDENTITY()
			END
			ELSE 
			BEGIN
				EXEC spa_ErrorHandler 0
				, 'favourites'
				, 'spa_favourites'
				, 'Error' 
				, 'Group Name already exists.'
				, ''
				
				RETURN
			END
			
		END
		
		SELECT @seq_no = ISNULL(MAX(seq_no), 0) + 1 FROM favourites_menu WHERE group_id = @group_id
		INSERT INTO favourites_menu (
			favourites_menu_name,
			group_id,
			function_id,
			file_path,
			seq_no
		)
		SELECT sm.display_name,
				@group_id,
				af.function_id,
				af.file_path,
				@seq_no
		FROM application_functions af
		INNER JOIN setup_menu sm ON sm.function_id = af.function_id
		WHERE af.function_id = @function_id AND sm.product_category = @product_category
	
		EXEC spa_ErrorHandler 0
			, 'favourites'
			, 'spa_favourites'
			, 'Success' 
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		DECLARE @DESC VARCHAR(500)
		DECLARE @err_no INT
 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'favourites'
		   , 'spa_favourites'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH	
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		DECLARE @idoc  INT
		
		--Create an internal representation of the XML document.
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		-- Create temp table to store xml data
		IF OBJECT_ID('tempdb..#temp_favourite_update') IS NOT NULL
			DROP TABLE #temp_favourite_update
	
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT group_id        group_id,
		       group_name      group_name,
		       group_order     group_order,
		       menu_id         menu_id,
		       menu_name       menu_name,
		       menu_order menu_order
		       INTO            #temp_favourite_update
		FROM OPENXML(@idoc, '/Root/TNode', 1)
		WITH (
		    group_id VARCHAR(20),
		    group_name VARCHAR(100),
		    group_order INT,
		    menu_id VARCHAR(20),
		    menu_name VARCHAR(1000),
		    menu_order INT
		)
		
		IF OBJECT_ID('tempdb..#temp_groups_update') IS NOT NULL
			DROP TABLE #temp_groups_update
		
		IF OBJECT_ID('tempdb..#temp_menu_update') IS NOT NULL
			DROP TABLE #temp_menu_update
			
		SELECT REPLACE(group_id, 'g_', '') group_id,
		       group_name,
		       MAX(group_order) group_order
		INTO #temp_groups_update
		FROM #temp_favourite_update
		GROUP BY group_id, group_name
		
		SELECT REPLACE(group_id, 'g_', '') group_id,
		       REPLACE(menu_id, 'm_', '') menu_id,
		       menu_name,
		       menu_order
		INTO #temp_menu_update
		FROM #temp_favourite_update
		
		DELETE fm
		FROM favourites_menu fm
		LEFT JOIN #temp_menu_update temp ON fm.favourites_menu_id = temp.menu_id
		WHERE fm.create_user = dbo.FNADBUser() AND temp.menu_id IS NULL
		
		DELETE fg
		FROM favourites_group fg
		LEFT JOIN #temp_groups_update temp ON fg.favourites_group_id = temp.group_id
		WHERE fg.create_user = dbo.FNADBUser() AND temp.group_id IS NULL
		
		UPDATE fm
		SET  group_id = temp.group_id,
			 seq_no = temp.menu_order
		FROM favourites_menu fm
		INNER JOIN #temp_menu_update temp ON fm.favourites_menu_id = temp.menu_id
		
		IF EXISTS (SELECT 1 FROM #temp_groups_update WHERE group_name = '')
		BEGIN
			--PRINT 'ERROR'
			--SELECT @err_no = ERROR_NUMBER()
			EXEC spa_ErrorHandler -1
		   , 'favourites'
		   , 'spa_favourites'
		   , 'Error'
		   , 'Please insert the group name.'
		   , ''
		END
		ELSE 
			BEGIN
		UPDATE fg
		SET favourites_group_name = temp.group_name,
			seq_no = temp.group_order
		FROM favourites_group fg
		INNER JOIN #temp_groups_update temp ON fg.favourites_group_id = temp.group_id
		
		EXEC spa_ErrorHandler 0
			, 'favourites'
			, 'spa_favourites'
			, 'Success' 
				, 'Changes have been saved successfully.'
			, ''
			END
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @desc = 'Fail to save data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'favourites'
		   , 'spa_favourites'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END
