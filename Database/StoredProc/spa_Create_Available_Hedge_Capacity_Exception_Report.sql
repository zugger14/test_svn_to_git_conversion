
IF OBJECT_ID(N'dbo.spa_Create_Available_Hedge_Capacity_Exception_Report', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_Create_Available_Hedge_Capacity_Exception_Report
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
--exec spa_Create_Available_Hedge_Capacity_Exception_Report '2011-10-31','1', null, null,'c','l',null,'a'

-- @summary option: 's' summary by semi-annual, 'q' summary by quarter, 'a' summary by annual, 'm' summary by month, 'd' detail
-- @settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions



--exec spa_Create_Available_Hedge_Capacity_Exception_Report '2004-09-30', '1', '79', '89', 'c', 'q', '3', 'e', '402', 'f', 'b'
CREATE PROC [dbo].[spa_Create_Available_Hedge_Capacity_Exception_Report]
	@as_of_date varchar(50), 
	@subsidiary_id varchar(MAX), 
	@strategy_id varchar(MAX) = NULL, 
	@book_id varchar(MAX) = NULL, 
	@report_type char(1), 
	@summary_option char(1),
	@convert_unit_id int = NULL,
	@exception_flag char(1),
	@asset_type_id int = 402,
	@settlement_option char(1) = 'f',
	@include_gen_tranactions char(1) = 'b',
	@forecated_tran char(1) = 'n'--@forecated_tran=y for hypo (gen_deal_header_id) and n for perfect hedge(source_deal_header_id)
	,@limit_bucketing varchar(3)='UK',
	@round_value CHAR(1) = 0,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

 AS

/*
 
 SET nocount off	
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
	

declare
	@as_of_date varchar(50)='2018-11-30', 
	@subsidiary_id varchar(MAX)=1308, 
	@strategy_id varchar(MAX) = 2658, 
	@book_id varchar(MAX) = 2666, 
	@report_type char(1)='c', 
	@summary_option char(1)='m',
	@convert_unit_id int = 1159,
	@exception_flag char(1)='e',
	@asset_type_id int = 402,
	@settlement_option char(1) = 'f',
	@include_gen_tranactions char(1) = 'b',
	@forecated_tran char(1) = 'n'--@forecated_tran=y for hypo (gen_deal_header_id) and n for perfect hedge(source_deal_header_id)
	,@limit_bucketing varchar(3)='UK',
	@round_value CHAR(1) = 0,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL

--exec spa_Create_Available_Hedge_Capacity_Exception_Report_new '2012-11-19', '4', NULL, NULL, 'c', 'l', null, 'a', '402', 'f', 'b'
--'2013-01-18', '87', NULL, NULL, 'c', 't', null, 'a', '402', 'f', 'b'
--exec spa_Create_Available_Hedge_Capacity_Exception_Report '2013-03-12', '199,198,197', NULL, NULL, 'c', 't', null, 'a', '402', 'f', 'b'
drop table #tempItems
drop table #tempAsset
drop table #tmp_s
drop table #tmp_d
drop table #temp_per_used


--*/


SET NOCOUNT ON

--to id = 3 mmbtu

--uncomment these to test locally
-- declare @as_of_date varchar(50)
-- declare 	@subsidiary_id varchar(100)
-- declare 	@strategy_id varchar(100)
-- declare 	@book_id varchar(100)
-- declare 	@report_type char(1)
-- declare 	@summary_option char(1)
-- declare 	@convert_unit_id int
-- declare 	@exception_flag char(1)
-- declare 	@asset_type_id int
-- declare 	@settlement_option char(1)
-- declare 	@include_gen_tranactions char(1)
-- set @as_of_date = '2011-10-31'
-- set @subsidiary_id = '1'
-- set @strategy_id = null
-- set @book_id = null
-- set @report_type = 'c'
-- set @summary_option = 'l'
-- set @convert_unit_id = 14
-- set @exception_flag = 'a'
-- set @asset_type_id = 402
-- SET @settlement_option = 'f'
-- --n means dont include, a means approved only, u means unapproved, b means both
-- SET @include_gen_tranactions = 'b'
---- -- -- 
-- drop table #tempItems
-- drop table #tempAsset

-- -- select dbo.FNAGetContractMonth(contract_expiration_date), sum(NetItemVol) from #tempItems where IndexName = 'CNG' group by contract_expiration_date order by contract_expiration_date
-- -- select dbo.FNAGetContractMonth(contract_expiration_date), sum(NetAssetVol) from #tempAsset where IndexName = 'CNG' group by contract_expiration_date order by contract_expiration_date
-- -- select * from #tempAsset

SET @as_of_date = dbo.FNAClientToSqlDate(@as_of_date)
--*******************************************************
-- this report works only for Summary Level Data
--******************************************************
/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
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


If @include_gen_tranactions IS NULL
	SET @include_gen_tranactions = 'b'

Declare @Sql_Select varchar(8000)
Declare @Sql_SelectS varchar(8000)
Declare @Sql_SelectD varchar(8000)
Declare @term_where_clause varchar(1000)
declare @summary_option_orginal varchar(1)
Declare @Sql_Where varchar(8000)
declare @report_identifier int,@tenor_name varchar(100)

set @tenor_name='Tenor Bucket ' +isnull(@limit_bucketing,'UK')

SET @sql_Where = ''

set @summary_option_orginal=@summary_option
if @summary_option_orginal='l'
begin 
	set @summary_option='s'
end

If @settlement_option = 'f'
begin
	set @term_where_clause = ' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
end
Else If @settlement_option = 'c'
	set @term_where_clause = ' AND sdd.term_start >=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as varchar) + '/1/' + cast(year(@as_of_date) as varchar) + ''' , 102)'
