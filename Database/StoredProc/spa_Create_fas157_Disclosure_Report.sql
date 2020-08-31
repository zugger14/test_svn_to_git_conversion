
IF OBJECT_ID(N'spa_Create_fas157_Disclosure_Report', N'P') IS NOT NULL
drop proc  [dbo].[spa_Create_fas157_Disclosure_Report]
GO

-- exec spa_Create_fas157_Disclosure_Report '2009-01-31', '195,192,193,196,194,230', NULL, NULL, 'd', 's', 'c', 3, 2, 5, 'Options'
-- exec spa_Create_fas157_Disclosure_Report '2009-01-31', '195,192,193,196,194,230', NULL, NULL, 'd', 's', 'c', 3, 2, 5, 'Copper/Zync'

-- exec spa_Create_fas157_Disclosure_Report '2004-12-31', '291,30,1,257,258,256', NULL, NULL, 'd', 's', 'b', 0


-- exec spa_Create_fas157_Disclosure_Report '2006-12-31', '291,30,1,257,258,256', NULL, NULL, 'd', 's', 'b', 3



-- EXEC spa_Create_fas157_Disclosure_Report '2006-06-30', null, 208, null, 'd', 's', 'b', 3, 1
-- EXEC spa_Create_fas157_Disclosure_Report '2006-06-30', null, 208, null, 'd', 's', 'b', 3, 2, 3, 'NG - Oil and HFO'
-- EXEC spa_Create_fas157_Disclosure_Report '2006-12-31',  '1, 30', null, null, 'd', 'c', 'b', 1 , 2, 5 , 'Sub2/Other Examples/Partial Designation'

CREATE PROC [dbo].[spa_Create_fas157_Disclosure_Report] 
	@as_of_date varchar(50), 
						@sub_entity_id varchar(MAX), 
 						@strategy_entity_id varchar(MAX) = NULL, 
						@book_entity_id varchar(MAX) = NULL, 
						@discount_option char(1) = 'd', 
						@summary_option char(1) = 's', --'s' summary, 'a' Sub, 'b' Sub/Strategy, 'c' Sub/Strategy/Book		
						@asset_liability char(1)= 'b', --'a' asset, 'l' liability, 'b' or NULL means both
						@prior_months int = 12,
						@drill_down_level int = 1, --1 means main report --2 means second level drill down --3 means third level drill down
						@drill_down_column int = NULL,
						@drill_down_value varchar(250) = NULL,
						@round_value CHAR(1) = 0,
						@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
	
 AS

 SET NOCOUNT ON

--SUMMARY and DETAIL

 -----begin of test
/*
 declare @as_of_date varchar(50), @sub_entity_id varchar(100), 
  	@strategy_entity_id varchar(100), 
  	@book_entity_id varchar(100), @discount_option char(1), 
  	@summary_option char(1), 
 	@prior_months int,
 	@drill_down_level int, --1 means main report --2 means second level drill down --3 means third level drill down
 	@drill_down_column int,
 	@drill_down_value varchar(250)
 
 set @as_of_date='2009-07-31'
 set  @sub_entity_id =  '58'
 set  @strategy_entity_id = null
 set @book_entity_id  = null
 --set  @strategy_entity_id = 79
 --set  @sub_entity_id ='1'
 set  @discount_option ='d'
 set @summary_option ='s'
 set @strategy_entity_id = null
 set @prior_months = 0
 set @drill_down_level = 2
 set @drill_down_column = 5 --3
 --set @drill_down_value = 'Econnergy'
 set @drill_down_value = 'Coal'
 
 drop table #ssbm
 drop table #temp
 drop table #sd_levels
 drop table #report2
 drop table #aoci_pnl_changes
 drop table #sdp
 drop table #cdp
 drop table #deal_fv_level
*/
 -----end of test
 /*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR (8000)
 
DECLARE @user_login_id VARCHAR (50)
 
DECLARE @sql_paging VARCHAR (8000)
 
DECLARE @is_batch BIT
 
SET @str_batch_table = ''
 
SET @user_login_id = dbo.FNADBUser() 
 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1
 
BEGIN
 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
 
END
 
/*******************************************1st Paging Batch END**********************************************/

Declare @Sql_Where varchar(8000)
Declare @Sql_Select varchar(8000)
Declare @Sql_Select2 varchar(8000)
Declare @beginning_date varchar(20)

