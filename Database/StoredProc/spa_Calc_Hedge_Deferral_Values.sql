
GO

IF OBJECT_ID(N'spa_Calc_Hedge_Deferral_Values', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_Calc_Hedge_Deferral_Values]

----- EXEC spa_Calc_Hedge_Deferral_Values '2010-10-01', 202, null, null, null, 2, null--'14'
Go
create PROCEDURE [dbo].[spa_Calc_Hedge_Deferral_Values](
	@as_of_date varchar(20),
	@sub_entity_id varchar(500),
	@strategy_entity_id varchar(500)=null,
	@book_entity_id varchar(500)=null,
	@term_start varchar(20)=null, 
    @allocation_approach INT = 1,  -- 1 even allocation, 2 item volume weighted allcoation
    @hedge_counterparty VARCHAR(500)=NULL,
    @item_counterparty VARCHAR(500)=NULL,
	@batch_process_id varchar(100)=NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
)
as

---------------TESTING BEGINS HERE
/*
DECLARE @sub_entity_id varchar(500)
DECLARE @strategy_entity_id varchar(500)
DECLARE @book_entity_id varchar(500)
DECLARE @as_of_date varchar(20)
DECLARE @term_start varchar(20)
DECLARE @allocation_approach INT
DECLARE @hedge_counterparty VARCHAR(500)
DECLARE @item_counterparty VARCHAR(500)
DECLARE @batch_process_id varchar(100)

set @sub_entity_id=202
set @strategy_entity_id=null --150
set @book_entity_id=null --158
set @as_of_date='2010-10-01'
set @term_start=null
set @hedge_counterparty = null --'1' --'14'
set @item_counterparty = null
SET @allocation_approach = 2

drop table #books
drop table #results1
drop table #t_values
drop table #pnl_def
drop table #alloc_months
drop table #final_alloc
drop table #item_volume
drop table #item_total_volume
drop table #error_deals
drop table #cpty
drop table #source_deal_settlement

------ select * from hedge_deferral_values
------ select * from #final_alloc
------ delete from hedge_Deferral_values
--*/
---------TESTING ENDS HERE

If @allocation_approach is null
	set @allocation_approach = 1

--Start tracking time for Elapse time
DECLARE @begin_time DATETIME
SET @begin_time = getdate()

DECLARE @user_login_id VARCHAR(50)
SET @user_login_id = dbo.FNADBUser() 

IF @batch_process_id IS NULL
	SET @batch_process_id = dbo.FNAGetNewID()

DECLARE @Sql_SelectB VARCHAR(5000)        
DECLARE @Sql_WhereB VARCHAR(5000)        
DECLARE @assignment_type int        
declare @desc varchar(5000)
DECLARE @print_diagnostic INT
DECLARE @log_time datetime
DECLARE @pr_name VARCHAR(5000)
DECLARE @log_increment 	int
        
set @print_diagnostic=1
        
SET @Sql_WhereB = ''        

If @print_diagnostic = 1
begin
	set @log_increment = 1
	print '******************************************************************************************'
	print '********************START &&&&&&&&&[spa_calc_hedge_deferral_values]**********'
end


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

CREATE TABLE #books (fas_book_id int) 

--if @pnl_source_value_id is null
--	set @pnl_source_value_id=4500

SET @Sql_SelectB=        
'INSERT INTO  #books     
SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN
            Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
            source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         
WHERE 1 = 1
'   
              
IF @sub_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
 IF @strategy_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
 IF @book_entity_id IS NOT NULL        
  SET @Sql_WhereB = @Sql_WhereB + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
        
SET @Sql_SelectB=@Sql_SelectB+@Sql_WhereB        
              
EXEC (@Sql_SelectB)

CREATE INDEX indx_books ON #books(fas_book_id)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of Collecting Books *****************************'	
END


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

CREATE TABLE #cpty (counterparty_id INT, hedge_or_item varchar(1) COLLATE DATABASE_DEFAULT)

If @hedge_counterparty IS NOT NULL
	EXEC('insert into #cpty select distinct source_counterparty_id, ''h'' from source_counterparty where source_counterparty_id in (' + @hedge_counterparty + ')')
