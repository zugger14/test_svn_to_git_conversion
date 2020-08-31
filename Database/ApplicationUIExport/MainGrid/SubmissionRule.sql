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
			
									SELECT 415,'SubmissionRule',NULL,NULL,'EXEC [dbo].[spa_submission_rule] @flag = grid_refresh, @submission_type = <ID>','Rules','g',NULL,NULL,NULL,NULL
				
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
								allow_multi_select CHAR(1) COLLATE DATABASE_DEFAULT
							)	
				
							INSERT INTO #temp_all_grids_columns(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, browser_grid_id, allow_multi_select)
							
												SELECT 415,'rule_id','Rule ID','ro',NULL,'n','y','1','y',NULL,NULL,'y','80','int',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'submission_type_id','Submission Type','combo','EXEC spa_StaticDataValues @flag=h, @type_id=44700','n','y','2','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'confirmation_type','Confirmation Type','combo','EXEC spa_StaticDataValues @flag=h, @type_id=46600','y','y','3','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'legal_entity_id','Legal Entity','combo','SELECT DISTINCT sc.source_counterparty_id, sc.counterparty_name FROM fas_subsidiaries fs INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id ORDER BY sc.counterparty_name','y','y','4','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'sub_book_id','Book Structure','combo','SELECT sub_book_id, book_structure FROM dbo.FNAGETPipeSeparatedBookStructure(20015200)','y','y','5','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'contract_id','Contract','combo','SELECT contract_id, contract_name FROM contract_group ORDER BY contract_name','y','y','6','n',NULL,NULL,'n','120','int',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'counterparty_id2','Counterparty 2','combo','SELECT source_counterparty_id, counterparty_id FROM source_counterparty ORDER BY counterparty_id','y','y','7','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'deal_type_id','Deal Type','combo','SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''n'' ORDER BY deal_type_id','y','y','8','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'deal_sub_type_id','Deal Sub Type','combo','SELECT source_deal_type_id, deal_type_id FROM source_deal_type WHERE sub_type = ''y'' ORDER BY deal_type_id','y','y','9','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'deal_template_id','Deal Template','combo','SELECT template_id, template_name FROM source_deal_header_template WHERE is_active = ''y'' ORDER BY template_name','y','y','9','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'commodity_id','Commodity','combo','SELECT source_commodity_id, commodity_id FROM source_commodity ORDER BY commodity_id','y','y','9','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'location_group_id','Location Group','combo','SELECT source_major_location_id, location_name FROM source_major_location ORDER BY location_name','y','y','10','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'location_id','Location','combo','SELECT source_minor_location_id, location_name FROM source_minor_location ORDER BY location_name','y','y','11','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'counterparty_id','Counterparty','combo','SELECT source_counterparty_id, counterparty_id FROM source_counterparty ORDER BY counterparty_id','y','n','12','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'counterpaty_type','Counterpaty Type','combo','SELECT ''i'' id, ''Internal'' code UNION ALL SELECT ''e'', ''EXternal'' UNION ALL SELECT ''b'', ''Broker'' UNION ALL SELECT ''c'', ''Clearing'' ','y','y','13','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'index_group','Index Group','combo','EXEC spa_StaticDataValues @flag=h, @type_id=15100','y','y','14','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'entity_type','Entity Type','combo','EXEC spa_StaticDataValues @flag=h, @type_id=10020','y','y','15','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'curve_id','Index','combo','EXEC spa_GetAllPriceCurveDefinitions @flag=a','y','y','16','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'buy_sell','Buy/Sell','combo','SELECT ''b'' id, ''Buy'' code UNION ALL SELECT ''s'', ''Sell''','y','y','17','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'confirm_status_id','Confirm Status','combo','EXEC spa_StaticDataValues @flag=h, @type_id=17200','y','y','18','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'deal_status_id','Deal Status','combo','EXEC spa_StaticDataValues @flag=h, @type_id=5600','y','y','19','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL 
												SELECT 415,'physical_financial_flag','Physical/Financial','combo','SELECT ''f'' [value],''Financial'' [code] UNION SELECT ''p'' ,''Physical''','y','y','20','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n' UNION ALL
												SELECT 415,'broker_id','Broker','combo','EXEC spa_source_counterparty_maintain @flag = ''c'', @int_ext_flag=''b''','y','n','21','n',NULL,NULL,'n','120','str',NULL,'left', NULL,'n'
							
							UPDATE tagc
							SET tagc.grid_id = @grid_id
							FROM #temp_all_grids_columns tagc
						
							INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required, column_order, is_hidden, fk_table, fk_column, is_unique, column_width, sorting_preference, validation_rule, column_alignment, browser_grid_id, allow_multi_select)
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
									tagc.allow_multi_select
										
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