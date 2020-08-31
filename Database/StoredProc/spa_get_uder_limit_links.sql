
IF OBJECT_ID('spa_get_uder_limit_links') IS NOT NULL
DROP PROC dbo.spa_get_uder_limit_links
GO

CREATE PROC [dbo].[spa_get_uder_limit_links]	
 		@sub_id varchar(1000)=null,
		@str_id varchar(1000)=null,
		@book_id varchar(1000)=null,
		@term_start datetime = NULL,
		@term_end datetime = NULL,
		@perfect_term_match varchar(1),--p=perfect, w=within
		@volume float = NULL,
		@volume_frequency varchar(1) = NULL, --m=term;t =total
		@curve_id INT=NULL,
		@sort_order varchar(1),--l=lifo, f=fifo
		@hedge_or_item VARCHAR(1)='i', --h=hedge; i=item
		@buy_sell VARCHAR(1)=NULL,
		@process_id varchar(150)=null,@forecated_tran varchar(1)='n'
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
		@hedge_or_item VARCHAR(1)--h=hedge; i=item
		,@process_id varchar(150)='cccc',@buy_sell VARCHAR(1)='s',@forecated_tran varchar(1)='n'

---exec spa_get_uder_limit_links 87,null,null,'2014-01-01','2014-01-31','p',5000.0000000000,'t',199,'l','i','b','cccc','y'

select
 		@sub_id ='87',
		@str_id =null,
		@book_id =null,
		@term_start  = '2013-04-01',
		@term_end  = '2013-04-30',
		@perfect_term_match ='p',
		@volume =5000,
	--	@volume_uom  NULL, --it will be used later. Now the parameter is not used in logic.
		@volume_frequency='t',
		@curve_id =199,
		@volume_split='y' ,
		@sort_order ='l',
		@hedge_or_item ='i' --h=hedge; i=item
  DROP TABLE #link_filter
 DROP TABLE  #link_running_sum
--	exec spa_get_uder_limit_links null,null,37,'2012-10-01','2012-07-31','p',20.0000000000,'t',null,'l','i','s','96DF1A10_64D8_4DEC_ACEA_92A3C073F8A6__000__0000'
--exec spa_get_uder_limit_links null,null,37,'2012-10-01','2012-07-31','p',20.0000000000,'t',null,'l','i','s','3A97CCD1_8019_411E_8752_21E9E0D80E68__037__0021'
--*/
 
 
 
 
declare @sql varchar(8000)
declare @sql_where varchar(8000)
set @sql_where=''

if @sub_id is not null
	set @sql_where=@sql_where+' and p_str.parent_entity_id in ('+@sub_id+')'
if @str_id is not null
	set @sql_where=@sql_where+' and p_str.entity_id in ('+@str_id+')'
if @book_id is not null
	set @sql_where=@sql_where+' and p_book.entity_id in ('+@book_id+')'


if OBJECT_ID('tempdb..#link_filter') is not null
  DROP TABLE #link_filter
  
if OBJECT_ID('tempdb..#link_running_sum') is not null
 DROP TABLE  #link_running_sum

