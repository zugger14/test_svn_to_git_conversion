
IF OBJECT_ID('spa_get_fifo_lifo_links') IS NOT NULL
DROP PROC dbo.spa_get_fifo_lifo_links
GO
	
CREATE PROC [dbo].[spa_get_fifo_lifo_links]	
 		@sub_id varchar(1000)=null,
		@str_id varchar(1000)=null,
		@book_id varchar(1000)=null,
		@term_start datetime = NULL,
		@term_end datetime = NULL,
		@perfect_term_match varchar(1),--p=perfect, w=within
		@volume float = NULL,
		@volume_uom  int = NULL, --it will be used later. Now the parameter is not used in logic.
		@volume_frequency varchar(1) = NULL, --m=term;t =total
		@curve_id INT=NULL,
		@volume_split  varchar(1), ---y=yes; n=no 
		@sort_order varchar(1),--l=lifo, f=fifo
		@dedesignation_date datetime,
		@hedge_or_item VARCHAR(1)='i', --h=hedge; i=item
		@buy_sell VARCHAR(1)=NULL,
		@limit_run_date VARCHAR(10)=NULL --l=dynamic limit
as
/*

  declare 	
 		@sub_id varchar(1000),
		@str_id varchar(1000),
		@book_id varchar(1000),
		@term_start datetime ,
		@term_end datetime ,
		@perfect_term_match varchar(1),--p=perfect, w=within
		@volume float ,
		@volume_uom  int , --it will be used later. Now the parameter is not used in logic.
		@volume_frequency varchar(1) , --m=term;t =total
		@curve_id INT,
		@volume_split  varchar(1), ---y=yes; n=no 
		@sort_order varchar(1),--l=lifo, f=fifo
		@dedesignation_date datetime,
		@hedge_or_item VARCHAR(1)--h=hedge; i=item
		,@buy_sell VARCHAR(1)=NULL,
	@limit_run_date VARCHAR(10)='2013-03-28'
 
select
 		@sub_id =null,
		@str_id =null,
		@book_id =null,
		@term_start  = '2013-01-01',
		@term_end  = '2013-01-31',
		@perfect_term_match ='p',
		@volume =30000,
	--	@volume_uom  NULL, --it will be used later. Now the parameter is not used in logic.
		@volume_frequency='m',
		@curve_id =NULL,
		@volume_split='y' ,
		@sort_order ='f',
		@dedesignation_date= '2009-11-30',
		@hedge_or_item ='i' --h=hedge; i=item
  DROP TABLE #link_filter
 DROP TABLE  #link_running_sum

--*/
 
 
declare @sql varchar(8000)
declare @sql_where varchar(8000),@limit_join varchar(8000),@limit_where varchar(8000)
set @sql_where=''

if @sub_id is not null
	set @sql_where=@sql_where+' and p_str.parent_entity_id in ('+@sub_id+')'
if @str_id is not null
	set @sql_where=@sql_where+' and p_str.entity_id in ('+@str_id+')'
if @book_id is not null
	set @sql_where=@sql_where+' and p_book.entity_id in ('+@book_id+')'

set @volume=ABS(@volume)

set @limit_join=''
set @limit_where=''
if @limit_run_date is not null
begin
	set @limit_join=' left join (
		select distinct dcr.link_id from dedesignation_criteria dc inner join dedesignation_criteria_result dcr on dc.dedesignation_criteria_id=dcr.dedesignation_criteria_id 
		and run_date='''+@limit_run_date+ ''''	+ case when @sub_id IS not null then ' and dc.fas_sub_id in ('+@sub_id+')' else '' end +'
		) lmt on lmt.link_id=fld.link_id'
	
	set @limit_where=' and lmt.link_id is null '
end

CREATE TABLE #link_filter(
	ROWID INT IDENTITY(1,1),
	link_id INT,
	link_effective_date DATETIME,
	link_description VARCHAR(2000) COLLATE DATABASE_DEFAULT , 
	perfect_hedge VARCHAR(1) COLLATE DATABASE_DEFAULT , 
	fas_book_id int,
	term_start DATETIME
	,term_end DATETIME
	,deal_volume float,
	percentage_included float
)

SET @sql='
insert into #link_filter (link_id,link_effective_date,link_description, perfect_hedge,fas_book_id,
	term_start,term_end,deal_volume,percentage_included)
SELECT link_id,link_effective_date,link_description, perfect_hedge,fas_book_id,
	min(term_start) term_start,max(term_end) term_end,sum(deal_volume) deal_volume,avg(percentage_included) percentage_included
