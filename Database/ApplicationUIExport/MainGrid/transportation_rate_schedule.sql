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
			
									SELECT 76,'transportation_rate_schedule',NULL,NULL,'EXEC spa_transportation_rate_schedule @flag=''s'', @for=''s'', @rate_schedule_id =<ID>','Demand/Fixed Charge','g',NULL,'20008900','20008900',NULL
				
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
							
												SELECT 76,'rec_pay','Rec/Pay','combo','SELECT ''r'' [value], ''Receive'' [name] UNION ALL SELECT ''p'', ''Pay''','y','n','24','n',NULL,NULL,'n','150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'contract_id','Contract','combo','EXEC spa_contract_group ''r''','y','n','22','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'counterparty_id','Counterparty','combo','EXEC spa_source_counterparty_maintain ''c''','y','n','21','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'settlement_calendar','Settlement Calendar','combo','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10017','y','n','19','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'payment_calendar','Payment Calendar','combo','EXEC spa_StaticDataValues @flag = ''b'', @type_id = 10017','y','n','17','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'billing_frequency','Billing Frequency','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 106300','y','n','15','n',NULL,NULL,NULL,'175','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'uom_id','UOM','combo','SELECT source_uom_id, uom_id uom_name  FROM source_uom','y','n','14','n',NULL,NULL,NULL,'175','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'currency_id','Currency','combo','SELECT source_currency_id, currency_name  FROM source_currency','y','y','13','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'rate_granularity','Rate Granularity','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 106200','y','n','10','n',NULL,NULL,NULL,'175','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'zone_to','Zone To','combo','SELECT value_id, code FROM static_data_value WHERE type_id=18000','y','n','5','n',NULL,NULL,NULL,'150',NULL,NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'zone_from','Zone From','combo','SELECT value_id, code FROM static_data_value WHERE type_id=18000','y','n','4','n',NULL,NULL,NULL,'150',NULL,NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'rate_type_id','Charge Type','combo','SELECT sdv.value_id, sdv.code FROM   static_data_value sdv INNER JOIN user_defined_fields_template udft ON  sdv.value_id = udft.field_name INNER JOIN static_data_value AS sdv2 ON udft.udf_category = sdv2.value_id WHERE  sdv.TYPE_ID = 5500 AND sdv2.value_id=101900','y','y','3','n',NULL,NULL,NULL,'175','str','NotEmpty','left', NULL,'n',NULL UNION ALL 
												SELECT 76,'settlement_date','Settlement Date','dhxCalendarA',NULL,'y','y','18','n',NULL,NULL,NULL,'125','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'payment_date','Payment Date','dhxCalendarA',NULL,'y','y','16','n',NULL,NULL,NULL,'125','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'effective_date','Effective Date','dhxCalendarA',NULL,'y','n','8','y',NULL,NULL,NULL,'125','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'end_date','End Date','dhxCalendarA',NULL,'y','y','7','n',NULL,NULL,NULL,'125','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'begin_date','Begin Date','dhxCalendarA',NULL,'y','y','6','n',NULL,NULL,NULL,'125','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'rate','Rate','ed_no',NULL,'y','n','9','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'rate_schedule_type','Rate Schedule Type','ro',NULL,'n','n','20','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'formula_name','Formula','ro',NULL,'y','y','12','n',NULL,NULL,NULL,'200',NULL,NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'formula_id','Formula ID','ro',NULL,'y','y','11','y',NULL,NULL,NULL,'200',NULL,NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'rate_schedule_id','Rate Schedule ID','ro',NULL,'n','y','2','y','transportation_rate_category','value_id',NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 76,'id','Rate ID','ro',NULL,'n','y','1','y',NULL,NULL,'y','100','str',NULL,'left', NULL,'n',NULL

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