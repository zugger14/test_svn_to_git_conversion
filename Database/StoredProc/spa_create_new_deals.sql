IF OBJECT_ID(N'[dbo].[spa_create_new_deals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_create_new_deals]
GO

/**
	SP used for transfering deal. Create for baseline and new gen import rule

	Parameters:
	@temp_table_name : Name of process table creating while running import rule
	@flag : Flag Operation
			'b' -- Modify data of process table
			'a' -- After trigger call for Baseline import / Model Deal Transfer import.
			't' -- Trasfer deals.
	@deal_type: Type of deal
				
*/

CREATE procedure [dbo].[spa_create_new_deals]  
	@temp_table_name NVARCHAR(200),
	@flag CHAR(1),
	@deal_type CHAR(1) = NULL  -- baseline, newgen
AS 

-- ===============================================================================================================
-- Author: arai@pioneersolutionsglobal.com
-- Create date: 2019-05-30
-- Description: Create deals with user import data.
-- ===============================================================================================================

--EXEC [spa_create_new_deals]  'adiha_process.dbo.temp_import_data_table_d_D9FB4BE3_48DD_4B25_8672_693324F59857', 'b'

SET NOCOUNT ON
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @tempTable NVARCHAR(100)
	DECLARE @sqlStmt NVARCHAR(MAX)
	DECLARE @column_list NVARCHAR(MAX)
	DECLARE @rule_id INT, @user_login_id NVARCHAR(100), @process_id NVARCHAR(200)
	DECLARE @temp_table_name_transfer NVARCHAR(200)

	IF OBJECT_ID(@tempTable) IS NOT NULL
	EXEC('DROP TABLE ' + @tempTable)

	SET @user_login_id = dbo.fnadbuser() 
	SET @process_id = REPLACE(newid(), '-', '_') 

	SET @tempTable = dbo.FNAProcessTableName('deal_invoice', @user_login_id, @process_id)

	IF @flag = 'b'
	BEGIN
		/* 1. For post trigger : Shapped volume import */
		--exec('select * from ' + @temp_table_name)

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''type'') IS NULL
			BEGIN
				ALTER TABLE ' + @temp_table_name + ' 
				ADD [type] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
			END
		')

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''template'') IS NULL
			BEGIN
				ALTER TABLE ' + @temp_table_name + ' 
				ADD [template] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
			END
		')

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''buy sell'') IS NULL
			BEGIN
				ALTER TABLE ' + @temp_table_name + ' 
				ADD [buy sell] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
			END
		')

		/************** CHECK MISSING column *****************/

		SELECT @process_id = SUBSTRING(@temp_table_name, CHARINDEX('table_d_', @temp_table_name) + LEN('table_d_'), LEN(@temp_table_name))

		IF OBJECT_ID('tempdb..#import_status') IS NOT NULL	
			DROP TABLE #import_status
		
		CREATE TABLE #import_status (
 			process_id        NVARCHAR(100) COLLATE DATABASE_DEFAULT,
 			error_code        NVARCHAR(50) COLLATE DATABASE_DEFAULT,
 			[description]     NVARCHAR(1000) COLLATE DATABASE_DEFAULT
		)

		--EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''Price Adder'') IS NULL
		--	BEGIN
		--		INSERT INTO #import_status 
		--		SELECT '''+ @process_id +''', ''column_missing'', ''Error: Price Adder column missing.''
		--	END
		--')

		IF OBJECT_ID('tempdb..#validate_column') IS NOT NULL	
			DROP TABLE #validate_column

		CREATE TABLE #validate_column (
 			[name]	NVARCHAR(300) COLLATE DATABASE_DEFAULT
		)

		INSERT INTO #validate_column
		SELECT 'buy sell' UNION ALL
		SELECT 'Contract' UNION ALL
		SELECT 'Counterparty' UNION ALL
		SELECT 'Currency' UNION ALL
		SELECT 'Deal Date' UNION ALL
		SELECT 'Deal Ref ID' UNION ALL
		SELECT 'hour' UNION ALL
		SELECT 'import_file_name' UNION ALL
		SELECT 'Is dst' UNION ALL
		SELECT 'leg' UNION ALL
		SELECT 'Location ID' UNION ALL
		SELECT 'Market Index' UNION ALL
		SELECT 'Original Book' UNION ALL
		SELECT 'price' UNION ALL
		SELECT 'Price Index' UNION ALL
		SELECT 'template' UNION ALL
		SELECT 'term date' UNION ALL
		SELECT 'TimeZone' UNION ALL
		SELECT 'Transfer Book' UNION ALL
		SELECT 'type' UNION ALL
		SELECT 'volume' UNION ALL
		SELECT 'Price Adder' UNION ALL
		SELECT 'Price Multiplier'

		--SELECT vc.* FROM #validate_column vc
		--LEFT JOIN ADIHA_PROCESS.INFORMATION_SCHEMA.COLUMNS a
		--	ON a.column_name = vc.name
		--WHERE TABLE_NAME = N'temp_import_data_table_d_D14728FE_D385_4456_8E47_092E2398E3271'
		--AND a.column_name IS NULL

		SET @sql = '
			INSERT INTO #import_status
			SELECT '''+ @process_id +''', ''column_missing'', ''Column Error: '' + vc.[name] + '' column missing '' FROM #validate_column vc
				LEFT JOIN (
					SELECT * FROM ADIHA_PROCESS.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK)
					WHERE TABLE_NAME =  N''' + REPLACE(@temp_table_name, 'adiha_process.dbo.', '') + '''
				) as b
			ON b.column_name = vc.name
			WHERE b.table_name IS NULL
		'
		EXEC(@sql);

		INSERT INTO source_system_data_import_status_detail (
			process_id, 
			[source], 
			[type], 
			[description], 
			type_error
		)
		SELECT 
			process_id,
			'ixp_source_deal_template',
			'Data Error',
			[description], 
			'Err_Cus_Col_Val'
		FROM #import_status

		IF EXISTS (SELECT 1 FROM #import_status)
		BEGIN
			SET @sql = 'DELETE tmp 
				FROM ' + @temp_table_name + ' tmp'
			EXEC(@sql);

			

			INSERT INTO source_system_data_import_status (
				[process_id], 
				[code], 
				[module], 
				[source], 
				[type],
				[description],
				[recommendation],
				[rules_name]
			)
			SELECT 
				@process_id,
				'Error',
				'Import Data',
				'ixp_source_deal_template', 
				'Column Mismatch',
				CAST(COUNT(*) AS VARCHAR) + ' mandatory columns are missing in the file.',
				'Please correct the file and reimport.',
				'Model Deal Transfer'
			FROM #import_status

			RETURN
		END

		/************** End *************/

		EXEC ('UPDATE a SET a.type = CASE WHEN ''' + @deal_type + ''' = ''b'' THEN ''Baseline'' WHEN ''' + @deal_type + ''' = ''n'' THEN ''New Gen'' ELSE a.template END FROM ' + @temp_table_name + ' a')

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''leg'') IS NULL
				BEGIN
					ALTER TABLE ' + @temp_table_name + ' 
					ADD [leg] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
				END
		');

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''schedule volume'') IS NULL
				BEGIN
					ALTER TABLE ' + @temp_table_name + ' 
					ADD [schedule volume] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
				END
		')

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''actual volume'') IS NULL
				BEGIN
					ALTER TABLE ' + @temp_table_name + ' 
					ADD [actual volume] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
				END
		')

		EXEC('IF COL_LENGTH(''' + @temp_table_name + ''', ''Minute'') IS NULL
				BEGIN
					ALTER TABLE ' + @temp_table_name + ' 
					ADD [Minute] NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL
				END
		')

		IF @deal_type IS NOT NULL
		BEGIN
			EXEC ('UPDATE a SET a.[leg] = 1 FROM ' + @temp_table_name + ' a')
		END

		--exec('select * from ' + @temp_table_name)
		--return

		DECLARE @temp_table_name_post NVARCHAR(200) -- to call in post trigger with same import file data.
		SET @temp_table_name_post = @temp_table_name + '_post'

		IF OBJECT_ID(@temp_table_name_post) IS NOT NULL
			EXEC('DROP TABLE ' + @temp_table_name_post)

		EXEC('SELECT * INTO ' + @temp_table_name_post + ' FROM ' + @temp_table_name)

		EXEC('ALTER TABLE ' + @temp_table_name_post + ' 
			ADD is_new NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL')

		EXEC ('UPDATE a SET a.is_new = CASE WHEN sdh.deal_id IS NOT NULL THEN 0 ELSE 1 END 
				FROM ' + @temp_table_name_post + ' a LEFT JOIN source_deal_header sdh ON sdh.[deal_id] = a.[deal ref id]')

		/* 1. End */

		SELECT @rule_id = ir.ixp_rules_id
		FROM ixp_rules ir
		WHERE ir.ixp_rules_name = 'Baseline import'

		/* 2. Create table of deals import collecting all columns*/
		SELECT @column_list = COALESCE(@column_list + ', ', '') + '' + REPLACE(iidm.source_column_name, 'd.', '') + ' ' + ic.column_datatype +' '+'  COLLATE DATABASE_DEFAULT'
		FROM ixp_tables it
		INNER JOIN ixp_columns ic ON ic.ixp_table_id = it.ixp_tables_id
		INNER JOIN ixp_rules ir ON ir.ixp_rules_name = 'Baseline import'
		INNER JOIN ixp_import_data_mapping iidm ON iidm.dest_column = ic.ixp_columns_id
			AND iidm.ixp_rules_id = ir.ixp_rules_id
		WHERE ixp_tables_name = 'ixp_source_deal_template'

		EXEC('CREATE TABLE  ' + @tempTable + ' (  ' + @column_list + ' )');

		SET @sqlStmt= '
		INSERT INTO ' + @tempTable + '( 
				[Deal Date],
				[Counterparty],
				[Deal Type],
				[Trader],
				[Header Buy/Sell],
				[Term Start],
				[Term End],
				[Leg],
				--[Deal Volume],
				[Volume Frequency],
				[Volume UOM],
				[deal id],
				[Physical Financial],
				[Option flag],
				[Template],
				[Commodity],
				[Deal Status],
				[Subbook],
				[Expiration Date],
				[Fixed Float],
				[Buy Sell],
				[contract],
				[pricing type],
				[market index],
				[profile],
				[currency],
				[Category],
				[Confirm Status],
				[Profile Granularity],
				[location],
				[index on],
				[addon],
				[Price Multiplier],
				[Option Exercise Type],
				[Option Type],
				[Internal Deal Type],
				[volume multiplier],
				[position uom],
				[broker],
				[TimeZone]
				)  
			 SELECT DISTINCT
				tt.[deal date],
				sc.counterparty_id,
				sdt.deal_type_id,
				st.trader_id, 
				''s'', --sdht.header_buy_sell_flag,
				c_date.term_start from_date,  
				c_date.term_end from_date, 
				CASE WHEN tt.[Type] = ''Baseline'' OR tt.[Type] = ''New Gen'' THEN 1 ELSE tt.[leg] END,
				--FLOOR(tt.Volume*ISNULL(conv.conversion_factor,1)),
				sddt.deal_volume_frequency,
				su.uom_id,
				tt.[deal ref id],
				sdht.physical_financial_flag,         		
				sdht.option_flag,	
				sdht.template_name,		
				sco.commodity_id,	
				sdv_ds.code,	
				tt.[Original book],		   -- **
				 c_date.term_end AS term_end,	
				''t'',	                        --**
				CASE WHEN tt.[Type] = ''Baseline'' OR tt.[Type] = ''New Gen'' THEN ''s'' ELSE CASE WHEN tt.[buy sell] = ''buy'' THEN ''b'' ELSE ''s'' END END,
				cg.contract_name,
				sdv_pt.code,
				tt.[Market Index],
				sdv_profile.code,
				tt.[currency],
				''Real'',
				''Confirmed'',
				''Hourly'',
				NULLIF(tt.[location id],''''),
				NULLIF(tt.[Price Index],''''),
				NULLIF(tt.[Price Adder],''''),
				NULLIF(tt.[Price Multiplier],''''),
				sdht.option_excercise_type,
				sdht.option_type,
				idtst.internal_deal_type_subtype_type,
				sddt.[multiplier],
				su_pu.uom_name,
				sc_broker.counterparty_id,
				tt.[TimeZone]
			FROM ' + @temp_table_name + ' tt
			INNER JOIN source_deal_header_template sdht ON sdht.template_name = tt.[Type]
			INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id AND sddt.leg = tt.leg
			LEFT JOIN source_traders st On st.source_trader_id = sdht.trader_id 
			LEFT JOIN source_counterparty sc On sc.counterparty_id = tt.[Counterparty]
			LEFT JOIN source_deal_type sdt On sdt.source_deal_type_id = sdht.source_deal_type_id
			LEFT JOIN source_commodity sco On sco.source_commodity_id = sdht.commodity_id  
			LEFT JOIN source_uom su ON su.source_uom_id=sddt.deal_volume_uom_id
			LEFT JOIN contract_group cg ON cg.contract_name = tt.[Contract]
			LEFT JOIN static_data_value sdv_pt ON sdv_pt.value_id = sdht.pricing_type 
			LEFT JOIN static_data_value sdv_ds ON sdv_ds.value_id = sdht.deal_status
			LEFT JOIN static_data_value sdv_profile ON sdv_profile.value_id = sdht.internal_desk_id
			LEFT JOIN source_uom su_pu ON su_pu.source_uom_id = sddt.[position_uom]
			LEFT JOIN source_counterparty sc_broker ON sc_broker.source_counterparty_id = sdht.[broker_id]
			LEFT JOIN internal_deal_type_subtype_types idtst ON idtst.internal_deal_type_subtype_id = sdht.internal_deal_type_value_id
			--OUTER APPLY (
			--	SELECT su_pu.uom_name, su.uom_id FROM source_deal_detail_template a
			--	--INNER JOIN source_uom sc1 ON sc1.source_uom_id = a.deal_volume_uom_id
			--	LEFT JOIN source_uom su_pu ON su_pu.source_uom_id = a.[position_uom]
			--	LEFT JOIN source_uom su ON su.source_uom_id=a.deal_volume_uom_id
			--		WHERE a.leg = sddt.leg AND sddt.template_id = a.template_id
			--) sddt2
			OUTER APPLY (
				SELECT MAX(currency_name) currency_name FROM source_currency WHERE source_currency_id = ISNULL(sddt.currency_id, 1)
			) cur
			OUTER APPLY (
				SELECT MIN(CAST([term date] AS DATE)) term_start, MAX(CAST([term date] AS DATE)) term_end FROM   ' + @temp_table_name + ' a WHERE tt.[deal ref id] = a.[deal ref id]
			) c_date
			'
		--PRINT @sqlStmt
		EXEC(@sqlStmt)

		EXEC('DROP TABLE ' + @temp_table_name)
		EXEC('SELECT * INTO ' + @temp_table_name + ' FROM ' + @tempTable)

		EXEC(' SELECT * FROM ' + @temp_table_name)

	END
	ELSE IF @flag = 'a' -- After trigger call for Baseline import / Model Deal Transfer import.
	BEGIN
		SELECT @rule_id = ir.ixp_rules_id
		FROM ixp_rules ir
		WHERE ir.ixp_rules_name = 'Shaped Volume Support'
		
		SELECT @tempTable = REPLACE(@temp_table_name, 'adiha_process.dbo.breakdown_import_data_' + dbo.fnadbuser(), 'adiha_process.dbo.temp_import_data_table_d')  + '_post'

		EXEC( 'UPDATE sdd
			SET contract_expiration_date =sdd.term_end 
				FROM source_deal_detail sdd 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN ' + @tempTable + ' t ON t.[deal ref id] = sdh.[deal_id]')

		SET @sqlStmt = '
			IF EXISTS(SELECT TOP 1 ''x'' FROM ' + @tempTable + ')
			BEGIN
				EXEC spa_ixp_rules	
					@flag = ''t'',
					@process_id = '''+ @process_id + ''',	
					@ixp_rules_id = ' + CAST(@rule_id AS VARCHAR) + ',
					@run_table = '''+ @tempTable + ''',
					@source = ''21400'',	
					@run_with_custom_enable = ''n'',
					@server_path = NULL,
					@run_in_debug_mode = ''n''
			END'
		EXEC (@sqlStmt)

	END
	ELSE IF @flag = 't' -- transfer deals [Called from customizing query of Shaped Volume Support Import.]
	BEGIN
		--SELECT @temp_table_name_transfer = @temp_table_name
		DECLARE @sql1 NVARCHAR(MAX)
		DECLARE @p_id NVARCHAR(500),
		        @alias NVARCHAR(50)

		SELECT @alias = IIF(iidc.data_source_alias IS NOT NULL,'_' + data_source_alias, '')
		FROM ixp_rules ir
		INNER JOIN ixp_import_data_source iidc
			ON iidc.rules_id = ir.ixp_rules_id
		WHERE ir.ixp_rules_name = 'Shaped Volume Support'

		-- Resolve raw import data for transfer deal which is inserted from custom query
		SELECT @temp_table_name_transfer = REPLACE(@temp_table_name, 'adiha_process.dbo.ixp_source_deal_detail_15min_template_0_' + dbo.fnadbuser(), 'adiha_process.dbo.temp_import_data_table' + @alias)  + '_transfer'

		SELECT @p_id = SUBSTRING(@temp_table_name, len('adiha_process.dbo.ixp_source_deal_detail_15min_template_0_') + len(dbo.fnadbuser()) + 2, (len(@temp_table_name) - len('adiha_process.dbo.ixp_source_deal_detail_15min_template_0_') ))
		--select @p_id

		CREATE TABLE #trasfer_detail (
			id INT IDENTITY(1,1), 
			transfer_sub_book NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			source_deal_header_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			counterparty_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			contract_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			trader_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			sub_book NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			template_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			location_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			formula_curve_id NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			deal_date NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			time_zone NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			currency NVARCHAR(100) COLLATE DATABASE_DEFAULT,
			transfer_deal NVARCHAR(10) COLLATE DATABASE_DEFAULT
		)

		SET @sql = ' 
		INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description], type_error)
		SELECT DISTINCT ''' + @p_id + ''', ''ixp_source_deal_detail_15min_template'', ''Data Error'', 
		''Data Error: '' + tmp.[Transfer Book] + '' : Book not available in the system for transfer deal.'', ''Error''
		FROM ' + @temp_table_name_transfer + ' tmp
		LEFT JOIN source_system_book_map ssbm ON ssbm.logical_name = tmp.[Transfer Book]
		WHERE ssbm.book_deal_type_map_id IS NULL'
		EXEC(@sql);

		SET @sql1 = 'DELETE tmp 
			FROM ' + @temp_table_name_transfer + ' tmp
		LEFT JOIN source_system_book_map ssbm ON ssbm.logical_name = tmp.[Transfer Book]
		WHERE ssbm.book_deal_type_map_id IS NULL'
		EXEC(@sql1);

		--DECLARE @tempTable1 NVARCHAR(MAX)
		--SET @tempTable1 = dbo.FNAProcessTableName('deal_invoice_', '1234567898', '1234567898')
		--EXEC('CREATE TABLE  ' + @tempTable1 + ' (  MSG NVARCHAR(MAX))
		--insert into ' + @tempTable1 + ' (MSG)
		--select ''' + @sql1 + '''
		--');

		--SET @sql = 'EXEC dbo.spa_message_board ''U'', '''+ @user_login_id +''', NULL, ''ImportData'', ''Error'', '''', '''', ''e'', NULL,NULL, ''' + @p_id + ''''
		--EXEC (@sql);

		IF 1 = 1
		BEGIN
		EXEC('SELECT DISTINCT [Transfer book], [Original book], [deal ref id], [is_new], [deal date], [TimeZone], [currency] INTO #temp1 FROM  ' + @temp_table_name_transfer + '

			INSERT INTO #trasfer_detail
			SELECT ssbm.book_deal_type_map_id AS [transfer_sub_book],
				sdh.[source_deal_header_id],
				ISNULL(ssbm1.primary_counterparty_id,sdh.[counterparty_id]),
				sdh.[contract_id],
				sdh.[trader_id],
				sdh.[sub_book],
				sdh.[template_id],
				sdd.[location_id],
				sdd.[formula_curve_id],
				a.[deal date],
				tz.timezone_id,
				sc.[source_currency_id],
				CASE WHEN a.[is_new] = 1 OR sdh_offset.source_deal_header_id IS NULL THEN ''true'' ELSE ''false'' END					
			FROM #temp1 a 
				INNER JOIN source_deal_header sdh ON sdh.deal_id = a.[deal ref id]
				LEFT JOIN source_deal_header sdh_offset
					ON sdh_offset.close_reference_id = sdh.source_deal_header_id
				OUTER APPLY (SELECT MAX(location_id) location_id, MAX(formula_curve_id) formula_curve_id FROM source_deal_detail sdd WHERE sdd.source_deal_header_id = sdh.source_deal_header_id) sdd
				LEFT JOIN source_system_book_map ssbm ON ssbm.logical_name = a.[Transfer book]
				LEFT JOIN source_system_book_map ssbm1 ON ssbm1.logical_name = a.[Original book]
				--LEFT JOIN source_price_curve_def spcd ON spcd.curve_name = a.[Price Index]
				LEFT JOIN time_zones tz ON tz.TIMEZONE_NAME_FOR_PHP = a.[TimeZone]
				LEFT JOIN source_currency sc ON sc.currency_name = a.[currency]
			--WHERE a.[is_new] = 1 OR sdh_offset.source_deal_header_id IS NULL
		')
		--select * from #trasfer_detail
		--return

		-- Transfer deal logic.		
		DECLARE @source_deal_header_id INT
		DECLARE @counterparty_id NVARCHAR(200)
		DECLARE @contract_id NVARCHAR(200)
		DECLARE @trader_id NVARCHAR(200)
		DECLARE @sub_book NVARCHAR(200)
		DECLARE @template_id NVARCHAR(200)
		DECLARE @location_id NVARCHAR(200)
		DECLARE @formula_curve_id NVARCHAR(200)
		DECLARE @deal_date NVARCHAR(200)
		DECLARE @time_zone NVARCHAR(200)
		DECLARE @currency NVARCHAR(200)
		DECLARE @val_xm NVARCHAR(MAX) ,
		        @transfer_offset_deal_ids NVARCHAR(MAX)

		/* Delete existing transfer and offset deals */

		IF OBJECT_ID('tempdb..#temp_term_change_deal') IS NOT NULL
			DROP TABLE #temp_term_change_deal;
		WITH cte AS (
			SELECT sdd.source_deal_header_id,sdd.source_deal_detail_id,sdd.term_start,sdd.term_end,sdd.header_audit_id,
				ROW_NUMBER() OVER (PARTITION BY sdd.source_deal_header_id,sdd.source_deal_detail_id ORDER BY sdd.audit_id DESC) row_no
			FROM (SELECT DISTINCT source_deal_header_id
				  FROM #trasfer_detail
				 ) sdh
			INNER JOIN source_deal_detail_audit sdd
				ON sdd.source_deal_header_id = sdh.source_deal_header_id
		)

		/*Delete detail id from audit which has already been deleted before. Get detail id whose term has been changed or detail row has been currently deleted*/
		SELECT DISTINCT c.source_deal_header_id
		INTO #temp_term_change_deal
		FROM cte c
		CROSS APPLY (SELECT MAX(header_audit_id) [header_audit_id]
					 FROM cte
					 WHERE source_deal_header_id = c.source_deal_header_id
					 AND row_no = 2
		) tbl_cte
			LEFT JOIN source_deal_detail sdd
				ON sdd.source_deal_header_id = c.source_deal_header_id
				AND sdd.source_deal_detail_id = c.source_deal_detail_id
			WHERE row_no = 2
		AND c.header_audit_id = tbl_cte.header_audit_id
		AND (sdd.term_start <> c.term_start OR sdd.term_end <> c.term_end OR sdd.source_deal_detail_id IS NULL)
		UNION 
		SELECT td.source_deal_header_id
		FROM #trasfer_detail td
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = td.source_deal_header_id
		INNER JOIN source_deal_header sdh_child
			ON sdh_child.close_reference_id = sdh.source_deal_header_id
		WHERE sdh.close_reference_id IS NULL
		AND (sdh_child.entire_term_start <> sdh.entire_term_start OR sdh_child.entire_term_end <> sdh.entire_term_end)

		SELECT @transfer_offset_deal_ids = STUFF((SELECT DISTINCT ',' +  CAST(source_deal_header_id AS NVARCHAR(20))
			FROM(
			SELECT sdh_t.source_deal_header_id
			FROM #temp_term_change_deal t
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = t.source_deal_header_id
			INNER JOIN source_deal_header sdh_t
				ON sdh_t.close_reference_id = sdh.source_deal_header_id
			WHERE sdh.close_reference_id IS NULL
			UNION 
			SELECT sdh_o.source_deal_header_id 
			FROM #temp_term_change_deal t
			INNER JOIN source_deal_header sdh
				ON sdh.source_deal_header_id = t.source_deal_header_id
			INNER JOIN source_deal_header sdh_t
				ON sdh_t.close_reference_id = sdh.source_deal_header_id
			INNER JOIN source_deal_header sdh_o
				ON sdh_o.close_reference_id = sdh_t.source_deal_header_id
			WHERE sdh.close_reference_id IS NULL	
			) tbl
			FOR XML PATH('')), 1, 1, '')

		EXEC spa_source_deal_header @flag = 'd', @deal_ids = @transfer_offset_deal_ids , @comments = ''
		/*End of delete*/

		/*Update transfer status to true for those deals which offset/transfer deal has been deleted*/
		UPDATE td
			SET transfer_deal = 'true'
		FROM #trasfer_detail td
		INNER JOIN #temp_term_change_deal ttcd
			ON ttcd.source_deal_header_id = td.source_deal_header_id


		/* Update exisiting offset/transfer deal*/
		UPDATE sdh_t
			SET sub_book = t.transfer_sub_book,
			    source_system_book_id1 = ssbm.source_system_book_id1,
				source_system_book_id2 = ssbm.source_system_book_id2,
				source_system_book_id3 = ssbm.source_system_book_id3,
				source_system_book_id4 = ssbm.source_system_book_id4
		FROM #trasfer_detail t
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_deal_header sdh_t
			ON sdh_t.close_reference_id = sdh.source_deal_header_id
		INNER JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = t.transfer_sub_book
		WHERE sdh.close_reference_id IS NULL
		AND sdh_t.sub_book <> t.transfer_sub_book

		UPDATE sdh_o
			SET sub_book = t.transfer_sub_book,
			    source_system_book_id1 = ssbm.source_system_book_id1,
				source_system_book_id2 = ssbm.source_system_book_id2,
				source_system_book_id3 = ssbm.source_system_book_id3,
				source_system_book_id4 = ssbm.source_system_book_id4
		FROM #trasfer_detail t
		INNER JOIN source_deal_header sdh
			ON sdh.source_deal_header_id = t.source_deal_header_id
		INNER JOIN source_deal_header sdh_t
			ON sdh_t.close_reference_id = sdh.source_deal_header_id
		INNER JOIN source_deal_header sdh_o
			ON sdh_o.close_reference_id = sdh_t.source_deal_header_id
		INNER JOIN source_system_book_map ssbm
			ON ssbm.book_deal_type_map_id = t.transfer_sub_book
		WHERE sdh.close_reference_id IS NULL
		AND sdh_o.sub_book <> t.transfer_sub_book
		/*End of update*/

		DECLARE cur_deals CURSOR LOCAL FOR
		SELECT source_deal_header_id,counterparty_id,contract_id,trader_id,transfer_sub_book,template_id,location_id, formula_curve_id, deal_date, time_zone, currency FROM #trasfer_detail a 
		WHERE a.transfer_deal = 'true'
 
		OPEN cur_deals ;
		FETCH NEXT FROM cur_deals INTO @source_deal_header_id, @counterparty_id, @contract_id, @trader_id, @sub_book, @template_id, @location_id, @formula_curve_id, @deal_date, @time_zone, @currency
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @val_xm = '
				<GridXML><GridRow
					counterparty_id = ''' + @counterparty_id + '''
					contract_id = ''' + @contract_id + '''
					trader_id = ''' + @trader_id + '''
					sub_book = ''' + @sub_book + '''
					template_id = ''' + @template_id + '''
					location_id = ''' + @location_id + '''
					transfer_volume = ''0''
					volume_per = ''100''
					pricing_options = ''d''
					fixed_price = ''''
					transfer_date = ''' + CONVERT(NVARCHAR(10), GETDATE(), 120)  + '''
					transfer_counterparty_id = ''''
					transfer_contract_id = ''''
					transfer_trader_id = ''''
					transfer_sub_book = ''''
					transfer_template_id = ''''
					fixed_adder = ''''
				></GridRow></GridXML>'

			--SELECT @val_xm
			--SELECT @source_deal_header_id
			EXEC spa_deal_transfer @flag='t',
				@source_deal_header_id=@source_deal_header_id,
				@transfer_without_offset=NULL,
				@transfer_only_offset= '1',
				@xml= @val_xm,
				@price_adder= NULL,
				@formula_curve_id = @formula_curve_id,
				@deal_date = @deal_date,
				@time_zone = @time_zone,
				@currency = @currency

			FETCH NEXT FROM cur_deals INTO @source_deal_header_id, @counterparty_id, @contract_id, @trader_id, @sub_book, @template_id, @location_id, @formula_curve_id, @deal_date, @time_zone, @currency
		END;

		CLOSE cur_deals ;
		DEALLOCATE cur_deals ;
		END
		
	END

END
GO

