
IF OBJECT_ID('spa_ice_deal_staging_process') IS NOT NULL
DROP PROCEDURE [dbo].[spa_ice_deal_staging_process] 
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[spa_ice_deal_staging_process]
	@flag CHAR(1),
	@user_login_id VARCHAR(20) = '',
	@process_id VARCHAR(150) = NULL,
	@error_code VARCHAR(10) = NULL,
	@stage_ice_deal VARCHAR(255) = NULL
	
AS
	--exec [spa_ice_deal_staging_process] 'c'

DECLARE @current_ts AS DATETIME = GETDATE()
DECLARE @sql VARCHAR(MAX), @job_name VARCHAR(500), @url varchar(500), @errorcode CHAR(1)

SET @user_login_id = ISNULL(NULLIF(@user_login_id, ''), dbo.fnadbuser())
SET @process_id = ISNULL(NULLIF(@process_id, ''), REPLACE(NEWID(), '-', '_'))

IF  @stage_ice_deal IS NULL
	SET @stage_ice_deal = 'adiha_process.dbo.IceDealImport_' + @process_id  --dbo.FNAProcessTableName('IceDealImport', @user_login_id, @process_id)
	
DECLARE @status CHAR(1), @elapsed_sec FLOAT, @start_ts DATETIME, @desc VARCHAR(8000) = 'Error Exist' --, @desc2 VARCHAR(1000) = 'Data may not be available in the source.Please check the data source.'

