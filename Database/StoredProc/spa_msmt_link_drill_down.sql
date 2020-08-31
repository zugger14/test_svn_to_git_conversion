

if OBJECT_ID('spa_msmt_link_drill_down') is not null
	drop proc dbo.spa_msmt_link_drill_down
	
GO

-- exec spa_Create_Hedges_Measurement_Report '2010-09-30', '795', NULL, NULL, 'd', 'a', 'c', 'm', '517','2',NULL,'n',NULL,NULL,NULL,NULL,NULL,NULL

-- exec spa_msmt_link_drill_down 'd', '1/31/2003', '52', 'f'
-- exec spa_msmt_link_drill_down 'd', '1/31/2003', '6-D', 'f'
-- EXEC spa_msmt_link_drill_down 'd', '2004-08-30', '191', 'c'
CREATE PROCEDURE [dbo].[spa_msmt_link_drill_down]  
	@discount_option varchar(1),
	@as_of_date varchar(20),
	@link_id varchar(100),
	@settlement_option varchar(1),
	@sub_entity_id varchar(MAX) = NULL, 
	@strategy_entity_id varchar(MAX) = NULL, 
	@book_entity_id varchar(MAX) = NULL,
	@round_value varchar(1) = '2',
	@legal_entity varchar(50) = NULL,
	@hypothetical varchar(1)=NULL,
	@non_drill_link_id varchar(500)=NULL,
	@source_deal_header_id varchar(500)=NULL,
	@deal_id varchar(500)=NULL,
	@report_type varchar(1) = NULL,	
	@all_mtm varchar(1) = 'n',
	@term_month varchar(20) = NULL,
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
					@link_desc varchar(1000)=null,
					@link_id_to varchar(500)=null,
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL
AS
SET NOCOUNT ON
/*
---------------------BEGIN TESTING 
declare  @discount_option varchar(1)='d',
					 @as_of_date varchar(20)='2011-12-31',
					 @link_id varchar(100)=null,
					 @settlement_option varchar(1)='f',
					 @sub_entity_id varchar(200) = '4', 
 					 @strategy_entity_id varchar(500) = NULL, 
					 @book_entity_id varchar(500) = NULL,
					 @round_value varchar(1) = '2',
					 @legal_entity varchar(50) = NULL,
				  	 @hypothetical varchar(1)='n',
					 @non_drill_link_id varchar(500)='30496',
					 @source_deal_header_id varchar(500)=NULL,
					 @deal_id varchar(500)=NULL,
					 @report_type varchar(1) = 'c',	
					 @all_mtm varchar(1) = 'n',
					 @term_month varchar(20) = NULL,
					 @term_start DATETIME=NULL,
					 @term_end DATETIME=NULL,
					 @link_desc varchar(1000)=null,
					 @batch_process_id varchar(50)=NULL,	
					 @batch_report_param varchar(1000)=NULL

--EXEC spa_msmt_link_drill_down  'd','2011-12-31', NULL,'f','4', NULL,  NULL  , 2 , NULL  ,  n , 30496, NULL  ,  NULL  , c  ,  n  ,  NULL  , NULL   , NULL

-- declare @discount_option varchar(1), @as_of_date varchar(20), @link_id varchar(100), @settlement_option varchar(1), 
--	@round_value varchar(1), @non_drill_link_id varchar(500), @deal_id varchar(500), @hypothetical varchar(1),
--	@sub_entity_id varchar(200), @strategy_entity_id varchar(500), @book_entity_id varchar(500), @legal_entity varchar(50),
--	@source_deal_header_id varchar(500), @report_type varchar(1), @batch_process_id varchar(50), @batch_report_param varchar(1000),
--	@term_month varchar(20), @all_mtm varchar(1), @term_start DATETIME, @term_end DATETIME
--
-- set @discount_option ='d'
-- set @as_of_date ='2009-09-30'
-- --should be 'linkid '+ '-D' for deal (i..e, '3-D')
-- set @link_id = 944--'483'
-- set @settlement_option ='a'
-- --set @deal_id = 'PD42343, PX404343, PDd053423'
-- set @deal_id = null--'PD04001' --'PD42343'
-- set @report_type = 'c'
-- set @sub_entity_id = '123'
drop table #links_1

--*/
----------------END OF TESTING
--
--If @term_start IS NOT NULL and @term_end IS NULL
--	SET @term_end=@term_start
--If @term_start IS NULL and @term_end IS NOT NULL
--	SET @term_start=@term_end

