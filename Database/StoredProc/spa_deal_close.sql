
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_close]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_deal_close]
GO

/**  

	Procedure used to close a Future deal and create new physical deal  
	
	Parameters
	@flag		: Operation flag that decides the action to be performed. Does not accept NULL.
	@per_close  : Close volume percentage		 
	@xmlValue	: XML with Deal fields values
	@deal_id	: Source Deal Header ID
*/


CREATE PROC [dbo].[spa_deal_close]
	@flag NCHAR(1),
	@per_close float = NULL,
	@xmlValue NVARCHAR(max) = NULL,
	@deal_id INT = NULL
AS
SET NOCOUNT ON
--declare @per_close float,@xmlValue NVARCHAR(max)
--set @per_close =NULL
--set @xmlValue='
--<Root><PSRecordset  edit_grid0="1" edit_grid1="04/08/2009" edit_grid2="04/30/2009" 
--edit_grid3="1" edit_grid4="b" edit_grid5="3434" edit_grid6="3434" edit_grid7="200" edit_grid8="4" 
--edit_grid9="d" edit_grid10="330" edit_grid11="0" edit_grid12="2" edit_grid13="2197"></PSRecordset></Root>'
--drop table #ztbl_xmlvalue

DECLARE @sql NVARCHAR(MAX)
IF @flag = 's'
BEGIN
	SELECT sdd.term_start,
           sdd.term_end,
           sdd.Leg,
           GETDATE() [post_date],
           dbo.FNARemoveTrailingZero(sdd.fixed_price) [price],
           dbo.FNARemoveTrailingZero((sdd.deal_volume - ISNULL(vol.volume, 0))) [floating_volume],
           su.uom_name [uom]
	FROM source_deal_detail sdd
    LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
    OUTER APPLY (
    	SELECT SUM(sdd.deal_volume) [volume] 
    	FROM source_deal_header sdh
    	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
    	WHERE sdh.close_reference_id = @deal_id
    ) vol
    WHERE sdd.source_deal_header_id = @deal_id  
END
IF @flag = 'p'
BEGIN
	DECLARE @deal_type INT
	SELECT @deal_type = source_deal_type_id
	FROM source_deal_type 
	WHERE source_deal_type_name = CASE WHEN @flag = 'g' THEN 'Swap' ELSE 'Future' END 
	AND sub_type = 'n'
		
	SET @sql = 'SELECT dbo.FNATRMWinHyperlink(''i'', 10131010, sdh.source_deal_header_id, sdh.source_deal_header_id, ''n'', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, 1) [deal_id], ' + CHAR(10)
			 + '           dbo.FNADateFormat(sdd.term_start) [term_start], ' + CHAR(10)
			 + '           dbo.FNADateFormat(sdd.term_end) [term_end], ' + CHAR(10)
			 + '           dbo.FNADateFormat(sdh.deal_date) [post_date], ' + CHAR(10)
			 + '           spcd.curve_name [index], ' + CHAR(10)
			 +	'		   dbo.FNARemoveTrailingZero(sdd.price_adder) [adder_discount], ' + CHAR(10)
			 + '           dbo.FNARemoveTrailingZero(sdd.deal_volume) [volume], ' + CHAR(10)
			 + '           dbo.FNARemoveTrailingZero(sdd.fixed_price) [ppost_price] ' + CHAR(10)
			 + '    FROM source_deal_header sdh ' + CHAR(10)
			 + '    INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id ' + CHAR(10)
			 + '    INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id ' + CHAR(10)
			 + '	WHERE sdh.close_reference_id = ' + CAST(@deal_id AS NVARCHAR(20))
	exec spa_print @sql
	EXEC(@sql)
