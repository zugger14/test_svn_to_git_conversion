IF OBJECT_ID(N'spa_create_detailed_aoci_schedule', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_detailed_aoci_schedule]
 GO 


--select dbo.FNAContractMonthFormat('2004-12-31')
-- exec spa_create_detailed_aoci_schedule '2004-12-31', null,null,'d',30,208,223,'d'

--This procedure provides AOCI release schedule. 

create PROC [dbo].[spa_create_detailed_aoci_schedule] @as_of_date varchar(20), @link_id varchar(20) = NULL, @i_term varchar(20) = NULL, 
				@discount_option varchar(1) = 'u', 
				@sub_entity_id varchar(MAX) = NULL, 
				@strategy_entity_id varchar(MAX) = NULL, 
				@book_entity_id varchar(MAX) = NULL,
				@summary_option varchar(1) = 'd',
				@round_value char(1)='0',
				@term_start DATETIME=NULL,
				@term_end DATETIME=NULL,
				@batch_process_id VARCHAR(50)=NULL,
				@batch_report_param VARCHAR(1000)=NULL
AS

declare @st varchar(8000)
DECLARE @str_batch_table varchar(max)       

If @term_start IS NOT NULL and @term_end IS NULL
	SET @term_end=@term_start
If @term_start IS NULL and @term_end IS NOT NULL
	SET @term_start=@term_end


 
SET @str_batch_table = ''        
IF @batch_process_id IS NOT NULL        
	SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)

if @summary_option = 'd'
begin
set @st='SELECT	dbo.FNADateFormat(car.as_of_date) [As Of Date], 
		car.link_id [Rel ID], 
		dbo.FNAContractMonthFormat(car.i_term) [Delivery Month], 
		car.source_deal_header_id [Der Deal ID],  
		sdh.deal_id [Source Deal ID],
		dbo.FNAContractMonthFormat(car.h_term) [Der Contract Month],  
		car.strip_months [Der Strip Months], 
		car.lagging_months [Der Lagging Months], 
		car.strip_item_months [Item Strip Months], 
		case when (car.mismatch_tenor_value_id = 250) then ''Perfect Tenor Match'' else sdv.code end [Release Type],
		round(case when (rollout_per_type IN (521, 524)) then car.per_pnl else car.per_vol end * 100, '+ @round_value +') [AOCI Release %],
		case when ('''+@discount_option+''' = ''u'') then u_aoci else d_aoci end [AOCI],
		case when (rollout_per_type IN (521, 524)) then 
			case when ('''+@discount_option+''' = ''u'') then car.aoci_allocation_pnl else car.d_aoci_allocation_pnl end 
		else case when ('''+@discount_option+''' = ''u'') then car.aoci_allocation_vol else car.d_aoci_allocation_vol end 
		end [AOCI Release] ' + @str_batch_table + '
FROM    '+dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_aoci_release')+'  car INNER JOIN
		source_deal_header sdh ON sdh.source_deal_header_id = car.source_deal_header_id INNER JOIN
(select as_of_date, link_id, max(sub_entity_id) sub_entity_id, max(strategy_entity_id) strategy_entity_id, 
		max(book_entity_id) book_entity_id 
FROM    '+dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values') +' report_measurement_values
WHERE   link_id = '+case when @link_id is null then 'link_id' else @link_id end+' AND as_of_date ='''+ @as_of_date +''' AND link_deal_flag = ''l''
'
+ case when (@sub_entity_id is null) then '' else ' and sub_entity_id in (' + @sub_entity_id + ')' end
+ case when (@strategy_entity_id is null) then '' else ' and strategy_entity_id in (' + @strategy_entity_id + ')' end
+ case when (@book_entity_id is null) then '' else ' and book_entity_id in (' + @book_entity_id + ')' end
+ ' 
GROUP BY as_of_date, link_id
) rmv ON rmv.as_of_date = car.as_of_date  AND rmv.link_id = car.link_id 
--WhatIf Changes
INNER JOIN fas_books fb ON fb.fas_book_id = RMV.book_entity_id
LEFT OUTER JOIN
static_data_value sdv ON sdv.value_id = car.rollout_per_type
WHERE   car.link_id ='+case when @link_id is null then 'car.link_id' else @link_id end+'  AND car.as_of_date = '''+ @as_of_date +''' and car.i_term = '+case when @i_term is null then  'i_term' else ''''+cast(@i_term as varchar)+'''' end +'
--WhatIf Changes
AND (fb.no_link IS NULL OR fb.no_link = ''n'') '
+ CASE WHEN @term_start IS NOT NULL THEN ' AND convert(varchar(10),car.i_term,120) >='''+convert(varchar(10),@term_start,120) +'''' ELSE '' END
+ CASE WHEN @term_start IS NOT NULL THEN ' AND convert(varchar(10),car.i_term,120) <='''+convert(varchar(10),@term_end,120) +'''' ELSE '' END
--+' AND  car.i_term > ''' +  cast(@as_of_date as varchar) + ''''
+'order by car.link_id, car.i_term, car.source_deal_header_id, car.h_term'
EXEC spa_print @st
exec(@st)
end
--select * from calcprocess_aoci_release