IF @deal_id = '' OR @deal_id IS NULL
	SET @deal_id = NULL
ELSE
BEGIN
	--set @deal_id = replace(@deal_id, ' ', '')
	set @deal_id = '''' + replace(@deal_id, ',', ''',''') + ''''
END

if @link_id_to is null and @non_drill_link_id is not null
	set @link_id_to=@non_drill_link_id

if @link_id_to is not null and @non_drill_link_id is  null
	set @non_drill_link_id=@link_id_to


--*****************For batch processing********************************        
DECLARE @str_batch_table varchar(max)        
	SET @str_batch_table=''        
	IF @batch_process_id is not null        
	 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)  
 
declare @st varchar(MAX)

declare @is_a_deal int
SET @is_a_deal = 0  --no deal

create table #links_1(link_id varchar(100) COLLATE DATABASE_DEFAULT  )

IF @link_id IS NOT NULL  -- THIS IS CALLED ALWAYS FROM DRILL DOWN IN MEASUREMENT REPORT
BEGIN

If CHARINDEX('-D', @link_id)<> 0
BEGIN
	SET @is_a_deal = 1  --yes deal
	set @link_id = REPLACE ( @link_id , '-D' , '' )
END 

If @is_a_deal = 0
		EXEC ('insert into #links_1
		select cast(link_id as varchar) + ''l'' from 
		fas_link_header where link_id in (' + @link_id + ')')
		else
		EXEC ('insert into #links_1
		select cast(source_deal_header_id as varchar) + ''d'' 
		from source_deal_header where source_deal_header_id in (' + @link_id + ')')
	--select * from #links_1
	
		end 

IF @non_drill_link_id IS NOT NULL or @link_desc is not null
BEGIN
		set @st='insert into #links_1
		select cast(fld.source_deal_header_id as varchar) + ''d'' 
		from fas_link_detail fld inner join fas_link_header flh on flh.link_id=fld.link_id where fld.hedge_or_item = ''h'' and fld.percentage_included <> 0'
		+ case when @non_drill_link_id is not null   then ' and fld.link_id between ' + @non_drill_link_id + ' and '+ @link_id_to else '' end
		+ case when @link_desc is not null then ' and flh.link_description like ''' + @link_desc+'%''' else '' end
		+' union all
		select cast(link_id as varchar) + ''l'' from fas_link_header where 1=1 '
		+ case when @non_drill_link_id is not null   then ' and (link_id between ' + @non_drill_link_id + ' and '+ @link_id_to +' or original_link_id between ' + @non_drill_link_id + ' and '+ @link_id_to + ')' else '' end
		+ case when @link_desc is not null then ' and link_description like ''' + @link_desc+'%''' else '' end
		EXEC spa_print @st
		exec(@st)
						end			


DECLARE @no_links int
select @no_links = count(*) from #links_1
if @no_links IS NULL AND (@non_drill_link_id IS NOT NULL OR @link_id IS NOT NULL)
	set @no_links=1
if @no_links IS NULL 
	set @no_links=0

IF @discount_option IS NULL
	SET @discount_option='d'
IF @round_value IS NULL
	SET @round_value = '2'

IF @source_deal_header_id = ''
	SET @source_deal_header_id = NULL

	set @st='
select		dbo.FNADateFormat(cd.valuation_date) [Valuation Date], sub.entity_name Sub, stra.entity_name Strategy, book.entity_name Book, 
			case when(hedge_or_item = ''h'') then ''Der'' else ''Item'' end [Der/Item], 
            cd.deal_id [Deal Ref ID], 
			dbo.FNATRMWinHyperlink(''a'', 10131010, cd.source_deal_header_id, ABS(cd.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) [Deal ID],
			case when (cd.link_type = ''link'') then  
			dbo.FNATRMWinHyperlink(''a'', 10233700, cd.link_id, ABS(cd.link_id),null,null,null,null,null,null,null,null,null,null,null,0) 
			else cast(cd.link_id as varchar) end [Rel ID], 
			dbo.FNATRMWinHyperlink(''a'', 10233700, cd.dedesignation_link_id, ABS(cd.dedesignation_link_id),null,null,null,null,null,null,null,null,null,null,null,0) [DeDesig Rel ID], 
			case when (link_type=''deal'') then ''deal'' else sdv_lt.code end [Rel Type], 
            isnull(nsc.counterparty_name, sc.counterparty_name) [Counterparty], 
			dbo.FNADateFormat(cd.deal_date) [Deal Date], 
			dbo.FNADateFormat(cd.link_effective_date) [Rel Eff Date], dbo.FNADateFormat(cd.dedesignation_date) [DeDesig Date],
            dbo.FNADateFormat(cd.term_start) [Term], cd.percentage_included [%], 
		case when(sdh.header_buy_sell_flag = ''b'') then 1 else -1 end * cd.deal_volume [Total Volume],
        case when(sdh.header_buy_sell_flag = ''b'') then 1 else -1 end * cd.percentage_included * cd.deal_volume [Volume used], su.uom_name [UOM], 
            spcd.curve_name [Index], round(cd.discount_factor, 4) [DF], cd.fixed_price [Deal Price], ISNULL(spc.curve_value, 0) [Market Price], 
			ISNULL(spce.curve_value, 0) [Inception Price], scu.currency_name [Currency], 
			round(case when ('''+@discount_option+'''=''d'') then dis_pnl else und_pnl end, '+@round_value+') [Cum FV],
			round(case when ('''+@discount_option+'''=''d'') then final_dis_instrinsic_pnl else final_und_instrinsic_pnl end, '+@round_value+') [Cum Int FV],
			case when (cd.link_type = ''deal'') then 0 else 
				(round(case when ('''+@discount_option+'''=''d'') then final_dis_pnl else final_und_pnl end, 2)  
			- round(case when ('''+@discount_option+'''=''d'') then final_dis_pnl_remaining else final_und_pnl_remaining end, 2)) end [Incpt FV],
			round(case when ('''+@discount_option+'''=''d'') then final_dis_instrinsic_pnl else final_und_instrinsic_pnl end, '+@round_value+') * percentage_included -
			round(case when ('''+@discount_option+'''=''d'') then final_dis_pnl_intrinsic_remaining else final_und_pnl_intrinsic_remaining end, '+@round_value+') [Incpt Int FV],
            round(case when ('''+@discount_option+'''=''d'') then final_dis_pnl_remaining else final_und_pnl_remaining end, '+@round_value+') [Cum Hedge FV], 		
            round(cfv_ratio, 2) [Hedge AOCI Ratio], round(dol_offset, 2) [Dollar Offset Ratio],
     		case when(cd.link_type=''deal'' OR cd.link_type_value_id = 452 OR cd.term_start <= cd.as_of_date) then ''N/A'' 
				 when (cd.assessment_test > 0) then testsdv.code + '' (Passed)'' else testsdv.code + '' (Failed)'' end Test,
            round(case when ('''+@discount_option+'''=''d'') then ar.d_aoci else ar.u_aoci end, '+@round_value+') AOCI,
			round(case when (cd.term_start > cd.as_of_date) then
				case when ('''+@discount_option+'''=''d'') then d_pnl_ineffectiveness + d_pnl_mtm + final_dis_extrinsic_pnl else u_pnl_ineffectiveness + u_pnl_mtm + final_und_extrinsic_pnl end 
			else 0 end, '+@round_value+') PNL,
			round(case when ('''+@discount_option+'''=''d'') then  isnull(ar.d_aoci_released, 0) else isnull(ar.aoci_released, 0) end, '+@round_value+') [AOCI Released],
			round(case when (cd.term_start <= cd.as_of_date) then
				round(case when ('''+@discount_option+'''=''d'') then  isnull(ar.d_aoci_released, 0) else isnull(ar.aoci_released, 0) end, '+@round_value+') + 
				case when ('''+@discount_option+'''=''d'') then d_pnl_ineffectiveness + d_pnl_mtm + final_dis_extrinsic_pnl else u_pnl_ineffectiveness + u_pnl_mtm + final_und_extrinsic_pnl end 
			else 0 end, '+@round_value+') [PNL Settled]  ' +

			@str_batch_table

+   
'
from  ' + dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' cd inner join
portfolio_hierarchy sub on sub.entity_id = cd.fas_subsidiary_id inner join
portfolio_hierarchy stra on stra.entity_id = cd.fas_strategy_id inner join
portfolio_hierarchy book on book.entity_id = cd.fas_book_id inner join 
fas_strategy fs ON fs.fas_strategy_id = cd.fas_strategy_id inner join
fas_books fb ON fb.fas_book_id = cd.fas_book_id inner join ' +
case when (@no_links = 0) then '' else 
'
#links_1 l ON l.link_id = cast(cd.link_id as varchar) + substring(link_type,1,1) inner join
'
						end
+ '
source_counterparty sc on sc.source_counterparty_id = cd.source_counterparty_id left outer join
source_counterparty nsc on nsc.source_counterparty_id = sc.netting_parent_counterparty_id left outer join
static_data_value sdv_et on sdv_et.value_id = sc.type_of_entity left outer join
source_uom su on su.source_uom_id = cd.deal_volume_uom_id left outer join
source_deal_type sdt on sdt.source_deal_type_id = cd.deal_type left outer join
source_deal_type sdts on sdt.source_deal_type_id = cd.deal_sub_type left outer join
source_price_curve_def spcd on spcd.source_curve_def_id = cd.curve_id left outer join 
source_currency scu on scu.source_currency_id = cd.pnl_currency_id left outer join
fas_eff_hedge_rel_type fehrt on fehrt.eff_test_profile_id = cd.use_eff_test_profile_id left outer join
static_data_value testsdv ON testsdv.value_id= fehrt.on_eff_test_approach_value_id left outer join
static_data_value sdv_lt on sdv_lt.value_id = cd.link_type_value_id left outer join
static_data_value sdv_ht on sdv_ht.value_id = cd.hedge_type_value_id left outer join
(select as_of_date, link_id, source_deal_header_id, h_term, 
sum(case when (i_term <= as_of_date) then case when (rollout_per_type in (520, 522)) then isnull(aoci_allocation_vol, 0) else isnull(aoci_allocation_pnl, 0) end else 0 end) aoci_released,
sum(case when (i_term <= as_of_date) then case when (rollout_per_type in (520, 522)) then isnull(d_aoci_allocation_vol, 0) else isnull(d_aoci_allocation_pnl, 0) end else 0 end) d_aoci_released,
sum(case when (i_term > as_of_date) then case when (rollout_per_type in (520, 522)) then isnull(aoci_allocation_vol, 0) else isnull(aoci_allocation_pnl, 0) end else 0 end) u_aoci,
sum(case when (i_term > as_of_date) then case when (rollout_per_type in (520, 522)) then isnull(d_aoci_allocation_vol, 0) else isnull(d_aoci_allocation_pnl, 0) end else 0 end) d_aoci
from ' + dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_aoci_release') + ' car
group by as_of_date, link_id, source_deal_header_id, h_term) ar ON ar.as_of_date = cd.as_of_date and
ar.link_id = cd.link_id and cd.link_type = ''link'' and ar.source_deal_header_id = cd.source_deal_header_id and
ar.h_term = cd.term_start left outer join
(select source_curve_def_id, maturity_date term_start, max(as_of_date) max_as_of_date FROM source_price_curve
 where curve_source_value_id = 4500 and as_of_date <= ''' + @as_of_date + ''' and assessment_curve_type_value_id = 77
 group by source_curve_def_id, maturity_date) spcedate ON spcedate.source_curve_def_id = cd.curve_id AND spcedate.term_start = cd.term_start left outer join
source_price_curve spc ON spc.as_of_date = spcedate.max_as_of_date and spc.curve_source_value_id = 4500 and
      spc.assessment_curve_type_value_id = 77 and spc.maturity_date = spcedate.term_start and
      spc.source_curve_def_id = spcedate.source_curve_def_id left outer join
source_price_curve spce ON spce.as_of_date = cd.link_effective_date and spce.curve_source_value_id = 4500 and
      spce.assessment_curve_type_value_id = 77 and spce.maturity_date = cd.term_start and spce.source_curve_def_id = cd.curve_id
left join dbo.source_deal_header sdh on cd.source_deal_header_id=sdh.source_deal_header_id
where cd.calc_type = ''m'' AND cd.as_of_date = ''' + @as_of_date + '''
 AND dbo.FNAContractMonthFormat(cd.term_start) ='+CASE WHEN @term_month IS NULL THEN 'dbo.FNAContractMonthFormat(cd.term_start)' ELSE +''''+@term_month+'''' END 
+ CASE	WHEN (isnull(@settlement_option, 'a') = 'a') THEN '' 
		WHEN (@settlement_option = 's') THEN ' AND cd.term_start < ''' + @as_of_date + ''''
		WHEN (@settlement_option = 'c') THEN ' AND cd.term_start >= ''' + @as_of_date + ''''
		ELSE ' AND cd.term_start > ''' + @as_of_date + ''''
  END 
+ CASE WHEN (@sub_entity_id IS NULL) THEN '' ELSE ' AND cd.fas_subsidiary_id IN ('+ @sub_entity_id + ')' END 
+ CASE WHEN (@strategy_entity_id IS NULL) THEN '' ELSE ' AND cd.fas_strategy_id IN ('+ @strategy_entity_id + ')' END 
+ CASE WHEN (@book_entity_id IS NULL) THEN '' ELSE ' AND cd.fas_book_id IN ('+ @book_entity_id + ')' END 
+ CASE WHEN (@no_links = 0 and @non_drill_link_id is not null) THEN ' AND cd.link_id IN ('+ @non_drill_link_id + ')' ELSE '' END 
+ CASE WHEN (@legal_entity IS NULL) THEN '' ELSE ' AND fb.legal_entity IN ('+ @legal_entity + ')' END 
+ CASE WHEN (isnull(@hypothetical, 'a') = 'a') THEN '' 
	   WHEN (@hypothetical = 'n') THEN ' AND (fb.no_link IS NULL OR fb.no_link = ''n'') '
	   ELSE ' AND (fb.no_link = ''y'') ' 
  END 
+ CASE WHEN (@source_deal_header_id IS NULL) THEN '' ELSE ' AND cd.source_deal_header_id IN ('+ @source_deal_header_id + ')' END 
+ CASE WHEN (@deal_id IS NULL) THEN '' ELSE ' AND cd.deal_id IN ('+ @deal_id + ')' END 
+ CASE WHEN (isnull(@all_mtm, 'n') = 'y') THEN ' AND cd.link_type = ''deal'' AND cd.hedge_or_item = ''h''' ELSE '' END
+ CASE WHEN (isnull(@report_type, 'a') = 'a') THEN '' 
	   WHEN (@report_type ='c') THEN ' AND fs.hedge_type_value_id = 150 '
	   WHEN (@report_type ='f') THEN ' AND fs.hedge_type_value_id = 151 '
	   ELSE ' AND fs.hedge_type_value_id = 152 ' END
+
+ CASE WHEN (@term_start IS NOT NULL) THEN ' AND convert(varchar(10),cd.term_start,120) >='''+convert(varchar(10),@term_start,120) +'''' ELSE '' END
+ CASE WHEN (@term_end IS NOT NULL) THEN ' AND convert(varchar(10),cd.term_end,120)<='''+convert(varchar(10),@term_end,120) +'''' ELSE '' END+
+ CASE WHEN @link_id IS NOT NULL THEN 'AND cd.link_id = ' + CAST(@link_id AS VARCHAR) ELSE '' END + 
' ORDER BY sub.entity_name, stra.entity_name, book.entity_name, cd.hedge_or_item, cd.source_deal_header_id, cd.term_start
'
EXEC spa_print @st
	exec(@st)



