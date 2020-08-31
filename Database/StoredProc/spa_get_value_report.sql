/****** Object:  StoredProcedure [dbo].[spa_get_value_report]    Script Date: 06/06/2012 21:20:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_value_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_value_report]
GO

/****** Object:  StoredProcedure [dbo].[spa_get_value_report]    Script Date: 06/06/2012 21:20:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spa_get_value_report] @as_of_date        DATETIME ,
	@commodity int,
	@sub                     VARCHAR(1000) = NULL,
	@str                     VARCHAR(1000) = NULL,
	@book                    VARCHAR(1000) = null, --'162', --'162,164,166,206'
	@granularity varchar(1)='z' ,--m=monthly;q=quarterly;s=seasonal;a=annual;z=mixed
	@counterparty  int = null ,
	@base_curve_id  int = null ,
	@tou  int = null ,
	@curve_id  int = null,
	@flag varchar(1)='r' --r=report ; c=cube export

 as
 SET NOCOUNT ON 
 /*        
     -- exec spa_run_sql  73,'as_of_date=2011-09-09,commodity_id=-1,source_price_curve_def=359,type=q,sub_id=147!209!149!148!218!214'   
DECLARE @as_of_date        DATETIME = '2011-09-09',
        @commodity int=-1,
       @sub                     VARCHAR(1000) = '147,209,149,148,218,214',
        @str                     VARCHAR(1000) = NULL,
        @book                    VARCHAR(1000) = null, --'162,164,166,206'
        @granularity varchar(1)='z' ,--m=monthly;q=quarterly;s=seasonal;a=annual;z=mixed
        @counterparty  int = null ,
        @base_curve_id  int = null ,
         @tou  int = null ,
@curve_id  int = 359 ,@flag varchar(1)='c'
drop table #book


--*/



DECLARE @st1                       VARCHAR(MAX),
        @st2                       VARCHAR(MAX),
        @st_granularity VARCHAR(MAX)
    
set @st_granularity=''
if isnull(@granularity,'z')='m'
	set @st_granularity=' and f.term_start is not null '
else if isnull(@granularity,'z')='q'
	set @st_granularity=' and f.term_start is  null and f.qtr is not null '
else if isnull(@granularity,'z')='s'
	set @st_granularity=' and f.term_start is  null and f.qtr is  null and f.[seasonal] is not null '
else if isnull(@granularity,'z')='a'
	set @st_granularity=' and f.term_start is  null and f.qtr is  null and f.[seasonal] is null '

 
create table #book (book_id int,book_deal_type_map_id int,source_system_book_id1 int,source_system_book_id2 int,source_system_book_id3 int,source_system_book_id4 int,func_cur_id INT)		
	
SET @st1='insert into #book (book_id )		
	select distinct book.entity_id from portfolio_hierarchy book (NOLOCK) 
		INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
		INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
	WHERE 1=1  '
		+CASE WHEN  @sub IS NULL THEN '' ELSE ' and sb.entity_id in ('+@sub+')' END
		+CASE WHEN  @str IS NULL THEN '' ELSE ' and stra.entity_id in ('+@str+')' END
		+CASE WHEN  @book IS NULL THEN '' ELSE ' and book.entity_id in ('+@book+')' END		
		
exec(@st1)    
  
/*
DECLARE @countryNameList nvarchar(max); 
SELECT @countryNameList = STUFF( (SELECT ', ' + quotename(value_id) +' as '+quotename(code)
FROM static_data_value where type_id=14000 
ORDER BY value_id 
FOR XML PATH('')) , 1, 2, ''); 
--   select @countryNameList

DECLARE @countryList nvarchar(max); 
SELECT @countryList = STUFF( (SELECT ', ' + quotename(value_id) 
FROM static_data_value where type_id=14000 
ORDER BY value_id 
FOR XML PATH('')) , 1, 2, ''); 
---select @countryList
*/
DECLARE @qry nvarchar(max),@grp_col nvarchar(max); 


if isnull(@flag,'r')='c'
begin
	SET @qry = ' 
			 select '''+convert(varchar(10),@as_of_date,120) +''' AsOfDate,
			 case when f.[seasonal] IS null then ''Year ''+  cast(f.yr as varchar) else
				case when qtr IS null then 
					case when month(f.seasonal)=1 then ''Summer '' else ''Winter '' end + cast(year(f.[seasonal]) as varchar) 
				else 
					case when f.term_start IS null then 
						case  month(qtr) when 1 then '' 1st ''
								when 4 then '' 2nd ''
								when 7 then '' 3rd ''
								when 10 then '' 4th ''
						end + ''Qtr '' +   CONVERT(varchar(4),f.qtr,120)
					else
						CONVERT(varchar(4),f.term_start,100)  +  CONVERT(varchar(4),f.term_start,120)
					end
				end
			end as LogicalName
			,f.curve_id,f.counterparty_id
			,book.entity_id Book_id,f.commodity_id,f.base_curve_id,
			 f.[user_toublock_id] TOU_id
			 , case when f.seasonal is null then ''Yearly''
					when f.seasonal is not null and f.qtr is null then ''Seasonal''
					when f.qtr is not null and f.term_start is null then ''Quarterly''
					when f.term_start is not null then ''Monthly''
				end [Type]
			,sum(f.avg_curve_value) [Average Price]				
			,sum(f.forward_value) [Value] 					
			,sum(f.forward_value / ISNULL(NULLIF(f.avg_curve_value,0),1)) [Value in Base UOM] 
			,f.func_currency_id currency_id,f.base_UOM_id UOM_id
			,f.source_system_book_id1,f.source_system_book_id2,f.source_system_book_id3,f.source_system_book_id4
			,COALESCE(yr,YEAR(seasonal),YEAR(qtr),YEAR(term_start))[Year],MONTH(term_start) [Month]
			,case when month(f.seasonal)=1 then ''Summer '' else ''Winter '' end [Season]
			,DATEPART(Q,qtr) Quarter'
			
	set @grp_col='  group by logical_code,f.[Yr],f.[seasonal] ,f.[qtr], f.term_start, f.curve_id,f.counterparty_id
			,book.entity_id ,f.commodity_id,f.base_curve_id, f.[user_toublock_id]
			 , case when f.seasonal is null then ''Yearly''
					when f.seasonal is not null and f.qtr is null then ''Seasonal''
					when f.qtr is not null and f.term_start is null then ''Quarterly''
					when f.term_start is not null then ''Monthly''
				end ,f.func_currency_id,f.base_UOM_id
				,f.source_system_book_id1,f.source_system_book_id2,f.source_system_book_id3,f.source_system_book_id4,yr,MONTH(term_start)'			
