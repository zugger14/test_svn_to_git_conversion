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
			
									SELECT 354,'StoragePosition',NULL,NULL,NULL,'Storage Position','t','grouper,location_name','10163740','10163740',NULL
				
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
							
												SELECT 354,'source_minor_location_id','Location ID','ro',NULL,'n','y','2','y',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'purchase_deal_id','Purchase Deal ID','ro',NULL,'n','y','3','y',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'lot','Lot','ro',NULL,'n','y','6','y',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'purchase_deal_sub_type','Purchase Deal Sub Type','ro',NULL,'n','y','8','y',NULL,NULL,'y','200','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'contract','Contract','ro',NULL,'n','y','11','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'operator','Operator','ro',NULL,'n','y','12','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'product','Product','ro',NULL,'n','y','13','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'convert_quantity_uom','Convert Quantity UOM','ro',NULL,'n','y','18','n',NULL,NULL,'y','180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'currency','Currency','ro',NULL,'n','y','24','n',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'original_quantity_uom','Original Quantity UOM','ro',NULL,'n','y','19','n',NULL,NULL,'y','200','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'convert_price_uom','Convert Price UOM','ro',NULL,'n','y','26','n',NULL,NULL,'y','180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'parent_source_deal_header_id','Parent ID','ro',NULL,'n','y','29','y',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'commodity_id','Commodity ID','ro',NULL,'n','y','30','y',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'storage_deal_id','Storage Deal ID','ro',NULL,'n','y','33','y',NULL,NULL,'y','180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'seq_no','Seq No','ro',NULL,'n','y','34','y',NULL,NULL,'y','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'pipeline_id','Pipeline','ro',NULL,'n','y','35','y',NULL,NULL,'y','50','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 354,'inventory_amount','Inventory Amount','ro_a',NULL,'n','y','32','y',NULL,NULL,'y','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 354,'balance_quantity','Scheduled Quantity','ro_no',NULL,'n','y','15','n',NULL,NULL,'y','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 354,'actual_volume','Actual Quantity','ro_no',NULL,'n','y','16','n',NULL,NULL,'y','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 354,'storage_receipt_quantity','Storage Receipt Quantity','ro_no',NULL,'n','y','17','n',NULL,NULL,'y','200','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 354,'price','Price','ro_no',NULL,'n','y','25','n',NULL,NULL,'y','150','str',NULL,'right', NULL,'n',NULL UNION ALL 
												SELECT 354,'grouper','Location/In-Transit','tree',NULL,'n','n','1',NULL,NULL,NULL,NULL,'320','str',NULL,'left', NULL,'n',NULL

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