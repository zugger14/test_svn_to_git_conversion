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
			
									SELECT 219,'MatchGroupDetail',NULL,NULL,NULL,'Match Group Detail','g',NULL,'10163700','10163700',NULL
				
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
							
												SELECT 219,'match_group_detail_id','Match Group Detail ID','ro',NULL,'n','y','1','y',NULL,NULL,'n','30','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'deal_id','Deal ID','ro',NULL,'n','y','2','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'location_name','Location','ro',NULL,'n','y','3','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'contract_name','Contract','ro',NULL,'n','y','4','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'commodity_name','Commodity','ro',NULL,'n','y','5','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'source_commodity_id','source_commodity_id','ro',NULL,'n','y','9','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'scheduling_period','Scheduling Period','ro',NULL,'n','y','10','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'notes','Notes','ro',NULL,'n','y','11','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'source_deal_detail_id','Detail ID','ro',NULL,'n','y','12','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'lot','Lot','ro',NULL,'n','y','14','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'batch_id','Batch ID','ro',NULL,'n','y','15','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'inco_terms','INCO Terms','ro',NULL,'n','y','16','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'crop_year','Crop Year','ro',NULL,'n','y','17','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'counterparty_id','Counterparty','ro',NULL,'n','y','18','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'source_deal_type_name','Deal Type','ro',NULL,'n','y','19','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'is_complete','Complete','ro',NULL,'n','y','20','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'frequency','Frequency','ro',NULL,'n','y','21','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'region','Region','ro',NULL,'n','y','22','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'match_group_id','Match Group ID','ro',NULL,'n','y','23','y',NULL,NULL,'y','30','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'unmoved_amt','Un Moved Amount','ro_a',NULL,'n','y','8','n',NULL,NULL,'n','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 219,'split_deal_detail_volume_id','Split Deal Detail Volume ID','ro_int',NULL,'n','y','13','y',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 219,'bookout_split_volume','Bookout/Match Volume','ro_v',NULL,'n','y','6','n',NULL,NULL,'n','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 219,'act_vol','Actual Volume','ro_v',NULL,'n','y','7','n',NULL,NULL,'n','150','str',NULL,'right', NULL,'n',NULL

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