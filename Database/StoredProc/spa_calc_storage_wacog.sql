IF EXISTS ( SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_calc_storage_wacog]') AND TYPE IN (N'P', N'PC') )
    DROP PROCEDURE [dbo].[spa_calc_storage_wacog]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Calculate Storage WACOG price of inventory deals

	Parameters : 
	@term_start : Term Start filter to process
	@term_end : Term End filter to process
	@flag : Flag
			- 's' - Transfer
			- 'o' - Offset
			- 'b' - Both
	@as_of_date : As Of Date to process
	@storage_assets_id : Storage Assets Id filter to process
	@product : Product filter to process
	@lot : Lot filter to process
	@batch_id : Batch Id filter to process
	@contract : Contract filter to process
	@location_id : Location Id filter to process
	@return_output : Return
	@batch_process_id : Process id when run through batch
	@batch_report_param : Paramater to run through batch
	@enable_paging : Enable Paging
	@page_size : Page Size
	@page_no : Page No

  */

CREATE PROC [dbo].[spa_calc_storage_wacog]	  
    @term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@flag CHAR(1) = NULL, -- 's',  ---'o'=offset;  'b'=both ;
	@as_of_date DATETIME  = NULL,
	@storage_assets_id VARCHAR(500) = NULL, --'2',  --general_assest_info_virtual_storage
	@product VARCHAR(100) = NULL,
	@lot VARCHAR(100) = NULL,
	@batch_id VARCHAR(500) = NULL,

	-- Additional Parameters
	@contract INT = NULL,
	@location_id INT = NULL,
	@return_output INT = 1,

	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

AS
SET NOCOUNT ON

/*
declare
	@term_start DATETIME = '2018-07-11',
	@term_end DATETIME =  '2018-07-31',
	@flag CHAR(1) = NULL, -- 's',  ---'o'=offset;  'b'=both ;
	@as_of_date DATETIME =  '2018-07-11',
	@storage_assets_id VARCHAR(500) ='1091', -- '11,2', --'2',  -- general_assest_info_virtual_storage
	@product VARCHAR(100) = NULL,
	@lot VARCHAR(100) = NULL,
	@batch_id VARCHAR(500) = NULL,

	----- Additional Parameters
	@contract INT = NULL, -- 9223
	@location_id INT = NULL,  --   1337

	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
  @return_output INT = 1

SELECT @as_of_date='2018-04-30', @storage_assets_id='114', @contract=NULL, @location_id=NULL, @term_start='2017-06-01', @term_end='2018-04-02'

 select * from source_minor_location where location_name like 'Rockstone%'
 select * from general_assest_info_virtual_storage
 alter table general_assest_info_virtual_storage add calculate_mtm varchar(1)
 select * from calcprocess_storage_wacog where storage_assets_id=1091


select  @as_of_date='2019-12-31', @storage_assets_id='22', @contract=NULL, @location_id=NULL, @term_start='2020-10-01', @term_end='2020-10-31'


select * from source_deal_header
select deal_volume,* from source_deal_detail where source_deal_header_id=8447
select deal_volume,* from source_deal_detail where source_deal_header_id=8448


if @@TRANCOUNT>0 rollback

begin tran

   commit




*/



IF ( SELECT CURSOR_STATUS('global', 'storage_cursor') ) >= -1
BEGIN
    IF ( SELECT CURSOR_STATUS('global', 'storage_cursor') ) > -1
	BEGIN
		CLOSE storage_cursor
	END
	DEALLOCATE storage_cursor
END

IF (SELECT CURSOR_STATUS('global', 'term_cursor')) >= -1
BEGIN
    IF (SELECT CURSOR_STATUS('global', 'term_cursor')) > -1
	BEGIN
		CLOSE term_cursor
	END
	DEALLOCATE term_cursor
END

IF OBJECT_ID(N'tempdb..#books', N'U') IS NOT NULL DROP TABLE #books
IF OBJECT_ID(N'tempdb..#tmp_inventory', N'U') IS NOT NULL DROP TABLE #tmp_inventory
IF OBJECT_ID(N'tempdb..#detail_inserted', N'U') IS NOT NULL DROP TABLE #detail_inserted
IF OBJECT_ID(N'tempdb..#detail_updated', N'U') IS NOT NULL DROP TABLE #detail_updated
IF OBJECT_ID(N'tempdb..#deal_selected', N'U') IS NOT NULL DROP TABLE #deal_selected
IF OBJECT_ID(N'tempdb..#beginning_balance', N'U') IS NOT NULL DROP TABLE #beginning_balance
IF OBJECT_ID(N'tempdb..#storage_balance', N'U') IS NOT NULL DROP TABLE #storage_balance
IF OBJECT_ID(N'tempdb..#withdrawal_balance', N'U') IS NOT NULL DROP TABLE #withdrawal_balance
IF OBJECT_ID(N'tempdb..#injection_deals', N'U') IS NOT NULL DROP TABLE #injection_deals
IF OBJECT_ID(N'tempdb..#beg_deals', N'U') IS NOT NULL DROP TABLE #beg_deals
IF OBJECT_ID(N'tempdb..#Calc_first_wacog', N'U') IS NOT NULL DROP TABLE #Calc_first_wacog
IF OBJECT_ID(N'tempdb..#temp', N'U') IS NOT NULL DROP TABLE #temp
IF OBJECT_ID(N'tempdb..#temp1', N'U') IS NOT NULL DROP TABLE #temp1
IF OBJECT_ID(N'tempdb..#temp2', N'U') IS NOT NULL DROP TABLE #temp2
IF OBJECT_ID(N'tempdb..#temp3', N'U') IS NOT NULL DROP TABLE #temp3
IF OBJECT_ID(N'tempdb..#wacog_cost', N'U') IS NOT NULL DROP TABLE #wacog_cost	
IF OBJECT_ID(N'tempdb..#stagin_table', N'U') IS NOT NULL DROP TABLE #stagin_table
IF OBJECT_ID(N'tempdb..#tmp_header', N'U') IS NOT NULL DROP TABLE #tmp_header
IF OBJECT_ID(N'tempdb..#tmp_inventory_ob', N'U') IS NOT NULL DROP TABLE #tmp_inventory_ob
IF OBJECT_ID(N'tempdb..#tmp_inventory_str_asset', N'U') IS NOT NULL DROP TABLE #tmp_inventory_str_asset

DECLARE @storage_location INT,
	@agreement INT,
	@schedule_injection_id INT,
	@schedule_withdrawl_id INT,
	@source_counterparty_id INT,
	@commodity_id INT,
	@accounting_type INT,
	@injection_as_long CHAR(1),
    @include_lot_product CHAR(1),
	@include_fees  CHAR(1),@volumn_uom int, @description VARCHAR(500)
		
DECLARE @Sql_Select VARCHAR(8000),
	    @location_group VARCHAR(30),
		@internal_deal_subtype_value_id VARCHAR(30),
		@deal_sub_type_type_id INT,
	--	@exclude_int_deal_sub_types VARCHAR(30) = '151,152',
        @run CHAR(1) = 'y',
        @storage_book_mapping VARCHAR(500) = 'Storage Book Mapping',
        @inv_actual_template_id int,
		@inv_forward_template_id int,
        @cursor_term_start DATETIME
		,@sub_book_id int
		,@currency_id int
		,@include_non_standard_deals char(1)
		,@schedule_base_volume_commodity_id VARCHAR(1000)
DECLARE @wacog_value_with_option NUMERIC(38,18) ,@first_term_date DATE

--Fetched from Storage WACOG Option Configuration
DECLARE	@storage_wacog_option VARCHAR(2)
select @storage_wacog_option = var_value from adiha_default_codes_values where default_code_id = 212
SELECT @storage_wacog_option = ISNULL(@storage_wacog_option, '1')

select   @schedule_base_volume_commodity_id = isnull(@schedule_base_volume_commodity_id+',','')+ cast(source_commodity_id as varchar)
 from source_commodity where commodity_name in ('Natural Gas','Gas') -- not ticket volume

select   @inv_actual_template_id = template_id from source_deal_header_template 
	where template_name='Actual Storage Inventory'

select   @inv_forward_template_id = template_id from source_deal_header_template 
	where template_name='Forward Storage Inventory'


DECLARE @each_storage_assets_id INT,@calc_mtm VARCHAR(1)
DECLARE @user_login_id VARCHAR(50)
DECLARE @desc VARCHAR(500)
DECLARE @errorcode VARCHAR(1)
declare @baseload_block_define_id varchar(30)

SELECT @baseload_block_define_id = value_id  FROM static_data_value WHERE [type_id] = 10018 AND code LIKE 'Base Load' -- External Static Data

SET @user_login_id = dbo.FNADBUser() 
SET @location_group = 'Storage'

SELECT @internal_deal_subtype_value_id = internal_deal_type_subtype_id
FROM   internal_deal_type_subtype_types WHERE  internal_deal_type_subtype_type = 'Storage Inventory'

DECLARE @storage_deal_type_id INT

SELECT @storage_deal_type_id =source_deal_type_id FROM source_deal_type WHERE source_deal_type_name = @location_group

SET @term_start = ISNULL(NULLIF(@term_start, ''), @as_of_date)
SET @term_end = ISNULL(NULLIF(@term_end, ''), @as_of_date)
 
--SET @term_end =dateadd(month,1,convert(varchar(8),@term_end,120)+'01')-1

CREATE TABLE #books(fas_book_id INT) 

CREATE TABLE #deal_selected
(
	source_deal_header_id INT,
	location_id               INT,
	curve_id                  INT,
	term_start                DATETIME,
	term_end				DATETIME,
	Leg                       INT,
	contract_id INT,
	template_id INT,
	deal_sub_type_type_id INT,
	buy_sell CHAR(1) COLLATE DATABASE_DEFAULT,
	fas_book_id               INT,
	ob_deal                   BIT,
	storage_assets_id         INT,
	lot                       VARCHAR(250) COLLATE DATABASE_DEFAULT,
	product                   VARCHAR(250) COLLATE DATABASE_DEFAULT,
	batch_id                  VARCHAR(500) COLLATE DATABASE_DEFAULT,
	is_inj_deal               BIT,
	daily_volume              NUMERIC(38, 18),
	price                     FLOAT,
	vol_conv_factor			numeric(38,18),
	block_define_id int,
	multiplier float,
	volume_multiplier2 float,
	deal_volume_frequency varchar(1) COLLATE DATABASE_DEFAULT,
	deal_volume NUMERIC(38, 18)
	,commodity_id int
	,ticket_base_volume bit
	,ticket_detail_id int
	,shipment_id int
	,description1 VARCHAR(250) COLLATE DATABASE_DEFAULT
	,deal_id VARCHAR(250) COLLATE DATABASE_DEFAULT
)