CREATE TABLE #link_filter(
	ROWID INT IDENTITY(1,1),
	link_id INT,
	link_effective_date DATETIME,
	link_description VARCHAR(2000) COLLATE DATABASE_DEFAULT , 
	perfect_hedge VARCHAR(1) COLLATE DATABASE_DEFAULT , 
	fas_book_id int,
	term_start DATETIME
	,term_end DATETIME
	,deal_volume numeric(28,12),
	percentage_included float
)

	
SET @sql='
	insert into #link_filter (link_id,link_effective_date,link_description, perfect_hedge,fas_book_id,
		term_start,term_end,deal_volume,percentage_included)
	SELECT link_id,link_effective_date,link_description, perfect_hedge,fas_book_id,
		min(term_start) term_start,max(term_end) term_end,sum(deal_volume) deal_volume,avg(percentage_included) percentage_included
	from 
	(
		select fld.gen_link_id link_id,flh.link_effective_date,
		max(flh.link_description) link_description,
		 max(flh.fas_book_id) fas_book_id,
		MIN(sdd.term_start) term_start,MAX(sdd.term_end)  term_end,
		'+ case when isnull(@volume_frequency,'t')='t' 
			THEN 'sum(sdd.deal_volume * isnull(fldd.percentage_used,fld.percentage_included))' 
			ELSE  'max(sdd.deal_volume * isnull(fldd.percentage_used,fld.percentage_included))'
			END +' deal_volume
		,Max(fld.percentage_included) percentage_included
		,max(sdd.buy_sell_flag) buy_sell
		,max(isnull(flh.perfect_hedge,''n'')) perfect_hedge
		FROM gen_fas_link_header flh 
		INNER JOIN	gen_fas_link_detail fld ON  fld.gen_link_id = flh.gen_link_id and process_id='''+@process_id+'''
				AND fld.hedge_or_item = case when isnull(flh.perfect_hedge,''n'')=''y'' then ''h'' else '''+ isnull(@hedge_or_item,'i') +  ''' end
		inner join portfolio_hierarchy p_book on flh.fas_book_id=p_book.entity_id
		inner join portfolio_hierarchy p_str on  p_book.parent_entity_id=p_str.entity_id 
		INNER JOIN '+case when isnull(@forecated_tran,'n')='n' then ' source_deal_detail sdd ON sdd.source_deal_header_id = fld.deal_number and sdd.leg=1 ' 
			else ' gen_deal_detail sdd on sdd.gen_deal_header_id=fld.deal_number and sdd.leg=1' end +'
		left join gen_fas_link_detail_dicing fldd on fldd.link_id=fld.gen_link_id and fldd.source_deal_header_id=fld.deal_number
			and fldd.term_start=sdd.term_start
		left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id '
		+ case when @curve_id is null then  '' else ' and sdd.curve_id='+ cast(@curve_id AS VARCHAR) end
		+ '	WHERE 1=1 '+ @sql_where 
			+ case when @curve_id is null then  '' else ' and isnull(spcd.proxy_source_curve_def_id,sdd.curve_id)='+ cast(@curve_id AS VARCHAR) end
		+'
		GROUP BY fld.gen_link_id,flh.link_effective_date'+
		CASE WHEN @buy_sell IS NOT NULL THEN 
			' having max(sdd.buy_sell_flag)=case when max(isnull(flh.perfect_hedge,''n''))=''y'' then  '''+ @buy_sell+'''
						 else '''+case when @buy_sell='b' then 's' else 'b' end+''' end  '
		else '' END + '
	) i_deals 
	GROUP BY link_id,link_effective_date,link_description, perfect_hedge,fas_book_id
	having '
		+	case when @perfect_term_match='p' then 
					' min(term_start)='''+ cast(@term_start AS VARCHAR)+''' and max(term_end)='''+cast(@term_end AS VARCHAR)+''''
				else
					' ((min(term_start)>='''+ cast(@term_start AS VARCHAR)+''' and max(term_end)<='''+cast(@term_end AS VARCHAR)+''')
					and not ( min(term_start)='''+ cast(@term_start AS VARCHAR)+''' and max(term_end)='''+cast(@term_end AS VARCHAR)+''')
					--OR ('''+ cast(@term_start AS VARCHAR)+'''>= min(term_start) and '''+cast(@term_end AS VARCHAR)+'''<=max(term_end))
					 )'
	 		END
		+
		'
	ORDER BY 7 desc,datediff(month,min(term_start),min(term_end)) desc,'+ case when isnull(@sort_order,'f')='f' THEN 'link_effective_date ' ELSE 'link_effective_date desc ' end +',link_id'


EXEC spa_print @sql
EXEC(@sql)


select m.link_id,m.deal_volume,isnull(r.run_total,m.deal_volume) run_total,m.term_start,m.term_end
from #link_filter m
cross apply (
	select SUM(deal_volume) run_total from #link_filter l where rowid<=m.rowid
) r
--where r.run_total-m.deal_volume<=@volume
where r.run_total-m.deal_volume<@volume
order by ROWID

EXEC spa_print 'end spa_get_uder_limit_links'
GO

