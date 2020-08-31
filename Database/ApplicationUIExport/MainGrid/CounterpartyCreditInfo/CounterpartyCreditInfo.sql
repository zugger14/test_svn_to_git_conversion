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
			
									SELECT 104,'counterparty_credit_info',NULL,NULL,'EXEC spa_source_counterparty_maintain ''j''',NULL,NULL,NULL,'10101123','10101124',NULL
				
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
							
												SELECT 104,'account_status','Account Status','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=10082','n','n','5','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Risk_rating','Risk Rating','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=10097','n','n','6','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Debt_rating','Primary Debt Rating','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=10098','n','n','7','y',NULL,NULL,NULL,'130','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'cva_data','Rating for CVA','combo','SELECT 1, ''Primary Debt Rating'' UNION ALL SELECT 2, ''Debt Rating 2'' UNION ALL SELECT 3, ''Debt Rating 3'' UNION ALL SELECT 4, ''Debt Rating 4'' UNION ALL SELECT 5, ''Debt Rating 5''  UNION ALL SELECT 6, ''Risk Rating'' UNION ALL SELECT 7, ''Counterparty Default VALUES'' UNION ALL SELECT 8,''Counterparty Credit Spread''','n','n','8','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'pfe_criteria','PFE Criteria','combo','EXEC spa_var_measurement_criteria_detail @flag=''g''','n','n','9','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Debt_Rating2','Debt Rating 2','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=11099','n','n','10','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Debt_Rating3','Debt Rating 3','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=11100','n','n','11','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Debt_Rating4','Debt Rating 4','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=11101','n','n','12','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Debt_Rating5','Debt Rating 5','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=11102','n','n','13','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Industry_type1','Industry Type 1','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=10083','n','n','14','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Industry_type2','Industry Type 2','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=10084','n','n','15','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'SIC_Code','SIC Code','combo','EXEC spa_StaticDataValues @flag=''h'', @type_id=10096','n','n','17','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'source_counterparty_id','Source Counterparty ID','ro',NULL,'n','n','1','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'counterparty_name','Counterparty','ro',NULL,'n','n','2','n',NULL,NULL,NULL,'115','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'counterparty_desc','Description','ro',NULL,'n','n','3','n',NULL,NULL,NULL,'115','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'counterparty_id','Counterparty ID','ro',NULL,'n','n','4','n',NULL,NULL,NULL,'115','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Ticker_symbol','Ticker Symbol','ro',NULL,'n','n','16','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Customer_since','Customer Since','ro',NULL,'n','n','18','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Duns_No','Duns No','ro',NULL,'n','n','19','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Approved_by','Approved By','ro',NULL,'n','n','20','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Date_established','Date Established','ro',NULL,'n','n','21','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Last_review_date','Last Review Date','ro',NULL,'n','n','22','y',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Next_review_date','Next Review Date','ro',NULL,'n','n','23','y',NULL,NULL,NULL,'120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'exclude_exposure_after','Exclude Exposure After (Months)','ro',NULL,'n','n','24','y',NULL,NULL,NULL,'200','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'type_id','Type ID','ro',NULL,'n','n','25','y',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'is_privilege_active','Privilege','ro',NULL,'n','n','26','y',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'Watch_list','Watch List','ro',NULL,'n','n','27','y',NULL,NULL,NULL,'100','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 104,'limit_expiration','Do not calc Credit Exposure','ro',NULL,'n','n','28','y',NULL,NULL,NULL,'180','str',NULL,'left', NULL,'n',NULL

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