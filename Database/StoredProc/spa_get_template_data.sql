IF OBJECT_ID('[dbo].[spa_get_template_data]','p') IS NOT NULL 
	DROP PROC [dbo].[spa_get_template_data]
GO 

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE PROCEDURE [dbo].[spa_get_template_data]
	@link_id INT = NULL,
	@eff_test_id INT = NULL,
	@doc_type INT = NULL,
	@flag CHAR = NULL
AS
	

-------Test

--declare @link_id int
--declare @eff_test_id int
--
--set @link_id = 80
--drop table #temp
--------End of test

--spa_get_template_data 13

declare @st_from varchar(max)
declare @st_where varchar(max)
declare @st_group_by varchar(max)
declare @st_sql varchar(max)
declare @st_sql1 varchar(max)
declare @reg_series varchar(max)
declare @result_id int
declare @link_effective_date DATETIME

IF @doc_type = '1'
BEGIN
	SELECT contract_name AS [ContractName],
		   [name] AS ContactName,	
		   subledger_code AS [ReferenceNumber],
		   cg.company AS [Company],
		   cg.[address] AS [Address],
		   cg.address2 AS [Address2]
	INTO #word_document_replace
	FROM   contract_group cg
	WHERE cg.contract_id = @link_id 
	
	SELECT 'ContactName' Search, CAST(ContactName AS VARCHAR) ReplaceBy FROM   #word_document_replace 
	UNION
	SELECT 'Company' Search, CAST(Company AS VARCHAR) ReplaceBy FROM   #word_document_replace
	UNION
	SELECT 'Address1' Search, CAST([Address] AS VARCHAR) ReplaceBy FROM   #word_document_replace
	UNION
	SELECT 'Address2' Search, CAST(Address2 AS VARCHAR) ReplaceBy FROM   #word_document_replace
	UNION
	SELECT 'ReferenceNumber' Search, CAST(ReferenceNumber AS VARCHAR) ReplaceBy FROM   #word_document_replace
	UNION
	SELECT 'Date' Search, CAST(GETDATE() AS VARCHAR(13)) ReplaceBy FROM   #word_document_replace
	
RETURN
END
ELSE
--SELECT * FROM dbo.source_deal_detail WHERE source_deal_header_id in (28,145)
--SELECT * FROM dbo.fas_link_detail WHERE link_id=13
select @link_effective_date = link_effective_date from fas_link_header where link_id = @link_id

select @result_id = coalesce(i.result_id, o.result_id) 
from 
(select link_id, max(eff_test_result_id) result_id from fas_eff_ass_test_results 
where link_id = @link_id and calc_level = 2 and initial_ongoing = 'i' and as_of_date >= @link_effective_date
group by link_id) i full outer join
(select link_id, max(eff_test_result_id) result_id from fas_eff_ass_test_results 
where link_id = @link_id and calc_level = 2 and initial_ongoing = 'o' and as_of_date >= @link_effective_date
group by link_id) o on o.link_id = i.link_id

if @flag = 'a'
BEGIN
	SELECT dbo.FNADateFormat(price_date) [Date], x_series [Hedge Price], y_series [Item Price] FROM fas_eff_ass_test_results_process_detail d 
	WHERE d.eff_test_result_id = @result_id
	ORDER BY price_date
	RETURN
END

set @reg_series = '<table><td width=150 style="font-size:12px"><b>Date</b></td><td width=150 style="font-size:12px"><b>Hedge Price</b></td><td width=150 style="font-size:12px"><b>Item Price</b></td>'
select @reg_series = @reg_series + '<tr><td width=150 style="font-size:12px">' + dbo.FNADateFormat(price_date) + '</td>' +
					'<td width=150 style="font-size:12px">' + cast(x_series as varchar) + '</td>' +
					'<td width=150 style="font-size:12px">' + cast(y_series as varchar) + '</td></tr>' 
