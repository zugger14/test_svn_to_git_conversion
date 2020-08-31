
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_ncrets_retirement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_ncrets_retirement]
GO

CREATE PROC [dbo].[spa_import_ncrets_retirement]
@temp_table_name	VARCHAR(100),
@process_id			VARCHAR(100),
@job_name			VARCHAR(100) = NULL,  
@file_name			VARCHAR(200) = NULL,
@user_login_id		VARCHAR(50)

AS

DECLARE @file_full_path VARCHAR(500), 
 @sql VARCHAR(MAX)

DECLARE @desc VARCHAR(1000),@error_code CHAR(1), @start_ts datetime

SELECT  @start_ts = isnull(min(create_ts),GETDATE()) from import_data_files_audit where process_id = @process_id

--SET @user_login_id = dbo.FNADBUser()

--SET  @file_full_path='\\lhotse\DB_Backup\Import test\NC RETS Retirement Import1.csv'
--SET  @file_full_path='d:\NC RETS Retirement Import (Multiple Generator).csv'

IF OBJECT_ID('tempdb.dbo.#tmp_dff') IS NOT NULL
DROP TABLE #tmp_dff

CREATE TABLE #tmp_dff (generator VARCHAR(1000) COLLATE DATABASE_DEFAULT, [monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT, volume VARCHAR(1000) COLLATE DATABASE_DEFAULT,
[member] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [percentage] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [cert from] VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
[cert to] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [compliance YEAR] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [sub-book1] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [sub-book2] VARCHAR(1000) COLLATE DATABASE_DEFAULT
)

EXEC('INSERT INTO #tmp_dff(generator , [monthly term] , volume ,
[member] , [percentage] , [cert from] , 
[cert to] , [compliance YEAR], [sub-book1], [sub-book2] )
SELECT generator , [monthly term] , volume ,
[member] , [percentage] , [cert from] , 
[cert to] , [compliance YEAR],  [sub-book1], [sub-book2] FROM ' + @temp_table_name)


--EXEC('
--BULK INSERT #tmp_dff
--		FROM '''+@file_full_path +'''
--		WITH 
--		( 
--			FIRSTROW = 2, 
--			FIELDTERMINATOR = '','', 
--			ROWTERMINATOR = ''\n'' 
--		)
--')



IF OBJECT_ID('tempdb.dbo.#tmp_final') IS NOT NULL
DROP TABLE #tmp_final

SELECT generator , [monthly term] , max(volume) volume ,
 [member] , MAX([percentage]) [percentage] , 
MAX([cert from]) [cert from] , 
MAX([cert to]) [cert to], [compliance YEAR], MAX([sub-book1]) [sub-book1], MAX([sub-book2]) [sub-book2]
INTO #tmp_final FROM #tmp_dff GROUP BY generator, member, [monthly term], [compliance YEAR]

--SELECT  *
--FROM    #tmp_final

IF OBJECT_ID('tempdb.dbo.#identified_deals') IS NOT NULL
DROP TABLE #identified_deals

SELECT 
sdh.counterparty_id,sdh.source_deal_header_id, sdd.source_deal_detail_id,sdd.settlement_uom, sdd.deal_volume_uom_id,
tf.volume , tf.[cert FROM], tf.[cert to], tf.[sub-book2], tf.[compliance YEAR]
INTO #identified_deals
  FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
CROSS APPLY(
	SELECT MAX(volume) Volume , MAX([cert FROM])[cert FROM], MAX([cert to])[cert to], MAX([sub-book2]) [sub-book2], [compliance YEAR] FROM
		#tmp_final tf WHERE tf.generator = rg.id AND sdh.entire_term_start = tf.[monthly term]
		group by tf.[compliance year] 
	) tf
WHERE
	sdd.buy_sell_flag ='b'
	AND sdh.assignment_type_value_id IS NULL
	AND sdh.close_reference_id IS NULL
	AND tf.[cert FROM] IS NOT NULL
	--AND sdh.counterparty_id = fs.counterparty_id
--select * from fas_subsidiaries
--update fas_subsidiaries set counterparty_id =25  where fas_subsidiary_id=11





DECLARE @process_table VARCHAR(300)
--SET @process_id=dbo.FNAGetNewID()
SET @process_table = dbo.FNAProcessTableName('process_table', @user_login_id,@process_id)

SET @sql = 'CREATE TABLE ' + @process_table + '([ID] INT,[Volume Assign] float, [cert_from] varchar(1000), 
[cert_to] varchar(1000), uom int, deal_volume_uom_id int, compliance_year varchar(1000))'
EXEC spa_print @sql
EXEC(@sql)


