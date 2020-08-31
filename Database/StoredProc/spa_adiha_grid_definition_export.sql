IF OBJECT_ID(N'[dbo].[spa_adiha_grid_definition_export]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_adiha_grid_definition_export]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Procedure created to export the grid and its columns definitions.

	Parameters:
		@grid_name	:	Unique name of the grid (that you want to generate script of) specified in grid definitions table.
*/

CREATE PROCEDURE [dbo].[spa_adiha_grid_definition_export]
	@grid_name VARCHAR(50)
AS

DECLARE @select_statement VARCHAR(MAX)
DECLARE @VeryLongText NVARCHAR(MAX) = '';
DECLARE @xml XML

SET NOCOUNT ON

BEGIN
	
	IF OBJECT_ID('tempdb..#temp_xml_output') IS NOT NULL
		DROP TABLE #temp_xml_output
	
	CREATE TABLE #temp_xml_output (template_name VARCHAR(400) COLLATE DATABASE_DEFAULT , xml_string XML)
	
	IF OBJECT_ID('tempdb..#temp_final_query') IS NOT NULL
		DROP TABLE #temp_final_query

	CREATE TABLE #temp_final_query (id INT IDENTITY(1,1), final_query VARCHAR(MAX) COLLATE DATABASE_DEFAULT )

	INSERT INTO #temp_final_query(final_query)
	SELECT 'BEGIN
			BEGIN TRY
			BEGIN TRAN
			'
			
	-- adiha_grid_definition
	
	
	IF OBJECT_ID('tempdb..#all_grids') IS NOT NULL
		DROP TABLE #all_grids
		
	CREATE TABLE #all_grids(
		grid_id				INT,
		grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		fk_table			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		fk_column			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		load_sql			VARCHAR(800) COLLATE DATABASE_DEFAULT ,
		grid_label			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		grid_type			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		grouping_column		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
		split_at			INT
	)

	INSERT INTO #all_grids(grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission)
	SELECT agd.grid_id, agd.grid_name,agd.fk_table,agd.fk_column,agd.load_sql,agd.grid_label,agd.grid_type,agd.grouping_column, agd.edit_permission, agd.delete_permission
	FROM adiha_grid_definition AS agd
	WHERE agd.grid_name = @grid_name
	
	
	INSERT INTO #temp_final_query(final_query)
	SELECT '
			IF OBJECT_ID(''tempdb..#temp_all_grids'') IS NOT NULL
				DROP TABLE #temp_all_grids

			CREATE TABLE #temp_all_grids (
				old_grid_id			INT,
				new_grid_id			INT,
				grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				fk_table			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				fk_column			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				load_sql			VARCHAR(800) COLLATE DATABASE_DEFAULT ,
				grid_label			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				grid_type			VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				grouping_column		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				is_new				VARCHAR(200) COLLATE DATABASE_DEFAULT ,
				split_at			INT	
			) '
	
	IF EXISTS(SELECT 1 FROM #all_grids)
	BEGIN
		
		SET @select_statement = NULL
		SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
									SELECT ' + CAST(grid_id AS VARCHAR(100)) + ',''' 
									+ grid_name + ''','
									+ ISNULL('''' + fk_table  + '''', 'NULL') + ',' 
									+ ISNULL('''' + fk_column  + '''', 'NULL') + ',' 
									+ ISNULL('''' + REPLACE(load_sql, '''', '''''') + '''', 'NULL') + ',' 
									+ ISNULL('''' + grid_label  + '''', 'NULL') + ',' 
									+ ISNULL('''' + CAST(grid_type AS VARCHAR(10)) + '''', 'NULL') + ',' 
									+ ISNULL('''' + grouping_column + '''', 'NULL') + ',' 
									+ ISNULL('''' + edit_permission + '''', 'NULL') + ','
									+ ISNULL('''' + delete_permission + '''', 'NULL') + ','
									+ ISNULL('''' + CAST(split_at AS VARCHAR(10)) + '''', 'NULL')							
		FROM #all_grids
			
			
		INSERT INTO #temp_final_query(final_query)
		SELECT '	
				
			INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
			' + @select_statement + '
				
			UPDATE tag
			SET tag.new_grid_id = agd.grid_id
			FROM #temp_all_grids tag
			INNER JOIN adiha_grid_definition AS agd
			ON agd.grid_name = tag.grid_name
				
			UPDATE tag
			SET tag.is_new = ''y''
			FROM #temp_all_grids tag
			WHERE tag.new_grid_id IS NULL
			
			IF EXISTS(SELECT 1 FROM #temp_all_grids WHERE is_new LIKE ''y'')
			BEGIN
					
				INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
				SELECT grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at
				FROM #temp_all_grids
				WHERE is_new LIKE ''y''
				
			END
			ELSE
			BEGIN
				
				UPDATE agd
				SET
					grid_name = tag.grid_name,
					fk_table = tag.fk_table,
					fk_column = tag.fk_column,
					load_sql = tag.load_sql,
					grid_label = tag.grid_label,
					grid_type = tag.grid_type,
					grouping_column = tag.grouping_column,
					edit_permission = tag.edit_permission,
					delete_permission = tag.delete_permission,
					split_at = tag.split_at
				FROM adiha_grid_definition AS agd
				INNER JOIN #temp_all_grids AS tag
				ON tag.new_grid_id = agd.grid_id
				
			END
			UPDATE tag
			SET tag.new_grid_id = agd.grid_id
			FROM #temp_all_grids tag
			INNER JOIN adiha_grid_definition AS agd
			ON agd.grid_name = tag.grid_name
			
			DECLARE @grid_id INT
			SELECT TOP 1 @grid_id = new_grid_id
			FROM #temp_all_grids
			'
				
				IF EXISTS(SELECT 1 FROM adiha_grid_columns_definition AS agcd INNER JOIN #all_grids ag ON ag.grid_id = agcd.grid_id)
				BEGIN
						
					SET @select_statement = NULL
	
					SELECT @select_statement = COALESCE(@select_statement + ' UNION ALL ', '') + '
												SELECT ' + CAST(agcd.grid_id AS VARCHAR(10)) + ','''
												+ agcd.column_name + ''',''' 
												+ agcd.column_label + ''',''' 
												+ agcd.field_type + ''',' 	
												+ ISNULL('''' + REPLACE(agcd.sql_string, '''', '''''') + '''', 'NULL') + ',''' 
												+ ISNULL(agcd.is_editable, 'n') + ''','''  
												+ ISNULL(agcd.is_required, 'y') + ''',' 
												+ ISNULL('''' + CAST(agcd.column_order AS VARCHAR(10)) + '''', 'NULL') + ',' 
												+ ISNULL('''' + CAST(agcd.is_hidden AS VARCHAR(10)) + '''', 'NULL') + ',' 
												+ ISNULL('''' + agcd.fk_table  + '''', 'NULL') + ',' 
												+ ISNULL('''' + agcd.fk_column  + '''', 'NULL') + ',' 
												+ ISNULL('''' + CAST(agcd.is_unique AS VARCHAR(10)) + '''', 'NULL') + ','
												+ ISNULL('''' + CAST(agcd.column_width AS VARCHAR(10)) + '''', 'NULL') + ',' 
												+ ISNULL('''' + agcd.sorting_preference  + '''', 'NULL') + ',' 
												+ ISNULL('''' + agcd.validation_rule  + '''', 'NULL') + ','
												+ ISNULL('''' + agcd.column_alignment  + '''', 'NULL') + ', '
                                                + ISNULL('''' + agcd.browser_grid_id + '''', 'NULL') + ','
												+ ISNULL('''' + CAST(agcd.allow_multi_select AS VARCHAR(10)) + '''', 'NULL') + ','
												+ ISNULL('''' + CAST(agcd.rounding AS VARCHAR(20)) + '''', 'NULL')
					FROM adiha_grid_columns_definition AS agcd
					INNER JOIN #all_grids ag
					ON ag.grid_id = agcd.grid_id

					-- adiha_grid_columns_definition

					INSERT INTO #temp_final_query(final_query)
					SELECT '
							DELETE FROM adiha_grid_columns_definition WHERE grid_id = @grid_id

							IF OBJECT_ID(''tempdb..#temp_all_grids_columns'') IS NOT NULL
								DROP TABLE #temp_all_grids_columns

							CREATE TABLE #temp_all_grids_columns(
								grid_id			INT,
								column_name		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								column_label	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								field_type		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								sql_string		VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
								is_editable		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								is_required		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								column_order	INT,
								is_hidden		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								fk_table		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								fk_column		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								is_unique		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								column_width	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								sorting_preference VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								validation_rule VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								column_alignment VARCHAR(200) COLLATE DATABASE_DEFAULT ,
								browser_grid_id VARCHAR(200) COLLATE DATABASE_DEFAULT,
								allow_multi_select CHAR(1) COLLATE DATABASE_DEFAULT,
								rounding VARCHAR(20) COLLATE DATABASE_DEFAULT
							)

							INSERT INTO #temp_all_grids_columns(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, browser_grid_id, allow_multi_select, rounding)
							' + @select_statement + '

							UPDATE tagc
							SET tagc.grid_id = @grid_id
							FROM #temp_all_grids_columns tagc

							INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, browser_grid_id, allow_multi_select, rounding)
							SELECT	tagc.grid_id,
									tagc.column_name,
									tagc.column_label,
									tagc.field_type,
									tagc.sql_string,
									tagc.is_editable,
									tagc.is_required,
									tagc.column_order,
									tagc.is_hidden,
									tagc.fk_table,
									tagc.fk_column,
									tagc.is_unique,
									tagc.column_width,
									tagc.sorting_preference,
									tagc.validation_rule,
									tagc.column_alignment,
									tagc.browser_grid_id,
									tagc.allow_multi_select,
									tagc.rounding
										
							FROM #temp_all_grids_columns tagc
					'
				END
	END
	
	INSERT INTO #temp_final_query(final_query)
	SELECT  'COMMIT 
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
					
				--EXEC spa_print ''Error ('' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + '') at Line#'' + CAST(ERROR_LINE() AS VARCHAR(10)) + '':'' + ERROR_MESSAGE() + ''''
			END CATCH
			
			IF OBJECT_ID(''tempdb..#temp_all_grids'') IS NOT NULL
				DROP TABLE #temp_all_grids
                           
			IF OBJECT_ID(''tempdb..#temp_all_grids_columns'') IS NOT NULL
				DROP TABLE #temp_all_grids_columns
				
		END '
	                 	
	SELECT @VeryLongText = COALESCE(@VeryLongText + CHAR(13) + CHAR(10), '') + ISNULL(final_query, '') FROM #temp_final_query ORDER BY id ASC	
						
	SELECT @xml = (SELECT @VeryLongText AS [processing-instruction(x)] FOR XML PATH(''))
			
	INSERT INTO #temp_xml_output
	SELECT @grid_name, @xml

	SELECT template_name [Grid Name], xml_string [Export Script] FROM #temp_xml_output

	--SELECT final_query FROM #temp_final_query
	--ORDER BY id
	
END