from 
(
	select fld.link_id,flh.link_effective_date,
	max(flh.link_description) link_description,
	max(flh.perfect_hedge) perfect_hedge, max(flh.fas_book_id) fas_book_id,
	MIN(sdd.term_start) term_start,MAX(sdd.term_end)  term_end,
	'+ case when isnull(@volume_frequency,'t')='t' 
		THEN 'sum(sdd.deal_volume * fld.percentage_included)' 
		ELSE  'min(sdd.deal_volume * fld.percentage_included)'
		END +' deal_volume
	,MIN(fld.percentage_included) percentage_included
	,max(sdd.buy_sell_flag) buy_sell
	FROM fas_link_header flh 
	INNER JOIN
		fas_link_detail fld ON  fld.link_id = flh.link_id and flh.link_effective_date <= ''' + CAST(@dedesignation_date AS VARCHAR) + ''' 
			and flh.link_active = ''y'' and flh.link_type_value_id = 450 and isnull(flh.fully_dedesignated,''n'') = ''n''
			AND fld.hedge_or_item =case when isnull(perfect_hedge,''n'')=''y'' then ''h'' else '''+ isnull(@hedge_or_item,'i') +  ''' end
			inner join portfolio_hierarchy p_book on flh.fas_book_id=p_book.entity_id
			inner join portfolio_hierarchy p_str on  p_book.parent_entity_id=p_str.entity_id 
	INNER JOIN
		source_deal_detail sdd ON sdd.source_deal_header_id = fld.source_deal_header_id and sdd.leg=1 
	left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id '
	+ @limit_join + '
	WHERE 1=1 '+ @sql_where+ @limit_where 
	+ case when @curve_id is null then  '' else ' and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+ cast(@curve_id AS VARCHAR) end
	+'
	GROUP BY fld.link_id,flh.link_effective_date'+
	CASE WHEN @buy_sell IS NOT NULL THEN ' having max(sdd.buy_sell_flag)='''+ CASE WHEN @buy_sell='b' THEN 's' ELSE 'b' END +''''
	else '' END + '
) i_deals 
GROUP BY link_id,link_effective_date,link_description, perfect_hedge,fas_book_id
having	'
	+	case when @perfect_term_match='p' then 
				' min(term_start)='''+ cast(@term_start AS VARCHAR)+''' and max(term_end)='''+cast(@term_end AS VARCHAR)+''''
			else
				' ((min(term_start)>='''+ convert(varchar(10),@term_start,120)+''' and max(term_end)<='''+ convert(varchar(10),@term_end,120)+''')
				OR ('''+  convert(varchar(10),@term_start,120)+'''>= min(term_start) and '''+ convert(varchar(10),@term_end,120)+'''<=max(term_end)) )'
 		END
	+
	'
ORDER BY '+ case when isnull(@sort_order,'f')='f' THEN 'link_effective_date, link_id ' ELSE 'link_effective_date desc, link_id desc ' end 


EXEC spa_print @sql
EXEC(@sql)


SELECT a.rowid,
       min(a.deal_volume) deal_volume, 
       SUM(b.deal_volume) RunningTotal 
INTO #link_running_sum
FROM #link_filter a CROSS JOIN #link_filter b
WHERE (b.rowid <= a.rowid)
GROUP BY a.rowid
ORDER BY a.rowid

SELECT a.rowid [SNo],l.link_id [Relationship ID],
	cast(
			CASE WHEN a.RunningTotal<= @volume 
			THEN 1
			ELSE 
				case when isnull(@volume_split,'n')='n'
				THEN 1
				else
					case when b.RunningTotal is null then 
							@volume/a.deal_volume
						 ELSE 
						 	CAST((@volume-b.RunningTotal) AS FLOAT)/a.deal_volume
					end
				END 
			END
		AS NUMERIC(38,4)) [Recommended %],
	cast(1-
			CASE WHEN a.RunningTotal<= @volume 
			THEN 1
			ELSE 
				case when isnull(@volume_split,'n')='n'
				THEN 1
				ELSE 
					case when b.RunningTotal is null then 
							@volume/a.deal_volume
						 ELSE 
						 	CAST((@volume-b.RunningTotal) AS FLOAT)/a.deal_volume
					end
				END 
			END
		AS NUMERIC(38,4)) [Remaining %],l.percentage_included [Available %],
	dbo.fnadateformat(l.link_effective_date) [Effective Date],
	dbo.FNAHyperLinkText(10233710, l.link_description, l.link_id) [Relatioship Desc]
	,l.perfect_hedge [Perfect Hedge],
	 l.fas_book_id [Book ID], dbo.fnadateformat(l.term_start) TermStart, dbo.fnadateformat(l.term_end) TermStart,l.deal_volume  link_volume,a.RunningTotal
FROM 
	#link_running_sum a 
	INNER JOIN  #link_filter l ON l.ROWID=a.rowid
	left JOIN #link_running_sum b ON a.rowid=b.rowid+1
WHERE b.RunningTotal<@volume OR b.RunningTotal IS NULL

--SELECT * FROM application_functions af WHERE af.function_name LIKE 'View%'
/************************************* Object: 'spa_get_fifo_lifo_links' END *************************************/