set @sql = 'INSERT INTO ' + @process_table + '
([ID], [Volume Assign], [cert_from], [cert_to], uom, deal_volume_uom_id, compliance_year ) 
select source_deal_detail_id, volume, 1, volume, deal_volume_uom_id, deal_volume_uom_id, [compliance year]
	from #identified_deals '
EXEC spa_print @sql
EXEC(@sql)


DECLARE @delete_deals_table VARCHAR(100), @process_id2 VARCHAR(100)
SET @process_id2 = dbo.FNAGetNewID()      
SET @delete_deals_table = dbo.FNAProcessTableName('delete_deals', @user_login_id,@process_id2)

EXEC('SELECT 
sdh.source_deal_header_id,CAST(NULL AS VARCHAR(10)) [Status],CAST(NULL AS VARCHAR(500)) [description]
INTO '+@delete_deals_table+'
  FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
INNER JOIN #tmp_final tf ON tf.[compliance YEAR] = sdh.compliance_year
and tf.generator = rg.id
WHERE sdh.assignment_type_value_id IS NOT NULL group by sdh.source_deal_header_id')
      
exec spa_sourcedealheader 'd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@process_id2

BEGIN TRAN
BEGIN TRY 

declare @compliance_year VARCHAR(100), @assigned_date DATETIME , @inserted_source_deal_header_id VARCHAR(MAX),
 @inserted_source_deal_detail_id VARCHAR(MAX), @book_deal_type_map_id INT 
SELECT @compliance_year =  [compliance YEAR] FROM #tmp_final
SELECT @assigned_date = dbo.fnastddate(CAST('12-31-'+@compliance_year AS DATETIME))

SELECT @book_deal_type_map_id = max(book_deal_type_map_id) FROM source_system_book_map ssbm
INNER JOIN #tmp_final tf ON tf.[sub-book1] = ssbm.logical_name


EXEC spa_assign_rec_deals
NULL,
5146, -- Assignment_type
293423,-- static_data_value for the state
@compliance_year, -- compliance year from the file
@assigned_date, -- year end of complaince year
NULL,
NULL,
NULL,
@process_table,
0, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,@book_deal_type_map_id ,NULL,
7,NULL,
@inserted_source_deal_header_id = @inserted_source_deal_header_id OUTPUT




	IF OBJECT_ID('tempdb..#deal_header') IS NOT NULL
	DROP TABLE #deal_header

	CREATE TABLE #deal_header([source_system_id] [int] ,[deal_id] [varchar](50) COLLATE DATABASE_DEFAULT ,[deal_date] [datetime] ,[physical_financial_flag] [char](10) COLLATE DATABASE_DEFAULT ,
					[counterparty_id] [int] ,[entire_term_start] [datetime] ,[entire_term_end] [datetime] ,[source_deal_type_id] [int] ,
					[deal_sub_type_type_id] [int],[option_flag] [char](1) COLLATE DATABASE_DEFAULT ,[option_type] [char](1) COLLATE DATABASE_DEFAULT,[option_excercise_type] [char](1) COLLATE DATABASE_DEFAULT,[source_system_book_id1] [int] ,
					[source_system_book_id2] [int],[source_system_book_id3] [int],[source_system_book_id4] [int],[description1] [varchar](100) COLLATE DATABASE_DEFAULT,[description2] [varchar](50) COLLATE DATABASE_DEFAULT,[description3] [varchar](50) COLLATE DATABASE_DEFAULT,
					[deal_category_value_id] [int] ,[trader_id] [int] ,[internal_deal_type_value_id] [int],[internal_deal_subtype_value_id] [int],[template_id] [int],[header_buy_sell_flag] [varchar](1) COLLATE DATABASE_DEFAULT,
					[generator_id] [int],[assignment_type_value_id] [int],[compliance_year] [int],[state_value_id] [int],[assigned_date] [datetime],[assigned_by] [varchar](50) COLLATE DATABASE_DEFAULT,
					ssb_offset1 [int],ssb_offset2 [int],ssb_offset3 [int],ssb_offset4 [int],source_deal_header_id INT,structured_deal_id VARCHAR(100) COLLATE DATABASE_DEFAULT, close_reference_id [int]				
	)

	IF OBJECT_ID('tempdb..#deal_detail') IS NOT NULL
	DROP TABLE #deal_detail

	CREATE TABLE #deal_detail([source_deal_header_id] [int],[term_start] [datetime],[term_end] [datetime],[leg] [int],[contract_expiration_date] [datetime],
		[fixed_float_leg] [char](1) COLLATE DATABASE_DEFAULT,[buy_sell_flag] [char](1) COLLATE DATABASE_DEFAULT,[curve_id] [int],[fixed_price] [float],[fixed_cost] [float],[fixed_price_currency_id] [int],
		[option_strike_price] [float],[deal_volume] NUMERIC(38,20),[deal_volume_frequency] [char](1) COLLATE DATABASE_DEFAULT,[deal_volume_uom_id] [int],[block_description] [varchar](100) COLLATE DATABASE_DEFAULT,
		[deal_detail_description] [varchar](100) COLLATE DATABASE_DEFAULT,[formula_id] [int],[settlement_volume] NUMERIC(38,20),[settlement_uom] [int],source_deal_detail_id INT, capacity float
	)
	
			SET @inserted_source_deal_header_id = case when @inserted_source_deal_header_id = '' THEN '-1' ELSE @inserted_source_deal_header_id END 
				
		 
		SET @sql='
		INSERT INTO source_deal_header
			(source_system_id, deal_id, deal_date,  physical_financial_flag, counterparty_id, entire_term_start, entire_term_end, 
			source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
			source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, 
			trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,generator_id,
			contract_id,structured_deal_id,close_reference_id,deal_locked, assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by
			)
		OUTPUT Inserted.source_system_id,Inserted.deal_id,Inserted.deal_date,Inserted.physical_financial_flag,Inserted.counterparty_id,Inserted.entire_term_start,Inserted.entire_term_end,Inserted.source_deal_type_id,Inserted.deal_sub_type_type_id,Inserted.option_flag,Inserted.option_type,Inserted.option_excercise_type,Inserted.source_system_book_id1,Inserted.source_system_book_id2,Inserted.source_system_book_id3,Inserted.source_system_book_id4,Inserted.description1,Inserted.description2,Inserted.description3,Inserted.deal_category_value_id,Inserted.trader_id,Inserted.internal_deal_type_value_id,Inserted.internal_deal_subtype_value_id,Inserted.template_id,Inserted.header_buy_sell_flag,Inserted.generator_id,Inserted.assignment_type_value_id,Inserted.compliance_year,Inserted.state_value_id,Inserted.assigned_date,Inserted.assigned_by,
		Inserted.source_system_book_id1,Inserted.source_system_book_id2,Inserted.source_system_book_id3,Inserted.source_system_book_id4,inserted.source_deal_header_id,inserted.structured_deal_id org_deal_id, inserted.close_reference_id
		INTO #deal_header
		SELECT  sdh.source_system_id,
			CASE WHEN rga.auto_assignment_type = 5181 THEN ''Offset-'' +  cast(sdh.source_deal_header_id as varchar)  + ''-'' + cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (sdh.source_deal_header_id))),1) as varchar)
			ELSE cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (sdh.source_deal_header_id))),1) as varchar)+''-farrms'' END, 
			deal_date,  sdh.physical_financial_flag, 
			ISNULL(rga.counterparty_id,sdh.counterparty_id),
			entire_term_start, entire_term_end, 
			sdh.source_deal_type_id, sdh.deal_sub_type_type_id, option_flag, option_type, option_excercise_type, 
			isnull(ssbm1.source_system_book_id1,sdh.source_system_book_id1),
			isnull(ssbm1.source_system_book_id2,sdh.source_system_book_id2), 
			isnull(ssbm1.source_system_book_id3,sdh.source_system_book_id3),
			isnull(ssbm1.source_system_book_id4,sdh.source_system_book_id4), description1, description2, description3, sdh.deal_category_value_id, 
			ISNULL(rga.trader_id,sdh.trader_id),internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,
			CASE WHEN sdh.header_buy_sell_flag = ''b'' THEN ''s'' ELSE ''b'' END,
			sdh.generator_id,
			sdh.contract_id, CAST(sdh.source_deal_header_id AS VARCHAR)+''-''+CAST(ISNULL(rga.generator_assignment_id,0) AS VARCHAR) org_deal_id,
			sdh.source_deal_header_id,''y''	, sdh.assignment_type_value_id, sdh.compliance_year, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by			
		FROM 	 
			source_deal_header sdh 
			INNER JOIN dbo.SplitCommaSeperatedValues(''' + @inserted_source_deal_header_id + ''') scsv 
				ON scsv.Item = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = scsv.item 
			INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd2.source_deal_detail_id
			INNER JOIN #identified_deals id ON id.source_deal_detail_id = aa.source_deal_header_id_from
			INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
			LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			LEFT JOIN source_system_book_map ssbm1 ON ssbm1.logical_name = id.[sub-book2]	
			LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = ISNULL(ssbm1.fas_book_id,ssbm.fas_book_id)
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
			LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id
		WHERE rga.auto_assignment_type is NOT NULL
		' 				
		EXEC spa_print @sql
		EXEC(@sql)

		
		SET @sql='
			INSERT INTO source_deal_detail(
				source_deal_header_id,
				term_start,
				term_end,
				leg,
				contract_expiration_date,
				fixed_float_leg,
				buy_sell_flag,
				curve_id,
				fixed_price,
				fixed_cost,
				fixed_price_currency_id,
				option_strike_price,
				deal_volume,
				deal_volume_frequency,
				deal_volume_uom_id,
				block_description,
				deal_detail_description,
				formula_id,
				settlement_volume,
				settlement_uom,
				capacity
			)
			OUTPUT Inserted.source_deal_header_id,Inserted.term_start,Inserted.term_end,Inserted.leg,Inserted.contract_expiration_date,Inserted.fixed_float_leg,Inserted.buy_sell_flag,Inserted.curve_id,Inserted.fixed_price,Inserted.fixed_cost,Inserted.fixed_price_currency_id,Inserted.option_strike_price,Inserted.deal_volume,Inserted.deal_volume_frequency,Inserted.deal_volume_uom_id,Inserted.block_description,Inserted.deal_detail_description,Inserted.formula_id,Inserted.settlement_volume,Inserted.settlement_uom,inserted.source_deal_detail_id, inserted.capacity
			INTO #deal_detail
			select dh.source_deal_header_id,
				sdd.term_start,
				sdd.term_end,
				sdd.leg,
				sdd.term_end,
				sdd.fixed_float_leg,
				dh.header_buy_sell_flag,
				isnull(rg.source_curve_def_id,sdd.curve_id),
				sdd.fixed_price,
				sdd.fixed_cost,
				sdd.fixed_price_currency_id,
				sdd.option_strike_price,
				CASE WHEN rga.auto_assignment_type = 5181 THEN sdd.deal_volume * CAST(COALESCE(tf.percentage,rga.auto_assignment_per,1) AS NUMERIC(18,10))
				ELSE sdd.deal_volume * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10)) END,
				sdd.deal_volume_frequency,
				sdd.deal_volume_uom_id deal_volume_uom_id,
				sdd.block_description,
				sdd.deal_detail_description,
				sdd.formula_id,
				sdd.deal_volume,
				sdd.deal_volume_uom_id,
				sdd.capacity * CAST(COALESCE(tf.percentage,rga.auto_assignment_per,1) AS NUMERIC(18,10))
			FROM 
				#deal_header dh
				INNER JOIN rec_generator rg ON rg.generator_id=dh.generator_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX(''-'',dh.structured_deal_id,0)) AS INT)
				INNER JOIN rec_generator_assignment rga ON rga.generator_id=dh.generator_id
					AND rga.generator_assignment_id = CAST(SUBSTRING(dh.structured_deal_id,CHARINDEX(''-'',dh.structured_deal_id,0)+1,LEN(dh.structured_deal_id)) AS INT)	
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = rga.counterparty_id
				INNER JOIN #tmp_final tf ON tf.generator = rg.id
					  AND dh.entire_term_start = tf.[monthly term] 
					  AND sc.counterparty_name = tf.member				
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				'
		EXEC(@sql)
		
	
		
	IF OBJECT_ID('tempdb..#offset_source_deal_header_id') IS NOT NULL
	DROP TABLE #offset_source_deal_header_id

	CREATE TABLE #offset_source_deal_header_id (source_deal_header_id INT)
	
	--SELECT * FROM #deal_header
	
			
	
		INSERT INTO source_deal_header(source_system_id, deal_id, deal_date,  physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, 
				source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
				source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, 
				trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,generator_id,
				close_reference_id,contract_id, deal_locked, assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by
		) OUTPUT INSERTED.source_deal_header_id INTO #offset_source_deal_header_id
		SELECT 
				dh.source_system_id, CASE WHEN rga.auto_assignment_type = 5181 THEN 'Allocated-'+CAST(dh.source_deal_header_id AS VARCHAR)
				ELSE 'Offset-'+CAST(dh.source_deal_header_id AS VARCHAR) END,dh.deal_date,dh.physical_financial_flag,dh.structured_deal_id,
				--ISNULL(rga.counterparty_id,sdh.counterparty_id),
				ISNULL(fs.counterparty_id,sdh.counterparty_id),
				dh.entire_term_start,dh.entire_term_end,
				dh.source_deal_type_id,dh.deal_sub_type_type_id,dh.option_flag,dh.option_type,dh.option_excercise_type,
				ISNULL(ssbm1.source_system_book_id1,sdh.source_system_book_id1),ISNULL(ssbm1.source_system_book_id2,sdh.source_system_book_id2),ISNULL(ssbm1.source_system_book_id3,sdh.source_system_book_id3),ISNULL(ssbm1.source_system_book_id4,sdh.source_system_book_id4),dh.description1,dh.description2,dh.description3,dh.deal_category_value_id,dh.trader_id,dh.internal_deal_type_value_id,
				dh.internal_deal_subtype_value_id,dh.template_id,CASE WHEN sdh.header_buy_sell_flag = 'b' THEN 's' ELSE 'b' END,dh.generator_id,sdh.source_deal_header_id,sdh.contract_id, 'y', sdh.assignment_type_value_id, sdh.compliance_year, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by
		FROM
			#deal_header dh
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=dh.source_deal_header_id
			
			INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX('-',dh.structured_deal_id,0)) AS INT)
				INNER JOIN rec_generator_assignment rga ON rga.generator_id=dh.generator_id
				AND rga.generator_assignment_id = CAST(SUBSTRING(dh.structured_deal_id,CHARINDEX('-',dh.structured_deal_id,0)+1,LEN(dh.structured_deal_id)) AS INT)
			LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = rga.source_book_map_id
			LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh1.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh1.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh1.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh1.source_system_book_id4
			LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = ISNULL(ssbm1.fas_book_id,ssbm.fas_book_id)
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
			LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id	

		WHERE
			rga.source_book_map_id IS NOT NULL
				
		
		INSERT INTO source_deal_detail(source_deal_header_id,term_start,term_end,leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,
				fixed_cost,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,
				deal_detail_description,formula_id,settlement_volume,settlement_uom, capacity)
		SELECT
			sdh.source_deal_header_id,dd.term_start,dd.term_end,dd.leg,dd.contract_expiration_date,dd.fixed_float_leg,
			CASE WHEN dd.buy_sell_flag = 'b' THEN 's' ELSE 'b' END, isnull(rg.source_curve_def_id,dd.curve_id), dd.fixed_price,
			dd.fixed_cost,dd.fixed_price_currency_id,dd.option_strike_price,dd.deal_volume,dd.deal_volume_frequency,dd.deal_volume_uom_id,dd.block_description,
			dd.deal_detail_description,dd.formula_id,dd.settlement_volume,dd.settlement_uom, dd.capacity
		FROM
			#deal_detail dd
			INNER JOIN #deal_header dh ON dh.source_deal_header_id=dd.source_deal_header_id
			INNER JOIN source_deal_header sdh ON sdh.close_reference_id=dh.source_deal_header_id
			INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id


	COMMIT 
	--ROLLBACK 
