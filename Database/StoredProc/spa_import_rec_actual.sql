
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_rec_actual]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_rec_actual]
GO

CREATE PROC [dbo].[spa_import_rec_actual]
@temp_table_name	VARCHAR(100),
@process_id			VARCHAR(100),
@job_name			VARCHAR(100) = NULL,  
@file_name			VARCHAR(200) = NULL,
@user_login_id		VARCHAR(50)

AS

DECLARE @file_full_path VARCHAR(500),  
 @sql VARCHAR(MAX), @book_deal_type_map_id INT, @template_id INT--, @user_login_id VARCHAR(100), @process_id VARCHAR(100),@job_name VARCHAR(100)

DECLARE @desc VARCHAR(1000),@error_code CHAR(1), @start_ts DATETIME

--SET @process_id = REPLACE(NEWID(),'-','_')

SELECT  @start_ts = isnull(min(create_ts),GETDATE()) from import_data_files_audit where process_id = @process_id

SET @template_id =  9 -- --6 -- 391 -- 5
--SET @book_deal_type_map_id =  4 -- --4 -- 321 -- 8
--SET @user_login_id = dbo.FNADBUser()

--SET  @file_full_path='\\lhotse\DB_Backup\Import test\REC import file with EE Costs.csv'
--SET  @file_full_path='d:\Hydro import final.csv'

IF OBJECT_ID('tempdb.dbo.#tmp_dff') IS NOT NULL
DROP TABLE #tmp_dff

CREATE TABLE #tmp_dff (generator VARCHAR(1000) COLLATE DATABASE_DEFAULT, [monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT, volume VARCHAR(1000) COLLATE DATABASE_DEFAULT,
[contract volume] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [invoice volume] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [price] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [cert from] VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
[cert to] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [Utility Cost] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [Participant Cost] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [Total Resource Cost] VARCHAR(1000) COLLATE DATABASE_DEFAULT
,[logical book name] VARCHAR(1000) COLLATE DATABASE_DEFAULT)

EXEC('INSERT INTO #tmp_dff(generator , [monthly term] , volume ,
[contract volume] , [invoice volume] , [price] , [cert from] , 
[cert to] , [Utility Cost] , [Participant Cost] , [Total Resource Cost], [logical book name])
select generator , [monthly term] , volume ,
[contract volume] , [invoice volume] , [price] , [cert from] , 
[cert to] , [Utility Cost] , [Participant Cost] , [Total Resource Cost], [Sub-Book1]
from ' + @temp_table_name )


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
--RETURN 
--SELECT  *
--FROM    #tmp_dff
--RETURN 
IF OBJECT_ID('tempdb..#tmp_dff2') is NOT NULL
DROP TABLE #tmp_dff2

CREATE TABLE #tmp_dff2(row_no VARCHAR(100) COLLATE DATABASE_DEFAULT, generator VARCHAR(1000) COLLATE DATABASE_DEFAULT, [monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT, volume VARCHAR(1000) COLLATE DATABASE_DEFAULT,
[contract volume] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [invoice volume] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [price] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [cert from] VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
[cert to] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [book_deal_type_map_id] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [Participant Cost] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [Total Resource Cost] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [Utility Cost] VARCHAR(1000) COLLATE DATABASE_DEFAULT
,[logical book name] VARCHAR(1000) COLLATE DATABASE_DEFAULT)
INSERT INTO #tmp_dff2(row_no , generator , [monthly term] , volume ,
[contract volume] , [invoice volume] , [price] , [cert from] , 
[cert to],  [Participant Cost] , [Total Resource Cost] , [Utility Cost], [logical book name] )
SELECT '__farrms__' + cast(ROW_NUMBER() OVER(ORDER BY [cert FROM]) AS VARCHAR), generator , [monthly term] , volume ,
[contract volume] , [invoice volume] , [price] , [cert from] , 
[cert to],  [Participant Cost] , [Total Resource Cost] , [Utility Cost], [logical book name] FROM #tmp_dff

