
/****** Object:  StoredProcedure [dbo].[spa_calc_inventory_accounting_entries_job]    Script Date: 12/15/2010 23:56:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_inventory_accounting_entries_job]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_inventory_accounting_entries_job]
/****** Object:  StoredProcedure [dbo].[spa_calc_inventory_accounting_entries_job]    Script Date: 12/15/2010 23:30:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 /**
	Calculate Inventory Accounting Entries of GL Acoount

	Parameters : 
	@as_of_date : From As Of Date to process
	@as_of_date_to : To As Of Date to process
	@account_group_id : Account group id to process
	@process_id : Process id when run through batch
	@job_name : Job name to create
	@user_login_id : Runner login id
	@calc_forward : Calculatition
					- 'y' - Forward only
					- 'n' - All
	@print_diagnostic : Print dynamic string


  */

CREATE procedure [dbo].[spa_calc_inventory_accounting_entries_job]
							@as_of_date varchar(100),
							@as_of_date_to varchar(20)=NULL,
							@account_group_id VARCHAR(100)=NULL,
							@process_id varchar(50)=NULL,
							@job_name varchar(100)=NULL,
							@user_login_id varchar(100)=NULL,
							@calc_forward CHAR(1) = 'n',
							@print_diagnostic INT =0
							
AS 

-- 
-- DELETE FROM report_measurement_values_inventory
-- DELETE FROM calcprocess_inventory_deals

-----------------------------------------
-- TEST DATA- Uncomment these Data to test
-----------------------------------------
SET STATISTICS IO off
SET NOCOUNT off
SET ROWCOUNT 0

/*

DECLARE @account_name VARCHAR(100)
DECLARE @as_of_date varchar(20)
DECLARE @as_of_date_to varchar(20)
DECLARE @production_month_from varchar(20)
DECLARE @production_month_to varchar(20)
DECLARE @process_id varchar(50)
DECLARE @job_name varchar(50)
DECLARE @user_login_id varchar(50)
DECLARE @print_diagnostic int
DECLARE @account_group_id VARCHAR(100)
DECLARE @calc_forward CHAR(1)

 DROP TABLE #temp_deals
 DROP TABLE #calc_status
 DROP TABLE #temp_deals_filter
 DROP TABLE #temp_deals_account_group
 DROP TABLE #temp_curves
 DROP TABLE #temp_deals_process
 DROP TABLE #prior_wght_avg_cost
 DROP TABLE #temp_cost
 DROP TABLE #wght_avg_cost
 --DROP TABLE #COGS
 DROP TABLE #temp_actual_vol
 DROP TABLE #source_deal_detail_hour
 DROP TABLE #wght_avg_cost_forward
 
	SET @print_diagnostic=1
	SET @as_of_date='2013-06-01'
	SET @process_id = REPLACE(newid(),'-','_')
	SET @account_group_id = '5'
	SET @calc_forward ='y'
----------------------------------------------------------
-- END TEST DATA
-----------------------------------------
--*/
--section 1
--##### DECLARE VARIABLES

	DECLARE @sqlstmt VARCHAR(MAX)
	DECLARE @log_increment INT
	DECLARE @log_time DATETIME
	DECLARE @pr_name VARCHAR(100)
	DECLARE @vol_frequency_table VARCHAR(100)
	DECLARE @group_id VARCHAR(10)
	DECLARE @account_type_value_id VARCHAR(10)
	DECLARE @account_type_name VARCHAR(200)
	DECLARE @gl_number_id VARCHAR(10)
	DECLARE @assignment_type_id VARCHAR(10)
	DECLARE @sub_entity_id VARCHAR(10)
	DECLARE @stra_entity_id VARCHAR(10)
	DECLARE @book_entity_id VARCHAR(10)
	DECLARE @technology VARCHAR(10)
	DECLARE @jurisdiction VARCHAR(10)
	DECLARE @gen_state VARCHAR(10)
	DECLARE @curve_id VARCHAR(10)
	DECLARE @vintage VARCHAR(10)
	DECLARE @generator_id VARCHAR(10)
	DECLARE @commodity_id VARCHAR(10)
	DECLARE @cost_calc_type CHAR(1)
	DECLARE @use_broker_fees CHAR(1)
	DECLARE @assignment_gl_number_id VARCHAR(10)
	DECLARE @gl_account_id VARCHAR(10)
	DECLARE @location_id VARCHAR(10)
	DECLARE @temp_deal_id int
	DECLARE @deal_id int
	DECLARE @formula_id int
	DECLARE @formula varchar(8000)
	DECLARE @termstart datetime
	DECLARE @formula_stmt varchar(8000)
	DECLARE @volume float
	DECLARE @counterparty_id int
	DECLARE @contract_id INT
	DECLARE @contract_expiration_date datetime
	DECLARE @curve_source_value_id INT
	DECLARE @source_price_curve varchar(100)
	DECLARE @derived_curve_table varchar(100)
	DECLARE @assessment_curve_type_value_id INT
	DECLARE @write_off_expired_recs int --1 means yes 0 means do not until it is explicitly write-off
	DECLARE @ap_multiplier int
	DECLARE @convert_uom_id INT
	DECLARE @account_receivable_gl_code VARCHAR(100)
	DECLARE @account_payable_gl_code VARCHAR(100)
	DECLARE @surrender_gl_code VARCHAR(100)
	DECLARE @cogs_gl_code VARCHAR(100) 
	DECLARE @sales_gl_code VARCHAR(100) 
	DECLARE @calc_from_outside CHAR(1)
	DECLARE @use_net_volume CHAR(1)

	SET @account_payable_gl_code=370
	SET @account_receivable_gl_code=371
	SET @surrender_gl_code=372
	--SET @cogs_gl_code=375
	SET @sales_gl_code=373
	
	SET @convert_uom_id=24
	SET @use_net_volume = 'y'
--## Default values
	SET @curve_source_value_id=4500
	IF @user_login_id is null
		SET @user_login_id=dbo.fnadbuser()

	IF @process_id IS NULL
	SET @process_id = REPLACE(newid(),'-','_')

	SET @ap_multiplier = -1
	SET @source_price_curve = dbo.FNAGetProcessTableName(@as_of_date, 'source_price_curve')
	SET @derived_curve_table = dbo.FNAProcessTableName('der_price_curve', @user_login_id, @process_id)
	SET @assessment_curve_type_value_id=77
	select @write_off_expired_recs = var_value from adiha_default_codes_values where instance_no = 1 and seq_no = 1 and default_code_id = 23


	IF @as_of_date IS NOT NULL AND (@as_of_date_to IS NULL OR @as_of_date_to='')
		SET @as_of_date_to=@as_of_date
	IF (@as_of_date IS NULL OR @as_of_date_to='') AND @as_of_date_to IS NOT NULL
		SET @as_of_date=@as_of_date_to

---------------------------------------


	If @print_diagnostic = 1
	begin
		set @log_increment = 1
		print '******************************************************************************************'
		print 'Section 1 ********************START &&&&&&&&&[spa_calc_inventory_accounting_entries]**********'
	end

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as VARCHAR)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end


	 SET @calc_from_outside = 'y'
	 --SET @calc_forward ='y'
--section 1.1 Create Temporay Deal Table
	create table #temp_deals(
		[temp_deal_id] [int] identity(1,1),
		[source_deal_header_id] [int]  NOT NULL ,
		[source_deal_detail_id] INT NOT NULL,
		[sub_entity_id] INT NOT NULL,
		[stra_entity_id] INT NOT NULL,
		[book_entity_id] INT NOT NULL,
		[deal_category_value_id] INT NOT NULL,
		[deal_id] [varchar] (50) COLLATE DATABASE_DEFAULT  NOT NULL ,
		[deal_date] [datetime] NOT NULL ,
		[counterparty_id] [int] NOT NULL ,
		[generator_id] INT NULL,
		[jurisdiction] INT NULL,
		[gen_state_value_id] INT NULL,
		[technology] INT NULL,
		[vintage] INT NULL,
		[commodity_id] INT NULL,
		[maturity_date] [datetime] NOT NULL,
		[term_start] [datetime] NOT NULL ,
		[term_end] [datetime] NOT NULL ,
		[Leg] [int] NOT NULL ,
		[contract_expiration_date] [datetime] NOT NULL ,
		[buy_sell_flag] [char] (1) COLLATE DATABASE_DEFAULT  NOT NULL ,
		[curve_id] [int] NULL ,
		[fixed_price] [float] NULL ,
		[fixed_price_currency_id] [int] NULL ,
		[option_strike_price] [float] NULL ,
		[deal_volume] [float] NOT NULL ,
		[deal_volume_frequency] [char] (1) COLLATE DATABASE_DEFAULT  NOT NULL ,
		[deal_volume_uom_id] [int] NOT NULL ,
		[formula_id] int NULL,
		[formula] varchar(6000) COLLATE DATABASE_DEFAULT NULL,
		[formula_value] float NULL,
		[price_adder] float NULL,
		[price_multiplier] float NULL,
		[derived_curve] varchar(1) COLLATE DATABASE_DEFAULT,
		[block_type] INT,
		[block_definition_id] INT,
		[fixed_cost] float,
		[assignment_type_value_id] INT NULL,
		[contract_id] INT NULL,
		[expiring] INT NULL,
		[surrender] INT NULL,
		exclude_inventory CHAR(1) COLLATE DATABASE_DEFAULT,
		status_value_id int null,
		current_buy_sell INT,
		cost_approach_id INT,
		unit_fixed_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		broker_unit_fees FLOAT,
		broker_fixed_cost FLOAT,
		adjustments FLOAT,
		fas_deal_type_value_id INT,
		settled INT,
		internal_deal_type_value_id INT,
		location_id INT,
		hourly_position_breakdown CHAR(1) COLLATE DATABASE_DEFAULT,
		formula_curve_id INT		
	)


	CREATE TABLE #calc_status
		(
			process_id varchar(100) COLLATE DATABASE_DEFAULT,
			ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
			Module varchar(100) COLLATE DATABASE_DEFAULT,
			Source varchar(100) COLLATE DATABASE_DEFAULT,
			type varchar(100) COLLATE DATABASE_DEFAULT,
			[description] varchar(1000) COLLATE DATABASE_DEFAULT,
			[nextstep] varchar(250) COLLATE DATABASE_DEFAULT
		)


	CREATE TABLE #temp_deals_filter
		(
			temp_deal_id INT,
			source_deal_header_id INT,
			source_deal_detail_id INT,
			sub_entity_id INT,
			stra_entity_id INT,
			book_entity_id INT,
			technology INT,
			jurisdiction INT,
			gen_state_value_id INT,
			curve_id INT,
			vintage INT,
			generator_id INT,
			commodity_id INT,
			contract_expiration_date DATETIME
		)

	CREATE TABLE #temp_deals_account_group
		(
			[temp_deal_id] INT,
			group_id INT,
			gl_account_id INT,
			account_type_value_id INT,
			account_type_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
			cost_calc_type CHAR(1) COLLATE DATABASE_DEFAULT,
			use_broker_fees CHAR(1) COLLATE DATABASE_DEFAULT,
			source_deal_header_id INT,
			source_deal_detail_id INT,
			sub_entity_id INT,
			stra_entity_id INT,
			book_entity_id INT,
			technology INT,
			jurisdiction INT,
			gen_state_value_id INT,
			curve_id INT,
			vintage INT,
			generator_id INT,
			commodity_id INT,
			[ARGL] int NULL, --A/R -- 1010
			[APGL] int NULL,  --A/P -- 1009
			[InvGL] int NULL,  -- Inventory - 1004
			[ExpGL] int NULL, -- Purchase Power Expense --
			[SExpGL] int NULL, -- REC Surrender Expense -- 1007
			[IExpGL] int NULL, -- REC Inventory Expense -- 1006
			[EExpGL] int NULL, -- REC Expiration Expense -- 1008
			[RevGL] int NULL, -- Revenue -- 1005
			[LiabGL] int NULL, -- Profit Liability - 
			[NoCost] int NULL, -- 1000
			[HeldForCompliance] int NULL, -- 1001
			[InventorPaidValue] int NULL, -- 1002
			[ComplianceLiability] int NULL, -- 1003
			[DeferredFuel] int NULL, --1011,
			contract_expiration_date DATETIME		
		)

	CREATE TABLE #temp_curves(
		[source_curve_def_id] [int] NOT NULL,
		[as_of_date] [datetime] NOT NULL,
		[Assessment_curve_type_value_id] [int] NOT NULL,
		[curve_source_value_id] [int] NOT NULL,
		[maturity_date] [datetime] NOT NULL,
		[curve_value] [float] NOT NULL,
		[pnl_as_of_date] [datetime] NOT NULL
	) 

	CREATE TABLE #temp_deals_process(
		[temp_deal_id] [int] identity(1,1) ,
		[source_deal_header_id] [int]  NOT NULL ,
		[source_deal_detail_id] INT NOT NULL
	)
