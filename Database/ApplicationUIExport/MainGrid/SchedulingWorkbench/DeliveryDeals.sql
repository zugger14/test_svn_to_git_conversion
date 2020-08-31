 BEGIN
			BEGIN TRY
			BEGIN TRAN
			

			IF OBJECT_ID('tempdb..#temp_all_grids') IS NOT NULL
				DROP TABLE #temp_all_grids

			CREATE TABLE #temp_all_grids (
				old_grid_id			INT,
				new_grid_id			INT,
				grid_name			VARCHAR(200) COLLATE DATABASE_DEFAULT,
				fk_table			VARCHAR(200) COLLATE DATABASE_DEFAULT,
				fk_column			VARCHAR(200) COLLATE DATABASE_DEFAULT,
				load_sql			VARCHAR(800) COLLATE DATABASE_DEFAULT,
				grid_label			VARCHAR(200) COLLATE DATABASE_DEFAULT,
				grid_type			VARCHAR(200) COLLATE DATABASE_DEFAULT,
				grouping_column		VARCHAR(200) COLLATE DATABASE_DEFAULT,
				edit_permission		VARCHAR(200) COLLATE DATABASE_DEFAULT,
				delete_permission	VARCHAR(200) COLLATE DATABASE_DEFAULT,
				is_new				VARCHAR(200) COLLATE DATABASE_DEFAULT,
				split_at			INT	
			) 
	
				
			INSERT INTO #temp_all_grids(old_grid_id, grid_name, fk_table, fk_column, load_sql, grid_label, grid_type, grouping_column, edit_permission, delete_permission, split_at)
			
									SELECT 225,'DeliveryDeals',NULL,NULL,NULL,'Delivery','g',NULL,'10163700','10163700',NULL
				
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
							
												SELECT 225,'deal_id','Deal ID','ron',NULL,'n','n','1',NULL,NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 225,'deal_type','Deal Type','ro',NULL,'n','n','2',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 225,'counterparty_name','Counterparty','ro',NULL,'n','n','3',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 225,'commodity_name','Commodity','ro',NULL,'n','n','4','y',NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 225,'location','Location','ro',NULL,'n','n','6',NULL,NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 225,'bal_quantity','Balance Quantity','ron',NULL,'n','n','9',NULL,NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 225,'del_quantity','Delivery Quantity','ron',NULL,'n','n','8',NULL,NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 225,'fixed_price','Price','ron',NULL,'n','n','15',NULL,NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 225,'source_deal_detail_id','Detail ID','ron',NULL,'n','n','16','y',NULL,NULL,NULL,'100','int',NULL,'left' UNION ALL 
												SELECT 225,'buy_sell_flag','buy/Sell Flag','ro',NULL,'n','n','17','y',NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 225,'term_start','Term Start','ro',NULL,'n','n','18','y',NULL,NULL,NULL,'150','date',NULL,'left' UNION ALL 
												SELECT 225,'term_end','Term End','ro',NULL,'n','n','19','y',NULL,NULL,NULL,'150','date',NULL,'left' UNION ALL 
												SELECT 225,'uom','UOM','ro',NULL,'n','n','11','n',NULL,NULL,NULL,'150','str',NULL,'right' UNION ALL 
												SELECT 225,'split_finilized_status','Split Finalized Status','ro',NULL,'n','n','20','n',NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 225,'match_status',' Match Status','ro',NULL,'n','n','21','y',NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 225,'split_deal_detail_volume_id','Deal Detail Split ID','ron',NULL,'n','n','22','y',NULL,NULL,NULL,'150','int',NULL,'left' UNION ALL 
												SELECT 225,'actual_volume',' Actual Volume','ro',NULL,'n','n','10','y',NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 225,'contractual_volume','Contractual Volume','ro',NULL,'n','n','7','y',NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 225,'deal_detail_id_split_deal_detail_volume_id','Deal detail and Split ID','ron',NULL,'n','n','23','y',NULL,NULL,NULL,'150','int',NULL,'left' UNION ALL 
												SELECT 225,'is_parent','Parent/Child','ro',NULL,'n','n','24','y',NULL,NULL,NULL,'100','str',NULL,'left' UNION ALL 
												SELECT 225,'est_movement_date','Estimated Movement Date','dhxCalendarA',NULL,'n','n','32','n',NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 225,'org_uom','Orginal UOM','ro',NULL,'n','y','12','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 225,'price_uom','Price UOM','ro',NULL,'n','y','13','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 225,'org_price_uom','Orginal Price UOM','ro',NULL,'n','y','14','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 225,'inco_terms','INCOTerm','ron',NULL,'n','y','38','n',NULL,NULL,'n','150','int',NULL,'left' UNION ALL 
												SELECT 225,'crop_year','Crop Year','ron',NULL,'n','y','39','n',NULL,NULL,'n','150','int',NULL,'left' UNION ALL 
												SELECT 225,'lot','Lot','ro',NULL,'n','y','40','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 225,'batch_id','Batch','ro',NULL,'n','y','41','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 225,'container_number','Container Number','ro',NULL,'n','y','42','n',NULL,NULL,'y','150','str',NULL,'left' UNION ALL 
												SELECT 225,'est_movement_date_to','Estimated Movement Date To','dhxCalendarA',NULL,'n','y','33','n',NULL,NULL,'y','150','str',NULL,'left' UNION ALL 
												SELECT 225,'product','Product','ro',NULL,'n','y','5','n',NULL,NULL,'y','150','str',NULL,'left' UNION ALL 
												SELECT 225,'packaging','Packaging','ro',NULL,'n','n','43','n',NULL,NULL,NULL,'150','str',NULL,'left' UNION ALL 
												SELECT 225,'no_of_package','No. of package','ron',NULL,'n','n','44','n',NULL,NULL,NULL,'150','int',NULL,'left'
							
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