from fas_eff_ass_test_results_process_detail d 
where d.eff_test_result_id = @result_id
order by price_date
set @reg_series = @reg_series + '</table>'



select	dbo.FNARemoveTrailingZeroes(round(sum(sddh.deal_volume/10000), 3)) ng_future_contract,
		dbo.FNARemoveTrailingZeroes(round(max(sddi.deal_volume), 3)) item_volume,
		max(case when(sddi.buy_sell_flag = 'b') then 'purchase' else 'sale' end) item_buy_sell,
		max(case when(sddh.buy_sell_flag = 'b') then 'long' else 'short' end) hedge_long_short,
		max(case when(sddi.buy_sell_flag = 'b') then 'purchased' else 'sold' end) item_bought_sold,
		max(convert(varchar(11) ,cast(flh.link_effective_date as datetime) ,1)) hedge_designation_date,
		right(convert(varchar(11) ,min(cast(sddi.term_start as datetime)) ,13),8) item_term_start,
		right(convert(varchar(11) ,max(cast(sddi.term_end as datetime)) ,13),8) item_term_end,
		right(convert(varchar(11) ,min(cast(sddh.term_start as datetime)) ,13),8) hedge_term_start,
		right(convert(varchar(11) ,max(cast(sddh.term_end as datetime)) ,13),8) hedge_term_end,
		max(scdi.curve_name) item_index,
		max(smli.Location_Name) item_location,

		dbo.FNARemoveTrailingZeroes(round(max(sddh.fixed_price), 3)) hedge_price,
		max(smlh.Location_Name) hedge_location,
		--max(scdh.curve_name) hedge_location,
		max(scdh.curve_name) hedge_index,

		max(corr) correlation,
		max(slope) slope,
		max(rsq) rsq,
		@reg_series reg_series,
	max(su.uom_name) deal_volume_uom_id,
		max(sdhh.deal_id) hedge_deal_ref_id
 
into #temp	
from 
fas_link_detail fldh INNER JOIN
source_deal_header sdhh ON fldh.hedge_or_item = 'h' 
	and fldh.source_deal_header_id = sdhh.source_deal_header_id 
INNER JOIN
fas_link_header flh on flh.link_id = fldh.link_id
INNER JOIN
source_deal_detail sddh ON sddh.source_deal_header_id = sdhh.source_deal_header_id 
INNER JOIN
fas_link_detail fldi ON fldi.link_id = fldh.link_id left JOIN
source_deal_header sdhi ON fldi.hedge_or_item = 'i' 
	and fldi.source_deal_header_id = sdhi.source_deal_header_id left JOIN
source_deal_detail sddi ON sddi.source_deal_header_id = sdhi.source_deal_header_id 
left JOIN
source_price_curve_def scdh on scdh.source_curve_def_id = sddh.curve_id 
left JOIN
source_price_curve_def scdi on scdi.source_curve_def_id = sddi.curve_id 
LEFT OUTER JOIN source_uom su on su.source_uom_id =sddh.deal_volume_uom_id 
LEFT join
dbo.source_minor_location smlh on smlh.source_minor_location_id= sddh.location_id
LEFT join
dbo.source_minor_location smli on smli.source_minor_location_id= sddi.location_id

LEFT OUTER JOIN

(select @link_id link_id, regression_corr corr, regression_slope slope, regression_rsq rsq 
from fas_eff_ass_test_results_process_header where eff_test_result_id = @result_id) reg on reg.link_id = fldh.link_id

where fldh.link_id = @link_id

if @link_id IS NULL
BEGIN
	SELECT null Search, null ReplaceBy
	RETURN
END