END
IF @flag = 'c'
BEGIN
	DECLARE @idoc INT
	DECLARE @spa NVARCHAR(MAX)
	DECLARE @user_login_id NVARCHAR(100)
	DECLARE @job_name NVARCHAR(100)


	exec sp_xml_preparedocument @idoc OUTPUT, @xmlValue
	
	IF OBJECT_ID('tempdb..#ztbl_xmlvalue') IS NOT NULL
		DROP TABLE #ztbl_xmlvalue
		
	CREATE TABLE #ztbl_xmlvalue (
		deal_header_id INT,
		detail_id INT,
		term_start DATETIME,
		term_end DATETIME,
		deal_date DATETIME,
		curve_id int,
		buy_sell_flag NCHAR(1) COLLATE DATABASE_DEFAULT,
		deal_volume FLOAT,
		left_volume FLOAT,
		close_volume FLOAT,
		deal_volume_frequency NCHAR(1) COLLATE DATABASE_DEFAULT,
		deal_volume_uom_id  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		fixed_price  NVARCHAR(100) COLLATE DATABASE_DEFAULT,	 
		fixed_price_currency_id  NVARCHAR(100) COLLATE DATABASE_DEFAULT,
		leg INT
	)

	INSERT INTO #ztbl_xmlvalue (deal_header_id, deal_date, close_volume, left_volume, fixed_price)
	SELECT 
		deal_header_id,
		deal_date,
		close_volume,
		left_volume,
		fixed_price
	FROM OPENXML (@idoc, '/Form/FormXML',2)
	WITH ( 
		deal_header_id int						'@deal_id',
		deal_date  NVARCHAR(100)					'@close_date',
		close_volume  FLOAT						'@close_volume',
		left_volume  FLOAT						'@left_volume',
		fixed_price  NVARCHAR(100)				'@fixed_price'			
	)
	
	UPDATE z
	SET term_start = sdd.term_start,
		term_end = sdd.term_end,
		detail_id = sdd.source_deal_detail_id,
		curve_id = sdd.curve_id,
		buy_sell_flag = sdd.buy_sell_flag,
		deal_volume = sdd.deal_volume,
		deal_volume_frequency = sdd.deal_volume_frequency,
		deal_volume_uom_id= sdd.deal_volume_uom_id,
		fixed_price_currency_id = sdd.fixed_price_currency_id,
		leg = sdd.leg	
	FROM #ztbl_xmlvalue z
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = z.deal_header_id
	
   
	 UPDATE #ztbl_xmlvalue SET fixed_price = NULL WHERE fixed_price = ''
	 DECLARE @primary_deal_id NVARCHAR(100)
	SELECT  @primary_deal_id=deal_header_id FROM #ztbl_xmlvalue
       
   
	exec sp_xml_removedocument @idoc
	declare @process_id NVARCHAR(100)
	SET @process_id = REPLACE(newid(),'-','_')


	--
	--select @per_close
	--return
	declare @deal_header_id int,@leg int , @term_start datetime,@term_end datetime,@deal_volume float

	BEGIN try
	BEGIN tran
		INSERT INTO [dbo].[source_deal_header]([source_system_id]
			,[deal_id],[deal_date],[ext_deal_id],[physical_financial_flag],[structured_deal_id]
			,[counterparty_id],[entire_term_start],[entire_term_end],[source_deal_type_id],[deal_sub_type_type_id]
			,[option_flag],[option_type],[option_excercise_type],[source_system_book_id1],[source_system_book_id2]
			,[source_system_book_id3],[source_system_book_id4],[description1],[description2],[description3]
			,[deal_category_value_id],[trader_id],[internal_deal_type_value_id],[internal_deal_subtype_value_id],[template_id]
			,[header_buy_sell_flag],[broker_id],[generator_id],[status_value_id],[status_date]
			,[assignment_type_value_id],[compliance_year],[state_value_id],[assigned_date],[assigned_by]
			,[generation_source],[aggregate_environment],[aggregate_envrionment_comment],[rec_price],[rec_formula_id]
			,[rolling_avg],[contract_id],[create_user],[create_ts],[update_user]
			,[update_ts],[legal_entity],[internal_desk_id],[product_id],[internal_portfolio_id]
			,[commodity_id],[reference],[close_reference_id] ,[block_type],[block_define_id],[granularity_id],[Pricing],[term_frequency]
			,[deal_locked],unit_fixed_flag,broker_fixed_cost,broker_unit_fees,broker_currency_id,deal_status,confirm_status_type)
		SELECT dh.[source_system_id]
			,cast(dh.[source_deal_header_id] as NVARCHAR)+'_Close_'+@process_id,t.[deal_date],
			 --dh.[deal_id] ,
			 dh.ext_deal_id,
			 dh.[physical_financial_flag],dh.[structured_deal_id]
			,dh.[counterparty_id],dh.[entire_term_start],dh.[entire_term_end],dh.[source_deal_type_id],dh.[deal_sub_type_type_id]
			,dh.[option_flag],dh.[option_type],dh.[option_excercise_type],dh.[source_system_book_id1],dh.[source_system_book_id2]
			,dh.[source_system_book_id3],dh.[source_system_book_id4],dh.[description1],dh.[description2],dh.[description3]
			,dh.[deal_category_value_id],dh.[trader_id],dh.[internal_deal_type_value_id],dh.[internal_deal_subtype_value_id],dh.[template_id]
			,case WHEN dh.[header_buy_sell_flag]='b' THEN 's' ELSE 'b' end ,dh.[broker_id],dh.[generator_id],dh.[status_value_id],dh.[status_date]
			,dh.[assignment_type_value_id],dh.[compliance_year],dh.[state_value_id],dh.[assigned_date],dh.[assigned_by]
			,dh.[generation_source],dh.[aggregate_environment],dh.[aggregate_envrionment_comment],dh.[rec_price],dh.[rec_formula_id]
			,dh.[rolling_avg],dh.[contract_id],dbo.FNADBUser(),getdate(),dbo.FNADBUser()
			,getdate(),dh.[legal_entity],dh.[internal_desk_id],dh.[product_id],dh.[internal_portfolio_id]
			,dh.[commodity_id],dh.[reference],dh.source_deal_header_id ,[block_type],[block_define_id],[granularity_id],[Pricing],[term_frequency]
			,dh.deal_locked,dh.unit_fixed_flag,dh.broker_fixed_cost,dh.broker_unit_fees,dh.broker_currency_id,dh.deal_status,dh.confirm_status_type
		from [dbo].[source_deal_header] dh inner join (select distinct deal_header_id,deal_date from #ztbl_xmlvalue) t on dh.source_deal_header_id=t.deal_header_id
	

	
		SET @deal_header_id=scope_identity() 
		
		INSERT INTO source_deal_groups (
			source_deal_header_id,
			term_from,
			term_to,
			location_id,
			curve_id,
			detail_flag,
			leg
		)
		SELECT @deal_header_id, sdd.[term_start] ,sdd.[term_end], sdd.location_id, CASE WHEN sdd.location_id IS NULL THEN sdd.curve_id ELSE NULL END, 0, sdd.Leg
		FROM [dbo].[source_deal_detail] sdd INNER JOIN source_deal_header sdh
		ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		INNER JOIN source_deal_header sdh1 ON sdh1.deal_id = cast(sdh.[source_deal_header_id] AS NVARCHAR) + '_Close_' + @process_id
		INNER JOIN  #ztbl_xmlvalue t 
			ON sdh1.[close_reference_id] = t.deal_header_id 
			AND sdd.term_start = t.term_start 
			AND sdd.term_end = t.term_end 
			AND t.leg = sdd.leg 
			AND isnull(t.[close_volume], 0) <> 0
			
		DECLARE @group_id INT
		SET @group_id = scope_identity()
	
		INSERT INTO [dbo].[source_deal_detail]
					   ([source_deal_header_id]
					   ,[term_start]
					   ,[term_end]
					   ,[Leg]
					   ,[contract_expiration_date]
					   ,[fixed_float_leg]
					   ,[buy_sell_flag]
					   ,[curve_id]
					   ,[fixed_price]
					   ,[fixed_price_currency_id]
					   ,[option_strike_price]
					   ,[deal_volume]
					   ,[deal_volume_frequency]
					   ,[deal_volume_uom_id]
					   ,[block_description]
					   ,[deal_detail_description]
					   ,[formula_id]
					   ,[volume_left]
					   ,[settlement_volume]
					   ,[settlement_uom]
					   ,[create_user]
					   ,[create_ts]
					   ,[update_user]
					   ,[update_ts]
					   ,[price_adder]
					   ,[price_multiplier]
					   ,[settlement_date]
					   ,[day_count_id]
						,[location_id]
					  ,[meter_id]
					  ,[physical_financial_flag]
					  ,[Booked]
					  ,[process_deal_status]
					  ,capacity
					  ,pay_opposite
					  --,total_volume
					  ,volume_multiplier2
					  ,price_adder_currency2
					  ,price_adder2
					  ,formula_currency_id
					  ,fixed_cost_currency_id
					  ,adder_currency_id
					  ,multiplier
					  ,fixed_cost
					  , settlement_currency
					  , standard_yearly_volume
					  , source_deal_group_id
					)
			SELECT

						sdh1.source_deal_header_id
					   ,sdd.[term_start]
					   ,sdd.[term_end]
					   ,sdd.[Leg]
					   ,sdd.[contract_expiration_date]
					   ,sdd.[fixed_float_leg]
						,case WHEN sdd.[buy_sell_flag]='b' THEN 's' ELSE 'b' end
					   ,sdd.[curve_id]
					   ,t.[fixed_price]
					   ,sdd.[fixed_price_currency_id]
					   ,sdd.[option_strike_price]
					   ,case when isnull(@per_close,0)=0 then cast(t.[close_volume] as NUMERIC(38,20)) else  
							case when (sdd.[deal_volume]*(@per_close/100))<=t.[left_volume] then cast(sdd.[deal_volume]*(@per_close/100) as NUMERIC(38,20)) else cast(t.[left_volume] as NUMERIC(38,20)) end
						end
					   ,sdd.[deal_volume_frequency]
					   ,sdd.[deal_volume_uom_id]
					   ,sdd.[block_description]
					   ,sdd.[deal_detail_description]
					   ,sdd.[formula_id]
					   ,case when isnull(@per_close,0)=0 then cast(t.[close_volume] as NVARCHAR(100)) else  
								case when (sdd.[deal_volume]*(@per_close/100))<=t.[left_volume] then cast(sdd.[deal_volume]*(@per_close/100) as NVARCHAR(100)) else cast(t.[left_volume] as NVARCHAR(100)) end
						end
					   ,sdd.[settlement_volume]
					   ,sdd.[settlement_uom]
					   ,dbo.FNADBUser()
					   ,getdate()
					   ,dbo.FNADBUser()
					   ,getdate()
					   ,sdd.[price_adder]
					   ,sdd.[price_multiplier]
					   ,sdd.[settlement_date]
					   ,sdd.[day_count_id]
						,sdd.location_id
					  ,sdd.[meter_id]
					  ,sdd.[physical_financial_flag]
					  ,sdd.[Booked]
					  ,12500
					  ,sdd.capacity
					  ,sdd.pay_opposite
					  --,sdd.total_volume
					  ,sdd.volume_multiplier2
					  ,sdd.price_adder_currency2
					  ,sdd.price_adder2
					  ,sdd.formula_currency_id
					  ,sdd.fixed_cost_currency_id
					  ,sdd.adder_currency_id
					  ,sdd.multiplier
					  ,sdd.fixed_cost
					  , sdd.settlement_currency
					  , sdd.standard_yearly_volume
					  , @group_id
		FROM [dbo].[source_deal_detail] sdd inner join source_deal_header sdh
				on sdh.source_deal_header_id=sdd.source_deal_header_id 
				inner join source_deal_header sdh1 on sdh1.deal_id=cast(sdh.[source_deal_header_id] as NVARCHAR)+'_Close_'+@process_id
				inner join  #ztbl_xmlvalue t on sdh1.[close_reference_id]=t.deal_header_id 
				and sdd.term_start=t.term_start and sdd.term_end=t.term_end and t.leg=sdd.leg and isnull(t.[close_volume],0)<>0
			


		update source_deal_header set deal_id=cast(source_deal_header_id as NVARCHAR)+ '_farrms'
			where deal_id like '%' +@process_id




	INSERT INTO user_defined_deal_fields (source_deal_header_id,udf_template_id,udf_value)
		SELECT @deal_header_id,udf_template_id,udf_value FROM user_defined_deal_fields WHERE source_deal_header_id=@primary_deal_id

	--PRINT @deal_header_id
	EXEC spa_insert_update_audit 'i',@deal_header_id
	EXEC spa_compliance_workflow 109,'i',@deal_header_id,'Deal',NULL


	------------------------Offset-----------------------------------------

		COMMIT TRAN
	
		DECLARE @report_position_deals NVARCHAR(300)
		DECLARE @total_vol_sql NVARCHAR(MAX)	
		SET @user_login_id=dbo.FNADBUser()	 

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action NCHAR(1))')

		SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@deal_header_id AS NVARCHAR) + ',''i'''
		EXEC spa_print @total_vol_sql 
		EXEC (@total_vol_sql) 

		SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,null,''' +@user_login_id+''',''n'''
		SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
		EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id 
	
		Exec spa_ErrorHandler 0, 'Deal Close', 
			'spa_deal_close', 'Success', 
			'The Deal is successfully closed.',''

	end try
	begin catch
		DECLARE @err NVARCHAR(1000)
		if @@TRANCOUNT >0
		rollback tran
		if ERROR_NUMBER()=2627
			SET @err='The Deal had already closed.'
		ELSE
			select  @err=ERROR_MESSAGE()
		
		Exec spa_ErrorHandler @@Error, 'Deal close', 
					'spa_deal_close', 'DB Error', 
					@err, ''


	end catch
END