-----######################

	CREATE TABLE #prior_wght_avg_cost (
		[as_of_date] [datetime] NOT NULL ,
		[group_id] INT,
		[gl_account_id] INT,
		[gl_code] [int] NULL ,
		[wght_avg_cost] [float] NULL ,
		[total_inventory] [float] NULL ,
		[total_units] [float] NULL ,
		inventory_account_type VARCHAR(100) COLLATE DATABASE_DEFAULT,
		inventory_account_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[deal_date] datetime,
		uom_id INT
	) 


	CREATE TABLE #wght_avg_cost (
		[as_of_date] [datetime] NOT NULL ,
		[group_id] INT,
		[gl_account_id] INT,
		[gl_code] [int] NULL ,
		[wght_avg_cost] [float] NULL ,
		[total_inventory] [float] NULL ,
		[total_units] [float] NULL ,
		inventory_account_type VARCHAR(100) COLLATE DATABASE_DEFAULT,
		inventory_account_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[deal_date] datetime,
		uom_id INT,
		currency_id INT
	) 

CREATE TABLE #wght_avg_cost_forward (
		[as_of_date] [datetime] NOT NULL ,
		[term_date]  [datetime] NOT NULL ,
		[group_id] INT,
		[gl_account_id] INT,
		[gl_code] [int] NULL ,
		[wght_avg_cost] [float] NULL ,
		[total_inventory] [float] NULL ,
		[total_units] [float] NULL ,
		inventory_account_type VARCHAR(100) COLLATE DATABASE_DEFAULT,
		inventory_account_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[deal_date] datetime,
		uom_id INT,
		currency_id INT
	) 

	If @print_diagnostic = 1
	begin
		set @pr_name= 'Section 1.1 sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	


	DECLARE @From_Deal INT

	SELECT @From_Deal = value_id
	FROM   static_data_value
	WHERE  code = 'From Deal'

---Section 1.2 Collect Deals

	set @sqlstmt='
		INSERT INTO #temp_deals ([source_deal_header_id],[source_deal_detail_id],[sub_entity_id],[stra_entity_id],[book_entity_id],[deal_category_value_id],[deal_id],[deal_date],[counterparty_id],[generator_id],[jurisdiction],[gen_state_value_id],[technology],[vintage],[commodity_id],[maturity_date],[term_start],[term_end],[Leg],[contract_expiration_date],[buy_sell_flag] ,[curve_id],[fixed_price],[fixed_price_currency_id],[option_strike_price],[deal_volume],[deal_volume_frequency] ,[deal_volume_uom_id],[formula_id],[formula] ,[formula_value],[price_adder],[price_multiplier],[derived_curve],[block_type] ,[block_definition_id] ,[fixed_cost] ,[assignment_type_value_id],[contract_id],[expiring],[surrender],exclude_inventory,status_value_id,current_buy_sell,cost_approach_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,[adjustments],[fas_deal_type_value_id],settled,internal_deal_type_value_id,location_id,hourly_position_breakdown,formula_curve_id) 
		SELECT    
			sdh.source_deal_header_id,
			sdd.source_deal_detail_id,
			sub.entity_id,
			stra.entity_id,
			book.entity_id,
			sdh.deal_category_value_id,
			sdh.deal_id,
			sdh.deal_date,
			sdh.counterparty_id,
			sdh.generator_id,
			rg.state_value_id,
			rg.gen_state_value_id,
			rg.technology,
			YEAR(sdd.term_start),	
			sdh.commodity_id,
			CASE WHEN ((spcd.monthly_index IS NOT NULL AND cast(''' +@as_of_date+ ''' as datetime) < DBO.FNAGetContractMonth(sdd.term_start)) OR 
					spcd.Granularity = 980 OR spcd.Granularity = 991 OR spcd.Granularity = 992 OR spcd.Granularity = 993) 
				 THEN cast(Year(sdd.term_start) as varchar) + ''-'' + cast(Month(sdd.term_start) as varchar) + ''-01'' ELSE sdd.term_start END maturity_date,
			sdd.term_start,
			sdd.term_end,
			sdd.leg,
			--sdd.contract_expiration_date,
			sdh.deal_date,
			CASE WHEN sdht.internal_deal_type_value_id  <> 13 THEN CASE WHEN sdd.buy_sell_flag =''s'' THEN ''b'' ELSE ''s'' END  ELSE  sdd.buy_sell_flag END,
			case when (spcd.monthly_index IS NOT NULL AND cast(''' +@as_of_date + ''' as datetime) < DBO.FNAGetContractMonth(sdd.term_start)) then spcd.monthly_index else ISNULL(sdd1.curve_id,sdd.curve_id) end curve_id,
			COALESCE(NULLIF(sdh.rec_price,0),ISNULL(sdd1.fixed_price,sdd.fixed_price),0),
			COALESCE(sdd1.fixed_price_currency_id,sdd.fixed_price_currency_id,2),
			ISNULL(sdd.option_strike_price,sdd.option_strike_price)option_strike_price,
			sdd.total_volume,
			sdd.deal_volume_frequency,
			ISNULL(spcd.display_uom_id,sdd.deal_volume_uom_id),
			ISNULL(sdd1.formula_id,sdd.formula_id), 
			fe.formula, 
			0,
			COALESCE(sdd1.price_adder,sdd.price_adder, 0), 
			COALESCE(NULLIF(sdd1.price_multiplier,0),NULLIF(sdd.price_multiplier,0), 1) price_multiplier,
			CASE WHEN (spcd.formula_id is not null) then ''y'' else ''n'' end derived_curve,
			sdh.block_type,
			sdh.block_define_id,
			COALESCE(sdd1.fixed_cost,sdd.fixed_cost, 0) fixed_cost,			
			sdh.assignment_type_value_id,
			sdh.contract_id,
			0 expiring,
			case when (isnull(sdh.assignment_type_value_id, 5149) NOT IN (5149, 5173, 5144)) then 1 else 0 end surrender,
			isnull(rg.exclude_inventory, ''n'') exclude_inventory,
			sdh.status_value_id,
			1 AS current_buy_sell,
			952 AS cost_approach_id,
			sdh.unit_fixed_flag,
			sdh.broker_unit_fees,
			sdh.broker_fixed_cost,
			0 as adjustments,
			sbm.fas_deal_type_value_id,
			0 as settled,
			CASE WHEN sdht.internal_deal_type_value_id =13 THEN CASE WHEN sdd.buy_sell_flag = ''b'' THEN 15 ELSE 16 END ELSE sdht.internal_deal_type_value_id END,
			sdd.location_id,
			sdht.hourly_position_breakdown,
			ISNULL(sdd1.formula_curve_id,sdd.formula_curve_id)
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN source_system_book_map sbm ON sdh.source_system_book_id1 = sbm.source_system_book_id1  
		           AND sdh.source_system_book_id2 = sbm.source_system_book_id2 
				   AND sdh.source_system_book_id3 = sbm.source_system_book_id3 
				   AND sdh.source_system_book_id4 = sbm.source_system_book_id4 
			INNER JOIN portfolio_hierarchy book ON sbm.fas_book_id = book.entity_id 
			INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id 
			INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id = sub.entity_id 
			LEFT JOIN source_deal_header_template sdht ON sdh.template_id=sdht.template_id
			LEFT JOIN user_defined_deal_fields_template udft  ON udft.[template_id] = sdh.[template_id] 
				AND udft.field_id = '+CAST(@From_Deal AS VARCHAR)+'
			LEFT JOIN  [user_defined_deal_fields] uddf ON uddf.source_deal_header_id = sdd.source_deal_header_id
				AND udft.udf_template_id = uddf.udf_template_id								
			LEFT JOIN source_deal_header sdh1 ON CAST(sdh1.source_deal_header_id AS VARCHAR) = uddf.udf_value AND sdht.internal_deal_type_value_id = 13
			CROSS APPLY(SELECT 
				MAX(curve_id)curve_id,MAX(fixed_price)fixed_price,MAX(fixed_price_currency_id)fixed_price_currency_id,MAX(formula_id)formula_id,MAX(price_adder)price_adder,
				MAX(price_multiplier)price_multiplier,MAX(fixed_cost)fixed_cost,MAX(formula_curve_id)formula_curve_id
				FROM source_deal_detail WHERE source_deal_header_id = sdh1.source_deal_header_id
					AND sdd.term_start BETWEEN term_start AND term_end
			) sdd1
			LEFT OUTER JOIN formula_editor fe ON fe.formula_id = ISNULL(sdd1.formula_id,sdd.formula_id)   
			LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ISNULL(sdd1.curve_id,sdd.curve_id) 
			LEFT OUTER JOIN rec_generator rg ON rg.generator_id=sdh.generator_id
			
		WHERE 1=1 
			AND sdd.total_volume IS NOT NULL
			--AND sdh.deal_date between '''+@as_of_date+''' AND '''+@as_of_date_to+'''
			'+CASE WHEN @calc_forward='n' THEN ' AND dbo.FNAGetContractMonth(sdd.term_start)=dbo.FNAGetContractMonth('''+@as_of_date+''')' ELSE ' AND sdd.term_start>='''+@as_of_date+'''' END+'
			AND sdht.internal_deal_type_value_id IN(19,20,21,13,15,16)'
			--+' AND sdh.source_deal_header_id=2673'
			--+' AND YEAR(sdd.term_start)=2009'
		print @sqlstmt
		EXEC(@sqlstmt)

	-------####### Create Index
	CREATE INDEX IDX_temp_deals ON #temp_deals(source_deal_header_id)
	CREATE INDEX IDX_temp_deals1 ON #temp_deals(curve_id,location_id,term_start,term_end)


	IF @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of Collecting Deals *****************************'	
	END




----Section 1.3 Update Formula values

	If @print_diagnostic = 1
	begin
		set @pr_name= 'Section 1.3 sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	