Else If @settlement_option = 's'
	set @term_where_clause = ' AND sdd.term_start <=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as varchar) + '/1/' + cast(year(@as_of_date) as varchar) + ''' , 102)'
Else
	set @term_where_clause = ''

if @report_type = 'c'
	SET @report_identifier = 150
else if @report_type = 'f'
	SET @report_identifier = 151
 
--drop table #tempItems


declare @link_deal_term_used_per varchar(200),@process_id varchar(150)

select @process_id=dbo.fnagetnewid(),@user_login_id =dbo.FNADBUser()

SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

--SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)


if OBJECT_ID(@link_deal_term_used_per) is not null
	exec('drop table '+@link_deal_term_used_per)
	
exec dbo.spa_get_link_deal_term_used_per @as_of_date =@as_of_date,@link_ids=null,@header_deal_id =null,@term_start=null
	,@no_include_link_id =NULL,@output_type =1	,@include_gen_tranactions  = @include_gen_tranactions,@process_table=@link_deal_term_used_per

CREATE TABLE #temp_per_used (source_deal_header_id int ,used_per VARCHAR(MAX) COLLATE DATABASE_DEFAULT  );	
SET @sql_Select = 'INSERT INTO #temp_per_used (source_deal_header_id  ,used_per )	
SELECT source_deal_header_id, AVG(percentage_used) percentage_used from
 (
	SELECT source_deal_header_id,	term_start, sum(isnull(percentage_used ,1)) percentage_used from ' +@link_deal_term_used_per + ' GROUP BY source_deal_header_id,term_start
) p GROUP BY source_deal_header_id'

exec spa_print @sql_Select

			
exec(@sql_Select)			

CREATE TABLE [dbo].[#tempItems] (
	[fas_book_id] [int] NOT NULL ,
	[deal_id] [varchar] (50)   NOT NULL ,
	[contract_expiration_date] datetime,
	[NetItemVol] [float] NULL ,
	[deal_volume_frequency] [varchar] (7)   NOT NULL ,
	[IndexName] [varchar] (100)   NOT NULL ,
	[sui] [int] NOT NULL,
	source_deal_header_id int ,curve_id int
) ON [PRIMARY]

--Get all the Items first
SET @sql_Where = ''
SET @sql_Select = '
	INSERT INTO #tempItems
	SELECT     flh.fas_book_id, sdh.deal_id, 
			dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
				CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN 
					(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * sdd.deal_volume * lp.percentage_used
							ELSE sdd.deal_volume * lp.percentage_used END) * (DATEDIFF(day,sdd.term_start,sdd.term_end)+1) 
				ELSE
					(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * sdd.deal_volume * lp.percentage_used
							ELSE sdd.deal_volume * lp.percentage_used END) 
				END	 AS NetItemVol, ''Monthly'' as deal_volume_frequency, 
	                      CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName,  
				sdd.deal_volume_uom_id,
		sdh.source_deal_header_id,CASE WHEN(sdd.fixed_float_leg = ''f'') THEN -1 ELSE isnull(pspcd.source_curve_def_id,spcd.source_curve_def_id) END curve_id
	FROM      fas_link_header flh INNER JOIN
              fas_link_detail fld ON flh.link_id = fld.link_id INNER JOIN
              source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
              source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
             inner join '+@link_deal_term_used_per+' lp on lp.link_id=fld.link_id and lp.source_deal_header_id=fld.source_deal_header_id
             and lp.term_start= sdd.term_start        INNER JOIN		      
				source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
				sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
				sdh.source_system_book_id4 = ssbm.source_system_book_id4 and  isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=401 LEFT OUTER JOIN
              source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
			  source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id INNER JOIN	
	          portfolio_hierarchy book ON flh.fas_book_id = book.entity_id INNER JOIN
			  --WhatIf Changes
			  fas_books fb ON fb.fas_book_id = book.entity_id INNER JOIN
	          portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id INNER JOIN   
			  portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id INNER JOIN
              fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
	WHERE    1=1' 
	+case when @as_of_date is null then '' else ' and 
	 flh.link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102) AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) ' end +'
		AND flh.link_type_value_id = 450 
		AND (fld.hedge_or_item = ''i'')		AND sdd.fixed_float_leg <> ''f''	AND sdd.leg = 1
		--WhatIf Changes
		AND (fb.no_link IS NULL OR fb.no_link = ''n'')	AND fs.hedge_type_value_id=' + CAST(@report_identifier as Char)  +
	case when  @subsidiary_id is null then '' else	' AND sub.entity_id IN  (' + @subsidiary_id + ') '  end
			+ @term_where_clause
--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
		
IF @strategy_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'
IF @book_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '
	
exec spa_print @sql_Select
exec spa_print  @sql_Where
EXEC (@sql_Select + @sql_Where)

