
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
			
									SELECT 188,'Match',NULL,NULL,NULL,'Match','g',NULL,'10163720','10163720'
				
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
							
												SELECT 188,'receipts_delivery','Receipt/Delivery','ro',NULL,'n','n','1',NULL,NULL,NULL,NULL,'75','str',NULL,'left' UNION ALL 
												SELECT 188,'deal','Deal','ro',NULL,'n','n','2',NULL,NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 188,'counterparty','Counterparty','ro',NULL,'n','n','3',NULL,NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 188,'quantity','Total Scheduling Line Quantity','ro',NULL,'n','n','6',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 188,'lineup','Lineup','ro',NULL,'n','n','8',NULL,NULL,NULL,NULL,'350','str',NULL,'left' UNION ALL 
												SELECT 188,'movement_date','Estimated Movement Date','dhxCalendarDT',NULL,'y','n','9',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 188,'commodity','Commodity','ro',NULL,'n','n','12',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 188,'location','Location','ro',NULL,'n','n','11',NULL,NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 188,'sch_period','Sched Period','ro',NULL,'n','n','13',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 188,'comment','Comment','ed',NULL,'n','n','14',NULL,NULL,NULL,NULL,'350','str',NULL,'left' UNION ALL 
												SELECT 188,'actual_volume','Actual Quantity','ro',NULL,'n','n','7','n',NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 188,'is_completed','Completed','combo','SELECT 1 AS [value], ''Yes'' AS [label] UNION ALL SELECT  0 AS [value], ''No'' AS [label]','n','n','15','n',NULL,NULL,NULL,'75','str',NULL,'left' UNION ALL 
												SELECT 188,'source_deal_detail_id','Detail ID','ron',NULL,'n','n','16','y',NULL,NULL,NULL,'150','int',NULL,'left' UNION ALL 
												SELECT 188,'split_id','Split ID','ron',NULL,'n','n','17','y',NULL,NULL,NULL,'150','int',NULL,'left' UNION ALL 
												SELECT 188,'sch_quantity','Scheduling Line Quantity','edn',NULL,'n','n','5','n',NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 188,'available_qty','Available Quantity','ron',NULL,'n','n','4','n',NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 188,'seq_no','seq_no','ron',NULL,'n','n','18','y',NULL,NULL,NULL,'150','int',NULL,'left' UNION ALL 
												SELECT 188,'inco_terms','INCOTerm','ron',NULL,'n','y','19','n',NULL,NULL,'n','150','int',NULL,'left' UNION ALL 
												SELECT 188,'crop_year','Crop Year','ron',NULL,'n','y','20','n',NULL,NULL,'n','150','int',NULL,'left' UNION ALL 
												SELECT 188,'lot','Lot','ed',NULL,'n','y','21','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 188,'batch_id','Batch','ed',NULL,'n','y','22','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 188,'est_movement_date_to','Estimated Movement Date To','dhxCalendarDT',NULL,'y','n','10','n',NULL,NULL,'y','150','str',NULL,'left'
							
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
					
				--EXEC spa_print 'Error (' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ') at Line#' + CAST(ERROR_LINE() AS VARCHAR(10)) + ':' + ERROR_MESSAGE() + ''
			END CATCH
			
			IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
				DROP TABLE #temp_all_grids
                           
			IF OBJECT_ID('tempdb..#temp_all_grids_columns') IS NOT NULL
				DROP TABLE #temp_all_grids_columns
				
	END 