/*
	DECLARE formula_cursor CURSOR FOR 
	select 	temp_deal_id, formula, term_start, source_deal_header_id, 		
		case 	when deal_volume_frequency ='d' then (datediff(day,term_start,term_end)+1)
			else 1
			End * deal_volume as volume, counterparty_id, contract_id, formula_id, contract_expiration_date
	 
	from #temp_deals where formula is not null

	OPEN formula_cursor

	FETCH NEXT FROM formula_cursor
	INTO @temp_deal_id, @formula, @termstart, @deal_id, @volume, @counterparty_id, @contract_id, @formula_id, @contract_expiration_date
	WHILE @@FETCH_STATUS = 0
	BEGIN

		--replace curve values
		SET @formula_stmt = dbo.FNAFormulaText (@termstart,	
				case when (@contract_expiration_date < @as_of_date) then @contract_expiration_date else @as_of_date end, 
				@volume, 0, @formula, 0, 0, 0, @curve_source_value_id)

		SET @formula_stmt = 'update #temp_deals set formula_value = ' + @formula_stmt + ' where temp_deal_id = ' + cast(@temp_deal_id as varchar)

		exec(@formula_stmt)

		IF (@@ERROR <> 0)
		BEGIN
			--Select 'MTM Calculation will be wrong as Syntax error found in formula for Deal ID ' + cast(@deal_id as varchar) + ': ' + @formula 
			INSERT INTO #calc_status
				Select @process_id,'Error','Inventory Calc','Run Inventory Calc','Application Error',
				'Inventory Calculation will be wrong as Syntax error found in formula for Deal ID ' + cast(@deal_id as varchar) + ': ' + @formula,
				'Please edit the formula for the deal.'

		END

		FETCH NEXT FROM formula_cursor
		INTO @temp_deal_id, @formula, @termstart, @deal_id, @volume, @counterparty_id, @contract_id, @formula_id, @contract_expiration_date

	END

	CLOSE formula_cursor
	DEALLOCATE  formula_cursor

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************Evaulating and updating values in Deals *****************************'	
	END

*/


----Section 1.4 Find Price Curve values

	If @print_diagnostic = 1
	begin
		set @pr_name= 'Section 1.4 sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end


	set @sqlstmt = '
	insert into #temp_curves (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
		curve_source_value_id, maturity_date, curve_value, pnl_as_of_date)
	select	cids.curve_id source_curve_def_id, 
			cids.as_of_date, spc.assessment_curve_type_value_id, spc.curve_source_value_id, spc.maturity_date,
			spc.curve_value, cids.pnl_as_of_date pnl_as_of_date
	from 
	(select distinct curve_id, maturity_date, CONTRACT_EXPIRATION_DATE as_of_date, ''' + @as_of_date + ''' pnl_as_of_date
		FROM #temp_deals 
		WHERE 
			settled = 0 AND curve_id is NOT NULL AND derived_curve = ''n''
			AND formula_curve_id IS NULL
	
	UNION ALL
	select td.curve_id, spc.maturity_date, max(td.contract_expiration_date) as_of_date, max(spc.as_of_date) pnl_as_of_date  
	from #temp_deals td INNER JOIN
	source_price_curve spc ON spc.source_curve_def_id = td.curve_id AND 
		spc.maturity_date = td.maturity_date
	WHERE derived_curve = ''n'' AND td.settled = 1 AND spc.as_of_date >= td.contract_expiration_date AND
		spc.as_of_date <= ''' + @as_of_date + '''
		AND formula_curve_id IS NULL
	group by td.curve_id, spc.maturity_date
	) cids left outer join
	' + @source_price_curve + ' spc ON 
		cids.curve_id = spc.source_curve_def_id AND
		cids.maturity_date = spc.maturity_date AND
		cids.as_of_date = spc.as_of_date AND 
		spc.assessment_curve_type_value_id = ' + cast(@assessment_curve_type_value_id as varchar) + '
		AND spc.curve_source_value_id = ' + cast(@curve_source_value_id as varchar) + ' 
	where spc.curve_value IS NOT NULL 
	'

	print @sqlstmt
	EXEC (@sqlstmt)

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************Selecting price curves1*****************************'	
	END

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	set @sqlstmt = '
	insert into #temp_curves (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
		curve_source_value_id, maturity_date, curve_value) 
	select DISTINCT spc.source_curve_def_id, spc.as_of_date, spc.assessment_curve_type_value_id,
			spc.curve_source_value_id, spc.maturity_date, spc.curve_value 
	from #temp_deals a inner join
	' + @source_price_curve + ' spc ON a.curve_id = spc.source_curve_def_id and
		spc.as_of_date = a.term_end and spc.maturity_date = a.term_end and
		spc.assessment_curve_type_value_id = ' + cast(@assessment_curve_type_value_id as varchar) + ' and
		spc.curve_source_value_id = ' + cast(@curve_source_value_id as varchar) + ' left outer join
	#temp_curves tc ON tc.source_curve_def_id = spc.source_curve_def_id and
					   tc.as_of_date = spc.as_of_date and tc.maturity_date = spc.maturity_date
	where a.curve_id IS NOT NULL AND (a.internal_deal_type_value_id = 6 OR a.internal_deal_type_value_id = 19) AND
		tc.source_curve_def_id IS NULL AND a.derived_curve = ''n''
		AND formula_curve_id IS NULL 
	'
	--EXEC(@sqlstmt)

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************Selecting price curves2*****************************'	
	END

	
	----------------------get derived curves

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end

	declare @der_curve_id int
	declare @min_term_start datetime
	declare @max_term_start datetime
	declare @as_of_date_from datetime

	SET @sqlstmt =
	'
	CREATE TABLE ' + @derived_curve_table + ' (
		source_curve_def_id INT,
		as_of_date datetime,
		maturity_date datetime,
		formula_value float,
		formula_id INT,
		formula_str VARCHAR(500)
	)
	'

	Exec(@sqlstmt)


	DECLARE formula_cursor_derc CURSOR FOR 
	select 	curve_id, min(term_start), max(term_start) 
	from #temp_deals where derived_curve = 'y'
		AND formula_curve_id IS NULL
	group by curve_id

	OPEN formula_cursor_derc

	FETCH NEXT FROM formula_cursor_derc
	INTO @der_curve_id, @min_term_start, @max_term_start
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @as_of_date_from = case when (@min_term_start < @as_of_date) then @min_term_start else @as_of_date end

		EXEC spa_derive_curve_value @der_curve_id, 
			 @as_of_date_from,
			 @as_of_date, @curve_source_value_id, @derived_curve_table, @min_term_start, @max_term_start

		FETCH NEXT FROM formula_cursor_derc
		INTO @der_curve_id, @min_term_start, @max_term_start

	END

	CLOSE formula_cursor_derc
	DEALLOCATE  formula_cursor_derc


	set @sqlstmt = '
	insert into #temp_curves (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
		curve_source_value_id, maturity_date, curve_value, pnl_as_of_date)
	select	cids.curve_id source_curve_def_id, 
			cids.as_of_date, 
			' + cast(@assessment_curve_type_value_id as varchar) + ' assessment_curve_type_value_id,
			' + cast(@curve_source_value_id as varchar) + ' curve_source_value_id,
			spc.maturity_date, spc.formula_value curve_value, cids.pnl_as_of_date pnl_as_of_date
	from 
		(select distinct curve_id, maturity_date, ''' + @as_of_date + ''' as_of_date, ''' + @as_of_date + ''' pnl_as_of_date
		from #temp_deals 
		where settled = 0 AND curve_id is NOT NULL AND derived_curve = ''y''
		AND formula_curve_id IS NULL
		UNION ALL
		select td.curve_id, spc.maturity_date, max(td.contract_expiration_date) as_of_date, max(spc.as_of_date) pnl_as_of_date
		from #temp_deals td INNER JOIN
		' + @derived_curve_table + ' spc ON spc.source_curve_def_id = td.curve_id AND 
			spc.maturity_date = td.maturity_date
		where derived_curve = ''y'' AND td.settled = 1 AND spc.as_of_date >= td.contract_expiration_date 
		AND formula_curve_id IS NULL
		group by td.curve_id, spc.maturity_date
		) cids left outer join
		' + @derived_curve_table + ' spc ON 
			cids.curve_id = spc.source_curve_def_id AND
			cids.maturity_date = spc.maturity_date AND
			cids.as_of_date = spc.as_of_date  
	where spc.formula_value IS NOT NULL 
	'

	EXEC(@sqlstmt)

	set @sqlstmt = dbo.FNAProcessDeleteTableSql(@derived_curve_table)
	EXEC (@sqlstmt)

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************END OF Processing Derived deals *****************************'	
	END



	----------------------get curves from formula_curve_id
	
	--INSERT INTO #temp_curves (source_curve_def_id, as_of_date, Assessment_curve_type_value_id,
	--	curve_source_value_id, maturity_date, curve_value, pnl_as_of_date)
	--SELECT 
	--	td.formula_curve_id,
	--	spc.as_of_date,
	--	spc.Assessment_curve_type_value_id,
	--	spc.curve_source_value_id,
	--	spc.maturity_date,
	--	dbo.FNARecCurve(spc.maturity_date,spc.as_of_date,td.formula_curve_id,1) curve_value,
	--	spc.as_of_date
	--FROM
	--	#temp_deals td
	--	LEFT JOIN source_price_curve spc ON td.formula_curve_id = spc.source_curve_def_id
	--		AND spc.as_of_date = @as_of_date
	--		AND spc.maturity_date BETWEEN td.term_start AND td.term_end
	--WHERE
	--	td.formula_curve_id IS NOT NULL		
					


