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
			
									SELECT 54,'grid_setup_counterparty',NULL,NULL,NULL,'Counterparty','t','parent_counterparty_id,counterparty_name',NULL,NULL,NULL
				
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
							
												SELECT 54,'counterparty_id','Counterparty ID','ro',NULL,'n','y','4','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'counterparty_desc','Description','ro',NULL,'n','y','5','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'counterparty_type','Counterparty Type','ro',NULL,'n','y','6','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'entity_type','Entity Type','ro',NULL,'n','y','7','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'customer_duns_number','Customer Duns No.','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'tax_id','Tax ID','ro',NULL,'n','n','9','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'is_active','Active','ro',NULL,'n','y','10','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'contact_title','Title','ro',NULL,'n','n','11','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'contact_name','Contact Name','ro',NULL,'n','n','12','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'contact_address','Address 1','ro',NULL,'n','n','13','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'contact_address2','Address 2','ro',NULL,'n','n','14','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'delivery_method','Delivery Method','ro',NULL,'n','n','17','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'is_privilege_active','Privilege','ro',NULL,'n','n','19','y',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'counterparty_contact_notes','Notes','ro',NULL,'n','n','20','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'source_counterparty_id','System ID','ro_int',NULL,'n','y','3','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'type_id','Type ID','ro_int',NULL,'n','n','18','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'phone_no','Phone Number','ro_phone',NULL,'n','n','15','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'fax','Fax','ro_phone',NULL,'n','n','16','n',NULL,NULL,NULL,'150','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 54,'counterparty_name','Parent Counterparty/Counterparty','tree',NULL,'n','y','2','n',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL

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