end
else
begin
	SET @qry = ' 
		 select '''+convert(varchar(10),@as_of_date,120) +''' AsOfDate,
		 case when f.[seasonal] IS null then ''Year ''+  cast(f.yr as varchar) else
			case when qtr IS null then 
				case when month(f.seasonal)=1 then ''Summer '' else ''Winter '' end + cast(year(f.[seasonal]) as varchar) 
			else 
					case when f.term_start IS null then 
						case  month(qtr) when 1 then '' 1st ''
								when 4 then '' 2nd ''
								when 7 then '' 3rd ''
								when 10 then '' 4th ''
						end + ''Qtr '' +   CONVERT(varchar(4),f.qtr,120)
					else
						CONVERT(varchar(4),f.term_start,100)  +  CONVERT(varchar(4),f.term_start,120)
					end
			end
		end as LogicalName
		,spcd_m.curve_name [Index],cp.counterparty_name Counterparty
		,subs.entity_name [Sub],stra.entity_name [Str],book.entity_name Book,com.commodity_name Commodity,spcd.curve_name [Proxy curve index],
		btg.block_name TOU, case when f.seasonal is null then ''Yearly''
							when f.seasonal is not null and f.qtr is null then ''Seasonal''
							when f.qtr is not null and f.term_start is null then ''Quarterly''
							when f.term_start is not null then ''Monthly''
						end [Type]
						
			,sum(f.avg_curve_value) [Average Price]				
			,sum(f.forward_value) [Value] 					
			,sum(f.forward_value / ISNULL(NULLIF(f.avg_curve_value,0),1)) [Value in Base UOM] 
			,sc.currency_name Currency,su.uom_name UOM'	
			
	set @grp_col=' group by logical_code,f.[Yr],f.[seasonal] ,f.[qtr], f.term_start,sc.currency_name,su.uom_name,cp.counterparty_name
		, case when f.seasonal is null then ''Yearly''
			when f.seasonal is not null and f.qtr is null then ''Seasonal''
			when f.qtr is not null and f.term_start is null then ''Quarterly''
			when f.term_start is not null then ''Monthly''
		end,subs.entity_name ,stra.entity_name ,book.entity_name ,com.commodity_name,spcd.curve_name,spcd_m.curve_name,btg.block_name'
			
end
SET @qry = @qry+' 
 from  dbo.forward_value_report f 
	left join source_currency sc on f.func_currency_id=sc.source_currency_id
	left join source_uom su on f.base_UOM_id=su.source_uom_id
	left join block_type_group btg on f.[user_toublock_id]=btg.id
	left join source_counterparty cp on cp.source_counterparty_id=f.counterparty_id
	left join portfolio_hierarchy book on book.entity_id=f.book_id
	left join portfolio_hierarchy stra on book.parent_entity_id=stra.entity_id
	left join portfolio_hierarchy subs on stra.parent_entity_id=subs.entity_id
	left join source_commodity com on com.source_commodity_id=f.commodity_id
	left join source_price_curve_Def spcd on spcd.source_curve_def_id=f.base_curve_id
	left join source_price_curve_Def spcd_m on spcd_m.source_curve_def_id=f.curve_id
where f.as_of_date='''+convert(varchar(10),@as_of_date,120) +'''' 
	+ CASE WHEN @commodity IS NOT NULL THEN ' AND f.commodity_id='+cast(@commodity as varchar) ELSE '' END
	+ case when @counterparty IS not null then ' and f.[counterparty_id]='+cast(@counterparty AS varchar) else '' end 
	+ case when @tou IS not null then ' and f.[user_toublock_id]='+cast(@tou AS varchar) else '' end
	+ case when @base_curve_id IS not null then ' and f.base_curve_id='+cast(@base_curve_id AS varchar) else '' end
	+ case when @tou IS not null then ' and f.[user_toublock_id]='+cast(@tou AS varchar) else '' end
	+ @st_granularity +@grp_col +'
	order by max(f.Rowid)'

--print @qry
exec(@qry)
  
/************************************* Object: 'spa_get_value_report' END *************************************/

GO


