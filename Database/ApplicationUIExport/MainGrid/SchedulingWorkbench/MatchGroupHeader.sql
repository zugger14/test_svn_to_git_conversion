 BEGIN
			BEGIN TRY
			BEGIN TRAN
			

			IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
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
			) 
	
				
			INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
			
									SELECT 218,'MatchGroupHeader',NULL,NULL,NULL,'Match Group Header','g',NULL,'10163700','10163700',NULL
				
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
					
				INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
				SELECT grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at
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
			

							DELETE FROM adiha_grid_columns_definition WHERE grid_id = @grid_id

							IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
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
							
												SELECT 218,'match_group_id','Match Group ID','ro',NULL,'n','y','2','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'match_bookout','Bookout/Match','ro',NULL,'n','y','3','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'match_book_auto_id','Match','ro',NULL,'n','y','4','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'location_name','Location','ro',NULL,'n','y','6','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'scheduler','Scheduler','ro',NULL,'n','y','7','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'last_edited_by','Last Edited By','ro',NULL,'n','y','8','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'last_edited_on','Last Edited On','ro',NULL,'n','y','9','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'header_status','Status','ro',NULL,'n','y','10','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'scheduled_from','Schedule From','ro',NULL,'n','y','11','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'scheduled_to','Schedule To','ro',NULL,'n','y','12','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'match_number','Match Number','ro',NULL,'n','y','13','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'comments','Comments','ro',NULL,'n','y','14','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'pipeline_cycle','Pipeline Cycle','ro',NULL,'n','y','15','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'consignee','Consignee','ro',NULL,'n','y','16','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'carrier','Carrier','ro',NULL,'n','y','17','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'po_number','CPO Number','ro',NULL,'n','y','18','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'container','Container','ro',NULL,'n','y','19','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'line_up','Line Up','ro',NULL,'n','y','20','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'product','Product','ro',NULL,'n','y','21','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'estimated_movement_date','Est. Movement Date','ro',NULL,'n','y','22','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'container_number','Container Number','ro',NULL,'n','y','24','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'est_movement_date_to','Est. Movement Date To','ro',NULL,'n','y','23','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 218,'bookout_match_total_amount','Amount','ro_a',NULL,'n','y','5','n',NULL,NULL,'n','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 218,'match_group_header_id','','sub_row_grid',NULL,'n','y','1','n',NULL,NULL,'n','30','str',NULL,'left', NULL,'n',NULL

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
					
COMMIT 
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN;
					
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			
			IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
				DROP TABLE #temp_all_grids
                           
			IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
				DROP TABLE #temp_all_grids_columns
				
		END 