Else 
	EXEC('insert into #cpty select distinct source_counterparty_id, ''h'' from source_counterparty ')

If @item_counterparty IS NOT NULL 
	EXEC('insert into #cpty select distinct source_counterparty_id, ''i'' from source_counterparty where source_counterparty_id in (' + @item_counterparty + ')')
Else 
	EXEC('insert into #cpty select distinct source_counterparty_id, ''i'' from source_counterparty ')

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of Collecting Counterparty*****************************'	
END


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

select      fh.eff_test_profile_id, max(eff_test_name) eff_test_name, fd.hedge_or_item, sdh.source_deal_header_id, cast(max(sdh.deal_id) as varchar) deal_id,
            max(fd.strip_months) strip_from, max(fd.strip_year_overlap) lag, max(fd.roll_forward_year) strip_to,
            min(sdd.term_start) min_term, max(sdd.term_start) max_term, MAX(sdd.curve_id) curve_id, MAX(sdh.counterparty_id) counterparty_id
into #results1 
from #books b inner join fas_eff_hedge_rel_type fh on fh.fas_book_id = b.fas_book_id inner join
fas_eff_hedge_rel_type_detail fd ON fd.eff_test_profile_id=fh.eff_test_profile_id inner join
source_system_book_map sb on sb.book_deal_type_map_id = fd.book_deal_type_map_id inner join
source_deal_header sdh on     sdh.source_system_book_id1 = sb.source_system_book_id1 and 
                                          sdh.source_system_book_id2 = sb.source_system_book_id2 and
                                          sdh.source_system_book_id3 = sb.source_system_book_id3 and
                                          sdh.source_system_book_id4 = sb.source_system_book_id4 inner join
source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.curve_id = fd.source_curve_def_id INNER JOIN
#cpty ch ON sdh.counterparty_id = ch.counterparty_id and fd.hedge_or_item = ch.hedge_or_item 
where	isnull(fh.profile_active, 'n') ='y' 
group by fh.eff_test_profile_id, fd.hedge_or_item, sdh.source_deal_header_id

-- select * from #results1 where source_DEAl_header_id=3787
-- select * from #cpty_hedge
-- select * from #cpty_item

CREATE INDEX indx_results1 ON #results1(source_deal_header_id)
CREATE INDEX indx_results2 ON #results1(eff_test_profile_id)
CREATE INDEX indx_results3 ON #results1(hedge_or_item)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of Collecting #results1 rel type*****************************'	
END


DECLARE @error_count INT

If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end


select source_deal_header_id, deal_id, count(*) total_count
into #error_deals
from #results1
group by source_deal_header_id, deal_id
having count(*) > 1

insert into MTM_TEST_RUN_LOG(process_id,code,module,source,type,[description],nextsteps)  
select	@batch_process_id, '<font color="red">Error</font>', 'Hedge Deferral Calc', 'spa_Calc_Hedge_Deferral_Values', 
		'Error',
		'A deal is defined part of multiple deferral rules  ' +  
		' Deal: ' + CAST(r.source_deal_header_id as varchar) + ' (Ref ID: ' + r.deal_id + ')' +
		' Deferral Rules: ' + dbo.FNAHyperLinkText(10232000, r.eff_test_name, cast(r.eff_test_profile_id as varchar))   description,
	'Please resolve conflicts.'
from #error_deals a INNER JOIN
	#results1 r on r.source_deal_header_id = a.source_deal_header_id

Select @error_count = count(*) from (
select distinct r.source_deal_header_id from 
#results1 r inner join
#error_deals e oN r.source_deal_header_id = e.source_deal_header_id 		
where r.hedge_or_item = 'h') a

DELETE #results1
from #results1 r inner join
(
select distinct r.eff_test_profile_id from 
#results1 r inner join
#error_deals e oN r.source_deal_header_id = e.source_deal_header_id
) d ON d.eff_test_profile_id = r.eff_test_profile_id		

-- select * from #results1

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of processing error deals*****************************'	
END

If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

