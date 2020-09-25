IF OBJECT_ID(N'[dbo].[spa_insert_blotter_deal]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_insert_blotter_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Used to save newly created deal.

	Parameters:
		@flag									:	Operation flag that decides which action to perform.
		@process_id								:	Process ID of Deal related data from grid.
		@header_xml								:	Deal Header data in XML.
		@detail_xml								:	Deal Detail data in XML.
		@template_id							:	Template ID of deal.
		@call_from								:	From where the window is called from.
		@runtime_user							:	Which user is active during deal insertion.
		@deal_type_id							:	Identifier of the type of Deal.
		@pricing_type							:	Identifier of the type of Pricing.
		@term_frequency							:	Frequency of Term (Daily/Hourly/Monthly).
		@shaped_process_id						:	Unique Identifier to create process table for storing Shaped Data.
		@header_cost_xml						:	Data related to Header Cost built in form of XML when header cost tab is enabled.
		@formula_process_id						:	Unique Identifier to create process table for storing data related to Formula.
		@call_from_delivery_path				:	Specify if the procedure is called from delivery path.
		@commodity_id							:	Identifier of Commodity.
		@environment_process_id					:	Unique Identifier to create process table to store data of Environment tab.
		@certificate_process_id					:	Unique Identifier to create process table to store data of Certificate.
		@return_output							:	Return the Output (success or failure).
		@deal_price_data_process_id				:	Unique Identifier to create process table to store data of Complex Pricing.
		@deal_provisional_price_data_process_id	:	Unique Identifier to create process table to store data of Provisional Pricing.
*/

CREATE PROCEDURE [dbo].[spa_insert_blotter_deal]
	@flag NCHAR(1),
	@process_id NVARCHAR(200) = NULL,
	@header_xml XML,
	@detail_xml XML,
	@template_id INT,
	@call_from NVARCHAR(20) = 'blotter',
	@runtime_user NVARCHAR(100)  = NULL,
	@deal_type_id INT = NULL,
	@pricing_type INT = NULL,
	@term_frequency NCHAR(1) = NULL,
	@shaped_process_id NVARCHAR(200) = NULL,
	@header_cost_xml XML = NULL,
	@formula_process_id NVARCHAR(200) = NULL,
	@call_from_delivery_path NCHAR(1) = NULL,
	@commodity_id INT = NULL,
	@environment_process_id NVARCHAR(200) = NULL,
	@certificate_process_id  NVARCHAR(200) = NULL,
	@return_output NVARCHAR(200) = NULL OUTPUT,
	@deal_price_data_process_id NVARCHAR(50) = NULL,
	@deal_provisional_price_data_process_id NVARCHAR(50) = NULL
  	
AS
SET NOCOUNT ON

/*-------------Debug Section-----------------
SET NOCOUNT ON
DECLARE @flag NCHAR(1),
		@process_id NVARCHAR(200) = NULL,
		@header_xml XML = NULL,
		@detail_xml XML = NULL,
		@template_id INT,
		@call_from NVARCHAR(20) = 'blotter',
		@runtime_user NVARCHAR(100)  = NULL,
		@deal_type_id INT = NULL,
		@pricing_type INT = NULL,
		@term_frequency NCHAR(1) = NULL,
		@shaped_process_id NVARCHAR(200) = NULL,
		@header_cost_xml XML = NULL,
		@formula_process_id NVARCHAR(200) = NULL,
		@call_from_delivery_path NCHAR(1) = NULL,
		@commodity_id INT = NULL,
		@environment_process_id NVARCHAR(200) = NULL,
		@certificate_process_id  NVARCHAR(200) = NULL,
		@return_output NVARCHAR(200) = NULL,
		@deal_price_data_process_id NVARCHAR(50) = NULL,
		@deal_provisional_price_data_process_id NVARCHAR(50) = NULL

SELECT @flag='i',@call_from='form',@template_id='4026',@header_xml=N'<GridXML><GridRow row_id="1"  sub_book="4067" source_deal_header_id="" deal_id="" deal_date="2020-04-16" counterparty_id="10895" source_deal_type_id="1171" trader_id="2279" header_buy_sell_flag="b" fas_deal_type_value_id="400" profile_granularity="993" commodity_id="123" physical_financial_flag="p" description3="????????? ?????????????????? ??????????????" description4="????????? ?????????????????? ??????????????" description1="????????? ?????????????????? ??????????????" description2="????????? ?????????????????? ??????????????"></GridRow></GridXML>'
,@detail_xml=N'<GridXML><GridRow row_id="1"  deal_group="New Group" group_id="1" detail_flag="0" blotterleg="1" source_deal_detail_id="NEW_1" lock_deal_detail="n" term_start="2020-05-01" term_end="2020-05-31" contract_expiration_date="2020-05-31" buy_sell_flag="b" fixed_price="" deal_volume="100" deal_volume_frequency="a" deal_volume_uom_id="1158" physical_financial_flag="p"></GridRow></GridXML>',
@deal_type_id = N'1171',@pricing_type = 46700, @commodity_id = 123,
@term_frequency = 'm', @shaped_process_id = N'A1567068_1F3D_4658_BB84_B85D18106EBE', 
@environment_process_id='',@certificate_process_id=''
-------------------------------------------*/


IF @deal_price_data_process_id IS NOT NULL
BEGIN
	DECLARE @pricing_process_table NVARCHAR(100)

	SET @pricing_process_table = 'adiha_process.dbo.pricing_xml_' + dbo.FNADBUser() + '_' + @deal_price_data_process_id
END

IF @deal_provisional_price_data_process_id IS NOT NULL
BEGIN
	DECLARE @price_provisional_process_table NVARCHAR(100)

	SET @price_provisional_process_table = 'adiha_process.dbo.provisional_pricing_xml_' + dbo.FNADBUser() + '_' + @deal_provisional_price_data_process_id
END



IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

IF @process_id IS NULL
	SET @process_id = dbo.FNAGetNewID()
 
DECLARE @sql           NVARCHAR(MAX),
        @user_name     NVARCHAR(200) = dbo.FNADBUser()

DECLARE @field_template_id INT, @original_buy_sell NCHAR(1), @is_gas_daily NCHAR(1)
		
SELECT @field_template_id = field_template_id,
	   @commodity_id = ISNULL(@commodity_id, sdht.commodity_id),
	   @deal_type_id = ISNULL(@deal_type_id, sdht.source_deal_type_id)
FROM source_deal_header_template sdht
WHERE sdht.template_id = @template_id

DECLARE @template_buy_sell NCHAR(1)
SELECT @template_buy_sell = sdht.header_buy_sell_flag, @is_gas_daily = ISNULL(sdht.is_gas_daily, 'n')
FROM source_deal_header_template sdht WHERE sdht.template_id = @template_id

DECLARE @spot_or_term CHAR(1)

-- When the term type is spot then the term frequency is 'd', so the value of spot or term can be obtained.
IF @term_frequency = 'd'
	SET @spot_or_term = 's'
ELSE
	SET @spot_or_term = 't'

SET @original_buy_sell = @template_buy_sell

IF @term_frequency IS NULL
BEGIN
	SELECT @term_frequency = sdht.term_frequency_type
	FROM source_deal_header_template sdht
	WHERE sdht.template_id = @template_id
 
	IF EXISTS (
		SELECT 1
		FROM deal_default_value
		WHERE [deal_type_id] = @deal_type_id
			  AND [commodity] = @commodity_id
			  AND ( ([pricing_type] IS NULL AND @pricing_type IS NULL) OR [pricing_type] = @pricing_type)
			  AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@template_buy_sell, 'y'))
	)
	BEGIN
		SELECT @term_frequency = ISNULL(term_frequency, @term_frequency)
		FROM deal_default_value 
		WHERE deal_type_id = @deal_type_id 
		AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
		AND commodity = @commodity_id
		AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@template_buy_sell, 'y'))
	END
END

DECLARE @is_admin INT = dbo.FNAIsUserOnAdminGroup(@user_name, 0)

