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
			
									SELECT 384,'SubmittedAccrualReportGrid',NULL,NULL,NULL,'Submitted Accrual Report Grid','t',NULL,NULL,NULL,NULL
				
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
												SELECT 384,'stmt_checkout_id','ID','ro',NULL,'n','n','1','y',NULL,NULL,'n','160','str',NULL,'left' UNION ALL
							
												SELECT 384,'Submitted_Date','Submitted Date','ro',NULL,'n','n','2','n',NULL,NULL,'n','160','str',NULL,'left' UNION ALL
												SELECT 384,'Counterparty_Name','Counterparty','ro',NULL,'n','n','3','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Contract_Name','Contract','ro',NULL,'n','n','4','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Deal','Deal ID','ro',NULL,'n','n','5','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Deal','Deal Ref','ro',NULL,'n','n','6','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Ticker_ID','Ticket','ro',NULL,'n','n','7','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'As_of_Date','As of Date','ro',NULL,'n','n','8','n',NULL,NULL,'n','160','str',NULL,'left' UNION ALL 
												SELECT 384,'Term_Start','Term Start','ro',NULL,'n','n','9','n',NULL,NULL,'n','160','str',NULL,'left' UNION ALL 
												SELECT 384,'Term_End','Term End','ro',NULL,'n','n','10','n',NULL,NULL,'n','160','str',NULL,'left' UNION ALL 
												SELECT 384,'Charge_Type','Charge Type','ro',NULL,'n','n','11','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Deal_Volume','Deal Volume','ro_no',NULL,'n','n','12','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Scheduled_Volume','Schedule Volume','ro_no',NULL,'n','n','13','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Acutal_volume','Actual Volume','ro_no',NULL,'n','n','14','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'volume','Volume','ro_no',NULL,'n','n','15','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Amount','Amount','ro_p',NULL,'n','n','16','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Price','Price','ro_p',NULL,'n','n','17','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Charge_Type_Alias','Charge Type Alias','ro',NULL,'n','n','18','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'PNL_Line_Item','Pnl Line Item','ro',NULL,'n','n','19','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Debit_GL_Number','Debit GL Number','ro',NULL,'n','n','20','n',NULL,NULL,'n','160','int',NULL,'left' UNION ALL 
												SELECT 384,'Credit_GL_Number','Credit GL Number','ro',NULL,'n','n','21','n',NULL,NULL,'n','160','str',NULL,'left' UNION ALL 
												SELECT 384,'Submitted_User','Submitted User','ro',NULL,'n','n','22','n',NULL,NULL,'n','160','str',NULL,'left' 
												
							
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