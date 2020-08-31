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
			
									SELECT 274,'deal_transfer',NULL,NULL,NULL,'From','g',NULL,NULL,NULL,NULL
				
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
							
												SELECT 274,'transfer_counterparty_id','Transfer Counterparty','combo','EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @not_int_ext_flag = ''b''','y','n','1','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'transfer_contract_id','Transfer Contract','combo','EXEC spa_contract_group ''r''','y','n','2','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'transfer_trader_id','Transfer Trader','combo','EXEC spa_source_traders_maintain ''y''','n','n','3','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'transfer_sub_book','Transfer Sub Book','combo','EXEC spa_get_source_book_map @flag = ''z'', @function_id=10131024','n','n','4','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'transfer_template_id','Transfer Template','combo','EXEC spa_getDealTemplate ''S''','y','n','5','y',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'counterparty_id','Offset Counterparty','combo','EXEC spa_source_counterparty_maintain @flag = ''c'', @is_active = ''y'', @not_int_ext_flag = ''b''','y','n','6','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'contract_id','Offset Contract','combo','EXEC spa_contract_group ''r''','y','n','7','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'trader_id','Offset Trader','combo','EXEC spa_source_traders_maintain ''y''','n','n','8','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'sub_book','Offset Sub Book','combo','EXEC spa_get_source_book_map @flag = ''z'', @function_id=10131024','n','n','9','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'template_id','Offset Template','combo','EXEC spa_getDealTemplate ''S''','y','n','10','y',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'location_id','Location','combo','EXEC spa_source_minor_location ''o''','y','n','12','y',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'transfer_volume','Transfer Volume','ed_v',NULL,'y','y','13','n',NULL,NULL,NULL,'180','int',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 274,'volume_per','Volume%','ed_v',NULL,'y','y','14','n',NULL,NULL,NULL,'180','int',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 274,'pricing_options','Pricing Options','combo','SELECT ''d'' [value], ''Original Deal Price'' [name] UNION ALL SELECT ''m'', ''Market Price'' UNION ALL SELECT ''x'', ''Fixed Price''','y','y','15','n',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'fixed_price','Fixed Price','ed_v',NULL,'y','y','16','n',NULL,NULL,NULL,'180','int',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 274,'transfer_date','Transfer Date','dhxCalendarA',NULL,'n','n','17','n',NULL,NULL,'n','120','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'index_adder','Index Adder','combo','EXEC spa_source_price_curve_def_maintain ''l''','n','n','18','n',NULL,NULL,NULL,'180','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 274,'fixed_adder','Fixed Adder','ed_no',NULL,'y','y','19','n',NULL,NULL,NULL,'180','float',NULL,'left', NULL,'n',NULL

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