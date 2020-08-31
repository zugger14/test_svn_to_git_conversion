IF OBJECT_ID(N'spa_Create_Hedge_Item_Matching_Report') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Create_Hedge_Item_Matching_Report]
 GO 
--
-- EXEC spa_Create_Hedge_Item_Matching_Report '2004-12-31','30','208','223','u',d,'f','n','CIF','2005-01-01','Metric Tons',NULL
----exec spa_Create_Hedge_Item_Matching_Report '2005-12-31', '', null, '223', 'a', 's', 'f', 'n'
--
---- @summary option: 's' summary by semi-annual, 'q' summary by quarter, 'a' summary by annual, 'm' summary by month, 'd' detail
---- @settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
--
CREATE PROC [dbo].[spa_Create_Hedge_Item_Matching_Report]
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@report_type char(1),   --a show all,  m show only matched, u show unmatched
	@summary_option char(1) = 'd', --s summary  front end always passes summary d detail,  m for deal level detail
	@settlement_option char(1) = 'f',
	@include_gen_tranactions char(1) = 'b',
	@index varchar(50) = NULL, 
	@term_start varchar(20) = NULL, 
	@uom_name varchar(50) = NULL, 
	@link_id varchar(50) = NULL,
	@commodity_id varchar(100) = NULL
 AS
--
--SET NOCOUNT ON

--to id = 3 mmbtu

-----------uncomment these to test locally
-- declare	@as_of_date varchar(50)
-- declare 	@sub_entity_id varchar(100)
-- declare 	@strategy_entity_id varchar(100)
-- declare 	@book_entity_id varchar(100)
-- declare 	@report_type char(1)
-- declare 	@summary_option char(1) 
-- --declare 	@convert_unit_id int
-- --declare 	@exception_flag char(1)
-- --declare 	@asset_type_id int
-- declare 	@settlement_option char(1)
-- declare 	@include_gen_tranactions char(1)
-- declare    @index varchar(50)
-- declare	@term_start varchar(20)
-- declare	@uom_name varchar(50)
-- declare	@link_id varchar(50)
--
-- 
-- set @as_of_date = '2004-12-31'
-- set @sub_entity_id = '30'
-- set @strategy_entity_id = null
-- set @book_entity_id = '223'
-- set @report_type = 'a'     --a show all,  m show only matched, u show unmatched
-- set @summary_option = 'd' --s summary  d detail
-- --set @convert_unit_id = 14
-- --set @exception_flag = 'a'
-- --set @asset_type_id = 402
-- SET @settlement_option = 'a'
-- --n means dont include, a means approved only, u means unapproved, b means both
-- SET @include_gen_tranactions = 'b'
----set @link_id = 622
-- -- -- 
-- drop table #tempItems
---- drop table #tempAsset
--drop table #ssbm_b



--*******************************************************
-- this report works only for Summary Level Data
--******************************************************


DECLARE @Sql_SelectB VARCHAR(5000)        
DECLARE @Sql_WhereB VARCHAR(5000)        
DECLARE @assignment_type int        
        
SET @Sql_WhereB = ''        

CREATE TABLE #ssbm_b(source_system_book_id1 int, 
					source_system_book_id2 int, 
					source_system_book_id3 int, 
					source_system_book_id4 int, 
					fas_book_id int,
					fas_deal_type_value_id int)        


SET @Sql_SelectB=        
'INSERT INTO  #ssbm_b        
SELECT	source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, max(book.entity_id) fas_book_id,
		max(fas_deal_type_value_id) fas_deal_type_value_id
	FROM portfolio_hierarchy book (nolock) INNER JOIN
		Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN   
		source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
'   

              
IF @sub_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
 IF @strategy_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
 IF @book_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
        
SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB + 
	' group by source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4 '     
     
         
EXEC (@Sql_SelectB)


If @include_gen_tranactions IS NULL
	SET @include_gen_tranactions = 'b'

Declare @Sql_Select varchar(8000)
Declare @Sql_SelectS varchar(8000)
Declare @Sql_SelectD varchar(8000)
Declare @term_where_clause varchar(1000)
Declare @detail_url varchar(3000)

Declare @Sql_Where varchar(8000)