--GET all perfect hedges opposite volume to represent hedged items
SET @sql_Where = ''
SET @sql_Select = '
	INSERT INTO #tempItems
	SELECT     flh.fas_book_id, sdh.deal_id + ''-p'' as deal_id, 
			dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
				CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN 
					(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN sdd.deal_volume * lp.percentage_used
							ELSE -1 * sdd.deal_volume * lp.percentage_used END) * (DATEDIFF(day,sdd.term_start,sdd.term_end)+1) 
				ELSE
					(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN sdd.deal_volume * lp.percentage_used
							ELSE -1 * sdd.deal_volume * lp.percentage_used END) 
				END			
				AS NetItemVol, 
				''Monthly'' as deal_volume_frequency, 
	                      CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName,  
				sdd.deal_volume_uom_id ,
			sdh.source_deal_header_id,CASE WHEN(sdd.fixed_float_leg = ''f'') THEN -1 ELSE isnull(pspcd.source_curve_def_id,spcd.source_curve_def_id) END curve_id
	FROM	fas_link_header flh INNER JOIN
			fas_link_detail fld ON flh.link_id = fld.link_id INNER JOIN
			source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id INNER JOIN
			source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			 inner join '+@link_deal_term_used_per+' lp on lp.link_id=fld.link_id and lp.source_deal_header_id=fld.source_deal_header_id
             and lp.term_start= sdd.term_start 	INNER JOIN		      
			source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
			sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
			sdh.source_system_book_id4 = ssbm.source_system_book_id4 and isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=400	LEFT OUTER JOIN
			source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
			source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id INNER JOIN	
			portfolio_hierarchy book ON flh.fas_book_id = book.entity_id INNER JOIN
			--WhatIf Changes
			fas_books fb ON fb.fas_book_id = book.entity_id INNER JOIN
			portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id INNER JOIN   
			portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id INNER JOIN
			fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
	WHERE 1=1' +case when  @as_of_date is null then '' else ' and (flh.link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) ' end +'
		AND flh.link_type_value_id = 450 
		AND (fld.hedge_or_item = ''h'') AND (flh.perfect_hedge = ''y'')
		AND sdd.fixed_float_leg <> ''f'' AND sdd.leg = 1
		--WhatIf Changes
		AND (fb.no_link IS NULL OR fb.no_link = ''n'')
		AND fs.hedge_type_value_id=' + CAST(@report_identifier as Char)  
		+case when @subsidiary_id is null then '' else ' AND sub.entity_id IN ( ' + @subsidiary_id + ') ' end +
			+ @term_where_clause
--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
		
IF @strategy_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'
IF @book_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '

exec spa_print @sql_Select
exec spa_print  @sql_Where
EXEC (@sql_Select + @sql_Where)


--Get outstanding forecasted transactions

If @include_gen_tranactions <> 'n'
BEGIN
	
	SET @sql_Select = 
	'INSERT INTO #tempItems
		SELECT     flh.fas_book_id, sdh.deal_id As deal_id, 
				dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
					sdd.deal_volume * isnull(lp.percentage_used,1) *
					CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN (DATEDIFF(day,sdd.term_start,sdd.term_end)+1) ELSE 1 end
					*
					CASE WHEN (sdd.buy_sell_flag = ''s'') THEN  
						case when isnull(flh.[perfect_hedge],''n'')=''n'' then -1 else 1 end
					else
						case when isnull(flh.[perfect_hedge],''n'')=''n'' then 1 else -1 end
					end		 AS NetItemVol, 
					''Monthly'' as deal_volume_frequency, 
		                      CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName,  
					sdd.deal_volume_uom_id,
				sdh.[source_deal_header_id] source_deal_header_id , CASE WHEN(sdd.fixed_float_leg = ''f'') THEN -1 ELSE isnull(pspcd.source_curve_def_id,spcd.source_curve_def_id) END AS curve_id  
		FROM	gen_fas_link_header flh INNER JOIN
		        gen_fas_link_detail fld ON flh.gen_link_id = fld.gen_link_id INNER JOIN
		        [source_deal_header] sdh ON fld.deal_number= sdh.[source_deal_header_id] INNER JOIN
		        [source_deal_detail] sdd ON sdh.[source_deal_header_id] = sdd.[source_deal_header_id]	
		        INNER JOIN	source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
				sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
				sdh.source_system_book_id4 = ssbm.source_system_book_id4 and  isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id)=[401]
				left join '+@link_deal_term_used_per+' lp on lp.link_id=flh.gen_link_id 
				and lp.source_deal_header_id=sdd.[source_deal_header_id]  and lp.term_start=sdd.term_start        
				 LEFT OUTER JOIN     source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
				source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id INNER JOIN	
		        portfolio_hierarchy book ON flh.fas_book_id = book.entity_id INNER JOIN
				--WhatIf Changes
				fas_books fb ON fb.fas_book_id = book.entity_id LEFT JOIN
		        portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id LEFT JOIN   
				portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id LEFT JOIN
		        fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
		WHERE 1=1'
		+case when @as_of_date  is null then '' else ' and  (flh.link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) 
			AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102))' end +'
			AND sdd.fixed_float_leg <> ''f''
			AND sdd.leg = 1 
			--WhatIf Changes
			AND (fb.no_link IS NULL OR fb.no_link = ''n'')
			AND fs.hedge_type_value_id=' + CAST(@report_identifier as Char)  
			+ case when @subsidiary_id is null then '' else ' AND sub.entity_id IN ( ' + @subsidiary_id + ') ' end 
				+ isnull(@term_where_clause,'')
	--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
			
	IF @strategy_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'
	IF @book_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '
	
	If @include_gen_tranactions = 'a'
		SET @Sql_Where = @Sql_Where + ' AND (flh.gen_status in ( ''a'',''p'') AND flh.gen_approved = ''y'' )'
	If @include_gen_tranactions = 'u'
		SET @Sql_Where = @Sql_Where + ' AND (flh.gen_status in ( ''a'',''p'')  AND flh.gen_approved = ''n'' )'
	If @include_gen_tranactions = 'b'
		SET @Sql_Where = @Sql_Where + ' AND (flh.gen_status  in ( ''a'',''p'') )'

	declare @sql_Select1 varchar(max)

	set @sql_Select1=REPLACE(@sql_Select,'[401]','401')
	--n means dont include, a means approved only, u means unapproved, b means both
	exec spa_print @sql_Select1
	exec spa_print @sql_Where
	exec spa_print  ' and isnull(flh.[perfect_hedge],''n'')=''n'' AND fld.[hedge_or_item] = ''i'''
	EXEC (@sql_Select1 + @sql_Where+' and isnull(flh.[perfect_hedge],''n'')=''n'' AND fld.[hedge_or_item] = ''i''')

	if isnull(@forecated_tran,'n')='y'
	begin
		set @sql_Select1=REPLACE(@sql_Select,'[source_deal_header_id]','gen_deal_header_id')
		set @sql_Select1=REPLACE(@sql_Select1,'[source_deal_header]','gen_deal_header')
		set @sql_Select1=REPLACE(@sql_Select1,'[source_deal_detail]','gen_deal_detail')
		exec spa_print @sql_Select1
		exec spa_print  @sql_Where
		exec spa_print ' and isnull(flh.[perfect_hedge],''n'')=''n'' AND fld.[hedge_or_item] = ''i'''
		EXEC (@sql_Select1 + @sql_Where+' and isnull(flh.[perfect_hedge],''n'')=''n'' AND fld.[hedge_or_item] = ''i''')
	end
	
	set @sql_Select1=REPLACE(@sql_Select,'[401]','400')
	exec spa_print @sql_Select1
	exec spa_print  @sql_Where
	exec spa_print ' and isnull(flh.[perfect_hedge],''n'')=''y'' AND fld.[hedge_or_item] = ''h'''
	EXEC (@sql_Select1 + @sql_Where+' and isnull(flh.[perfect_hedge],''n'')=''y'' AND fld.[hedge_or_item] = ''h''')