if @prior_months is null
	set @prior_months = 12

SET @sql_Where = ''            
CREATE TABLE #ssbm
(fas_book_id INT, hedge_type_value_id INT, sub_name varchar(250) COLLATE DATABASE_DEFAULT, stra_name varchar(250) COLLATE DATABASE_DEFAULT, book_name varchar(250) COLLATE DATABASE_DEFAULT)
    
       
----------------------------------            
SET @Sql_select=            
'INSERT INTO #ssbm SELECT   distinct book.entity_id fas_book_id, hedge_type_value_id,
		sub.entity_name, stra.entity_name, book.entity_name
FROM            
	portfolio_hierarchy book INNER JOIN
	portfolio_hierarchy stra ON  book.parent_entity_id = stra.entity_id INNER JOIN
	portfolio_hierarchy sub ON  stra.parent_entity_id = sub.entity_id INNER JOIN
	fas_strategy fs ON fs.fas_strategy_id = stra.entity_id 
WHERE 1 = 1 '            

IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND sub.entity_id IN  ( ' + @sub_entity_id + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'            
 IF @book_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            

EXEC (@Sql_Select)            


           
-- get all levels or fair value categories
CREATE TABLE #sd_levels(            
 seq_no int identity,            
 value_id int,            
 code varchar(50) COLLATE DATABASE_DEFAULT,            
 [description] varchar(250) COLLATE DATABASE_DEFAULT
)            

insert into #sd_levels
select value_id, code, [description]
from static_data_value where type_id = 10094
order by value_id 

declare @max_value_id int
select @max_value_id = max(value_id) from #sd_levels

IF @prior_months > 0 
	select @beginning_date = dbo.FNAGetSQLStandardDate(max(as_of_date)) from 
	measurement_run_dates where as_of_date <= dbo.FNALastDayInDate(dateadd(mm, -1*@prior_months, @as_of_date))
ELSE
	SET @beginning_date = NULL


IF @beginning_date IS NULL --OR @prior_months = 0
	SET @beginning_date= '1900-01-01'


select [source_deal_header_id], [term_start], [term_end], [Leg], [pnl_as_of_date],
      [und_pnl], [und_intrinsic_pnl], [und_extrinsic_pnl], [dis_pnl], [dis_intrinsic_pnl],
      [dis_extrinisic_pnl], [pnl_source_value_id], [pnl_currency_id], [pnl_conversion_factor],
      [pnl_adjustment_value], [deal_volume], [create_user], [create_ts], [update_user], [update_ts],
	  cast(NULL as varchar(250)) sub_name,  cast(NULL as varchar(250))  stra_name, cast(NULL as varchar(250))  book_name
into #sdp from source_deal_pnl  where 1 = 2

select * into #cdp from calcprocess_deals  where 1 = 2



set @Sql_Select = 'insert into #sdp 
		select	sdp.[source_deal_header_id], [term_start], [term_end], [Leg], [pnl_as_of_date],
				[und_pnl], [und_intrinsic_pnl], [und_extrinsic_pnl], [dis_pnl], [dis_intrinsic_pnl],
				[dis_extrinisic_pnl], [pnl_source_value_id], [pnl_currency_id], [pnl_conversion_factor],
				[pnl_adjustment_value], [deal_volume], sdp.[create_user], sdp.[create_ts], sdp.[update_user], sdp.[update_ts],
				s.sub_name, s.stra_name, s.book_name 
	 
		from ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_pnl') + ' sdp INNER JOIN 
			source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id INNER JOIN
			source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND
						ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND
						ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND
						ssbm.source_system_book_id4 = sdh.source_system_book_id4 INNER JOIN
			#ssbm s ON s.fas_book_id = ssbm.fas_book_id 
		where (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 400 OR (s.hedge_type_value_id = 151 AND  isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 401)) AND
			  sdp.term_start > ''' +  @as_of_date + ''' AND pnl_as_of_date = ''' +  @as_of_date + ''''

	exec(@Sql_Select)


	set @Sql_Select = 'insert into #cdp select cd.* from ' + dbo.FNAGetProcessTableName(@as_of_date, 'calcprocess_deals') + ' cd INNER JOIN
		#ssbm ssbm ON ssbm.fas_book_id = cd.fas_book_id where (hedge_or_item = ''h'' OR (cd.hedge_type_value_id = 151 AND hedge_or_item = ''i''))
		AND cd.term_start > ''' +  @as_of_date + ''' AND as_of_date = ''' +  @as_of_date + ''''

	exec(@Sql_Select)	

