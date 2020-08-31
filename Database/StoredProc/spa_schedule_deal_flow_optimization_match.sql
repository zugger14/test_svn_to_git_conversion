
--drop if exists previuosly created but now not used sp [spa_schedule_deal_flow_optimization_book]
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_schedule_deal_flow_optimization_book]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_schedule_deal_flow_optimization_book]

IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_schedule_deal_flow_optimization_match]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_schedule_deal_flow_optimization_match]
	
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_schedule_deal_flow_optimization_match]
	@flag			CHAR(1),
	@flow_date_from DATETIME,
	@sub            VARCHAR(1000) = NULL,
	@str            VARCHAR(1000) = NULL,
	@book           VARCHAR(1000) = NULL --,'162,164,166,206'
	,@sub_book VARCHAR(1000) = null
	,@box_ids	VARCHAR(1000)
	,@contract_process_id			VARCHAR(50) = NULL
	,@from_priority int=null
	,@to_priority int=null
	,@flow_date_to DATETIME = NULL
	,@counterparty_id int = null

as
set nocount on


/*
declare @flag			CHAR(1),
	@flow_date_from DATETIME,
	@sub            VARCHAR(1000) = NULL,
	@str            VARCHAR(1000) = NULL,
	@book           VARCHAR(1000) = NULL 
	,@sub_book VARCHAR(1000)
	,@box_ids	VARCHAR(1000)
	,@contract_process_id VARCHAR(50) = NULL
	,@from_priority int = null
	,@to_priority int = null
	,@flow_date_to DATETIME = NULL
	,@counterparty_id int = null

select 
@flag='i',@box_ids='1',@flow_date_from='2016-10-01',@flow_date_to='2016-10-02',@contract_process_id='265CA349_D3AC_41E7_9145_EF65EF4023C6'


--*/



IF OBJECT_ID(N'tempdb..#tmp_udhv') IS NOT NULL drop table #tmp_udhv
IF OBJECT_ID(N'tempdb..#term_demand') IS NOT NULL drop table #term_demand
IF OBJECT_ID(N'tempdb..#Nom_group_vol') IS NOT NULL drop table #Nom_group_vol
IF OBJECT_ID(N'tempdb..#Nom_group_vol_run') IS NOT NULL drop table #Nom_group_vol_run
IF OBJECT_ID(N'tempdb..#tmp_nom_location') IS NOT NULL drop table #tmp_nom_location
IF OBJECT_ID(N'tempdb..#book_pipeline') IS NOT NULL DROP TABLE #book_pipeline
IF OBJECT_ID(N'tempdb..#tmp_header') IS NOT NULL DROP TABLE #tmp_header
IF OBJECT_ID(N'tempdb..#inserted_deal_detail') IS NOT NULL DROP TABLE #inserted_deal_detail
IF OBJECT_ID(N'tempdb..#inserted_deal_scheduled') IS NOT NULL DROP TABLE #inserted_deal_scheduled
IF OBJECT_ID(N'tempdb..#tmp_vol_split_deal_final') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final
IF OBJECT_ID(N'tempdb..#inserted_optimizer_header') IS NOT NULL DROP TABLE #inserted_optimizer_header
IF OBJECT_ID(N'tempdb..#group_path_breakdown_vol') IS NOT NULL DROP TABLE #group_path_breakdown_vol
IF OBJECT_ID(N'tempdb..#group_path_volume') IS NOT NULL DROP TABLE #group_path_volume
IF OBJECT_ID(N'tempdb..#tmp_vol_split_deal_final_grp_pre') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final_grp_pre
IF OBJECT_ID(N'tempdb..#tmp_vol_split_deal_final_grp') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final_grp
                                

   
Declare @process_id					VARCHAR(50)
	, @report_position				VARCHAR(250)
	, @user_name					VARCHAR(30)
	, @st1							VARCHAR(max)
	, @sdh_id						INT
	, @idoc							INT
	, @contract_detail				VARCHAR(250)
	, @scheduled_deals				VARCHAR(250)
	, @opt_deal_detail_pos			VARCHAR(250)
DECLARE @sql VARCHAR(MAX)
	

DECLARE  @sdv_from_deal	INT,@sdv_priority INT,@sdv_to_deal int,@path_id int
	,@package_id varchar(20) , @upstream_counterparty INT, @upstream_contract INT

set @package_id=replace(ltrim(replace(str(cast(RAND() as numeric(20,20)),20,20),'0.','')),' ','')
		
SELECT @sdv_from_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'From Deal'

SELECT @sdv_to_deal = value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'To Deal'

SELECT @sdv_priority=value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Priority'

	 
SELECT @upstream_counterparty=value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Upstream CPTY'

SELECT @upstream_contract=
value_id
FROM static_data_value
WHERE [TYPE_ID] = 5500 AND code = 'Upstream Contract'


SET @from_priority = ISNULL(@from_priority, @to_priority)
SET @to_priority = ISNULL(@to_priority, @from_priority)

-- change value id filter to code
SELECT @from_priority = sdv.code
FROM static_data_value sdv 
WHERE sdv.value_id = @from_priority

SELECT @to_priority = sdv.code
FROM static_data_value sdv 
WHERE sdv.value_id = @to_priority


SET @process_id= ISNULL(@contract_process_id, dbo.FNAGetNewID())
SET @user_name= dbo.FNADBUser()	
SET @report_position = dbo.FNAProcessTableName('report_position', @user_name, @process_id) 
SET @contract_detail = dbo.FNAProcessTableName('contractwise_detail_mdq', @user_name, @process_id) 
SET @scheduled_deals = dbo.FNAProcessTableName('scheduled_deals', @user_name, @process_id) 
SET @opt_deal_detail_pos= dbo.FNAProcessTableName('opt_deal_detail_pos', @user_name, @process_id) 
DECLARE @dest_deal_info VARCHAR(500) = dbo.FNAProcessTableName('dest_deal_info', @user_name, @process_id)
 