select	sds.source_deal_header_id, sds.term_start, sds.term_end, sum(isnull(fin_volume, 0)) volume, 
		max(settlement_currency_id) settlement_currency_id, max(volume_uom) volume_uom, 
		SUM(isnull(settlement_amount, 0)) settlement_amount, SUM(isnull(market_value, 0)) market_value, 
		SUM(isnull(contract_value, 0)) contract_value 
into #source_deal_settlement
from #results1 r inner join
source_deal_settlement sds on sds.source_deal_header_id = r.source_deal_header_id
AND (sds.set_type = 'f' AND sds.as_of_date =@as_of_date OR ( sds.set_type = 's' AND @as_of_date>=sds.term_end))
GROUP BY sds.source_deal_header_id, sds.term_start, sds.term_end


CREATE INDEX indx_source_deal_settlement1 ON #source_deal_settlement (source_deal_header_id)
CREATE INDEX indx_source_deal_settlement2 ON #source_deal_settlement (term_start)
CREATE INDEX indx_source_deal_settlement3 ON #source_deal_settlement (term_end)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of collecting settlement values*****************************'	
END

If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end


create table #t_values(eff_test_profile_id int, eff_test_name varchar(200) COLLATE DATABASE_DEFAULT, term_start datetime, und_mtm float, dis_mtm float,
                  strip_from int, lag int, strip_to int, min_term datetime, max_term datetime,
                  source_deal_header_id INT, deal_id varchar(100) COLLATE DATABASE_DEFAULT, 
                  pnl_currency_id INT, deal_volume FLOAT, 
                  market_value FLOAT, contract_value FLOAT, dis_market_value FLOAT, dis_contract_value FLOAT)

insert into #t_values
select      r.eff_test_profile_id, r.eff_test_name, 
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.term_start ELSE
				coalesce(sds.term_start, sdp.term_start) END term_start, 				
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.und_pnl --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.und_pnl , 0) + ISNULL(sds.settlement_amount, 0)
			ELSE coalesce(sds.settlement_amount, sdp.und_pnl) --COMPLETELY SETTLED
			END und_mtm,            
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.dis_pnl --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.dis_pnl , 0) + ISNULL(sds.settlement_amount, 0)
			ELSE coalesce(sds.settlement_amount, sdp.dis_pnl) --COMPLETELY SETTLED
			END dis_mtm,            				            
            r.strip_from, r.lag, r.strip_to, 
            --isnull(item.min_term, hedge.min_term) min_term, 
            --isnull(item.max_term, hedge.max_term) max_term, 
            isnull(item.min_term, '1900-01-01') min_term, 
            isnull(item.max_term, '5000-01-01') max_term, 
            r.source_deal_header_id, r.deal_id,
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.pnl_currency_id ELSE
				coalesce(sds.settlement_currency_id, sdp.pnl_currency_id) END pnl_currency_id,				
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.deal_volume --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.deal_volume, 0) + ISNULL(sds.volume, 0)
			ELSE coalesce(sds.volume, sdp.deal_volume) --COMPLETELY SETTLED
			END deal_volume,                        
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.market_value --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.market_value, 0) + ISNULL(sds.market_value, 0)
			ELSE coalesce(sds.market_value, sdp.market_value) --COMPLETELY SETTLED
			END market_value,                        
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.contract_value --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.contract_value, 0) + ISNULL(sds.contract_value, 0)
			ELSE coalesce(sds.contract_value, sdp.contract_value) --COMPLETELY SETTLED
			END contract_value,            
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.dis_market_value --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.dis_market_value, 0) + ISNULL(sds.market_value, 0)
			ELSE coalesce(sds.market_value, sdp.dis_market_value) --COMPLETELY SETTLED
			END dis_market_value,  			                      
			CASE WHEN (sdp.term_start is not null and sdp.term_start > @as_of_date) THEN sdp.dis_contract_value --COMPLETELY FORWARD
				 WHEN (CONVERT(varchar(7), coalesce(sds.term_start, sdp.term_start), 120) = CONVERT(varchar(7), @as_of_date, 120)) THEN --CURRENT MONTH
					isnull(sdp.dis_contract_value, 0) + ISNULL(sds.contract_value, 0)
			ELSE coalesce(sds.contract_value, sdp.dis_contract_value) --COMPLETELY SETTLED
			END dis_contract_value

