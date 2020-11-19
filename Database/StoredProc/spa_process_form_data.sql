IF OBJECT_ID (N'[dbo].[spa_process_form_data]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_process_form_data]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 /**
	Generic SP to process data for insert/update operations.
 
	Parameters
	@flag : Flag Operation		
		- 'd' - Delete data.
	@xml : XML string of the Data to be inserted/updated.
	@return_process_table : Return process table that stores recomendation ID.
	@success_message: 1 to show success message, 0 if no success message is required
*/

CREATE PROC dbo.spa_process_form_data
	@flag CHAR(1) = 's',
	@xml XML = NULL,
	@return_process_table VARCHAR(200) = NULL,
	@success_message BIT = 1
AS

/*----------------------------------------------Debug Section---------------------------------------------
--Sample Use = EXEC spa_process_form_data 'i','10111000', ''<Root><PSRecordset user_login_id="test_test" user_pwd="asdasdasd" user_f_name="asd" user_m_name="asd" user_l_name="asd" user_title="asd" entity_id="300797" user_address1="asd" user_address2="asd" state_value_id="300797" user_off_tel="asd" user_main_tel="asd" user_pager_tel="asd" user_mobile_tel="asd" user_emal_add="asd" region_id="1" user_active="0" reports_to="" timezone_id=""  ></PSRecordset></Root>'

IF OBJECT_ID('tempdb..#xml_process_table_name') IS NOT NULL
	DROP TABLE #xml_process_table_name

IF OBJECT_ID('tempdb..#process_table') IS NOT NULL
	DROP TABLE #process_table

IF OBJECT_ID('tempdb..#final_sql') IS NOT NULL
	DROP TABLE #final_sql

IF OBJECT_ID('tempdb..#grid_xml_process_table_name') IS NOT NULL
	DROP TABLE #grid_xml_process_table_name

IF OBJECT_ID('tempdb..#unpivot_fields') IS NOT NULL
	DROP TABLE #unpivot_fields

IF OBJECT_ID('tempdb..#field_value_pair') IS NOT NULL
	DROP TABLE #field_value_pair

DECLARE @flag CHAR(1), @xml XML, @success_message BIT = 1
SELECT @xml='<Root function_id="20002300" object_id="416"><FormXML  deal_type_pricing_maping_id="416" template_id="2750" commodity_id="" source_deal_type_id="1245" pricing_type="46700" fixed_price="n" curve_id="n" price_adder="n" formula_id="n" multiplier="n" pricing_start="n" pricing_end="n" detail_pricing="n" pricing_tab="n" formula_curve_id="n" enable_term_type="n" location_id="y" price_multiplier="n" enable_efp="n" enable_trigger="n" enable_cost_tab="y" enable_exercise_tab="n" enable_tranches_tab="n" enable_udf_tab="y" block_define_id="n" settlement_currency="n" settlement_date="n" fx_conversion_rate="n" cycle="n" upstream_counterparty="n" upstream_contract="n" enable_provisional_tab="n" enable_escalation_tab="n" enable_certificate="n" enable_prepay_tab="n"></FormXML><GridGroup></GridGroup></Root>'
-----------------------------------------------------------------------------------------------------------------*/

SET NOCOUNT ON
BEGIN TRY
	DECLARE @function_id VARCHAR(100),
			@xml_table_name VARCHAR(200),
			@sql VARCHAR(MAX),
			@col_list VARCHAR(MAX)	,	
		    @form_xml NVARCHAR(MAX)	,	
			@grid_xml VARCHAR(MAX)		,
			@grid_xml_table_name VARCHAR(200),
			@identity_insert_value VARCHAR(100),
			@object_id VARCHAR(100),
			@table_name VARCHAR(200),
			@select_list VARCHAR(MAX),
			@update_list VARCHAR(MAX),
			@where_condition VARCHAR(MAX),
			@sql_join VARCHAR(MAX),
			@process_table_name VARCHAR(200),
			@insert_list VARCHAR(MAX),
			@process_order INT,
			@primary_value VARCHAR(200),
			@final_update_sql  VARCHAR(MAX),
			@final_insert_sql VARCHAR(MAX),
			@fk_value_id VARCHAR(100),
			@delete_xml VARCHAR(MAX),
			@to_delete_id VARCHAR(1000),
			@to_delete_table VARCHAR(1000),
			@to_delete_table_name VARCHAR(1000),
			@desc VARCHAR(1000),
			@is_primary VARCHAR(100),
			@is_udf_present INT,
			@udf_object_id VARCHAR(100), 
			@udf_insert NVARCHAR(MAX),
			@udf_select NVARCHAR(MAX),
			@udf_update NVARCHAR(MAX)
	
		SELECT @form_xml = '<Root>' + CAST(col.query('.') AS NVARCHAR(MAX)) + '</Root>'
		FROM @xml.nodes('/Root/FormXML') AS xmlData(col)
  
		SELECT @grid_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) + '</Root>'
		FROM @xml.nodes('/Root/GridGroup') AS xmlData(col)

		SELECT @delete_xml = '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) + '</Root>'
		FROM @xml.nodes('/Root/GridGroup/GridDelete') AS xmlData(col)    

		-- parse the Function ID
		SELECT @function_id = xmlData.col.value('@function_id','VARCHAR(100)'),
			   @object_id = xmlData.col.value('@object_id','VARCHAR(100)')
		FROM @xml.nodes('/Root') AS xmlData(Col)   

		-- Store and parse XML in process table
		IF @form_xml IS NOT NULL
		BEGIN
			CREATE TABLE #xml_process_table_name (
				table_name VARCHAR(200) COLLATE DATABASE_DEFAULT
			)
		
			INSERT INTO #xml_process_table_name 
			EXEC spa_parse_xml_file 'b', NULL, @form_xml
		
			SELECT @xml_table_name = table_name 
			FROM #xml_process_table_name
	
			--Added for bit support by standard form
			DECLARE @bit_colums VARCHAR(MAX), 
					@tbl_name VARCHAR(1000), 
					@varchar_to_bit_sql VARCHAR(MAX), 
					@process_tbl VARCHAR(MAX)
	
			SELECT @tbl_name = table_name
			FROM application_ui_template 
			WHERE application_function_id = @function_id

			SELECT @bit_colums = ISNULL(@bit_colums + ', ', '') + mcol.COLUMN_NAME + ' = IIF( ' + mcol.COLUMN_NAME + ' = ''y'' OR ' + mcol.COLUMN_NAME + ' = ''1'', 1 , 0)'
			FROM INFORMATION_SCHEMA.COLUMNS mcol WITH(NOLOCK)
			INNER JOIN adiha_process.INFORMATION_SCHEMA.COLUMNS acol WITH(NOLOCK) ON mcol.COLUMN_NAME = acol.COLUMN_NAME
				AND acol.TABLE_NAME = REPLACE(@xml_table_name, 'adiha_process.dbo.', '')
			WHERE mcol.TABLE_NAME = @tbl_name
				AND mcol.DATA_TYPE = 'bit'
		END
	
		IF @bit_colums IS NOT NULL 
		BEGIN
			SELECT @process_tbl = table_name
			FROM #xml_process_table_name
			
			SET @varchar_to_bit_sql = 'UPDATE '+ @process_tbl + ' SET ' + @bit_colums 
			
			EXEC (@varchar_to_bit_sql)
		END
		--End of Added for bit support by standard form	

		IF @xml_table_name IS NOT NULL
		BEGIN
			--Removed create_ts,create_user,update_ts and update_user from the temporary table
			EXEC ('
				IF COL_LENGTH (N''' + @xml_table_name + ''', N''create_ts'') IS NOT NULL
					ALTER TABLE ' + @xml_table_name + ' DROP COLUMN create_ts;
			')

			EXEC ('
				IF COL_LENGTH (N''' + @xml_table_name + ''', N''create_user'') IS NOT NULL
					ALTER TABLE ' + @xml_table_name + ' DROP COLUMN create_user;
			')

			EXEC ('
				IF COL_LENGTH (N''' + @xml_table_name + ''', N''update_ts'') IS NOT NULL
					ALTER TABLE ' + @xml_table_name + ' DROP COLUMN update_ts;
			')

			EXEC ('
				IF COL_LENGTH (N''' + @xml_table_name + ''', N''update_user'') IS NOT NULL
					ALTER TABLE ' + @xml_table_name + ' DROP COLUMN update_user;
			')
		END
		-- Store and parse XML in process table
		IF @grid_xml IS NOT NULL
		BEGIN
			CREATE TABLE #grid_xml_process_table_name(
				table_name VARCHAR(200) COLLATE DATABASE_DEFAULT
			)
			--	Remove delete xml data if exists in grid xml.
			IF @delete_xml IS NOT NULL
			BEGIN
				SELECT @grid_xml = (SELECT '<Root><GridGroup>' + CAST( @xml.query('/Root/GridGroup/Grid') AS VARCHAR(MAX)) + '</GridGroup></Root>')
			END	
			
			INSERT INTO #grid_xml_process_table_name
			EXEC spa_parse_xml_file 'b', NULL, @grid_xml
		
			SELECT @grid_xml_table_name = table_name
			FROM #grid_xml_process_table_name
		END
	
		IF @delete_xml IS NOT NULL AND @flag <> 'd'
		BEGIN
			BEGIN TRY
				DECLARE @xml_script XML

				IF CURSOR_STATUS('global', 'list_xml_script') >= -1
					DEALLOCATE list_xml_script

				DECLARE list_xml_script CURSOR  
				FOR
					SELECT '<Root>' + CAST(col.query('.') AS VARCHAR(MAX)) + '</Root>' AS [xml_script]
					FROM @xml.nodes('/Root/GridGroup/GridDelete') AS XMLDATA(col)
				OPEN list_xml_script
				FETCH NEXT FROM list_xml_script INTO @xml_script
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF OBJECT_ID('tempdb..#delete_data_process_table_name') IS NOT NULL
						DROP TABLE #delete_data_process_table_name

					CREATE TABLE #delete_data_process_table_name (
						table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  
					)
				
					INSERT INTO #delete_data_process_table_name
					EXEC spa_parse_xml_file 'b', NULL, @xml_script
				
					DECLARE @process_table VARCHAR(512)

					SELECT @process_table = table_name
					FROM #delete_data_process_table_name
				
					DECLARE @query NVARCHAR(3000),
							@table_to_delete NVARCHAR(512)
				
					SET @query = '
						SELECT DISTINCT at.grid_id
						FROM ' + @process_table + ' at
						INNER JOIN adiha_grid_definition agd ON  at.grid_id = agd.grid_name
						INNER JOIN adiha_grid_columns_definition agcd ON  agcd.grid_id = agd.grid_id
					'
				
					SET @query = 'DECLARE delete_table CURSOR FOR ' + @query
					
					EXEC sp_executesql @query
					
					OPEN delete_table
					
					FETCH NEXT FROM delete_table INTO @table_to_delete
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @sql = 'DELETE pt FROM ' + @table_to_delete + ' pt CROSS JOIN ' + @process_table + ' at '
						
						DECLARE @sql_condition NVARCHAR(4000) = '',
								@column_name NVARCHAR(255)

						SET @query = '
							SELECT DISTINCT agcd.column_name
							FROM ' + @process_table + ' at
							INNER JOIN adiha_grid_definition agd ON at.grid_id = agd.grid_name
							INNER JOIN adiha_grid_columns_definition agcd ON agcd.grid_id = agd.grid_id 
							AND agcd.is_unique = ''y''
						'
					
						SET @query = 'DECLARE table_columns CURSOR FOR ' + @query

						EXEC sp_executesql @query
						
						OPEN table_columns
						FETCH NEXT FROM table_columns INTO @column_name
						WHILE @@FETCH_STATUS = 0
						BEGIN
							SET @sql_condition += (CASE WHEN @sql_condition = '' THEN ' WHERE ' ELSE ' AND ' END)
	                
							SET @sql_condition += ' pt.' + @column_name + ' = at.' + @column_name 
							FETCH NEXT FROM table_columns INTO @column_name
						END
						CLOSE table_columns
						DEALLOCATE table_columns

						EXEC (@sql + @sql_condition)
						
						FETCH NEXT FROM delete_table INTO @table_to_delete
					END
					CLOSE delete_table
					DEALLOCATE delete_table 
					FETCH NEXT FROM list_xml_script INTO @xml_script
				END 
				CLOSE list_xml_script
				DEALLOCATE list_xml_script
			
			--COMMIT TRAN

			--EXEC spa_ErrorHandler 0, 
			--	'Process Form Data', 
			--	'spa_process_form_data', 
			--	'Success', 
			--	'Changes have been saved successfully.',
			--	''
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN 
			
				DECLARE @err_num INT = ERROR_NUMBER()

				IF @err_num = 547 --FK voilation
				BEGIN 
					SET @desc =  'Error Found: Data Used in other Entity.'
				END 
				ELSE 
				BEGIN 
					SET @desc = 'Error Found: ' + ERROR_MESSAGE()
				END
			
				EXEC spa_ErrorHandler -1, 'Process Form Data', 'spa_process_form_data', 'Error', @desc, ''
				
				RETURN
			END CATCH
		END
		
		--Delete functionality to handle main grid & Accordian grid , XML data varies for both grid
	
		IF OBJECT_ID('tempdb..#primary_id') IS NOT NULL
			DROP TABLE #primary_id
	
		CREATE TABLE #primary_id(
			ID VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		IF @flag = 'd'
		BEGIN 
			BEGIN TRY 
				BEGIN TRAN 
				DECLARE @ph_key VARCHAR(100)
			
				SELECT @to_delete_table = aut.table_name,
					   @ph_key = autd.field_id
				FROM application_ui_template aut
				INNER JOIN application_ui_template_definition autd ON autd.application_function_id = aut.application_function_id
				WHERE aut.application_function_id = @function_id
					AND autd.is_primary = 'y'

				IF OBJECT_ID('tempdb..#main_gridrows_to_delete') IS NOT NULL
					DROP TABLE #main_gridrows_to_delete					

				CREATE TABLE #main_gridrows_to_delete (
					row_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT  
				)

				IF CHARINDEX('GridGroup', CAST(@xml AS VARCHAR(MAX))) = 0 --main grid 
				BEGIN
					INSERT INTO #main_gridrows_to_delete
					SELECT t.c.value('@grid_id', 'VARCHAR(MAX)') AS grid_id
					FROM @xml.nodes('/Root/GridDelete') t(c)	
				END 
				ELSE --Accordian grid
				BEGIN
					INSERT INTO #main_gridrows_to_delete
					SELECT t.c.value('@grid_id', 'VARCHAR(MAX)') AS grid_id
					FROM @xml.nodes('/Root/GridGroup/GridDelete') t(c)
				END
				
				SET @sql = 'DELETE d FROM ' + @to_delete_table + ' d '
				SET @sql += 'INNER JOIN #main_gridrows_to_delete rd ON rd.row_id = d.' + @ph_key
				
				EXEC (@sql)
			    
				COMMIT TRAN

				EXEC spa_ErrorHandler 0, 'Process Form Data', 'spa_process_form_data', 'Success', 'Changes have been saved successfully.', @ph_key
				RETURN
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN
			
				SET @desc = dbo.FNAHandleDBError(@function_id)
				
				EXEC spa_ErrorHandler -1, 'Process Form Data', 'spa_process_form_data', 'Error', @desc, ''
				RETURN
			END CATCH
		END

		SELECT @col_list = COALESCE(@col_list + N',', N'') + QUOTENAME(c.name) 
		FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
		INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id
			AND o.xtype = 'U'
		WHERE o.name = REPLACE(@xml_table_name, 'adiha_process.dbo.', '')

		CREATE TABLE #final_sql (
			final_sql VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)

		CREATE TABLE #unpivot_fields(
			field_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
			field_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
			grid_id VARCHAR(500) COLLATE DATABASE_DEFAULT,
			process_table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  
		)

		-- Insert Form Data
		SET @sql = '
			INSERT INTO #unpivot_fields
			SELECT _field_name_, NULLIF(field_value, ''NULL''), NULL, ''' + @xml_table_name + '''
			FROM (
				SELECT ' + @col_list + '
				FROM ' + @xml_table_name + '
			) p
			UNPIVOT (field_value FOR _field_name_ IN (' + @col_list + ')) AS unpvt; 
		'
		
		EXEC(@sql)

		SELECT aut.table_name,
			   ad.farrms_field_id,
			   upf.field_value,
			   CASE WHEN ad.data_type IN ('int', 'float', 'numeric') THEN '''' ELSE '' END AS single_quote,
			   CASE WHEN ad.is_primary = 'y' THEN ad.farrms_field_id ELSE NULL END AS primary_key,
			   CASE WHEN ad.is_primary = 'y' THEN upf.field_value ELSE NULL END AS primary_value,
			   CAST(NULL AS VARCHAR(200)) AS fk_table,
			   CAST(NULL AS VARCHAR(200)) AS fk_column,
			   process_table_name,
			   1 AS process_order,
			   ISNULL(ad.is_identity, 'n') is_identity,
			   ISNULL(ad.is_udf, 'n') is_udf,
			   autf.application_field_id
		INTO #field_value_pair
		FROM application_ui_template aut
		INNER JOIN application_ui_template_group ag ON aut.application_ui_template_id = ag.application_ui_template_id
		INNER JOIN application_ui_template_definition ad ON aut.application_function_id = ad.application_function_id
		INNER JOIN application_ui_template_fields autf ON autf.application_group_id = ag.application_group_id
			AND autf.application_ui_field_id = ad.application_ui_field_id
		LEFT JOIN user_defined_fields_template udft ON udft.udf_template_id = autf.udf_template_id
			/*
			spa_create_application_ui_json 'j' flag generates field name for UDF as 'udf_' + ABS(udft.field_name), which is actually sdv.value_id.
			So we are re-creating same field name for UDF so that they can be joined.

			One idea to simply this is to put the UDF name like 'udf_' + ABS(udft.field_name) e.g. udf_5685 in application_ui_template_definition.field_id, but
			export-import logic of UI script will have trouble mapping UDF value as udft.field_name which is actually sdv.value_id keeps changing on differt systems.
			So we should put simple meaningful names in that field (e.g. Operator)
			*/
		INNER JOIN #unpivot_fields upf ON upf.field_name = CASE WHEN ISNULL(ad.is_udf,'n') = 'n' THEN ad.farrms_field_id ELSE 'udf_' + CAST(ABS(udft.field_name) AS VARCHAR(30)) END
		WHERE ad.application_function_id = @function_id
			AND ISNULL(ad.field_id,'') IS NOT NULL;

		-- Insert Grid Data	
		SET @col_list = NULL
		SELECT @col_list = coalesce(@col_list+N',', N'') + quotename(c.name) 
		FROM adiha_process.dbo.sysobjects o WITH(NOLOCK)
		INNER JOIN adiha_process.dbo.syscolumns c WITH(NOLOCK) ON o.id = c.id
			AND o.xtype = 'U'
		WHERE o.name = REPLACE(@grid_xml_table_name, 'adiha_process.dbo.', '')
			AND c.name <> 'grid_id'

		IF @grid_xml_table_name IS NOT NULL
		BEGIN
			SET @sql = '
			INSERT INTO #unpivot_fields
			SELECT _field_name_, field_value, grid_id, ''' + @grid_xml_table_name + '''
			FROM (
				SELECT ' + @col_list + ', grid_id
				FROM ' + @grid_xml_table_name + '
			) p
			UNPIVOT (field_value FOR _field_name_ IN (' + @col_list + '))AS unpvt;
		'

		EXEC(@sql)

		INSERT INTO #field_value_pair
		SELECT agd.grid_name table_name,
			   agcd.column_name field_id,
			   upf.field_value,
			   CASE WHEN agcd.field_type IN ('ro') THEN '''' ELSE '' END AS single_quote,
			   CASE WHEN agcd.is_unique = 'y' THEN agcd.column_name ELSE NULL END AS primary_key,
			   CASE WHEN agcd.is_unique = 'y' THEN upf.field_value ELSE NULL END AS primary_value,
			   agcd.fk_table fk_table,
			   agcd.fk_column fk_column,
			   process_table_name,
			   2 AS process_order,
			   ISNULL(agcd.is_unique, 'n') is_identity,
			   'n' is_udf,
			   0 AS application_field_id
		FROM adiha_grid_definition agd
		INNER JOIN adiha_grid_columns_definition agcd ON agcd.grid_id = agd.grid_id
		INNER JOIN #unpivot_fields upf ON upf.grid_id = agd.grid_name
			AND upf.field_name = agcd.column_name
		WHERE upf.grid_id IS NOT NULL 
			AND ISNULL(agcd.column_name, '''') IS NOT NULL;
		END
	
		SET @identity_insert_value = 0
		
		SELECT @fk_value_id = primary_value
		FROM #field_value_pair
		WHERE process_order = 1
			AND primary_key = 'y'
		
		-- If no form is defined then get the FK ID from Object ID
		IF @fk_value_id IS NULL
			SET @fk_value_id = @object_id
	
		DECLARE cur1 CURSOR LOCAL FOR
		
			SELECT table_name,
				   process_table_name,
				   process_order,
				   MAX(primary_value)
			FROM #field_value_pair
			GROUP BY table_name, process_table_name, process_order
			ORDER BY process_order
		
		OPEN cur1
		FETCH NEXT FROM cur1 INTO @table_name, @process_table_name, @process_order, @primary_value
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @update_list = NULL
			SET @where_condition = ''
			SET @insert_list = NULL
			SET @select_list = NULL
			SET @sql_join = ''

			SELECT @update_list = COALESCE(@update_list + N',', N'') + 'a.' + c.farrms_field_id + ' = ' + 'NULLIF(NULLIF(b.' + c.farrms_field_id + ', ''NULL''), '''')'
			FROM (
				SELECT DISTINCT
					   table_name,
					   farrms_field_id,
					   primary_key 
				FROM #field_value_pair
				WHERE table_name = @table_name
					AND is_udf = 'n'
			) c  
			WHERE c.primary_key IS NULL	

			SELECT DISTINCT @where_condition = COALESCE(@where_condition + N' ', N'') + 'AND a.' + c.primary_key + ' = ' + 'NULLIF(b.' + c.primary_key + ', ''NULL'')'
			FROM #field_value_pair c  
			WHERE c.primary_key IS NOT NULL
				AND table_name = @table_name
				AND is_udf = 'n'
			
			SELECT @final_update_sql = 'UPDATE a SET ' + @update_list + ' FROM ' + @table_name + ' a INNER JOIN ' + @process_table_name + ' b ON 1 = 1 ' + @where_condition;
			
			SELECT @final_update_sql = 'UPDATE a SET ' + @update_list + 'OUTPUT INSERTED.' + ISNULL(c.primary_key, '') + ' INTO #primary_id FROM ' + @table_name + ' a INNER JOIN ' + @process_table_name + ' b ON 1 = 1 ' + @where_condition
			FROM #field_value_pair c
			WHERE c.primary_key IS NOT NULL
				AND table_name = @table_name
				AND is_udf = 'n'
				
			SET @where_condition = ''

			SELECT @insert_list = COALESCE(@insert_list + N',', N'') +  'a.' + c.farrms_field_id,
				   @select_list = COALESCE(@select_list + N',', N'') + CASE WHEN c.fk_column IS NOT NULL AND @fk_value_id <> '0' THEN '''' + @fk_value_id + '''' ELSE 'NULLIF(NULLIF(a.' + c.farrms_field_id + ', ''NULL''), '''')' END
			FROM (
				SELECT DISTINCT
					   table_name,
					   farrms_field_id,
					   primary_key,
					   fk_column
				FROM  #field_value_pair
				WHERE is_identity <>'y'
					AND table_name = @table_name
					AND is_udf= 'n'
			) c
			WHERE 1 = 1

			SELECT DISTINCT
				   @sql_join = COALESCE(@sql_join + N' ', N'') + 'AND ' + CASE WHEN c.fk_column IS NOT NULL AND @fk_value_id <> '0' THEN '''' + @fk_value_id + '''' ELSE 'NULLIF(NULLIF(a.' + c.primary_key + ',''NULL''),'''')' END + ' = ' + 'b.' + c.primary_key
			FROM #field_value_pair c  
			WHERE c.primary_key IS NOT NULL
				AND table_name = @table_name
				AND is_udf = 'n'

			SELECT DISTINCT
				   @where_condition = COALESCE(@where_condition + N' ', N'') + CASE WHEN @identity_insert_value = 0 THEN  'AND b.' + c.primary_key +' IS NULL' ELSE '' END
			FROM #field_value_pair c
			WHERE c.primary_key IS NOT NULL
				AND table_name = @table_name
				AND is_udf = 'n'

			IF @sql_join IS NOT NULL
				SET @sql_join = 'LEFT JOIN ' + @table_name + ' b ON 1 = 1 ' + @sql_join  

			SET @final_insert_sql = '
				INSERT INTO ' + @table_name + '(' + @insert_list + ')
				SELECT DISTINCT ' + @select_list + '
				FROM ' + @process_table_name + ' a 
				' + @sql_join + ' 
				WHERE 1 = 1 
				' + @where_condition;
					
			IF @process_order <> 1
				SET @final_insert_sql += ' AND a.grid_id = ''' + @table_name + ''''
					
			IF @final_update_sql IS NOT NULL
			BEGIN
				EXEC(@final_update_sql)
			END	
					
			IF @final_insert_sql IS NOT NULL
			BEGIN
				EXEC(@final_insert_sql)
				
				IF @@ROWCOUNT>0
				BEGIN
					IF @process_order =1
					BEGIN
						SET @identity_insert_value = ISNULL(CAST(IDENT_CURRENT(@table_name) AS VARCHAR(200)), 0)
						SET @fk_value_id = @identity_insert_value
							
						INSERT INTO #primary_id(id)
						SELECT ISNULL(@identity_insert_value, 0)
					END
				END
				ELSE
				BEGIN
					SET @fk_value_id = @primary_value
				END
			END					
			--------------------------------UDF Values---------------------------------------
			SELECT @is_primary = primary_key
			FROM #field_value_pair
			WHERE primary_key IS NOT NULL
				AND table_name = @table_name

			SELECT @is_udf_present = COUNT(is_udf)
			FROM #field_value_pair
			WHERE is_udf = 'y'

			SELECT @udf_object_id = id
			FROM #primary_id
			
			IF @is_udf_present > 0  
			BEGIN	
				DELETE m  
				FROM maintain_udf_static_data_detail_values m 
				INNER JOIN #field_value_pair fvp ON fvp.application_field_id = m.application_field_id 
				WHERE m.primary_field_object_id = @udf_object_id
					
				SET @udf_insert = 'INSERT INTO maintain_udf_static_data_detail_values (application_field_id, primary_field_object_id, static_data_udf_values)'

				SET @udf_select = '
					SELECT fvp.application_field_id,
						   ' + @udf_object_id + ',
						   fvp.field_value 
					FROM #field_value_pair fvp
					LEFT JOIN maintain_udf_static_data_detail_values m ON fvp.application_field_id = m.application_field_id
						AND m.primary_field_object_id = ' + @udf_object_id + '
					WHERE is_udf = ''y''
						AND m.maintain_udf_detail_values_id IS NULL
				'
					
				EXEC (@udf_insert + @udf_select)
			END
			---------------------------------------------------------------------------------				

		FETCH NEXT FROM cur1 INTO @table_name, @process_table_name, @process_order, @primary_value
		END
		CLOSE cur1
		DEALLOCATE cur1

		DECLARE @return_string VARCHAR(100)
		IF @identity_insert_value <> '0'
		BEGIN
			IF @object_id<>'0'
				SET @return_string = @object_id + ',' + @identity_insert_value
			ELSE 
				SET @return_string = @identity_insert_value
		END
		ELSE
		BEGIN
			SET @return_string =  @object_id
		END
		
		IF @return_process_table IS NOT NULL
		BEGIN
			-- Insert Object ID into return process table
			DECLARE @return_sql VARCHAR(1000)
			SET @return_sql = 'INSERT INTO ' + @return_process_table + '(id) SELECT ' + IIF(@identity_insert_value <> '0', @identity_insert_value, @object_id)
			EXEC(@return_sql)
		END
		
		IF @success_message = 1
		EXEC spa_ErrorHandler 0, 'Process Form Data', 'spa_process_form_data', 'Success', 'Changes have been saved successfully.', @return_string
		RETURN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		IF CURSOR_STATUS ('local', 'cur1') > 0
		BEGIN
			  CLOSE cur1;
			  DEALLOCATE cur1;
		END
			
		SET @desc = dbo.FNAHandleDBError(@function_id)
	
		EXEC spa_ErrorHandler -1, 'Process Form Data', 'spa_process_form_data', 'Error', @desc, ''
	END CATCH
GO