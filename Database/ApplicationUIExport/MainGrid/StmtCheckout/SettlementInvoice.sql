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
			
									SELECT 386,'SettlementInvoice',NULL,NULL,NULL,NULL,'t','counterparty,contract,invoice_number','20012201','20012202',NULL
				
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
							
												SELECT 386,'invoice_id','Invoice ID','ro',NULL,'n','y','2','n',NULL,NULL,NULL,'175','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'counterparty_id','Counterparty ID','ro',NULL,'n','y','3','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'contract_id','Contract ID','ro',NULL,'n','y','4','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_template','Invoice Template','ro',NULL,'n','y','5','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'date_from','Date From','ro',NULL,'n','n','6','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'date_to','Date To','ro',NULL,'n','y','7','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'settlement_date','Invoice Date','ro',NULL,'n','n','8','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'currency','Currency','ro',NULL,'n','y','10','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'acc_status','Accounting Status','ro',NULL,'n','n','11','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_status','Workflow Status','ro',NULL,'n','n','12','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'void_status','Void Status','ro',NULL,'n','n','13','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_type','Invoice Type','ro',NULL,'n','y','14','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'payment_date','Payment Date','ro',NULL,'n','y','15','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'stmt_invoice_id','Settlement Invoice ID','ro',NULL,'n','y','16','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'finalized_date','Finalized Date','ro',NULL,'n','y','17','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_note','Invoice Note','ro',NULL,'n','y','18','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_status_id','Invoice Status ID','ro',NULL,'n','y','19','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'as_of_date','As of Date','ro',NULL,'n','y','20','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'create_date','Create Date','ro',NULL,'n','y','23','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'create_user','Create User','ro',NULL,'n','y','24','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'update_date','Update Date','ro',NULL,'n','y','25','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'update_user','Update User','ro',NULL,'n','y','26','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'netting_invoice_id','Netting Invoice ID','ro',NULL,'n','y','27','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_file_name','Invoice File Name','ro',NULL,'n','n','28','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'document_type','Document Type','ro',NULL,'n','y','29','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'payment_status','Payment Status','ro',NULL,'n','y','30','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'is_locked','Lock Status','ro',NULL,'n','y','31','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'amount','Amount','ro_a',NULL,'n','y','9','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'incoming_invoice_amount','Incoming Invoice Amount','ro_a',NULL,'n','y','21','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'variance','Variance','ro_a',NULL,'n','y','22','y',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 386,'invoice_number','Invoice Number','tree',NULL,'n','y','1','n',NULL,NULL,NULL,'175','str',NULL,'left', NULL,'n',NULL

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