from #results1 r INNER JOIN
source_deal_detail sdd ON sdd.leg = 1 AND sdd.source_deal_header_id = r.source_deal_header_id LEFT JOIN 
(select eff_test_profile_id, min(min_term) min_term, max(max_term) max_term from #results1 
where hedge_or_item = 'i'
group by eff_test_profile_id) item on item.eff_test_profile_id = r.eff_test_profile_id LEFT JOIN
(select eff_test_profile_id, min(min_term) min_term, max(max_term) max_term from #results1 
where hedge_or_item = 'h'
group by eff_test_profile_id) hedge on hedge.eff_test_profile_id = r.eff_test_profile_id LEFT JOIN
source_deal_pnl sdp on sdp.source_deal_header_id=r.source_deal_header_id and 
	  sdp.term_start = sdd.term_start and sdp.term_end = sdd.term_end and 
      CASE WHEN (sdp.pnl_source_value_id = 775) THEN 4500 ELSE sdp.pnl_source_value_id END = 4500 and
		sdp.pnl_as_of_date = @as_of_date LEFT JOIN
#source_deal_settlement sds on sds.source_deal_header_id=r.source_deal_header_id and 
	  sds.term_start = sdd.term_start and sds.term_end = sdd.term_end  		
where r.hedge_or_item='h' AND
	(@term_start IS NULL OR (@term_start IS NOT NULL AND coalesce(sds.term_start, sdp.term_start) >= @term_start))


CREATE INDEX indx_t_values1 ON #t_values (strip_from)
CREATE INDEX indx_t_values2 ON #t_values (lag)
CREATE INDEX indx_t_values3 ON #t_values (strip_to)
CREATE INDEX indx_t_values4 ON #t_values (term_start)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of collecting MTM Values #t_values*****************************'	
END


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

-- select * from #t_values where source_deal_header_id=3787 order by term_Start
SELECT	DISTINCT 
		t.source_deal_header_id, t.deal_id, t.eff_test_profile_id, t.eff_test_name, 
		t.term_start cash_flow_term,
		r.strip_from, r.lag, r.strip_to,
		CAST(CONVERT(VARCHAR(5),DATEADD(MONTH,ABS(r.pricing_term),t.term_start),120)+CAST(phy_month AS VARCHAR)+'-01' AS DATETIME) pnl_term,
		t.dis_mtm, t.und_mtm, t.pnl_currency_id, t.deal_volume, t.market_value, t.contract_value, t.dis_market_value, t.dis_contract_value
into #pnl_def
FROM position_break_down_rule r
INNER JOIN #t_values t ON r.strip_from=t.strip_from AND r.lag=t.lag AND t.strip_to=r.strip_to 
AND MONTH(DATEADD(MONTH,ABS(r.pricing_term),t.term_start))=r.phy_month
WHERE CAST(CONVERT(VARCHAR(5),DATEADD(MONTH,ABS(r.pricing_term),t.term_start),120)+CAST(phy_month AS VARCHAR)+'-01' AS DATETIME)  
		between t.min_term and t.max_term
order BY term_start,pnl_term

-- select * from #pnl_def
CREATE INDEX indx_pnl_def1 ON #pnl_def (pnl_term)
CREATE INDEX indx_pnl_def2 ON #pnl_def (eff_test_profile_id)
CREATE INDEX indx_pnl_def3 ON #pnl_def (cash_flow_term)
CREATE INDEX indx_pnl_def4 ON #pnl_def (source_deal_header_id)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of collecting #pnl_def *****************************'	
END


CREATE TABLE #item_volume (eff_test_profile_id INT, pnl_term DATETIME, item_volume FLOAT)
CREATE TABLE #item_total_volume (eff_test_profile_id INT, source_deal_header_id INT, cash_flow_term DATETIME, total_item_volume FLOAT)