END




--select * from #tempItems

/*
UPDATE #tempItems
SET NetItemVol = NetItemVol * conversion_factor,
sui = vuc.to_source_uom_id
FROM #tempItems tI LEFT OUTER JOIN volume_unit_conversion  vuc
	ON tI.sui = vuc.from_source_uom_id 
WHERE vuc.to_source_uom_id = @convert_unit_id
*/

--select * from #tempItems

--select sum(netitemvol) as tot from #tempItems where fas_book_id = 10

--========Asset
--drop table [dbo].[#tempAsset]

CREATE TABLE [dbo].[#tempAsset] (
	[fas_book_id] [int] NOT NULL ,
	[deal_id] [varchar] (50)   NOT NULL ,
	[contract_expiration_date] datetime,
	[IndexName] [varchar] (100)   NOT NULL ,
	[deal_volume_frequency] [varchar] (7)   NOT NULL ,
	[NetAssetVol] [float] NULL ,
	[sui] [int] NOT NULL,
	source_deal_header_id int ,curve_id int
) ON [PRIMARY]




SET @sql_Select = '
INSERT INTO #tempAsset
SELECT     ssbm.fas_book_id,  sdh.deal_id, 			
		dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
			CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName, 
			''Monthly'' as deal_volume_frequency, --sdd.term_start, sdd.term_end, sdd.deal_volume,DATEDIFF(day,sdd.term_start,sdd.term_end)+1 as days,
                      CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN 
				(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN 
					-1 * sdd.deal_volume ELSE sdd.deal_volume END) * (DATEDIFF(day,sdd.term_start,sdd.term_end)+1)
			ELSE 
				(CASE WHEN (sdd.buy_sell_flag = ''s'') THEN 
					-1 * sdd.deal_volume ELSE sdd.deal_volume END)	END		AS NetAssesVol, 
			 sdd.deal_volume_uom_id AS sui,
		sdh.source_deal_header_id,isnull(pspcd.source_curve_def_id,spcd.source_curve_def_id) curve_id
FROM	source_deal_detail sdd INNER JOIN
        source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id LEFT OUTER JOIN
        source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
		source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id INNER JOIN		      
        source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 AND 
        sdh.source_system_book_id2 = ssbm.source_system_book_id2 AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 AND 
        sdh.source_system_book_id4 = ssbm.source_system_book_id4 INNER JOIN
        portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id INNER JOIN
		--WhatIf Changes
		fas_books fb ON fb.fas_book_id = book.entity_id INNER JOIN
        portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id INNER JOIN   
		portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id INNER JOIN
        fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
WHERE     (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = ' + cast(@asset_type_id as varchar)  + ') and  (sdh.deal_date  <= CONVERT(DATETIME, ''' + @as_of_date+ ''', 102)) and fs.hedge_type_value_id= ' + CAST(@report_identifier As Char) +
		' 
			--WhatIf Changes
			AND (fb.no_link IS NULL OR fb.no_link = ''n'')
			AND sdd.fixed_float_leg <> ''f''
		AND sdd.leg = 1
		AND sub.entity_id IN  ( ' + @subsidiary_id + ') ' +
		+ @term_where_clause			
--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'


SET @sql_Where = ''

IF @strategy_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'
IF @book_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '

--print (@sql_Select + @sql_Where)
EXEC (@sql_Select + @sql_Where)
--print @sql_Select + @sql_Where

--select * from #tempAsset

UPDATE #tempAsset
SET NetAssetVol = NetAssetVol * conversion_factor,
sui = vuc.to_source_uom_id
FROM #tempAsset tI LEFT OUTER JOIN volume_unit_conversion  vuc
	ON tI.sui = vuc.from_source_uom_id 
WHERE vuc.to_source_uom_id = @convert_unit_id

--select * from #tempAsset

--===combine asset and item

--supporting granularity type 's' means monthly, 'q' quarter, 's' semi-annual, 'a' anual
declare @granularity_type varchar(1)

declare @st_ids varchar(1000)
if @summary_option_orginal='l'
begin
	set @st_ids='max(s.entity_id) sub_id , max(s.entity_id) stra_id, max(s.entity_id) book_id,max(s.curve_id) curve_id, '
	SET @granularity_type ='t' --case when isnull(@limit_bucketing,'DE') ='DE' then 'm' else  't' end
end
else 
begin
	set @st_ids=''
	SET @granularity_type = @summary_option
end

If @summary_option <> 'd'
   SET @summary_option = 's'
   
 create table #tmp_s
(	sub_id int, stra_id int, book_id int,curve_id int, Subsidiary  varchar(150) COLLATE DATABASE_DEFAULT   , Strategy  varchar(150) COLLATE DATABASE_DEFAULT  ,yr int, mnth int
	, Book  varchar(150) COLLATE DATABASE_DEFAULT  ,IndexName  varchar(150) COLLATE DATABASE_DEFAULT  , ContractMonth datetime,  VolumeFrequency  varchar(50) COLLATE DATABASE_DEFAULT  ,VolumeUOM varchar(150) COLLATE DATABASE_DEFAULT  , 
     [NetAssetVol(+Buy,-Sell)] numeric(26,10), [NetItemVol(+Buy,-Sell)] numeric(26,10),[AvailableCapacity(+Buy,-Sell)] numeric(26,10), [OverHedged] varchar(3) COLLATE DATABASE_DEFAULT  
)   
   
--select convert(varchar(16),getdate(),107)
SET @sql_SelectS = '
	 insert into #tmp_s
	(	sub_id, stra_id, book_id,curve_id,	yr, mnth, Subsidiary, Strategy, Book,IndexName, ContractMonth,  VolumeFrequency,VolumeUOM , 
		 [NetAssetVol(+Buy,-Sell)], [NetItemVol(+Buy,-Sell)],[AvailableCapacity(+Buy,-Sell)],[OverHedged]
	)   
	SELECT  max(sub.entity_id) sub_id , max(stra.entity_id) stra_id, max(book.entity_id) book_id,max(a.curve_id) curve_id
		,year(max(A.ContractMonth)) yr, month(max(A.ContractMonth)) mnth
		, sub.entity_name AS Subsidiary, stra.entity_name AS Strategy, book.entity_name AS Book, A.IndexName,
		 A.ContractMonth,  A.VolumeFrequency, A.VolumeUOM, 
          round(SUM(A.[NetAssetVol]), 0) AS [NetAssetVol(+Buy,-Sell)], round(SUM(A.[NetItemVol]), 0) AS [NetItemVol(+Buy,-Sell)], 
		      round(
		      case when  abs(ISNULL(SUM(A.NetAssetVol), 0))< abs(ISNULL(SUM(A.NetItemVol), 0)) then  0 else
				abs(ISNULL(SUM(A.NetAssetVol), 0))-  abs(ISNULL(SUM(A.NetItemVol), 0))* case when SUM(A.NetAssetVol)<0 then -1 else 1 end  
				end, 0) [AvailableCapacity(+Buy,-Sell)],
			--New Logic
				case when  abs(ISNULL(SUM(A.NetAssetVol), 0))< abs(ISNULL(SUM(A.NetItemVol), 0)) then ''Yes'' else ''No'' end AS [OverHedged]
		FROM  portfolio_hierarchy sub INNER JOIN  portfolio_hierarchy stra INNER JOIN
            (
				SELECT    COALESCE (At.curve_id, it.curve_id) AS curve_id, COALESCE(At.fas_book_id, it.fas_book_id) AS fas_book_id, COALESCE (At.IndexName, it.IndexName) AS IndexName
					, COALESCE (At.ced, it.ced) AS ContractMonth, COALESCE (At.dvf, it.dvf) AS VolumeFrequency, COALESCE (AUOM.uom_name, IUOM.uom_name) AS VolumeUOM, 
			         isnull(At.NetAssetVol,0) AS NetAssetVol, isnull(it.NetItemVol,0) AS NetItemVol
				FROM  (
						SELECT     fas_book_id, contract_expiration_date AS ced, IndexName, deal_volume_frequency AS dvf, SUM(NetAssetVol) AS NetAssetVol, sui,max(curve_id) curve_id
	                    FROM     #tempAsset
	                       GROUP BY fas_book_id, contract_expiration_date, IndexName, deal_volume_frequency, sui) At INNER JOIN
	                      source_uom AUOM ON At.sui = AUOM.source_uom_id FULL OUTER JOIN
	                      source_uom IUOM INNER JOIN
                          (
								SELECT     fas_book_id, contract_expiration_date AS ced, SUM(NetItemVol) AS NetItemVol, deal_volume_frequency AS dvf, IndexName, sui,max(curve_id) curve_id
								FROM          #tempItems
								GROUP BY fas_book_id, contract_expiration_date, deal_volume_frequency, sui, IndexName
                            ) it ON IUOM.source_uom_id = it.sui ON 
	                      At.fas_book_id = it.fas_book_id AND At.ced = it.ced AND At.IndexName = it.IndexName
                  ) A INNER JOIN
                  portfolio_hierarchy book ON A.fas_book_id = book.entity_id ON stra.entity_id = book.parent_entity_id ON 
                  sub.entity_id = stra.parent_entity_id 
				GROUP BY sub.entity_name, stra.entity_name, book.entity_name, A.IndexName,  A.ContractMonth,  A.VolumeFrequency, A.VolumeUOM
'   
 
EXEC spa_print @sql_SelectS
exec(@sql_SelectS)


declare @as_of_date_month varchar(10)
declare @sql_from varchar(max),@fld_contract_month varchar(2000),@sql_order_by varchar(2000)

set @as_of_date_month=convert(varchar(8),cast(@as_of_date as datetime),120)+'01'

IF @summary_option = 's'	
BEGIN
	if @granularity_type='t'
	begin
		set @sql_from='
		 from #tmp_s s inner join generic_mapping_values g on g.clm1_value=s.curve_id 
			 inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id and h.mapping_name='''+ @tenor_name+'''
			inner join [dbo].[risk_tenor_bucket_detail] b on CAST(b.bucket_header_id AS VARCHAR(100)) = g.clm2_value and b.tenor_name=convert(varchar(3),cast('''+ @as_of_date_month +''' as datetime),107) 
				and s.ContractMonth between cast(year('''+ @as_of_date_month +''')+relative_year_from as varchar) + ''-''+right(''0''+cast(tenor_from as varchar),2)+''-01'' 
			 and cast(year('''+ @as_of_date_month +''')+relative_year_to as varchar) + ''-''+right(''0''+cast(tenor_to as varchar),2)+''-01''
		'
		set @fld_contract_month=',b.tenor_description TenorBucket,dbo.FNAUserDateFormat(cast(year('''+ @as_of_date_month +''')+relative_year_from as varchar) + ''-''+right(''0''+cast(tenor_from as varchar),2)+''-01'', '''+ dbo.FNADBUser()+''')  TenorStart
			,dbo.FNAUserDateFormat(cast(year('''+ @as_of_date_month +''')+relative_year_to as varchar) + ''-''+right(''0''+cast(tenor_to as varchar),2)+''-01'', '''+ dbo.FNADBUser()+''')  TenorEnd'
		
		set @sql_order_by=''
		
		set @sql_SelectS='select ' +
			case when  @summary_option_orginal='l' then 'sub_id, stra_id, book_id,curve_id,' else '' end	
			+ ' Subsidiary, Strategy, Book,IndexName '+ @fld_contract_month+', max(VolumeFrequency) VolumeFrequency,max(VolumeUOM) VolumeUOM , 
			 sum([NetAssetVol(+Buy,-Sell)]) [NetAssetVol(+Buy,-Sell)], sum([NetItemVol(+Buy,-Sell)]) [NetItemVol(+Buy,-Sell)]
			 
			 ,case when abs(sum([NetAssetVol(+Buy,-Sell)]))<abs( sum([NetItemVol(+Buy,-Sell)])) then 0 else abs(abs(sum([NetAssetVol(+Buy,-Sell)]))-abs(sum([NetItemVol(+Buy,-Sell)])))*case when sum([NetAssetVol(+Buy,-Sell)])<0 then -1 else 1 end end [AvailableCapacity(+Buy,-Sell)]
			 ,case when abs(sum([NetAssetVol(+Buy,-Sell)]))<abs( sum([NetItemVol(+Buy,-Sell)])) then ''Yes'' else ''No'' end [OverHedged]
			  ' +  @str_batch_table + ' '+@sql_from
			 + ' Group by ' + case when  @summary_option_orginal='l' then 'sub_id, stra_id, book_id,curve_id,' else '' end	+ ' Subsidiary, Strategy, Book,IndexName
			 ,b.tenor_description,cast(year('''+ @as_of_date_month +''')+relative_year_from as varchar) + ''-''+right(''0''+cast(tenor_from as varchar),2)+''-01''
			,cast(year('''+ @as_of_date_month +''')+relative_year_to as varchar) + ''-''+right(''0''+cast(tenor_to as varchar),2)+''-01'' '
		
		IF @exception_Flag = 'e'
			SET @sql_SelectS = 'SELECT Subsidiary, Strategy,Book, IndexName ' +@fld_contract_month+'
					, max(VolumeFrequency) VolumeFrequency,max(VolumeUOM) VolumeUOM, CAST (sum([NetAssetVol(+Buy,-Sell)]) AS NUMERIC(38,' + @round_value + ')) [NetAssetVol(+Buy,-Sell)], CAST(sum([NetItemVol(+Buy,-Sell)]) AS NUMERIC(38,' + @round_value + ')) [NetItemVol(+Buy,-Sell)],max([OverHedged]) [OverHedged]
				 ' +  @str_batch_table + ' '+@sql_from + ' WHERE OverHedged = ''YES''
			 Group by Subsidiary, Strategy, Book,IndexName,b.tenor_description,cast(year('''+ @as_of_date_month +''')+relative_year_from as varchar) + ''-''+right(''0''+cast(tenor_from as varchar),2)+''-01''
			,cast(year('''+ @as_of_date_month +''')+relative_year_to as varchar) + ''-''+right(''0''+cast(tenor_to as varchar),2)+''-01'''

		set @sql_SelectS=@sql_SelectS+'	
			 ORDER BY Subsidiary, Strategy, Book, IndexName ,TenorStart,TenorEnd'
	end
	else
	begin

		set @sql_from=' from #tmp_s s '
		set @fld_contract_month=case when (@granularity_type in ('m', 'd')) then  ',dbo.FNAContractMonthFormat(s.ContractMonth) ' else ',dbo.FNAGetTermGrouping(s.ContractMonth , ''' + @granularity_type + ''') ' end 

		set @sql_order_by=''

		--set @sql_SelectS='select Subsidiary,Strategy,Book ,IndexName, ContractMonth,VolumeFrequency,VolumeUOM, 
		--	 [NetAssetVol(+Buy,-Sell)], [NetItemVol(+Buy,-Sell)],[AvailableCapacity(+Buy,-Sell)], [OverHedged] '+@sql_from

		if @summary_option_orginal='l'
			set @fld_contract_month=',null TenorBucket,dbo.FNAUserDateFormat(cast(yr as varchar) + ''-''+right(''0''+cast(mnth as varchar),2)+''-01'', '''+ dbo.FNADBUser()+''') TenorStart
						,dbo.FNAUserDateFormat(convert(varchar(10),dateadd(month,1,cast(cast(yr as varchar) + ''-''+right(''0''+cast(mnth as varchar),2)+''-01'' as datetime))-1,120), '''+ dbo.FNADBUser()+''') TenorEnd'
		else
			set @fld_contract_month=', dbo.FNAUserDateFormat(ContractMonth, '''+ dbo.FNADBUser()+''')'		
		
		set @sql_SelectS='select ' +
			case when  @summary_option_orginal='l' then 'sub_id, stra_id, book_id,curve_id,' else '' end	
			+ ' Subsidiary, Strategy, Book,IndexName '+ @fld_contract_month + ' ContractMonth, VolumeFrequency,VolumeUOM , 
			 [NetAssetVol(+Buy,-Sell)], [NetItemVol(+Buy,-Sell)]
			 ,case when abs([NetAssetVol(+Buy,-Sell)])<abs( [NetItemVol(+Buy,-Sell)]) then 0 else (abs([NetAssetVol(+Buy,-Sell)])-abs( [NetItemVol(+Buy,-Sell)]))*case when [NetAssetVol(+Buy,-Sell)]<0 then -1 else 1 end end [AvailableCapacity(+Buy,-Sell)]
			 ,case when abs([NetAssetVol(+Buy,-Sell)])<abs( [NetItemVol(+Buy,-Sell)]) then ''Yes'' else ''No'' end [OverHedged] ' +  @str_batch_table + ' 
			  '+@sql_from
			 
		set @sql_SelectS='select ' +
			case when  @summary_option_orginal='l' then 'sub_id, stra_id, book_id,curve_id,' else '' end	
			+ ' Subsidiary, Strategy, Book,IndexName '+ @fld_contract_month + ' ContractMonth, VolumeFrequency,VolumeUOM , 
			 [NetAssetVol(+Buy,-Sell)], [NetItemVol(+Buy,-Sell)]
			 ,case when abs([NetAssetVol(+Buy,-Sell)])<abs( [NetItemVol(+Buy,-Sell)]) then 0 else (abs([NetAssetVol(+Buy,-Sell)])-abs( [NetItemVol(+Buy,-Sell)]))*case when [NetAssetVol(+Buy,-Sell)]<0 then -1 else 1 end end [AvailableCapacity(+Buy,-Sell)]
			 ,case when abs([NetAssetVol(+Buy,-Sell)])<abs( [NetItemVol(+Buy,-Sell)]) then ''Yes'' else ''No'' end [OverHedged] ' +  @str_batch_table + ' '+@sql_from
			 

		IF @exception_Flag = 'e'
			SET @sql_SelectS = 'SELECT Subsidiary, Strategy,Book, IndexName ' +@fld_contract_month+' ContractMonth
					, VolumeFrequency,VolumeUOM, CAST ([NetAssetVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [NetAssetVol(+Buy,-Sell)], CAST ([NetItemVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [NetItemVol(+Buy,-Sell)], [OverHedged]
					' +  @str_batch_table + ' 
				 '+@sql_from + ' WHERE OverHedged = ''YES'''
			
			
		if @summary_option_orginal='l' and @granularity_type='m'
			set @sql_SelectS=@sql_SelectS+'	 
				 ORDER BY sub_id, stra_id, book_id,curve_id  ,yr,mnth'
		else		 
			set @sql_SelectS=@sql_SelectS+'	 
				 ORDER BY Subsidiary, Strategy, Book, IndexName ' +
				 case   when (@granularity_type IN ( 's','q') AND @exception_flag = 'e') then ', right(contractMonth,4), left(contractMonth,1)'  
					when (@granularity_type IN ( 'm', 'd')) then ', convert(datetime, replace(ContractMonth, ''-'', ''-1-''), 102)' 
						 when (@granularity_type = 'a') then ', ContractMonth'
						else ' , substring(dbo.FNAGetTermGrouping(ContractMonth , ''' + @granularity_type + ''') , len(dbo.FNAGetTermGrouping(ContractMonth , ''' + @granularity_type + ''')) -3, 4), 
							dbo.FNAGetTermGrouping(ContractMonth , ''' + @granularity_type + ''') ' 
					end			 
	end


	EXEC spa_print '************************************8'
	EXEC spa_print @sql_SelectS
	EXEC spa_print '************************************8'

	EXEC(@sql_SelectS)
END
else
begin
	 create table #tmp_d
	(	 book_id int,curve_id int,	yr int, mnth int, ContractMonth datetime, [Type] varchar(15) COLLATE DATABASE_DEFAULT  ,DealID  varchar(150) COLLATE DATABASE_DEFAULT  , VolumeFrequency  varchar(50) COLLATE DATABASE_DEFAULT  
		,VolumeUOM varchar(50) COLLATE DATABASE_DEFAULT  , [NetAssetVol(+Buy,-Sell)] numeric(26,10), source_deal_header_id int
	)

	SET @sql_SelectD = 'insert into #tmp_d
		(	 book_id,curve_id ,	yr, mnth, ContractMonth, [Type], DealID,VolumeFrequency ,VolumeUOM,  [NetAssetVol(+Buy,-Sell)] , source_deal_header_id		)
		SELECT   a.fas_book_id,A.curve_id,yeAR(A.ContractMonth) Yr,month(A.ContractMonth) mnth, 
		A.ContractMonth, Type, A.DealID, A.VolumeFrequency, A.VolumeUOM, 
			round(A.[Vol], 0) AS [NetAssetVol(+Buy,-Sell)],	A.source_deal_header_id			
		FROM  portfolio_hierarchy sub INNER JOIN
		portfolio_hierarchy stra INNER JOIN
		(
		SELECT  fas_book_id, IndexName, 
			contract_expiration_date AS ContractMonth,  
			''Asset'' Type,
			deal_id DealID, 
			deal_volume_frequency AS VolumeFrequency, 
			SUM(NetAssetVol) AS Vol, 
			max(uom_name) AS VolumeUOM,
			max(source_deal_header_id)  source_deal_header_id,curve_id
		FROM  #tempAsset LEFT OUTER JOIN source_uom UOM ON sui = UOM.source_uom_id 
		GROUP BY fas_book_id,  IndexName, contract_expiration_date,  deal_id, deal_volume_frequency, sui,curve_id
		UNION
		SELECT  fas_book_id, IndexName, 
			contract_expiration_date AS ContractMonth,  
			''Items'' Type,
			deal_id DealID, 
			deal_volume_frequency AS VolumeFrequency, 
			SUM(NetItemVol) AS Vol, 
			max(uom_name) AS VolumeUOM,
			max(source_deal_header_id)  source_deal_header_id,curve_id
		FROM   #tempItems LEFT OUTER JOIN source_uom UOM ON sui = UOM.source_uom_id 
		GROUP BY fas_book_id,  IndexName, contract_expiration_date,  deal_id, deal_volume_frequency, sui,curve_id
		) A INNER JOIN portfolio_hierarchy book ON A.fas_book_id = book.entity_id ON stra.entity_id = book.parent_entity_id ON 
		sub.entity_id = stra.parent_entity_id '	

	EXEC spa_print @sql_SelectD
	EXEC(@sql_SelectD)

	SET @sql_SelectD = 'SELECT  SummaryA.Subsidiary, SummaryA.Strategy, SummaryA.Book, SummaryA.IndexName [Index Name]
			, dbo.FNADateFormat(SummaryA.ContractMonth) [Contract Month]
			, CAST(SummaryA.[NetAssetVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [Net Asset Vol (+Buy,-Sell)]
			, CAST(SummaryA.[NetItemVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [Net Item Vol (+Buy,-Sell)]
			, A.Type
			, dbo.FNATRMWinHyperlink(''a'', 10131010, A.DealId, ABS(A.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Deal ID]
			--, dbo.FNAHyperLink(10131000, A.DealId, A.source_deal_header_id,-1) [Deal ID],
			, A.VolumeFrequency [Volume Frequency]
			, A.VolumeUOM [Volume UOM]
			, CAST(A.[NetAssetVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) As Volume
			, SummaryA.[OverHedged] [Over Hedged]
			' +  @str_batch_table + ' 
			FROM #tmp_d A INNER JOIN #tmp_s SummaryA ON 
			 A.book_id = SummaryA.book_id AND A.curve_id = SummaryA.curve_id AND A.yr = SummaryA.yr AND A.mnth = SummaryA.mnth
			ORDER BY SummaryA.Subsidiary, SummaryA.Strategy, SummaryA.Book, SummaryA.IndexName, convert(datetime, replace(A.ContractMonth, ''-'', ''-1-''), 102), A.Type, A.DealId'

	
	exec spa_print @sql_SelectD
	-- EXEC spa_print @summary_Option
	--IF @summary_Option = 'd'
	EXEC(@sql_SelectD)
	---------==============================
end


/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_Create_Available_Hedge_Capacity_Exception_Report', 'Available Hedge Capacity Exception Report')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/
