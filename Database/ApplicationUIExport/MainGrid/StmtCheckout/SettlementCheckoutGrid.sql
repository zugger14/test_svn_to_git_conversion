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
			
									SELECT 381,'settlement_checkout_grid',NULL,NULL,NULL,'Settlement Checkout Grid','t','Group1,Group2,Group3,Group4,Group5',NULL,NULL,NULL
				
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
							
												SELECT 381,'Validation_Status','','ro',NULL,'n','n','2','n',NULL,NULL,'n','50','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Counterparty','Counterparty','ro',NULL,'n','n','2','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Deal_Reference','Deal Reference','ro',NULL,'n','n','3','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Ticket_Number','Ticket Number','ro',NULL,'n','n','3','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Leg','Leg','ro',NULL,'n','n','4','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Match_Group_ID','Match Group ID','ro',NULL,'n','n','5','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Shipment_ID','Shipment ID','ro',NULL,'n','n','6','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Deal_ID','Deal ID','ro',NULL,'n','n','7','n',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Deal_Detail_ID','Deal Detail ID','ro',NULL,'n','n','8','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Ticket_ID','Ticket ID','ro',NULL,'n','n','9','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Counterparty_ID','Counterparty ID','ro',NULL,'n','n','10','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Contract_ID','Contract ID','ro',NULL,'n','n','11','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Deal_Charge_Type_ID','Deal Charge Type ID','ro',NULL,'n','n','12','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Contract_Charge_Type_ID','Contract Charge Type ID','ro',NULL,'n','n','13','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Currency_ID','Currency ID','ro',NULL,'n','n','14','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Volume_UOM_ID','Volume UOM ID','ro',NULL,'n','n','15','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Contract','Contract','ro',NULL,'n','n','16','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Deal_Type','Deal Type','ro',NULL,'n','n','17','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Movement_Date','Movement Date','ro',NULL,'n','n','21','y',NULL,NULL,'n','160','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Buy_Sell','Buy Sell','ro',NULL,'n','n','22','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Volume_UOM','Volume UOM','ro',NULL,'n','n','27','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Status','Status','ro',NULL,'n','n','30','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Currency','Currency','ro',NULL,'n','n','31','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Pricing_Status','Pricing Status','ro',NULL,'n','n','32','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Product','Product','ro',NULL,'n','n','33','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Charge_Type_Alias','Charge Type Alias','ro',NULL,'n','n','34','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'PNL_Line_Item','PNL Line Item','ro',NULL,'n','n','35','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Invoicing_Charge_Type','Invoicing Charge Type','ro',NULL,'n','n','36','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Charge_Type_Alias_ID','Charge Type Alias ID','ro',NULL,'n','n','37','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'PNL_Line_Item_ID','PNL Line Item ID','ro',NULL,'n','n','38','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Invoicing_Charge_Type_ID','Invoicing Charge Type ID','ro',NULL,'n','n','39','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Debit_GL_Number','Debit GL Number','ro',NULL,'n','n','40','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Credit_GL_Number','Credit GL Number','ro',NULL,'n','n','41','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'payment_dr_gl_code','Payment Dr GL Code','ro',NULL,'n','n','42','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'payment_cr_gl_code','Payment Cr GL Code','ro',NULL,'n','n','43','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Invoice','Invoice ID','ro',NULL,'n','n','44','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Index_Fees_ID','Index Fees ID','ro',NULL,'n','n','48','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Settlement_Checkout_ID','Settlement Checkout ID','ro',NULL,'n','n','49','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Est_Post_GL_ID','Est Post GL ID','ro',NULL,'n','n','50','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Stmt_Invoice_ID','Stmt Invoice ID','ro',NULL,'n','n','51','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Type','Type','ro',NULL,'n','n','52','y',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Apply_Cash_Status','Payment Status','ro',NULL,'n','n','54','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'payment_date','Payment Date','ro',NULL,'n','n','56','n',NULL,NULL,'n','160','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'reversal_required','Reversal Required','ro',NULL,'n','n','57','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'invoice_type','Invoice Type','ro',NULL,'n','y','59','n',NULL,NULL,NULL,'150','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Amount','Amount','ro_a',NULL,'n','n','29','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Apply_Cash_Variance','Payment Variance','ro_a',NULL,'n','n','55','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'As_of_Date','As of Date','ro_dhxCalendarA',NULL,'n','n','18','n',NULL,NULL,'n','160','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Term_Start','Term Start','ro_dhxCalendarA',NULL,'n','n','19','n',NULL,NULL,'n','160','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Term_End','Term End','ro_dhxCalendarA',NULL,'n','n','20','n',NULL,NULL,'n','160','date',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Price','Price','ro_p',NULL,'n','n','28','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Price_Value','Price Value','ro_p',NULL,'n','n','45','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Amount_Value','Amount Value','ro_a',NULL,'n','n','46','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Apply_Cash_Received','Payment Received','ro_a',NULL,'n','n','53','n',NULL,NULL,'n','160','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Deal_Volume','Deal Volume','ro_v',NULL,'n','n','23','n',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Schedule_Volume','Schedule Volume','ro_v',NULL,'n','n','24','n',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Actual_Volume','Actual Volume','ro_v',NULL,'n','n','25','n',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Settlement_Volume','Settlement Volume','ro_v',NULL,'n','n','26','n',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Settlement_Volume_Value','Settlement Volume Value','ro_v',NULL,'n','n','47','y',NULL,NULL,'n','160','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 381,'Charges','Charges','tree',NULL,'n','n','1','n',NULL,NULL,'n','280','str',NULL,'left', NULL,'n',NULL

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