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
			
									SELECT 408,'StmtAmountReport',NULL,NULL,NULL,'Settlement Amount Report','g',NULL,NULL,NULL,0  
				
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
								column_alignment VARCHAR(200) COLLATE DATABASE_DEFAULT 
							)	
				
							INSERT INTO #temp_all_grids_columns(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment)
							
												SELECT 408,'source_deal_header_id','Deal ID','ro',NULL,'n','n','1','n',NULL,NULL,'n','150','int',NULL,'left' UNION ALL 
												SELECT 408,'deal_id','Deal Ref ID','ro',NULL,'n','n','2','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 408,'commodity_id','Commodity','ro',NULL,'n','n','3','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 408,'trader_id','Trader','ro',NULL,'n','n','4','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 408,'Deal_Type','Deal Type','ro',NULL,'n','n','5','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 408,'Template','Template','ro',NULL,'n','n','6','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL 
												SELECT 408,'Counterparty','Counterparty','ro',NULL,'n','n','7','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Contract','Contract','ro',NULL,'n','n','8','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'term_start','Term Start','ro',NULL,'n','n','9','n',NULL,NULL,'n','150','date',NULL,'left' UNION ALL
												SELECT 408,'term_end','Term End','ro',NULL,'n','n','10','n',NULL,NULL,'n','150','date',NULL,'left' UNION ALL
												SELECT 408,'term_start_year_month','Term Start Year Month','ro',NULL,'n','n','11','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Leg','Leg','ro',NULL,'n','n','12','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'charge_type','Charges','ro',NULL,'n','n','13','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'[buy_sell','Buy/Sell','ro',NULL,'n','n','14','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'location','Location','ro',NULL,'n','n','15','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Index','Index','ro',NULL,'n','n','16','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Block_Definition','Block Definition','ro',NULL,'n','n','17','y',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Notional_Volume','Notional Volume','ro_no',NULL,'n','n','18','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'UOM','UOM','ro',NULL,'n','n','19','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Position','Position','ro_no',NULL,'n','n','20','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Position_uom','Position UOM','ro',NULL,'n','n','21','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Price','Price','ro_p',NULL,'n','n','22','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Value','Value','ro_p',NULL,'n','n','23','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL								
												SELECT 408,'discount_factor','Discount Factor','ro',NULL,'n','n','24','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'dis_pnl','PNL','ro_p',NULL,'n','n','25','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'Currency','Currency','ro',NULL,'n','n','26','n',NULL,NULL,'n','150','str',NULL,'left' UNION ALL
												SELECT 408,'actual_forward','Actual/Forward','ro',NULL,'n','n','27','n',NULL,NULL,'n','150','str',NULL,'left'  

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