SELECT [source_system_id],
    CAST([deal_id] AS VARCHAR(250)) [deal_id],
    [deal_date],
    [ext_deal_id],
    [physical_financial_flag],
    [structured_deal_id],
    [counterparty_id],
    [entire_term_start],
    [entire_term_end],
    [source_deal_type_id],
    [deal_sub_type_type_id],
    [option_flag],
    [option_type],
    [option_excercise_type],
    [source_system_book_id1],
    [source_system_book_id2],
    [source_system_book_id3],
    [source_system_book_id4],
    [description1],
    [description2],
    [description3],
    [deal_category_value_id],
    [trader_id],
    [internal_deal_type_value_id],
    [internal_deal_subtype_value_id],
    [template_id],
    [header_buy_sell_flag],
    [broker_id],
    [generator_id],
    [status_value_id],
    [status_date],
    [assignment_type_value_id],
    [compliance_year],
    [state_value_id],
    [assigned_date],
    [assigned_by],
    [generation_source],
    [aggregate_environment],
    [aggregate_envrionment_comment],
    [rec_price],
    [rec_formula_id],
    [rolling_avg],
    [contract_id],
    [create_user],
    [create_ts],
    [update_user],
    [update_ts],
    [legal_entity],
    [internal_desk_id],
    [product_id],
    [internal_portfolio_id],
    [commodity_id],
    [reference],
    [deal_locked],
    [close_reference_id],
    [block_type],
    [block_define_id],
    [granularity_id],
    [Pricing],
    [deal_reference_type_id],
    [unit_fixed_flag],
    [broker_unit_fees],
    [broker_fixed_cost],
    [broker_currency_id],
    [deal_status],
    [term_frequency],
    [option_settlement_date],
    [verified_by],
    [verified_date],
    [risk_sign_off_by],
    [risk_sign_off_date],
    [back_office_sign_off_by],
    [back_office_sign_off_date],
    [book_transfer_id],
    [confirm_status_type],
    [sub_book],
    [deal_rules],
    [confirm_rule],
    [description4],
    [timezone_id],
    CAST(0 AS INT) source_deal_header_id
INTO #tmp_header
FROM   [dbo].[source_deal_header]
WHERE 1 = 2

CREATE TABLE #detail_inserted
(
	id                        INT IDENTITY(1, 1),
	source_deal_header_id     INT,
	source_deal_detail_id     INT,
	leg                       INT,
	term_start                DATETIME
)

CREATE TABLE #detail_updated
(
	id                        INT IDENTITY(1, 1),
	source_deal_detail_id     INT,
	injection_amount numeric(38,18), --'Injection Amount'
	withdrawal_amount numeric(38,18), --  'Withdrawal Amount'
	injection_volume numeric(38,18),  --  'Injection Volume'
	withdrawal_volume numeric(38,18), -- 'Withdrawal Volume'
	begining_balance numeric(38,18),  --  'Begining Balance'
	ending_balance numeric(38,18)  --  'Ending Balance'
)

IF OBJECT_ID('tempdb..#inj_deal_amount') IS NOT NULL
    DROP TABLE #inj_deal_amount

CREATE TABLE #inj_deal_amount
(
	source_deal_header_id     INT,
	term_start                DATETIME,
	Leg                       INT,
	ticket_detail_id int, 
	shipment_id int,
	price                     FLOAT,
	volume                    NUMERIC(38, 18)
)


/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT

SET @str_batch_table = ''

SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)


IF @enable_paging = 1 --paging processing
BEGIN

	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID()
    
	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
    
			--retrieve data from paging table instead of main table
    IF @page_no IS NOT NULL
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
		EXEC (@sql_paging) 
        RETURN
	END
END
				
/*******************************************1st Paging Batch END**********************************************/


SET @Sql_Select = 
'
INSERT INTO  #books
SELECT distinct 
		ssbm.fas_book_id fas_book_id 
FROM source_system_book_map ssbm 
	--portfolio_hierarchy book (nolock)
	--INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id       --LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
WHERE 1=1
	--(fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)  OR fas_deal_type_value_id = 408
'   
		--+ CASE 
		--        WHEN @cursor_term_start > @as_of_date THEN ' OR fas_deal_type_value_id = 408'
		--        ELSE ''
		--    END
--     + CASE WHEN NULLIF(@sub_book_id, '') IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN  ( ' + @sub_book_id + ') ' ELSE '' END
 
EXEC spa_print @sql_select
EXEC (@Sql_Select)

if @storage_assets_id is null
	select @storage_assets_id=isnull(@storage_assets_id+',','')+cast(general_assest_id as varchar) from general_assest_info_virtual_storage