If @allocation_approach = 2
BEGIN

	If @print_diagnostic = 1
	begin
		set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
		set @log_increment = @log_increment + 1
		set @log_time=getdate()
		print @pr_name+' Running..............'
	end


	INSERT INTO #item_volume
	select r.eff_test_profile_id, sdd.term_start pnl_term, SUM(ISNULL(sdd.total_volume, sdd.deal_volume)) item_volume 
	from #results1 r inner join
		 source_deal_detail sdd on sdd.source_deal_header_id = r.source_deal_header_id
	where r.hedge_or_item = 'i' and sdd.physical_financial_flag = 'p'
	group by r.eff_test_profile_id, sdd.term_start

	INSERT INTO #item_total_volume
	select p.eff_test_profile_id, p.source_deal_header_id, p.cash_flow_term, SUM(i.item_volume) total_item_volume 
	from #pnl_def p inner join
		 #item_volume i on i.eff_test_profile_id = p.eff_test_profile_id AND
						   i.pnl_term = p.pnl_term
	group by p.eff_test_profile_id, p.source_deal_header_id, p.cash_flow_term

	If @print_diagnostic = 1
	BEGIN
		print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
		print '**************** End of collecting #item_volume *****************************'	
	END

END

--select * from #item_volume
--select * from #item_total_volume
--select * from #pnl_def
-- select * from #pnl_def
-- select * from #t_values
-- select * from #alloc_months

If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

select eff_test_profile_id, source_deal_header_id, cash_flow_term, count(*) allocation_months
into #alloc_months
from #pnl_def 
group by eff_test_profile_id, source_deal_header_id, cash_flow_term


CREATE INDEX indx_alloc_months1 ON #alloc_months (cash_flow_term)
CREATE INDEX indx_alloc_months2 ON #alloc_months (source_deal_header_id)
CREATE INDEX indx_alloc_months3 ON #alloc_months (eff_test_profile_id)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of collecting #alloc_months *****************************'	
END

declare @as_of_date_end datetime, @settle_date datetime

SET @as_of_date_end=dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1

IF @as_of_date_end=@as_of_date
	SET @settle_date=@as_of_date_end
ELSE
	SET @settle_date=cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME)-1
	
	
--------------*********** NEED TO SAVE SETTLEMENT VS FORWARD JUST LIKE IN CASH CURVE...
--select * from #item_volume
--select * from #item_total_volume
If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

select    @as_of_date as_of_date,
		  case when (p.cash_flow_term <= @settle_date) then 's' else 'f' end set_type,
		  p.eff_test_profile_id,
          p.source_deal_header_id,
          p.cash_flow_term, 
          p.pnl_term, 
          max(p.strip_from) strip_from, max(p.lag) lag, max(p.strip_to) strip_to,
          sum(und_mtm) und_mtm,
          sum(dis_mtm) dis_mtm,          
          sum(und_mtm * case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) und_pnl,
          sum(dis_mtm * case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) dis_pnl,
          MAX(case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end) per_alloc,
          --1/cast(MAX(a.allocation_months) as float) per_alloc,
          GETDATE() create_ts,
          dbo.FNADBUser() create_user,
          MAX(pnl_currency_id) pnl_currency_id,
          SUM(deal_volume* case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) deal_volume, 
          sum(market_value) market_value,
          sum(contract_value) contract_value,          
          sum(dis_market_value) dis_market_value,
          sum(dis_contract_value) dis_contract_value,                    
          sum(market_value * case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) market_value_pnl,
          sum(contract_value * case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) contract_value_pnl,
          sum(dis_market_value * case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) dis_market_value_pnl,
          sum(dis_contract_value * case when (iv.item_volume IS NULL) then (cast(1 as float)/a.allocation_months) else iv.item_volume/itv.total_item_volume end ) dis_contract_value_pnl
                    
into #final_alloc                   
from #pnl_def p inner join 
	 #alloc_months a on a.cash_flow_term = p.cash_flow_term and 
						a.source_deal_header_id=p.source_deal_header_id and
						a.eff_test_profile_id = p.eff_test_profile_id LEFT JOIN
	 #item_volume iv on iv.eff_test_profile_id = p.eff_test_profile_id and
						iv.pnl_term = p.pnl_term LEFT JOIN 
	 #item_total_volume itv on itv.eff_test_profile_id = p.eff_test_profile_id and
								itv.source_deal_header_id = p.source_deal_header_id and
								itv.cash_flow_term = p.cash_flow_term
