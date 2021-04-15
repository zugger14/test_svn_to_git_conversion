
BEGIN
		BEGIN TRY
		BEGIN TRAN
			

		IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
			DROP TABLE #temp_all_grids

		CREATE TABLE #temp_all_grids (
			old_grid_id		INT,
			new_grid_id     INT,
			grid_name       varchar(200) COLLATE DATABASE_DEFAULT,
			fk_table		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			fk_column		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			load_sql		VARCHAR(800) COLLATE DATABASE_DEFAULT,
			grid_label		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			grid_type		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			grouping_column	VARCHAR(200) COLLATE DATABASE_DEFAULT,
			edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT,
			delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_new			VARCHAR(200) COLLATE DATABASE_DEFAULT
		) 
	
				
		INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission)
			
								SELECT 26,'view_scheduled_job','','','EXEC spa_get_schedule_job @flag=''s''','','g',NULL,NULL,NULL
				
		UPDATE tag
		SET tag.new_grid_id = agd.grid_id
		FROM #temp_all_grids tag
		INNER JOIN adiha_grid_definition AS agd
		ON agd.grid_name = tag.grid_name
				
		UPDATE tag
		SET tag.is_new = 'y'
		FROM #temp_all_grids tag
		WHERE tag.new_grid_id IS NULL
			
		IF EXISTS(SELECT 1 FROM #temp_all_grids WHERE is_new LIKE 'y')
		BEGIN
					
			INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission)
			SELECT grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission
			FROM #temp_all_grids
			WHERE is_new LIKE 'y'
				
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
				delete_permission = tag.delete_permission
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
			

						DELETE FROM adiha_grid_columns_definition WHERE grid_id = @grid_id
															
						IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
							DROP TABLE #temp_all_grids_columns

						CREATE TABLE #temp_all_grids_columns(
							grid_id			INT,
							column_name		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							column_label	VARCHAR(200) COLLATE DATABASE_DEFAULT,
							field_type		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							sql_string		VARCHAR(5000) COLLATE DATABASE_DEFAULT,
							is_editable		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							is_required		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							column_order	INT,
							is_hidden		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							fk_table		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							fk_column		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							is_unique		VARCHAR(200) COLLATE DATABASE_DEFAULT,
							column_width	VARCHAR(200) COLLATE DATABASE_DEFAULT,
							sorting_preference VARCHAR(200) COLLATE DATABASE_DEFAULT,
							validation_rule VARCHAR(200) COLLATE DATABASE_DEFAULT,
							column_alignment VARCHAR(200) COLLATE DATABASE_DEFAULT
						)	
				
						INSERT INTO #temp_all_grids_columns(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment)
							
											SELECT 26,'name','Job Name','ro',NULL,'y','y','1','n',NULL,NULL,NULL,'400','str',NULL,'left' UNION ALL 
											SELECT 26,'date_created','Date Created','ro',NULL,'y','y','2','n',NULL,NULL,NULL,'200','date',NULL,'left' UNION ALL 
											SELECT 26,'next_scheduled_run_date','Next Scheduled Run Date','ro',NULL,'y','y','3','n',NULL,NULL,NULL,'200','date',NULL,'left' UNION ALL 
											SELECT 26,'last_exectued_step_date','Last Executed Date','ro',NULL,'y','y','4','n',NULL,NULL,NULL,'200','date',NULL,'left' UNION ALL 
											SELECT 26,'owner_sid','Job Owner','ro',NULL,'y','y','5','n',NULL,NULL,NULL,'200','str',NULL,'left' UNION ALL 
											SELECT 26,'run_status','Job Status','ro',NULL,'y','y','6','n',NULL,NULL,NULL,'200','str',NULL,'left' UNION ALL 
											SELECT 26,'date_modified','Date Modified','ro',NULL,'y','y','7','n',NULL,NULL,NULL,'200','date',NULL,'left' UNION ALL 
											SELECT 26,'user_name','User Name','ro',NULL,'y','y','8','n',NULL,NULL,NULL,'200','str',NULL,'left' UNION ALL
											SELECT 26,'description','Description','ro',NULL,'y','y','9','n',NULL,NULL,NULL,'300','str',NULL,'left' UNION ALL
											SELECT 26,'job_id','Job ID','ro',NULL,'y','y','10','y',NULL,NULL,NULL,'300','str',NULL,'left' UNION ALL
											SELECT 26,'is_enabled','Enabled','ro',NULL,'y','y','11','y',NULL,NULL,NULL,'200','str',NULL,'left' UNION ALL
											SELECT 26,'batch_type','Batch Type','ro',NULL,'y','y','12','y',NULL,NULL,NULL,'200','str',NULL,'left'

							
						UPDATE tagc
						SET tagc.grid_id = @grid_id
						FROM #temp_all_grids_columns tagc
						
						INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment)
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
								tagc.column_alignment
										
						FROM #temp_all_grids_columns tagc
					
	COMMIT 
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRAN;
					
			PRINT 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
		END CATCH
			
		IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
			DROP TABLE #temp_all_grids
                           
		IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
			DROP TABLE #temp_all_grids_columns
				
	END
