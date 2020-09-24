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
			
									SELECT 223,'document_contacts',NULL,NULL,NULL,NULL,'g',NULL,NULL,NULL,NULL
				
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
							
												SELECT 223,'contact_type','Contact Type','combo','EXEC spa_StaticDataValues @flag = ''h'', @type_id = 32200','n','n','7','y',NULL,NULL,NULL,'140','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'delivery_method','Delivery Method','combo','SELECT value_id,code FROM static_data_value WHERE type_id = 21300 AND value_id IN (21301,21302,21304)','n','n','8','n',NULL,NULL,NULL,'140','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'document1','Document Type','ro',NULL,'n','n','1','n',NULL,NULL,NULL,'230','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'document2','Document Category','ro',NULL,'n','n','1','n',NULL,NULL,NULL,'230','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'message_document_id','Document ID','ro',NULL,'n','n','2','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'document_type','Document Type','ro',NULL,'n','n','3','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'effective_date','Effective Date','ro',NULL,'n','n','4','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'document_category','Document Category','ro',NULL,'n','n','5','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'id','ID','ro',NULL,'n','n','6','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'as_defined_in_contract','Defined in contract','ro',NULL,'n','n','9','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'email','email','ro',NULL,'n','n','11','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'email_cc','email_cc','ro',NULL,'n','n','12','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'email_bcc','email_bcc','ro',NULL,'n','n','13','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'internal_contact_type','Internal Contact Type','ro',NULL,'n','n','14','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'document_template','Document Template','ro',NULL,'n','n','14','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'email_group','Email Group','ro',NULL,'n','n','15','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'email_group_cc','Email Group CC','ro',NULL,'n','n','16','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'email_group_bcc','Email Group BCC','ro',NULL,'n','n','17','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'message_template_id','Message Template','ro_int',NULL,'n','n','18','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'message','Message','txttxt',NULL,'n','n','10','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 223,'subject','Subject','txttxt',NULL,'n','n','14','y',NULL,NULL,NULL,'140','int',NULL,'left', NULL,'n',NULL UNION ALL
												SELECT 223,'use_generated_document','Use Generated Document','ro',NULL,'n','n','19','y',NULL,NULL,NULL,'250','str',NULL,'left', NULL,'n',NULL

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