declare @report_identifier int

SET @sql_Where = ''

If @settlement_option = 'f'
	set @term_where_clause = ' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
Else If @settlement_option = 'c'
	set @term_where_clause = ' AND sdd.term_start >=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as varchar) + '/1/' + cast(year(@as_of_date) as varchar) + ''' , 102)'
Else If @settlement_option = 's'
	set @term_where_clause = ' AND sdd.term_start <=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as varchar) + '/1/' + cast(year(@as_of_date) as varchar) + ''' , 102)'
Else
	set @term_where_clause = ''

 
--drop table #tempItems

CREATE TABLE [dbo].[#tempItems] (
	[link_id] [int] NULL,
	[gen_link] varchar(1) NULL,
	[fas_book_id] [int] NULL,
	[source_deal_header_id] [int] NULL,
	[deal_id] [varchar] (50)  NULL ,
	[term_start] datetime NULL,
	[linked_vol] [float] NULL ,
	[linked_per] [float] NULL ,
	[original_vol] [float] NULL ,	
	[frequency] [char] (7)   NULL ,
	[index_name] [varchar] (100)   NULL ,	
	fas_deal_type_value_id int NULL,
	[uom_name] [varchar] (20) NULL,
	[perfect_hedge] varchar(1) NULL,
	[deal_date] datetime NULL,
	[link_effective_date] datetime NULL 
) ON [PRIMARY]