if @beginning_date <> '1900-01-01'
BEGIN
	set @Sql_Select = 'insert into #sdp 
		select	sdp.[source_deal_header_id], [term_start], [term_end], [Leg], [pnl_as_of_date],
				[und_pnl], [und_intrinsic_pnl], [und_extrinsic_pnl], [dis_pnl], [dis_intrinsic_pnl],
				[dis_extrinisic_pnl], [pnl_source_value_id], [pnl_currency_id], [pnl_conversion_factor],
				[pnl_adjustment_value], [deal_volume], sdp.[create_user], sdp.[create_ts], sdp.[update_user], sdp.[update_ts],
				s.sub_name, s.stra_name, s.book_name  
	 
		from ' + dbo.FNAGetProcessTableName(@beginning_date, 'source_deal_pnl') + ' sdp INNER JOIN 
			source_deal_header sdh ON sdh.source_deal_header_id = sdp.source_deal_header_id INNER JOIN
			source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1 AND
						ssbm.source_system_book_id2 = sdh.source_system_book_id2 AND
						ssbm.source_system_book_id3 = sdh.source_system_book_id3 AND
						ssbm.source_system_book_id4 = sdh.source_system_book_id4 INNER JOIN
			#ssbm s ON s.fas_book_id = ssbm.fas_book_id 
		where (isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 400 OR (s.hedge_type_value_id = 151 AND  isnull(sdh.fas_deal_type_value_id,ssbm.fas_deal_type_value_id) = 401)) AND
			  sdp.term_start > ''' +  @as_of_date + ''' AND pnl_as_of_date = ''' +  @beginning_date + ''''

	exec(@Sql_Select)

	set @Sql_Select = 'insert into #cdp select cd.* from ' + dbo.FNAGetProcessTableName(@beginning_date, 'calcprocess_deals') + ' cd INNER JOIN
			#ssbm ssbm ON ssbm.fas_book_id = cd.fas_book_id where (hedge_or_item = ''h'' OR (cd.hedge_type_value_id = 151 AND hedge_or_item = ''i''))
			AND cd.term_start > ''' +  @as_of_date + ''' AND  as_of_date = ''' +  @beginning_date + ''''

	exec(@Sql_Select)	

END



select source_deal_header_id, term_start, max(fv_level) fv_level 
into #deal_fv_level
from (
select sdd.source_deal_header_id, sdd.curve_id, sdd.term_start, 
		sdd.fv_level fv_level_header, coalesce(pcfm.fv_reporting_group_id, sdd.fv_level, @max_value_id) fv_level,
		sdd.month_no  
from 
(select source_deal_header_id from #sdp where pnl_as_of_date = @as_of_date group by source_deal_header_id) sdp INNER JOIN
(
select	sdd.source_deal_header_id, sdd.curve_id, sdd.term_start, fv_level,
		datediff(mm, @as_of_date, sdd.term_start) month_no  
from source_deal_detail sdd inner join
source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
where sdd.term_start > @as_of_date
) sdd ON sdp.source_deal_header_id = sdd.source_deal_header_id left outer join
(
select source_curve_def_id source_curve_def_id1, max(isnull(effective_date, '1900-01-01')) max_effective_date 
from price_curve_fv_mapping where isnull(effective_date, '1900-01-01') <= @as_of_date
group by source_curve_def_id
) mef  on mef.source_curve_def_id1 = sdd.curve_id left outer join
price_curve_fv_mapping pcfm ON pcfm.source_curve_def_id = sdd.curve_id and
		mef.max_effective_date = isnull(pcfm.effective_date, '1900-01-01') and
		sdd.month_no BETWEEN pcfm.from_no_of_months AND pcfm.to_no_of_months
) d group by source_deal_header_id, term_start

--print @beginning_date
--print dbo.FNALastDayInDate(dateadd(mm, -1*@prior_months, @as_of_date))
declare @st varchar(8000)
create table  #temp (
Sub varchar(100) COLLATE DATABASE_DEFAULT,
Strategy varchar(100) COLLATE DATABASE_DEFAULT, 
Book varchar(100) COLLATE DATABASE_DEFAULT, 
[description] varchar(250) COLLATE DATABASE_DEFAULT,
source_deal_header_id int, 
as_of_date datetime, 
term_start datetime,
fv_level int, 
fv_level_desc varchar(250) COLLATE DATABASE_DEFAULT, 
pnl float,
total_aoci float, 
total_pnl float
)