IF @flag = 'c'
BEGIN
	-- initiate import audit log,
	IF NOT EXISTS (SELECT 1 FROM import_data_files_audit WHERE process_id = @process_id)
	BEGIN
		EXEC spa_import_data_files_audit 'i', @current_ts, NULL, @process_id, 'ICE Deal Import', 'source_deal_detail', @current_ts, 'p', NULL
	END
		
	SET @sql = 'IF OBJECT_ID(''' + @stage_ice_deal + ''') IS NOT NULL
		DROP TABLE ' + @stage_ice_deal 
	EXEC(@sql)
	
	SET @sql = 
		'
		CREATE TABLE ' + @stage_ice_deal + 
		'(
			 [id]				INT IDENTITY(1,1)			
			,[trade_date]		DATETIME NULL			
			,[trade_time]		NVARCHAR(255) NULL		
			,[deal_id]			NVARCHAR(255) NULL		
			,[leg_id]			NVARCHAR(255) NULL		
			,[orig_id]			NVARCHAR(255) NULL		
			,[b_s]				NVARCHAR(255) NULL		
			,[product]			NVARCHAR(255) NULL		
			,[hub]				NVARCHAR(255)NULL		
			,[strip]			NVARCHAR(255) NULL
			,[begin_date]		DATETIME NULL
			,[end_date]			DATETIME NULL
			,[option]			NVARCHAR(255) NULL
			,[strike]			NVARCHAR(255) NULL
			,[strike_2]			NVARCHAR(255) NULL
			,[style]			NVARCHAR(255) NULL
			,[counterparty]		NVARCHAR(255) NULL
			,[price]			NUMERIC(38,20) NULL
			,[price_units]		NVARCHAR(255) NULL
			,[qty_per_period]	NVARCHAR(255) NULL
			,[periods]			NVARCHAR(255) NULL
			,[total_quantity]	NVARCHAR(255) NULL
			,[qty_units]		NVARCHAR(255) NULL
			,[trader]			NVARCHAR(255) NULL
			,[memo]				NVARCHAR(255) NULL
			,[clearing_venue]	NVARCHAR(255) NULL
			,[user_id]			NVARCHAR(255) NULL
			,[source]			NVARCHAR(255) NULL
			,[usi]				NVARCHAR(255) NULL
			,[authorized_trader_id]	NVARCHAR(255) NULL
			,[pipeline]			NVARCHAR(255) NULL
			,[state]			NVARCHAR(255) NULL
			
			,[contract] NVARCHAR(255) NULL
			,[clearing_acct] NVARCHAR(255) NULL
			,[cust_acct] NVARCHAR(255) NULL
			--,[clearing_firm] NVARCHAR(255) NULL
			--,[lots] NVARCHAR(255) NULL
			,[tt] NVARCHAR(255) NULL
			,[brk] NVARCHAR(255) NULL
			,[link_id] NVARCHAR(255) NULL
			,[location] NVARCHAR(255) NULL
			,[meter] NVARCHAR(255) NULL
			,[lead_time] NVARCHAR(255) NULL
			
			,[physical_financial_flag] CHAR(10)
			,[source_deal_type_id] VARCHAR(50)
			,[source_deal_sub_type_id] VARCHAR(50)
			,[source_system_book_id1] VARCHAR(50)
			,[source_system_book_id2] VARCHAR(50)
			,[source_system_book_id3] VARCHAR(50)
			,[source_system_book_id4] VARCHAR(50)
			,[deal_category_value_id] VARCHAR(50)
			,[commodity_id] VARCHAR(50)
			,[term_frequency] CHAR(1)
			,[template_id] VARCHAR(250)
			,[leg] INT
			,[fixed_float_leg] CHAR(1)
			,[physical_financial_flag_detail] CHAR(1)
			,[contract_id] VARCHAR(50)
			,[term_start] VARCHAR(50)
			,[term_end] VARCHAR(50)
			,[curve_id] VARCHAR(100)
		)'
		
 				
	EXEC(@sql)
	--PRINT(@sql)	
	SELECT @stage_ice_deal loadtable
END
ELSE IF @flag = 'e'
BEGIN

	SET @status = 'e'

	IF @error_code = 2
	BEGIN
		SET @desc = 'Data Flow Error. Error in file or format'
		--SET @desc2 = 'Invalid File Format'
	END
	else IF @error_code = 3
	BEGIN
		SET @desc = 'Bilateral Deals not found'
	END		
	else IF @error_code = 5
	BEGIN
		SET @desc = 'Error in reading source file'
	END	
	ELSE
		SET @desc = 'Error occured'			
		
	--INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
	--SELECT  @process_id, @filename, 'Data Error', @desc
	
	INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
	SELECT  @process_id,'Error','Import Data','source_deal','Data Error',@desc,'n/a'

END 
ELSE IF @flag = 'i'
BEGIN
	
	DECLARE @staging_tbl_name VARCHAR(100)
	DECLARE @logical_name VARCHAR(200) = 'Ice Deals'
	DECLARE @source_system_book_id1 VARCHAR(50) = '', @source_system_book_id2 VARCHAR(50) = '', @source_system_book_id3 VARCHAR(50) = '', @source_system_book_id4 VARCHAR(50) = ''

	SELECT distinct @source_system_book_id1 = sb1.source_system_book_id, @source_system_book_id2 = sb2.source_system_book_id, 
	@source_system_book_id3 = sb3.source_system_book_id, @source_system_book_id4 = sb4.source_system_book_id
	--source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4
	FROM portfolio_hierarchy book (nolock) 
	INNER JOIN portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id 
	INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = stra.parent_entity_id  
	INNER JOIN source_system_book_map sbm ON sbm.fas_book_id = book.entity_id   
	INNER JOIN source_book sb1 ON sb1.source_book_id = sbm.source_system_book_id1
	INNER JOIN source_book sb2 ON sb2.source_book_id = sbm.source_system_book_id2
	INNER JOIN source_book sb3 ON sb3.source_book_id = sbm.source_system_book_id3
	INNER JOIN source_book sb4 ON sb4.source_book_id = sbm.source_system_book_id4
	WHERE sbm.logical_name  = @logical_name

	IF OBJECT_ID('tempdb..#staging_tbl_name') IS NOT NULL
		DROP TABLE #staging_tbl_name

	CREATE TABLE #staging_tbl_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT )  
	
	BEGIN TRY
	IF @error_code = 0
	BEGIN
		INSERT #staging_tbl_name  
		EXEC spa_import_temp_table '4028'

		SELECT @staging_tbl_name = table_name FROM #staging_tbl_name
		--SELECT @staging_tbl_name
	
		--EXEC(' DELETE FROM ' + @stage_ice_deal + ' WHERE ISNULL(trade_time, ''Trade Time'') = ''Trade Time'' ')
		EXEC(' DELETE FROM ' + @stage_ice_deal + ' WHERE trade_time IS NULL')
	
		CREATE TABLE #replace_str(string VARCHAR(100) COLLATE DATABASE_DEFAULT , replace_str VARCHAR(100) COLLATE DATABASE_DEFAULT )
		INSERT INTO #replace_str(string, replace_str) VALUES
		('(', ''), 	(')', ''), ('{', ''), ('}', ''), ('[', ''), (']', ''), ('"', ''), --('''', ''),
		('.', '_'), (',', '_'), ('/', '_'), ('#', '_'),	('*', '_'),	('%', '_'),	('&', '_'),	('@', '_'),	('!', '_')
	
		DECLARE @st VARCHAR(MAX),@st1 VARCHAR(MAX)
		SET @st	='s.hub'
		SELECT @st='replace('+@st+',''' +string+''','''+ replace_str+''')' FROM #replace_str
		--PRINT @st	

		SET @st1='
		UPDATE s SET s.hub = '+@st+' FROM ' + @stage_ice_deal + ' s'

		PRINT @st1
		EXEC(@st1)

		-- error handling
		CREATE TABLE #error_deals_flag(code VARCHAR(25) COLLATE DATABASE_DEFAULT )

		-- unknown 'product' i.e template
		EXEC('
		INSERT INTO source_system_data_import_status(process_id, code, MODULE, source, TYPE, [description], recommendation)
		OUTPUT INSERTED.code INTO #error_deals_flag		
		SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', ''source_deal'' , ''Data Error'',  ''Deal '' + ISNULL(idsr.deal_id, ''NULL'') + '' not imported. '' + idsr.product + '' template not found'', '''' 
		FROM ' + @stage_ice_deal + ' idsr
		LEFT JOIN source_deal_header_template sdht ON sdht.template_name = idsr.[product]
		WHERE sdht.template_id IS NULL
		')

		-- unknown 'hub' i.e location
		EXEC('
		INSERT INTO source_system_data_import_status(process_id, code, MODULE, source, TYPE, [description], recommendation)
		OUTPUT INSERTED.code INTO #error_deals_flag		
		SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', ''source_deal'' , ''Data Error'',  ''Deal '' + ISNULL(idsr.deal_id, ''NULL'') + '' not imported. '' + idsr.hub + '' location not found'', '''' 
		FROM ' + @stage_ice_deal + ' idsr
		LEFT JOIN source_minor_location sml ON sml.location_id = idsr.[hub]
		WHERE sml.source_minor_location_id IS NULL
		')

		-- unknown 'counterparty'
		EXEC('
		INSERT INTO source_system_data_import_status(process_id, code, MODULE, source, TYPE, [description], recommendation)
		OUTPUT INSERTED.code INTO #error_deals_flag		
		SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', ''source_deal'' , ''Data Error'',  ''Deal '' + ISNULL(idsr.deal_id, ''NULL'') + '' not imported. '' + idsr.counterparty + '' counterparty not found'', '''' 
		FROM ' + @stage_ice_deal + ' idsr
		LEFT JOIN source_counterparty sc ON sc.counterparty_id = idsr.[counterparty]
		WHERE sc.source_counterparty_id IS NULL
		')

		-- unknown 'trader'
		EXEC('
		INSERT INTO source_system_data_import_status(process_id, code, MODULE, source, TYPE, [description], recommendation)
		OUTPUT INSERTED.code INTO #error_deals_flag		
		SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', ''source_deal'' , ''Data Error'',  ''Deal '' + ISNULL(idsr.deal_id, ''NULL'') + '' not imported. '' + idsr.trader + '' trader not found'', '''' 
		FROM ' + @stage_ice_deal + ' idsr
		LEFT JOIN source_traders st ON st.trader_id = idsr.[trader]
		WHERE st.source_trader_id IS NULL
		')		
		
		-- formula curve ID (resolved as '<Hub> <last word of product>') not defined
		EXEC('
		INSERT INTO source_system_data_import_status(process_id, code, MODULE, source, TYPE, [description], recommendation)
		OUTPUT INSERTED.code INTO #error_deals_flag
		SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', ''source_deal'' , ''Data Error'',  ''Deal '' + ISNULL(idsr.deal_id, ''NULL'') + '' not imported. '' + idsr.hub + '' '' + REVERSE(LEFT(REVERSE(idsr.product), CHARINDEX('' '', REVERSE(idsr.product)) - 1)) + '' formula curve ID not defined in system'', '''' 
		FROM ' + @stage_ice_deal + ' idsr
		LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = idsr.hub + '' '' + REVERSE(LEFT(REVERSE(idsr.product), CHARINDEX('' '', REVERSE(idsr.product)) - 1))
		WHERE spcd.source_curve_def_id IS NULL AND idsr.product NOT LIKE ''%FP''
		')

		EXEC('
		DELETE idsr FROM ' + @stage_ice_deal + ' idsr
		LEFT JOIN source_price_curve_def spcd ON spcd.curve_id = idsr.hub + '' '' + REVERSE(LEFT(REVERSE(idsr.product), CHARINDEX('' '', REVERSE(idsr.product)) - 1))
		WHERE spcd.source_curve_def_id IS NULL AND idsr.product NOT LIKE ''%FP''
		')
		  
		
		SET @sql = 'INSERT INTO '  + @staging_tbl_name+ 
		'(deal_id, source_system_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, header_buy_sell_flag, curve_id, fixed_price, price_adder
		, fixed_price_currency_id, deal_volume, deal_volume_frequency, deal_volume_uom_id, deal_date, physical_financial_flag, source_deal_type_id
		, source_deal_sub_type_id, deal_category_value_id, contract_id, physical_financial_flag_detail, location_id, pay_opposite, term_frequency
		, deal_status ,source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, trader_id, counterparty_id
		, broker_id,option_flag, [template], commodity_id, description1, description3, option_type, option_strike_price, option_excercise_type, table_code)


		SELECT
		 idsr.[deal_id] AS deal_id	
		 , ''2'' AS source_system_id
		 , t.term_start  -- idsr.[begin_date]  AS term_start
		 , t.term_end    -- idsr.[end_date]  AS term_end
		 , sddt.leg AS Leg
		 , idsr.[end_date] AS contract_expiration_date
		 , sddt.fixed_float_leg AS fixed_float_leg
		 , CASE WHEN idsr.[b_s] = ''Bought'' THEN ''b'' WHEN idsr.[b_s] = ''Sold'' THEN ''s'' END AS buy_sell_flag
		 , CASE WHEN idsr.[b_s] = ''Bought'' THEN ''b'' WHEN idsr.[b_s] = ''Sold'' THEN ''s'' END AS header_buy_sell_flag
		 , spcd.curve_id AS curve_id
		 , CASE WHEN idsr.[product] = ''NG Firm Phys, FP'' THEN idsr.[price] ELSE NULL END AS fixed_price
		 , CASE WHEN idsr.[product] IN (''NG Firm Phys, ID, GDD'', ''NG Firm Phys, ID, IF'') THEN idsr.[price] ELSE NULL END AS price_adder
		 , sc.currency_id AS fixed_price_currency_id
		 , idsr.[qty_per_period] AS deal_volume
		 , CASE idsr.[periods] WHEN ''Daily'' THEN ''d'' END AS deal_volume_frequency
		 , su.uom_id AS deal_volume_uom_id
		 , idsr.[trade_date] AS deal_date
		 , sdht.physical_financial_flag AS physical_financial_flag
		 , sdt.deal_type_id AS Deal_type
		 , sdt2.deal_type_id AS deal_sub_type
		 , sdht.deal_category_value_id AS Category  -- hardcode Real
		 , cg.contract_name AS [contract_id]
		 , sddt.physical_financial_flag AS physical_financial_flag_detail
		 , sml.location_id AS location_id
		 , ''Y'' AS [pay_opposite]  -- yes
		 , sdht.term_frequency_type
		 , ''5604'' AS deal_status 
		 , '''+ @source_system_book_id1 +''' source_system_book_id1  
		 , '''+ @source_system_book_id2 +''' source_system_book_id2  
		 , '''+ @source_system_book_id3 +''' source_system_book_id3  
		 , '''+ @source_system_book_id4 +''' source_system_book_id4  
		 , st.trader_id AS trader
		 , sc_counterparty.counterparty_id AS CounterParty
		 , NULL AS Broker  -- not reqd
		 , ''n'' AS option_flag
		 , sdht.template_name AS template_name
		 , scd.commodity_id AS commodity_id -- natural gas
		 , idsr.orig_id description1
		 , idsr.memo description3
		 , idsr.[option] option_type
		 , idsr.[strike] option_strike_price
		 , idsr.[style] option_excercise_type
		 , ''4028'' table_code
	 
		-- SELECT *
		 FROM ' + @stage_ice_deal + ' idsr
		INNER JOIN source_deal_header_template sdht ON 	sdht.template_name = idsr.[product]
		INNER JOIN source_deal_detail_template sddt ON sddt.template_id = sdht.template_id
		CROSS APPLY dbo.FNATermBreakdown(sdht.term_frequency_type, idsr.begin_date, idsr.end_date) t
		INNER JOIN source_currency sc ON sc.currency_id = ''USD''
		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdht.source_deal_type_id 
		LEFT JOIN source_deal_type sdt2 ON sdt2.source_deal_type_id =  sdht.deal_sub_type_type_id
		LEFT JOIN source_uom su ON su.uom_id = idsr.[qty_units]
		INNER JOIN source_minor_location sml ON sml.location_id = idsr.[hub]
		LEFT JOIN  source_price_curve_def spcd  ON spcd.source_curve_def_id = sml.term_pricing_index
		LEFT JOIN source_commodity scd ON scd.source_commodity_id = sdht.commodity_id
		INNER JOIN source_traders st ON st.trader_id = idsr.[trader] 
		INNER JOIN source_counterparty sc_counterparty ON sc_counterparty.counterparty_id = idsr.[counterparty]
		OUTER APPLY (SELECT MAX(c.contract_id) contract_id FROM counterparty_contract_address c WHERE c.counterparty_id = sc_counterparty.source_counterparty_id) cont
		INNER JOIN contract_group cg ON cg.contract_id = cont.contract_id

		'

		EXEC (@sql)
	
		SET @job_name = 'Import_' + @process_id

		PRINT 'spa_import_data_job ''' + @staging_tbl_name + ''',4005, ''' + @job_name + ''','''+@process_id+''','''+ @user_login_id+''',''n'',12'

		EXEC ('spa_import_data_job ''' + @staging_tbl_name + ''',4005, ''' + @job_name + ''','''+@process_id+''','''+ @user_login_id+''',''n'',12' )

		-- updating formula_curve_id
		
		EXEC(' UPDATE sdd SET sdd.formula_curve_id = spcd.source_curve_def_id FROM ' + @stage_ice_deal + ' i
		INNER JOIN source_price_curve_def spcd ON spcd.curve_id = i.hub + '' '' + REVERSE(LEFT(REVERSE(i.product), CHARINDEX('' '', REVERSE(i.product)) - 1))
		INNER JOIN ' + @staging_tbl_name + ' s ON s.deal_id = i.deal_id		
		INNER JOIN source_deal_header sdh ON sdh.deal_id = s.deal_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		  ')
		
		-- pipeline  udf
		EXEC(' UPDATE uddf SET uddf.udf_value = sc.source_counterparty_id FROM ' + @stage_ice_deal + ' i
				INNER JOIN ( SELECT DISTINCT deal_id FROM ' + @staging_tbl_name + ' ) s ON s.deal_id = i.deal_id
				INNER JOIN source_deal_header sdh ON sdh.deal_id = s.deal_id
				INNER JOIN source_counterparty sc ON sc.counterparty_id = i.pipeline		
				INNER JOIN static_data_value sdv ON sdv.code = ''Pipeline'' AND sdv.type_id = 5500
				INNER JOIN user_defined_fields_template udft ON udft.field_name = sdv.value_id			
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = udft.field_name AND sdh.template_id = uddft.template_id
				INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
		')  
		
		EXEC('  INSERT INTO user_defined_deal_fields(source_deal_header_id, udf_template_id, udf_value)
				SELECT sdh.source_deal_header_id, uddft.udf_template_id, sc.source_counterparty_id FROM ' + @stage_ice_deal + ' i
				INNER JOIN ( SELECT DISTINCT deal_id FROM ' + @staging_tbl_name + ' ) s ON s.deal_id = i.deal_id
				INNER JOIN source_deal_header sdh ON sdh.deal_id = s.deal_id
				INNER JOIN source_counterparty sc ON sc.counterparty_id = i.pipeline		
				INNER JOIN static_data_value sdv ON sdv.code = ''Pipeline'' AND sdv.type_id = 5500
				INNER JOIN user_defined_fields_template udft ON udft.field_name = sdv.value_id			
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = udft.field_name AND sdh.template_id = uddft.template_id
				LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
				WHERE uddf.udf_deal_id IS NULL
		') 

	   -- state udf
	   	EXEC(' UPDATE uddf SET uddf.udf_value = sdv.value_id FROM ' + @stage_ice_deal + ' i
			   INNER JOIN ( SELECT DISTINCT deal_id FROM ' + @staging_tbl_name + ' ) s ON s.deal_id = i.deal_id
			   INNER JOIN source_deal_header sdh ON sdh.deal_id = s.deal_id
			   INNER JOIN static_Data_value sdv ON sdv.type_id = 10016 AND sdv.code = i.state	
			   INNER JOIN static_data_value sdv2 ON sdv2.code = ''State'' AND sdv2.type_id = 5500
			   INNER JOIN user_defined_fields_template udft ON udft.field_name = sdv2.value_id		
			   INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = udft.field_name AND sdh.template_id = uddft.template_id
			   INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id			   
		')  
		

		EXEC(' INSERT INTO user_defined_deal_fields(source_deal_header_id, udf_template_id, udf_value)
				SELECT sdh.source_deal_header_id, uddft.udf_template_id, sdv.value_id FROM ' + @stage_ice_deal + ' i
				INNER JOIN ( SELECT DISTINCT deal_id FROM ' + @staging_tbl_name + ' ) s ON s.deal_id = i.deal_id
				INNER JOIN source_deal_header sdh ON sdh.deal_id = s.deal_id
			    INNER JOIN static_Data_value sdv ON sdv.type_id = 10016 AND sdv.code = i.state	
				INNER JOIN static_data_value sdv2 ON sdv2.code = ''State'' AND sdv2.type_id = 5500
				INNER JOIN user_defined_fields_template udft ON udft.field_name = sdv2.value_id			
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = udft.field_name AND sdh.template_id = uddft.template_id
				LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh.source_deal_header_id AND uddf.udf_template_id = uddft.udf_template_id
				WHERE uddf.udf_deal_id IS NULL

		') 
		

	/*-----------------------------------------Total Deal vloume update for the imported deals ----------------------------------------------------------------------------*/	
			DECLARE @spa                    VARCHAR(1000)
				DECLARE @report_position_deals  VARCHAR(150)
    	
				SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
				PRINT @report_position_deals
				EXEC (
						 'CREATE TABLE ' + @report_position_deals + 
						 '( source_deal_header_id INT, action CHAR(1))'
					 )
    	
				SET @sql = 'INSERT INTO ' + @report_position_deals + 
						'(source_deal_header_id,action)
						SELECT DISTINCT source_deal_header_id ,''u''
						FROM ' +  @staging_tbl_name + ' t 
						INNER JOIN source_deal_header sdh 
							on t.deal_id = sdh.deal_id'
					
				EXEC (@sql)
    	
				SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(1000)) 
					+ ''''
			PRINT @spa
				SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
				EXEC spa_run_sp_as_job @job_name,
					 @spa,
					 'spa_update_deal_total_volume',
					 @user_login_id


			DECLARE @count INT 
			SELECT @count=COUNT(1) FROM source_system_data_import_status_detail WHERE process_id = @process_id AND ([type]='Error' OR [type]='Data Error'OR [type]='Data Warning')
			IF @count >0
			BEGIN
				SET @errorcode='e'
			END
			ELSE
			BEGIN
				SET @errorcode='s'
			END
			
			IF EXISTS(SELECT 1 FROM #error_deals_flag)
				SET @errorcode = 'e'
				
	END
	ELSE IF @error_code = 1
	BEGIN
		SET @errorcode = 'e'
		INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT  @process_id,'Error','Import Data','source_deal','Data Error','No File found','n/a'
	END
	END TRY
	BEGIN CATCH
		INSERT  INTO  source_system_data_import_status(process_id,code,module,source,type,[description],recommendation) 
		SELECT  @process_id,'Error','Import Data','source_deal','Data Error','Exception occured','n/a'
	
		INSERT  INTO  source_system_data_import_status_detail(process_id,source,type,[description]) 
		SELECT  @process_id,'source_deal','Data Error',ERROR_MESSAGE()
	
		SET @errorcode='e'
	END CATCH

	IF @error_code <> 0
		SET @errorcode = 'e'
		
	SELECT  @start_ts = ISNULL(MIN(create_ts),GETDATE()) FROM import_data_files_audit WHERE process_id = @process_id
	SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_login_id+''''
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + 
	'Import process Completed for Ice Deal for as of date:' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
	+ CASE WHEN (@errorcode = 'e') THEN ' (ERRORS found)' ELSE '' END 
	+ '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec.</a>' 
	
	UPDATE import_data_files_audit SET [status] = @errorcode, elapsed_time = @elapsed_sec --, imp_file_name = 'source_price_curve' + CASE WHEN @error_code = -1 THEN '(Manual)' ELSE '' END
	--, import_source = 'ixp_source_price_curve_template'
	 WHERE Process_ID = @process_id
		
	IF EXISTS( SELECT 1 FROM message_board WHERE process_id = @process_id) --removing default messaging for IceDeal specific messaging
		DELETE FROM message_board WHERE process_id = @process_id

	--EXEC  spa_message_board 'u', @user_login_id, NULL, 'Import Data', @desc, '', '', @errorcode, @job_name,null,@process_id
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc, @errorcode, @job_name, 1

 
END