set @st_from=
case when @link_id<0
then
		' from fas_eff_hedge_rel_type fehrt inner join fas_strategy fs on fehrt.eff_test_profile_id=fs.no_links_fas_eff_test_profile_id
		INNER JOIN portfolio_hierarchy fb ON fb.parent_entity_id=fs.fas_strategy_id
		inner join	source_system_book_map ssbm ON fb.entity_id = ssbm.fas_book_id
		inner join source_deal_header sdh on sdh.source_system_book_id1=ssbm.source_system_book_id1 
		and sdh.source_system_book_id2 = ssbm.source_system_book_id2 and sdh.source_system_book_id3 = ssbm.source_system_book_id3 
		and sdh.source_system_book_id4 = ssbm.source_system_book_id4 
		inner join	source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id  
		inner join	source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
		left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id
		left join source_commodity sc on spcd.commodity_id=sc.source_commodity_id
	'
else
	' from fas_eff_hedge_rel_type fehrt inner join fas_link_header flh on fehrt.eff_test_profile_id=flh.eff_test_profile_id
	inner join fas_link_detail fld on flh.link_id=fld.link_id
	inner join	source_deal_detail sdd on sdd.source_deal_header_id = fld.source_deal_header_id  
	inner join	source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
	inner join source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id
	left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id
	left join source_commodity sc on spcd.commodity_id=sc.source_commodity_id'
+
	'
	left join
	(select fld.source_deal_header_id, max(su.uom_name) uom_name, max(sc.commodity_name) commodity_name
	from fas_link_detail fld 
	inner join source_deal_detail sdd on sdd.source_deal_header_id = fld.source_deal_header_id
	inner join	source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
	left join source_price_curve_def spcd on sdd.curve_id=spcd.source_curve_def_id
	left join source_commodity sc on spcd.commodity_id=sc.source_commodity_id
	where hedge_or_item = ''i'' and fld.link_id = ' + cast(@link_id as varchar) + ' and sdd.leg = 2
	group by fld.source_deal_header_id) maxcom ON
		maxcom.source_deal_header_id = fld.source_deal_header_id
'

end
set @st_where=
case when @link_id<0 
then
	' WHERE (ssbm.fas_deal_type_value_id=401) and sdd.leg=1 and (fb.entity_id='+ cast(abs(@link_id) as varchar)	+ ' or fb.parent_entity_id='+ cast(abs(@link_id) as varchar)	+ ')'
else
	' WHERE (fld.hedge_or_item=''i'') and sdd.leg=1 and (fld.link_id='+ cast(@link_id as varchar)+')'
end


set @st_group_by=' group by fehrt.eff_test_profile_id,fehrt.update_ts,'+
case when @link_id<0
then
	'fehrt.effective_start_date'
else
	'flh.link_effective_date'
END

IF OBJECT_ID('tempdb..##pivot_table') IS NOT NULL
    DROP TABLE ##pivot_table

set @st_sql='Select * into ##pivot_table from (select ''*LinkID*'' Search,cast(max('+cast(abs(@link_id) as varchar)+') as varchar) ReplaceBy'
 + @st_from +@st_where+@st_group_by + ' union all ' +
'select ''*Hedge_Effective_Date*'' Search,'+case when @link_id<0 then ' dbo.fnadateformat(fehrt.effective_start_date)' else ' dbo.fnadateformat(flh.link_effective_date) ' end +' ReplaceBy'
 + @st_from +@st_where+@st_group_by

set @st_sql1=
'select ''*Documentation_Saved_Date*'' Search, dbo.fnadateformat(fehrt.update_ts) ReplaceBy'
 + @st_from +@st_where+@st_group_by + ' union all ' +
'select ''*Item_Tenor*'' Search,''From: ''+cast(datename(mm,min(sdd.term_start)) as varchar(3))+'' ''+cast(datename(yyyy,min(sdd.term_start)) as varchar)
 + '' To: ''+cast(datename(mm,max(sdd.term_end)) as varchar(3))+'' ''+cast(datename(yyyy,max(sdd.term_end)) as varchar) ReplaceBy'
 + @st_from +@st_where+@st_group_by + ' union all ' +