--Get all the Items first
declare @linked_per varchar(500)
set @linked_per = ' case when '''+@as_of_date+'''>=isnull(flh.link_end_date,''9999-01-01'') then 0 else isnull(fld.percentage_included,0) end '

SET @sql_Select = '
	INSERT INTO #tempItems
	SELECT  flh.link_id,  
			''n'' gen_link, 
			flh.fas_book_id, 
			sdh.source_deal_header_id,
			sdh.deal_id, 
			dbo.FNAGetContractMonth(sdd.term_start) AS term_start,
			CASE WHEN (sdd.deal_volume_frequency = ''d'') THEN DATEDIFF(day,sdd.term_start,sdd.term_end)+1 ELSE 1 END *
			CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 ELSE 1 END * sdd.deal_volume * ' + @linked_per +  ' AS linked_vol, 
			' + @linked_per +  ' linked_per,
			CASE WHEN (sdd.deal_volume_frequency = ''d'') THEN DATEDIFF(day,sdd.term_start,sdd.term_end)+1 ELSE 1 END *
			CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 ELSE 1 END * sdd.deal_volume AS original_vol, 
			''Monthly'' as deal_volume_frequency, 
	        CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName,  
			isnull(sdh.fas_deal_type_value_id,sb.fas_deal_type_value_id) fas_deal_type_value_id,
			su.uom_name uom_name,
			isnull(flh.perfect_hedge, ''n'') perfect_hedge,
			sdh.deal_date,
			flh.link_effective_date 
	FROM    source_deal_header sdh INNER JOIN
			#ssbm_b sb ON sdh.source_system_book_id1 = sb.source_system_book_id1 AND
					sdh.source_system_book_id2 = sb.source_system_book_id2 AND
					sdh.source_system_book_id3 = sb.source_system_book_id3 AND
					sdh.source_system_book_id4 = sb.source_system_book_id4 INNER JOIN
			source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id LEFT OUTER JOIN
			fas_link_detail fld ON fld.source_deal_header_id = sdh.source_deal_header_id LEFT OUTER JOIN
			fas_link_header flh ON flh.link_id = fld.link_id LEFT OUTER JOIN
			source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
			source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id LEFT OUTER JOIN
	        portfolio_hierarchy book ON flh.fas_book_id = book.entity_id LEFT OUTER JOIN
	        portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN
			portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id LEFT OUTER JOIN
			fas_strategy fs ON stra.entity_id = fs.fas_strategy_id LEFT OUTER JOIN
			source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
	WHERE   flh.link_effective_date <= ''' + @as_of_date + ''' 
		AND sdh.deal_date <= ''' + @as_of_date + ''''

--select * from source_uom
EXEC (@sql_Select + @term_where_clause)
--print @sql_Select


If @include_gen_tranactions <> 'n'
BEGIN
	SET @sql_Select = '
		INSERT INTO #tempItems
		SELECT  flh.link_id, 
				''y'' gen_link,   
				flh.fas_book_id, 
				sdh.source_deal_header_id,
				sdh.deal_id, 
				dbo.FNAGetContractMonth(sdd.term_start) AS term_start,
				CASE WHEN (sdd.deal_volume_frequency = ''d'') THEN DATEDIFF(day,sdd.term_start,sdd.term_end)+1 ELSE 1 END *
				CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 ELSE 1 END * sdd.deal_volume * isnull(fld.percentage_included,0) AS linked_vol, 
				isnull(fld.percentage_included,0) linked_per,
				CASE WHEN (sdd.deal_volume_frequency = ''d'') THEN DATEDIFF(day,sdd.term_start,sdd.term_end)+1 ELSE 1 END *
				CASE WHEN (sdd.buy_sell_flag = ''s'') THEN -1 ELSE 1 END * sdd.deal_volume AS original_vol, 
				''Monthly'' as deal_volume_frequency, 
				CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName,  
				isnull(sdh.fas_deal_type_value_id,sb.fas_deal_type_value_id) fas_deal_type_value_id,
				su.uom_name uom_name,
				isnull(flh.perfect_hedge, ''n'') perfect_hedge,
				sdh.deal_date, 
				flh.link_effective_date 
		FROM    source_deal_header sdh INNER JOIN
				#ssbm_b sb ON sdh.source_system_book_id1 = sb.source_system_book_id1 AND
						sdh.source_system_book_id2 = sb.source_system_book_id2 AND
						sdh.source_system_book_id3 = sb.source_system_book_id3 AND
						sdh.source_system_book_id4 = sb.source_system_book_id4 INNER JOIN
				source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id LEFT OUTER JOIN
				gen_fas_link_detail fld ON fld.deal_number = sdh.source_deal_header_id LEFT OUTER JOIN
				gen_fas_link_header flh ON flh.gen_link_id = fld.gen_link_id LEFT OUTER JOIN
				source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id LEFT OUTER JOIN
				source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id LEFT OUTER JOIN
				portfolio_hierarchy book ON flh.fas_book_id = book.entity_id LEFT OUTER JOIN
				portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN
				portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id LEFT OUTER JOIN
				fas_strategy fs ON stra.entity_id = fs.fas_strategy_id LEFT OUTER JOIN
				source_uom su on su.source_uom_id = sdd.deal_volume_uom_id
		WHERE   flh.link_effective_date <= ''' + @as_of_date + ''' 
			AND sdh.deal_date <= ''' + @as_of_date + ''''

	If @include_gen_tranactions = 'a'
		SET @term_where_clause = @term_where_clause + ' AND (flh.gen_status = ''a'' AND flh.gen_approved = ''y'' )'
	If @include_gen_tranactions = 'u'
		SET @term_where_clause = @term_where_clause + ' AND (flh.gen_status = ''a'' AND flh.gen_approved = ''n'' )'
	If @include_gen_tranactions = 'b'
		SET @term_where_clause = @term_where_clause + ' AND (flh.gen_status = ''a'')'

	EXEC (@sql_Select + @term_where_clause)
END


-- Insert perfect hedges items
insert into #tempItems
select	link_id, 
		'n' gen_link, 
		max(fas_book_id) fas_book_id, NULL source_deal_header_id, NULL deal_id, 
		term_start, -1 * sum(linked_vol) linked_vol,
		sum(linked_per)  linked_per,
		-1 * max(original_vol) original_vol, 
		max(frequency) frequency, index_name, 401 fas_deal_type_value_id,
		max(uom_name) uom_name,
		'n' perfect_hedge,
		max(deal_date) deal_date,
		max(link_effective_date) link_effective_date
from #tempItems 
where perfect_hedge = 'y'
group by link_id, source_deal_header_id, term_start, index_name

--Insert not linked values
insert into #tempItems
select	NULL link_id, 
		'y' gen_link, 
		max(fas_book_id) fas_book_id, source_deal_header_id, max(deal_id) deal_id, 
		term_start, sum(linked_vol) linked_vol,
		1 - sum(linked_per)  linked_per,
		max(original_vol) original_vol, 
		max(frequency) frequency, index_name, max(fas_deal_type_value_id) fas_deal_type_value_id,
		max(uom_name) uom_name,
		'n' perfect_hedge,
		max(deal_date) deal_date,
		max(link_effective_date) link_effective_date
from #tempItems 
where source_deal_header_id IS NOT NULL 
group by source_deal_header_id, term_start, index_name
having sum(linked_per) < 1 

if @summary_option = 's'
begin
	
	select	coalesce(h.index_name, i.index_name) [Commodity/Index],
			dbo.FNADateFormat(coalesce(h.term_start, i.term_start)) [Delivery Month],
			coalesce(h.uom_name, i.uom_name) [UOM],
			sum(isnull(h.linked_vol, 0)) [Hedge Vol],
			sum(isnull(i.linked_vol, 0)) [Hedged Item Vol],
			sum(isnull(h.linked_vol, 0) + isnull(i.linked_vol, 0)) [Net Vol],
			'<a target="_blank" HREF="' + 
			'../dev/spa_html.php?spa=EXEC spa_Create_Hedge_Item_Matching_Report ' + 
			case when (@as_of_date is NULL) then 'NULL' else '''' + @as_of_date + ''''  end + ',' +
			case when (@sub_entity_id is NULL) then 'NULL' else '''' + @sub_entity_id + ''''  end + ',' +
			case when (@strategy_entity_id is NULL) then 'NULL' else '''' + @strategy_entity_id + ''''  end + ',' +
			case when (@book_entity_id is NULL) then 'NULL' else '''' + @book_entity_id + ''''  end + ',' +
			case when (@report_type is NULL) then 'NULL' else '''' + @report_type + ''''  end + ',' +
			'd' + ',' +
			case when (@settlement_option is NULL) then 'NULL' else '''' + @settlement_option + ''''  end + ',' +
			case when (@include_gen_tranactions is NULL) then 'NULL' else '''' + @include_gen_tranactions + ''''  end + ',' +
			'''' + coalesce(h.index_name, i.index_name) + ''''  + ',' +
			'''' + dbo.FNAGetSQLStandardDate(coalesce(h.term_start, i.term_start)) + ''''  + ',' +
			'''' + coalesce(h.uom_name, i.uom_name) + ''''  + ',' +
			'NULL' +
			'">Detail...</a>' [Detail]

	from 
	(
		select index_name, term_start, uom_name, sum(linked_vol) linked_vol
		from   #tempItems where fas_deal_type_value_id = 400
		and (@report_type  = 'a' OR (@report_type = 'm' AND link_id IS NOT NULL) OR
				(@report_type = 'u' AND link_id IS NULL)) 
		group by index_name, term_start, uom_name	
	) h FULL OUTER JOIN
	(
		select index_name, term_start, uom_name, sum(linked_vol) linked_vol
		from   #tempItems where fas_deal_type_value_id = 401
		and (@report_type  = 'a' OR (@report_type = 'm' AND link_id IS NOT NULL) OR
				(@report_type = 'u' AND link_id IS NULL)) 
		group by index_name, term_start, uom_name
	) i ON h.index_name = i.index_name AND h.term_start = i.term_start AND h.uom_name = i.uom_name
	group by coalesce(h.index_name, i.index_name), coalesce(h.term_start, i.term_start), coalesce(h.uom_name, i.uom_name)
end
else if @summary_option = 'd' 
begin 

	select	
			case when (coalesce(h.gen_link, i.gen_link) = 'n') then 
				dbo.FNAHyperLinkText(10233710, cast(coalesce(h.link_id, i.link_id) as varchar), cast(coalesce(h.link_id, i.link_id) as varchar)) 
			else cast(coalesce(h.link_id, i.link_id) as varchar) end [Hedge Rel ID],
			coalesce(h.index_name, i.index_name) [Commodity/Index],
			dbo.FNADateFormat(coalesce(h.term_start, i.term_start)) [Delivery Month],
			coalesce(h.uom_name, i.uom_name) [UOM],
			sum(isnull(h.linked_vol, 0)) [Hedge Vol],
			sum(isnull(i.linked_vol, 0)) [Hedged Item Vol],
			sum(isnull(h.linked_vol, 0) + isnull(i.linked_vol, 0)) [Net Vol],
			'<a target="_blank" HREF="' + 
				'../dev/spa_html.php?spa=EXEC spa_Create_Hedge_Item_Matching_Report ' + 
			case when (@as_of_date is NULL) then 'NULL' else '''' + @as_of_date + ''''  end + ',' +
			case when (@sub_entity_id is NULL) then 'NULL' else '''' + @sub_entity_id + ''''  end + ',' +
			case when (@strategy_entity_id is NULL) then 'NULL' else '''' + @strategy_entity_id + ''''  end + ',' +
			case when (@book_entity_id is NULL) then 'NULL' else '''' + @book_entity_id + ''''  end + ',' +
			case when (@report_type is NULL) then 'NULL' else '''' + @report_type + ''''  end + ',' +
			'm'   + ',' +
			case when (@settlement_option is NULL) then 'NULL' else '''' + @settlement_option + ''''  end + ',' +
			case when (@include_gen_tranactions is NULL) then 'NULL' else '''' + @include_gen_tranactions + ''''  end + ',' +
			'NULL' + ',' +
			'NULL' + ',' +
			'NULL' + + ',' +
			isnull('''' + cast(coalesce(h.link_id, i.link_id) as varchar) + '''', NULL)  +
			'">Detail...</a>' [Detail]
	from 
	(
		select link_id, max(gen_link) gen_link, index_name, term_start, uom_name, sum(linked_vol) linked_vol
		from   #tempItems where fas_deal_type_value_id = 400
		and (@report_type  = 'a' OR (@report_type = 'm' AND link_id IS NOT NULL) OR
				(@report_type = 'u' AND link_id IS NULL)) 
		and index_name = isnull(@index, index_name) and term_start = isnull(@term_start, term_start) and uom_name = isnull(@uom_name, uom_name)
		group by link_id, index_name, term_start, uom_name	
	) h FULL OUTER JOIN
	(
		select link_id, max(gen_link) gen_link, index_name, term_start, uom_name, sum(linked_vol) linked_vol
		from   #tempItems where fas_deal_type_value_id = 401
		and (@report_type  = 'a' OR (@report_type = 'm' AND link_id IS NOT NULL) OR
				(@report_type = 'u' AND link_id IS NULL)) 
		and index_name = isnull(@index, index_name) and term_start = isnull(@term_start, term_start) and uom_name = isnull(@uom_name, uom_name)
		group by link_id, index_name, term_start, uom_name
	) i ON h.index_name = i.index_name AND h.term_start = i.term_start AND h.uom_name = i.uom_name
	group by coalesce(h.link_id, i.link_id), coalesce(h.index_name, i.index_name), coalesce(h.term_start, i.term_start), 
			coalesce(h.uom_name, i.uom_name), coalesce(h.gen_link, i.gen_link)
end
else if @summary_option = 'm' 
begin

	select	case when (gen_link = 'n') then 
				dbo.FNAHyperLinkText(10233710, cast(link_id as varchar), cast(link_id as varchar)) else  cast(link_id as varchar) end [Hedge Rel ID],
			dbo.FNADateFormat(term_start) [Delivery Month], 
			index_name [Commodity/Index], 
			case when (fas_deal_type_value_id = 400) then 'Hedge' else 'Item' end [Hedge/Item],
			source_deal_header_id [Deal ID], 
			dbo.FNAHyperLinkText(10131000, deal_id, cast(source_deal_header_id as varchar)) [Ref Deal ID],			
			uom_name [UOM], 
			linked_vol Vol
		from   #tempItems 
		WHERE (@report_type  = 'a' OR (@report_type = 'm' AND link_id IS NOT NULL) OR
				(@report_type = 'u' AND link_id IS NULL)) 
		and index_name = isnull(@index, index_name) and term_start = isnull(@term_start, term_start) and uom_name = isnull(@uom_name, uom_name)
		and isnull(link_id, -1) = isnull(@link_id, -1)
		order by link_id, term_start, index_name, fas_deal_type_value_id, source_deal_header_id, deal_id
end