---Section 1.5 Filter deals using the Inventory account logic
	

	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'Section 1.5 sql_log_' + cast(@log_increment as VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=getdate()
		print @pr_name+' Running..............'
	END



	--UPDATE td
	--	SET td.fixed_price=tc.curve_value
	--FROM
	--	#temp_curves tc 
	--	INNER JOIN #temp_deals td ON tc.source_curve_def_id=td.curve_id
	--	AND tc.maturity_date=td.contract_expiration_date

------Update the price from Settlement Invoice 
/*
		UPDATE td
			SET [fixed_price]=a.Price
		FROM
			#temp_deals td
		JOIN
		(
	SELECT 
			civv.generator_id,civv.prod_date,SUM(civ.value) value,FLOOR(SUM(civ.volume*ISNULL(conv1.conversion_factor,1))) volume,SUM(civ.value)/ISNULL(NULLIF(FLOOR(SUM(civ.volume*ISNULL(conv1.conversion_factor,1))),0),1) as Price  
		FROM
			(SELECT MAX(as_of_date) as_of_date,generator_id,counterparty_id,contract_id,prod_date from calc_invoice_volume_variance GROUP BY generator_id,counterparty_id,contract_id,prod_date)a
			JOIN calc_invoice_volume_variance civv ON civv.counterparty_id=a.counterparty_id 
				 AND civv.counterparty_id=a.counterparty_id 
				 AND civv.generator_id=a.generator_id 	
				 AND civv.prod_date=a.prod_date
 				 AND civv.as_of_date=a.as_of_date
			JOIN calc_invoice_volume civ ON civv.calc_id=civ.calc_id
			JOIN contract_group cg ON cg.contract_id = civv.contract_id   
			JOIN contract_group_detail cgd on cgd.contract_id = cg.contract_id   
				 AND civ.invoice_line_item_id=cgd.invoice_line_item_id   
				 AND prod_type= case when ISNULL(cg.term_start,'')='' then 'p'
									 when dbo.FNAGETCONTRACTMONTH(cg.term_start)<=dbo.FNAGETCONTRACTMONTH(civv.prod_date) then 'p'
									else 't' end   
			LEFT JOIN rec_volume_unit_conversion conv1 ON 
				conv1.from_source_uom_id=civv.UOM
				AND conv1.to_source_uom_id=@convert_uom_id
				AND conv1.state_value_id IS NULL
				AND conv1.curve_id IS NULL
				AND conv1.assignment_type_value_id IS NULL
				AND conv1.to_curve_id IS NULL

		WHERE
			ISNULL(cgd.inventory_item,'n')='y'
			AND dbo.FNAGETCONTRACTMONTH(civv.prod_date) between @as_of_date AND @as_of_date_to
		GROUP BY civv.generator_id,civv.prod_date
		) a
			ON td.generator_id=a.generator_id
			   AND td.term_start=a.prod_date	
	

*/		


--- Apply the filter the create the inventory group

	DECLARE inv_acct CURSOR FOR
	SELECT
		group_id,gl_account_id,account_type_value_id,account_type_name,ISNULL(gl_number_id,-1),ISNULL(assignment_type_id,-1),ISNULL(assignment_gl_number_id,-1),sub_entity_id,stra_entity_id,
		book_entity_id,technology,jurisdiction,gen_state,curve_id,vintage,generator_id,commodity_id,cost_calc_type,use_broker_fees,location_id
	FROM
		inventory_account_type
	WHERE group_id=@account_group_id

	OPEN inv_acct
	FETCH NEXT FROM inv_acct INTO
		@group_id,@gl_account_id,@account_type_value_id,@account_type_name,@gl_number_id,@assignment_type_id,@assignment_gl_number_id,@sub_entity_id,@stra_entity_id,
		@book_entity_id,@technology,@jurisdiction,@gen_state,@curve_id,@vintage,@generator_id,@commodity_id,@cost_calc_type,@use_broker_fees,@location_id

	WHILE @@FETCH_STATUS = 0
	BEGIN

		delete #temp_deals_filter
		set @sqlstmt = ' INSERT INTO #temp_deals_filter
						SELECT
							temp_deal_id,
							source_deal_header_id,
							source_deal_detail_id,
							sub_entity_id,
							stra_entity_id,
							book_entity_id,
							technology,
							jurisdiction,
							gen_state_value_id,
							curve_id,
							vintage,
							generator_id,
							commodity_id,
							contract_expiration_date
						FROM
							#temp_deals 
						WHERE 1=1 '+
						+CASE WHEN  @sub_entity_id IS NOT NULL THEN ' AND sub_entity_id='+@sub_entity_id ELSE '' END
						+CASE WHEN  @stra_entity_id IS NOT NULL THEN ' AND stra_entity_id='+@stra_entity_id ELSE '' END
						+CASE WHEN  @book_entity_id IS NOT NULL THEN ' AND book_entity_id='+@book_entity_id ELSE '' END
						+CASE WHEN  @technology IS NOT NULL THEN ' AND technology='+@technology ELSE '' END
						+CASE WHEN  @jurisdiction IS NOT NULL THEN ' AND jurisdiction='+@jurisdiction ELSE '' END
						+CASE WHEN  @gen_state IS NOT NULL THEN ' AND gen_state_value_id='+@gen_state ELSE '' END
						+CASE WHEN  @curve_id IS NOT NULL THEN ' AND curve_id='+@curve_id ELSE '' END								
						+CASE WHEN  @vintage IS NOT NULL THEN ' AND vintage='+@vintage ELSE '' END								
						+CASE WHEN  @generator_id IS NOT NULL THEN ' AND generator_id='+@generator_id ELSE '' END								
						+CASE WHEN  @commodity_id IS NOT NULL THEN ' AND commodity_id='+@commodity_id ELSE '' END	
						+CASE WHEN  @location_id IS NOT NULL THEN ' AND location_id='+@location_id ELSE '' END	
						--+CASE WHEN  @assignment_type_id <>-1 THEN ' AND assignment_type_value_id='+@assignment_type_id ELSE '' END								
			print @sqlstmt
			EXEC(@sqlstmt)
		

			SET @sqlstmt='
				INSERT INTO #temp_deals_account_group
				SELECT
					[temp_deal_id],
					'+@group_id+',
					'+@gl_account_id+',
					'+@account_type_value_id+',
					'''+@account_type_name+''',
					'''+@cost_calc_type+''',
					'''+@use_broker_fees+''',
					tdf.source_deal_header_id,
					tdf.source_deal_detail_id,
					tdf.sub_entity_id,
					tdf.stra_entity_id,
					tdf.book_entity_id,
					tdf.technology,
					tdf.jurisdiction,
					tdf.gen_state_value_id,
					tdf.curve_id,
					tdf.vintage,
					tdf.generator_id,
					tdf.commodity_id,
					--CASE WHEN '+@account_type_value_id+'=3010  THEN '+@gl_number_id+' ELSE NULL END [ARGL],
					'+@account_receivable_gl_code+' [ARGL],
					--CASE WHEN '+@account_type_value_id+'=3009  THEN '+@gl_number_id+' ELSE NULL END APGL,
					'+@account_payable_gl_code+' APGL,
					CASE WHEN '+@account_type_value_id+'=3004  THEN '+@gl_number_id+' ELSE NULL END InvGL,
					NULL ExpGL,
					CASE WHEN '+@account_type_value_id+'=3004 AND '+@assignment_type_id+' IN(5146,5180) THEN '+ISNULL(@assignment_gl_number_id,@surrender_gl_code)+' ELSE NULL END SExpGL,
					--CASE WHEN '+@account_type_value_id+'=3006  THEN '+@gl_number_id+' ELSE NULL END IExpGL,
					'+@sales_gl_code+'IExpGL,
					CASE WHEN '+@account_type_value_id+'=3004 AND '+@assignment_type_id+' IN(5144) THEN '+@gl_number_id+' ELSE NULL END EExpGL,
					CASE WHEN '+@account_type_value_id+'=3005  THEN '+@gl_number_id+' ELSE NULL END [RevGL],
					NULL as LiabGL,
					CASE WHEN '+@account_type_value_id+'=3000  THEN '+@gl_number_id+' ELSE NULL END NoCost,
					CASE WHEN '+@account_type_value_id+'=3001  THEN '+@gl_number_id+' ELSE NULL END [HeldForCompliance],
					CASE WHEN '+@account_type_value_id+'=3002  THEN '+@gl_number_id+' ELSE NULL END [InventorPaidValue],
					CASE WHEN '+@account_type_value_id+'=3003  THEN '+@gl_number_id+' ELSE NULL END [ComplianceLiability],
					CASE WHEN '+@account_type_value_id+'=3011  THEN '+@gl_number_id+' ELSE NULL END [DeferredFuel],
					contract_expiration_date
				FROM
					#temp_deals_filter  tdf
					LEFT OUTER JOIN (
						SELECT DISTINCT source_deal_header_id from  #temp_deals_account_group
						WHERE CAST(group_id AS VARCHAR)+CAST(account_type_value_id AS VARCHAR) = ' +@group_id +@account_type_value_id+') ex ON
					tdf.source_deal_header_id = ex.source_deal_header_id
					WHERE ex.source_deal_header_id IS NULL '
			
			EXEC(@sqlstmt)

		FETCH NEXT FROM inv_acct INTO
			@group_id,@gl_account_id,@account_type_value_id,@account_type_name,@gl_number_id,@assignment_type_id,@assignment_gl_number_id,@sub_entity_id,@stra_entity_id,
			@book_entity_id,@technology,@jurisdiction,@gen_state,@curve_id,@vintage,@generator_id,@commodity_id,@cost_calc_type,@use_broker_fees,@location_id

		END
		CLOSE inv_acct
		DEALLOCATE inv_acct



---- ################### get the schedule/nomination/actual volume for each day

-- Get the actual volume
	SELECT
		sdd.source_deal_header_id,
		sddh.term_date term_start,
		SUM(sddh.volume* ISNULL(conv.conversion_factor,1)) volume,
		sdd.location_id
		
	INTO 
		#source_deal_detail_hour	
	FROM	
		source_deal_detail_hour sddh (nolock) 
		INNER JOIN  source_deal_detail sdd (nolock) on sdd.source_deal_detail_id=sddh.source_deal_detail_id
		AND sddh.term_date BETWEEN sdd.term_start AND sdd.term_end
		INNER JOIN  #temp_deals td on sdd.source_deal_detail_id=td.source_deal_detail_id 
			AND td.internal_deal_type_value_id=19
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
		LEFT JOIN rec_volume_unit_conversion conv ON conv.from_source_uom_id=sdd.deal_volume_uom_id
			AND conv.to_source_uom_id=spcd.display_uom_id			
	GROUP BY sdd.source_deal_header_id,sddh.term_date,sdd.location_id
	


	
	CREATE TABLE #temp_actual_vol(
		source_deal_header_id INT,
		location_id INT,
		term_start DATETIME,
		deal_volume NUMERIC(38,20),
		uom_id INT
	)
	
			
				
	SET @sqlstmt='
		INSERT INTO #temp_actual_vol(source_deal_header_id,location_id,term_start,deal_volume,uom_id)
		SELECT
			COALESCE(sddh.source_deal_header_id,td.source_deal_header_id),
			td.location_id,
			ISNULL(sddh.term_start,rhpd.term_start),
			SUM(ISNULL(sddh.volume ,
				    ABS(rhpd.hr1+rhpd.hr2+rhpd.hr3+rhpd.hr4+rhpd.hr5+rhpd.hr6+rhpd.hr7+rhpd.hr8+rhpd.hr9+rhpd.hr10+rhpd.hr11+rhpd.hr12+rhpd.hr13+rhpd.hr14+rhpd.hr15+rhpd.hr16+rhpd.hr17+rhpd.hr18+rhpd.hr19+rhpd.hr20+rhpd.hr21+rhpd.hr22+rhpd.hr23+rhpd.hr24))) 
			  AS deal_volume,
			 MAX(rhpd.deal_volume_uom_id)
			-- ,sdh1.source_deal_header_id
		FROM
			#temp_deals td
			INNER JOIN #temp_deals_account_group tdag ON td.temp_deal_id = tdag.temp_deal_id	
			INNER JOIN report_hourly_position_deal rhpd ON rhpd.term_start BETWEEN td.term_start AND td.term_end
				AND rhpd.source_deal_detail_id=td.source_deal_detail_id
			LEFT JOIN source_deal_header sdh1 ON sdh1.close_reference_id = td.source_deal_header_id 
				AND sdh1.internal_deal_subtype_value_id =20
			LEFT JOIN source_deal_header sdh2 ON sdh2.close_reference_id = ISNULL(sdh1.source_deal_header_id,td.source_deal_header_id) 
				AND sdh2.internal_deal_subtype_value_id =19	
			LEFT JOIN #source_deal_detail_hour sddh ON sddh.source_deal_header_id = ISNULL(sdh2.source_deal_header_id,sdh1.source_deal_header_id)
				AND sddh.location_id = td.location_id
				AND sddh.term_start = ISNULL(rhpd.term_start,td.term_start)
		WHERE
			 td.internal_deal_type_value_id IN(19,20,21)
			AND ISNULL(sddh.term_start,rhpd.term_start) IS NOT NULL '
		+CASE WHEN @calc_forward='n' THEN ' AND ISNULL(rhpd.term_start,rhpd.term_start) = '''+@as_of_date+'''' ELSE ' AND ISNULL(rhpd.term_start,rhpd.term_start)>'''+@as_of_date+'''' END+				
		' GROUP BY 
			COALESCE(sddh.source_deal_header_id,td.source_deal_header_id),td.location_id,
			ISNULL(sddh.term_start,rhpd.term_start)'
	print @sqlstmt	
	EXEC(@sqlstmt)


-- Get the actual volume for transportaion deals
	SET @sqlstmt='
		INSERT INTO #temp_actual_vol(source_deal_header_id,location_id,term_start,deal_volume,uom_id)
		SELECT
			td.source_deal_header_id,
			td.location_id,
			rhpd.term_start,
			SUM(COALESCE(ds.delivered_volume,mv.volume ,
				    ABS(rhpd.hr1+rhpd.hr2+rhpd.hr3+rhpd.hr4+rhpd.hr5+rhpd.hr6+rhpd.hr7+rhpd.hr8+rhpd.hr9+rhpd.hr10+rhpd.hr11+rhpd.hr12+rhpd.hr13+rhpd.hr14+rhpd.hr15+rhpd.hr16+rhpd.hr17+rhpd.hr18+rhpd.hr19+rhpd.hr20+rhpd.hr21+rhpd.hr22+rhpd.hr23+rhpd.hr24))) 
			  AS deal_volume,
			 MAX(rhpd.deal_volume_uom_id)
		FROM
			#temp_deals td
			INNER JOIN #temp_deals_account_group tdag ON td.temp_deal_id = tdag.temp_deal_id	
			INNER JOIN report_hourly_position_deal rhpd ON rhpd.term_start BETWEEN td.term_start AND td.term_end
				AND rhpd.source_deal_detail_id=td.source_deal_detail_id			
			OUTER APPLY (SELECT MAX(estimated_delivery_date) estimated_delivery_date FROM  delivery_status ds WHERE ds.source_deal_detail_id = td.source_deal_detail_id) ds1
			LEFT JOIN delivery_status ds ON ds1.estimated_delivery_date = ds.estimated_delivery_date AND ds.source_deal_detail_id = td.source_deal_detail_id 
				AND td.leg = 1
			OUTER APPLY(
				SELECT SUM(mvh.hr1+mvh.hr2+mvh.hr3+mvh.hr4+mvh.hr5+mvh.hr6+mvh.hr7+mvh.hr8+mvh.hr9+mvh.hr10+mvh.hr11+mvh.hr12+mvh.hr13+mvh.hr14+mvh.hr15+mvh.hr16+mvh.hr17+mvh.hr18+mvh.hr19+mvh.hr20+mvh.hr21+mvh.hr22+mvh.hr23+mvh.hr24) volume
				FROM
					source_minor_location_meter smlm
					INNER JOIN mv90_data mv ON smlm.meter_id = mv.meter_id
					INNER JOIN mv90_data_hour mvh ON mvh.meter_data_id = mv.meter_data_id
				WHERE
					smlm.source_minor_location_id = td.location_id
					AND mvh.prod_date = rhpd.term_start
			) mv
		WHERE
			td.internal_deal_type_value_id IN(15,16)
			AND rhpd.term_start IS NOT NULL '
			
		+CASE WHEN @calc_forward='n' THEN ' AND ISNULL(rhpd.term_start,rhpd.term_start) = '''+@as_of_date+'''' ELSE ' AND ISNULL(rhpd.term_start,rhpd.term_start)>'''+@as_of_date+'''' END+				
		' GROUP BY 
			td.source_deal_header_id,td.location_id,
			rhpd.term_start'
	print @sqlstmt	
	EXEC(@sqlstmt)





	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '****************END OF Deal Filters *****************************'	
	END

---Section 1.6 caclulate weighted average cost
	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'Section 1.6 sql_log_' + cast(@log_increment as VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=getdate()
		print @pr_name+' Running..............'
	END


	CREATE TABLE #temp_cost(
		gl_code INT,
		deal_category_value_id INT,
		source_deal_header_id INT,
		source_deal_detail_id INT,
		inventory FLOAT,
		units FLOAT,
		group_id INT,
		gl_account_id INT,
		account_type_value_id INT,
		account_type_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT,
		contract_expiration_date DATETIME,		
		cost_calc_type CHAR(1) COLLATE DATABASE_DEFAULT,
		fas_deal_type_value_id INT,
		uom_id INT,
		term_start DATETIME,
		as_of_date DATETIME,
		currency_id INT,
		price FLOAT
	)


--select * from #temp_deals

--WHILE CAST(@as_of_date as datetime)<=cast(@as_of_date_to as datetime)
--BEGIN
	
	DELETE FROM  #temp_cost
	DELETE FROM #prior_wght_avg_cost
	DELETE FROM #wght_avg_cost


	delete from #temp_curves
	SET @sqlstmt= CAST('' AS VARCHAR(MAX)) + '
		INSERT INTO #temp_cost
		select 	
				
				tdag.InvGL,
				td.deal_category_value_id,
				'+CASE WHEN @use_net_volume = 'y' THEN 'MAX(td.source_deal_header_id)' ELSE',td.source_deal_header_id'  END +',
				'+CASE WHEN @use_net_volume = 'y' THEN 'MAX(td.source_deal_detail_id)' ELSE 'td.source_deal_detail_id' END+' ,						
				sum(CASE WHEN (exclude_inventory = ''y'') THEN 0 
						ELSE	
					-- this one is for any buy or sell that excludes sell that match a buy	DEBIT Buy Credit Sell
					case when (current_buy_sell = 1 AND ((buy_sell_flag = ''s'' AND td.assignment_type_value_id IS NULL) OR
									buy_sell_flag = ''b'' )) then
						case when (buy_sell_flag = ''b'') then 1 else -1 end * ISNULL(tav.deal_volume,0)*  
							case when (isnull(td.status_value_id, -1) IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) NOT IN(475,476))
								then 0 else

							case when (buy_sell_flag = ''s'' AND td.assignment_type_value_id IS NULL and cost_approach_id = 952) then 
								isnull(1, 0) else (ISNULL(fixed_price,0) +ISNULL(price_adder,0)+(dbo.FNARecCurve(ISNULL(tav.term_start,td.term_start),'''+@as_of_date+''',td.formula_curve_id,1,NULL,NULL, NULL,NULL,NULL))/ISNULL(conv.conversion_factor,1))*price_multiplier* ISNULL(sc.factor,1) end end
					else 0 end +
					-- this one is for the one that is expiring/surrender or that got sold which has a sale position tied to the original buy
					--Creit that expires for sold
					case when (--adjustments = 0 AND 
						((expiring = 1 AND buy_sell_flag = ''b'') OR (surrender = 1 AND buy_sell_flag = ''s'') OR isnull(td.assignment_type_value_id, 5149) = 5173)) then
						case when ((expiring = 1 AND buy_sell_flag = ''b'') OR buy_sell_flag = ''s'') then -1 else 1 end * ISNULL(tav.deal_volume,0)*
							case when (isnull(td.status_value_id, -1) IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) NOT IN(475,476))
								then 0 else
							case when (cost_approach_id = 952) then 
								isnull(1, 0) else (ISNULL(fixed_price,0) +ISNULL(price_adder,0)+(dbo.FNARecCurve(ISNULL(tav.term_start,td.term_start),'''+@as_of_date+''',td.formula_curve_id,1,NULL,NULL, NULL, NULL,NULL))/ISNULL(conv.conversion_factor,1))*price_multiplier* ISNULL(sc.factor,1) end end
					else 0 end END  +
					-- Broker fees
					CASE WHEN tdag.use_broker_fees=''y'' THEN 
						 CASE WHEN td.unit_fixed_flag=''f'' THEN broker_fixed_cost
							  ELSE broker_unit_fees * ISNULL(tav.deal_volume,0) END
						 ELSE 0 END	)	
					 as inventory,
				sum(CASE WHEN (exclude_inventory = ''y'') THEN 0 ELSE	
				-- this one is for any buy or sell that excludes sell that match a buy	DEBIT Buy Credit Sell
				case when (current_buy_sell = 1 AND ((buy_sell_flag = ''s'' AND td.assignment_type_value_id is NULL) OR
								buy_sell_flag = ''b'' )) then
					case when (buy_sell_flag = ''b'') then 1 else -1 end * 
						case when (td.status_value_id IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) NOT IN(475,476)) then 0 else 1 end * ISNULL(tav.deal_volume,0)
				else 0 end +
				-- this one is for the one that is expiring/surrender or that got sold which has a sale position tied to the original buy
				--Creit that expires for sold
				case when (--adjustments = 0 AND 
					( (expiring = 1 AND buy_sell_flag = ''b'') OR (surrender = 1 AND buy_sell_flag = ''s'') OR isnull(td.assignment_type_value_id, 5149) = 5173) ) then
					case when ((expiring = 1 AND buy_sell_flag = ''b'') OR buy_sell_flag = ''s'') then -1 else 1 end * 
						case when (td.status_value_id IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) NOT IN(475,476)) then 0 else 1 end * ISNULL(tav.deal_volume,0)
				else 0 end END) as units,
				 tdag.group_id,
				 tdag.gl_account_id,
				 tdag.account_type_value_id,
				 tdag.account_type_name,
				 '+CASE WHEN @use_net_volume = 'y' THEN 'MAX(td.buy_sell_flag)' ELSE 'td.buy_sell_flag' END+',
				 max(td.contract_expiration_date) contract_expiration_date,
				 MAX(cost_calc_type) cost_calc_type,
				 td.fas_deal_type_value_id,
				 MAX(ISNULL(tav.uom_id,td.deal_volume_uom_id)),
				 ISNULL(tav.term_start,td.term_start),
				 '''+@as_of_date+''',
				 --MAX(ISNULL(sc.currency_id_to,sc.source_currency_id)) currency_id,
				 MAX(COALESCE(sc.currency_id_to,sc.source_currency_id,td.fixed_price_currency_id)) currency_id,
				 --MAX(ISNULL(fixed_price,0)) +MAX(ISNULL(price_adder,0))+MAX((ISNULL(dbo.FNARecCurve(ISNULL(tav.term_start,td.term_start),'''+@as_of_date+''',td.formula_curve_id,1,NULL,NULL, NULL, NULL,NULL), 0)/ISNULL(conv.conversion_factor,1))*ISNULL(price_multiplier,1)* ISNULL(sc.factor,1)) price
				 ISNULL(td.fixed_price,0) +MAX(ISNULL(price_adder,0))+MAX((ISNULL(dbo.FNARecCurve(ISNULL(tav.term_start,td.term_start),'''+@as_of_date+''',td.formula_curve_id,1,NULL,NULL, NULL, NULL,NULL), 0)/ISNULL(conv.conversion_factor,1))*ISNULL(price_multiplier,1)* ISNULL(sc.factor,1)) price
				 
			FROM    
					 #temp_deals td
					INNER JOIN #temp_deals_account_group tdag ON td.temp_deal_id=tdag.temp_deal_id
					LEFT JOIN #temp_actual_vol tav
						ON tav.source_deal_header_id = td.source_deal_header_id
						AND tav.location_id = td.location_id
						AND tav.term_start BETWEEN td.term_start AND td.term_end					
					LEFT JOIN #temp_curves tc ON tc.source_curve_def_id = td.curve_id AND 
						 tc.maturity_date = CASE WHEN ('+CAST(@assessment_curve_type_value_id AS VARCHAR)+'= 77) THEN
										dbo.FNAGetSQLStandardDate(td.maturity_date)
									ELSE  ''' + @as_of_date + '''   END 
						AND tc.as_of_date= case when (td.contract_expiration_date < ''' + @as_of_date + ''') then td.contract_expiration_date else ''' + @as_of_date + ''' end
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = td.formula_curve_id
					LEFT JOIN source_currency sc ON sc.source_currency_id = spcd.source_currency_id
					LEFT JOIN rec_volume_unit_conversion conv ON 
						conv.from_source_uom_id=spcd.uom_id
						AND conv.to_source_uom_id=ISNULL(tav.uom_id,td.deal_volume_uom_id)			
											
			WHERE
				td.term_end>=CAST('''+@as_of_date+''' AS DATETIME)
			GROUP BY 
				tdag.gl_account_id,tdag.InvGL'+CASE WHEN @use_net_volume = 'y' THEN '' ELSE',td.source_deal_header_id'  END +',td.deal_category_value_id'+CASE WHEN @use_net_volume = 'y' THEN '' ELSE ',td.buy_sell_flag' END+', 
				tdag.account_type_value_id, tdag.account_type_name,tdag.group_id'+CASE WHEN @use_net_volume = 'y' THEN '' ELSE ',td.source_deal_detail_id' END+',td.fas_deal_type_value_id,ISNULL(tav.term_start,td.term_start), td.fixed_price
		'
	PRINT @sqlstmt
	EXEC(@sqlstmt)





	IF @use_net_volume ='y'
		UPDATE #temp_cost SET inventory =CASE WHEN units<0 THEN 0 ELSE units *ISNULL(price,1)  END,buy_sell_flag=CASE WHEN units<0 THEN 's' else 'b' end
	 


----- If no begining inverntoyr is defined then add the begining inventory from storage asset definition

		INSERT INTO calcprocess_inventory_wght_avg_cost(as_of_date,	group_id,gl_account_id,gl_code,wght_avg_cost,total_inventory,total_units,inventory_account_type,inventory_account_name,uom_id,currency_id)		
			SELECT 
				gsi.effective_date as_of_date,
				tc.group_id,
				tc.gl_account_id,
				tc.gl_code,
				beg_storage_cost wght_avg_cost,
				beg_storage_volume * beg_storage_cost total_inventory ,
				beg_storage_volume total_units ,
				tc.account_type_value_id,
				tc.account_type_name,
				tc.uom_id,
				ISNULL(gsi.cost_currency,tc.currency_id)
			FROM
				general_assest_info_virtual_storage gsi
				CROSS APPLY(SELECT DISTINCT group_id,gl_account_id,gl_code,account_type_name,account_type_value_id,uom_id,currency_id 
							FROM  
								#temp_cost tc INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tc.source_deal_detail_id
							WHERE sdd.location_id = gsi.storage_location
						) tc	
				OUTER APPLY (select gl_account_id FROM calcprocess_inventory_wght_avg_cost WHERE  gl_account_id = tc.gl_account_id AND group_id = tc.group_id) ciw
			WHERE ciw.gl_account_id IS NULL
	
				

-------------- Now Insert the Manual Journal Entry
			INSERT INTO #temp_cost(gl_code,deal_category_value_id,source_deal_header_id,source_deal_detail_id,inventory,units,group_id,gl_account_id,account_type_value_id,account_type_name,buy_sell_flag,contract_expiration_date,cost_calc_type,fas_deal_type_value_id,uom_id)	
			SELECT 
				iat.gl_number_id,	
				475,
				-1,
				-1,
				(-1*ISNULL(mjd.credit_amount,0))+(1*ISNULL(mjd.debit_amount,0)) as Inventory,
				 CASE WHEN mjd.credit_amount>0 THEN -1 ELSE 1 END*ISNULL(mjd.Volume,0),
				iatg.group_id,
				iat.gl_account_id,
				iat.account_type_value_id,
				iat.account_type_name,
				CASE WHEN mjd.debit_amount>0 THEN 'b' WHEN mjd.credit_amount>0 THEN 's' END as buy_sell,
				--mjh.as_Of_date,
				@as_of_date,	
				'w',
				400,
				mjd.uom
			FROM
				manual_je_header mjh
				JOIN manual_je_detail mjd ON mjh.manual_je_id=mjd.manual_je_id
				JOIN inventory_account_type iat ON iat.gl_account_id=mjd.gl_account_id
				JOIN inventory_account_type_group iatg ON iatg.group_id=iat.group_id
			WHERE 1=1
				AND ((@as_of_date>=mjh.as_of_date
						AND ISNULL(mjd.until_date,mjh.until_date)>=@as_of_date AND ISNULL(mjd.frequency,mjh.frequency)='r')
					  OR
					 (@as_of_date=mjh.as_of_date AND ISNULL(mjd.frequency,mjh.frequency)='o'))


		------------------------
		-- FIND OUT THE prior Weighted average value

			--select * from calcprocess_inventory_wght_avg_cost
			INSERT INTO #prior_wght_avg_cost
				SELECT	
					wacog.as_of_date,
					wacog.group_id,
					wacog.[gl_account_id],
					wacog.[gl_code],
					wacog.[wght_avg_cost],
					wacog.[total_inventory],
					wacog.[total_units],
					wacog.inventory_account_type,
					wacog.inventory_account_name,
					wacog.as_of_date,
					wacog.uom_id
				FROM
					(select MAX(as_of_date)as_of_date ,a.gl_account_id 
						FROM calcprocess_inventory_wght_avg_cost a 
							WHERE ((a.as_of_date<@as_of_date AND @calc_forward='n') OR (a.as_of_date<=@as_of_date AND @calc_forward='y')) GROUP BY a.gl_account_id)a
					JOIN calcprocess_inventory_wght_avg_cost wacog 
						ON a.gl_account_id=wacog.gl_account_id AND a.as_of_date=wacog.as_of_date
				WHERE
					(group_id=@account_group_id OR @account_group_id IS NULL)
		-- If there is no data for the as of date then insert the 0 values
				INSERT INTO #temp_cost(gl_code,deal_category_value_id,source_deal_header_id,source_deal_detail_id,inventory,units,group_id,gl_account_id,account_type_value_id,account_type_name,buy_sell_flag,contract_expiration_date,cost_calc_type,fas_deal_type_value_id)	
				SELECT pwac.gl_code,475,-2,-2,0,0,pwac.group_id,pwac.gl_account_id,inventory_account_type,inventory_account_name,'b',
						pwac.as_of_date,'w',400
				FROM
					#prior_wght_avg_cost pwac
					LEFT JOIN #temp_cost tc
					ON tc.gl_code=pwac.gl_code	and tc.buy_sell_flag='b'
				WHERE 1=1			
					AND  tc.gl_code IS NULL	
				
				
		IF NOT EXISTS(select * from #prior_wght_avg_cost)
				INSERT INTO #prior_wght_avg_cost
				SELECT	
					@as_of_date,
					tc.group_id,
					tc.[gl_account_id],
					tc.[gl_code],
					SUM(CASE WHEN buy_sell_flag='s' THEN 0 ELSE [inventory] END )/ISNULL(NULLIF(SUM(CASE WHEN buy_sell_flag='s' THEN 0 ELSE [units] END),0),1)[wght_avg_cost],
					0 [total_inventory],
					0 [total_units],
					tc.account_type_value_id,
					tc.account_type_name,
					@as_of_date,
					MAX(tc.uom_id)
				FROM
					#temp_cost tc
					WHERE  1=1 
					AND MONTH(term_start)=MONTH(@as_of_date)
					AND YEAR(term_start)=YEAR(@as_of_date)
					
				GROUP BY tc.group_id,
					tc.[gl_account_id],
					tc.[gl_code],
					tc.account_type_value_id,
					tc.account_type_name
		ELSE
			UPDATE prior_wacog
				SET prior_wacog.[wght_avg_cost]=cur_wacog.[wght_avg_cost]

			FROM
				#prior_wght_avg_cost prior_wacog
			INNER JOIN 
			(	SELECT		
						tc.[gl_account_id],
						tc.[gl_code],
						SUM([inventory]+[total_inventory])/ISNULL(NULLIF(SUM([units]+wacog.[total_units]),0),1)[wght_avg_cost],
						SUM([inventory]+[total_inventory]) [total_inventory],
						SUM([units]+wacog.[total_units]) [total_units]
					FROM	
						(SELECT SUM(CASE WHEN buy_sell_flag='s' THEN 0 ELSE [units] END)[units],SUM(CASE WHEN buy_sell_flag='s' THEN 0 ELSE [inventory] END)inventory, gl_account_id,[gl_code] 
							FROM #temp_cost tc 
							WHERE
								MONTH(term_start)=MONTH(@as_of_date)
								AND YEAR(term_start)=YEAR(@as_of_date)
							GROUP BY gl_account_id,[gl_code]) tc
						LEFT JOIN #prior_wght_avg_cost wacog ON tc.gl_account_id=wacog.gl_account_id
					WHERE 1=1
						--AND buy_sell_flag='b'
					GROUP BY tc.[gl_account_id],tc.[gl_code]
			) cur_wacog
			ON prior_wacog.[gl_account_id]=cur_wacog.[gl_account_id]


		---######## Find Out Weighted average cost
		IF @calc_forward = 'n'
		BEGIN
			INSERT INTO #wght_avg_cost
				select 	
					--(tc.contract_expiration_date) as_of_date, 
					@as_of_date,
					tc.group_id,
					tc.gl_account_id,
					tc.gl_code,
					--tc.buy_sell_flag,
					(sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
											CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*wacog.wght_avg_cost END END)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_inventory ELSE 0 END),0))/(case when (sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_units ELSE 0 END),0)= 0) then  1 else sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_units ELSE 0 END),0) END)  wght_avg_cost,
					sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
											CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*wacog.wght_avg_cost END END)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_inventory ELSE 0 END),0) total_inventory, 
					sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_units ELSE 0 END),0)total_units,
					tc.account_type_value_id,
					tc.account_type_name,
					MAX(tc.contract_expiration_date),--,tc.source_deal_header_id
					MAX(ISNULL(tc.uom_id,wacog.uom_id)),
					MAX(currency_id)
				from 
					 #temp_cost tc
					 LEFT JOIN #prior_wght_avg_cost wacog ON tc.gl_account_id=wacog.gl_account_id
					 LEFT JOIN inventory_cost_override ico ON ico.source_deal_header_id=tc.source_deal_header_id	
				WHERE 1=1
					AND tc.gl_code IS NOT NULL	
					AND tc.fas_deal_type_value_id<>408
				group by tc.gl_code,tc.account_type_value_id,tc.account_type_name,tc.group_id,tc.gl_account_id



			DELETE 
				a
			FROM 
				calcprocess_inventory_wght_avg_cost a,
				#wght_avg_cost b	
			WHERE 
				a.as_of_date=b.as_of_date
				AND a.as_of_date=b.as_of_date
				AND a.group_id=b.group_id
				AND a.gl_account_id=b.gl_account_id


			INSERT INTO calcprocess_inventory_wght_avg_cost(as_of_date,	group_id,gl_account_id,gl_code,wght_avg_cost,total_inventory,total_units,inventory_account_type,inventory_account_name,uom_id,currency_id)		
			SELECT 
				as_of_date,
				group_id,
				gl_account_id,
				gl_code,
				CASE WHEN total_inventory< 0 THEN 0 ELSE wght_avg_cost END ,
				CASE WHEN total_inventory< 0 THEN 0 ELSE total_inventory END,
				CASE WHEN total_units< 0 THEN 0 ELSE total_units END,
				inventory_account_type,
				inventory_account_name,
				uom_id,
				currency_id		
			FROM
				#wght_avg_cost
	END
	ELSE
	BEGIN	
	
			INSERT INTO #wght_avg_cost_forward
			select 	
				@as_of_date,
				(tc.term_start),
				tc.group_id,
				tc.gl_account_id,
				tc.gl_code,
				(sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
										CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*wacog.wght_avg_cost END END)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_inventory ELSE 0 END),0))/(case when (sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_units ELSE 0 END),0)= 0) then  1 else sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_units ELSE 0 END),0) END)  wght_avg_cost,
				sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
										CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*wacog.wght_avg_cost END END)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_inventory ELSE 0 END),0) total_inventory, 
				sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN wacog.total_units ELSE 0 END),0)total_units,
				tc.account_type_value_id,
				tc.account_type_name,
				MAX(tc.contract_expiration_date),
				MAX(ISNULL(tc.uom_id,wacog.uom_id)),
				MAX(tc.currency_id)
			from 
				 #temp_cost tc
				 LEFT JOIN #prior_wght_avg_cost wacog ON tc.gl_account_id=wacog.gl_account_id
				 LEFT JOIN inventory_cost_override ico ON ico.source_deal_header_id=tc.source_deal_header_id	
			WHERE 1=1
				AND MONTH(term_start)=MONTH(@as_of_date)
				AND YEAR(term_start)=YEAR(@as_of_date)
				AND DAY(term_start)=DAY(@as_of_date)
				AND tc.gl_code IS NOT NULL	
				AND tc.fas_deal_type_value_id<>408
			group by tc.gl_code,tc.account_type_value_id,tc.account_type_name,tc.group_id,tc.gl_account_id,(tc.term_start)

	
	-- for each forward month the weighted average price should the wacog of last month
	
		DECLARE @term_date DATETIME,@wacog FLOAT,@total_inventory FLOAT, @total_units FLOAT
	
		DECLARE cur1 CURSOR for
		SELECT 	gl_account_id,(term_start) FROM #temp_cost WHERE term_start>(@as_of_date) GROUP BY gl_account_id,(term_start) ORDER BY  gl_account_id,(term_start)
		OPEN cur1
		FETCH NEXT FROM cur1 INTO @gl_account_id,@term_date
		WHILE @@FETCH_STATUS=0
		BEGIN
		

		-- get the previous wacog and calculate the current one
		IF NOT EXISTS(SELECT * FROM #wght_avg_cost_forward)
		
			SELECT
				 @wacog= wght_avg_cost,
				 @total_inventory = total_inventory,
				 @total_units = total_units
			FROM 
				calcprocess_inventory_wght_avg_cost WHERE gl_account_id=@gl_account_id AND as_of_date=@as_of_date
		ELSE
			SELECT
				 @wacog= wght_avg_cost,
				 @total_inventory = total_inventory,
				 @total_units = total_units
			FROM 
				#wght_avg_cost_forward  a
				INNER JOIN (SELECT MAX(term_date) term_date,gl_account_id FROM #wght_avg_cost_forward WHERE term_date<@term_date GROUP BY gl_account_id) b
				ON a.gl_account_id=b.gl_account_id
				AND a.term_date=b.term_date
				WHERE a.gl_account_id =@gl_account_id 

		
			
			INSERT INTO #wght_avg_cost_forward
				select 	
					@as_of_date,
					(tc.term_start),
					tc.group_id,
					tc.gl_account_id,
					tc.gl_code,
					(sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
											CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*@wacog END END)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN @total_inventory ELSE @total_inventory END),0))/(case when (sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN @total_units ELSE @total_units END),0)= 0) then  1 else sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN @total_units ELSE @total_units END),0) END)  wght_avg_cost,
					sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
											CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*@wacog END END)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN @total_inventory ELSE @total_inventory END),0) total_inventory, 
					--sum(tc.units)+ISNULL(MAX(CASE WHEN tc.buy_sell_flag='b' THEN @total_units ELSE 0 END),0)total_units,
					sum(tc.units)+@total_units total_units,
					tc.account_type_value_id,
					tc.account_type_name,
					MAX(tc.contract_expiration_date),
					MAX(tc.uom_id),
					MAX(tc.currency_id)
				from 
					 #temp_cost tc
					 LEFT JOIN inventory_cost_override ico ON ico.source_deal_header_id=tc.source_deal_header_id	
				WHERE 1=1
					AND gl_account_id =@gl_account_id 
					AND MONTH(term_start)=MONTH(@term_date)
					AND YEAR(term_start)=YEAR(@term_date)
					AND DAY(term_start)=DAY(@term_date)
					AND tc.gl_code IS NOT NULL	
					AND tc.fas_deal_type_value_id<>408
				group by tc.gl_code,tc.account_type_value_id,tc.account_type_name,tc.group_id,tc.gl_account_id,(tc.term_start)
		
		
		
		FETCH NEXT FROM cur1 INTO @gl_account_id,@term_date
		END
		CLOSE cur1
		DEALLOCATE cur1
		
		
		DELETE 
			a
		FROM 
			calcprocess_inventory_wght_avg_cost_forward a,
			#wght_avg_cost_forward b	
		WHERE 
			a.as_of_date=b.as_of_date
			AND a.as_of_date=b.as_of_date
			AND a.group_id=b.group_id
			AND a.gl_account_id=b.gl_account_id
			AND a.term_date=b.term_date


		INSERT INTO calcprocess_inventory_wght_avg_cost_forward(as_of_date,term_date,group_id,gl_account_id,gl_code,wght_avg_cost,total_inventory,total_units,inventory_account_type,inventory_account_name,uom_id,currency_id)		
		SELECT 
			as_of_date,
			term_date,
			group_id,
			gl_account_id,
			gl_code,
			--CASE WHEN total_inventory< 0 THEN 0 ELSE wght_avg_cost END ,
			--CASE WHEN total_inventory< 0 THEN 0 ELSE total_inventory END,
			--CASE WHEN total_units< 0 THEN 0 ELSE total_units END,
			wght_avg_cost,
			total_inventory,
			total_units,
			inventory_account_type,
			inventory_account_name,
			uom_id,
			currency_id		
		FROM
			#wght_avg_cost_forward
	
	END
	

			-----
			If @print_diagnostic = 1
			BEGIN
				print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
				print '****************END OF Weighted Average Calculations *****************************'	
			END


		---#### Insert in calcprocess_inventory_deals
			-- DELET IF EXISTS
			DELETE a
			FROM 
					calcprocess_inventory_deals a,
					#temp_cost b
			WHERE
				--a.source_deal_header_id=b.source_deal_header_id
				a.gl_account_id=b.gl_account_id		
				AND a.as_of_date=@as_of_date
				AND calc_type = CASE @calc_forward WHEN 'y' THEN 'f' ELSE 's' END
--select * from #temp_cost
			INSERT INTO calcprocess_inventory_deals(as_of_date,gl_code,deal_category_value_id,source_deal_header_id,source_deal_detail_id,inventory,units,group_id,gl_account_id,account_type_value_id,account_type_name,buy_sell_flag,deal_date,cost_calc_type,fas_deal_type_value_id,term_date,calc_type)
				select 	
					tc.as_of_date, 
					tc.gl_code,	
					MAX(deal_category_value_id),
					tc.source_deal_header_id,
					tc.source_deal_detail_id,
					sum(CASE WHEN tc.buy_sell_flag='b' THEN tc.inventory ELSE 
											CASE WHEN ico.price IS NOT NULL THEN ico.price*tc.units WHEN ico.fixed_cost is NOT NULL THEN ico.fixed_cost ELSE tc.units*wacog.wght_avg_cost END END)  total_inventory, 
					sum(tc.units) total_units,
					tc.group_id,
					tc.gl_account_id,
					tc.account_type_value_id,
					tc.account_type_name,
					MAX(buy_sell_flag),
					tc.contract_expiration_date,
					MAX(cost_calc_type),
					MAX(fas_deal_type_value_id)	,
					tc.term_start,
					CASE @calc_forward WHEN 'y' THEN 'f' ELSE 's' END
				from 
					 #temp_cost tc
					 LEFT JOIN #prior_wght_avg_cost wacog
						ON tc.gl_account_id=wacog.gl_account_id --AND wacog.as_of_date=@as_of_date
					 LEFT JOIN inventory_cost_override ico ON ico.source_deal_header_id=tc.source_deal_header_id	
				WHERE 1=1
					AND tc.gl_code IS NOT NULL	
					AND tc.fas_deal_type_value_id<>408
					AND tc.source_deal_header_id<>-2
				group by tc.as_of_date,tc.gl_code,tc.account_type_value_id,tc.account_type_name,tc.group_id,tc.gl_account_id,tc.source_deal_header_id,tc.contract_expiration_date,tc.source_deal_detail_id,tc.term_start
			
			

	--SET @as_of_date=DATEADD(day,1,@as_of_date)
	--END

	--CREATE TABLE #COGS(gl_code INT,group_id INT,gl_account_id INT,inventory INT,Cost INT, as_of_date DATETIME)
	--INSERT INTO #COGS(gl_code,group_id,gl_account_id,inventory,Cost,as_of_date)
	--SELECT
	--		gl_code,group_id,gl_account_id,SUM(inventory),SUM(inventory/units) Cost,MAX(as_of_date)
	--FROM
	--	calcprocess_inventory_deals
	--WHERE buy_sell_flag='b'
	--	  AND as_of_date<=@as_of_date	
	--GROUP BY
	--	gl_code,group_id,gl_account_id


---Section 1.7 Insert into report_measurement_values_inventory
	IF @print_diagnostic = 1
	BEGIN
		SET @pr_name= 'Section 1.7 sql_log_' + cast(@log_increment as VARCHAR)
		SET @log_increment = @log_increment + 1
		SET @log_time=getdate()
		print @pr_name+' Running..............'
	END

/*
	DELETE FROM report_measurement_values_inventory
		WHERE as_of_date=@as_of_date
	

	insert into report_measurement_values_inventory(as_of_date,sub_entity_id,strategy_entity_id,book_entity_id,link_id,term_month,u_hedge_mtm,u_rec_mtm,u_hedge_st_asset,u_hedge_st_asset_units,u_hedge_st_liability,u_hedge_st_liability_units,u_pnl_settlement,u_pnl_settlement_units,u_pnl_inventory,u_pnl_inventory_units,u_sur_expense,u_sur_expense_units,u_inv_expense,u_inv_expense_units,u_exp_expense,u_exp_expense_units,u_revenue,u_revenue_units,u_liability,u_liability_units,gl_code_hedge_st_asset,gl_code_hedge_st_liability,gl_settlement,gl_inventory,gl_code_sur_expense,gl_code_inv_expense,gl_code_exp_expense,gl_code_u_revenue,gl_code_liability,currency_unit,uom_id,deal_date,create_user,create_ts)
	select 	
		td.contract_expiration_date, 
		td.sub_entity_id, 
		td.stra_entity_id,
		td.book_entity_id,
		td.source_deal_header_id, 
		dbo.FNAGetContractMonth(td.term_start) as term_month,
		--Contract value
		case when (buy_sell_flag = 'b') then -1 else 1 end * deal_volume * (fixed_price + formula_value) as u_hedge_mtm, 

		--REC value
		case when (buy_sell_flag = 'b') then -1 else 1 end * deal_volume * 
				((fixed_price + formula_value)) as u_rec_mtm, 

		---*****A/R (+increase Debit) - Credit
		case when (current_buy_sell = 0 OR  buy_sell_flag = 'b') then 0 else
			deal_volume * ((fixed_price + formula_value)) end as u_hedge_st_asset,
		
		case when (current_buy_sell = 0 OR  buy_sell_flag = 'b') then 0 else
			deal_volume end as u_hedge_st_asset_units,
		---*****End of A/R 

		---*****A/P	to reflect the total contract price (-increase Credit) + Debit
		--If GIS Recon Active or Inactive no A/P entries required .. just inventory
		case when (isnull(td.status_value_id, -1) IN (5177, 5178, 5179)) then 0 
		else

			case when (current_buy_sell = 0 OR  buy_sell_flag = 's') then 0 else
				-1 * deal_volume * (fixed_price + formula_value) end 
		end as u_hedge_st_liability,

		case when (isnull(td.status_value_id, -1) IN (5177, 5178, 5179) OR (fixed_price +formula_value) = 0) then 0 
		else

			case when (current_buy_sell = 0 OR  buy_sell_flag = 's') then 0 else
				@ap_multiplier * -1 * deal_volume end 
		end as u_hedge_st_liability_units,
		---*****End of A/P	to reflect the total contract price (Credit)
		0 as u_pnl_settlement,
		0 as u_pnl_settlement_units,

		---*****REC Inventory + Increase Debit (-decrease Credit)	
		CASE WHEN (exclude_inventory = 'y') THEN 0 
			 WHEN (cost_approach_id in(953,954,955)) THEN 0
			ELSE	
			-- this one is for any buy or sell that excludes sell that match a buy	DEBIT Buy Credit Sell
			case when (current_buy_sell = 1 AND ((buy_sell_flag = 's' AND assignment_type_value_id IS NULL) OR
							buy_sell_flag = 'b' )) then
				case when (buy_sell_flag = 'b') then 1 else -1 end * deal_volume * 
					case when (isnull(td.status_value_id, -1) IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) <> 475)
						then 0 else
					case when (buy_sell_flag = 's' AND cost_approach_id = 952) then 
						isnull(wght_avg_cost, 0) else (fixed_price + formula_value) end end
			else 0 end +
			-- this one is for the one that is expiring/surrender or that got sold which has a sale position tied to the original buy
			--Creit that expires for sold
			case when (--adjustments = 0 AND 
				((expiring = 1 AND buy_sell_flag = 'b') OR (surrender = 1 AND buy_sell_flag = 's') OR isnull(assignment_type_value_id, 5149) = 5173)) then
				case when ((expiring = 1 AND buy_sell_flag = 'b') OR buy_sell_flag = 's') then -1 else 1 end * deal_volume * 
					case when (isnull(td.status_value_id, -1) IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) <> 475 OR isnull(assignment_type_value_id,5149) = 5173)
						then 0 else
					case when (cost_approach_id = 952) then 
						isnull(wght_avg_cost, 0) else (fixed_price + formula_value) end end
			else 0 end 
		END as u_pnl_inventory,

		CASE WHEN (exclude_inventory = 'y') THEN 0 
			 WHEN (cost_approach_id in(953,954,955)) THEN 0	
			 ELSE		 

			-- this one is for any buy or sell that excludes sell that match a buy	DEBIT Buy Credit Sell
			case when (current_buy_sell = 1 AND ((buy_sell_flag = 's' AND assignment_type_value_id IS NULL) OR
							buy_sell_flag = 'b' )) then
				case when (buy_sell_flag = 'b') then 1 else -1 end * 
					case when (td.status_value_id IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) <> 475) then 0 else 1 end * deal_volume 
			else 0 end +
			-- this one is for the one that is expiring/surrender or that got sold which has a sale position tied to the original buy
			--Creit that expires for sold
			case when (--adjustments = 0 AND 
				( (expiring = 1 AND buy_sell_flag = 'b') OR (surrender = 1 AND buy_sell_flag = 's') OR isnull(assignment_type_value_id, 5149) = 5173)) then
				case when ((expiring = 1 AND buy_sell_flag = 'b') OR buy_sell_flag = 's') then -1 else 1 end * 
					case when (td.status_value_id IN (5170, 5179) OR isnull(td.deal_category_value_id, -1) <> 475) then 0 else 1 end * deal_volume 
			else 0 end 
		END as u_pnl_inventory_units,

		---*****End of REC Inventory	

		--Surrender expense (+increase Debit) decrease Credit

		case when (--adjustments = 0 AND 
	--		((surrender = 1 and buy_sell_flag = 'b') and isnull(assignment_type_value_id, 5149) NOT IN(5149, 5173))) then
			(surrender = 1 and buy_sell_flag = 's')) then
			case when (buy_sell_flag = 's') then 1 else -1 end * deal_volume * 
				case when (cost_approach_id = 952) then isnull(wght_avg_cost, 0) else 
					(fixed_price + formula_value) end
		else 0 end as u_sur_expense,	


		case when (--adjustments = 0 AND 
	--		((surrender = 1 and buy_sell_flag = 'b') and isnull(assignment_type_value_id, 5149) NOT IN(5149, 5173))) then
			(surrender = 1 and buy_sell_flag = 's')) then
			case when (buy_sell_flag = 's') then 1 else -1 end * deal_volume 
		else 0 end as u_sur_expense_units,	

		--Inventory expense (+increase Debit) decrease Credit
		--this one is for the original buy that has been sold Debit Inventory Expense
		case when (adjustments = 0 AND (buy_sell_flag = 's' and (isnull(assignment_type_value_id, 5149) = 5173 OR assignment_type_value_id is null))) then    
			case 	when (buy_sell_flag = 's') then -1 else 1 end * deal_volume * (fixed_price + formula_value)
		else 0 end as u_inv_expense,

		case when (adjustments = 0 AND (buy_sell_flag = 's' and (isnull(assignment_type_value_id, 5149) = 5173 OR assignment_type_value_id is null))) then    
			case 	when (buy_sell_flag = 's') then -1 else 1 end * deal_volume 
		else 0 end as u_inv_expense_units,

		--Expiration expense (+increase Debit) -decrease Credit
		case when (adjustments = 0 AND ((expiring = 1 and buy_sell_flag = 'b') and isnull(assignment_type_value_id, 5149) IN (5144, 5149))) then
			case when (buy_sell_flag = 'b') then 1 else -1 end * deal_volume * 
				case when (cost_approach_id = 952) then isnull(wght_avg_cost, 0) else
					(fixed_price + formula_value) end
		else 0 end as u_exp_expense,

		case when (adjustments = 0 AND ((expiring = 1 and buy_sell_flag = 'b') and isnull(assignment_type_value_id, 5149) IN (5144, 5149))) then
			case when (buy_sell_flag = 'b') then 1 else -1 end * deal_volume 
		else 0 end as u_exp_expense_units,
		--this one is for A/R (+increase Debit) Revenue (- increase Credit)

		case when (current_buy_sell = 0 OR  buy_sell_flag = 'b') then 0 else    
			-1 * deal_volume * ((fixed_price + formula_value)) end  as u_revenue,

		case when (current_buy_sell = 0 OR  buy_sell_flag = 'b') then 0 else    
			-1 * deal_volume end  as u_revenue_units,

		0 as u_liability,
		0 as u_liability_units,

		tdag.ARGL as gl_code_hedge_st_asset, 
		tdag.APGL  as gl_code_hedge_st_liability, 
		tdag.ExpGL as gl_settlement, 
		tdag.InvGL gl_inventory,
		tdag.[SExpGL], -- REC Surrender Expense
		tdag.[IExpGL], -- REC Inventory Expense
		tdag.[EExpGL], -- REC Expiration Expense
		tdag.[RevGL], -- Revenue
		tdag.[LiabGL], -- Profit Liability 
		fixed_price_currency_id currency_unit,
		deal_volume_uom_id uom_id,
		td.deal_date,	
		@user_login_id create_user, 
		getdate() create_ts
	from #temp_deals td 
		INNER JOIN #temp_deals_account_group tdag ON td.temp_deal_id=tdag.temp_deal_id
		left outer join #wght_avg_cost wac ON 
		  --tdag.gl_account_id=wac.gl_account_id		
		  tdag.account_type_name=wac.inventory_account_name		
		--AND DATEADD(day,-1,isnull (td.deal_date,td.deal_date)) = wac.as_of_date
		
	where  1=1
		AND (isnull(td.status_value_id, -1) IN (5170, 5179)   -- if now not active then need to reverse prior entries 
		OR isnull(td.deal_category_value_id, -1) <> 475   -- if now not Real then need to reverse prior entries 
		--(fixed_price + formula_value) <> 0 OR
		OR ISNULL((fixed_price + formula_value),0) <> 0
		OR ISNULL((fixed_price + formula_value),0) = 0)
	--AND source_deal_header_id NOT IN(select ISNULL(deal_id,0) FROM calc_invoice_volume_detail)

*/
	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '*************** Inventory calc Completed *****************************'	
	END



---Section 1.8 Log errors and give message

	DECLARE @count_fail int
	DECLARE @count_total int
	DECLARE @desc VARCHAR(5000)
	DECLARE @user_name VARCHAR(100)
	DECLARE @url VARCHAR(500)
	set @count_fail = 0
	set @count_total = 0

	select @count_fail = count(*) from  #calc_status
	SELECT @count_total = COUNT(distinct source_deal_header_id) from #temp_deals 
	--select @count_success


	set @desc='Inventory Accounting Calculation done for as of date: '+ dbo.FNAUserDateFormat(@as_of_date, @user_login_id) +
		'  Total Deals Processed Count: ' + cast(@count_total as varchar) + ' Deals Failed Count: ' +
		 cast(@count_fail as varchar) 

	insert into #calc_status values(@process_id, case when @count_fail = 0 then 'Success' else 'Error' end,
	'Accounting Entries','Run Inventory Accounting Entries','Results', --'Successful',
	@desc,'')


	if @process_id is NULL 
	Begin

		select errorcode,module,source,type,[description],nextstep from #calc_status
		return
	END
	else
	Begin
		insert into inventory_accounting_log(process_id,code,module,source,type,[description],nextsteps)  
		select * from #calc_status where process_id=@process_id
		
		SET @user_name = @user_login_id
		declare @urlM varchar(500),@descM varchar(2000)

		SET @url = '../../dev/spa_html.php?__user_name__=' + @user_name + 
			'&spa=exec spa_get_inventory_accounting_log ''' + @process_id + ''''
		
		SET @urlM = './dev/spa_html.php?__user_name__=' + @user_name + 
			'&spa=exec spa_get_inventory_accounting_log ''' + @process_id + ''''

		DECLARE @error_count int
		DECLARE @type char
		
		SELECT  @error_count =   COUNT(*) 
		FROM        inventory_accounting_log
		WHERE     process_id = @process_id AND code = 'Error'
		
		If @error_count > 0 
			SET @type = 'e'
		Else
			SET @type = 's'


		set @desc = 'Inventory Accounting Entries are calculated as of date ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) 
				+ '. Total records processed: ' + cast(@count_total as varchar)		


		If @type = 'e'
		begin
			set @descM = '<a target="_blank" href="' + @urlM + '">'  + @desc + 
				case when (@type = 'e') then ' (ERRORS found)' else '' end +
				'.</b></a>'

			SET @desc = '<a target="_blank" href="' + @url + '">' + @desc + 
				case when (@type = 'e') then ' (ERRORS found)' else '' end +
				'.</b></a>'
			
		end
		else
			set @descM = @desc

		--If @counterparty_id is null OR @type = 'e'
		--	EXEC  spa_message_board 'i', @user_name,
		--				NULL, 'Inventory Accounting',
		--				@descM, '', '', @type, @job_name
		


	End

/************************************* Object: 'spa_calc_inventory_accounting_entries_job' END *************************************/