'select ''*Total_Forecasted_Transaction*'' Search,'' ''+cast(sum(cast(sdd.deal_volume'+case when @link_id<0 then ')' else '*fld.percentage_included as money))' end +' as varchar)
+ '' ''+ isnull(max(isnull(maxcom.uom_name, su.uom_name)), '''') + '' ''+isnull(max(isnull(maxcom.commodity_name, sc.commodity_name)),'''') ReplaceBy'
 + @st_from +@st_where+@st_group_by + ' union all ' +
'select ''*ItemVolume*'' Search,'' ''+cast(sum(cast(sdd.deal_volume'+case when @link_id<0 then ')' else '*fld.percentage_included as money))' end +' as varchar) ReplaceBy'
 + @st_from +@st_where+@st_group_by 

+
' UNION select ''*ng_future_contract*'' Search, cast(ng_future_contract as varchar) ReplaceBy from #temp 
UNION
select ''*item_volume*'' Search, cast(item_volume as varchar) ReplaceBy from  #temp 
UNION
select ''*item_buy_sell*'' Search, cast(item_buy_sell as varchar) ReplaceBy from  #temp 
UNION
select ''*hedge_long_short*'' Search, cast(hedge_long_short as varchar) ReplaceBy from  #temp 
UNION
select ''*hedge_designation_date*'' Search, cast(hedge_designation_date as varchar) ReplaceBy from  #temp 
UNION
select ''*item_term_start*'' Search, cast(item_term_start as varchar) ReplaceBy from  #temp 
UNION
select ''*item_term_end*'' Search, cast(item_term_end as varchar) ReplaceBy from  #temp 
UNION
select ''*item_location*'' Search, cast(item_location as varchar) ReplaceBy from  #temp 
UNION
select ''*hedge_price*'' Search, cast(hedge_price as varchar) ReplaceBy from  #temp 
UNION
select ''*item_bought_sold*'' Search, cast(item_bought_sold as varchar) ReplaceBy from  #temp
UNION
select ''*hedge_location*'' Search, cast(hedge_location as varchar) ReplaceBy from  #temp
UNION
select ''*correlation*'' Search, cast(correlation as varchar) ReplaceBy from  #temp
UNION
select ''*slope*'' Search, cast(slope as varchar) ReplaceBy from  #temp
UNION
select ''*rsq*'' Search, cast(rsq as varchar) ReplaceBy from  #temp
UNION
select ''*hedge_UOM*'' Search, cast(deal_volume_uom_id as varchar) ReplaceBy from  #temp
UNION
select ''*hedge_deal_ref_id*'' Search, cast(hedge_deal_ref_id as varchar) ReplaceBy from  #temp
'
+
'
UNION
select ''*reg_series*'' Search, reg_series ReplaceBy from  #temp
UNION
select ''*hedge_term_start*'' Search, cast(hedge_term_start as varchar) ReplaceBy from  #temp 
UNION
select ''*hedge_term_end*'' Search, cast(hedge_term_end as varchar) ReplaceBy from  #temp 
UNION
select ''*hedge_index*'' Search, hedge_index ReplaceBy from  #temp 
UNION
select ''*item_index*'' Search, item_index  ReplaceBy from  #temp )a

'
exec spa_print @st_sql
exec spa_print ' union all ', @st_sql1
EXEC (@st_sql+' union all ' + @st_sql1)

DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)
 
--Get distinct values of the PIVOT Column 
SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(search)
FROM (SELECT DISTINCT search FROM ##pivot_table) AS Courses
 
--Prepare the PIVOT query using the dynamic 
SET @DynamicPivotQuery = 
  N'SELECT ' + @ColumnName + '
    FROM ##pivot_table
    PIVOT(min(replaceby) 
          FOR search IN (' + @ColumnName + ')) AS PVTTable'
--Execute the Dynamic Pivot Query
EXEC sp_executesql @DynamicPivotQuery

IF OBJECT_ID('tempdb..##pivot_table') IS NOT NULL
    DROP TABLE ##pivot_table