if OBJECT_ID(@scheduled_deals) is not null
	exec('drop table '+@scheduled_deals)


if OBJECT_ID(@report_position) is not null
	exec('drop table '+@report_position)

--SELECT @contract_detail
--RETURN

EXEC ('IF OBJECT_ID (N''' + @report_position + ''') IS NOT NULL DROP TABLE ' + @report_position + ' 
		CREATE TABLE ' + @report_position + '(source_deal_header_id INT, action CHAR(1))')  


IF OBJECT_ID(N'tempdb..#collect_xml_data') IS NOT NULL DROP TABLE #collect_xml_data
IF OBJECT_ID(N'tempdb..#collect_deals') IS NOT NULL DROP TABLE #collect_deals
IF OBJECT_ID(N'tempdb..#source_deal_book') IS NOT NULL DROP TABLE #source_deal_book
IF OBJECT_ID(N'tempdb..#tmp_vol_split_deal') IS NOT NULL DROP TABLE #tmp_vol_split_deal
IF OBJECT_ID(N'tempdb..#tmp_vol_split_deal_final_grp') IS NOT NULL DROP TABLE #tmp_vol_split_deal_final_grp


set @from_priority=coalesce(@from_priority,@to_priority,0)
set @to_priority=coalesce(@to_priority,nullif(@from_priority,0),999999999)


if OBJECT_ID('tempdb..##dest_deal_info') is not null
drop table ##dest_deal_info

exec('select * into ##dest_deal_info from ' + @dest_deal_info)

if OBJECT_ID('tempdb..#sch_deal_detail') is not null
drop table #sch_deal_detail


if OBJECT_ID('tempdb..#tmp_serial_no') is not null
drop table #tmp_serial_no


if OBJECT_ID('tempdb..#sch_deal_detail_up') is not null
drop table #sch_deal_detail_up




select  group_path_id,single_path_id ,serial_no=identity(int,1,1)
into #tmp_serial_no
from ##dest_deal_info ddi
group by group_path_id,single_path_id


select d.source_deal_header_id template_deal_id,ddi.sub_book_id,dp.[contract], ddi.group_path_id,dp.path_id
	,ddi.loss_factor,ddi.term_start,dp.from_location,dp.to_location
	,cast(ddi.rec_vol as float) rec_vol,cast(ddi.del_vol as float) del_vol
	,dp.counterParty [path_pipeline], ddi.rec_deals, ddi.del_deals
	,sn.serial_no
into #sch_deal_detail --  select * from #sch_deal_detail
from ##dest_deal_info ddi
	inner join #tmp_serial_no sn on ddi.group_path_id=sn.group_path_id and ddi.single_path_id=sn.single_path_id
	inner join delivery_path dp on dp.path_id = ddi.single_path_id
		CROSS JOIN (
		SELECT DISTINCT sdd.source_deal_header_id , sdd.term_start 
		FROM source_deal_detail sdd
		inner join source_deal_header h on sdd.source_deal_header_id=h.source_deal_header_id
		WHERE h.deal_id='Gath Nom Template'
	) d	




select 
p.*,
	sdd.source_deal_header_id
	, sdd.source_deal_detail_id 
	, sdd.deal_volume
	, sdd.deal_volume available_volume
	, p.rec_vol tot_volume
	, cast(0 as numeric(22,8)) run_sum 
	,rowid=identity(int,1,1)
	into #sch_deal_detail_up --  select * from #sch_deal_detail
from #sch_deal_detail p 
cross apply dbo.fnasplit(p.rec_deals,',') up_deal
inner join  dbo.source_deal_detail sdd on sdd.source_deal_header_id =up_deal.item
	and p.term_start between sdd.term_start and sdd.term_end
	and p.from_location=sdd.location_id
where p.serial_no=1
order by p.term_start,sdd.source_deal_header_id,sdd.source_deal_detail_id


if OBJECT_ID('tempdb..#sch_deal_header') is not null
drop table #sch_deal_header
select sdd.path_id, max(sdd.loss_factor) loss_factor, max(sdd.[contract]) [contract], min(sdd.term_start) entire_term_start
, max(sdd.term_start) entire_term_end
	, sum(sdd.rec_vol) total_vol, max(sdd.template_deal_id) template_deal_id, max(sdd.sub_book_id) sub_book_id
	, max(sdd.path_pipeline) [path_pipeline], max(sdd.group_path_id) group_path_id
	, sum(sdd.del_vol) total_vol_del
into #sch_deal_header --select * from #sch_deal_header
from #sch_deal_detail sdd
group by sdd.path_id





--print'	----- start cursor----'
--print '@from_location:'+cast(@from_location as varchar) +'  ,@to_location:'+cast(@to_location as varchar)	 +'  ,@path_id:'+cast(@path_id as varchar)
--print'	-----__________________----'




declare @term datetime
DECLARE  cur_source_deal CURSOR LOCAL FOR
      select   term_start 
	  from #sch_deal_detail_up 
	  group by  term_start
	  order by 1


OPEN cur_source_deal
      FETCH NEXT FROM cur_source_deal INTO @term
      WHILE @@FETCH_STATUS = 0   
      BEGIN 
			--print'	----- start cursor----'
			--print '@from_location:'+cast(@from_location as varchar) +'  ,@to_location:'+cast(@to_location as varchar)	 +'  ,@path_id:'+cast(@path_id as varchar)
			--print'	-----__________________----'

			update a set run_sum=run_sum.run_sum from #sch_deal_detail_up a
			outer apply
			(	
				select sum(available_volume) run_sum from #sch_deal_detail_up where term_start=@term
					and   rowid<=a.rowid	
			) run_sum
			where   a.tot_volume>=run_sum.run_sum-a.available_volume and term_start=@term	
		--	select sum(available_volume) from #tmp_vol_split_deal
			 --select distinct * from  #tmp_vol_split_deal where tot_volume>run_sum and from_location=@from_location 
				--and to_location=@to_location  and path_id=@path_id 

			 -- select * from #sch_deal_detail_up

			delete #sch_deal_detail_up where run_sum=0	and term_start=@term 
				

			--update required deal volume for the location (split deal)
			update #sch_deal_detail_up set available_volume=tot_volume-(run_sum-available_volume)
				where  run_sum> tot_volume and term_start=@term

			--update remaing deal volume for other low ranking location (split deal)
			update 	t  set available_volume =new_available_volume from #sch_deal_detail_up t
			 cross join
			(	select  run_sum- tot_volume new_available_volume from  #sch_deal_detail_up
				 where run_sum>= tot_volume	and term_start=@term
			) d
			where term_start=@term and run_sum=0

			delete #sch_deal_detail_up where available_volume=0 and term_start=@term

			--print'	----- end cursor----'
			--print '@from_location:'+cast(@from_location as varchar) +'  ,@to_location:'+cast(@to_location as varchar) 	 +'  ,@path_id:'+cast(@path_id as varchar)
			--print'	-----__________________----'


            FETCH NEXT FROM cur_source_deal INTO @term
      END

CLOSE cur_source_deal
DEALLOCATE  cur_source_deal
--print getdate()	



 -- select * from #sch_deal_detail_up order by rowid
	 
--print'	----- end cursor----'
--print '@from_location:'+cast(@from_location as varchar) +'  ,@to_location:'+cast(@to_location as varchar) 	 +'  ,@path_id:'+cast(@path_id as varchar)
--print'	-----__________________----'



if OBJECT_ID('tempdb..#tmp_header') is not null
drop table #tmp_header
SELECT [source_system_id]
		, cast([deal_id] as varchar(250)) [deal_id]
		, [deal_date]
		, [ext_deal_id]
		, [physical_financial_flag]
		, [structured_deal_id]
		, [counterparty_id]
		, [entire_term_start]
		, [entire_term_end]
		, [source_deal_type_id]
		, [deal_sub_type_type_id]
		, [option_flag]
		, [option_type]
		, [option_excercise_type]
		, [source_system_book_id1]
		, [source_system_book_id2]
		, [source_system_book_id3]
		, [source_system_book_id4]
		, [description1]
		, [description2]
		, [description3]
		, [deal_category_value_id]
		, [trader_id]
		, [internal_deal_type_value_id]
		, [internal_deal_subtype_value_id]
		, [template_id]
		, [header_buy_sell_flag]
		, [broker_id]
		, [generator_id]
		, [status_value_id]
		, [status_date]
		, [assignment_type_value_id]
		, [compliance_year]
		, [state_value_id]
		, [assigned_date]
		, [assigned_by]
		, [generation_source]
		, [aggregate_environment]
		, [aggregate_envrionment_comment]
		, [rec_price]
		, [rec_formula_id]
		, [rolling_avg]
		, [contract_id]
		, [create_user]
		, [create_ts]
		, [update_user]
		, [update_ts]
		, [legal_entity]
		, [internal_desk_id]
		, [product_id]
		, [internal_portfolio_id]
		, [commodity_id]
		, [reference]
		, [deal_locked]
		, [close_reference_id]
		, [block_type]
		, [block_define_id]
		, [granularity_id]
		, [Pricing]
		, [deal_reference_type_id]
		, [unit_fixed_flag]
		, [broker_unit_fees]
		, [broker_fixed_cost]
		, [broker_currency_id]
		, [deal_status]
		, [term_frequency]
		, [option_settlement_date]
		, [verified_by]
		, [verified_date]
		, [risk_sign_off_by]
		, [risk_sign_off_date]
		, [back_office_sign_off_by]
		, [back_office_sign_off_date]
		, [book_transfer_id]
		, [confirm_status_type]
		, [sub_book]
		, [deal_rules]
		, [confirm_rule]
		, [description4]
		, [timezone_id]
		, CAST(0 AS INT) source_deal_header_id 
	INTO #tmp_header
	FROM [dbo].[source_deal_header] 
	WHERE 1 = 2

BEGIN TRY
	begin tran
	INSERT INTO [dbo].[source_deal_header]
			   ([source_system_id]
			   , [deal_id]
			   , [deal_date]
			   , [ext_deal_id]
			   , [physical_financial_flag]
			   , [structured_deal_id]
			   , [counterparty_id]
			   , [entire_term_start]
			   , [entire_term_end]
			   , [source_deal_type_id]
			   , [deal_sub_type_type_id]
			   , [option_flag]
			   , [option_type]
			   , [option_excercise_type]
			   , [source_system_book_id1]
			   , [source_system_book_id2]
			   , [source_system_book_id3]
			   , [source_system_book_id4]
			   , [description1]
			   , [description2]
			   , [description3]
			   , [deal_category_value_id]
			   , [trader_id]
			   , [internal_deal_type_value_id]
			   , [internal_deal_subtype_value_id]
			   , [template_id]
			   , [header_buy_sell_flag]
			   , [broker_id]
			   , [generator_id]
			   , [status_value_id]
			   , [status_date]
			   , [assignment_type_value_id]
			   , [compliance_year]
			   , [state_value_id]
			   , [assigned_date]
			   , [assigned_by]
			   , [generation_source]
			   , [aggregate_environment]
			   , [aggregate_envrionment_comment]
			   , [rec_price]
			   , [rec_formula_id]
			   , [rolling_avg]
			   , [contract_id]
			   , [create_user]
			   , [create_ts]
			   , [update_user]
			   , [update_ts]
			   , [legal_entity]
			   , [internal_desk_id]
			   , [product_id]
			   , [internal_portfolio_id]
			   , [commodity_id]
			   , [reference]
			   , [deal_locked]
			   , [close_reference_id]
			   , [block_type]
			   , [block_define_id]
			   , [granularity_id]
			   , [Pricing]
			   , [deal_reference_type_id]
			   , [unit_fixed_flag]
			   , [broker_unit_fees]
			   , [broker_fixed_cost]
			   , [broker_currency_id]
			   , [deal_status]
			   , [term_frequency]
			   , [option_settlement_date]
			   , [verified_by]
			   , [verified_date]
			   , [risk_sign_off_by]
			   , [risk_sign_off_date]
			   , [back_office_sign_off_by]
			   , [back_office_sign_off_date]
			   , [book_transfer_id]
			   , [confirm_status_type]
			   , [sub_book]
			   , [deal_rules]
			   , [confirm_rule]
			   , [description4]
			   , [timezone_id])

		output 
				inserted.[source_system_id]
			   , inserted.[deal_id]
			   , inserted.[deal_date]
			   , inserted.[ext_deal_id]
			   , inserted.[physical_financial_flag]
			   , inserted.[structured_deal_id]
			   , inserted.[counterparty_id]
			   , inserted.[entire_term_start]
			   , inserted.[entire_term_end]
			   , inserted.[source_deal_type_id]
			   , inserted.[deal_sub_type_type_id]
			   , inserted.[option_flag]
			   , inserted.[option_type]
			   , inserted.[option_excercise_type]
			   , inserted.[source_system_book_id1]
			   , inserted.[source_system_book_id2]
			   , inserted.[source_system_book_id3]
			   , inserted.[source_system_book_id4]
			   , inserted.[description1]
			   , inserted.[description2]
			   , inserted.[description3]
			   , inserted.[deal_category_value_id]
			   , inserted.[trader_id]
			   , inserted.[internal_deal_type_value_id]
			   , inserted.[internal_deal_subtype_value_id]
			   , inserted.[template_id]
			   , inserted.[header_buy_sell_flag]
			   , inserted.[broker_id]
			   , inserted.[generator_id]
			   , inserted.[status_value_id]
			   , inserted.[status_date]
			   , inserted.[assignment_type_value_id]
			   , inserted.[compliance_year]
			   , inserted.[state_value_id]
			   , inserted.[assigned_date]
			   , inserted.[assigned_by]
			   , inserted.[generation_source]
			   , inserted.[aggregate_environment]
			   , inserted.[aggregate_envrionment_comment]
			   , inserted.[rec_price]
			   , inserted.[rec_formula_id]
			   , inserted.[rolling_avg]
			   , inserted.[contract_id]
			   , inserted.[create_user]
			   , inserted.[create_ts]
			   , inserted.[update_user]
			   , inserted.[update_ts]
			   , inserted.[legal_entity]
			   , inserted.[internal_desk_id]
			   , inserted.[product_id]
			   , inserted.[internal_portfolio_id]
			   , inserted.[commodity_id]
			   , inserted.[reference]
			   , inserted.[deal_locked]
			   , inserted.[close_reference_id]
			   , inserted.[block_type]
			   , inserted.[block_define_id]
			   , inserted.[granularity_id]
			   , inserted.[Pricing]
			   , inserted.[deal_reference_type_id]
			   , inserted.[unit_fixed_flag]
			   , inserted.[broker_unit_fees]
			   , inserted.[broker_fixed_cost]
			   , inserted.[broker_currency_id]
			   , inserted.[deal_status]
			   , inserted.[term_frequency]
			   , inserted.[option_settlement_date]
			   , inserted.[verified_by]
			   , inserted.[verified_date]
			   , inserted.[risk_sign_off_by]
			   , inserted.[risk_sign_off_date]
			   , inserted.[back_office_sign_off_by]
			   , inserted.[back_office_sign_off_date]
			   , inserted.[book_transfer_id]
			   , inserted.[confirm_status_type]
			   , inserted.[sub_book]
			   , inserted.[deal_rules]
			   , inserted.[confirm_rule]
			   , inserted.[description4]
			   , inserted.[timezone_id]
			, inserted.[source_deal_header_id]			
		INTO #tmp_header
	--insert into #tmp_header
	SELECT 
		h.[source_system_id]
			   , @process_id+'____' + CAST(p.path_id AS VARCHAR)
			   , @flow_date_from
			   , h.[ext_deal_id]
			   , h.[physical_financial_flag]
			   , h.[structured_deal_id]
			   , p.[path_pipeline] [counterparty_id]
			   , p.entire_term_start
			   , p.entire_term_end
			   , h.[source_deal_type_id]
			   , h.[deal_sub_type_type_id]
			   , h.[option_flag]
			   , h.[option_type]
			   , h.[option_excercise_type]
			   , isnull(ssbm.source_system_book_id1,h.source_system_book_id1 )
			   , isnull(ssbm.source_system_book_id2 ,h.source_system_book_id2 )
			   , isnull(ssbm.source_system_book_id3 ,h.source_system_book_id3 )
			   , isnull(ssbm.source_system_book_id4 ,h.source_system_book_id4)
			   , h.[description1]
			   , h.[description2]
			   , h.[description3]
			   , h.[deal_category_value_id]
			   , h.[trader_id]
			   , h.[internal_deal_type_value_id] [internal_deal_type_value_id]
			   , h.[internal_deal_subtype_value_id]
			   , h.[template_id]
			   , h.[header_buy_sell_flag]
			   , h.[broker_id]
			   , h.[generator_id]
			   , h.[status_value_id]
			   , h.[status_date]
			   , h.[assignment_type_value_id]
			   , h.[compliance_year]
			   , h.[state_value_id]
			   , h.[assigned_date]
			   , h.[assigned_by]
			   , h.[generation_source]
			   , h.[aggregate_environment]
			   , h.[aggregate_envrionment_comment]
			   , h.[rec_price]
			   , h.[rec_formula_id]
			   , h.[rolling_avg]
			   , p.[contract]
			   , h.[create_user]
			   , getdate()
			   , h.[update_user]
			   , getdate()
			   , h.[legal_entity]
			   , h.[internal_desk_id]
			   , h.[product_id]
			   , h.[internal_portfolio_id]
			   , h.[commodity_id]
			   , h.[reference]
			   , 'n' [deal_locked]
			   , h.[close_reference_id]
			   , h.[block_type]
			   , h.[block_define_id]
			   , h.[granularity_id]
			   , h.[Pricing]
			   , h.[deal_reference_type_id]
			   , h.[unit_fixed_flag]
			   , h.[broker_unit_fees]
			   , h.[broker_fixed_cost]
			   , h.[broker_currency_id]
			   , h.[deal_status]
			   , h.[term_frequency]
			   , h.[option_settlement_date]
			   , h.[verified_by]
			   , h.[verified_date]
			   , h.[risk_sign_off_by]
			   , h.[risk_sign_off_date]
			   , h.[back_office_sign_off_by]
			   , h.[back_office_sign_off_date]
			   , h.[book_transfer_id]
			   , h.[confirm_status_type]
			   ,ISNULL(p.sub_book_id, h.[sub_book])
			   , h.[deal_rules]
			   , h.[confirm_rule]
			   , p.group_path_id [description4]
			   , h.[timezone_id]
			   --,p.path_id source_deal_header_id
from #sch_deal_header p --select * from #sch_deal_header
INNER JOIN source_deal_header h ON h.source_deal_header_id = p.template_deal_id	 
left join source_system_book_map ssbm on ssbm.book_deal_type_map_id = p.sub_book_id



	CREATE TABLE #inserted_deal_detail (
		source_deal_header_id	INT, 
		source_deal_detail_id	INT,
		leg						INT   ,
		term_start datetime
	)


	INSERT INTO [dbo].[source_deal_detail]
			   ([source_deal_header_id]
			   , [term_start]
			   , [term_end]
			   , [Leg]
			   , [contract_expiration_date]
			   , [fixed_float_leg]
			   , [buy_sell_flag]
			   , [curve_id]
			   , [fixed_price]
			   , [fixed_price_currency_id]
			   , [option_strike_price]
			   , [deal_volume]
			   , [deal_volume_frequency]
			   , [deal_volume_uom_id]
			   , [block_description]
			   , [deal_detail_description]
			   , [formula_id]
			   , [volume_left]
			   , [settlement_volume]
			   , [settlement_uom]
			   , [create_user]
			   , [create_ts]
			   , [update_user]
			   , [update_ts]
			   , [price_adder]
			   , [price_multiplier]
			   , [settlement_date]
			   , [day_count_id]
			   , [location_id]
			   , [meter_id]
			   , [physical_financial_flag]
			   , [Booked]
			   , [process_deal_status]
			   , [fixed_cost]
			   , [multiplier]
			   , [adder_currency_id]
			   , [fixed_cost_currency_id]
			   , [formula_currency_id]
			   , [price_adder2]
			   , [price_adder_currency2]
			   , [volume_multiplier2]
			  -- , [total_volume]
			   , [pay_opposite]
			   , [capacity]
			   , [settlement_currency]
			   , [standard_yearly_volume]
			   , [formula_curve_id]
			   , [price_uom_id]
			   , [category]
			   , [profile_code]
			   , [pv_party]
			   , [status]
			   , [lock_deal_detail])
	OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.leg  ,inserted.term_start
	INTO #inserted_deal_detail
	select th.[source_deal_header_id]
			   , p.term_start
			   , p.term_start
			   , s.[Leg]
			   , s.[contract_expiration_date]
			   , s.[fixed_float_leg]
			   , s.[buy_sell_flag]
			   , s.[curve_id]
			   , s.[fixed_price]
			   , s.[fixed_price_currency_id]
			   , s.[option_strike_price]
			   , p.rec_vol  [deal_volume]
			   , s.[deal_volume_frequency]
			   , s.[deal_volume_uom_id]
			   , s.[block_description]
			   , s.[deal_detail_description]
			   , s.[formula_id]
			   , p.del_vol [volume_left]
			   , s.[settlement_volume]
			   , s.[settlement_uom]
			   , s.[create_user]
			   , getdate() [create_ts]
			   , s.[update_user]
			   , getdate() [update_ts]
			   , s.[price_adder]
			   , s.[price_multiplier]
			   , s.[settlement_date]
			   , s.[day_count_id]
			   , p.from_location [location_id]
			   , s.meter_id [meter_id]
			   , s.[physical_financial_flag]
			   , s.[Booked]
			   , s.[process_deal_status]
			   , s.[fixed_cost]
			   , s.[multiplier]
			   , s.[adder_currency_id]
			   , s.[fixed_cost_currency_id]
			   , s.[formula_currency_id]
			   , s.[price_adder2]
			   , s.[price_adder_currency2]
			   , s.[volume_multiplier2]
			  -- , s.[total_volume]
			   , s.[pay_opposite]
			   , s.[capacity]
			   , s.[settlement_currency]
			   , s.[standard_yearly_volume]
			   , s.[formula_curve_id]
			   , s.[price_uom_id]
			   , s.[category]
			   , s.[profile_code]
			   , s.[pv_party]
			   , s.[status]
			   , s.[lock_deal_detail]	
	from #sch_deal_detail p	
	inner join	[dbo].[source_deal_detail] s on s.source_deal_header_id=p.template_deal_id and s.Leg=1
	inner join  #tmp_header th  ON th.deal_id=@process_id +'____'+cast(p.path_id AS VARCHAR)
	--cross apply [dbo].[FNATermBreakdown]('d',isnull(p.match_term_start,@flow_date_from) ,isnull(p.match_term_end,@flow_date_to)) tm
	
	--LEFT JOIN delivery_path dp ON dp.path_id = p.path_id
	INSERT INTO [dbo].[source_deal_detail]
			   ([source_deal_header_id]
			   , [term_start]
			   , [term_end]
			   , [Leg]
			   , [contract_expiration_date]
			   , [fixed_float_leg]
			   , [buy_sell_flag]
			   , [curve_id]
			   , [fixed_price]
			   , [fixed_price_currency_id]
			   , [option_strike_price]
			   , [deal_volume]
			   , [deal_volume_frequency]
			   , [deal_volume_uom_id]
			   , [block_description]
			   , [deal_detail_description]
			   , [formula_id]
			   , [volume_left]
			   , [settlement_volume]
			   , [settlement_uom]
			   , [create_user]
			   , [create_ts]
			   , [update_user]
			   , [update_ts]
			   , [price_adder]
			   , [price_multiplier]
			   , [settlement_date]
			   , [day_count_id]
			   , [location_id]
			   , [meter_id]
			   , [physical_financial_flag]
			   , [Booked]
			   , [process_deal_status]
			   , [fixed_cost]
			   , [multiplier]
			   , [adder_currency_id]
			   , [fixed_cost_currency_id]
			   , [formula_currency_id]
			   , [price_adder2]
			   , [price_adder_currency2]
			   , [volume_multiplier2]
			  -- , [total_volume]
			   , [pay_opposite]
			   , [capacity]
			   , [settlement_currency]
			   , [standard_yearly_volume]
			   , [formula_curve_id]
			   , [price_uom_id]
			   , [category]
			   , [profile_code]
			   , [pv_party]
			   , [status]
			   , [lock_deal_detail])
	OUTPUT INSERTED.source_deal_header_id, INSERTED.source_deal_detail_id ,INSERTED.leg  ,inserted.term_start
	INTO #inserted_deal_detail
	select th.[source_deal_header_id]
			   , p.term_start
			   , p.term_start
			   , s.[Leg]
			   , s.[contract_expiration_date]
			   , s.[fixed_float_leg]
			   , s.[buy_sell_flag]
			   , s.[curve_id]
			   , s.[fixed_price]
			   , s.[fixed_price_currency_id]
			   , s.[option_strike_price]
			   , p.del_vol  [deal_volume]
			   , s.[deal_volume_frequency]
			   , s.[deal_volume_uom_id]
			   , s.[block_description]
			   , s.[deal_detail_description]
			   , s.[formula_id]
			   , p.del_vol [volume_left]
			   , s.[settlement_volume]
			   , s.[settlement_uom]
			   , s.[create_user]
			   , getdate() [create_ts]
			   , s.[update_user]
			   , getdate() [update_ts]
			   , s.[price_adder]
			   , s.[price_multiplier]
			   , s.[settlement_date]
			   , s.[day_count_id]
			   , p.to_location [location_id]
			   , s.meter_id [meter_id]
			   , s.[physical_financial_flag]
			   , s.[Booked]
			   , s.[process_deal_status]
			   , s.[fixed_cost]
			   , s.[multiplier]
			   , s.[adder_currency_id]
			   , s.[fixed_cost_currency_id]
			   , s.[formula_currency_id]
			   , s.[price_adder2]
			   , s.[price_adder_currency2]
			   , s.[volume_multiplier2]
			  -- , s.[total_volume]
			   , s.[pay_opposite]
			   , s.[capacity]
			   , s.[settlement_currency]
			   , s.[standard_yearly_volume]
			   , s.[formula_curve_id]
			   , s.[price_uom_id]
			   , s.[category]
			   , s.[profile_code]
			   , s.[pv_party]
			   , s.[status]
			   , s.[lock_deal_detail]	
	from #sch_deal_detail p	
	inner join	[dbo].[source_deal_detail] s on s.source_deal_header_id=p.template_deal_id and s.Leg=2
	inner join  #tmp_header th  ON th.deal_id=@process_id +'____'+cast(p.path_id AS VARCHAR)

	

	--insert into deal_schedule
	CREATE TABLE #inserted_deal_scheduled (
			deal_schedule_id		INT, 
			path_id					INT 	
	)

	/*
	INSERT INTO [dbo].[deal_schedule](path_id, term_start, term_end, scheduled_volume, delivered_volume) 
	OUTPUT INSERTED.deal_schedule_id, INSERTED.path_id
	INTO #inserted_deal_scheduled
	SELECT p.path_id path_id
		, p.entire_term_start term_start
		, p.entire_term_end term_end
		, p.receipt_volume
		, p.delivery_volume
	 FROM #sch_deal_header p
	--cross apply [dbo].[FNATermBreakdown]('d',isnull(p.match_term_start,@flow_date_from) ,isnull(p.match_term_end,@flow_date_to)) tm
	 where isnull(p.storage_deal_type	,'n') ='n'
	*/ 

	/**********************insert into *[user_defined_deal_fields]*****************************************************/

	DECLARE @delivery_path_id INT 

	SELECT @delivery_path_id =value_id
	FROM static_data_value sdv
	WHERE code = 'Delivery Path'	
	
	--SELECT value_id
	--FROM static_data_value sdv
	--WHERE code = 'Delivery Path'			

	--print 'INSERT INTO [dbo].[user_defined_deal_fields]'
	--print	getdate()
	
									
	INSERT INTO [dbo].[user_defined_deal_fields]
			([source_deal_header_id]
			,[udf_template_id]
			,[udf_value]
			,[create_user]
			,[create_ts])
	SELECT	th.source_deal_header_id 
			,u.[udf_template_id]
			, CASE uddft.field_id				
					--WHEN -5607 THEN ids.deal_schedule_id
					WHEN -5614 THEN cast(p.loss_factor as varchar)	 -- loss_factor
					WHEN @delivery_path_id THEN cast(cast(isnull(p.path_id,p.path_id) as numeric(28,0)) as varchar)
					
					ELSE u.udf_value
			END
			,dbo.fnadbuser()
			,GETDATE()
	from #sch_deal_header p
	
	left join [user_defined_deal_fields] u on 	u.[source_deal_header_id]=p.template_deal_id
	left join  #tmp_header th	ON th.deal_id=@process_id+'____'+cast(p.path_id AS VARCHAR)
	left JOIN [dbo].[user_defined_deal_fields_template] uddft ON uddft.template_id = th.template_id 
		AND uddft.udf_template_id = u.udf_template_id 
	
	/*
	INSERT INTO user_defined_deal_detail_fields
	(
		-- udf_deal_id -- this column value is auto-generated
		source_deal_detail_id,
		udf_template_id,
		udf_value
	)
	SELECT idd.source_deal_detail_id
		, uddft.udf_template_id
	, CASE uddft.field_id				
		when  @sdv_priority then cast(cast(case when  p.storage_deal_type='i' then sdv.value_id
									else uddft.default_value end as numeric(28,0)) as varchar)
	ELSE uddft.default_value
	END default_value
	from #tmp_vol_split_deal_final_grp p inner join  #tmp_header th	ON th.deal_id=@process_id+'____'+cast(p.rowid AS VARCHAR)
	inner join	#inserted_deal_detail idd on th.source_deal_header_id=idd.source_deal_header_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = p.templete_deal_id
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
	AND uddft.leg = idd.leg	and uddft.udf_type = 'd'
	left join  #tmp_vol_split_deal_final_grp p_tra	ON p_tra.rowid=-1*p.rowid  and p.rowid<0 and p_tra.rowid>0
	left join static_data_value sdv on isnull(p_tra.description2,168)=sdv.code and sdv.type_id=32000

	--print 'update 	h set description2= sdv.code '
	*/

	/*
	update 	h set description2= sdv.code   from  source_deal_header h
	INNER JOIN #tmp_vol_split_deal_final_grp p ON h.deal_id=@process_id+'____'+cast(p.rowid AS VARCHAR)
	inner join #collect_deals wth on isnull(p.single_path_id,p.path_id)=isnull(wth.single_path_id,wth.path_id) --and p.rowid>100000000 
		and  p.org_storage_deal_type= 'w'
		and p.storage_deal_type='n' and wth.storage_deal_type='w'
	inner join  #tmp_header th_wth	ON th_wth.deal_id=@process_id+'____'+cast(100000000+wth.rowid AS VARCHAR)
	left JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = th_wth.source_deal_header_id
	left JOIN user_defined_deal_fields_template uddft1 ON uddft1.template_id = sdh1.template_id
		AND uddft1.leg = 1 and uddft1.udf_type = 'd' and uddft1.field_id= @sdv_priority
	left join static_data_value sdv on sdv.value_id=uddft1.default_value
	*/
	--return
	

	UPDATE [dbo].[source_deal_header] set deal_id= 'SCHD_' +cast(h.source_deal_header_id AS VARCHAR) 
	FROM [dbo].[source_deal_header] h 
	INNER JOIN #tmp_header t ON h.source_deal_header_id=t.source_deal_header_id
	INNER JOIN #sch_deal_header p ON h.deal_id=@process_id+'____'+cast(p.path_id AS VARCHAR)

	
	create table #inserted_optimizer_header (optimizer_header_id int, package_id varchar(20) COLLATE DATABASE_DEFAULT ,	 SLN_id int
	,flow_date datetime,transport_deal_id int,del_nom_volume numeric(28,8),rec_nom_volume  numeric(28,8))
   
   --select * from #inserted_optimizer_header
	insert into dbo.optimizer_header
		(
			flow_date ,	
			transport_deal_id ,
			package_id ,	
			SLN_id ,		
			receipt_location_id,	
			delivery_location_id,	
			rec_nom_volume,
			del_nom_volume	
			
		 )
	output inserted.optimizer_header_id, inserted.package_id,inserted.SLN_id,inserted.flow_date,inserted.transport_deal_id ,inserted.del_nom_volume,inserted.rec_nom_volume
		into #inserted_optimizer_header (optimizer_header_id , package_id,SLN_id,flow_date,transport_deal_id,del_nom_volume,rec_nom_volume )
	select	@flow_date_from ,	
			th.source_deal_header_id transport_deal_id ,
			@package_id package_id ,	
			path_id SLN_id ,		
			null receipt_location_id,	
			null delivery_location_id,	
			p.total_vol rec_nom_volume,
			p.total_vol_del del_nom_volume
			--select * from #sch_deal_detail
	from #sch_deal_header p
	  inner join  #tmp_header th	ON th.deal_id=@process_id+'____'+cast(p.path_id AS VARCHAR)
	  
	 --and p.storage_deal_type='n'

 --------------------------------------------------------
 --schedule deal: received volumn unthreaed (first deal of group path or non group path)--p.serial_no=1 
 -------------------------------------------------------
	insert into dbo.optimizer_detail
		(
			optimizer_header_id,
			flow_date,	
			transport_deal_id,
			up_down_stream,
			source_deal_header_id,
			source_deal_detail_id,
			deal_volume,
			volume_used
	)	
	select i.optimizer_header_id ,p.term_start,i.transport_deal_id
		, 'U' up_down_stream
		, p.source_deal_header_id
		, p.source_deal_detail_id 
		, null deal_volume
		, p.available_volume volume_used
	 from #sch_deal_detail_up p
	inner join #inserted_optimizer_header i on  i.SLN_id=p.path_id 
			and p.serial_no=1 
	--cross apply dbo.fnasplit(p.rec_deals,',') up_deal
	--inner join  dbo.source_deal_detail sdd on sdd.source_deal_header_id =up_deal.item
	--	and p.term_start between sdd.term_start and sdd.term_end
	--	and p.from_location=sdd.location_id

-- select * from #sch_deal_detail
-- select * from #inserted_optimizer_header
--------------------------------------------------------
 --schedule deal: received volumn unthreaed (group path only)--p.serial_no>1 
 -------------------------------------------------------
	insert into dbo.optimizer_detail
		(
			optimizer_header_id,
			flow_date,	
			transport_deal_id,
			up_down_stream,
			source_deal_header_id,
			source_deal_detail_id,
			deal_volume,
			volume_used
	)	
	select p.optimizer_header_id ,sch.term_start,p.transport_deal_id
		,'U' up_down_stream
		,sdd.source_deal_header_id
		,sdd.source_deal_detail_id
		,null deal_volume
		,sdd.deal_volume
	from #inserted_optimizer_header p
	inner join #inserted_optimizer_header p_up on  p_up.optimizer_header_id+1=p.optimizer_header_id
		and p_up.flow_date=p.flow_date
	inner join  #sch_deal_detail sch on  p_up.SLN_id=sch.path_id 
			--and p.serial_no>1 
	inner join  dbo.source_deal_detail sdd on sdd.source_deal_header_id =p_up.transport_deal_id
		and sch.term_start between sdd.term_start and sdd.term_end
		and sdd.leg=2	

 
	insert into dbo.optimizer_detail
		(
			optimizer_header_id,
			flow_date,	
			transport_deal_id,
			up_down_stream,
			source_deal_header_id,
			source_deal_detail_id,
			deal_volume,
			volume_used
	)	
	select p.optimizer_header_id ,sch.term_start,p.transport_deal_id
		,'D' up_down_stream
		,sdd.source_deal_header_id
		,sdd.source_deal_detail_id
		,null deal_volume
		,sdd.deal_volume
		
	 from #inserted_optimizer_header p
	inner join #inserted_optimizer_header p_dw on  p_dw.optimizer_header_id-1=p.optimizer_header_id
		and p_dw.flow_date=p.flow_date
	inner join  #sch_deal_detail sch on  p_dw.SLN_id=sch.path_id 
			--and p.serial_no>1 
	inner join  dbo.source_deal_detail sdd on sdd.source_deal_header_id =p_dw.transport_deal_id
		and sch.term_start between sdd.term_start and sdd.term_end
		and sdd.leg= 1
	 

   insert into dbo.optimizer_detail
		(
			optimizer_header_id,
			flow_date,	
			transport_deal_id,
			up_down_stream,
			source_deal_header_id,
			source_deal_detail_id,
			deal_volume,
			volume_used
	)	
	select p.optimizer_header_id ,sch.term_start,p.transport_deal_id
		, 'D'  up_down_stream
		,sdd.source_deal_header_id
		,sdd.source_deal_detail_id
		,null deal_volume
		,sdd.deal_volume
	 from 
	( select top(1) * from #inserted_optimizer_header order by transport_deal_id desc  ) p
	inner join #sch_deal_detail sch on p.SLN_id=sch.path_id 
	cross apply dbo.fnasplit(sch.del_deals,',') dw_deal
	inner join  dbo.source_deal_detail sdd on sdd.source_deal_header_id =dw_deal.item
		and sdd.location_id= sch.to_location	
		and sch.term_start between sdd.term_start and sdd.term_end
	
	--1604
	--select location_id from source_deal_detail where source_deal_header_id=40334
	
	--Deal audit logic for insert deals starts
	DECLARE @deal_ids VARCHAR(MAX)

	SELECT @deal_ids = STUFF((SELECT ','+ CAST(sdh.source_deal_header_id  AS VARCHAR)  
								FROM #tmp_header sdh ORDER BY  sdh.source_deal_header_id  FOR XML PATH ('')), 1, 1, '')
			
	--print @deal_ids	
	
	--INSERT DEALS JUST CREATED ON PROCESS TABLE THAT IS USED TO DELETE BY REFRESH BUTTON ON OPTIMIZATION SCREEN ON BASIS OF PROCESS ID
	SET @sql = '
	SELECT  ROW_NUMBER() OVER(ORDER BY d.item) [row_id], d.item [source_deal_header_id]
	INTO ' + @scheduled_deals + '
	FROM dbo.SplitCommaSeperatedValues(''' + @deal_ids + ''') d'
	--print @sql
	EXEC(@sql)
	--select * from adiha_process.dbo.scheduled_deals_farrms_admin_FCE5E015_5769_4525_B9E0_D82C26EDCE05				
							
	EXEC spa_insert_update_audit 'i', @deal_ids
	--Deal audit logic for insert deals ends
			
	IF EXISTS(SELECT 1 FROM #tmp_header)
	BEGIN
		DECLARE @spa VARCHAR(max), @job_name       VARCHAR(150)
		SET @job_name = 'calc_deal_position_breakdown' + @process_id

		SET @st1 = 'INSERT INTO ' + @report_position + '(source_deal_header_id,action) SELECT source_deal_header_id,''i'' from #tmp_header'
		--print @st1   
		EXEC (@st1) 

		SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_name + ''',NULL, NULL, ' + ISNULL('' + null + '', 'NULL') + ''	
		--print(@spa)
		EXEC spa_run_sp_as_job @job_name,  @spa, 'generating_report_table', @user_name

	END
	commit
	
	
	EXEC spa_ErrorHandler 0
	, 'Flow Optimization'
	, 'spa_schedule_deal_flow_optimization_match'
	, 'Success'
	, 'Successfully saved transportation deal.'
	, ''

	
END TRY
BEGIN CATCH
rollback
	--print 'Catch Error:' + ERROR_MESSAGE()	
	declare @err_msg varchar(3000) = error_message()
	EXEC spa_ErrorHandler 1
	, 'Flow Optimization'
	, 'spa_schedule_deal_flow_optimization_match'
	, 'Error'
	, 'Fail to save transportation deal.'
	, @err_msg

END CATCH
--*/