INSERT INTO source_system_data_import_status
    	      (
    	        [source],
    	        process_id,
    	        code,
    	        module,
    	        [type],
    	        [description],
    	        recommendation
    	      )
			SELECT DISTINCT td.generator,
				@process_id,
				'Success',
				'Import NCRETS Data',
				'Success',
				'NCRETS Retirement for generator ' + td.generator + ' for term ' + td.[monthly term] + ', volume ' + max(td.volume) + ' imported for File:',
				''
			FROM #tmp_dff td  
			GROUP BY td.generator,td.[monthly term]   	


declare @url VARCHAR(MAX)
		
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
       '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id 
       + ''''
declare @elapsed_sec float 
      
 SET @elapsed_sec = DATEDIFF(second, @start_ts, GETDATE())

SELECT @desc = '<a target="_blank" href="' + @url + '">' +
       'NCRETS Retirement Data Imported Successfully' +'</a>'+ ' '+
       '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(100)) + ' sec </a>'
      
set @error_code ='s'

END TRY
BEGIN CATCH
	--EXEC spa_print 'error' +ERROR_MESSAGE()
	SET @error_code = 'e'
	SET @desc ='Unable to complete NCRETS Retirement Data Import'
	ROLLBACK 
END CATCH

EXEC spa_NotificationUserByRole 2, @process_id, 'REC Actual Data Import', @desc , @error_code, @job_name, 1

--updating using flag 'e' which automatically calculate the estimated time.
EXEC spa_import_data_files_audit
     @flag = 'e',
     @process_id = @process_id,
     @status = @error_code
GO