set @st='insert into #temp 
	select 	isnull(deals.sub_name, sdp.sub_name) Sub, isnull(deals.stra_name, sdp.stra_name) Strategy, isnull(deals.book_name, sdp.book_name) Book, 
	case when ('''+@summary_option+''' = ''a'') then isnull(deals.sub_name, sdp.sub_name)
	     when ('''+@summary_option +'''= ''b'') then isnull(deals.sub_name, sdp.sub_name) + ''/'' + isnull(deals.stra_name, sdp.stra_name) 
	     when ('''+@summary_option +'''= ''c'') then isnull(deals.sub_name, sdp.sub_name) + ''/'' + isnull(deals.stra_name, sdp.stra_name) + ''/'' + isnull(deals.book_name, sdp.book_name)
	     else isnull(deals.book_name, sdp.book_name) end [description],
	sdp.source_deal_header_id, sdp.as_of_date, sdp.term_start, ISNULL(dfl.fv_level, -1) fv_level,
	isnull(sdv_l.description, ''Undefined Category'') fv_level_desc, 
	isnull(sdp.deal_pnl, 0) pnl,
 	isnull(total_aoci, 0) total_aoci, 
 	isnull(sdp.deal_pnl, 0) - isnull(total_aoci, 0) total_pnl
from 
(select source_deal_header_id, term_start, pnl_as_of_date as_of_date, sum(' + CASE WHEN (@discount_option='d') THEN 'dis_pnl' ELSE 'und_pnl' END + ' + pnl_adjustment_value) deal_pnl, 
 max(sub_name) sub_name, max(stra_name) stra_name, max(book_name) book_name
from 
#sdp source_deal_pnl where pnl_as_of_date = '''+@as_of_date+''' OR pnl_as_of_date = '''+@beginning_date+'''
group by source_deal_header_id, term_start, pnl_as_of_date
) 
sdp LEFT OUTER JOIN
( 
select source_deal_header_id, as_of_date, term_start hedge_term_start, ' + 
	CASE WHEN (@discount_option='d') THEN ' sum(final_dis_pnl_remaining) rel_pnl, sum(d_aoci) total_aoci, sum(d_pnl_ineffectiveness + d_extrinsic_pnl + d_pnl_mtm) total_pnl, '
	ELSE ' sum(final_und_pnl_remaining) rel_pnl, sum(u_aoci) total_aoci, sum(u_pnl_ineffectiveness + u_extrinsic_pnl + u_pnl_mtm) total_pnl, ' END
+ '      
	   max(sub.entity_name) sub_name, max(stra.entity_name) stra_name, max(book.entity_name) book_name
from #cdp cd INNER JOIN
	 portfolio_hierarchy sub ON sub.entity_id = cd.fas_subsidiary_id INNER JOIN
	 portfolio_hierarchy stra ON stra.entity_id = cd.fas_strategy_id  INNER JOIN
	 portfolio_hierarchy book ON book.entity_id = cd.fas_book_id 
group by source_deal_header_id, as_of_date, term_start
) deals on sdp.source_deal_header_id = deals.source_deal_header_id and
	sdp.term_start = deals.hedge_Term_start and
	deals.as_of_date = sdp.as_of_date LEFT OUTER JOIN
#deal_fv_level dfl ON dfl.source_deal_header_id = sdp.source_deal_header_id AND
			dfl.term_start = sdp.term_start LEFT OUTER JOIN 
static_data_value sdv_l on sdv_l.value_id = ISNULL(dfl.fv_level, -1)
'

--print(@st)
exec(@st)