IF @flag = 'i'
BEGIN
    IF @header_xml IS NOT NULL
	BEGIN
		DECLARE @header_process_table NVARCHAR(200), @where NVARCHAR(200)
		SET @header_process_table = dbo.FNAProcessTableName('header_process_table', @user_name, @process_id)
		
		EXEC spa_parse_xml_file 'b', NULL, @header_xml, @header_process_table
		
		IF OBJECT_ID('tempdb..#temp_header_columns') IS NOT NULL
			DROP TABLE #temp_header_columns
		
		IF OBJECT_ID('tempdb..#temp_sdh') IS NOT NULL
			DROP TABLE #temp_sdh
		
		IF OBJECT_ID('tempdb..#temp_not_null_sdh') IS NOT NULL
			DROP TABLE #temp_not_null_sdh
		
		IF OBJECT_ID('tempdb..#field_template') IS NOT NULL
			DROP TABLE #field_template
			
		IF OBJECT_ID('tempdb..#temp_template_default') IS NOT NULL
			DROP TABLE #temp_template_default
			
		CREATE TABLE #temp_header_columns (
			column_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			columns_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)
		
		CREATE TABLE #temp_sdh(
			column_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			data_type        NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_nullable		 NVARCHAR(20) COLLATE DATABASE_DEFAULT
		)
				
		CREATE TABLE #temp_not_null_sdh(
			column_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			data_type        NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value	 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
			default_label	 NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)
		
		CREATE TABLE #field_template(
			farrms_field_id     NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			field_label			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value       NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type           NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_udf              NCHAR(1) COLLATE DATABASE_DEFAULT,
			insert_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			update_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			min_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			max_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)
		
		CREATE TABLE #temp_template_default(
			column_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value	 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)
				
		DECLARE @table_name NVARCHAR(200) = REPLACE(@header_process_table, 'adiha_process.dbo.', '')
		
		SET @where = 'row_id = 1'
		INSERT INTO #temp_header_columns	
		EXEC spa_Transpose @table_name, @where, 1
		SET @where = NULL
		
		INSERT INTO #temp_sdh
		SELECT column_name,
				DATA_TYPE,
				IS_NULLABLE
		FROM INFORMATION_SCHEMA.Columns
		WHERE TABLE_NAME = 'source_deal_header'
		AND COLUMN_DEFAULT IS NULL
		
		INSERT INTO #temp_not_null_sdh (column_name, data_type)
		SELECT column_name,
			   DATA_TYPE
		FROM #temp_sdh
		WHERE is_nullable = 'no' AND column_name NOT IN ('source_deal_header_id', 'deal_id')
		UNION ALL
		SELECT mfd.farrms_field_id, mfd.data_type
		FROM maintain_field_template_detail mftd
		INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
		where field_template_id = @field_template_id 
		AND ISNULL(mftd.value_required, '') = 'y' 
		AND udf_or_system = 's' 
		AND mfd.header_detail = 'h'
		AND mfd.farrms_field_id NOT IN ('source_deal_header_id', 'deal_id', 'template_id')

		INSERT #field_template
		SELECT *
		FROM FNAGetTemplateFieldTable(@template_id, 'h', 'y') j 
		
		SET @where = 'template_id = ' + CAST(@template_id AS NVARCHAR(20))
		INSERT INTO #temp_template_default
		EXEC spa_Transpose 'source_deal_header_template', @where
		SET @where = NULL
		
		UPDATE ft
		SET default_value = ISNULL(ttd.default_value, ft.default_value)
		FROM #field_template ft
		INNER JOIN #temp_template_default ttd ON ft.farrms_field_id = ttd.column_name 
		
		UPDATE tnns 
		SET default_label = ISNULL(ft.field_label, tnns.column_name)
		FROM #temp_not_null_sdh tnns
		LEFT JOIN #field_template ft ON tnns.column_name = ft.farrms_field_id

		UPDATE tnns
		SET default_label = 'Sub Book'
		FROM #temp_not_null_sdh tnns
		INNER JOIN #temp_header_columns thc ON thc.column_name = 'sub_book'
		WHERE tnns.column_name = 'source_system_book_id1'
		
		DECLARE @hidden_table_columns NVARCHAR(MAX)
		DECLARE @hidden_column_string NVARCHAR(MAX)
		
		SELECT @hidden_table_columns = COALESCE(@hidden_table_columns + ',', '') + ft.farrms_field_id + ' ' + 
			CASE ft.data_type 
				WHEN 'VARCHAR' THEN 'NVARCHAR(2000) COLLATE DATABASE_DEFAULT' 
				WHEN 'CHAR' THEN 'NCHAR(2) COLLATE DATABASE_DEFAULT' 
				WHEN 'number' THEN 'NUMERIC(38, 20)' 
				WHEN 'price' THEN 'NUMERIC(38, 20)' ELSE ft.data_type 
			END
			+ CASE WHEN ft.default_value IS NULL THEN '' ELSE ' DEFAULT ''' 
			+ CASE WHEN ft.data_type = 'datetime' THEN dbo.FNAGetSQLStandardDate(ft.default_value) 
				ELSE CAST(ft.default_value AS NVARCHAR(2000)) END  + '''' 
				END,
			   @hidden_column_string = COALESCE(@hidden_column_string + ',', '') + ft.farrms_field_id
		FROM #field_template ft
		LEFT JOIN #temp_header_columns thc ON ft.farrms_field_id = thc.column_name
		WHERE ft.farrms_field_id NOT LIKE '%UDF___%' AND ft.farrms_field_id <> 'template_id'
		AND thc.column_name IS NULL
		
		DECLARE @insert_value_string NVARCHAR(MAX)
		DECLARE @insert_column_string NVARCHAR(MAX)
		DECLARE @insert_table_columns NVARCHAR(MAX)
		--DECLARE @h_udf_update_string NVARCHAR(MAX)
		
		SELECT @insert_value_string = COALESCE(@insert_value_string + ',', '') + CASE WHEN tsdh.data_type = 'datetime' THEN 'dbo.FNAGetSQLStandardDate(NULLIF(LTRIM(RTRIM(' + thc.column_name + ')),''''))' ELSE 'NULLIF(LTRIM(RTRIM(' + thc.column_name + ')),'''')' END,
			   @insert_column_string = COALESCE(@insert_column_string + ',', '') + tsdh.column_name,
			   @insert_table_columns  = COALESCE(@insert_table_columns + ',', '') + tsdh.column_name + ' ' + CASE tsdh.data_type WHEN 'varchar' THEN 'VARCHAR(2000) COLLATE DATABASE_DEFAULT' WHEN 'numeric' THEN 'NUMERIC(38, 20)' WHEN 'nvarchar' THEN 'NVARCHAR(MAX) COLLATE DATABASE_DEFAULT' ELSE tsdh.data_type END
		FROM #temp_header_columns thc
		INNER JOIN #temp_sdh tsdh ON tsdh.column_name = thc.column_name
		WHERE tsdh.column_name NOT IN ('source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'template_id')
		AND thc.column_name NOT LIKE '%UDF___%'		
		
		IF OBJECT_ID('tempdb..#temp_source_deal_header') IS NOT NULL
			DROP TABLE #temp_source_deal_header
			
		CREATE TABLE #temp_source_deal_header (
			sno INT IDENTITY(1,1)
		)	
	
		SET @sql = 'ALTER TABLE #temp_source_deal_header ADD row_id INT, ' + @insert_table_columns + ISNULL(',' + @hidden_table_columns, '''')
		--PRINT(@sql)
		EXEC(@sql)
			
		IF COL_LENGTH('tempdb..#temp_source_deal_header', 'pricing_type') IS NULL
  		BEGIN
  			ALTER TABLE #temp_source_deal_header ADD pricing_type INT
  		END

		IF COL_LENGTH('tempdb..#temp_source_deal_header', 'commodity_id') IS NULL
  		BEGIN
  			ALTER TABLE #temp_source_deal_header ADD commodity_id INT
  		END
			
		SET @sql = '
					INSERT INTO #temp_source_deal_header (row_id, ' + @insert_column_string + ')
					SELECT row_id, ' + @insert_value_string + '
					FROM ' + @header_process_table + '
					
					UPDATE temp
					SET source_system_book_id1 = ssbm.source_system_book_id1,
						source_system_book_id2 = ssbm.source_system_book_id2,
						source_system_book_id3 = ssbm.source_system_book_id3,
						source_system_book_id4 = ssbm.source_system_book_id4
					FROM #temp_source_deal_header temp
					INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = temp.sub_book		
					
					UPDATE #temp_source_deal_header
					SET deal_id = ''SYSTEM____'' + dbo.FNAGETNewID()
					WHERE NULLIF(deal_id, '''') IS NULL						
					'
		--PRINT(@sql)
		EXEC(@sql)
		
		IF NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'trader_id')
		BEGIN			
			DECLARE @trader_id INT
			SELECT @trader_id = st.source_trader_id
			FROM source_traders st
			WHERE st.user_login_id = dbo.FNADBUser()
		
			UPDATE #temp_source_deal_header 
			SET trader_id = @trader_id
			WHERE @trader_id IS NOT NULL
		END

		DECLARE @temp_is_mapping_updated NCHAR(1) = 'n'
		IF @deal_type_id IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'source_deal_type_id') OR @call_from <> 'blotter'
			BEGIN
				UPDATE #temp_source_deal_header SET source_deal_type_id = @deal_type_id WHERE 1 = 1
			END
			
			IF EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'source_deal_type_id') AND @call_from = 'blotter'
			BEGIN
				SELECT TOP(1) @deal_type_id = source_deal_type_id, @template_buy_sell = header_buy_sell_flag
				FROM #temp_source_deal_header
				
				SET @temp_is_mapping_updated = 'y'				
			END
		END

		IF @pricing_type IS NOT NULL
		BEGIN
			UPDATE #temp_source_deal_header SET pricing_type = @pricing_type WHERE 1 = 1
		END

		IF @commodity_id IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'commodity_id') OR @call_from <> 'blotter'
			BEGIN
				UPDATE #temp_source_deal_header SET commodity_id = @commodity_id WHERE 1 = 1
			END
			
			IF EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'commodity_id') AND @call_from = 'blotter'
			BEGIN
				SELECT TOP(1) @commodity_id = commodity_id, @template_buy_sell = header_buy_sell_flag
				FROM #temp_source_deal_header
				SET @temp_is_mapping_updated = 'y'
			END
		END

		IF @temp_is_mapping_updated = 'y'
		BEGIN
			IF EXISTS (
				SELECT 1
				FROM deal_default_value
				WHERE [deal_type_id] = @deal_type_id
					AND [commodity] = @commodity_id
					AND ( ([pricing_type] IS NULL AND @pricing_type IS NULL) OR [pricing_type] = @pricing_type)
					AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@template_buy_sell, 'y'))
			)
			BEGIN
				SELECT @term_frequency = ISNULL(term_frequency, @term_frequency)
				FROM deal_default_value 
				WHERE deal_type_id = @deal_type_id 
				AND ((pricing_type IS NULL AND @pricing_type IS NULL) OR pricing_type = @pricing_type)
				AND commodity = @commodity_id
				AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(@template_buy_sell, 'y'))
			END
		END

		IF OBJECT_ID('tempdb..#temp_not_null_error_handler') IS NOT NULL
			DROP TABLE #temp_not_null_error_handler
		
		CREATE TABLE #temp_not_null_error_handler (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			row_id INT
		)	
		
		-- not nullable columns error handeling 
		DECLARE @column_name NVARCHAR(300)
		DECLARE not_null_columns_cursor CURSOR  
		FOR
			SELECT column_name
			FROM #temp_not_null_sdh
			WHERE column_name NOT IN ('entire_term_start', 'entire_term_end')
		OPEN not_null_columns_cursor
		FETCH NEXT FROM not_null_columns_cursor INTO @column_name
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_not_null_error_handler
						SELECT ''' + @column_name + ''', row_id
						FROM #temp_source_deal_header
						WHERE NULLIF(' + @column_name + ', '''') IS NULL'
			EXEC(@sql)
		
			FETCH NEXT FROM not_null_columns_cursor INTO @column_name	
		END
		CLOSE not_null_columns_cursor
		DEALLOCATE not_null_columns_cursor 	
		
		DECLARE @err_msg NVARCHAR(2000)
		
		IF EXISTS (SELECT 1 FROM #temp_not_null_error_handler)
		BEGIN
			SELECT TOP(1) @err_msg = tnns.default_label + ' cannot be blank. (Deal Header row ID : ' + CAST(tnne.row_id AS NVARCHAR(20)) + ')' 
			FROM #temp_not_null_error_handler tnne
			INNER JOIN #temp_not_null_sdh tnns ON tnns.column_name = tnne.column_name
			
			EXEC spa_ErrorHandler -1,
				 'spa_insert_blotter_deal',
				 'spa_insert_blotter_deal',
				 'DB Error',
				  @err_msg,
				  ''
			RETURN
		END
		
		IF OBJECT_ID('tempdb..#temp_min_max_error_handler') IS NOT NULL
			DROP TABLE #temp_min_max_error_handler
		
		CREATE TABLE #temp_min_max_error_handler (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			row_id INT,
			error_type NVARCHAR(10) COLLATE DATABASE_DEFAULT
		)
		
		-- min-max columns error handeling 
		DECLARE @min_value NVARCHAR(200), 
				@max_value NVARCHAR(200)
		DECLARE min_max_columns_cursor CURSOR  
		FOR
			SELECT ft.farrms_field_id,ft.max_value, ft.min_value
			FROM #field_template ft
			WHERE (ft.min_value IS NOT NULL OR ft.max_value IS NOT NULL)
			AND (ISNULL(ft.min_value,0) <> ISNULL(ft.max_value, 0))
		OPEN min_max_columns_cursor
		FETCH NEXT FROM min_max_columns_cursor INTO @column_name, @max_value, @min_value
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_min_max_error_handler '
			DECLARE @min_val_check INT = 0
			
			IF @min_value IS NOT NULL
			BEGIN
				SET @sql += '
							 SELECT ''' + @column_name + ''', row_id, ''go beneath''
							 FROM #temp_source_deal_header
							 WHERE ' + @column_name + ' < ' + @min_value + ''
				SET @min_val_check = 1
			END	
			
			IF @max_value IS NOT NULL
			BEGIN
				SET @sql += CASE WHEN @min_val_check = 1 THEN ' UNION ALL ' ELSE '' END + 
							'
							 SELECT ''' + @column_name + ''', row_id, ''exceed''
							 FROM #temp_source_deal_header
							 WHERE ' + @column_name + ' > ' + @max_value + ''
			END		
			--PRINT(@sql)
			EXEC(@sql)
		
			FETCH NEXT FROM min_max_columns_cursor INTO @column_name, @max_value, @min_value	
		END
		CLOSE min_max_columns_cursor
		DEALLOCATE min_max_columns_cursor
		
		IF EXISTS (SELECT 1 FROM #temp_min_max_error_handler)
		BEGIN
			SELECT TOP(1)
			@err_msg = 'Value for ' + ft.field_label + ' should not ' + tnne.error_type + ' ' + CASE WHEN tnne.error_type = 'exceed' THEN ft.max_value ELSE ft.min_value END
			FROM #temp_min_max_error_handler tnne
			INNER JOIN #field_template ft ON ft.farrms_field_id = tnne.column_name 
			
			EXEC spa_ErrorHandler -1,
				 'spa_insert_blotter_deal',
				 'spa_insert_blotter_deal',
				 'DB Error',
				  @err_msg,
				  ''
			RETURN
		END
		ELSE
		BEGIN
			DROP TABLE #temp_min_max_error_handler
		END
		IF EXISTS (SELECT COUNT(deal_id) test FROM #temp_source_deal_header GROUP BY deal_id HAVING COUNT(deal_id) > 1)
		BEGIN
			EXEC spa_ErrorHandler -1,
					'spa_insert_blotter_deal',
					'spa_insert_blotter_deal',
					'DB Error',
					'Please enter unique Reference ID.',
					''    
			RETURN
		END
		
		IF EXISTS (SELECT 1
		           FROM   source_deal_header sdh
		           INNER JOIN #temp_source_deal_header temp ON temp.deal_id = sdh.deal_id)
		BEGIN			
			SELECT TOP(1) @err_msg = 'Reference ID ''' + sdh.deal_id + ''' already exists.'
		    FROM  source_deal_header sdh
		    INNER JOIN #temp_source_deal_header temp ON temp.deal_id = sdh.deal_id
			
			EXEC spa_ErrorHandler -1,
				 'spa_insert_blotter_deal',
				 'spa_insert_blotter_deal',
				 'DB Error',
				  @err_msg,
				  ''					
			RETURN
		END
		
		DECLARE @check_option_type NVARCHAR(100), @option_excercise_type NVARCHAR(100)
		SET @check_option_type = COL_LENGTH('tempdb..#temp_source_deal_header', 'option_type')
		SET @option_excercise_type = COL_LENGTH('tempdb..#temp_source_deal_header', 'option_excercise_type')
		
		IF @check_option_type IS NOT NULL
		BEGIN
			IF EXISTS (SELECT option_flag FROM #temp_source_deal_header WHERE option_flag = 'y' AND option_type IS NULL)
			BEGIN 
				SELECT TOP(1) @err_msg = ' Option Type field is blank in row ' + CAST(row_id AS NVARCHAR)
				FROM #temp_source_deal_header
				WHERE option_flag = 'y'
				AND   option_type IS NULL
					
				EXEC spa_ErrorHandler -1,
						'Error',
						'spa_InsertDealXmlBlotter',
						'DB Error',
						@err_msg,
						''
							
				RETURN
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM #temp_source_deal_header WHERE option_flag = 'y')
			BEGIN
				EXEC spa_ErrorHandler -1,
							'spa_insert_blotter_deal',
							'spa_insert_blotter_deal',
							'DB Error',
							'Option Type field is not defined in template',
							''
						
					RETURN
			END
		END

		IF @is_admin = 0
		BEGIN
			IF EXISTS(
				SELECT 1
				FROM #temp_source_deal_header temp
				LEFT JOIN template_mapping tm 
					ON tm.template_id = @template_id
					AND tm.deal_type_id = temp.source_deal_type_id
					--AND tm.commodity_id = temp.commodity_id
					AND ISNULL(tm.commodity_id, -1) = CASE WHEN tm.commodity_id IS NULL OR temp.commodity_id IS NULL THEN ISNULL(tm.commodity_id, -1) ELSE temp.commodity_id END
				LEFT JOIN template_mapping_privilege tmp 
					ON tmp.template_mapping_id = tm.template_mapping_id
					AND (tmp.[user_id] = @user_name OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
				WHERE tm.template_mapping_id IS NULL OR tmp.template_mapping_id IS NULL
			)
			BEGIN
				SELECT TOP(1) @err_msg = 'You do not have privilege to insert deal with combination [Template:' + sdht.template_name + ', Deal Type:' + sdt.source_deal_type_name + ', Commodity:' + sc.commodity_name + ']'
				FROM #temp_source_deal_header temp
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = @template_id
				INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = temp.source_deal_type_id
				INNER JOIN source_commodity sc ON sc.source_commodity_id = temp.commodity_id
				LEFT JOIN template_mapping tm 
					ON tm.template_id = @template_id
					AND tm.deal_type_id = temp.source_deal_type_id
					AND tm.commodity_id = temp.commodity_id
				LEFT JOIN template_mapping_privilege tmp 
					ON tmp.template_mapping_id = tm.template_mapping_id
					AND (tmp.[user_id] = @user_name OR tmp.role_id IN (SELECT fur.role_id FROM dbo.FNAGetUserRole(@user_name) fur))
				WHERE tm.template_mapping_id IS NULL OR tmp.template_mapping_id IS NULL 

				EXEC spa_ErrorHandler -1,
						'spa_insert_blotter_deal',
						'spa_insert_blotter_deal',
						'DB Error',
						@err_msg,
						''
						
				RETURN
			END
		END

		IF @option_excercise_type IS NOT NULL
		BEGIN
			IF EXISTS (
				SELECT option_flag
			    FROM  #temp_source_deal_header
			    WHERE  option_flag = 'y' AND option_excercise_type IS NULL
			)
			BEGIN 
				SELECT @err_msg = 'Option Excercise Type field is blank in row  ' + CAST(row_id AS NVARCHAR)
			    FROM  #temp_source_deal_header
			    WHERE  option_flag = 'y'
			    AND option_excercise_type IS NULL
			    
				EXEC spa_ErrorHandler -1,
				     'Error',
				     'spa_InsertDealXmlBlotter',
				     'DB Error',
				     @err_msg,
				     ''
				     
				RETURN
			END
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM #temp_source_deal_header WHERE option_flag = 'y')
			BEGIN
				EXEC spa_ErrorHandler -1,
							'spa_insert_blotter_deal',
							'spa_insert_blotter_deal',
							'DB Error',
							'Option Excercise Type field is not defined in template',
							''
						
				RETURN
			END
		END					
		
		--PRINT('-----header insert completed')
	END
	ELSE 
	BEGIN
		EXEC spa_ErrorHandler -1,
				'spa_insert_blotter_deal',
				'spa_insert_blotter_deal',
				'DB Error',
				'Incomplete information.',
				''
		RETURN
	END

	IF @detail_xml IS NOT NULL
	BEGIN
		DECLARE @detail_xml_table         NVARCHAR(200),
		        @detail_where             NVARCHAR(200),
		        @term_level_process_table NVARCHAR(300),
		        @detail_process_table     NVARCHAR(300)
		        
		SET @detail_xml_table = dbo.FNAProcessTableName('detail_xml_table', @user_name, @process_id)		
		SET @term_level_process_table = dbo.FNAProcessTableName('term_level_detail', 'system', @process_id)
		
		EXEC spa_parse_xml_file 'b', NULL, @detail_xml, @detail_xml_table
		
		IF EXISTS (
			SELECT 1
			FROM maintain_field_template_detail d
			INNER JOIN maintain_field_deal f
				ON  d.field_id = f.field_id
			INNER JOIN source_deal_header_template sdht
				ON sdht.field_template_id = d.field_template_id
			INNER JOIN source_deal_detail_template sddt
				ON sddt.template_id = sdht.template_id
			WHERE farrms_field_id = 'vintage' 
				AND udf_or_system = 's'
				AND sdht.template_id = @template_id
		)
		BEGIN
			SET @sql = '
				IF COL_LENGTH(''' + @detail_xml_table + ''', ''term_start'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_xml_table + ' ADD term_start DATETIME
				END
				
				IF COL_LENGTH(''' + @detail_xml_table + ''', ''term_end'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_xml_table + ' ADD term_end DATETIME
				END

				IF COL_LENGTH(''' + @detail_xml_table + ''', ''vintage'') IS NULL
				BEGIN
					ALTER TABLE ' + @detail_xml_table + ' ADD vintage NVARCHAR(10)
				END
			'
			EXEC (@sql)

			SET @sql = '
				UPDATE dxt
				SET dxt.term_start = CONVERT(DATE, ISNULL(sdv.code, 1900) + ''-01-01'', 120), 
						dxt.term_end = CONVERT(DATE, ISNULL(sdv.code, 1900) + ''-12-31'', 120)
				FROM ' + @detail_xml_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.value_id = dxt.vintage
						AND sdv.type_id = 10092
			'

			EXEC(@sql)
			
			SET @sql = '
				UPDATE dxt
				SET dxt.vintage = sdv.value_id 
				FROM ' + @detail_xml_table + ' dxt
				INNER JOIN static_data_value sdv
					ON sdv.code = YEAR(dxt.term_start)
						AND sdv.type_id = 10092
			'
			EXEC(@sql)
		END
				
		
		IF @is_gas_daily = 'y'
		BEGIN
			DECLARE @term_end_present INT
			SET @term_end_present = COL_LENGTH(@detail_xml_table, 'term_end')

			IF @term_end_present IS NOT NULL
			BEGIN
				SET @sql = '
					UPDATE ' + @detail_xml_table + '
					SET term_end = CONVERT(NVARCHAR(10), DATEADD(d, -1, term_end), 120)
				'
				EXEC(@sql)
			END			
		END
		
		DECLARE @formula_present INT
		SET @formula_present = COL_LENGTH(@detail_xml_table, 'formula_id')
		
		IF OBJECT_ID('tempdb..#temp_detail_columns') IS NOT NULL
			DROP TABLE #temp_detail_columns
			
		IF OBJECT_ID('tempdb..#temp_sdd') IS NOT NULL
			DROP TABLE #temp_sdd
		
		IF OBJECT_ID('tempdb..#temp_not_null_sdd') IS NOT NULL
			DROP TABLE #temp_not_null_sdd
		
		IF OBJECT_ID('tempdb..#field_template_detail') IS NOT NULL
			DROP TABLE #field_template_detail
			
		IF OBJECT_ID('tempdb..#temp_template_default_detail') IS NOT NULL
			DROP TABLE #temp_template_default_detail
		
		IF OBJECT_ID('tempdb..#temp_source_deal_groups') IS NOT NULL
			DROP TABLE #temp_source_deal_groups
		
		CREATE TABLE #temp_source_deal_groups (
			id INT IDENTITY(1,1),
			group_id INT,
			row_id INT,
			group_name NVARCHAR(500) COLLATE DATABASE_DEFAULT
		)
		
		CREATE TABLE #temp_detail_columns (
			column_name NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			column_value NVARCHAR(2000) COLLATE DATABASE_DEFAULT
		)
				
		CREATE TABLE #temp_sdd(
			column_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			data_type        NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_nullable		 NVARCHAR(20) COLLATE DATABASE_DEFAULT
		)
				
		CREATE TABLE #temp_not_null_sdd(
			column_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			data_type        NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value	 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
			default_label	 NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)
		
		CREATE TABLE #field_template_detail (
			farrms_field_id     NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			field_label			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value       NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			data_type           NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			is_udf              NCHAR(1) COLLATE DATABASE_DEFAULT,
			insert_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			update_required     NCHAR(1) COLLATE DATABASE_DEFAULT,
			min_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			max_value			NVARCHAR(200) COLLATE DATABASE_DEFAULT
		)
		
		CREATE TABLE #temp_template_fields_detail(
			column_name     NVARCHAR(200) COLLATE DATABASE_DEFAULT,
			default_value	 NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
		)
		
		DECLARE @detail_table_name NVARCHAR(200) = REPLACE(@detail_xml_table, 'adiha_process.dbo.', '')
		
		SET @detail_where = 'row_id = 1 AND blotterleg = 1'
		IF @call_from <> 'blotter'
		BEGIN
			SET @detail_where += ' AND group_id = 1'
		END		
		
		INSERT INTO #temp_detail_columns	
		EXEC spa_Transpose @detail_table_name, @detail_where, 1
		SET @detail_where = NULL
		
		INSERT INTO #temp_sdd
		SELECT column_name,
				DATA_TYPE,
				IS_NULLABLE
		FROM INFORMATION_SCHEMA.Columns
		WHERE TABLE_NAME = 'source_deal_detail'
		AND COLUMN_DEFAULT IS NULL
		
		
		INSERT INTO #temp_not_null_sdd (column_name, data_type)
		SELECT column_name,
			   DATA_TYPE
		FROM #temp_sdd
		WHERE is_nullable = 'no' AND column_name NOT IN ('source_deal_detail_id', 'source_deal_header_id', 'source_deal_group_id')
		UNION ALL
		SELECT mfd.farrms_field_id, mfd.data_type
		FROM maintain_field_template_detail mftd
		INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
		where field_template_id = @field_template_id 
		AND ISNULL(mftd.value_required, '') = 'y' 
		AND udf_or_system = 's' 
		AND mfd.header_detail = 'd'
		AND mfd.farrms_field_id NOT IN ('source_deal_detail_id', 'source_deal_header_id')
		UNION ALL 
		SELECT 'term_start', 'datetime'
		UNION ALL
		SELECT 'term_end', 'datetime'
		
		
		INSERT #field_template_detail
		SELECT *
		FROM FNAGetTemplateFieldTable(@template_id, 'd', 'y') j 
		
		UPDATE tnns 
		SET default_label = ISNULL(ft.field_label, tnns.column_name)
		FROM #temp_not_null_sdd tnns
		LEFT JOIN #field_template_detail ft ON tnns.column_name = ft.farrms_field_id
		
		SET @detail_where = 'leg=1 AND template_id = ' + CAST(@template_id AS NVARCHAR(20))
		INSERT INTO #temp_template_fields_detail
		EXEC spa_Transpose 'source_deal_detail_template', @detail_where
		SET @detail_where = NULL
		
		SELECT * INTO #temp_template_default_details FROM source_deal_detail_template WHERE template_id = @template_id
		
		SET @sql = 'INSERT INTO #temp_template_default_details(leg,fixed_float_leg,buy_sell_flag,curve_type,curve_id,deal_volume_frequency,deal_volume_uom_id,currency_id,block_description,template_id,commodity_id,create_user,create_ts,update_user,update_ts,day_count,physical_financial_flag,location_id,meter_id,strip_months_from,lag_months,strip_months_to,conversion_factor,pay_opposite,formula,settlement_currency,standard_yearly_volume,price_uom_id,category,profile_code,pv_party,adder_currency_id,booked,capacity,day_count_id,deal_detail_description,fixed_cost,fixed_cost_currency_id,formula_currency_id,formula_curve_id,formula_id,multiplier,option_strike_price,price_adder,price_adder_currency2,price_adder2,price_multiplier,process_deal_status,settlement_date,settlement_uom,settlement_volume,total_volume,volume_left,volume_multiplier2,term_start,term_end,contract_expiration_date,fixed_price,fixed_price_currency_id,deal_volume,status,lock_deal_detail,contractual_volume,contractual_uom_id,actual_volume,detail_commodity_id,detail_pricing,pricing_start,pricing_end,cycle,schedule_volume,origin,form,organic,attribute1,attribute2,attribute3,attribute4,attribute5,position_uom,detail_inco_terms,batch_id,detail_sample_control,crop_year,lot,buyer_seller_option,product_description)
					SELECT temp.blotterleg, temp3.fixed_float_leg,temp3.buy_sell_flag,temp3.curve_type,temp3.curve_id,temp3.deal_volume_frequency,temp3.deal_volume_uom_id,temp3.currency_id,temp3.block_description,temp3.template_id,temp3.commodity_id,temp3.create_user,temp3.create_ts,temp3.update_user,temp3.update_ts,temp3.day_count,temp3.physical_financial_flag,temp3.location_id,temp3.meter_id,temp3.strip_months_from,temp3.lag_months,temp3.strip_months_to,temp3.conversion_factor,temp3.pay_opposite,temp3.formula,temp3.settlement_currency,temp3.standard_yearly_volume,temp3.price_uom_id,temp3.category,temp3.profile_code,temp3.pv_party,temp3.adder_currency_id,temp3.booked,temp3.capacity,temp3.day_count_id,temp3.deal_detail_description,temp3.fixed_cost,temp3.fixed_cost_currency_id,temp3.formula_currency_id,temp3.formula_curve_id,temp3.formula_id,temp3.multiplier,temp3.option_strike_price,temp3.price_adder,temp3.price_adder_currency2,temp3.price_adder2,temp3.price_multiplier,temp3.process_deal_status,temp3.settlement_date,temp3.settlement_uom,temp3.settlement_volume,temp3.total_volume,temp3.volume_left,temp3.volume_multiplier2,temp3.term_start,temp3.term_end,temp3.contract_expiration_date,temp3.fixed_price,temp3.fixed_price_currency_id,temp3.deal_volume,temp3.status,temp3.lock_deal_detail,temp3.contractual_volume,temp3.contractual_uom_id,temp3.actual_volume,temp3.detail_commodity_id,temp3.detail_pricing,temp3.pricing_start,temp3.pricing_end,temp3.cycle,temp3.schedule_volume,temp3.origin,temp3.form,temp3.organic,temp3.attribute1,temp3.attribute2,temp3.attribute3,temp3.attribute4,temp3.attribute5,temp3.position_uom,temp3.detail_inco_terms,temp3.batch_id,temp3.detail_sample_control,temp3.crop_year,temp3.lot,temp3.buyer_seller_option,temp3.product_description 
					FROM ' + @detail_xml_table + ' temp
					LEFT JOIN #temp_template_default_details temp2 ON temp.blotterleg = temp2.leg
					OUTER APPLY (SELECT TOP(1) * FROM source_deal_detail_template WHERE template_id = ' + CAST(@template_id AS NVARCHAR(20)) + ' ORDER BY leg) temp3
					WHERE temp2.template_detail_id IS NULL
		'
		EXEC(@sql)
		
		
		
		DECLARE @detail_hidden_table_columns NVARCHAR(MAX)
		DECLARE @detail_hidden_columns_string NVARCHAR(MAX)
		DECLARE @detail_hidden_select_columns_string NVARCHAR(MAX)
		
		SELECT @detail_hidden_table_columns = COALESCE(@detail_hidden_table_columns + ',', '') + ft.farrms_field_id + ' ' + CASE ft.data_type WHEN 'NVARCHAR' THEN 'NVARCHAR(2000) COLLATE DATABASE_DEFAULT' WHEN 'NCHAR' THEN 'NCHAR(1) COLLATE DATABASE_DEFAULT' WHEN 'number' THEN 'NUMERIC(38, 20)' WHEN 'price' THEN 'NUMERIC(38, 20)' ELSE ft.data_type END,
			   @detail_hidden_columns_string = COALESCE(@detail_hidden_columns_string + ',', '') + ft.farrms_field_id,
			   @detail_hidden_select_columns_string = COALESCE(@detail_hidden_select_columns_string + ',', '') + 'NULLIF(LTRIM(RTRIM(ttdd.' + ft.farrms_field_id + ')),'''')'
		FROM #field_template_detail ft
		LEFT JOIN #temp_detail_columns thc ON ft.farrms_field_id = thc.column_name
		WHERE ft.farrms_field_id NOT LIKE '%UDF___%' 
		AND ft.farrms_field_id NOT IN ('source_deal_detail_id', 'source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'leg', 'total_volume')
		AND thc.column_name IS NULL
		
		DECLARE @detail_insert_column_string NVARCHAR(MAX)
		DECLARE @detail_select_column_string NVARCHAR(MAX)
		DECLARE @detail_insert_table_columns NVARCHAR(MAX)
		--DECLARE @h_udf_update_string NVARCHAR(MAX)
		
		SELECT @detail_insert_column_string = COALESCE(@detail_insert_column_string + ',', '') + tsdd.column_name,
			   @detail_select_column_string = COALESCE(@detail_select_column_string + ',', '') + 'NULLIF(LTRIM(RTRIM(tlpc.' + tsdd.column_name + ')),'''')',
			   @detail_insert_table_columns  = COALESCE(@detail_insert_table_columns + ',', '') + tsdd.column_name + ' ' + CASE tsdd.data_type WHEN 'NVARCHAR' THEN 'NVARCHAR(2000) COLLATE DATABASE_DEFAULT' WHEN 'NCHAR' THEN 'NCHAR(1) COLLATE DATABASE_DEFAULT' WHEN 'numeric' THEN 'NUMERIC(38, 20)' ELSE tsdd.data_type END
		FROM #temp_detail_columns thc
		INNER JOIN #temp_sdd tsdd ON tsdd.column_name = thc.column_name
		WHERE tsdd.column_name NOT IN ('source_deal_detail_id', 'source_deal_header_id', 'update_ts', 'update_user', 'create_ts', 'create_user', 'leg', 'total_volume')
		AND thc.column_name NOT LIKE '%UDF___%'		
		
		IF OBJECT_ID('tempdb..#temp_source_deal_detail') IS NOT NULL
			DROP TABLE #temp_source_deal_detail
			
		CREATE TABLE #temp_source_deal_detail (
			sno INT IDENTITY(1,1)
		)	
		
		SET @sql = 'ALTER TABLE #temp_source_deal_detail ADD row_id INT, blotterleg INT, group_id INT, group_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT, ' + @detail_insert_table_columns + ISNULL(',' + @detail_hidden_table_columns, '''')
		--PRINT(@sql)
		EXEC(@sql)
		
		IF ISNULL(CHARINDEX('detail_commodity_id', @detail_insert_table_columns), 0) = 0 AND ISNULL(CHARINDEX('detail_commodity_id', @detail_hidden_table_columns), 0) = 0
		BEGIN
			ALTER TABLE #temp_source_deal_detail ADD detail_commodity_id INT
		END
		
		IF OBJECT_ID(@term_level_process_table) IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO #temp_source_deal_detail (row_id, blotterleg, group_id, group_name, ' + @detail_insert_column_string + ', ' + @detail_hidden_columns_string + ')
						SELECT tlpc.row_id, tlpc.blotterleg, 1, NULL,' + @detail_select_column_string + ', ' + @detail_hidden_select_columns_string + ' 
						FROM ' + @term_level_process_table + ' tlpc
						INNER JOIN #temp_template_default_details ttdd 
							ON tlpc.blotterleg = ttdd.leg
						
					'
			--PRINT(@sql)
			EXEC(@sql)

			-- delete data from xml table if it is present in term level breakdown detail level process table
			SET @sql = 'DELETE dxt
			            FROM ' + @detail_xml_table + ' dxt
			            INNER JOIN ' + @term_level_process_table + ' tlpc 
							ON dxt.row_id = tlpc.row_id
							AND dxt.blotterleg = tlpc.blotterleg
						'
						
			EXEC(@sql)
		END
		
		SELECT * INTO #temp_break_down_data FROM #temp_source_deal_detail WHERE 1 = 2
		
		IF OBJECT_ID(@detail_xml_table) IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO #temp_break_down_data (row_id, blotterleg, group_id, group_name, ' + @detail_insert_column_string + ', ' + @detail_hidden_columns_string + ')
						SELECT tlpc.row_id, tlpc.blotterleg, tlpc.group_id, tlpc.deal_group, ' + @detail_select_column_string + ', ' + @detail_hidden_select_columns_string + ' 
						FROM ' + @detail_xml_table + ' tlpc
						INNER JOIN #temp_template_default_details ttdd 
							ON tlpc.blotterleg = ttdd.leg
						
						'
			EXEC(@sql)
		END

		/*Update term_end value based on term_start according to defined term frequency*/
		IF EXISTS (SELECT 1 from maintain_field_template_detail mftd
											INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
											WHERE mftd.field_template_id = @field_template_id
											AND mfd.farrms_field_id = 'term_end'
											AND mfd.header_detail = 'd'
											AND mftd.insert_required = 'n')
		BEGIN	

			UPDATE #temp_source_deal_detail
			SET term_end = CASE WHEN @term_frequency = 'm' THEN EOMONTH(term_start)
									WHEN @term_frequency = 'a' THEN CAST(DATEADD(ms,-3,DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,term_start)+1,0))) AS DATE)
								ELSE term_start
								END
			WHERE term_end IS NULL
				
			UPDATE #temp_break_down_data
			SET term_end = CASE WHEN @term_frequency = 'm' THEN EOMONTH(term_start)
									WHEN @term_frequency = 'a' THEN CAST(DATEADD(ms,-3,DATEADD(yy,0,DATEADD(yy,DATEDIFF(yy,0,term_start)+1,0))) AS DATE)
								ELSE term_start
						   END
			WHERE term_end IS NULL
		END
		
		IF EXISTS(SELECT 1 FROM #temp_break_down_data) 
		BEGIN
			IF OBJECT_ID('tempdb..#temp_terms') IS NOT NULL
				DROP TABLE #temp_terms
			
			CREATE TABLE #temp_terms (
				term_start DATETIME,
				term_end DATETIME,
				row_id INT,
				blotterleg INT,
				group_id INT,
				group_name NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			)
			
			IF @term_frequency <> 'h'
			BEGIN
				IF @term_frequency = 't'
				BEGIN
					INSERT INTO #temp_terms(term_start, term_end, row_id, blotterleg, group_id, group_name)
					SELECT [term_start], [term_end], row_id, blotterleg, group_id, group_name
					FROM #temp_break_down_data
				END
				ELSE
				BEGIN
					WITH cte_terms AS (
						SELECT [term_start], CASE WHEN [term_end] IS NOT NULL THEN CASE WHEN [term_end] < dbo.FNAGetTermEndDate(@term_frequency, [term_start], 0) THEN [term_end] ELSE dbo.FNAGetTermEndDate(@term_frequency, [term_start], 0) END ELSE NULL END [term_end], row_id, blotterleg, [term_end] [final_term_start], group_id, group_name
						FROM #temp_break_down_data
						UNION ALL
						SELECT dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), CASE WHEN [final_term_start] < dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) THEN [final_term_start] ELSE dbo.FNAGetTermEndDate(@term_frequency, dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1), 0) END, cte.row_id, cte.blotterleg, [final_term_start], group_id, group_name
						FROM cte_terms cte 
						WHERE dbo.FNAGetTermStartDate(@term_frequency, cte.[term_start], 1) <= [final_term_start]
					) 
					INSERT INTO #temp_terms(term_start, term_end, row_id, blotterleg, group_id, group_name)
					SELECT term_start, term_end, row_id, blotterleg, group_id, group_name
					FROM cte_terms
					option (maxrecursion 0)
				END
			END
			
			IF EXISTS(SELECT 1 FROM #temp_terms)
			BEGIN				
				SET @detail_select_column_string = REPLACE(REPLACE(@detail_select_column_string, 'tlpc.term_start', 'tt.term_start'), 'tlpc.term_end', 'tt.term_end')
				SET @detail_hidden_select_columns_string = REPLACE(REPLACE(@detail_hidden_select_columns_string, 'ttdd.term_start', 'tt.term_start'), 'ttdd.term_end', 'tt.term_end')
				
				SET @sql = 'INSERT INTO #temp_source_deal_detail (row_id, blotterleg, group_id, group_name, ' + @detail_insert_column_string + ', ' + @detail_hidden_columns_string + ')
							SELECT tlpc.row_id, tlpc.blotterleg, tlpc.group_id, tt.group_name, ' + @detail_select_column_string + ', ' + @detail_hidden_select_columns_string + ' 
							FROM #temp_terms tt
							INNER JOIN #temp_break_down_data tlpc ON tt.row_id = tlpc.row_id AND tt.blotterleg = tlpc.blotterleg AND tt.group_id = tlpc.group_id
							INNER JOIN #temp_template_default_details ttdd 
								ON tlpc.blotterleg = ttdd.leg
							'
				--PRINT(@sql)
				EXEC(@sql)
			END
		END

		IF COL_LENGTH('tempdb..#temp_source_deal_detail', 'shipper_code1') IS NOT NULL
		BEGIN
			UPDATE sdd
			SET shipper_code1 = scmd1_default.shipper_code_mapping_detail_id
			FROM  
			#temp_source_deal_detail sdd
			OUTER APPLY (SELECT counterparty_id FROM #temp_source_deal_header ) sdh 
			INNER JOIN shipper_code_mapping scm ON scm.counterparty_id = sdh.counterparty_id						
			OUTER APPLY
			(SELECT scmd1_fil.shipper_code_mapping_detail_id FROM
				(SELECT * FROM
					(SELECT scmd1_def.shipper_code_mapping_detail_id , 
						scmd1_def.shipper_code1, 
						scmd1_def.effective_date,
						ROW_NUMBER() OVER (PARTITION BY shipper_code1 ORDER BY scmd1_def.effective_date DESC) rn
							FROM shipper_code_mapping_detail scmd1_def
							WHERE scmd1_def.location_id = sdd.location_id 
								AND scmd1_def.shipper_code_id = scm.shipper_code_id
								AND scmd1_def.effective_date <= CAST(sdd.term_start AS DATE)
								AND scmd1_def.is_active = 'y'
					) a WHERE rn =1
				) b 
				INNER JOIN shipper_code_mapping_detail scmd1_fil ON
					b.effective_date = scmd1_fil.effective_date  AND scmd1_fil.location_id = sdd.location_id 
					AND scmd1_fil.is_active = 'y' AND scmd1_fil.shipper_code_id = scm.shipper_code_id
				AND ISNULL(NULLIF(scmd1_fil.shipper_code1_is_default, ''), 'n') = 'y'
			) scmd1_default
		END
		
		IF COL_LENGTH('tempdb..#temp_source_deal_detail', 'shipper_code2') IS NOT NULL
		BEGIN
			UPDATE sdd
			SET shipper_code2 = scmd2_default.shipper_code_mapping_detail_id
			FROM  
			#temp_source_deal_detail sdd
			OUTER APPLY (SELECT counterparty_id FROM #temp_source_deal_header ) sdh 
			INNER JOIN shipper_code_mapping scm ON scm.counterparty_id = sdh.counterparty_id
			OUTER APPLY 
			( SELECT scmd2_fil.shipper_code_mapping_detail_id FROM
				(SELECT * FROM
					(SELECT scmd2_def.shipper_code_mapping_detail_id , 
						scmd2_def.shipper_code, 
						scmd2_def.effective_date,
						ROW_NUMBER() OVER (PARTITION BY scmd2_def.shipper_code ORDER BY scmd2_def.effective_date DESC) rn
					FROM shipper_code_mapping_detail scmd2_def
					WHERE scmd2_def.location_id = sdd.location_id 
						AND scmd2_def.effective_date <= CAST(sdd.term_start AS DATE)
						AND scmd2_def.shipper_code_id = scm.shipper_code_id
						AND scmd2_def.is_active = 'y'	
					) a WHERE rn =1
				) b 
				INNER JOIN shipper_code_mapping_detail scmd2_fil ON b.effective_date = scmd2_fil.effective_date 
				AND scmd2_fil.location_id = sdd.location_id  
					AND scmd2_fil.is_active = 'y' AND scmd2_fil.shipper_code_id = scm.shipper_code_id
				AND ISNULL(NULLIF(scmd2_fil.is_default, ''), 'n') = 'y'	
			) scmd2_default
		END
		
		DECLARE @grouping_info NVARCHAR(MAX)
		DECLARE @grouping_alter_cols NVARCHAR(MAX)
		DECLARE @grouping_where NVARCHAR(MAX)
		DECLARE @grouping_select NVARCHAR(MAX)
		
		SELECT @grouping_info = dgi.grouping_columns
		FROM deal_grouping_information dgi 
		WHERE dgi.template_id = @template_id
		-- tsdg2.row_id = tsdh.row_id
		
		--IF @grouping_info IS NULL
 	--		SET @grouping_info = 'term_start,term_end,location_id,curve_id'

		SELECT @grouping_alter_cols = COALESCE(@grouping_alter_cols + ',', '') + spvc.item + ' NVARCHAR(MAX) COLLATE DATABASE_DEFAULT',
			   @grouping_where = COALESCE(@grouping_where + ' AND ', '') + 'tsdg.' + spvc.item + ' = tsdd.' + REPLACE(spvc.item, 'leg', 'blotterleg'),
			   @grouping_select = COALESCE(@grouping_select + ',', '') + 'tsdd.' + spvc.item
		FROM dbo.SplitCommaSeperatedValues(@grouping_info) spvc
		
		IF @grouping_alter_cols IS NOT NULL
		BEGIN
			EXEC('ALTER TABLE #temp_source_deal_groups ADD ' + @grouping_alter_cols) 
		END		
		
		SET @sql = 'INSERT INTO #temp_source_deal_groups (group_id, row_id, group_name ' + ISNULL(',' + @grouping_info, '') + ')
					SELECT ROW_NUMBER() OVER(PARTITION BY tsdd.row_id ORDER BY tsdd.row_id ASC),
						   tsdd.row_id,
						   NULLIF(dxt.deal_group, ''New Group'')   
						   ' + ISNULL(',' + REPLACE(@grouping_select, 'leg', 'blotterleg'), '') + '
					FROM #temp_source_deal_detail tsdd
					INNER JOIN ' + @detail_xml_table + ' dxt ON dxt.group_id = tsdd.group_id	
					GROUP BY tsdd.row_id, tsdd.group_id, NULLIF(dxt.deal_group, ''New Group'') ' + ISNULL(',' + REPLACE(@grouping_select, 'leg', 'blotterleg'), '')
		
		EXEC(@sql)

		SET @sql = 'UPDATE tsdd
					SET group_id = tsdg.group_id
		            FROM #temp_source_deal_detail tsdd
		            INNER JOIN #temp_source_deal_groups tsdg 
						ON tsdd.row_id = tsdg.row_id
						AND ISNULL(NULLIF(tsdd.group_name, ''New Group''), '''') = ISNULL(NULLIF(tsdg.group_name, ''New Group''), '''')
						' + ISNULL(' AND ' + @grouping_where, '') + '
		'
		EXEC(@sql)

		IF COL_LENGTH(N'tempdb..#temp_source_deal_detail', N'contract_expiration_date') IS NOT NULL
			AND COL_LENGTH(N'tempdb..#temp_source_deal_detail', N'term_end') IS NOT NULL
		BEGIN
			UPDATE tsdd
			SET contract_expiration_date = ISNULL(NULLIF(tsdd.contract_expiration_date, ''), tsdd.term_end)
			FROM #temp_source_deal_detail tsdd
			WHERE NULLIF(tsdd.contract_expiration_date, '') IS NULL
		END
		
		IF OBJECT_ID('tempdb..#temp_not_null_error_handler_detail') IS NOT NULL
			DROP TABLE #temp_not_null_error_handler_detail
		
		CREATE TABLE #temp_not_null_error_handler_detail (
			err_id INT IDENTITY(1,1),
			column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
			row_id INT,
			blotterleg INT
		)
				
		-- not nullable columns error handeling 
		DECLARE @detail_column_name NVARCHAR(300)
		DECLARE detail_not_null_columns_cursor CURSOR  
		FOR
			SELECT column_name
			FROM #temp_not_null_sdd
			WHERE column_name NOT IN ('leg')
		OPEN detail_not_null_columns_cursor
		FETCH NEXT FROM detail_not_null_columns_cursor INTO @detail_column_name
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			SET @sql = 'INSERT INTO #temp_not_null_error_handler_detail
						SELECT ''' + @detail_column_name + ''', row_id, blotterleg
						FROM #temp_source_deal_detail
						WHERE ' + @detail_column_name + ' IS NULL'
			--PRINT(@sql)
			EXEC(@sql)
		
			FETCH NEXT FROM detail_not_null_columns_cursor INTO @detail_column_name	
		END
		CLOSE detail_not_null_columns_cursor
		DEALLOCATE detail_not_null_columns_cursor 	
		
		IF EXISTS (SELECT 1 FROM #temp_not_null_error_handler_detail)
		BEGIN
			SELECT TOP(1) @err_msg = tnns.default_label + ' cannot be blank. (Deal Detail row id : ' + CAST(tnne.row_id AS NVARCHAR(20)) + ' leg : ' + CAST(tnne.blotterleg AS NVARCHAR(20)) + ')' 
			FROM #temp_not_null_error_handler_detail tnne
			INNER JOIN #temp_not_null_sdd tnns ON tnns.column_name = tnne.column_name
			
			EXEC spa_ErrorHandler -1,
					'spa_insert_blotter_deal',
					'spa_insert_blotter_deal',
					'DB Error',
					@err_msg,
					''
			RETURN
		END
		
		IF EXISTS (SELECT location_id
			FROM #temp_source_deal_detail
			WHERE physical_financial_flag = 'p'
			AND location_id IS NULL
		)
		BEGIN 
			SELECT TOP(1) @err_msg = 'Location must be defined for Physical Deal in row :' + CAST(row_id AS NVARCHAR) + ' and leg : ' + CAST(blotterleg AS NVARCHAR(20)) + '.'
			FROM #temp_source_deal_detail
			WHERE physical_financial_flag = 'p'
			AND location_id IS NULL
				
			EXEC spa_ErrorHandler -1,
					'spa_insert_blotter_deal',
					'spa_insert_blotter_deal',
					'DB Error',
					@err_msg,
					''
			RETURN
		END
				
		IF EXISTS (SELECT 1
				   FROM #temp_source_deal_detail
		           WHERE fixed_float_leg = 't'
				   AND curve_id IS NULL
		)
		BEGIN 
			SELECT TOP(1) @err_msg = 'Curve must be defined For Float deal in row :' + CAST(row_id AS NVARCHAR) + ' and leg : ' + CAST(blotterleg AS NVARCHAR(20)) + '.'
			FROM #temp_source_deal_detail
		    WHERE fixed_float_leg = 't'
			AND curve_id IS NULL
				
			EXEC spa_ErrorHandler -1,
					'spa_insert_blotter_deal',
					'spa_insert_blotter_deal',
					'DB Error',
					@err_msg,
					''
			RETURN
		END
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler -1,
				'spa_insert_blotter_deal',
				'spa_insert_blotter_deal',
				'DB Error',
				'Incomplete information.',
				''
		RETURN
	END
	
	IF NOT EXISTS(SELECT 1 FROM #temp_source_deal_header)
	BEGIN
		EXEC spa_ErrorHandler -1,
				'spa_insert_blotter_deal',
				'spa_insert_blotter_deal',
				'DB Error',
				'Incomplete information.',
				''
		RETURN
	END
	
	IF NOT EXISTS(SELECT 1 FROM #temp_source_deal_detail)
	BEGIN
		EXEC spa_ErrorHandler -1,
				'spa_insert_blotter_deal',
				'spa_insert_blotter_deal',
				'DB Error',
				'Incomplete information.',
				''
		RETURN
	END
	
	IF OBJECT_ID('tempdb..#temp_min_max_error_handler_detail') IS NOT NULL
		DROP TABLE #temp_min_max_error_handler_detail
	
	CREATE TABLE #temp_min_max_error_handler_detail (
		err_id INT IDENTITY(1,1),
		column_name NVARCHAR(300)  COLLATE DATABASE_DEFAULT,
		row_id INT,
		error_type NVARCHAR(10)  COLLATE DATABASE_DEFAULT
	)
	DECLARE @is_udf NCHAR(1)
	DECLARE min_max_columns_cursor_detail CURSOR  
	FOR
		SELECT ft.farrms_field_id,ft.max_value, ft.min_value, ft.is_udf
		FROM #field_template_detail ft
		WHERE (ft.min_value IS NOT NULL OR ft.max_value IS NOT NULL)
		AND (ISNULL(ft.min_value,0) <> ISNULL(ft.max_value, 0))
	OPEN min_max_columns_cursor_detail
	FETCH NEXT FROM min_max_columns_cursor_detail INTO @column_name, @max_value, @min_value, @is_udf
	WHILE @@FETCH_STATUS = 0   
	BEGIN
		SET @sql = 'INSERT INTO #temp_min_max_error_handler_detail '
		DECLARE @min_val_check_detail INT = 0
			
		IF @min_value IS NOT NULL
		BEGIN
			SET @sql += '
							SELECT ''' + @column_name + ''', row_id, ''go beneath''
							FROM ' + CASE WHEN @is_udf = 'n' THEN ' #temp_source_deal_detail ' ELSE @detail_xml_table END + '
							WHERE ' + @column_name + ' < ' + @min_value + ''
			SET @min_val_check_detail = 1
		END	
			
		IF @max_value IS NOT NULL
		BEGIN
			SET @sql += CASE WHEN @min_val_check_detail = 1 THEN ' UNION ALL ' ELSE '' END + 
						'
							SELECT ''' + @column_name + ''', row_id, ''exceed''
							FROM  ' + CASE WHEN @is_udf = 'n' THEN ' #temp_source_deal_detail ' ELSE @detail_xml_table END + '
							WHERE ' + @column_name + ' > ' + @max_value + ''
		END		
		--PRINT(@sql)
		EXEC(@sql)
		
		FETCH NEXT FROM min_max_columns_cursor_detail INTO @column_name, @max_value, @min_value, @is_udf
	END
	CLOSE min_max_columns_cursor_detail
	DEALLOCATE min_max_columns_cursor_detail
		
	IF EXISTS (SELECT 1 FROM #temp_min_max_error_handler_detail)
	BEGIN
		SELECT TOP(1)
		@err_msg = 'Value for ' + ft.field_label + ' should not ' + tnne.error_type + ' ' + CASE WHEN tnne.error_type = 'exceed' THEN ft.max_value ELSE ft.min_value END
		FROM #temp_min_max_error_handler_detail tnne
		INNER JOIN #field_template_detail ft ON ft.farrms_field_id = tnne.column_name 
			
		EXEC spa_ErrorHandler -1,
				'spa_insert_blotter_deal',
				'spa_insert_blotter_deal',
				'DB Error',
				@err_msg,
				''
		RETURN
	END
	ELSE
	BEGIN
		DROP TABLE #temp_min_max_error_handler_detail
	END
	
	--If buy_sell_flag field is not listed in deal detail grid then buy sell flag should be saved according to header buy sell. 
	IF EXISTS (SELECT 1 from maintain_field_template_detail mftd
                                            INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
                                            WHERE mftd.field_template_id = @field_template_id
                                            AND mfd.farrms_field_id = 'buy_sell_flag'
                                            AND mfd.header_detail = 'd'
                                            AND mftd.insert_required = 'n')
	BEGIN		
		UPDATE tsdd
		SET buy_sell_flag = IIF(tsdd.blotterleg%2 = 1, tsdh.header_buy_sell_flag, IIF(tsdh.header_buy_sell_flag = 'b', 's' , 'b')) 
		FROM #temp_source_deal_header tsdh
		INNER JOIN #temp_source_deal_detail tsdd ON tsdd.row_id = tsdh.row_id
		WHERE tsdh.header_buy_sell_flag <> @original_buy_sell
	END
	
	-- update entire term start and entire term end 
	UPDATE h
	SET entire_term_start = d.term_start,
		entire_term_end = d.term_end
	FROM #temp_source_deal_header h
	INNER JOIN (
			SELECT MIN(CAST(term_start AS DATETIME)) term_start,
					MAX(CAST(term_end AS DATETIME)) term_end,
					row_id
			FROM #temp_source_deal_detail
			GROUP BY row_id
	) d ON  h.row_id = d.row_id
		
	-- update physical financial flag in header
	UPDATE tdh
	SET physical_financial_flag = tdd.physical_financial_flag
	FROM #temp_source_deal_header tdh
	INNER JOIN #temp_source_deal_detail tdd
		ON  tdh.row_id = tdd.row_id
		AND tdd.blotterleg = 1
		
	CREATE TABLE #counterparty_block_info (
		counterparty_credit_block_id  INT,
		counterparty_id               INT,
		row_id                        INT,
		message_type                  NVARCHAR(30) COLLATE DATABASE_DEFAULT,
		msg_description               NVARCHAR(2000) COLLATE DATABASE_DEFAULT
	)
	
	-- collect all counterparty by checking the account status for counterparty, if credit info is defined for that counterparty
	INSERT INTO #counterparty_block_info (counterparty_id, row_id, message_type, msg_description)
	SELECT tdh.counterparty_id, tdh.row_id, 'status', 'Counterparty:' + sc.counterparty_name + ' account status is ' + sdv.[description] + '.Please update the account status in order to proceed with the deal entry.'
	FROM #temp_source_deal_header tdh
	INNER JOIN source_counterparty sc ON tdh.counterparty_id = sc.source_counterparty_id
	INNER JOIN counterparty_credit_info cci ON sc.source_counterparty_id = cci.Counterparty_id
	INNER JOIN static_data_value sdv ON sdv.value_id = cci.account_status
	WHERE sdv.value_id = 10085
	
	-- collect all counterparty by checking the product blocking information, if it is defined
	INSERT INTO #counterparty_block_info (counterparty_credit_block_id, counterparty_id, row_id, message_type, msg_description)
	SELECT DISTINCT 
		   scbt.counterparty_credit_block_id,
		   sc.source_counterparty_id,
		   tdh.row_id,
		   'block',
		   'Deal(s) Entry is unsuccessful.' + CASE tdh.header_buy_sell_flag
		                                            WHEN 'b' THEN ' Buy'
		                                            WHEN 's' THEN 'Sell'
		                                            ELSE ''
		                                        END 
		    + ' Transaction of Deal type:' + ISNULL(sdt.source_deal_type_name, '') 
		    + ' with Counterparty:' + ISNULL(sc.counterparty_name, '') + 
		    ' for Commodity:' + ISNULL(scom.commodity_name, '')
		    + ' and Contract:' + ISNULL(cg.contract_name, '') + 
		    ' is not allowed.'
	FROM #temp_source_deal_header tdh
	INNER JOIN #temp_source_deal_detail tdd ON tdh.row_id = tdd.row_id
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = tdd.curve_id 
	INNER JOIN source_counterparty sc ON tdh.counterparty_id = sc.source_counterparty_id
	INNER JOIN counterparty_credit_info cci ON sc.source_counterparty_id = cci.Counterparty_id
	INNER JOIN counterparty_credit_block_trading scbt
		ON  scbt.counterparty_credit_info_id = cci.counterparty_credit_info_id
		AND ISNULL(cci.check_apply, 'n') = 'y'
		AND ISNULL(active, 'n') = 'y'
		AND scbt.comodity_id = spcd.commodity_id
		AND scbt.deal_type_id = tdh.source_deal_type_id
		AND scbt.contract = tdh.contract_id
		AND scbt.buysell_allow = tdh.header_buy_sell_flag
	INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = scbt.deal_type_id
	INNER JOIN source_commodity scom ON scom.source_commodity_id = scbt.comodity_id
	INNER JOIN contract_group cg ON cg.contract_id = scbt.contract
	  
	
	IF EXISTS(SELECT 1 FROM #counterparty_block_info)
	BEGIN
		DECLARE @url_desc NVARCHAR(MAX)
		DECLARE @process_table_view NVARCHAR(300)
		
		SET @process_table_view = dbo.FNAProcessTableName('batch_report', @user_name, @process_id)
		
		SET @sql = 'IF OBJECT_ID(''' + @process_table_view + ''') IS NOT NULL
		                DROP TABLE ' + @process_table_view + '
		            
		            SELECT msg_description [Error Description] 
		            INTO ' + @process_table_view  + '
		            FROM   #counterparty_block_info'
		
		EXEC (@sql)

		SET @url_desc = 'batch_report_view NULL,''' + @process_id + ''',''s'''
		--PRINT(@url_desc)

		SET @url_desc = 'Product blocking for the counterparty is found.'
		
		EXEC spa_ErrorHandler -1,
				'spa_insert_blotter_deal',
				'spa_insert_blotter_deal',
				'DB Error',
				@url_desc,
				@url_desc
		RETURN
	END
	
	IF OBJECT_ID('tempdb..#temp_inserted_source_deal_header') IS NOT NULL
		DROP TABLE #temp_inserted_source_deal_header
	
	CREATE TABLE #temp_inserted_source_deal_header (
		source_deal_header_id INT,
		deal_id NVARCHAR(300) COLLATE DATABASE_DEFAULT,
		row_id INT
	)
	
	IF OBJECT_ID('tempdb..#temp_inserted_source_deal_detail') IS NOT NULL
		DROP TABLE #temp_inserted_source_deal_detail
	
	CREATE TABLE #temp_inserted_source_deal_detail(
		source_deal_header_id     INT,
		source_deal_detail_id     NVARCHAR(300) COLLATE DATABASE_DEFAULT,
		term_start                DATETIME,
		term_end                  DATETIME,
		leg                       INT,
		row_id					  INT,
		group_id				  INT
	)
		
	--SELECT * INTO #source_deal_header FROM source_deal_header WHERE 1 = 2
	--SELECT * INTO #source_deal_detail FROM source_deal_detail WHERE 1 = 2
	
	BEGIN TRAN
	BEGIN TRY				
			SET @sql = '
						INSERT INTO source_deal_header (' + @insert_column_string + ',' + @hidden_column_string + ', template_id)
						OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id INTO #temp_inserted_source_deal_header (source_deal_header_id, deal_id)
						SELECT ' + @insert_column_string + ',' + @hidden_column_string + ', ' + CAST(@template_id AS NVARCHAR(20)) + '
						FROM #temp_source_deal_header '
			--PRINT(@sql)
			EXEC(@sql)
			
			UPDATE th
			SET row_id = tsdh.row_id
			FROM #temp_inserted_source_deal_header th
			INNER JOIN #temp_source_deal_header tsdh ON th.deal_id = tsdh.deal_id
			
			UPDATE sdh
			SET deal_id = ISNULL(drip.prefix, 'FARRMS_') + CAST(sdh.source_deal_header_id AS NVARCHAR(100))
			FROM source_deal_header sdh
			INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
			LEFT JOIN deal_reference_id_prefix drip
				ON  sdh.source_deal_type_id = drip.deal_type
			WHERE sdh.deal_id LIKE 'SYSTEM____%'
			
			UPDATE sdh
			SET internal_deal_type_value_id = sdht.internal_deal_type_value_id,
				internal_deal_subtype_value_id = sdht.internal_deal_subtype_value_id
			FROM source_deal_header sdh
			INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id

			IF @commodity_id IS NULL
			BEGIN
				SELECT TOP(1) @commodity_id = sdh.commodity_id
				FROM #temp_inserted_source_deal_header temp
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = temp.source_deal_header_id
			END
			ELSE
			BEGIN
				DECLARE @deal_commodity_id INT
				SELECT TOP(1) @deal_commodity_id = sdh.commodity_id
				FROM #temp_inserted_source_deal_header temp
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = temp.source_deal_header_id

				IF @commodity_id <> @deal_commodity_id
					SET @commodity_id = @deal_commodity_id
			END
			
			IF NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'internal_counterparty')
			BEGIN				
				UPDATE sdh
				SET internal_counterparty = COALESCE(sdht.internal_counterparty,ssbm.primary_counterparty_id, fb.primary_counterparty_id, fst.primary_counterparty_id, fs.counterparty_id, pcpty.counterparty_id)
				FROM source_deal_header sdh
				INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
				INNER JOIN source_system_book_map ssbm
					ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
				INNER JOIN fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
				INNER JOIN portfolio_hierarchy ph_book ON ph_book.[entity_id] = fb.fas_book_id
				INNER JOIN portfolio_hierarchy ph_st ON ph_st.[entity_id] = ph_book.parent_entity_id
				INNER JOIN portfolio_hierarchy ph_sub ON ph_sub.[entity_id] = ph_st.parent_entity_id
				INNER JOIN fas_subsidiaries fs ON ph_sub.[entity_id] = fs.fas_subsidiary_id
				INNER JOIN fas_strategy fst ON ph_st.[entity_id] = fst.fas_strategy_id
				OUTER APPLY (SELECT counterparty_id FROM fas_subsidiaries WHERE fas_subsidiary_id = -1) pcpty
			END
						
			DECLARE @confirm_status_new INT = 17200
			DECLARE @deal_status_new INT

			SELECT @deal_status_new = srd.Change_to_status_id
			FROM   status_rule_detail srd
			INNER JOIN status_rule_header srh
				ON  srh.status_rule_id = srd.status_rule_id
			LEFT JOIN static_data_value sdv1
				ON  srd.event_id = sdv1.value_id
				AND sdv1.[type_id] = 19500
			WHERE  srh.status_rule_name = 'Deal Status'
				   AND sdv1.code = 'deal insert'
				   AND srd.event_id = 19501
			
			UPDATE sdh
			SET deal_status = ISNULL(sdh.deal_status, @deal_status_new),
				confirm_status_type = ISNULL(sdh.confirm_status_type, @confirm_status_new),
				term_frequency = @term_frequency
			FROM source_deal_header sdh
			INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
			
			IF Exists (SELECT  template_id
				FROM maintain_field_template_detail mftd
				INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id
				INNER JOIN source_deal_header_template sdht ON sdht.field_template_id = mftd.field_template_id
				WHERE mfd.farrms_field_id IN ('is_environmental') AND sdht.template_id = @template_id )
			BEGIN
			DECLARE @check_rec int = 0
			DECLARE @environmental_process_table NVARCHAR (200)
				Set @environmental_process_table = dbo.FNAProcessTableName('environmental', @user_name, @environment_process_id)
            DECLARE @certificate_process_table NVARCHAR (200)
				Set @certificate_process_table = dbo.FNAProcessTableName('certificate', @user_name, @certificate_process_id)

				--PRINT @environmental_process_table
				--PRINT @certificate_process_table


			IF OBJECT_ID(@environmental_process_table) IS NOT NULL
				OR
			OBJECT_ID(@certificate_process_table) IS NOT NULL
			OR 
			EXISTS(Select 1 from source_deal_header sdh
			INNER JOIN rec_generator rg on rg.generator_id = sdh.generator_id
			INNER JOIN eligibility_mapping_template_detail emtd on emtd.template_id = rg.eligibility_mapping_template_id
			where sdh.generator_id IS NOT NULL AND source_deal_header_id = (select source_deal_header_id from #temp_inserted_source_deal_header))
			OR 
			EXISTS(Select columns_value FROM  #temp_header_columns WHERE column_name in ('state_value_id') and columns_value is not null) AND Exists(Select columns_value FROM  #temp_header_columns WHERE column_name in ('tier_value_id') and columns_value is not null)
				BEGIN 
					SET @check_rec = 1
				END
				ELSE 
				BEGIN
					SET @err_msg = 'Data in Jurisdiction or Tier field is missing. Please check the data and resave.'	
					
					IF @@TRANCOUNT > 0
						ROLLBACK

					EXEC spa_ErrorHandler -1,
									'spa_insert_blotter',
									'spa_insert_blotter',
									'DB Error',
									@err_msg,
								'' 	
					RETURN
				END
			END

			IF (@check_rec = 1)
			BEGIN
			IF @environment_process_id IS NOT NULL
			BEGIN				
				IF OBJECT_ID(@environmental_process_table) IS NOT NULL
				BEGIN
					SET @sql = '
						UPDATE temp
						SET temp.source_deal_header_id = tsdh.source_deal_header_id
						FROM ' + @environmental_process_table + ' temp
						INNER JOIN  
							 #temp_inserted_source_deal_header tsdh	ON 1 = 1							
					'	
					EXEC (@sql)								
					EXEC spa_gis_product_detail  @flag  = 'v', @environment_process_id = @environment_process_id
					
				END
			END
			END
			
			
			IF OBJECT_ID('tempdb..#temp_sdg') IS NOT NULL
				DROP TABLE #temp_sdg
			
			CREATE TABLE #temp_sdg (
				id INT IDENTITY(1, 1),
				source_deal_header_id INT,
				source_deal_groups_id INT,
				term_from DATETIME,
				term_to DATETIME,
				location_id INT,
				curve_id INT,
				group_id INT,
				leg INT
			)
			
			INSERT INTO source_deal_groups (
				source_deal_header_id,
				detail_flag,
				source_deal_groups_name, 
				static_group_name, 
				quantity
			)
			OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_groups_id INTO #temp_sdg (source_deal_header_id, source_deal_groups_id)
			SELECT source_deal_header_id,
			       0,
			       CASE WHEN CHARINDEX('::', tsdg.group_name) = 0 AND CHARINDEX('x->', tsdg.group_name) = 0 THEN tsdg.group_name
						WHEN CHARINDEX('x->', tsdg.group_name) <> 0 AND CHARINDEX('::', tsdg.group_name) = 0
							THEN SUBSTRING(tsdg.group_name, CHARINDEX('x->', tsdg.group_name)+3, LEN(tsdg.group_name))
						ELSE SUBSTRING(tsdg.group_name,  CHARINDEX('::', tsdg.group_name) + 3, LEN(tsdg.group_name))
				   END,
			       CASE WHEN CHARINDEX('::', tsdg.group_name) = 0 THEN NULL
						WHEN CHARINDEX('x->', tsdg.group_name) <> 0 AND CHARINDEX('::', tsdg.group_name) <> 0
							THEN SUBSTRING(SUBSTRING(tsdg.group_name, 0, CHARINDEX('::', tsdg.group_name)), CHARINDEX('x->', tsdg.group_name)+3, LEN(tsdg.group_name))
						ELSE SUBSTRING(tsdg.group_name,  0, CHARINDEX('::', tsdg.group_name))
					END,
					CASE WHEN CHARINDEX('x->', tsdg.group_name) = 0 THEN NULL
						ELSE SUBSTRING(tsdg.group_name, 0, CHARINDEX('x->', tsdg.group_name))
					END
			FROM   #temp_source_deal_groups tsdg
			INNER JOIN #temp_inserted_source_deal_header tsdh ON  tsdh.row_id = tsdg.row_id
			ORDER BY tsdg.id ASC
			
			SET @sql = 'UPDATE tsdg
						SET group_id = tsdg2.group_id
						FROM #temp_sdg tsdg
						INNER JOIN #temp_inserted_source_deal_header tsdh ON tsdh.source_deal_header_id = tsdg.source_deal_header_id
						INNER JOIN #temp_source_deal_groups tsdg2 
							ON tsdg2.row_id = tsdh.row_id
							AND tsdg2.id = tsdg.id
						'
			--PRINT(@sql)
			EXEC(@sql)

			-----------------Start of Update curve from location--------------------------
			/**Update curve_id from location only when the field is hidden in Grid*/
			DECLARE @take_index_from_location NCHAR(2) = 'y'
			SELECT @take_index_from_location = IIF(ISNULL(mftd.insert_required,'n') = 'n', 'y', 'n')
			FROM maintain_field_template_detail mftd
			INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
			WHERE mftd.field_template_id = @field_template_id
			AND mfd.farrms_field_id = 'curve_id'
			AND mfd.header_detail = 'd'

			IF @take_index_from_location = 'n'
			BEGIN
				SELECT @take_index_from_location = IIF(ISNULL(curve_id,0) = 0, 'y', 'n')
				FROM   deal_type_pricing_maping
				WHERE template_id             = @template_id
				AND   source_deal_type_id     = @deal_type_id
				AND   ((@pricing_type IS NULL AND pricing_type IS NULL) OR pricing_type = @pricing_type)
				AND	( ([commodity_id] IS NULL AND @commodity_id IS NULL) OR ISNULL([commodity_id],@commodity_id) = @commodity_id)
			END
			IF EXISTS (	SELECT 1
						FROM   adiha_default_codes_values
						WHERE  default_code_id = 56
							   AND var_value = 1) AND @take_index_from_location = 'y'			
			BEGIN
				UPDATE tsdd
				SET curve_id = COALESCE(gm_index.[index], sml.term_pricing_index, tsdd.curve_id)
				FROM #temp_source_deal_detail tsdd
				LEFT JOIN source_minor_location sml ON  tsdd.location_id = sml.source_minor_location_id
					AND tsdd.fixed_float_leg = 't' AND tsdd.physical_financial_flag = 'p'
				LEFT JOIN source_commodity sc ON sc.source_commodity_id = tsdd.detail_commodity_id
				OUTER APPLY (
					SELECT gmv.clm3_value [index]
					FROM generic_mapping_header gmh
					INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
					WHERE gmh.mapping_name = 'Commodity Market Curve Mapping'
					AND gmv.clm1_value = CAST(sml.source_minor_location_id AS NVARCHAR(20))
					AND gmv.clm2_value = CAST(sc.source_commodity_id AS NVARCHAR(20))
				) gm_index
			END
			-----------------End of Update curve from location--------------------------
			
			DECLARE @detail_select_columns NVARCHAR(MAX),
					@detail_hidden_columns NVARCHAR(MAX)
			SELECT @detail_select_columns = COALESCE(@detail_select_columns + ',', '') + 'tsdd.' + scsv.item  
			FROM dbo.SplitCommaSeperatedValues(@detail_insert_column_string) scsv 
			
			SELECT @detail_hidden_columns = COALESCE(@detail_hidden_columns + ',', '') + 'tsdd.' + scsv.item 
			FROM dbo.SplitCommaSeperatedValues(@detail_hidden_columns_string) scsv 
							
			SET @sql = 'INSERT INTO source_deal_detail (source_deal_header_id, leg, source_deal_group_id, ' + @detail_insert_column_string + ', ' + @detail_hidden_columns_string + ')
						OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id, INSERTED.leg, INSERTED.term_start, INSERTED.term_end INTO #temp_inserted_source_deal_detail (source_deal_header_id, source_deal_detail_id, leg, term_start, term_end)
						SELECT th.source_deal_header_id, tsdd.blotterleg, tg.source_deal_groups_id, ' + @detail_select_columns + ', ' + @detail_hidden_columns + '
						FROM #temp_source_deal_detail tsdd
						INNER JOIN #temp_inserted_source_deal_header th ON tsdd.row_id = th.row_id
						INNER JOIN #temp_sdg tg 
							ON tg.source_deal_header_id = th.source_deal_header_id
							AND tsdd.group_id = tg.group_id
						'
			--PRINT(@sql)
			EXEC(@sql)

			--Updated deal_volume with best available volume
			UPDATE sdd 
			SET deal_volume = COALESCE(sdd.actual_volume, sdd.schedule_volume, sdd.contractual_volume),
				volume_left = CASE WHEN volume_left IS NULL THEN 0 ELSE volume_left END
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #temp_inserted_source_deal_detail tsdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
			WHERE sdh.is_environmental = 'y' --sdt.deal_type_id IN ('RECs','Allowance','Emission Credits','RIN') 
			--AND sdd.buy_sell_flag = 'b'


			--Updated deal_volume with best available volume
			UPDATE sdd 
				SET deal_volume = ISNULL(sdd.deal_volume, sdd.contractual_volume)
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd 
				ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #temp_inserted_source_deal_detail tsdd 
				ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdh.internal_deal_subtype_value_id = 158 --'Physical - Oi land Soft'

			
			UPDATE tsdd 
			SET group_id = tsdg.group_id
			FROM #temp_inserted_source_deal_detail tsdd
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tsdd.source_deal_detail_id
			INNER JOIN #temp_sdg tsdg ON tsdg.source_deal_groups_id = sdd.source_deal_group_id
			
			UPDATE tsdd
			SET row_id = tsdh.row_id
			FROM #temp_inserted_source_deal_detail tsdd
			INNER JOIN #temp_inserted_source_deal_header tsdh ON tsdh.source_deal_header_id = tsdd.source_deal_header_id
			
			UPDATE sdd
			SET contract_expiration_date = CASE WHEN NULLIF(sdd.contract_expiration_date, '1900-01-01 00:00:00.000') IS NULL THEN sdd.term_end ELSE sdd.contract_expiration_date END
			FROM source_deal_detail sdd 
			INNER JOIN source_Deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #temp_inserted_source_deal_detail tsdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
			
			/* Removed because not needed in other version except kenkko and oil, for those version we need to discuss
			UPDATE sdd
			SET deal_volume = ISNULL(sdd.contractual_volume, sdd.deal_volume)
			FROM source_deal_detail sdd 
			INNER JOIN #temp_inserted_source_deal_detail tsdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
			*/
			
			UPDATE sdd
			SET multiplier = sdg.quantity
			FROM source_deal_detail sdd
			INNER JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
			INNER JOIN #temp_inserted_source_deal_detail tsdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE sdd.multiplier IS NULL AND NULLIF(sdg.quantity, 0) IS NOT NULL
			
			--Logic to update detail_commodity field if it is left blank
			UPDATE sdd
			SET sdd.detail_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #temp_inserted_source_deal_header tsdh ON sdh.source_deal_header_id = tsdh.source_deal_header_id

			IF @call_from = 'blotter' AND NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'pricing_type')
			BEGIN
				UPDATE sdh
				SET sdh.pricing_type = CASE
											WHEN sdh.physical_financial_flag = 'f' THEN CASE WHEN sdd.formula_curve_id IS NULL THEN 46704 ELSE 46705 END
											ELSE CASE WHEN sdd.formula_curve_id IS NULL THEN 46700 ELSE 46701 END
										END
				FROM source_deal_header sdh
				INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
				OUTER APPLY (
					SELECT MAX(sdd.formula_curve_id) formula_curve_id, source_deal_header_id 
					FROM source_deal_detail sdd 
					WHERE sdd.source_deal_header_id = sdh.source_deal_header_id 
					AND sdd.formula_curve_id IS NOT NULL
					GROUP BY sdd.source_deal_header_id
				) sdd
			END

			IF EXISTS(
				SELECT 1 
				FROM deal_default_value 
				WHERE deal_type_id = @deal_type_id 
				AND commodity = @commodity_id 
			)
			BEGIN
				UPDATE sdh
				SET internal_deal_type_value_id = ISNULL(ddv.internal_deal_type,sdh.internal_deal_type_value_id),
					internal_deal_subtype_value_id = ISNULL(ddv.internal_deal_sub_type, sdh.internal_deal_subtype_value_id),
					deal_sub_type_type_id = CASE WHEN @spot_or_term = 's' THEN ISNULL(sdh.deal_sub_type_type_id, st.sub_type_id) ELSE ISNULL(ddv.deal_sub_type_type_id, sdh.deal_sub_type_type_id) END
				FROM source_deal_header sdh
				INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
				OUTER APPLY (SELECT * FROM deal_default_value ddv WHERE ddv.deal_type_id = @deal_type_id 
				AND ((pricing_type IS NULL AND sdh.pricing_type IS NULL) OR pricing_type = sdh.pricing_type)
				AND commodity = @commodity_id
				AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(sdh.header_buy_sell_flag, 'y'))
				) ddv
				OUTER APPLY(
					SELECT source_deal_type_id [sub_type_id]
					FROM source_deal_type sdt
					WHERE sub_type = 'y'
						AND deal_type_id = 'Spot'
				) st

				IF @call_from = 'blotter' AND NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'profile_granularity')
				BEGIN
					UPDATE sdh
					SET profile_granularity = COALESCE(
																			ddv.volume_frequency, 
																			sdh.profile_granularity, 
																			sdht.profile_granularity, 
																			CASE 
																					WHEN sdd.deal_volume_frequency = 'x' THEN 987
																					WHEN sdd.deal_volume_frequency = 'y' THEN 989
																					WHEN sdd.deal_volume_frequency = 'a' THEN 993
																					WHEN sdd.deal_volume_frequency = 'd' THEN 981
																					WHEN sdd.deal_volume_frequency IN ('h', 't') THEN 982
																					WHEN sdd.deal_volume_frequency = 'm' THEN 980
																					ELSE 982 
																			END
																		)
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
					INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
					OUTER APPLY (SELECT * FROM deal_default_value ddv WHERE ddv.deal_type_id = @deal_type_id 
					AND ((pricing_type IS NULL AND sdh.pricing_type IS NULL) OR pricing_type = sdh.pricing_type)
					AND commodity = @commodity_id
					AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(sdh.header_buy_sell_flag, 'y'))
					) ddv 
				END
				
				IF NOT EXISTS(SELECT 1 FROM #temp_header_columns WHERE column_name = 'underlying_options')
				BEGIN					
					UPDATE sdh
					SET underlying_options = ddv.underlying_options
					FROM source_deal_header sdh
					INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
					OUTER APPLY (
						SELECT ddv.underlying_options
						FROM deal_default_value ddv
						WHERE deal_type_id = @deal_type_id 
						AND commodity = @commodity_id 
						AND ((pricing_type IS NULL AND sdh.pricing_type IS NULL) OR pricing_type = sdh.pricing_type)
						AND (buy_sell_flag IS NULL OR ISNULL(buy_sell_flag, 'x') = ISNULL(sdh.header_buy_sell_flag, 'y'))
					) ddv
				END

				SET @sql = 
					'UPDATE sdd SET pay_opposite = ISNULL(ddv.pay_opposite, sdd.pay_opposite) '
				
				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'cycle')
					SET @sql += ' ,cycle = ISNULL(ddv.cycle, sdd.cycle)'
				
				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'upstream_counterparty')
					SET @sql += ' ,upstream_counterparty = ISNULL(ddv.upstream_counterparty, sdd.upstream_counterparty)'
				
				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'upstream_contract')
					SET @sql += ' ,upstream_contract = ISNULL(ddv.upstream_contract, sdd.upstream_contract)'			
				
				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'fx_conversion_rate')
					SET @sql += ' ,fx_conversion_rate = ISNULL(ddv.fx_conversion_rate, sdd.fx_conversion_rate)'

				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'settlement_currency')
					SET @sql += ' ,settlement_currency = ISNULL(ddv.settlement_currency, sdd.settlement_currency)'
			
				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'settlement_date')
					SET @sql += ' ,settlement_date = ISNULL(ddv.settlement_date, sdd.settlement_date)'

				IF NOT EXISTS(SELECT 1 FROM #temp_detail_columns WHERE column_name = 'physical_financial_flag')
					SET @sql += ' ,physical_financial_flag = ISNULL(ddv.physical_financial_flag, sdd.physical_financial_flag)'

				SET @sql += ' 
						FROM source_deal_detail sdd 
						INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
						INNER JOIN #temp_inserted_source_deal_detail tsdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
						OUTER APPLY (
							SELECT TOP(1) * 
							FROM deal_default_value ddv WHERE ddv.deal_type_id = ' + CAST(@deal_type_id AS NVARCHAR(10)) + ' 
							AND ISNULL(ddv.pricing_type, -1) = ISNULL(sdh.pricing_type, -1)
							AND commodity = ' + CAST(@commodity_id AS NVARCHAR(10)) + ' 
							AND (ddv.buy_sell_flag IS NULL OR ISNULL(ddv.buy_sell_flag, ''x'') = ISNULL(sdd.buy_sell_flag, ''y''))
						) ddv
				'
				EXEC(@sql) 
			END
			
			IF @shaped_process_id IS NOT NULL
			BEGIN
				DECLARE @shaped_process_table NVARCHAR(400) = dbo.FNAProcessTableName('shaped_volume', @user_name, @shaped_process_id)
				
				IF OBJECT_ID(@shaped_process_table) IS NOT NULL
				BEGIN
					SET @sql = '
						UPDATE temp
						SET source_deal_detail_id = sdd.source_deal_detail_id
						FROM ' + @shaped_process_table + ' temp
						INNER JOIN (
							SELECT sdd.* 
							FROM #temp_inserted_source_deal_detail tsdd
							INNER JOIN source_deal_detail sdd ON tsdd.source_deal_detail_id = sdd.source_deal_detail_id
						) sdd
						ON sdd.leg = temp.leg
						AND temp.term_date BETWEEN sdd.term_start AND sdd.term_end	
					'	
					EXEC(@sql)			
					
					DECLARE @sdh_id INT
					SELECT @sdh_id = source_deal_header_id
					FROM #temp_inserted_source_deal_header					
					
					EXEC spa_update_shaped_volume  @flag='v',@source_deal_header_id=@sdh_id, @process_id=@shaped_process_id, @response = 'n'
				END
			END

			IF (@check_rec = 1)
			BEGIN
				IF OBJECT_ID(@certificate_process_table) IS NOT NULL
				BEGIN
						
						SET @sql =  'select c.source_certificate_number
								,t.source_deal_detail_id source_deal_header_id
								,c.certificate_number_from_int
								,c.certificate_number_to_int
								,c.gis_certificate_number_from
								,c.gis_certificate_number_to
								,c.gis_cert_date
								,c.state_value_id
								,c.tier_type
								,c.contract_expiration_date
								,c.year
								,c.certification_entity
								,c.insert_del
								into #temp_certificate
						 from ' + @certificate_process_table + ' c
						 cross join #temp_inserted_source_deal_detail t

						 delete from ' + @certificate_process_table + '

						 INSERT INTO ' + @certificate_process_table + '
						 select * from #temp_certificate 
					'	
					EXEC (@sql)								
					EXEC spa_gis_certificate_detail  @flag  = 'v', @certificate_process_id = @certificate_process_id
				END
			END

			DECLARE @udf_where NVARCHAR(500)
			        
			IF OBJECT_ID('tempdb..#template_udf_default') IS NOT NULL
				DROP TABLE #template_udf_default
				
			CREATE TABLE #template_udf_default (
				sno INT IDENTITY(1,1),
				column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
				column_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			)
			
			SET @udf_where = 'row_id=1'
			SET @table_name = REPLACE(@header_process_table, 'adiha_process.dbo.', '')
			
			INSERT #template_udf_default	
			EXEC spa_Transpose @table_name, @udf_where, 1
			
			DECLARE @fields NVARCHAR(MAX)
			SELECT @fields = COALESCE(@fields + ',', '') + '[' + column_name + ']'
			FROM #template_udf_default
			WHERE column_name LIKE '%UDF___%'
			
			IF @fields IS NOT NULL
			BEGIN
				SET @sql = 'INSERT INTO [dbo].[user_defined_deal_fields] (
								[source_deal_header_id],
								udf_template_id,
								[udf_value]
							)
							SELECT source_deal_header_id, uddft.udf_template_id udf_template_id, udf_value
							FROM (
								SELECT tsdh.source_deal_header_id, ' + @fields + '  
								FROM ' + @header_process_table + ' hpt
								INNER JOIN #temp_inserted_source_deal_header tsdh ON tsdh.row_id = hpt.row_id
							) a UNPIVOT (udf_value FOR udf_template_id IN (' + @fields + ')) unpvt
							INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_user_field_id = ABS(CAST(REPLACE(unpvt.udf_template_id, ''UDF___'', '''') AS INT))
							WHERE uddft.template_id = ' + CAST(@template_id AS NVARCHAR(20)) + '
							'
			
				EXEC(@sql)
			END
			
			--inserts hidden header udf
			INSERT INTO [dbo].[user_defined_deal_fields] (
				[source_deal_header_id],
				udf.udf_template_id,
				[udf_value]
			)
			SELECT tsdh.source_deal_header_id,
				   uddft.udf_template_id,
				   NULLIF(CAST(uddft.default_value AS NVARCHAR(500)), '') 
			FROM #temp_inserted_source_deal_header tsdh
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = @template_id
			INNER JOIN user_defined_fields_template udft ON uddft.field_name = udft.field_name
			LEFT JOIN user_defined_deal_fields uddf
				ON  uddft.udf_template_id = uddf.udf_template_id
				AND uddf.source_deal_header_id = tsdh.source_deal_header_id				       
			WHERE udft.udf_type = 'h' AND uddft.udf_template_id > 0
			AND uddf.udf_template_id IS NULL
			
			IF @header_cost_xml IS NOT NULL
			BEGIN
				DECLARE @header_costs_xml_table NVARCHAR(300)
				SET @header_costs_xml_table = dbo.FNAProcessTableName('header_costs_table', @user_name, @process_id)
				EXEC spa_parse_xml_file 'b', NULL, @header_cost_xml, @header_costs_xml_table
			
				SET @sql = 'UPDATE uddf
 							SET udf_value = hct.udf_value,
 								currency_id = NULLIF(hct.currency_id, ''''),
 								uom_id = NULLIF(hct.uom_id, ''''),
 								counterparty_id = NULLIF(hct.counterparty_id, ''''),
								seq_no = NULLIF(hct.seq_no, '''')
 							FROM #temp_inserted_source_deal_header tsdh
							INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = tsdh.source_deal_header_id	 							
 							INNER JOIN ' + @header_costs_xml_table + ' hct ON hct.cost_id = uddf.udf_template_id
 							'
 				--PRINT(@sql)
 				EXEC(@sql)

				SET @sql = '
					INSERT INTO user_defined_deal_fields (source_deal_header_id, udf_template_id, udf_value, currency_id, uom_id, counterparty_id, seq_no, contract_id, receive_pay, fixed_fx_rate)
					SELECT sdh.source_deal_header_id, hct.cost_id, NULLIF(hct.udf_value, ''''), NULLIF(hct.currency_id, ''''), NULLIF(hct.uom_id, ''''), NULLIF(hct.counterparty_id, ''''), NULLIF(hct.seq_no, '''') , NULLIF(hct.contract_id, ''''), NULLIF(hct.receive_pay, ''''),
					NULLIF(hct.fixed_fx_rate, '''')
					FROM ' + @header_costs_xml_table + ' hct
					OUTER APPLY (SELECT DISTINCT source_deal_header_id FROM #temp_inserted_source_deal_header) sdh 
					LEFT JOIN user_defined_deal_fields uddf
						ON hct.cost_id = uddf.udf_template_id
 						AND uddf.source_deal_header_id = sdh.source_deal_header_id
					WHERE hct.cost_id < 0 AND uddf.udf_deal_id IS NULL
					'
				EXEC(@sql)
			END
					       
			IF OBJECT_ID('tempdb..#template_udf_detail_default') IS NOT NULL
				DROP TABLE #template_udf_detail_default
				
			CREATE TABLE #template_udf_detail_default (
				sno INT IDENTITY(1,1),
				column_name NVARCHAR(300) COLLATE DATABASE_DEFAULT,
				column_value NVARCHAR(MAX) COLLATE DATABASE_DEFAULT
			)
			

			DECLARE @new_process_table NVARCHAR(200)
			SET @new_process_table = dbo.FNAProcessTableName('new_process_table', @user_name, dbo.FNAGetNewID())
			EXEC('SELECT TOP(1) * INTO ' + @new_process_table + ' FROM ' + @detail_xml_table + ' WHERE row_id = 1 AND blotterleg = 1')

			SET @udf_where = 'blotterleg=1 AND row_id=1'
			SET @table_name = REPLACE(@new_process_table, 'adiha_process.dbo.', '')
			INSERT #template_udf_detail_default	
			EXEC spa_Transpose @table_name, @udf_where, 1

			IF NOT EXISTS(SELECT 1 FROM #template_udf_detail_default) 
			BEGIN
				IF OBJECT_ID(@term_level_process_table) IS NOT NULL
				BEGIN
					IF OBJECT_ID(@new_process_table) IS NOT NULL
						EXEC('DROP TABLE ' + @new_process_table)
				
					EXEC('SELECT TOP(1) * INTO ' + @new_process_table + ' FROM ' + @term_level_process_table + ' WHERE row_id = 1 AND blotterleg = 1')
					SET @udf_where = 'blotterleg=1 AND row_id=1'
					SET @table_name = REPLACE(@new_process_table, 'adiha_process.dbo.', '')
					INSERT #template_udf_detail_default	
					EXEC spa_Transpose @table_name, @udf_where, 1
					
					IF OBJECT_ID(@new_process_table) IS NOT NULL
						EXEC('DROP TABLE ' + @new_process_table)
				END
			END
			ELSE
			BEGIN
				IF OBJECT_ID(@new_process_table) IS NOT NULL
					EXEC('DROP TABLE ' + @new_process_table)
			END			

			DECLARE @detail_fields NVARCHAR(MAX)
			SELECT @detail_fields = COALESCE(@detail_fields + ',', '') + column_name
			FROM ( 
					SELECT DISTINCT column_name		
			FROM #template_udf_detail_default temp
			WHERE column_name LIKE '%UDF___%'
				) a

			IF @detail_fields IS NOT NULL 
			BEGIN
				IF OBJECT_ID(@term_level_process_table) IS NOT NULL
				BEGIN
					SET @sql = 'INSERT INTO [dbo].user_defined_deal_detail_fields (
									source_deal_detail_id,
									udf_template_id,
									[udf_value]
								)
								SELECT source_deal_detail_id, uddft.udf_template_id, udf_value
								FROM (
									SELECT tsdd.source_deal_detail_id, ' + @detail_fields + '  
									FROM ' + @term_level_process_table + ' hpt
									INNER JOIN #temp_inserted_source_deal_detail tsdd 
										ON tsdd.row_id = hpt.row_id 
										AND tsdd.leg = hpt.blotterleg
										AND hpt.term_start = tsdd.term_start
								) a UNPIVOT (udf_value FOR udf_template_id IN (' + @detail_fields + ')) unpvt
								INNER JOIN user_defined_fields_template udft ON CAST(udft.udf_template_id AS NVARCHAR) = REPLACE(unpvt.udf_template_id, ''UDF___'', '''') AND udft.udf_type = ''d''
								INNER JOIN user_defined_deal_fields_template uddft 
									ON udft.field_name = uddft.field_name
									AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(200)) + '
								'
			
					--PRINT(@sql)
					EXEC (@sql)
				END
				SET @sql = 'INSERT INTO [dbo].user_defined_deal_detail_fields (
								source_deal_detail_id,
								udf_template_id,
								[udf_value]
							)
							SELECT source_deal_detail_id, uddft.udf_template_id, udf_value
							FROM (
								SELECT tsdd.source_deal_detail_id, ' + @detail_fields + '  
								FROM ' + @detail_xml_table + ' dxt
								INNER JOIN #temp_inserted_source_deal_detail tsdd 
									ON tsdd.row_id = dxt.row_id 
									AND tsdd.leg = dxt.blotterleg
									AND dxt.group_id = tsdd.group_id
							) a UNPIVOT (udf_value FOR udf_template_id IN (' + @detail_fields + ')) unpvt							
							INNER JOIN user_defined_fields_template udft ON CAST(udft.udf_template_id AS NVARCHAR) = REPLACE(unpvt.udf_template_id, ''UDF___'', '''') AND udft.udf_type = ''d''
							INNER JOIN user_defined_deal_fields_template uddft 
								ON udft.field_name = uddft.field_name
								AND uddft.template_id = ' + CAST(@template_id AS NVARCHAR(200)) + '
							'
				--PRINT (@sql)
				EXEC(@sql)
			END
			
			IF @formula_process_id IS NOT NULL
			BEGIN
				DECLARE @detail_formula_process_table NVARCHAR(300) = dbo.FNAProcessTableName('detail_formula_process_table', @user_name, @formula_process_id)
				
				IF OBJECT_ID(@detail_formula_process_table) IS NOT NULL
				BEGIN					
					SET @sql = '
						INSERT INTO deal_detail_formula_udf (source_deal_detail_id, udf_template_id, udf_value)
						SELECT tsdd.source_deal_detail_id, t1.udf_template_id, t1.udf_value 
						FROM ' + @detail_formula_process_table + ' t1
						INNER JOIN #temp_inserted_source_deal_detail tsdd 
							ON tsdd.row_id = t1.row_id 
							AND tsdd.leg = t1.leg
							AND tsdd.group_id = t1.source_deal_group_id
					
					'
					EXEC(@sql)
					EXEC('DROP TABLE ' + @detail_formula_process_table)
				END				
			END	
			
			-- update position uom from price curve, if it is blank in deal.
			UPDATE sdd
			SET position_uom = COALESCE(spcd.display_uom_id, spcd.uom_id)
			FROM source_deal_detail sdd 
			INNER JOIN #temp_inserted_source_deal_header th ON sdd.source_deal_header_id = th.source_deal_header_id
			INNER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
			WHERE sdd.position_uom IS NULL

			IF @call_from = 'blotter'
			BEGIN
				UPDATE uddf
				SET udf_template_id = uddft2.udf_template_id
				FROM user_defined_deal_fields uddf
				INNER JOIN #temp_inserted_source_deal_header th ON uddf.source_deal_header_id = th.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = @template_id
				INNER JOIN user_defined_deal_fields_template_main uddft1 ON uddf.udf_template_id = uddft1.udf_template_id
				INNER JOIN user_defined_deal_fields_template_main uddft2 
					ON uddft1.field_name = uddft2.field_name
					AND uddft2.template_id = sdht.update_template_id
				WHERE sdht.update_template_id IS NOT NULL AND uddft2.template_id IS NOT NULL

				UPDATE uddf
				SET udf_template_id = uddft2.udf_template_id
				FROM user_defined_deal_detail_fields uddf
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = uddf.source_deal_detail_id
				INNER JOIN #temp_inserted_source_deal_header th ON sdd.source_deal_header_id = th.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = @template_id
				INNER JOIN user_defined_deal_fields_template_main uddft1 ON uddf.udf_template_id = uddft1.udf_template_id
				INNER JOIN user_defined_deal_fields_template_main uddft2 
					ON uddft1.field_name = uddft2.field_name
					AND uddft2.template_id = sdht.update_template_id
				WHERE sdht.update_template_id IS NOT NULL AND uddft2.template_id IS NOT NULL
			END
				   
			-- update audit info
			UPDATE sdh
			SET create_ts = GETDATE(),
				create_user = dbo.FNADBUser(),
				update_user = NULL,
				update_ts = NULL,
				template_id = ISNULL(sdht.update_template_id, sdht.template_id),
				pricing_type = ISNULL(sdh.pricing_type, @pricing_type)
			FROM source_deal_header sdh
			INNER JOIN source_deal_header_template sdht ON sdh.template_id = sdht.template_id
			INNER JOIN #temp_inserted_source_deal_header th ON sdh.source_deal_header_id = th.source_deal_header_id
			
			UPDATE sdd
			SET create_ts = GETDATE(),
				create_user = dbo.FNADBUser(),
				update_user = NULL,
				update_ts = NULL
			FROM source_deal_detail sdd
			INNER JOIN #temp_inserted_source_deal_header th ON sdd.source_deal_header_id = th.source_deal_header_id
						
			COMMIT TRAN 
			
			DECLARE @recommendation NVARCHAR(10)
			SET @recommendation = ''
			
			IF @call_from <> 'blotter'
			BEGIN
				SELECT @recommendation = source_deal_header_id FROM #temp_inserted_source_deal_header
			END
			
			IF ISNULL(@call_from_delivery_path, '') <> 'y' 
			BEGIN
				EXEC spa_ErrorHandler 0
					, 'spa_insert_blotter_deal'
					, 'spa_insert_blotter_deal'
					, 'Success' 
					, 'Successfully saved data.'
					, @recommendation
			END
			else if ISNULL(@call_from_delivery_path, '') = 'y' 
			begin
				declare @capacity_deal_table NVARCHAR(300) = dbo.FNAProcessTableName('capacity_deal_table', @user_name, @process_id)

				IF OBJECT_ID(@capacity_deal_table) IS NOT NULL
				BEGIN
					EXEC('DROP TABLE ' + @capacity_deal_table)
				END
				
				EXEC ('CREATE TABLE ' + @capacity_deal_table + '(source_deal_header_id INT)')
				
				exec('INSERT INTO ' + @capacity_deal_table + '(source_deal_header_id) select source_deal_header_id FROM #temp_inserted_source_deal_header')
			end

			IF @call_from = 'scheduler'
			BEGIN
				SELECT @return_output = COALESCE(@return_output + ',', '') +  CAST(source_deal_header_id AS NVARCHAR(10))
				FROM   #temp_inserted_source_deal_header
			END
			ELSE
			BEGIN				
			EXEC spa_ErrorHandler 0
				, 'spa_insert_blotter_deal'
				, 'spa_insert_blotter_deal'
				, 'Success' 
				, 'Successfully saved data.'
				, @recommendation
			END
				
			DECLARE @after_insert_process_table NVARCHAR(300), @job_name NVARCHAR(200), @job_process_id NVARCHAR(200) = dbo.FNAGETNEWID()
			SET @after_insert_process_table = dbo.FNAProcessTableName('after_insert_process_table', @user_name, @job_process_id)
			
			--PRINT @after_insert_process_table
			IF OBJECT_ID(@after_insert_process_table) IS NOT NULL
			BEGIN
				EXEC('DROP TABLE ' + @after_insert_process_table)
			END
				
			EXEC ('
				CREATE TABLE ' + @after_insert_process_table + ' (
					source_deal_header_id INT,
					detail_process_table NVARCHAR(200) COLLATE DATABASE_DEFAULT,
					complex_price_process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
					provisional_price_detail_process_id NVARCHAR(200) COLLATE DATABASE_DEFAULT,
					is_gas_daily NCHAR(1)  COLLATE DATABASE_DEFAULT
				)
			')

			SET @sql = 'INSERT INTO ' + @after_insert_process_table + '(source_deal_header_id, detail_process_table, complex_price_process_id, provisional_price_detail_process_id, is_gas_daily) 
						SELECT source_deal_header_id, 
							   ''' + @detail_xml_table + ''', 
							   ' + ISNULL('''' + NULLIF(@deal_price_data_process_id, '') + '''', 'NULL') + ',
							   ' + ISNULL('''' + NULLIF(@deal_provisional_price_data_process_id, '') + '''', 'NULL') + ',
							   ' + ISNULL(''''+ @is_gas_daily + '''', 'NULL') + '
						FROM #temp_inserted_source_deal_header'
			EXEC(@sql)
			
			SET @sql = 'spa_deal_insert_update_jobs ''i'', ''' + @after_insert_process_table + ''''
			--PRINT @sql
			EXEC(@sql)
			
			/** INSERT transport deal **/
			DECLARE @source_deal_header_id_rec INT 

			SELECT @source_deal_header_id_rec = source_deal_header_id 
			FROM #temp_inserted_source_deal_header

			IF EXISTS(
				SELECT 1  
				FROM source_deal_header sdh
					INNER JOIN user_defined_deal_fields uddf
						ON sdh.source_deal_header_id = uddf.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft
						ON uddft.template_id = sdh.template_id
						AND uddft.udf_template_id = uddf.udf_template_id
					INNER JOIN user_defined_fields_template udft
						ON udft.field_id = uddft.field_id
				WHERE udft.field_label = 'Delivery Path'
					AND sdh.source_deal_header_id = @source_deal_header_id_rec
					AND sdh.header_buy_sell_flag = 'b'
			)
			BEGIN
				DECLARE @sub_book_id INT 
				DECLARE @xml_opt_text NVARCHAR(MAX)
				DECLARE @initial_rec_vol NUMERIC(38, 17)

				IF OBJECT_ID('tempdb..#temp_trans') IS NOT NULL
					DROP TABLE #temp_trans

				CREATE TABLE #temp_trans (
					row_id INT,
					path_id INT,
					contract INT,
					sub_book_id INT,
					single_path_id INT,
					term_start DATE,
					rec_vol NUMERIC(38, 17),
					del_vol NUMERIC(38, 17),
					loss_factor NUMERIC(38, 17)
				)
	
				SELECT 
					@xml_opt_text = '<Root rec_deals="' + CAST(@source_deal_header_id_rec AS NVARCHAR(10))  + 
										'" del_deals=""'  + 
										'  rec_location="' + CAST(dp.from_location AS NVARCHAR(10)) + 
										'" del_location=""' + 
										' flow_date_from="' + dbo.FNAGetSQLStandardDate(sdh.entire_term_start)  + 
										'" flow_date_to="' + dbo.FNAGetSQLStandardDate(sdh.entire_term_end) + 
										'" uom="' + CAST(sdd.deal_volume_uom_id AS NVARCHAR(10)) + '" >'
				FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
						AND sdh.entire_term_start = sdd.term_start		
					INNER JOIN user_defined_deal_fields_template uddft
						ON uddft.template_id = sdh.template_id
					INNER JOIN user_defined_fields_template udft
						ON udft.field_id = uddft.field_id
					INNER JOIN user_defined_deal_fields uddf
						ON uddf.source_deal_header_id = sdh.source_deal_header_id
						AND uddf.udf_template_id = uddft.udf_template_id
					INNER JOIN delivery_path dp 
						ON CAST(dp.path_id AS NVARCHAR(100)) = CAST(uddf.udf_value AS NVARCHAR(100))
						and dp.from_location = sdd.location_id
				WHERE sdh.source_deal_header_id = @source_deal_header_id_rec
					AND udft.Field_label = 'Delivery Path'

				INSERT INTO #temp_trans (
					row_id,
					path_id,					
					contract,				
					sub_book_id,			
					single_path_id,			
					term_start,				
					rec_vol,					
					del_vol,					
					loss_factor	
				)
				SELECT 
					row_number() over( order by dbo.FNAGetSQLStandardDate(IIF(sdh.term_frequency = 'd', sdd.term_start, tb.term_start) ) , CAST(ISNULL(dp_sub.path_id, dp.path_id) AS NVARCHAR(10))),
					CAST(dp.path_id AS NVARCHAR(10)),
					CAST(sdh.contract_id AS NVARCHAR(10)),
					CAST(gmv.clm2_value AS NVARCHAR(10)),
					CAST(ISNULL(dp_sub.path_id, dp.path_id) AS NVARCHAR(10)),
					dbo.FNAGetSQLStandardDate(IIF(sdh.term_frequency = 'd', sdd.term_start, tb.term_start) ),
					CAST(sdd.deal_volume AS NVARCHAR(50)),
					sdd.deal_volume,
					CAST(COALESCE(pls_sub.loss_factor, pls.loss_factor, 0) AS NVARCHAR(50))
				FROM user_defined_deal_fields uddf					
					INNER JOIN user_defined_deal_fields_template uddft
						ON uddft.udf_template_id = uddf.udf_template_id
					INNER JOIN user_defined_fields_template udft
						ON udft.field_id = uddft.field_id
					INNER JOIN delivery_path dp 
						ON CAST(dp.path_id  AS NVARCHAR(100)) = CAST(uddf.udf_value AS NVARCHAR(100))
					LEFT JOIN delivery_path_detail dpd
						ON dpd.path_id = dp.path_id
					LEFT JOIN delivery_path dp_sub
						ON dp_sub.path_id = dpd.path_name
					INNER JOIN generic_mapping_values gmv
						ON CAST(gmv.clm1_value AS NVARCHAR(100)) = CAST(ISNULL(dp_sub.counterparty, dp.counterparty) AS NVARCHAR(100))
					INNER JOIN generic_mapping_header gmh
						ON gmv.mapping_table_id = gmh.mapping_table_id	
					INNER JOIN source_deal_header sdh
						ON sdh.source_deal_header_id = uddf.source_deal_header_id
					INNER JOIN source_deal_detail sdd
						ON sdh.source_deal_header_id = sdd.source_deal_header_id
					LEFT JOIN path_loss_shrinkage pls
						ON pls.path_id = dp.path_id
					LEFT JOIN path_loss_shrinkage pls_sub
						ON pls_sub.path_id = dp_sub.path_id
					CROSS APPLY (
						SELECT * 
						FROM [dbo].[FNATermBreakdown](
							--IIF(sdh.term_frequency = 'd', 'm', 'd') --need to discuss this line logic, seems to be carried from g2x
							'm' --breakdown monthly done since, max recursion error when template is monthly
							, sdh.entire_term_start
							, IIF(sdh.term_frequency = 'd', sdh.entire_term_start,  sdh.entire_term_end)
						)
					) tb		
				WHERE gmh.mapping_name = 'Flow Optimization Mapping'
					AND uddf.source_deal_header_id = @source_deal_header_id_rec
					AND udft.Field_label = 'Delivery Path'
				ORDER BY dbo.FNAGetSQLStandardDate(IIF(sdh.term_frequency = 'd', sdd.term_start, tb.term_start)) 
						, CAST(ISNULL(dp_sub.path_id, dp.path_id) AS NVARCHAR(10))

				SELECT @initial_rec_vol = rec_vol 
				FROM #temp_trans 
				WHERE row_id = 1	

				;WITH cte_trans AS 
					( 
						--initialization 
						SELECT 
							row_id,
							path_id,					
							contract,				
							sub_book_id,			
							single_path_id,			
							term_start,				
							CAST(rec_vol AS NUMERIC(38, 17)) rec_vol,					
							rec_vol * (1 - loss_factor) del_vol,					
							loss_factor	
						FROM #temp_trans
						WHERE  row_id = 1
						UNION ALL 
						--recursive execution 
						SELECT 
							tt.row_id,
							tt.path_id,					
							tt.contract,				
							tt.sub_book_id,			
							tt.single_path_id,			
							tt.term_start,				
							IIF(tt.term_start <> ct.term_start, @initial_rec_vol, CAST(ct.del_vol AS NUMERIC(38, 17))) ,					
							IIF(tt.term_start <> ct.term_start, @initial_rec_vol, CAST(ct.del_vol AS NUMERIC(38, 17))) * (1 - tt.loss_factor) del_vol,					
							tt.loss_factor	
						FROM #temp_trans tt
							INNER JOIN cte_trans ct  
								ON  tt.row_id -1 = ct.row_id
					) 

				SELECT 		
					@xml_opt_text +=
							' <PSRecordset path_id="' + CAST(path_id AS NVARCHAR(10)) + 
							'" contract="' +  CAST(contract AS NVARCHAR(10)) + 
							'" sub_book_id="' + CAST(sub_book_id AS NVARCHAR(10)) + 
							'" single_path_id="' + CAST(single_path_id AS NVARCHAR(10)) +
							'" term_start="' + CAST(term_start AS NVARCHAR(100)) +  
							'" rec_vol="' + CAST(rec_vol AS NVARCHAR(50)) + 
							'" del_vol="'+ CAST(del_vol AS NVARCHAR(50)) + 
							'" loss_factor="' + CAST(loss_factor AS NVARCHAR(50)) + 
							'" />' 
				FROM cte_trans
				OPTION (MAXRECURSION 5000)

				SET @xml_opt_text += ' </Root>'

				--EXEC spa_flow_optimization_match 'm', @xml_opt_text 
			END

--------Transfer Deal	
	--DECLARE @source_deal_header_id NVARCHAR (100)
	--DECLARE @val_deal_date DATETIME

	--SELECT @source_deal_header_id = sdh.source_deal_header_id,
	--	   @val_deal_date = sdh.deal_date 
	--FROM source_deal_header sdh 
	--	INNER JOIN #temp_inserted_source_deal_header sdh_temp ON sdh_temp.source_deal_header_id = sdh.source_deal_header_id
	----SELECT @source_deal_header_id

	--IF EXISTS(SELECT 1 FROM source_deal_header sdh
	--		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id AND sdh.source_deal_header_id = @source_deal_header_id
	--		INNER JOIN deal_transfer_mapping dtm 
	--			ON dtm.counterparty_id_from = sdh.counterparty_id 
	--			AND dtm.source_book_mapping_id_from = sdh.sub_book 
	--			AND (dtm.counterparty_id_to = sdh.internal_counterparty or dtm.counterparty_id_to is null)
	--			AND (dtm.contract_id_from = sdh.contract_id or dtm.contract_id_from is null)
	--			AND (dtm.trader_id_from = sdh.trader_id or dtm.trader_id_from is null)
	--			AND (dtm.source_deal_type_id = sdh.source_deal_type_id or dtm.source_deal_type_id is null)
	--			AND (dtm.template_id = sdh.template_id or dtm.template_id is null))

	--BEGIN 	
	--	DECLARE @val_source_deal_header_id NVARCHAR(100)
	--	DECLARE @val_transfer_without_offset NVARCHAR(100)
	--	DECLARE @val_transfer_only_offset NVARCHAR(100)
	--	DECLARE @val_book_map_id NVARCHAR(100)
	--	DECLARE @val_book_map_id_offset NVARCHAR(100)
	--	DECLARE @val_contract_to NVARCHAR(100)
	--	DECLARE @val_trader_to NVARCHAR(100)
	--	DECLARE @deal_transfer_mapping_id NVARCHAR(100)
	--	DECLARE @val_fixed NVARCHAR(100)
	--	DECLARE @val_xm NVARCHAR(max)
	--	DECLARE @val_transfer_type NVARCHAR(100)
	--	DECLARE	@val_counterparty_to NVARCHAR(100)
	--	DECLARE @val_fixed_adder NVARCHAR(100)
	--	DECLARE @val_location_id NVARCHAR(100)
	--	DECLARE	@val_total_volume NVARCHAR(max)
	--	DECLARE @val_index_adder NVARCHAR(100)
	--	DECLARE @transfer_type NVARCHAR(100)
	--	DECLARE @val_counterparty_id NVARCHAR(100)
	--	DECLARE @val_contract_id NVARCHAR(100)
	--	DECLARE @counterparty_id_to NVARCHAR(100)
	--	DECLARE @template_id_to NVARCHAR(100)

	--	SELECT @deal_transfer_mapping_id = max(dtm.deal_transfer_mapping_id) FROM source_deal_header sdh
	--		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id AND sdh.source_deal_header_id = @source_deal_header_id
	--		INNER JOIN deal_transfer_mapping dtm 
	--			ON dtm.counterparty_id_from = sdh.counterparty_id 
	--			AND dtm.source_book_mapping_id_from = sdh.sub_book 
	--			AND (dtm.counterparty_id_to = sdh.internal_counterparty or dtm.counterparty_id_to is null)
	--			AND (dtm.contract_id_from = sdh.contract_id or dtm.contract_id_from is null)
	--			AND (dtm.trader_id_from = sdh.trader_id or dtm.trader_id_from is null)
	--			AND (dtm.source_deal_type_id = sdh.source_deal_type_id or dtm.source_deal_type_id is null)
	--			AND (dtm.template_id = sdh.template_id or dtm.template_id is null)

	--	-- To Criteria
	--	SELECT @val_book_map_id = dtmd.transfer_sub_book,
	--		   @val_trader_to = dtmd.transfer_trader_id,
	--		   @val_fixed = dtmd.fixed_price,
	--		   --@val_transfer_without_offset = CASE WHEN dtm.offset = 'n' THEN 1 ELSE 0 END,
	--		   --@val_transfer_only_offset = CASE WHEN dtm.[transfer] = 'n' THEN 1 ELSE 0 END,
	--		   @transfer_type = dtm.[transfer],
	--		   @val_transfer_type = CASE dtmd.transfer_type
	--									WHEN 1 THEN 'd' 
	--									WHEN 2 THEN 'm' 
	--									WHEN 3 THEN 'x' 
	--								END,
	--			@val_fixed_adder = NULLIF(dtmd.fixed_adder, ''),
	--			@val_index_adder = NULLIF(dtmd.index_adder, ''),
	--			@val_counterparty_id = dtmd.transfer_counterparty_id,
	--			@val_contract_id =  dtmd.transfer_contract_id,
	--			@counterparty_id_to = dtm.counterparty_id_to,
	--			@template_id_to = dtmd.transfer_template_id
	--	FROM deal_transfer_mapping dtm 
	--	INNER JOIN deal_transfer_mapping_detail dtmd
	--		ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
	--	WHERE dtm.deal_transfer_mapping_id = @deal_transfer_mapping_id	
		
	--	-- Original Deal
	--	SELECT	@val_source_deal_header_id = sdh.source_deal_header_id, 
	--			@val_book_map_id_offset = sdh.sub_book, 
	--			@val_contract_to = sdh.contract_id,
	--			@val_counterparty_to = sdh.counterparty_id,
	--			@val_location_id = sdd.location_id,
	--			@val_total_volume = sdd.total_volume

	--	FROM source_deal_header sdh
	--	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	--	WHERE sdh.source_deal_header_id = @source_deal_header_id
	----select total_volume,* from source_deal_detail sdd where sdd.source_deal_header_id = @source_deal_header_id
	--	IF @val_transfer_type = 'd' -- Original price
	--	BEGIN
	--		SET @val_fixed = NULL
	--		SET @val_index_adder = NULL
	--	END

	--	IF @val_transfer_type = 'm' -- Market Price
	--	BEGIN
	--		SET @val_fixed = NULL
	--	END

	--	IF @val_transfer_type = 'x' -- Fixed price
	--	BEGIN
	--		SET @val_index_adder = NULL
	--	END

	--	IF @transfer_type = 'o' -- offset only
	--	BEGIN
	--		SET @val_transfer_without_offset = '0'
	--		SET @val_transfer_only_offset = '1'
	--	END
	--	ELSE IF @transfer_type = 'b' -- offset with xfer
	--	BEGIN
	--		SET @val_transfer_without_offset = '0'
	--		SET @val_transfer_only_offset = '0'
	--	END
	--	ELSE IF @transfer_type = 'x' -- xfer only
	--	BEGIN
	--		SET @val_transfer_without_offset = '1'
	--		SET @val_transfer_only_offset = '0'
	--		SET @val_book_map_id_offset = @val_book_map_id
	--	END


	--	SELECT @val_xm = '<GridXML>'
	--		SELECT @val_xm += STUFF((SELECT  '<GridRow
	--										   counterparty_id = ''' + ISNULL(CAST(dtmd.counterparty_id AS NVARCHAR(20)), '') + '''
	--										   contract_id = ''' + ISNULL(CAST(dtmd.contract_id AS NVARCHAR(20)), '') + '''
	--										   trader_id = ''' + ISNULL(CAST(dtmd.trader_id AS NVARCHAR(20)), '') + '''
	--										   sub_book = ''' + ISNULL(CAST(dtmd.sub_book AS NVARCHAR(20)), '') + '''
	--										   location_id = ''' + ISNULL(CAST(dtmd.location_id AS NVARCHAR(20)), '') + '''
	--										   transfer_volume = ''' + ISNULL(NULLIF(CAST(dtmd.transfer_volume AS NVARCHAR(20)), ''), '0') + '''
	--										   volume_per = ''' + ISNULL(CAST(dtmd.volume_per AS NVARCHAR(100)),'') + '''
	--										   pricing_options = ''' + ISNULL(CAST(dtmd.pricing_options AS NVARCHAR(20)), '') + '''
	--										   fixed_price = ''' + ISNULL(CAST(dtmd.fixed_price AS NVARCHAR(20)), '') + '''
	--										   transfer_date = ''' + ISNULL(CAST(dbo.[FNAGetSQLStandardDate](dtmd.transfer_date) AS NVARCHAR(20)), '') + '''
	--										   transfer_counterparty_id = ''' + ISNULL(CAST(dtmd.transfer_counterparty_id AS NVARCHAR(20)), '') + '''
	--										   transfer_contract_id = ''' + ISNULL(CAST(dtmd.transfer_contract_id AS NVARCHAR(20)), '') + '''
	--										   transfer_trader_id = ''' + ISNULL(CAST(dtmd.transfer_trader_id AS NVARCHAR(20)), '') + '''
	--										   transfer_sub_book = ''' + ISNULL(CAST(dtmd.transfer_sub_book AS NVARCHAR(20)), '') + '''
	--										  ></GridRow>'
	--								FROM deal_transfer_mapping dtm
	--								INNER JOIN deal_transfer_mapping_detail dtmd
	--									ON dtmd.deal_transfer_mapping_id = dtm.deal_transfer_mapping_id
	--								WHERE dtm.deal_transfer_mapping_id = @deal_transfer_mapping_id
	--												For Xml Path(''), type
	--								).value('.', 'nNVARCHAR(max)')
	--								, 1, 1, '') 
	--		SELECT @val_xm += '</GridXML>'

	--	EXEC spa_deal_transfer @flag='t',
	--			@source_deal_header_id=@source_deal_header_id,
	--			@transfer_without_offset=@val_transfer_without_offset,
	--			@transfer_only_offset=@val_transfer_only_offset,
	--			@xml= @val_xm,
	--			@price_adder= @val_fixed_adder,
	--			@formula_curve_id = @val_index_adder
				
	--END

	--TODO: Verify if we can remove duplicate code (above) by just calling following SP, which resolved the transfer criteria
	--run cursor 
	--
	--select * FROM #temp_inserted_source_deal_header
	DECLARE @source_deal_header_id NVARCHAR(MAX)
	SELECT @source_deal_header_id = ISNULL(@source_deal_header_id + ',', '') + CAST(source_deal_header_id AS NVARCHAR(10))
	FROM #temp_inserted_source_deal_header

	EXEC spa_auto_transfer @source_deal_header_id=@source_deal_header_id
------------------------------------------------------------------------------------------------------------------------------


	END TRY
	BEGIN CATCH
		DECLARE @desc NVARCHAR(500)
		DECLARE @err_no INT
 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SELECT @err_no = ERROR_NUMBER()
 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
  
		EXEC spa_ErrorHandler @err_no
		   , 'spa_insert_blotter_deal'
		   , 'spa_insert_blotter_deal'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
	
END
-- Clean up Process Tables Used after the scope is completed when Debug Mode is Off.
DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
BEGIN
	EXEC spa_clear_all_temp_table NULL, @process_id
END

GO