--SELECT * FROM #tmp_dff2
--RETURN 

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
INNER JOIN #tmp_dff2 tmp ON tmp.generator = rg.id
      AND tmp.[monthly term] = sdd.term_start ')
      
exec spa_sourcedealheader 'd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@process_id2

delete udddf
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	INNER JOIN #tmp_dff2 tmp ON tmp.generator = rg.id
      AND tmp.[monthly term] = sdd.term_start
	INNER JOIN user_defined_deal_detail_fields udddf on udddf.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = udddf.udf_template_id
	WHERE uddft.field_label IN ('invoice volume','Participant Cost', 'Total Resource Cost', 'Utility Cost')
	AND uddft.template_id = @template_id

BEGIN TRAN
BEGIN TRY

	
	IF OBJECT_ID('tempdb..#inserted_source_deal_header_id') is NOT NULL
	DROP TABLE #inserted_source_deal_header_id
	CREATE TABLE #inserted_source_deal_header_id(source_deal_header_id INT, row_no VARCHAR(100) COLLATE DATABASE_DEFAULT)
	
	insert into source_deal_header (deal_id, physical_financial_flag, option_flag, option_type, 
	 description1, description2, description3, header_buy_sell_flag, source_deal_type_id, 
	deal_sub_type_type_id,   internal_deal_type_value_id, internal_deal_subtype_value_id, 
	deal_status, deal_category_value_id, 
	legal_entity, commodity_id, internal_portfolio_id, product_id, internal_desk_id, block_type, block_define_id, 
	granularity_id, Pricing,  
	contract_id, counterparty_id, deal_rules, confirm_rule, trader_id, 
	source_system_id, deal_date, ext_deal_id, structured_deal_id, 
	entire_term_start, entire_term_end, option_excercise_type, broker_id, generator_id, status_value_id, 
	status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, 
	generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, 
	rolling_avg, reference, deal_locked, close_reference_id, deal_reference_type_id, unit_fixed_flag, 
	broker_unit_fees, broker_fixed_cost, broker_currency_id, term_frequency, option_settlement_date, 
	verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, 
	back_office_sign_off_date, book_transfer_id, confirm_status_type, source_system_book_id1,
	source_system_book_id2, source_system_book_id3, source_system_book_id4,template_id)

	OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id
	INTO #inserted_source_deal_header_id(source_deal_header_id, row_no)
	SELECT '__farrms__' + CAST( ROW_NUMBER() OVER( ORDER BY source_deal_header_id) AS VARCHAR), physical_financial_flag, option_flag, option_type, 
	 description1, description2, description3, header_buy_sell_flag, source_deal_type_id, 
	deal_sub_type_type_id,   internal_deal_type_value_id, internal_deal_subtype_value_id, 
	5605, deal_category_value_id, 
	legal_entity, commodity_id, internal_portfolio_id, product_id, internal_desk_id, block_type, block_define_id, 
	granularity_id, Pricing,  
	isnull(rg.ppa_contract_id,contract_id), isnull(rg.ppa_counterparty_id,counterparty_id), deal_rules, confirm_rule, trader_id, 
	source_system_id, CASE WHEN dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) <= GETDATE() THEN dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) ELSE GETDATE() END deal_date, ext_deal_id, structured_deal_id, 
	dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) entire_term_start,  CAST (cast(YEAR(td.[monthly term]) AS VARCHAR)+ '-' +  cast(MONTH(td.[monthly term]) AS VARCHAR)+ '-' + CAST(dbo.FNALastDayInMonth(td.[monthly term]) AS VARCHAR) AS DATETIME) entire_term_end, option_excercise_type, broker_id, rg.generator_id, status_value_id, 
	status_date, assignment_type_value_id, compliance_year, sdht.state_value_id, assigned_date, assigned_by, 
	generation_source, sdht.aggregate_environment, sdht.aggregate_envrionment_comment, sdht.rec_price, sdht.rec_formula_id, 
	rolling_avg, reference, deal_locked, close_reference_id, deal_reference_type_id, unit_fixed_flag, 
	broker_unit_fees, broker_fixed_cost, broker_currency_id, term_frequency, option_settlement_date, 
	verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, 
	back_office_sign_off_date, book_transfer_id, confirm_status_type, ssbm.source_system_book_id1,
	ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4, @template_id
	FROM source_deal_header_template sdht CROSS JOIN #tmp_dff2 td 
	INNER JOIN rec_generator rg ON rg.id = td.generator
	INNER JOIN source_system_book_map ssbm ON ssbm.logical_name = td.[logical book name]
	WHERE sdht.template_id = @template_id 
		

	UPDATE sdh SET sdh.deal_id = cast(isdh.source_deal_header_id AS VARCHAR) + '-farrms' 
	FROM source_deal_header sdh
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	
	
	
	 
	insert into source_deal_detail (source_deal_header_id,leg, fixed_float_leg, buy_sell_flag, curve_id, deal_volume_frequency,
	deal_volume_uom_id,  block_description,   
	day_count_id, physical_financial_flag, location_id, meter_id, pay_opposite, 
	settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party,
	adder_currency_id, booked, deal_detail_description, fixed_cost,
	fixed_cost_currency_id, formula_currency_id, formula_curve_id, formula_id, multiplier,
	option_strike_price, price_adder, price_adder_currency2, price_adder2, price_multiplier,
	process_deal_status, settlement_date, settlement_uom, settlement_volume,
	volume_left, volume_multiplier2, term_start, term_end, contract_expiration_date, 
	fixed_price_currency_id, deal_volume, capacity, fixed_price)

	SELECT isdh.source_deal_header_id, leg, fixed_float_leg, buy_sell_flag, isnull(rg.source_curve_def_id, curve_id), deal_volume_frequency,
	deal_volume_uom_id, block_description,  
	 day_count_id, sddt.physical_financial_flag, sddt.location_id, meter_id, pay_opposite, 
	settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party,
	adder_currency_id, booked, deal_detail_description, fixed_cost,
	fixed_cost_currency_id, formula_currency_id, formula_curve_id, formula_id, multiplier,
	option_strike_price, price_adder, price_adder_currency2, price_adder2, price_multiplier,
	process_deal_status, settlement_date, settlement_uom, settlement_volume,
	volume_left, volume_multiplier2, dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) term_start, CAST (cast(YEAR(td.[monthly term]) AS VARCHAR)+ '-' +  cast(MONTH(td.[monthly term]) AS VARCHAR)+ '-' + CAST(dbo.FNALastDayInMonth(td.[monthly term]) AS VARCHAR) AS DATETIME) term_end, CAST (cast(YEAR(td.[monthly term]) AS VARCHAR)+ '-' +  cast(MONTH(td.[monthly term]) AS VARCHAR)+ '-' + CAST(dbo.FNALastDayInMonth(td.[monthly term]) AS VARCHAR) AS DATETIME) contract_expiration_date, 
	fixed_price_currency_id, isnull(td.volume,td.[contract volume]), td.[contract volume], td.[price]
	FROM source_deal_detail_template sddt 
	INNER JOIN source_deal_header_template sdht ON sddt.template_id = sdht.template_id
	CROSS JOIN #tmp_dff2 td 
	INNER JOIN rec_generator rg ON rg.id = td.generator
	--INNER JOIN source_deal_header sdh ON sdh.template_id = sdht.template_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.row_no = td.row_no
	WHERE sddt.template_id = @template_id 

	DECLARE @report_position_deals VARCHAR(300), @process_id3 VARCHAR(300)
	SET @process_id3 = REPLACE(newid(),'-','_')
	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id3)

	--exec('IF OBJECT_ID(' + @report_position_deals + ') is not null
	--DROP TABLE ' + @report_position_deals )
	EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
	SELECT source_deal_header_id,''i'' from #inserted_source_deal_header_id'
	EXEC(@sql)

	IF OBJECT_ID('tempdb..#report_position_deals') IS NOT NULL
	DROP TABLE #report_position_deals

	CREATE TABLE #report_position_deals(source_deal_header_id INT, ACTION VARCHAR(100) COLLATE DATABASE_DEFAULT)

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
				

				
	SET @sql = 'INSERT INTO #report_position_deals SELECT source_deal_header_id,''i'' from #inserted_source_deal_header_id'
	EXEC(@sql)


		SET @sql='
		INSERT INTO source_deal_header
			(source_system_id, deal_id, deal_date,  physical_financial_flag, counterparty_id, entire_term_start, entire_term_end, 
			source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
			source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, 
			trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,generator_id,
			contract_id,structured_deal_id,close_reference_id,deal_locked,deal_status
			)
		OUTPUT Inserted.source_system_id,Inserted.deal_id,Inserted.deal_date,Inserted.physical_financial_flag,Inserted.counterparty_id,Inserted.entire_term_start,Inserted.entire_term_end,Inserted.source_deal_type_id,Inserted.deal_sub_type_type_id,Inserted.option_flag,Inserted.option_type,Inserted.option_excercise_type,Inserted.source_system_book_id1,Inserted.source_system_book_id2,Inserted.source_system_book_id3,Inserted.source_system_book_id4,Inserted.description1,Inserted.description2,Inserted.description3,Inserted.deal_category_value_id,Inserted.trader_id,Inserted.internal_deal_type_value_id,Inserted.internal_deal_subtype_value_id,Inserted.template_id,Inserted.header_buy_sell_flag,Inserted.generator_id,Inserted.assignment_type_value_id,Inserted.compliance_year,Inserted.state_value_id,Inserted.assigned_date,Inserted.assigned_by,
		Inserted.source_system_book_id1,Inserted.source_system_book_id2,Inserted.source_system_book_id3,Inserted.source_system_book_id4,inserted.source_deal_header_id,inserted.structured_deal_id org_deal_id, inserted.close_reference_id
		INTO #deal_header([source_system_id]  ,[deal_id]  ,[deal_date]  ,[physical_financial_flag]  ,
					[counterparty_id]  ,[entire_term_start]  ,[entire_term_end]  ,[source_deal_type_id]  ,
					[deal_sub_type_type_id] ,[option_flag]  ,[option_type] ,[option_excercise_type] ,[source_system_book_id1]  ,
					[source_system_book_id2] ,[source_system_book_id3] ,[source_system_book_id4] ,[description1] ,[description2] ,[description3] ,
					[deal_category_value_id]  ,[trader_id]  ,[internal_deal_type_value_id] ,[internal_deal_subtype_value_id] ,[template_id] ,[header_buy_sell_flag] ,
					[generator_id] ,[assignment_type_value_id] ,[compliance_year] ,[state_value_id] ,[assigned_date] ,[assigned_by] ,
					ssb_offset1 ,ssb_offset2 ,ssb_offset3 ,ssb_offset4 ,source_deal_header_id ,structured_deal_id , close_reference_id )
		SELECT  sdh.source_system_id,
			CASE WHEN rga.auto_assignment_type IN (5146,5148) THEN ''Assigned-'' +  cast(td.source_deal_header_id as varchar)  + ''-'' + cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)
			 WHEN rga.auto_assignment_type = 5181 THEN ''Offset-'' +  cast(td.source_deal_header_id as varchar)  + ''-'' + cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)
			ELSE cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)+''-farrms'' END, 
			deal_date,  physical_financial_flag, 
			ISNULL(rga.counterparty_id,sdh.counterparty_id),
			--25, -- greenco
			entire_term_start, entire_term_end, 
			sdh.source_deal_type_id, sdh.deal_sub_type_type_id, option_flag, option_type, option_excercise_type, 
			CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id1
			 ELSE isnull(ssbm1.source_system_book_id1,ssbm.source_system_book_id1) END,
			CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id2
			ELSE isnull(ssbm1.source_system_book_id2,ssbm.source_system_book_id2) END, 
			CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id3
			ELSE isnull(ssbm1.source_system_book_id3,ssbm.source_system_book_id3) END,
			CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id4
			ELSE isnull(ssbm1.source_system_book_id4,ssbm.source_system_book_id4) END,
			description1, description2, description3, sdh.deal_category_value_id, 
			ISNULL(rga.trader_id,sdh.trader_id),internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,''s'',sdh.generator_id,
			ISNULL(rga.contract_id,sdh.contract_id), CAST(sdh.source_deal_header_id AS VARCHAR)+''-''+CAST(ISNULL(rga.generator_assignment_id,0) AS VARCHAR) org_deal_id,
			td.source_deal_header_id,''y'',5605		
		FROM #report_position_deals td	 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
			INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
			LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = rga.source_book_map_offset	
			LEFT JOIN source_system_book_map ssbm2 ON ssbm2.book_deal_type_map_id = rga.source_book_map_id
			LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			--INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = 5
			LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = ISNULL(ssbm1.fas_book_id,ssbm.fas_book_id)
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
			LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id
		WHERE ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) is NOT NULL' 				

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
				''s'',
				isnull(rg.source_curve_def_id,sdd.curve_id),
				sdd.fixed_price,
				sdd.fixed_cost,
				sdd.fixed_price_currency_id,
				sdd.option_strike_price,
				CASE WHEN rga.auto_assignment_type = 5181 THEN sdd.deal_volume * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10))
				ELSE sdd.deal_volume * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10)) END,
				sdd.deal_volume_frequency,
				sdd.deal_volume_uom_id deal_volume_uom_id,
				sdd.block_description,
				sdd.deal_detail_description,
				sdd.formula_id,
				sdd.deal_volume,
				sdd.deal_volume_uom_id,
				CASE WHEN rga.auto_assignment_type = 5181 THEN sdd.capacity * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10))
				ELSE sdd.capacity END				
			FROM 
				#deal_header dh
				INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX(''-'',dh.structured_deal_id,0)) AS INT)
				INNER JOIN rec_generator_assignment rga ON rga.generator_id=dh.generator_id
					AND rga.generator_assignment_id = CAST(SUBSTRING(dh.structured_deal_id,CHARINDEX(''-'',dh.structured_deal_id,0)+1,LEN(dh.structured_deal_id)) AS INT)	
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id					
			WHERE sdd.buy_sell_flag=''b'''
		EXEC(@sql)
	
	DECLARE @auto_assignment_type2 INT, @deal_volume2 float, @source_deal_detail_id3 INT, @source_deal_detail_id_from2 INT, @deal_date2 varchar(100),
			@state_value_id2 INT, @assigned_date2 datetime, @cert_to2 float
	
			DECLARE cur_status2 CURSOR LOCAL FOR
				SELECT 
				max(rga.auto_assignment_type),
				max(dd.deal_volume),
				dd.source_deal_detail_id,
				sddExt.source_deal_detail_id,
				YEAR(max(dh.deal_date)),
				max(rg.state_value_id),
				dbo.FNAGetSQLStandardDate(max(dh.deal_date)),
				round(max(dd.deal_volume),0) from
				#deal_header dh
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
				INNER JOIN #deal_detail dd ON dh.source_deal_header_id = dd.source_deal_header_id
				INNER JOIN rec_generator rg on rg.generator_id = dh.generator_id
				inner join rec_generator_assignment rga on rga.generator_id = rg.generator_id
				--and rga.counterparty_id = sc.source_counterparty_id
				INNER JOIN source_deal_header sdhExt ON sdhExt.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX('-',dh.structured_deal_id,0)) AS INT)
				INNER JOIN source_deal_detail sddExt ON sddExt.source_deal_header_id=sdhExt.source_deal_header_id
				AND sddExt.term_start=dd.term_start
				WHERE sddExt.buy_sell_flag='b'  AND rga.auto_assignment_type IN (5146,5148)
			group by dd.source_deal_detail_id,sddExt.source_deal_detail_id
				
			OPEN cur_status2;

			FETCH NEXT FROM cur_status2 INTO @auto_assignment_type2, @deal_volume2, @source_deal_detail_id3, @source_deal_detail_id_from2, @deal_date2,
			@state_value_id2, @assigned_date2, @cert_to2
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
				INSERT INTO
				assignment_audit(
				assignment_type,
				assigned_volume,
				source_deal_header_id,
				source_deal_header_id_from,
				compliance_year,
				state_value_id,
				assigned_date,
				assigned_by,
				cert_from,
				cert_to
			)
			SELECT 
			@auto_assignment_type2, @deal_volume2, @source_deal_detail_id3, @source_deal_detail_id_from2, @deal_date2,
			@state_value_id2, @assigned_date2,'Auto Assigned', 1, @cert_to2
			
			
				FETCH NEXT FROM cur_status2 INTO @auto_assignment_type2, @deal_volume2, @source_deal_detail_id3, @source_deal_detail_id_from2, @deal_date2,
			@state_value_id2, @assigned_date2, @cert_to2
			
			END;

			CLOSE cur_status2;
			DEALLOCATE cur_status2;	
	
	
	DECLARE @auto_assignment_type INT, @deal_volume float, @source_deal_detail_id2 INT, @source_deal_detail_id_from INT, @deal_date varchar(100),
			@state_value_id INT, @assigned_date datetime, @cert_to float
	
			DECLARE cur_status CURSOR LOCAL FOR
				SELECT 
				max(rga.auto_assignment_type),
				max(dd.deal_volume),
				dd.source_deal_detail_id,
				sddExt.source_deal_detail_id,
				YEAR(max(dh.deal_date)),
				max(rg.state_value_id),
				dbo.FNAGetSQLStandardDate(max(dh.deal_date)),
				round(max(dd.deal_volume),0)
			FROM
				#deal_header dh
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
				INNER JOIN #deal_detail dd ON dh.source_deal_header_id = dd.source_deal_header_id
				INNER JOIN rec_generator rg on rg.generator_id = dh.generator_id
				inner join rec_generator_assignment rga on rga.generator_id = rg.generator_id
				and rga.counterparty_id = sc.source_counterparty_id
				INNER JOIN source_deal_header sdhExt ON sdhExt.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX('-',dh.structured_deal_id,0)) AS INT)
				INNER JOIN source_deal_detail sddExt ON sddExt.source_deal_header_id=sdhExt.source_deal_header_id
				AND sddExt.term_start=dd.term_start
				WHERE sddExt.buy_sell_flag='b' AND rga.auto_assignment_type NOT IN (5181,5146,5148)
			group by dd.source_deal_detail_id,sddExt.source_deal_detail_id
				
			OPEN cur_status;

			FETCH NEXT FROM cur_status INTO @auto_assignment_type, @deal_volume, @source_deal_detail_id2, @source_deal_detail_id_from, @deal_date,
			@state_value_id, @assigned_date, @cert_to
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
				INSERT INTO
				assignment_audit(
				assignment_type,
				assigned_volume,
				source_deal_header_id,
				source_deal_header_id_from,
				compliance_year,
				state_value_id,
				assigned_date,
				assigned_by,
				cert_from,
				cert_to
			)
			SELECT 
			@auto_assignment_type, @deal_volume, @source_deal_detail_id2, @source_deal_detail_id_from, @deal_date,
			@state_value_id, @assigned_date,'Auto Assigned', 1, @cert_to
			
			
				FETCH NEXT FROM cur_status INTO @auto_assignment_type, @deal_volume, @source_deal_detail_id2, @source_deal_detail_id_from, @deal_date,
			@state_value_id, @assigned_date, @cert_to
			
			END;

			CLOSE cur_status;
			DEALLOCATE cur_status;	
		
	IF OBJECT_ID('tempdb..#offset_source_deal_header_id') IS NOT NULL
	DROP TABLE #offset_source_deal_header_id

	CREATE TABLE #offset_source_deal_header_id (source_deal_header_id INT)
	
	--SELECT * FROM #deal_header
		
		INSERT INTO source_deal_header(source_system_id, deal_id, deal_date,  physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, 
				source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
				source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, 
				trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,generator_id,
				close_reference_id,contract_id, deal_locked, deal_status
		) OUTPUT INSERTED.source_deal_header_id INTO #offset_source_deal_header_id
		SELECT 
				dh.source_system_id, CASE WHEN rga.auto_assignment_type = 5181 THEN 'Allocated-' + CAST(dh.source_deal_header_id AS VARCHAR) ELSE 'Offset-' + CAST(dh.source_deal_header_id AS VARCHAR) END
				,dh.deal_date,dh. physical_financial_flag,dh.structured_deal_id,
				ISNULL(fs.counterparty_id,sdh.counterparty_id),				
				dh.entire_term_start,dh.entire_term_end,
				dh.source_deal_type_id,dh.deal_sub_type_type_id,dh.option_flag,dh.option_type,dh.option_excercise_type,
				ISNULL(ssbm1.source_system_book_id1,sdh.source_system_book_id1),ISNULL(ssbm1.source_system_book_id2,sdh.source_system_book_id2),ISNULL(ssbm1.source_system_book_id3,sdh.source_system_book_id3),ISNULL(ssbm1.source_system_book_id4,sdh.source_system_book_id4),dh.description1,dh.description2,dh.description3,dh.deal_category_value_id,dh.trader_id,dh.internal_deal_type_value_id,
				dh.internal_deal_subtype_value_id,dh.template_id,CASE WHEN sdh.header_buy_sell_flag = 'b' THEN 's' ELSE 'b' END,
				dh.generator_id,sdh.source_deal_header_id,sdh2.contract_id, 'y', 5605
		FROM
			#deal_header dh
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=dh.source_deal_header_id
			INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX('-',dh.structured_deal_id,0)) AS INT)
			LEFT JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdh.close_reference_id
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
			AND rga.auto_assignment_type NOT IN (5146,5148)
			
		
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
			
	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
				SELECT source_deal_header_id,''i'' from #deal_header'
				EXEC(@sql)

	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
	SELECT source_deal_header_id,''i'' from #offset_source_deal_header_id'
	EXEC(@sql)
		
	exec spa_update_deal_total_volume NULL, @process_id3 ,0,null,@user_login_id,'y'

-- UDF invoice volume
-- inserting invoice volume for original deals
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, isnull(td.[invoice volume],td.[contract volume])
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	CROSS join user_defined_deal_fields_template uddft 
	WHERE uddft.field_label = 'invoice volume' AND uddft.template_id = @template_id
	
	
-- inserting invoice volume for offset deals
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, isnull(td.[invoice volume],td.[contract volume]) * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10))
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	INNER join user_defined_deal_fields_template uddft ON uddft.template_id = dh.template_id
	WHERE uddft.field_label = 'invoice volume' AND uddft.template_id = @template_id
		
-- inserting invoice volume for allocation deals
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, isnull(td.[invoice volume],td.[contract volume]) * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10))
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #offset_source_deal_header_id osdh ON osdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = dh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	INNER join user_defined_deal_fields_template uddft ON uddft.template_id = dh.template_id
	WHERE uddft.field_label = 'invoice volume' AND uddft.template_id = @template_id
	
	
	-- UDF Participant Cost
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Participant Cost] 
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	CROSS join user_defined_deal_fields_template uddft 
	WHERE uddft.field_label = 'Participant Cost' AND uddft.template_id = @template_id
	
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Participant Cost]
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER  JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	CROSS join user_defined_deal_fields_template uddft 
	WHERE uddft.field_label = 'Participant Cost' AND uddft.template_id = @template_id
	
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Participant Cost] 
	  from  source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #offset_source_deal_header_id osdh ON osdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = dh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER  JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	INNER join user_defined_deal_fields_template uddft ON uddft.template_id = dh.template_id
	WHERE uddft.field_label = 'Participant Cost' AND uddft.template_id = @template_id

	
	-- UDF Total Resource Cost

	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Total Resource Cost]
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	CROSS join user_defined_deal_fields_template uddft 
	WHERE uddft.field_label = 'Total Resource Cost' AND uddft.template_id = @template_id
	
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Total Resource Cost]
	  from source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER  JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	CROSS join user_defined_deal_fields_template uddft  
	WHERE uddft.field_label = 'Total Resource Cost' AND uddft.template_id = @template_id
	
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Total Resource Cost]
	  from 
	  source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #offset_source_deal_header_id osdh ON osdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = dh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER  JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	INNER join user_defined_deal_fields_template uddft ON uddft.template_id = dh.template_id
	WHERE uddft.field_label = 'Total Resource Cost' AND uddft.template_id = @template_id
	
	
	-- UDF Utility Cost
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Utility Cost]
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	CROSS join user_defined_deal_fields_template uddft 
	WHERE uddft.field_label = 'Utility Cost' AND uddft.template_id = @template_id
	
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Utility Cost]
	  from 
	 source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER  JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	CROSS join user_defined_deal_fields_template uddft
	WHERE uddft.field_label = 'Utility Cost' AND uddft.template_id = @template_id
	
	
	INSERT INTO user_defined_deal_detail_fields (source_deal_detail_id, udf_template_id,udf_value)
	SELECT sdd.source_deal_detail_id, uddft.udf_template_id, td.[Utility Cost] 
	  from 
	  source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #offset_source_deal_header_id osdh ON osdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = dh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
	INNER  JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
	AND rga.counterparty_id = sc.source_counterparty_id
	INNER join user_defined_deal_fields_template uddft ON uddft.template_id = dh.template_id 
	WHERE uddft.field_label = 'Utility Cost' AND uddft.template_id = @template_id
	
	
	
	INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
	SELECT sdd.source_deal_detail_id, [cert from], [cert to], REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))),
	td.volume,
	GETDATE()
	  FROM source_deal_header sdh
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	
	
	INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
	SELECT sdd.source_deal_detail_id, [cert from], [cert to], 
	REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))),
	td.volume,
	GETDATE()
	  FROM source_deal_header sdh
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	
		
	INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
	SELECT sdd.source_deal_detail_id, [cert from], [cert to], REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))),
	td.volume,
	GETDATE()
	  FROM source_deal_header sdh
	INNER JOIN #offset_source_deal_header_id osdh ON osdh.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.close_reference_id
	INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = dh.close_reference_id
	INNER JOIN #tmp_dff2 td ON td.row_no = isdh.row_no
	
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
				'REC ACTUALS for generator ' + td.generator + ' for term ' + td.[monthly term] + ', volume ' + max(td.volume) + ' imported for File:',
				''
			FROM #tmp_dff2 td  
			GROUP BY td.generator,td.[monthly term]   	


declare @url VARCHAR(MAX)
		
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
       '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id 
       + ''''
declare @elapsed_sec float 
      
 SET @elapsed_sec = DATEDIFF(second, @start_ts, GETDATE())

SELECT @desc = '<a target="_blank" href="' + @url + '">' +
       'REC Actual Data Imported Successfully' +'</a>'+ ' '+
       '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(100)) + ' sec </a>'
      

set @error_code ='s'
    	      
	
END TRY
BEGIN CATCH
	--EXEC spa_print 'error' + ERROR_MESSAGE()
	SET @error_code = 'e'
	SET @desc ='Unable to complete REC Actual Data Import'
	ROLLBACK 
END CATCH 

EXEC spa_NotificationUserByRole 2, @process_id, 'REC Actual Data Import', @desc , @error_code, @job_name, 1

--updating using flag 'e' which automatically calculate the estimated time.
EXEC spa_import_data_files_audit
     @flag = 'e',
     @process_id = @process_id,
     @status = @error_code
    
GO