group by p.eff_test_profile_id, p.pnl_term, p.source_deal_header_id, p.cash_flow_term

-- select* from #final_alloc
CREATE INDEX indx_final_alloc1 ON #final_alloc (source_deal_header_id)
CREATE INDEX indx_final_alloc2 ON #final_alloc (cash_flow_term)
CREATE INDEX indx_final_alloc3 ON #final_alloc (set_type)
CREATE INDEX indx_final_alloc4 ON #final_alloc (as_of_date)

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** End of collecting #final_alloc *****************************'	
END


If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

-- DELETE SETTLEMENT VALUES FOR SPECIFIC CASH FLOW TERM
delete hedge_deferral_values
from hedge_deferral_values h INNER JOIN
#final_alloc f ON	f.source_deal_header_id = h.source_deal_header_id AND 
					f.cash_flow_term = h.cash_flow_term AND
					f.set_type = h.set_type
WHERE h.set_type = 's'					

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** Deleting Settled existing values from  hedge_deferral_values *****************************'	
END

If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

-- DELETE all forward months
delete hedge_deferral_values
from hedge_deferral_values h INNER JOIN
#final_alloc f ON	f.source_deal_header_id = h.source_deal_header_id AND 
					f.as_of_date = h.as_of_date	
					--AND f.set_type = h.set_type			
WHERE h.set_type = 'f'					

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** Deleting Forward existing values from  hedge_deferral_values *****************************'	
END

If @print_diagnostic = 1
begin
	set @pr_name= 'sql_log_' + cast(@log_increment as varchar)
	set @log_increment = @log_increment + 1
	set @log_time=getdate()
	print @pr_name+' Running..............'
end

insert into hedge_deferral_values
select * from #final_alloc

If @print_diagnostic = 1
BEGIN
	print @pr_name+': '+cast(datediff(ss,@log_time,getdate()) as varchar) +'*************************************'
	print '**************** Inserting values from  hedge_deferral_values *****************************'	
END

DECLARE @saved_records  int
Select @saved_records = COUNT(*) FROM  (select distinct source_deal_header_id from #final_alloc) a

declare @status_type varchar(1) 

If ISNULL(@error_count, 0) > 0 
	set @status_type = 'e'
Else
	set @status_type = 's'

declare @e_time_s int
declare @e_time_text_s varchar(100)
set @e_time_s = datediff(ss,@begin_time,getdate())
set @e_time_text_s = cast(cast(@e_time_s/60 as int) as varchar) + ' Mins ' + cast(@e_time_s - cast(@e_time_s/60 as int) * 60 as varchar) + ' Secs'

If @status_type = 'e'
	SET @desc = '<a target="_blank" href="' +  './dev/spa_html.php?__user_name__=' + @user_login_id + 
		'&spa=exec spa_get_mtm_test_run_log ''' + @batch_process_id + '''' + '">' + 
	'Errors Found while calculating hedge deferral as of date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) + 
	' Saved Deal Count: ' + CAST(ISNULL(@saved_records, 0) as varchar) + '  Error Deal Count: ' + CAST(ISNULL(@error_count, 0) as varchar) + 
	' [Elapse time: ' + @e_time_text_s + ']' + 
	'.</a>'
Else
	SET @desc = 'Hedge deferral calculation process completed for as of date ' + isnull(dbo.FNADateFormat(@as_of_date), @as_of_date) +
	' Saved Deal Count: ' + CAST(ISNULL(@saved_records, 0) as varchar) + '  Error Deal Count: ' + CAST(ISNULL(@error_count, 0) as varchar) + 
	' [Elapse time: ' + @e_time_text_s + ']' 

	
declare @job_name varchar(250)
set @job_name = 'hedge_deferral_'+@batch_process_id 
EXEC  spa_message_board 'u', @user_login_id, NULL, 'Hedge Deferral', @desc, '', '', @status_type, @job_name,NULL, @batch_process_id,NULL,'n',NULL,'y'




/************************************* Object: 'spa_Calc_Hedge_Deferral_Values' END *************************************/

