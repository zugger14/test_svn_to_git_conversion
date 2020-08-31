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
			
									SELECT 230,'SourceRemitStandard',NULL,NULL,NULL,'Report Detail','g',NULL,NULL,NULL,NULL
				
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
							
												SELECT 230,'stra_id','Strategy','ro',NULL,'n','n','5','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'market_id_participant_counterparty','ID of the market participant or counterparty','ro',NULL,'n','n','8','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'type_of_code_field_1','Type of code used in field 1','ro',NULL,'n','n','9','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'trader_id_market_participant','ID of the trader participant or counterparty','ro',NULL,'n','n','10','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'other_id_market_participant_counterparty','ID of the other participant or counterparty','ro',NULL,'n','n','11','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'type_of_code_field_4','Type of code used in field 4','ro',NULL,'n','n','12','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'reporting_entity_id','Reporting Entity ID','ro',NULL,'n','n','13','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'type_of_code_field_6','Type of code used in field 6','ro',NULL,'n','n','14','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'beneficiary_id','Beneficiary ID','ro',NULL,'n','n','15','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'type_of_code_field_8','Type of code used in field 8','ro',NULL,'n','n','16','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'trading_capacity_market_participant','Trading capacity of the market participant or counterparty in field 1','ro',NULL,'n','n','17','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'buy_sell_indicator','Buy sell indicator','ro',NULL,'n','n','18','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'initiator_aggressor','Initiator Aggressor','ro',NULL,'n','n','19','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'order_type','Order Type','ro',NULL,'n','n','21','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'order_condition','Order Condition','ro',NULL,'n','n','22','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'order_status','Order Status','ro',NULL,'n','n','23','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'order_duration','Order Duration','ro',NULL,'n','n','27','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'contract_name','Contract Name','ro',NULL,'n','n','29','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'contract_type','Contract Type','ro',NULL,'n','n','30','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'energy_commodity','Energy Commodity','ro',NULL,'n','n','31','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'settlement_method','Settlement method','ro',NULL,'n','n','33','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'organised_market_place_id_otc','Organised market place ID / OTC','ro',NULL,'n','n','34','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'contract_trading_hours','Contract trading hours','ro',NULL,'n','n','35','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'last_trading_date_and_time','Last trading date and time','ro',NULL,'n','n','36','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'transaction_timestamp','Transaction timestamp','ro',NULL,'n','n','37','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'unique_transaction_id','Unique transaction ID','ro',NULL,'n','n','38','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'linked_transaction_id','Linked transaction ID','ro',NULL,'n','n','39','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'linked_order_id','Linked order ID','ro',NULL,'n','n','40','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'voice_brokered','Voice-brokered','ro',NULL,'n','n','41','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'index_value','Index value','ro',NULL,'n','n','43','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'price_currency','Price currency','ro',NULL,'n','n','44','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'notional_currency','Notional currency','ro',NULL,'n','n','46','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'total_notional_contract_quantity','Total notional contract quantity','ro',NULL,'n','n','48','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'quantity_unit_field_40_and_41','Quantity unit for field 40 and 41','ro',NULL,'n','n','49','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'termination_date','Termination date','ro',NULL,'n','n','50','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'option_style','Option style','ro',NULL,'n','n','51','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'option_type','Option type','ro',NULL,'n','n','52','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'option_exercise_date','Option exercise date','ro',NULL,'n','n','53','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'delivery_point_or_zone','Delivery point or zone','ro',NULL,'n','n','55','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'delivery_start_date','Delivery start date','ro',NULL,'n','n','56','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'delivery_end_date','Delivery end date','ro',NULL,'n','n','57','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'load_type','Load type','ro',NULL,'n','n','59','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'days_of_the_week','Days of the week','ro',NULL,'n','n','60','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'load_delivery_intervals','Load delivery Intervals','ro',NULL,'n','n','61','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'delivery_capacity','Delivery capacity','ro',NULL,'n','n','62','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'quantity_unit_used_in_field_55','Quantity unit used in field 55','ro',NULL,'n','n','63','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'price_time_interval_quantity','Price/time interval quantity','ro',NULL,'n','n','64','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'action_type','Action type','ro',NULL,'n','n','65','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'error_validation_message','Error Validation Message','ro',NULL,'n','n','66','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'notional_amount','Notional amount','ro_a',NULL,'n','n','45','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'source_deal_header_id','TRMDeal ID','ro_int',NULL,'n','n','1','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'deal_id','Ref ID','ro_int',NULL,'n','n','2','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'process_id','Process ID','ro_int',NULL,'n','n','3','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'sub_id','Subsidiary','ro_int',NULL,'n','n','4','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'book_id','Book','ro_int',NULL,'n','n','6','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'sub_book_id','SubBook','ro_int',NULL,'n','n','7','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'order_id','Order ID','ro_int',NULL,'n','n','20','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'contract_id','Contract ID','ro_int',NULL,'n','n','28','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'duration','Duration','ro_int',NULL,'n','n','58','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'price_limit','Price Limit','ro_p',NULL,'n','n','25','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'fixing_index_or_reference_price','Fixing index or reference price','ro_p',NULL,'n','n','32','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'price','Price','ro_p',NULL,'n','n','42','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'option_strike_price','Option strike price','ro_p',NULL,'n','n','54','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'minimum_execution_volume','Min Execution Volume','ro_v',NULL,'n','n','24','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'undisclosed_volume','Undisclosed Volume','ro_v',NULL,'n','n','26','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL UNION ALL 
												SELECT 230,'quantity_volume','Quantity / Volume','ro_v',NULL,'n','n','47','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n',NULL

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