IF @drill_down_level = 1
BEGIN
	DECLARE @value_id int, @code varchar(50), @desc varchar(250)
	DECLARE @entity_id varchar(100)
	DECLARE a_cursor CURSOR FOR
	select value_id, code, [description]
	from #sd_levels
	order by seq_no
	
	OPEN a_cursor
	
	FETCH NEXT FROM a_cursor
	INTO @value_id, @code, @desc 
	
	SET @Sql_Select = 'select [description] [Description], CAST (sum(pnl) AS NUMERIC(38,' + @round_value + ')) [' + 
		dbo.FNADateFormat(@as_of_date) + '] '
	
	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 
	
	-- 	select 	@value_id, @code, @desc 
	
		IF @max_value_id <> @value_id
			SET @Sql_Select = @Sql_Select +	
				', case when (fv_level = ' + cast(@value_id as varchar) + ') then CAST (sum(pnl) AS NUMERIC(38,' + @round_value + ')) else 0 end [' + cast(@value_id as varchar) + '] '
		ELSE	
			SET @Sql_Select = @Sql_Select +	
				', case when (fv_level = ' + cast(@value_id as varchar) + ' OR fv_level = -1) then CAST (sum(pnl) AS NUMERIC(38,' + @round_value + ')) else 0 end [' + cast(@value_id as varchar) + '] '
	
		FETCH NEXT FROM a_cursor
		INTO @value_id, @code, @desc 
	
	END -- end book
	CLOSE a_cursor
	DEALLOCATE  a_cursor
	
	SET @Sql_Select = @Sql_Select +
	'from #temp where as_of_date = ''' + @as_of_date + ''' and term_start > ''' + @as_of_date  + '''
	group by [description], fv_level '
	
-- 	EXEC spa_print @Sql_Select	
	
	DECLARE b_cursor CURSOR FOR
	select value_id, code, [description]
	from #sd_levels
	order by seq_no
	
	OPEN b_cursor
	
	FETCH NEXT FROM b_cursor
	INTO @value_id, @code, @desc 
	
	SET @Sql_Select2 = 
	'select [Description], sum([' + dbo.FNADateFormat(@as_of_date) + ']) as ['+ dbo.FNADateFormat(@as_of_date) + ']'
	
	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 
	
	-- 	select 	@value_id, @code, @desc 
	
		SET @Sql_Select2 = @Sql_Select2 +	
			', sum([' + cast(@value_id as varchar) + ']) as ['  + @desc  + ']'
	
		FETCH NEXT FROM b_cursor
		INTO @value_id, @code, @desc 
	
	END -- end book
	CLOSE b_cursor
	DEALLOCATE  b_cursor
	
	SET @Sql_Select2 = @Sql_Select2  + @str_batch_table + ' from (' + @Sql_select + ') x group by [Description]'
	
	EXEC spa_print @Sql_Select2
	
	exec (@Sql_Select2)

END
IF @drill_down_level = 2
BEGIN
	declare @sel_level int
	set @drill_down_column = @drill_down_column - 2
	select @sel_level = value_id from #sd_levels where seq_no = @drill_down_column	


	CREATE TABLE #report2
	(
	seq_no int identity,
	clm1 varchar(1250) COLLATE DATABASE_DEFAULT, 
	clm2 varchar(1250) COLLATE DATABASE_DEFAULT 
	)
	
	select 	beginning.term_start, 
		sum(isnull(ending.total_aoci, 0) - isnull(beginning.total_aoci, 0)) aoci_changes,
		sum(isnull(ending.total_pnl, 0) - isnull(beginning.total_pnl, 0)) pnl_changes
	into #aoci_pnl_changes
	from 
	(select source_deal_header_id, term_start, fv_level, sum(isnull(total_aoci, 0)) total_aoci,
		sum(isnull(total_pnl, 0)) total_pnl
	from #temp where 
	as_of_date = @beginning_date 
	and term_start > @beginning_date
	and [description] = @drill_down_value 
--	and [description] LIKE @drill_down_value + '%'
	group by source_deal_header_id, term_start, fv_level) beginning
	full outer join
	(select source_deal_header_id, term_start, fv_level, sum(isnull(total_aoci, 0)) total_aoci,
		sum(isnull(total_pnl, 0)) total_pnl
	from #temp where 
	as_of_date = @as_of_date 
	and term_start >= dbo.FNAGetContractMonth(@as_of_date)
	and [description] = @drill_down_value 
--	and [description] LIKE @drill_down_value + '%'
	AND (#temp.fv_level = @sel_level OR #temp.fv_level = -1)

	group by source_deal_header_id, term_start, fv_level) ending ON
	beginning.source_deal_header_id = ending.source_deal_header_id and
	beginning.term_start = ending.term_start and
	beginning.fv_level = ending.fv_level
	group by beginning.term_start
	
--select * from #temp
--select * from #aoci_pnl_changes
	DECLARE @clm_name VARCHAR(100)

--	insert into #report2
--	select '' clm1, ( '<b>' + (select [description] from #sd_levels where seq_no = @drill_down_column) + ' for ' + isnull(@drill_down_value, '') + '</b>') clm_2

	SELECT @clm_name=[description]+ ' for ' + isnull(@drill_down_value, '') from #sd_levels where seq_no = @drill_down_column
 
	insert into #report2
	Select 'Beginning Balance', cast (round(isnull((select sum(pnl) from #temp 
						where 	as_of_date = @beginning_date and 
							term_start > @beginning_date and
							fv_level = @sel_level and
							[description] =  @drill_down_value 
--							[description] LIKE  @drill_down_value + '%'
							), 0), 2) as varchar)
	
	insert into #report2
	Select '  Total gains or losses (realized/unrealized)', NULL
	
	insert into #report2
	Select '      Included in earnings (or changes in net assets)', cast (round(isnull((select sum(isnull(pnl_changes, 0)) from #aoci_pnl_changes), 0), 2) as varchar)
	
	insert into #report2
	Select '      Included in other comprehensive income', cast (round(isnull((select sum(isnull(aoci_changes, 0)) from #aoci_pnl_changes), 0), 2) as varchar)
	
	
	insert into #report2
	Select '  Purchases, issuances, settlements ', cast(round(isnull((select sum(isnull(pnl, 0)) new_deals_pnl
							from #temp 
							where 	fv_level = @sel_level and as_of_date = @as_of_date and 
								[description] = @drill_down_value and
--								[description] LIKE @drill_down_value + '%' and
								term_start > @as_of_date and 	
							source_deal_header_id not in 
							(select distinct source_deal_header_id 
							from #temp 
							where as_of_date = @beginning_date and 
							[description] = @drill_down_value 
--							[description] LIKE @drill_down_value + '%'
							)), 0), 2) as varchar)
	
	insert into #report2
	Select '  Transfers in and/or out of Level ', cast (round(isnull((select sum(isnull(pnl, 0)) level_in_out_pnl
							from #temp 
							inner join (select distinct source_deal_header_id, fv_level 
									from #temp 
									where as_of_date = @beginning_date and 
									[description] = @drill_down_value 
--									[description] LIKE @drill_down_value + '%'
									) pre
							on pre.source_deal_header_id = #temp.source_deal_header_id and
							   pre.fv_level <> #temp.fv_level
							where 	#temp.fv_level = @sel_level and as_of_date = @as_of_date and 
								[description] = @drill_down_value  and
--								[description] LIKE @drill_down_value  + '%' and
								term_start > @as_of_date), 0), 2) as varchar)
	
	
	insert into #report2
	Select 'Ending Balance', cast (round(isnull((select sum(isnull(pnl, 0)) from #temp 
						where 	(fv_level = @sel_level OR fv_level = -1) and as_of_date = @as_of_date and 
							term_start > @as_of_date and
							[description] = @drill_down_value 
--							[description] LIKE @drill_down_value + '%'
							), 0), 2) as varchar)
	
	
	insert into #report2
	Select 'Total amount of total gains or losses for the period included in earnings (or changes in net assets) ' +
		' attributable to the change in unrealized gains or losses relating to assets still held at the reporting date', 
			cast (round(isnull((select sum(isnull(pnl_changes, 0)) from #aoci_pnl_changes where term_start > @as_of_date), 0), 2) as varchar)
	


-- 	set @Sql_Select = ' select clm1 as [ ], clm2 as [' + (select [description] from #sd_levels where seq_no = @drill_down_column) + ' for ' + isnull(@drill_down_value, '')  + '] from #report2
-- 	order by seq_no'

	exec('select clm1 [Items], clm2 ['+@clm_name+'] ' + @str_batch_table + ' from #report2	order by seq_no')
	exec (@Sql_Select)
	

END

/*******************************************2nd Paging Batch START**********************************************/
--update time spent and batch completion message in message board
 
IF @is_batch = 1
 
BEGIN
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_Create_fas157_Disclosure_Report', 'Fair Value Disclosure Report') --TODO: modify sp and report name
 
	EXEC (@str_batch_table)
 
	RETURN
 
END