BEGIN TRY
	--    select @storage_assets_id
	DECLARE storage_cursor CURSOR 
	FOR
	    SELECT s.item,
	        g.storage_location,
	        g.agreement,
	        g.schedule_injection_id,
	        g.schedule_withdrawl_id,
	        g.source_counterparty_id,
	        g.commodity_id commodity_id,
	        g.accounting_type,
	        isnull(g.injection_as_long,'y'),
	        g.injection_deal,
	        g.withdrawal_deal,
	--   g.subbook_id,
			g.include_product_lot,
			g.include_fees,g.volumn_uom,isnull(g.calculate_mtm,'y')
			,cg.currency,isnull(g.include_non_standard_deals,'n')
   FROM   general_assest_info_virtual_storage g
	        INNER JOIN dbo.SplitCommaSeperatedValues(@storage_assets_id) s
	            ON  s.item = g.general_assest_id
		inner join storage_asset sa on sa.storage_asset_id=g.storage_asset_id
		left join contract_group cg on cg.contract_id=g.agreement
	
	OPEN storage_cursor
	    FETCH NEXT FROM storage_cursor INTO @each_storage_assets_id, @storage_location, @agreement, 
	    @schedule_injection_id, @schedule_withdrawl_id, @source_counterparty_id, @commodity_id, @accounting_type
			, @injection_as_long, @schedule_injection_id, @schedule_withdrawl_id
			--, @sub_book_id
			, @include_lot_product,@include_fees,@volumn_uom,@calc_mtm,@currency_id,@include_non_standard_deals
	WHILE @@FETCH_STATUS = 0
	BEGIN
		TRUNCATE TABLE #deal_selected
		--print '====================================================================================='
		--PRINT '@each_storage_assets_id : ' + CAST(@each_storage_assets_id AS VARCHAR(25)) + 
		--	' ======================================================================================'

		SELECT @sub_book_id=CAST(clm4_value AS INT)
		FROM   generic_mapping_header h INNER JOIN generic_mapping_values v
					ON  v.mapping_table_id = h.mapping_table_id AND h.mapping_name = @storage_book_mapping
		where CAST(clm1_value AS INT)=	@storage_location
			and clm2_value ='n' and CAST(clm3_value AS INT)=@source_counterparty_id

	SET @Sql_Select =  '
		insert into #deal_selected 
		(
			source_deal_header_id,location_id,curve_id ,Leg,contract_id ,template_id
			,deal_sub_type_type_id,buy_sell,fas_book_id,ob_deal,storage_assets_id, lot
			, product, batch_id, is_inj_deal,vol_conv_factor,price ,block_define_id
			,multiplier,volume_multiplier2,deal_volume_frequency,deal_volume,term_start,term_end,commodity_id
			,shipment_id,ticket_detail_id,description1,deal_id
		)
		SELECT	sdh.source_deal_header_id,sdd.location_id,sdd.curve_id,sdd.Leg,max(sdh.contract_id),max(sdh.template_id)
			,max(sdh.internal_deal_type_value_id),max(sdd.buy_sell_flag)
			,max(b.fas_book_id),case when max(sdh.deal_id) like ''Beg Bal%'' then 1 else 0 end ob_deal
			,' + CAST(@each_storage_assets_id AS VARCHAR)+ ' storage_assets_id
			,sdd.lot ,sdd.product_description product, sdd.batch_id,
			case when ''' + @injection_as_long + '''=''y'' then case when  max(sdd.buy_sell_flag)=''b'' then 1 else 0 end
				else case when  max(sdd.buy_sell_flag)=''s'' then 1 else 0 end
			end,max(isnull(conv.conversion_factor,1))
			,max(sdd.fixed_price)
			,max(COALESCE(spcd.block_define_id, sdh.block_define_id,'+@baseload_block_define_id+'))
			,max(sdd.multiplier),max(sdd.volume_multiplier2)
			--,case when max(mgd.source_deal_detail_id) is null then max(sdd.deal_volume_frequency) else ''d'' end deal_volume_frequency
			,max(sdd.deal_volume_frequency)  deal_volume_frequency
			,max(coalesce(td.net_quantity,td.gross_quantity, mgd.bookout_split_volume,sdd.actual_volume,sdd.schedule_volume, CASE WHEN sdd.deal_volume < 0 AND sdd.total_volume >=0 THEN -1 ELSE 1 END * sdd.total_volume)) --made total_volume negative when deal_volume is also negative
			,cast(sdd.term_start as date) term_start
			,cast(sdd.term_end as date) term_end
			--,cast(isnull(td.movement_date_time,sdd.term_start) as date) term_start
			--,cast(isnull(td.movement_date_time,sdd.term_end) as date) term_end
			,coalesce('+cast(@commodity_id as varchar)+',sdd.detail_commodity_id,sdh.commodity_id) commodity_id
			,isnull(mgh.match_group_shipment_id,-1) shipment_id, isnull(td.ticket_detail_id,-1) ticket_detail_id,
			max(sdh.description1),max(sdh.deal_id)
		FROM #books b 
			INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = b.fas_book_id
			INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
				AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
				AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
			inner JOIN source_deal_header_template sdht on sdht.template_id = sdh.template_id
		'
		+ case when @include_non_standard_deals='n' then 
			' and sdh.source_deal_type_id=' + CAST(@storage_deal_type_id AS VARCHAR(100)) else '' end
			+ ' and isnull(sdh.internal_deal_subtype_value_id,-1) not in (' + @internal_deal_subtype_value_id + ')
			INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
			inner JOIN source_minor_location ml on ml.source_minor_location_id=sdd.location_id
			inner JOIN source_major_location mj on mj.source_major_location_id=ml.source_major_location_ID 
				and mj.location_name=''' + @location_group + '''
			LEFT JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id = sdd.curve_id 
			LEFT JOIN rec_volume_unit_conversion conv (nolock) ON conv.from_source_uom_id=sdd.deal_volume_uom_id
				AND to_source_uom_id='+cast(@volumn_uom as varchar)+'
			left join  match_group_detail mgd on mgd.source_deal_detail_id=sdd.source_deal_detail_id
				and mgd.is_complete=''1''
			left join match_group_header mgh on mgh.match_group_header_id=mgd.match_group_header_id
			left join match_group_shipment mgs on  mgs.match_group_shipment_id=mgh.match_group_shipment_id
			left join ticket_match tm on tm.match_group_detail_id=mgd.match_group_detail_id
			left join ticket_detail td on td.ticket_detail_id=tm.ticket_detail_id
		WHERE sdh.template_id <>'+cast(@inv_actual_template_id as varchar)+' and sdh.template_id <>'+cast(@inv_forward_template_id as varchar)

		--	  AND (sdh.deal_id like ''Beg Bal%'' OR ''' + CONVERT(VARCHAR(10), @cursor_term_start, 120) + ''' between  sdd.term_start and sdd.term_end )' 
		+ CASE WHEN @storage_location IS NULL THEN ''
				ELSE ' AND sdd.location_id =' + CAST(@storage_location AS VARCHAR)  END
		+ CASE WHEN @agreement IS NULL THEN ''
				ELSE ' AND sdh.contract_id=' + CAST(@agreement AS VARCHAR) END
		--+case when charindex(quotename(cast(@commodity_id as varchar)),@schedule_base_volume_commodity_id)<>0 then 
		--	CASE WHEN @source_counterparty_id IS NULL THEN ''
		--	ELSE ' AND sdh.counterparty_id = ' + CAST(@source_counterparty_id AS VARCHAR)  END
		--else '' end
		--+ CASE WHEN @commodity_id IS NULL THEN ''
		--	    ELSE '  AND isnull(sdd.detail_commodity_id,sdh.commodity_id) = ' + CAST(@commodity_id AS VARCHAR) END
		+ CASE WHEN @product IS NULL THEN ''
				ELSE ' AND ISNULL(sdd.product_description, ''' + @product + ''')  = ''' + @product + '''' END
		+ CASE WHEN @lot IS NULL THEN ''
				ELSE ' AND ISNULL(sdd.lot, ''' + @lot + ''') = ''' + @lot + '''' END
		+ CASE WHEN @batch_id IS NULL THEN ''
			ELSE ' AND ISNULL(sdd.batch_id, ''' + @batch_id + ''') = ''' + @batch_id + '''' END
		+' Group by
			sdh.source_deal_header_id,sdd.location_id,sdd.curve_id,sdd.lot,sdd.leg 
			,sdd.product_description, sdd.batch_id,cast(sdd.term_start as date)
			,cast(sdd.term_end as date),coalesce('+cast(@commodity_id as varchar)+',sdd.detail_commodity_id,sdh.commodity_id)
			,isnull(mgh.match_group_shipment_id,-1), isnull(td.ticket_detail_id,-1)
		'

		EXEC spa_print @Sql_Select
		EXEC (@Sql_Select)

		UPDATE ds
		SET    daily_volume = deal_volume*ds.vol_conv_factor
		FROM   #deal_selected ds 
		where ds.ob_deal=1

		DELETE calcprocess_storage_wacog
		   where storage_assets_id = @each_storage_assets_id
			--location_id =@storage_location
			--and contract_id=@agreement
			AND term >= @term_start
			AND ISNULL(product, '-1') = COALESCE(@product,product, '-1')
			AND ISNULL(lot, '-1') = COALESCE(@lot,lot, '-1')
			AND ISNULL(batch_id, '-1') = COALESCE(@batch_id,batch_id, '-1')
		--	and isnull(commodity_id,-1)=@commodity_id

		DECLARE term_cursor CURSOR 
		FOR
			SELECT term_start FROM   [dbo].[FNATermBreakdown]('d', @term_start, @term_end)
		OPEN term_cursor
		FETCH NEXT FROM term_cursor INTO @cursor_term_start
		WHILE @@FETCH_STATUS = 0
		BEGIN

			EXEC spa_print '----------------------------------------------------------------'
			SET @description ='Term Start : ' + CAST(@cursor_term_start AS VARCHAR(25)) + 
			' --------------------------------------------------------------------'
			EXEC spa_print @description

			TRUNCATE TABLE #tmp_header -- select * from #tmp_header
			TRUNCATE TABLE #detail_inserted
			--TRUNCATE TABLE #detail_updated
			TRUNCATE TABLE #inj_deal_amount

			UPDATE #deal_selected SET daily_volume = null, price =null   where ob_deal<>1
					and	@cursor_term_start between term_start and  term_end

			IF OBJECT_ID(N'tempdb..#neg_wacog_price', N'U') IS NOT NULL DROP TABLE #neg_wacog_price

			IF OBJECT_ID('tempdb..#tmp_inventory') IS NOT NULL  DROP TABLE #tmp_inventory
			IF OBJECT_ID(N'tempdb..#tmp_inventory_ob', N'U') IS NOT NULL  DROP TABLE #tmp_inventory_ob
	        
			

			UPDATE ds 
				SET daily_volume =cast(CAST(ds.deal_volume AS NUMERIC(38,18)) * 
					cast(CASE ds.deal_volume_frequency 
					when 'h' then 1 --vft.volume_mult 
					when 'x' then 1 --vft.volume_mult*4 --15 minute
					when 'y' then 1 --vft.volume_mult*2 --30 minute
					when 'd' then 1 
					when 't' then 1/(datediff(day,ds.term_start,ds.term_end) +1)
					when 'm' then 
						cast(1 as numeric(38,18))/datediff(day,cast(convert(varchar(8),@cursor_term_start,120)+'01' as datetime),dateadd(month,1,cast(convert(varchar(8),@cursor_term_start,120)+'01' as datetime)))
					when 'a' then 
						cast(1 as numeric(38,18))/datediff(day,cast(cast(year(@cursor_term_start) as varchar)+'-01-01' as datetime),cast(cast(year(@cursor_term_start)+1 as varchar)+'-01-01' as datetime))
					when 'w' then cast(1 as numeric(38,18))/7
					when 'q' then 
						cast(1 as numeric(38,18))/datediff(day,convert(datetime,cast(year(@cursor_term_start) as varchar) +'-'+cast((DATEPART(qq,@cursor_term_start) *3)-2 AS VARCHAR)+'-01',120),dateadd(month,1,convert(datetime,cast(year(@cursor_term_start) as varchar) +'-'+cast((DATEPART(qq,@cursor_term_start) *3) AS VARCHAR)+'-01',120)))
				end  AS NUMERIC(38,18)) AS NUMERIC(38,18)) *cast(cast(CAST(ISNULL(ds.multiplier,1) AS NUMERIC(38,18)) AS NUMERIC(38,18))*CAST(ISNULL(ds.volume_multiplier2,1) AS NUMERIC(38,18)) AS NUMERIC(38,18))
			FROM  #deal_selected ds  with (nolock) 
			outer apply 
			( 
				SELECT sum(volume_mult) volume_mult FROM hour_block_term with (nolock) 
					where term_date=@cursor_term_start AND block_define_id = ds.block_define_id
			) vft
			where ds.ob_deal<>1 and	@cursor_term_start between ds.term_start and  ds.term_end

		   SET @Sql_Select = '
			insert into #inj_deal_amount ( source_deal_header_id,term_start,Leg,ticket_detail_id,shipment_id,price,volume)
			select  ds.source_deal_header_id , ''' + CONVERT(VARCHAR(10), @cursor_term_start, 120) + '''
			,ds.Leg,ds.ticket_detail_id,ds.shipment_id, '
			+ CASE WHEN @cursor_term_start > @as_of_date THEN 'isnull(sdpd.contract_value/nullif(sdpd.deal_volume,0),0)' ELSE 'sdpd.net_price' END +
				case when isnull(@include_fees,'n')='y' then ' + isnull(fees.fees,0)' else '' end +', ds.daily_volume
			from  #deal_selected ds
			' +
			CASE  WHEN @cursor_term_start > @as_of_date THEN 
			' left join source_deal_pnl_detail sdpd on ds.source_deal_header_id=sdpd.source_deal_header_id
				and  ''' + CONVERT(VARCHAR(10), @cursor_term_start, 120) + ''' between sdpd.term_start and sdpd.term_end
				and ds.Leg=sdpd.leg --and ds.is_inj_deal=1
				and  sdpd.pnl_as_of_date=''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
			'
			ELSE 
				' 
				outer apply 
				( 
					select max(as_of_date) aod_max from source_deal_settlement sdpd where ds.source_deal_header_id=sdpd.source_deal_header_id
					and  ''' + CONVERT(VARCHAR(10), @cursor_term_start, 120) + ''' between sdpd.term_start and sdpd.term_end 
					and ds.Leg=sdpd.leg and set_type=''s'' and sdpd.as_of_date<=''' + CONVERT(VARCHAR(10), @as_of_date, 120) + '''
				) aod_max
				left join source_deal_settlement sdpd on ds.source_deal_header_id=sdpd.source_deal_header_id
					and isnull(sdpd.ticket_detail_id,-1)=ds.ticket_detail_id 
					--and isnull(sdpd.shipment_id,-1)=ds.shipment_id
					and  ''' + CONVERT(VARCHAR(10), @cursor_term_start, 120) + ''' between sdpd.term_start and sdpd.term_end 
					and ds.Leg=sdpd.leg and set_type=''s'' and  as_of_date=aod_max.aod_max
				'
			END + 
			case when isnull(@include_fees,'n')='y' then		   
				CASE  WHEN @cursor_term_start > @as_of_date THEN 
				'
				outer apply
				(
					select isnull(sum([value]/nullif(ds.daily_volume,0)),0) fees 
					from index_fees_breakdown  i inner join #deal_selected ds
						on ds.source_deal_header_id = i.source_deal_header_id and ds.Leg = i.leg
					where i.source_deal_header_id=sdpd.source_deal_header_id 
						and i.as_of_date=sdpd.pnl_as_of_date and
						i.internal_type<>-1 and  i.term_start=sdpd.term_start and i.Leg=sdpd.leg 
				) fees
				'
				ELSE 
				'
				outer apply
				(
					select isnull(sum([value]/nullif(ds.daily_volume,0)),0) fees 
					from index_fees_breakdown_settlement i inner join #deal_selected ds
						on ds.source_deal_header_id =i.source_deal_header_id and ds.Leg = i.leg
					where i.source_deal_header_id=sdpd.source_deal_header_id and as_of_date=aod_max.aod_max
						and set_type=''s'' and  ds.term_start=sdpd.term_start and i.Leg=sdpd.leg 
						and ds.term_start between i.term_start and i.term_end
				) fees
				'
				END
			else '' end
			--  +' where ds.is_inj_deal=1 '

	      --  select @Sql_Select
	   
	      EXEC spa_print @Sql_Select
	      EXEC (@Sql_Select)
	        

	        UPDATE ds
	        SET    --volume = ABS(i.volume),
	               price = CASE WHEN is_inj_deal = 1 THEN i.price ELSE NULL END
			FROM   #deal_selected ds
	            INNER JOIN #inj_deal_amount i
	                ON  i.source_deal_header_id = ds.source_deal_header_id
	                -- AND i.term_start = ds.term_start
	                AND i.leg = ds.leg
					and i.ticket_detail_id=ds.ticket_detail_id and i.shipment_id=ds.shipment_id
					and ds.ob_deal<>1

		-- take all the current period transaction for all the possible grouping level
	        SELECT @each_storage_assets_id storage_assets_id,
	               CASE WHEN @include_lot_product = 'y' THEN ds.product ELSE NULL END product_description,
	               CASE WHEN @include_lot_product = 'y' THEN ds.lot ELSE NULL END lot,
	               CASE WHEN @include_lot_product = 'y' THEN ds.batch_id ELSE NULL END batch_id,
				   ds.commodity_id,
	               MAX(ds.location_id)     location_id,
	               @cursor_term_start       term_start,
	               MAX(ds.contract_id)      contract_id,
	            CAST(ABS(
	                   SUM(
	                       CASE WHEN @injection_as_long = 'y' THEN 
								CASE WHEN ds.ob_deal = 1 THEN 0 
								ELSE 
									CASE WHEN ds.buy_sell = 'b' THEN ds.daily_volume ELSE 0 END END
	                         ELSE 
								CASE WHEN ds.ob_deal = 1 THEN 0
	                            ELSE 
									CASE WHEN ds.buy_sell = 's' THEN ds.daily_volume ELSE 0 END END
	                        END)
	               ) AS NUMERIC(38,18))  inj_deal_total_volume,
	             CAST(ABS(
	                   SUM(
	                       CASE WHEN @injection_as_long = 'y' THEN 
								CASE WHEN ds.ob_deal = 1 THEN 0
								ELSE 
									CASE WHEN ds.buy_sell = 's' THEN ds.daily_volume ELSE 0 END
	                            END
							ELSE 
								CASE WHEN ds.ob_deal = 1 THEN 0
	                            ELSE 
									CASE WHEN ds.buy_sell = 'b' THEN ds.daily_volume ELSE 0 END
	                            END
							END)
	               ) AS NUMERIC(38,18))  wth_deal_total_volume,
				 CAST(ABS(
	                    SUM(
						CASE WHEN 	isnull(ds.description1,'')<>'108300'
						THEN CASE WHEN @injection_as_long = 'y' THEN 
								CASE WHEN ds.ob_deal = 1 THEN 0
								ELSE 
									CASE WHEN ds.buy_sell = 's' THEN ds.daily_volume ELSE 0 END
	                            END
							ELSE 
								CASE WHEN ds.ob_deal = 1 THEN 0
	                            ELSE 
									CASE WHEN ds.buy_sell = 'b' THEN ds.daily_volume ELSE 0 END
	                            END
							END ELSE 0 END) 
	               ) AS NUMERIC(38,18))  wth_deal_total_volume2,
	               CAST(ABS(
	                   SUM(
	                       CASE WHEN @injection_as_long = 'y' THEN 
								CASE WHEN ds.ob_deal = 1 THEN 0
	                            ELSE 
									CASE WHEN ds.buy_sell = 'b' THEN ds.daily_volume * ds.price ELSE 0 END
	                             END
	                        ELSE
								CASE WHEN ds.ob_deal = 1 THEN 0
	                            ELSE
									CASE WHEN ds.buy_sell = 's' THEN ds.daily_volume * ds.price ELSE 0 END
	                            END
							END)
	               ) AS NUMERIC(38,18)) inj_inventory_amt,
	               CAST(0 AS NUMERIC(38,18)) wth_inventory_amt,
	               CAST(NULL AS NUMERIC(38,18)) prior_inventory_vol,
	               CAST(NULL AS NUMERIC(38,18)) prior_inventory_amt,
	               CAST(NULL AS NUMERIC(38,18)) prior_wacog,
	               CAST(0 AS NUMERIC(38,18)) current_inventory_vol,
	               CAST(0 AS NUMERIC(38,18)) current_inventory_amt,
	               CAST(0 AS NUMERIC(38,18)) total_inventory_vol,
	               CAST(0 AS NUMERIC(38,18)) total_inventory_amt,
	               CAST(0 AS NUMERIC(38,18)) WACOG,
	               0                        FIFO_price,
	               0                        LIFO_price,
	               0                        pre_calculated --=case when ob.storage_assets_id is null then 0 else 1 end
										--, ds.ob_deal
	               ,
	               rowid = IDENTITY(INT, 1, 1)
			INTO   #tmp_inventory -- select * from #tmp_inventory
	       FROM   #deal_selected ds 
			where ds.daily_volume  is not null
				and @cursor_term_start between ds.term_start and  ds.term_end
	        GROUP BY
	               CASE WHEN @include_lot_product = 'y' THEN ds.product ELSE NULL END,
	               CASE WHEN @include_lot_product = 'y' THEN ds.lot ELSE NULL END,
	               CASE WHEN @include_lot_product = 'y' THEN ds.batch_id ELSE NULL END
				   ,ds.commodity_id
	        	     
					  

			--return
		-- take ob select * from calcprocess_storage_wacog ( that have already calculated wacog of that grouping level)
			
	        UPDATE ti
	        SET    prior_inventory_vol = ob.total_inventory_vol,
	               prior_inventory_amt = CASE WHEN @storage_wacog_option = '3' THEN 
												CASE WHEN ob.total_inventory_vol IS NOT NULL THEN 
														ob.total_inventory_vol * ob.wacog
												ELSE 0 END
										ELSE ob.total_inventory_amt END,
				   -- if option 3
				   -- then if prio inv vol is not NULL then prior inv vol * prior_wacog ELSE 0 END
				   -- else total_inventory_amt END
	               prior_wacog = case when @storage_wacog_option = '2'  
						THEN NULLIF(ob2.wacog,0) 
					else 
						ob.wacog 
					end

	        FROM   #tmp_inventory ti
				CROSS APPLY
				(
					SELECT TOP(1) * 
					FROM   calcprocess_storage_wacog
					WHERE  storage_assets_id = ti.storage_assets_id
						   AND ISNULL(lot, '-1') = ISNULL(ti.lot, '-1')
						   AND ISNULL(product, '-1') = ISNULL(ti.product_description, '-1')
						   AND ISNULL(batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						   and commodity_id=ti.commodity_id
						   AND term < @cursor_term_start
					ORDER BY term DESC
				) ob

				CROSS APPLY
				(

					SELECT sum(inj_inventory_amt)/NULLIF(Sum(inj_deal_total_volume),0) wacog
					FROM   calcprocess_storage_wacog
					WHERE  storage_assets_id = ti.storage_assets_id
						   AND ISNULL(lot, '-1') = ISNULL(ti.lot, '-1')
						   AND ISNULL(product, '-1') = ISNULL(ti.product_description, '-1')
						   AND ISNULL(batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						   and commodity_id=ti.commodity_id
						   AND term <= @cursor_term_start
					--ORDER BY term DESC
				) ob2

	        WHERE  ob.total_inventory_vol IS NOT NULL -- already calculated wacog only
	        
		-- take ob from Beg Bal deals ( that have not yet calculated wacog of that grouping level)
	        UPDATE ti
	        SET    prior_inventory_vol = ISNULL(sdd.prior_inventory_vol, 0),
	               prior_inventory_amt = ISNULL(sdd.prior_inventory_amt, 0),
	               prior_wacog = ISNULL(sdd.prior_wacog, 0)
	        FROM   #tmp_inventory ti
	               CROSS APPLY
				(
					SELECT prior_inventory_vol = SUM(
							   CASE WHEN @injection_as_long = 'y' THEN CASE WHEN buy_sell = 'b' THEN daily_volume ELSE 0 END
							   ELSE CASE WHEN buy_sell = 's' THEN daily_volume ELSE 0 END
							   END -
							   CASE WHEN @injection_as_long = 'y' THEN CASE WHEN buy_sell = 's' THEN daily_volume ELSE 0 END
							   ELSE CASE WHEN buy_sell = 'b' THEN daily_volume ELSE 0 END
								   END
						   ),
						   prior_inventory_amt = SUM(
								   (
								   CASE WHEN @injection_as_long = 'y' THEN CASE WHEN buy_sell = 'b' THEN daily_volume ELSE 0 END
								   ELSE CASE WHEN buy_sell = 's' THEN daily_volume ELSE 0 END
								   END -
								   CASE WHEN @injection_as_long = 'y' THEN CASE WHEN buy_sell = 's' THEN daily_volume ELSE 0 END
								   ELSE CASE WHEN buy_sell = 'b' THEN daily_volume ELSE 0 END
									END
								   ) * price
						   ),
						   prior_wacog           = MAX(price)
					FROM   #deal_selected
					WHERE  storage_assets_id     = ti.storage_assets_id
						   AND ISNULL(lot, '-1') = ISNULL(ti.lot, '-1')
						   AND ISNULL(product, '-1') = ISNULL(ti.product_description, '-1')
						   AND ISNULL(batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						   and commodity_id=ti.commodity_id
						   AND ob_deal = 1
				) sdd
	        WHERE  ti.prior_inventory_vol IS NULL -- that have not yet calculated wacog only
	        
	        UPDATE #tmp_inventory
	        SET    current_inventory_vol = ISNULL(inj_deal_total_volume, 0) -ISNULL(wth_deal_total_volume, 0) 
	        
	        UPDATE #tmp_inventory
	        SET    current_inventory_vol = ISNULL(inj_deal_total_volume, 0) -ISNULL(wth_deal_total_volume, 0),
	               current_inventory_amt = CASE WHEN @storage_wacog_option = '3' THEN inj_inventory_amt
												ELSE 				   
												inj_inventory_amt -(
											   ISNULL(wth_deal_total_volume2, 0) *
												CASE ISNULL(@accounting_type, 45400)
													WHEN 45401 THEN fifo_price
														WHEN 45402 THEN lifo_price
													WHEN 45400 THEN ISNULL(prior_wacog, 0)
												   END
											   )
											  END 
		
			

	        UPDATE #tmp_inventory
	        SET    total_inventory_vol = ISNULL(prior_inventory_vol, 0) + ISNULL(current_inventory_vol, 0),
	               total_inventory_amt = ISNULL(prior_inventory_amt, 0) + ISNULL(current_inventory_amt, 0),
	               wacog = case when @storage_wacog_option = '1' then 
					isnull(ABS(
	                   (
	                       ISNULL(prior_inventory_amt, 0) + ISNULL(current_inventory_amt, 0)
	                   ) / NULLIF(
	                       ISNULL(prior_inventory_vol, 0) + ISNULL(current_inventory_vol, 0), 0
	                   )
	               ),0) 
				   when @storage_wacog_option = '2' then
						prior_wacog
					else
					isnull(ABS(
	                   (
	                       ISNULL(prior_inventory_amt, 0) + ISNULL(current_inventory_amt, 0)
	                   ) / NULLIF(
	                       ISNULL(prior_inventory_vol, 0) + ISNULL(inj_deal_total_volume, 0), 0
	                   )
	               ),0)
					end
			
			-- used for negative wacog_price and storage_wacog_option 3 & prior_inventory_volume is 0
			select ti.location_id,ti.commodity_id,ti.term_start,spc.curve_value price
			into #neg_wacog_price -- select * from #neg_wacog_price
			from 
			( select distinct location_id,commodity_id,term_start from	#tmp_inventory )ti 
			left join location_price_index lpi 
				ON ti.location_id= lpi.location_id AND lpi.commodity_id = ti.commodity_id
			left join source_minor_location sml
				ON ti.location_id= sml.source_minor_location_id 
			outer apply
			(
			select min(maturity_date) maturity_date from source_price_curve where source_curve_def_id=isnull(lpi.curve_id,sml.term_pricing_index)
				and as_of_date=@as_of_date
				--and maturity_date>=convert(varchar(8),ti.term_start,120)+'01'
				and maturity_date>=ti.term_start
			) mx_term
			inner join source_price_curve spc on spc.source_curve_def_id=isnull(lpi.curve_id,sml.term_pricing_index)
				and spc.as_of_date=@as_of_date
				and spc.maturity_date>=mx_term.maturity_date

			-- storage_wacog_option 3 & prior_inventory_volume is 0
			update	ti set 
				wacog=w.price
			from #tmp_inventory ti
				inner join  #neg_wacog_price w on  ti.location_id=w.location_id 
					and ti.commodity_id=w.commodity_id and ti.term_start=w.term_start 
			where ti.prior_inventory_vol <= 0 AND @storage_wacog_option = '3'

	         --update for first time data entry for the storage.
			UPDATE ti
				SET ti.wacog = ti.inj_inventory_amt/nullif(ti.inj_deal_total_volume,0)
			 FROM   #tmp_inventory ti
			 OUTER APPLY
				  (

					SELECT 1 data_exists
					FROM   calcprocess_storage_wacog
					WHERE  storage_assets_id = ti.storage_assets_id
						   AND ISNULL(lot, '-1') = ISNULL(ti.lot, '-1')
						   AND ISNULL(product, '-1') = ISNULL(ti.product_description, '-1')
						   AND ISNULL(batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						   and commodity_id=ti.commodity_id
						   AND term <= @cursor_term_start
					--ORDER BY term DESC
				) ob2
				WHERE ob2.data_exists IS NULL
					and ti.inj_inventory_amt/nullif(ti.inj_deal_total_volume,0) is not null

			-- update wth_inventory_amt 
			UPDATE #tmp_inventory
				SET    wth_inventory_amt =  ISNULL(wth_deal_total_volume2, 0) * ISNULL(case when @storage_wacog_option IN ('1','2') then prior_wacog else wacog end, 0)
			
			
			-- negative wacog 		
			update	ti set 
				prior_inventory_amt = CASE WHEN @storage_wacog_option = '3' THEN 
												ti.prior_wacog * ISNULL(ti.prior_inventory_vol,0)
										ELSE w.price*ti.prior_inventory_vol END,
				current_inventory_amt = CASE WHEN @storage_wacog_option = '3' THEN 
												w.price*ISNULL(ti.inj_deal_total_volume, 0)
										ELSE w.price*ti.current_inventory_vol END,
				total_inventory_amt=CASE WHEN @storage_wacog_option = '3' THEN 
												ti.prior_wacog * ISNULL(ti.prior_inventory_vol,0) + w.price*ISNULL(ti.inj_deal_total_volume, 0)
										ELSE w.price*ti.total_inventory_vol END,
				wacog=w.price,
				inj_inventory_amt=w.price*ISNULL(ti.inj_deal_total_volume, 0)
				,wth_inventory_amt=w.price*ISNULL(ti.wth_deal_total_volume, 0)
			from #tmp_inventory ti
				inner join  #neg_wacog_price w on  ti.location_id=w.location_id 
					and ti.commodity_id=w.commodity_id and ti.term_start=w.term_start 
			where 
			(@storage_wacog_option <> '3' AND ti.total_inventory_vol<0)
			OR
			(@storage_wacog_option = '3'
			AND (ti.prior_wacog * ISNULL(ti.prior_inventory_vol,0) + w.price*ISNULL(ti.inj_deal_total_volume, 0)) < 0)

	        -- End calculating  inventoy and wacog

			
-------------------------------------------------------------------------------------------------------------------------------------------------
	        -- Start Data Saving in physical table
	        -- select * from calcprocess_storage_wacog
		  --  DELETE calcprocess_storage_wacog
		  --  FROM   calcprocess_storage_wacog csw
				--INNER JOIN #tmp_inventory ti ON  csw.storage_assets_id = ti.storage_assets_id
				--	AND csw.term >= ti.term_start -- delete all
				--	AND ISNULL(csw.product, '-1') = COALESCE(@product, csw.product, '-1')
				--	AND ISNULL(csw.lot, '-1') = COALESCE(@lot, csw.lot, '-1')
				--	AND ISNULL(csw.batch_id, '-1') = COALESCE(@batch_id, csw.batch_id, '-1')
	        
			INSERT INTO dbo.calcprocess_storage_wacog -- select * from dbo.calcprocess_storage_wacog
			(
				storage_assets_id,
				product,
				lot,
				batch_id,
				 commodity_id,
				location_id,
				contract_id,
				term,
				prior_inventory_vol,
				prior_inventory_amt,
				current_inventory_vol,
				current_inventory_amt,
				total_inventory_vol,
				total_inventory_amt,
				wacog,
				deal_price,
				inj_deal_total_volume,
				wth_deal_total_volume,
				create_ts,
				create_user,
				as_of_date,
				inj_inventory_amt,
				wth_inventory_amt
				,Volume_adjustment_withdrawal
			)
			SELECT ti.storage_assets_id,
					ti.product_description,
					ti.lot,
					ti.batch_id,
					ti.commodity_id,
					ISNULL(ti.location_id, @location_id),
					ti.contract_id,
					ti.term_start,
					ti.prior_inventory_vol,
					ti.prior_inventory_amt,
					ti.current_inventory_vol,
					ti.current_inventory_amt,
					ti.total_inventory_vol,
					ti.total_inventory_amt,
					ti.wacog,
					isnull(ti.current_inventory_amt / NULLIF(ti.current_inventory_vol, 0),0) deal_price,
					ISNULL(ti.inj_deal_total_volume, 0),
					ISNULL(ti.wth_deal_total_volume, 0),
					GETDATE()        create_ts,
					@user_login_id     create_user,
					@as_of_date,
					ti.inj_inventory_amt,
					ti.wth_inventory_amt
					,ti.wth_deal_total_volume2
			FROM   #tmp_inventory ti
			OUTER APPLY
			(
				SELECT TOP(1) total_inventory_vol total_inventory_vol_pr,
						total_inventory_amt total_inventory_amt_pr,
						WACOG          WACOG_pr,
						deal_price     deal_price_pr
				FROM   dbo.calcprocess_storage_wacog
				WHERE  storage_assets_id = ti.storage_assets_id
						AND ISNULL(product, '-1') = ISNULL(ti.product_description, '-1')
						AND ISNULL(lot, '-') = ISNULL(ti.lot, '-1')
						AND ISNULL(batch_id, '-') = ISNULL(ti.batch_id, '-1')
						and commodity_id=ti.commodity_id
						AND term < ti.term_start
				ORDER BY term           DESC
			) pr
			LEFT JOIN calcprocess_storage_wacog c
				ON  c.storage_assets_id = ti.storage_assets_id
					AND ISNULL(c.product, '-1') = ISNULL(ti.product_description, '-1')
					AND ISNULL(c.lot, '-') = ISNULL(ti.lot, '-1')
					AND ISNULL(c.batch_id, '-') = ISNULL(ti.batch_id, '-1')
					and c.commodity_id=ti.commodity_id
					AND c.term = ti.term_start
			WHERE  c.rowid IS NULL
	                
			------------------------------------------------------------------------------------
				-- Deal create or update start
			--------------------------------------------------------------------------------------
	        
			update sdd 
			set deal_volume=null
				,[fixed_price]=null
			FROM   #tmp_inventory ti
				inner JOIN source_deal_header sdh
					ON  sdh.entire_term_start >= CONVERT(VARCHAR(8), ti.term_start, 120) + '01'
					AND sdh.description4 = RIGHT(
							'00000000' + CAST(@each_storage_assets_id AS VARCHAR(20)), 8) + '~' + ISNULL(ti.product_description, 'NULL') + '~' + ISNULL(ti.lot, 'NULL') + '~' + ISNULL(ti.batch_id, 'NULL')
					AND sdh.deal_id LIKE 'Inv%'
					AND sdh.template_id in (@inv_actual_template_id,@inv_forward_template_id)
				inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
						and sdd.term_start>= ti.term_start

			 UPDATE udddf
				SET    udddf.udf_value =  null 
				FROM   #tmp_inventory ti
				inner JOIN source_deal_header sdh
					ON  sdh.entire_term_start >= CONVERT(VARCHAR(8), ti.term_start, 120) + '01'
						AND sdh.description4 = RIGHT(
								'00000000' + CAST(@each_storage_assets_id AS VARCHAR(20)), 8) + '~' + ISNULL(ti.product_description, 'NULL') 
								+ '~' + ISNULL(ti.lot, 'NULL') + '~' + ISNULL(ti.batch_id, 'NULL')
						AND sdh.deal_id LIKE 'Inv%'
						AND sdh.template_id in (@inv_actual_template_id,@inv_forward_template_id)
				inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
						and sdd.term_start>= ti.term_start
				INNER JOIN user_defined_deal_fields_template uddft ON  uddft.template_id = sdh.template_id
					AND uddft.Field_label in( 'Injection Volume', 'Injection Amount','Withdrawal Volume','Withdrawal Amount','Begining Balance','Ending Balance')
				INNER JOIN user_defined_deal_detail_fields udddf
					ON  udddf.source_deal_detail_id = sdd.source_deal_detail_id
					AND udddf.udf_template_id = uddft.udf_template_id


			-- Create Inventory Deal
	        
				--PRINT '@flag:' + @flag
				--PRINT 'Inventory Deals'
	        
			TRUNCATE TABLE #tmp_header
	        
		INSERT INTO [dbo].[source_deal_header]
		(
				[source_system_id],
				[deal_id],
				[deal_date],
				[ext_deal_id],
				[physical_financial_flag],
				[structured_deal_id],
				[counterparty_id],
				[entire_term_start],
				[entire_term_end],
				[source_deal_type_id],
				[deal_sub_type_type_id],
				[option_flag],
				[option_type],
				[option_excercise_type],
				[source_system_book_id1],
				[source_system_book_id2],
				[source_system_book_id3],
				[source_system_book_id4],
				[description1],
				[description2],
				[description3],
				[deal_category_value_id],
				[trader_id],
				[internal_deal_type_value_id],
				[internal_deal_subtype_value_id],
				[template_id],
				[header_buy_sell_flag],
				[broker_id],
				[generator_id],
				[status_value_id],
				[status_date],
				[assignment_type_value_id],
				[compliance_year],
				[state_value_id],
				[assigned_date],
				[assigned_by],
				[generation_source],
				[aggregate_environment],
				[aggregate_envrionment_comment],
				[rec_price],
				[rec_formula_id],
				[rolling_avg],
				[contract_id],
				[create_user],
				[create_ts],
				[update_user],
				[update_ts],
				[legal_entity],
				[internal_desk_id],
				[product_id],
				[internal_portfolio_id],
				[commodity_id],
				[reference],
				[deal_locked],
				[close_reference_id],
				[block_type],
				[block_define_id],
				[granularity_id],
				[Pricing],
				[deal_reference_type_id],
				[unit_fixed_flag],
				[broker_unit_fees],
				[broker_fixed_cost],
				[broker_currency_id],
				[deal_status],
				[term_frequency],
				[option_settlement_date],
				[verified_by],
				[verified_date],
				[risk_sign_off_by],
				[risk_sign_off_date],
				[back_office_sign_off_by],
				[back_office_sign_off_date],
				[book_transfer_id],
				[confirm_status_type],
				[sub_book],
				[deal_rules],
				[confirm_rule],
				[description4],
				[timezone_id]
			)
			OUTPUT INSERTED.[source_system_id], INSERTED.[deal_id], 
			INSERTED.[deal_date], INSERTED.[ext_deal_id], 
				INSERTED.[physical_financial_flag], INSERTED.[structured_deal_id], INSERTED.[counterparty_id], 
				INSERTED.[entire_term_start], INSERTED.[entire_term_end], INSERTED.[source_deal_type_id], 
				INSERTED.[deal_sub_type_type_id], INSERTED.[option_flag], INSERTED.[option_type], 
				INSERTED.[option_excercise_type], INSERTED.[source_system_book_id1], INSERTED.[source_system_book_id2], 
				INSERTED.[source_system_book_id3], INSERTED.[source_system_book_id4], INSERTED.[description1], 
				INSERTED.[description2], INSERTED.[description3], INSERTED.[deal_category_value_id], INSERTED.[trader_id], 
				INSERTED.[internal_deal_type_value_id], INSERTED.[internal_deal_subtype_value_id], INSERTED.[template_id], 
				INSERTED.[header_buy_sell_flag], INSERTED.[broker_id], INSERTED.[generator_id], INSERTED.[status_value_id], 
				INSERTED.[status_date], INSERTED.[assignment_type_value_id], INSERTED.[compliance_year], 
				INSERTED.[state_value_id], INSERTED.[assigned_date], INSERTED.[assigned_by], INSERTED.[generation_source], 
				INSERTED.[aggregate_environment], INSERTED.[aggregate_envrionment_comment], INSERTED.[rec_price], 
				INSERTED.[rec_formula_id], INSERTED.[rolling_avg], INSERTED.[contract_id], INSERTED.[create_user], 
				INSERTED.[create_ts], INSERTED.[update_user], INSERTED.[update_ts], INSERTED.[legal_entity], 
				INSERTED.[internal_desk_id], INSERTED.[product_id], INSERTED.[internal_portfolio_id], 
				INSERTED.[commodity_id], INSERTED.[reference], 
				INSERTED.[deal_locked], INSERTED.[close_reference_id], INSERTED.[block_type], INSERTED.[block_define_id], 
				INSERTED.[granularity_id], INSERTED.[Pricing], INSERTED.[deal_reference_type_id], 
				INSERTED.[unit_fixed_flag], INSERTED.[broker_unit_fees], INSERTED.[broker_fixed_cost], 
				INSERTED.[broker_currency_id], INSERTED.[deal_status], INSERTED.[term_frequency], 
				INSERTED.[option_settlement_date], INSERTED.[verified_by], INSERTED.[verified_date], 
				INSERTED.[risk_sign_off_by], INSERTED.[risk_sign_off_date], INSERTED.[back_office_sign_off_by], 
				INSERTED.[back_office_sign_off_date], INSERTED.[book_transfer_id], INSERTED.[confirm_status_type], 
				INSERTED.[sub_book], INSERTED.[deal_rules], INSERTED.[confirm_rule], INSERTED.[description4], 
				INSERTED.[timezone_id], INSERTED.[source_deal_header_id] 
			INTO #tmp_header  -- select * from #tmp_header 
			SELECT sdh_tmp.[source_system_id],
				'Inv'+case when sdh_tmp.template_id=@inv_actual_template_id then 'A' else 'F' end
				+ '_' + CONVERT(VARCHAR(8), @cursor_term_start, 112) + '_' + cast(@each_storage_assets_id as varchar) ,
				case when sdh_tmp.template_id=@inv_actual_template_id then tm.term -1 else @as_of_date end ,
				sdh_tmp.[ext_deal_id],
				sdh_tmp.[physical_financial_flag],
				sdh_tmp.[structured_deal_id],
				@source_counterparty_id [counterparty_id],
				CONVERT(VARCHAR(8), tm.term, 120) + '01',
				dateadd(day,case when sdh_tmp.template_id=@inv_actual_template_id then 1 else 0 end,eoMONTH(tm.term)),
				sdh_tmp.[source_deal_type_id],
				sdh_tmp.[deal_sub_type_type_id],
				sdh_tmp.[option_flag],
				sdh_tmp.[option_type],
				sdh_tmp.[option_excercise_type],
				ISNULL( ssbm.source_system_book_id1,-1 ),
				ISNULL( ssbm.source_system_book_id2,-2),
				ISNULL( ssbm.source_system_book_id3,-3 ),
				ISNULL( ssbm.source_system_book_id4,-4 ),
				sdh_tmp.[description1],
				sdh_tmp.[description2],
				sdh_tmp.[description3],
				sdh_tmp.[deal_category_value_id],
				sdh_tmp.[trader_id],
				sdh_tmp.[internal_deal_type_value_id],
				sdh_tmp.[internal_deal_subtype_value_id],
				sdh_tmp.[template_id],
				sdh_tmp.[header_buy_sell_flag],
				sdh_tmp.[broker_id],
				sdh_tmp.[generator_id],
				sdh_tmp.[status_value_id],
				sdh_tmp.[status_date],
				sdh_tmp.[assignment_type_value_id],
				sdh_tmp.[compliance_year],
				sdh_tmp.[state_value_id],
				sdh_tmp.[assigned_date],
				sdh_tmp.[assigned_by],
				sdh_tmp.[generation_source],
				sdh_tmp.[aggregate_environment],
				sdh_tmp.[aggregate_envrionment_comment],
				sdh_tmp.[rec_price],
				sdh_tmp.[rec_formula_id],
				sdh_tmp.[rolling_avg],
				isnull(@agreement,sdh_tmp.[contract_id]) [contract_id],
				sdh_tmp.[create_user],
				GETDATE(),
				sdh_tmp.[update_user],
				GETDATE(),
				sdh_tmp.[legal_entity],
				sdh_tmp.[internal_desk_id],
				sdh_tmp.[product_id],
				sdh_tmp.[internal_portfolio_id],
				isnull(@commodity_id,sdh_tmp.[commodity_id]) [commodity_id],
				sdh_tmp.[reference],
				'n' [deal_locked],
				sdh_tmp.[close_reference_id],
				sdh_tmp.[block_type],
				sdh_tmp.[block_define_id],
				sdh_tmp.[granularity_id],
				sdh_tmp.[Pricing],
				sdh_tmp.[deal_reference_type_id],
				sdh_tmp.[unit_fixed_flag],
				sdh_tmp.[broker_unit_fees],
				sdh_tmp.[broker_fixed_cost],
				sdh_tmp.[broker_currency_id],
				sdh_tmp.[deal_status],
				sdh_tmp.[term_frequency_type],
				sdh_tmp.[option_settlement_date],
				sdh_tmp.[verified_by],
				sdh_tmp.[verified_date],
				sdh_tmp.[risk_sign_off_by],
				sdh_tmp.[risk_sign_off_date],
				sdh_tmp.[back_office_sign_off_by],
				sdh_tmp.[back_office_sign_off_date],
				sdh_tmp.[book_transfer_id],
				sdh_tmp.[confirm_status_type],
				@sub_book_id,
				sdh_tmp.[deal_rules],
				sdh_tmp.[confirm_rule],
				RIGHT('00000000' + CAST(@each_storage_assets_id AS VARCHAR(20)), 8) + '~' + ISNULL(@product, 'NULL') + '~' + ISNULL(@lot, 'NULL') + '~' + ISNULL(@batch_id, 'NULL') 
				[description4],
				sdh_tmp.[timezone_id]
		   FROM    source_deal_header_template sdh_tmp 
			   cross join 
			   (
			   select @cursor_term_start term
			   --union 
			   --select case when eomonth(@cursor_term_start)=@cursor_term_start then @cursor_term_start+1 else @cursor_term_start end term
			   ) tm
				LEFT JOIN source_deal_header sdh ON  sdh.entire_term_start = CONVERT(VARCHAR(8), tm.term, 120) + '01'
					AND sdh.description4 = RIGHT(
					'00000000' + CAST(@each_storage_assets_id AS VARCHAR(20)), 8) + '~' + ISNULL(@product, 'NULL') + '~' + ISNULL(@lot, 'NULL') + '~' +  ISNULL(@batch_id, 'NULL')
					AND sdh.deal_id LIKE 'Inv%' AND sdh.template_id=sdh_tmp.template_id
				LEFT JOIN source_system_book_map ssbm ON  ssbm.book_deal_type_map_id = @sub_book_id
			WHERE  sdh.source_deal_header_id IS NULL
				and (sdh_tmp.template_id=@inv_actual_template_id 
					or sdh_tmp.template_id=case when isnull(@calc_mtm,'y')='y' then @inv_forward_template_id else 0 end)
				AND sdh_tmp.source_system_id = 2
				and 
				(
					( 
						sdh_tmp.template_id=@inv_actual_template_id and
						CONVERT(VARCHAR(8), tm.term, 120) + '01'<=@as_of_date
					) -- actual deal
					or
					( 
						sdh_tmp.template_id=@inv_forward_template_id and
						(DATEADD(MONTH, 1, CONVERT(VARCHAR(8), tm.term, 120) + '01') -1)>=@as_of_date
					)  -- forward deal
				)

	             
			TRUNCATE TABLE #detail_inserted
	        

			-- insert daily term for new added deal header for newly term
	        INSERT INTO [dbo].[source_deal_detail]
	        (
	            [source_deal_header_id],
	            [term_start],
	            [term_end],
	            [Leg],
	            [contract_expiration_date],
	            [fixed_float_leg],
	            [buy_sell_flag],
	            [curve_id],
	            [fixed_price],
	            [fixed_price_currency_id],
	            [option_strike_price],
	            [deal_volume],
	            [deal_volume_frequency],
	            [deal_volume_uom_id],
	            [block_description],
	            [deal_detail_description],
	            [formula_id],
	            [volume_left],
	            [settlement_volume],
	            [settlement_uom],
	            [create_user],
	            [create_ts],
	            [update_user],
	            [update_ts],
	            [price_adder],
	            [price_multiplier],
	            [settlement_date],
	            [day_count_id],
	            [location_id],
	            [meter_id],
	            [physical_financial_flag],
	            [Booked],
	            [process_deal_status],
	            [fixed_cost],
	            [multiplier],
	            [adder_currency_id],
	            [fixed_cost_currency_id],
	            [formula_currency_id],
	            [price_adder2],
	            [price_adder_currency2],
	            [volume_multiplier2],
	            [pay_opposite],
	            [capacity],
	            [settlement_currency],
	            [standard_yearly_volume],
	            [formula_curve_id],
	            [price_uom_id],
	            [category],
	            [profile_code],
	            [pv_party],
	            [status],
	            [lock_deal_detail],
	            lot,
	            product_description,
	            batch_id,detail_commodity_id
	        ) 
			--OUTPUT INSERTED.source_deal_header_id,INSERTED.source_deal_detail_id, INSERTED.leg, INSERTED.term_start
			--INTO #detail_inserted
	        SELECT th.[source_deal_header_id],
	               tm.term_start,
	               tm.term_end,
	               sdd_tmp.[Leg],
	               tm.term_end [contract_expiration_date],
	               sdd_tmp.[fixed_float_leg],
	               sdd_tmp.[buy_sell_flag],
	               sdd_tmp.[curve_id],
					null [fixed_price],
	               isnull(@currency_id,sdd_tmp.[fixed_price_currency_id]) [fixed_price_currency_id],
	               sdd_tmp.[option_strike_price],
					null [deal_volume],
	               sdd_tmp.[deal_volume_frequency],
	               isnull(@volumn_uom,sdd_tmp.[deal_volume_uom_id]) [deal_volume_uom_id],
	               sdd_tmp.[block_description],
	               sdd_tmp.[deal_detail_description],
	               sdd_tmp.[formula_id],
					null  [volume_left],
	               sdd_tmp.[settlement_volume],
	               sdd_tmp.[settlement_uom],
	               sdd_tmp.[create_user],
	               GETDATE() [create_ts],
	               sdd_tmp.[update_user],
	               GETDATE() [update_ts],
	               sdd_tmp.[price_adder],
	               sdd_tmp.[price_multiplier],
	               sdd_tmp.[settlement_date],
	               sdd_tmp.[day_count_id],
	               @storage_location  location_id,
	               sdd_tmp.[meter_id],
	               sdd_tmp.[physical_financial_flag],
	               sdd_tmp.[Booked],
	               sdd_tmp.[process_deal_status],
	               sdd_tmp.[fixed_cost],
	               sdd_tmp.[multiplier],
	               isnull(@currency_id,sdd_tmp.[adder_currency_id]) [adder_currency_id],
	               isnull(@currency_id,sdd_tmp.[fixed_cost_currency_id]) [fixed_cost_currency_id],
	               isnull(@currency_id,sdd_tmp.[formula_currency_id]) [formula_currency_id],
	               sdd_tmp.[price_adder2],
	               isnull(@currency_id,sdd_tmp.[price_adder_currency2]) [price_adder_currency2],
	               sdd_tmp.[volume_multiplier2] ,
	               sdd_tmp.[pay_opposite],
	               sdd_tmp.[capacity],
	               isnull(@currency_id,sdd_tmp.[settlement_currency]) [settlement_currency],
	               sdd_tmp.[standard_yearly_volume],
	               sdd_tmp.[formula_curve_id],
	               sdd_tmp.[price_uom_id],
	               sdd_tmp.[category],
	               sdd_tmp.[profile_code],
	               sdd_tmp.[pv_party],
	               sdd_tmp.[status],
	               sdd_tmp.[lock_deal_detail],
	               @lot,
	               @product,
	               @batch_id, @commodity_id
	        FROM #tmp_header th
	            INNER JOIN [dbo].[source_deal_detail_template] sdd_tmp
	                ON sdd_tmp.template_id = th.template_id
				CROSS APPLY [dbo].[FNATermBreakdown]('d', th.entire_term_start, th.entire_term_end) tm


	        
	        
	       -- End Inventory deal create
	        ----------------------------------------------------------------------------------------------------------------------------------

			IF OBJECT_ID(N'tempdb..#tmp_inventory_str_asset', N'U') IS NULL AND EXISTS (SELECT 1 FROM #tmp_inventory)
			BEGIN
				SELECT storage_assets_id,lot,product_description,batch_id,commodity_id
					INTO #tmp_inventory_str_asset
				FROM #tmp_inventory
			END
	
			FETCH NEXT FROM term_cursor INTO @cursor_term_start
		END
		CLOSE term_cursor
		DEALLOCATE term_cursor
	        
		TRUNCATE TABLE #detail_updated

		----Logic to retrieve WACOG/with price BASED ON WACOG option and update to wth Price START
	
		----SELECT MAX(storage_assets_id) storage_assets_id,
	 ----              CASE WHEN @include_lot_product = 'y' THEN ds.product ELSE NULL END product_description,
	 ----              CASE WHEN @include_lot_product = 'y' THEN ds.lot ELSE NULL END lot,
	 ----              CASE WHEN @include_lot_product = 'y' THEN ds.batch_id ELSE NULL END batch_id,
		----		   ds.commodity_id
		----	INTO   #tmp_inventory_str_asset
	 ----      FROM   #deal_selected ds 
	 ----       GROUP BY
	 ----              CASE WHEN @include_lot_product = 'y' THEN ds.product ELSE NULL END,
	 ----              CASE WHEN @include_lot_product = 'y' THEN ds.lot ELSE NULL END,
	 ----              CASE WHEN @include_lot_product = 'y' THEN ds.batch_id ELSE NULL END
		----		   ,ds.commodity_id
		IF OBJECT_ID(N'tempdb..#tmp_inventory_str_asset', N'U') IS NOT NULL
		BEGIN
			IF NOT EXISTS( SELECT 1 FROM #tmp_inventory_str_asset ti
				INNER JOIN general_assest_info_virtual_storage gasivs ON gasivs.general_assest_id = ti.storage_assets_id
				INNER JOIN source_commodity sc ON sc.source_commodity_id = gasivs.commodity_id 
				WHERE sc.commodity_id IN ('Natural Gas','Gas'))
			BEGIN
			
				UPDATE csw
						SET csw.wacog = ob2.wacog
					FROM calcprocess_storage_wacog csw
					INNER JOIN #tmp_inventory_str_asset ti ON csw.storage_assets_id = ti.storage_assets_id
							AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
							AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
							AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							AND csw.commodity_id=ti.commodity_id
							AND csw.as_of_date = @as_of_date
					CROSS APPLY
					(

						SELECT sum(inj_inventory_amt)/NULLIF(Sum(inj_deal_total_volume),0) wacog
						FROM   calcprocess_storage_wacog
						WHERE  storage_assets_id = ti.storage_assets_id
							   AND ISNULL(lot, '-1') = ISNULL(ti.lot, '-1')
							   AND ISNULL(product, '-1') = ISNULL(ti.product_description, '-1')
							   AND ISNULL(batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							   and commodity_id=ti.commodity_id
							   AND term <= csw.term
						--ORDER BY term DESC
					) ob2
					where ob2.wacog is not null


				SELECT 
					@wacog_value_with_option = CASE gasivs.wacog_option WHEN  110502 THEN c1.wacog WHEN 110500 THEN c2.wacog WHEN 110501 THEN c3.wacog ELSE NULL END
				FROM #tmp_inventory_str_asset ti
				INNER JOIN general_assest_info_virtual_storage gasivs ON gasivs.general_assest_id = ti.storage_assets_id
				OUTER APPLY(
					SELECT Top (1) csw.wacog
					FROM calcprocess_storage_wacog csw
					WHERE csw.storage_assets_id = ti.storage_assets_id
						AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
						AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
						AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						AND csw.commodity_id=ti.commodity_id
						AND csw.as_of_date = @as_of_date
						AND csw.term <= @as_of_date
					ORDER BY csw.term DESC
				) c1
				OUTER APPLY(
					SELECT Top (1) csw.wacog
					FROM calcprocess_storage_wacog csw
					WHERE csw.storage_assets_id = ti.storage_assets_id
						AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
						AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
						AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						AND csw.commodity_id=ti.commodity_id
						AND csw.as_of_date = @as_of_date
						AND csw.term < @as_of_date
					ORDER BY csw.term DESC
				) c2
				OUTER APPLY(
					SELECT Top (1) csw.wacog
					FROM calcprocess_storage_wacog csw
					WHERE csw.storage_assets_id = ti.storage_assets_id
						AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
						AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
						AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
						AND csw.commodity_id=ti.commodity_id
						AND csw.as_of_date <= DATEADD(D,-1,DATEADD(mm, DATEDIFF(m,0,@as_of_date),0))
						AND csw.term < @as_of_date
					ORDER BY csw.term DESC
				) c3

				IF @wacog_value_with_option IS NOT NULL
				BEGIN
					UPDATE csw
						SET csw.wth_inventory_amt = @wacog_value_with_option * csw.Volume_adjustment_withdrawal
							, csw.current_inventory_amt = csw.inj_inventory_amt - (@wacog_value_with_option * csw.Volume_adjustment_withdrawal)
					FROM calcprocess_storage_wacog csw
					INNER JOIN #tmp_inventory_str_asset ti ON csw.storage_assets_id = ti.storage_assets_id
							AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
							AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
							AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							AND csw.commodity_id=ti.commodity_id
							AND csw.as_of_date = @as_of_date
			
					--update total_inventory_amt of first term
				
			
					SELECT TOP 1
						@first_term_date = csw.term
					FROM calcprocess_storage_wacog csw
					INNER JOIN #tmp_inventory_str_asset ti ON csw.storage_assets_id = ti.storage_assets_id
							AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
							AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
							AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							AND csw.commodity_id=ti.commodity_id
							AND csw.as_of_date = @as_of_date
						ORDER BY csw.term ASC


					UPDATE csw
						SET csw.total_inventory_amt = csw.prior_inventory_amt + csw.current_inventory_amt
					FROM calcprocess_storage_wacog csw
					INNER JOIN #tmp_inventory_str_asset ti ON csw.storage_assets_id = ti.storage_assets_id
							AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
							AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
							AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							AND csw.commodity_id=ti.commodity_id
							AND csw.as_of_date = @as_of_date
							AND csw.term = @first_term_date

				
					--update prior inventory amt of remaining terms
					--update total inventory amt of remaining terms
					UPDATE csw
						SET csw.prior_inventory_amt = c1.total_inventory_amt
						,csw.total_inventory_amt = c1.total_inventory_amt + csw.current_inventory_amt
					FROM calcprocess_storage_wacog csw
					INNER JOIN #tmp_inventory_str_asset ti ON csw.storage_assets_id = ti.storage_assets_id
							AND ISNULL(csw.lot, '-1') = ISNULL(ti.lot, '-1')
							AND ISNULL(csw.product, '-1') = ISNULL(ti.product_description, '-1')
							AND ISNULL(csw.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							AND csw.commodity_id=ti.commodity_id
							AND csw.as_of_date = @as_of_date 
					OUTER APPLY (
						SELECT 
						TOP (1) c2.total_inventory_amt
						FROM calcprocess_storage_wacog c2 
						WHERE c2.storage_assets_id = ti.storage_assets_id
							AND ISNULL(c2.lot, '-1') = ISNULL(ti.lot, '-1')
							AND ISNULL(c2.product, '-1') = ISNULL(ti.product_description, '-1')
							AND ISNULL(c2.batch_id, '-1') = ISNULL(ti.batch_id, '-1')
							AND c2.commodity_id=ti.commodity_id
							AND c2.as_of_date = @as_of_date
							AND c2.term <  csw.term
						ORDER BY c2.term DESC
					) c1
					WHERE csw.term <> @first_term_date

				END
			END
			IF OBJECT_ID(N'tempdb..#tmp_inventory_str_asset', N'U') IS NOT NULL  DROP TABLE #tmp_inventory_str_asset
		END
		----Logic to retrieve WACOG/with price BASED ON WACOG option and update to wth Price END

	    UPDATE sdd
	    SET    [fixed_price] =	
				
				case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) then
						csw.wacog
						when sdd.term_start = @as_of_date+1 then 
						case when @storage_wacog_option IN ('1','3') then 
							case when csw.term <sdd.term_start  then csw.total_inventory_amt/nullif(csw.total_inventory_vol,0)
							else csw.prior_inventory_amt/nullif(csw.prior_inventory_vol,0) end
						else csw.wacog end
					else null end
				else
					CASE WHEN sdd.term_start> @as_of_date THEN  csw.wacog ELSE NULL END 
				end,
	            [deal_volume] = case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) then
							csw.total_inventory_vol
						when sdd.term_start = @as_of_date+1 then 
							case when csw.term <sdd.term_start  then  csw.total_inventory_vol else csw.prior_inventory_vol end
						else null end
				else
					CASE WHEN sdd.term_start> @as_of_date and csw.term=sdd.term_start then csw.current_inventory_vol ELSE NULL END 
				end,
	            [volume_left] =case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) then
						csw.total_inventory_vol
						when sdd.term_start = dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date)+1 then 
							case when csw.term <sdd.term_start  then  csw.total_inventory_vol
								else csw.prior_inventory_vol end
						else null end
				else
					CASE WHEN sdd.term_start> @as_of_date THEN  csw.current_inventory_vol ELSE NULL END 
				end ,
				settlement_volume=case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) and csw.term =sdd.term_start  then csw.inj_inventory_amt
					--	when sdd.term_start <= @as_of_date+1 then csw.inj_inventory_amt
						else null end
				else
					CASE WHEN sdd.term_start> @as_of_date and csw.term <=@cursor_term_start  THEN  csw.inj_inventory_amt ELSE NULL END 
				end , --'Injection Amount'
				--contractual_volume=case when  sdh.template_id=@inv_actual_template_id then
				--	CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) 
				--	then 1 else 0 end, @as_of_date) and csw.term =sdd.term_start  then 
				--					case when sdh.commodity_id in(@schedule_base_volume_commodity_id) THEN 
				--	 csw_pre.wacog else csw.wacog END *csw.wth_deal_total_volume ELSE 0 END +
				--		CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) 
				--	then 1 else 0 end, @as_of_date) AND csw.wth_deal_total_volume<>csw.Volume_adjustment_withdrawal THEN -1*
				--	case when sdh.commodity_id in(@schedule_base_volume_commodity_id) THEN 
				--	 csw_pre.wacog else csw.wacog END *(csw.wth_deal_total_volume-csw.Volume_adjustment_withdrawal)
				--		 else  NULL end
				--		--when sdd.term_start <= @as_of_date+1 then csw.wth_inventory_amt
				--		--else null end
				--else
				--	CASE WHEN sdd.term_start> @as_of_date and csw.term =sdd.term_start  THEN 
				--		case when sdh.commodity_id in(@schedule_base_volume_commodity_id) THEN 
				--	 csw_pre.wacog else csw.wacog END *csw.Volume_adjustment_withdrawal  ELSE NULL END 
				--end , --  'Withdrawal Amount'
				contractual_volume = csw2.wth_inventory_amt, --  'Withdrawal Amount'
				actual_volume=case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) and 
					csw.term =sdd.term_start  then csw.inj_deal_total_volume
						--when sdd.term_start <= @as_of_date+1 then csw.inj_deal_total_volume
						else null end
				else
					CASE WHEN sdd.term_start> @as_of_date and csw.term =sdd.term_start  THEN  csw.inj_deal_total_volume ELSE NULL END 
				end ,  --  'Injection Volume'
				schedule_volume=case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) and csw.term =sdd.term_start  then csw.wth_deal_total_volume
						--when sdd.term_start <= @as_of_date+1 then csw.wth_deal_total_volume
						else null end
				else
					CASE WHEN sdd.term_start> @as_of_date and csw.term <=@cursor_term_start THEN  csw.wth_deal_total_volume ELSE NULL END 
				end , -- 'Withdrawal Volume'
				standard_yearly_volume=case when  sdh.template_id=@inv_actual_template_id then
					CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) then
						case when csw.term <sdd.term_start  then csw.total_inventory_vol
							else csw.prior_inventory_vol end
					--	when sdd.term_start <= @as_of_date+1 then csw.prior_inventory_vol
						else null end
				else
					CASE WHEN sdd.term_start> @as_of_date THEN 
						case when csw.term <sdd.term_start  then csw.total_inventory_vol
							else csw.prior_inventory_vol end
						ELSE NULL END 
				end   --,  --  'Begining Balance'
				--total_volume=case when  sdh.template_id=@inv_actual_template_id then
				--	CASE WHEN sdd.term_start <=dateadd(day,case when @as_of_date=eomonth(@as_of_date) then 1 else 0 end, @as_of_date) then csw.total_inventory_vol
				--		--when sdd.term_start <= @as_of_date+1 then csw.total_inventory_vol
				--		else null end
				--else
				--	CASE WHEN sdd.term_start> @as_of_date THEN  csw.total_inventory_vol ELSE NULL END 
				--end  --  'Ending Balance'
		OUTPUT INSERTED.source_deal_detail_id,inserted.settlement_volume,inserted.contractual_volume
			,inserted.actual_volume,inserted.schedule_volume
			,inserted.standard_yearly_volume,inserted.deal_volume --inserted.total_volume
		INTO #detail_updated  --   select * from #detail_updated
		(source_deal_detail_id,injection_amount,withdrawal_amount, injection_volume,withdrawal_volume,begining_balance,ending_balance)
	    FROM    source_deal_header sdh
			CROSS APPLY [dbo].[FNATermBreakdown]('m', @term_start, @term_end + 1) tm
	        INNER JOIN [dbo].[source_deal_detail] sdd
				ON  sdh.source_deal_header_id = sdd.source_deal_header_id
					and  sdh.entire_term_start = CONVERT(VARCHAR(8), tm.term_start, 120) + '01'
					--and  sdh.entire_term_start = dateadd(day,1,EOMONTH(@cursor_term_start))
	            AND sdh.description4 = RIGHT('00000000' + CAST(@each_storage_assets_id AS VARCHAR(20)), 8) + '~' + ISNULL(@product, 'NULL') + '~' + ISNULL(@lot, 'NULL') + '~' + ISNULL(@batch_id, 'NULL')
				AND sdh.deal_id LIKE 'Inv%'
				AND sdh.template_id in (@inv_actual_template_id,@inv_forward_template_id)
			OUTER APPLY 
			(
				SELECT TOP(1) * FROM dbo.calcprocess_storage_wacog WHERE  storage_assets_id = @each_storage_assets_id
					AND ISNULL(product, '-1') = ISNULL(@product, '-1')
					AND ISNULL(lot, '-1') = ISNULL(@lot, '-1')
					AND ISNULL(batch_id, '-1') = ISNULL(@batch_id, '-1')
					AND term <=sdd.term_start
				ORDER BY term DESC
			) csw 
			OUTER APPLY 
			(
				SELECT TOP(1) wth_inventory_amt FROM dbo.calcprocess_storage_wacog WHERE  storage_assets_id = @each_storage_assets_id
					AND ISNULL(product, '-1') = ISNULL(@product, '-1')
					AND ISNULL(lot, '-1') = ISNULL(@lot, '-1')
					AND ISNULL(batch_id, '-1') = ISNULL(@batch_id, '-1')
					AND term =sdd.term_start
				ORDER BY term DESC
			) csw2 
			OUTER APPLY 
			(
				SELECT TOP(1) * FROM dbo.calcprocess_storage_wacog	WHERE  storage_assets_id = @each_storage_assets_id
					AND ISNULL(product, '-1') = ISNULL(@product, '-1')
					AND ISNULL(lot, '-1') = ISNULL(@lot, '-1')
					AND ISNULL(batch_id, '-1') = ISNULL(@batch_id, '-1')
					and commodity_id=isnull(@commodity_id,-1)
					AND term <sdd.term_start
				ORDER BY term DESC
			) csw_pre

			 
		WHERE  sdd.term_start BETWEEN tm.term_start 
			AND dateadd(day, case when tm.term_end=eomonth(tm.term_end) and sdh.template_id =@inv_actual_template_id then 1 else 0 end,tm.term_end)

	
		INSERT INTO user_defined_deal_fields
	    (
			source_deal_header_id,
			udf_template_id,
			udf_value
	    )
	    SELECT sdh.source_deal_header_id, uddft.udf_template_id, default_value udf_value
			FROM   (
				SELECT TOP 1 t2.source_deal_header_id
					FROM #detail_updated t1 
					INNER JOIN source_deal_detail t2 ON t2.source_deal_detail_id = t1.source_deal_detail_id
				) t
			INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = t.source_deal_header_id
	        INNER JOIN source_deal_header_template sdht
	            ON  sdh.template_id = sdht.template_id
	        INNER JOIN user_defined_deal_fields_template uddft
	            ON  uddft.template_id = sdh.template_id
				AND uddft.udf_template_id > 0
	            AND uddft.udf_type = 'h' 
			   --AND uddft.Field_label in ('Conversion Neutrality Charge','Variable Storage Charge')
		LEFT JOIN user_defined_deal_fields udddf
	            ON  udddf.source_deal_header_id = sdh.source_deal_header_id
	                AND udddf.udf_template_id = uddft.udf_template_id
		WHERE  udddf.udf_deal_id IS NULL

	    INSERT INTO user_defined_deal_detail_fields
	    (
			source_deal_detail_id,
			udf_template_id,
			udf_value
	    )
	    SELECT sdd.source_Deal_detail_id, uddft.udf_template_id, null udf_value
		FROM   #detail_updated t
	        INNER JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = t.source_deal_detail_id 
			INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
	        INNER JOIN source_deal_header_template sdht
	            ON  sdh.template_id = sdht.template_id
	        INNER JOIN user_defined_deal_fields_template uddft
	            ON  uddft.template_id = sdh.template_id
	            AND uddft.Field_label in ('Injection Volume', 'Injection Amount','Withdrawal Volume','Withdrawal Amount','Begining Balance','Ending Balance') 
				AND uddft.Field_type = 't'					
			LEFT JOIN user_defined_deal_detail_fields udddf
	            ON  udddf.source_deal_detail_id = sdd.source_deal_detail_id
	                AND udddf.udf_template_id = uddft.udf_template_id
		WHERE  udddf.udf_deal_id IS NULL

	    UPDATE udddf
	    SET    udddf.udf_value = 
			case uddft.Field_label
				when 'Injection Volume' then t.injection_volume
				when 'Injection Amount' then t.injection_amount
				when 'Withdrawal Volume' then t.withdrawal_volume 
				when 'Withdrawal Amount' then t.withdrawal_amount
				when 'Begining Balance' then t.begining_balance
				when 'Ending Balance' then t.ending_balance
			else null end
		FROM   #detail_updated t
	            INNER JOIN source_deal_detail sdd
	                ON  sdd.source_deal_detail_id = t.source_deal_detail_id 
			INNER JOIN source_deal_header sdh
	                ON  sdh.source_deal_header_id = sdd.source_deal_header_id
	        INNER JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id
	        INNER JOIN user_defined_deal_fields_template uddft ON  uddft.template_id = sdh.template_id
	            AND uddft.Field_label in( 'Injection Volume', 'Injection Amount','Withdrawal Volume','Withdrawal Amount','Begining Balance','Ending Balance')
	        INNER JOIN user_defined_deal_detail_fields udddf
	            ON  udddf.source_deal_detail_id = sdd.source_deal_detail_id
	            AND udddf.udf_template_id = uddft.udf_template_id

		update sdd set 
			settlement_volume=null,
			contractual_volume=null,
			actual_volume=null,
			schedule_volume=null,
			standard_yearly_volume=null
			--,total_volume=null
		FROM   #detail_updated t
	            INNER JOIN source_deal_detail sdd
	                ON  sdd.source_deal_detail_id = t.source_deal_detail_id 

	    UPDATE source_deal_header
	    SET    deal_id = 'Inv'+case when th.template_id=@inv_actual_template_id then 'A' else 'F' end
				+ '_' + CAST(sdh.source_deal_header_id AS VARCHAR)
	    FROM   #tmp_header th
	            INNER JOIN [dbo].[source_deal_header] sdh
	                ON  th.source_deal_header_id = sdh.source_deal_header_id



	    FETCH NEXT FROM storage_cursor INTO @each_storage_assets_id, @storage_location, @agreement, @schedule_injection_id, @schedule_withdrawl_id
		, @source_counterparty_id, @commodity_id, @accounting_type, @injection_as_long, @schedule_injection_id, @schedule_withdrawl_id
				--, @sub_book_id
				, @include_lot_product,@include_fees,@volumn_uom,@calc_mtm,@currency_id,@include_non_standard_deals
	END
	CLOSE storage_cursor
	DEALLOCATE storage_cursor
	
	--45401	45400	FIFO
	--45402	45400	LIFO
	--45400	45400	WACOG

	SET @desc = 'Storage WACOG calculation process completed for run date ' + dbo.FNAUserDateFormat(@as_of_date, dbo.FNADBUser())  + '.'
	
	SET @errorcode = 's'
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
	    ROLLBACK

	SET @errorcode = 'e'
	EXEC spa_print 'CatchError'
		
	IF ERROR_MESSAGE() = 'CatchError'
		BEGIN
	    SET @desc = 'Storage WACOG calculation process completed for run date ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id) + ' (ERRORS found).'
		END
		ELSE
		BEGIN
	    SET @desc = 'Storage WACOG calculation critical error found ( Errr Description:' + ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) 
	        + ').'
		END
END CATCH

DECLARE @sqll varchar(MAX) 
SET @sqll = 'select * ' + isnull(@str_batch_table,'') + ' from #tmp_inventory'
IF @return_output = 1
BEGIN
	if object_id('tempdb..#tmp_inventory') is not null
	exec(@sqll)
END
/*******************************************2nd Paging Batch START**********************************************/
IF @is_batch = 1
BEGIN
    SELECT @sql_paging = dbo.FNABatchProcess(
               'u',
               @batch_process_id,
               @batch_report_param,
               GETDATE(),
               NULL,
               NULL
           ) 
    --EXEC(@sql_paging)
    
    --TODO: modify sp and report name
    SELECT @sql_paging = dbo.FNABatchProcess(
               'c',
               @batch_process_id,
               @batch_report_param,
               GETDATE(),
               'spa_calc_storage_wacog',
               'WACOG Calc'
           )
    --EXEC(@sql_paging)  
    DECLARE @job_name VARCHAR(100)
    SET @job_name = 'report_batch_' + @batch_process_id  
    EXEC spa_message_board 'u',
         @user_login_id,
         NULL,
         'WACOG_Calc',
         @desc,
         '',
         '',
         @errorcode,
         @job_name,
         NULL,
         @batch_process_id,
         NULL,
         'n',
         NULL,
         'y'

    RETURN
END

			--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
    SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
    EXEC (@sql_paging)
END/*******************************************2nd Paging Batch END**********************************************/

