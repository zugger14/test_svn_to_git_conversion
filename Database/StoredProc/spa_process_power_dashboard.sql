
if object_id('spa_process_power_dashboard') is not null
	drop proc dbo.spa_process_power_dashboard

GO

CREATE PROCEDURE [dbo].[spa_process_power_dashboard] 
	@flag varchar(1)='s'   -- s-select value from saved table; c - calcuate value ; b= best case	
				--; w=what if ; s=save what if value in new deal; r= generation reserve planner ; o=call 
	,@sub varchar(1000)=null 
	,@str varchar(1000)=null
	,@book 	varchar(1000) =null
	,@term_start datetime ='2015-11-01'
	,@term_end datetime =null
	,@hr_start int=1
	,@hr_no int=10
	,@process_id varchar(250)  =null
	,@xml xml	 =null
	,@header_deal_ids varchar(1000) = null
	,@save_xml xml = null
	,@solver_decision varchar(1)='y' --y=call solver logic
	,@snapshot_id INT = null
	,@snapshot_name VARCHAR(100) = null
	,@pdf_xml NVARCHAR(MAX) = null
AS

SET NOCOUNT ON
/*


declare
	@flag varchar(1)='c'  -- s-select value from saved table; c - calcuate value ; b= best case	; w=what if ; 	s=save what if value in new deal
	,@sub varchar(1000)=null 
	,@str varchar(1000)=null
	,@book 	varchar(1000) =null
	,@term_start datetime ='2016-01-01'
	,@term_end datetime = '2016-01-01'
	,@hr_start int=0
	,@hr_no int=2
	,@process_id varchar(250)  =null
	,@xml xml	 =null --'<Root><grid process_row_id="33" hour="1" term="2016-01-01" value="2" is_dst="0" /></Root>'
	,@header_deal_ids varchar(1000) = null --'69693,69688'89996,92011
	,@save_xml xml = null
	,@solver_decision varchar(1)='y'
	,@snapshot_id INT = null
	,@snapshot_name VARCHAR(100) = null
	,@pdf_xml NVARCHAR(MAX) = null
--	 select * from source_deal_header where deal_id in ('Peaker','Cogen')

  --*/
--set nocount on

IF OBJECT_ID(N'tempdb..#tmp_deals') IS NOT NULL DROP TABLE #tmp_deals
IF OBJECT_ID(N'tempdb..#books') IS NOT NULL DROP TABLE #books
IF OBJECT_ID(N'tempdb..#tmp_hr') IS NOT NULL DROP TABLE #tmp_hr
IF OBJECT_ID(N'tempdb..#time_series_data') IS NOT NULL DROP TABLE #time_series_data

IF OBJECT_ID(N'tempdb..#tmp_group') IS NOT NULL DROP TABLE #tmp_group
IF OBJECT_ID(N'tempdb..#online_status_pre') IS NOT NULL DROP TABLE #online_status_pre
IF OBJECT_ID(N'tempdb..#online_status') IS NOT NULL DROP TABLE #online_status
IF OBJECT_ID(N'tempdb..#reserves') IS NOT NULL DROP TABLE #reserves
IF OBJECT_ID(N'tempdb..#total_sales') IS NOT NULL DROP TABLE #total_sales
IF OBJECT_ID(N'tempdb..#online_capacity_pre') IS NOT NULL DROP TABLE #online_capacity_pre
IF OBJECT_ID(N'tempdb..#online_capacity') IS NOT NULL DROP TABLE #online_capacity
IF OBJECT_ID(N'tempdb..#db_value') IS NOT NULL DROP TABLE #db_value
IF OBJECT_ID(N'tempdb..#generic_mapping_hr') IS NOT NULL DROP TABLE #generic_mapping_hr
IF OBJECT_ID(N'tempdb..#spin_requirement') IS NOT NULL DROP TABLE #spin_requirement
IF OBJECT_ID(N'tempdb..#ancillary') IS NOT NULL DROP TABLE #ancillary
IF OBJECT_ID(N'tempdb..#whatif') IS NOT NULL DROP TABLE #whatif
IF OBJECT_ID(N'tempdb..#capacity_usage') IS NOT NULL DROP TABLE #capacity_usage
IF OBJECT_ID(N'tempdb..#db_value1') IS NOT NULL DROP TABLE #db_value1
IF OBJECT_ID(N'tempdb..#xml') IS NOT NULL DROP TABLE #xml
IF OBJECT_ID(N'tempdb..#base_case') IS NOT NULL DROP TABLE #base_case
IF OBJECT_ID(N'tempdb..#temp_inserted_deals') IS NOT NULL DROP TABLE #temp_inserted_deals
IF OBJECT_ID(N'tempdb..#temp_inserted_deal_detail') IS NOT NULL DROP TABLE #temp_inserted_deal_detail
IF OBJECT_ID(N'tempdb..#save_xml') IS NOT NULL DROP TABLE #save_xml
IF OBJECT_ID(N'tempdb..#save_xml_deal') IS NOT NULL DROP TABLE #save_xml_deal
IF OBJECT_ID(N'tempdb..#tmp_msg') IS NOT NULL DROP TABLE #tmp_msg
IF OBJECT_ID(N'tempdb..#reserves_adj') IS NOT NULL DROP TABLE #reserves_adj
IF OBJECT_ID(N'tempdb..#total_purchases') IS NOT NULL DROP TABLE #total_purchases


---select @flag='w',@term_start='2016-01-01',@hr_start='0',@hr_no='2',@xml='<Root><grid process_row_id="33" hour="1" term="2016-01-01" value="2" is_dst="0" /></Root>'

--select  @flag='t',@save_xml='<Root><grid deal_id="35851" hour="1" term="2016-01-01" value="2" is_dst="0" type="d" ></grid><grid deal_id="35851" hour="2" term="2016-01-01" value="0" is_dst="0" type="d" ></grid><grid deal_id="36047" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36047" hour="2" term="2016-01-01" value="0" is_dst="0" type="t" ></grid><grid deal_id="36048" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36048" hour="2" term="2016-01-01" value="0" is_dst="0" type="t" ></grid><grid deal_id="36049" hour="1" term="2016-01-01" value="0" is_dst="0" type="t" ></grid><grid deal_id="36049" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36050" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36050" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36051" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36051" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36052" hour="1" term="2016-01-01" value="1"			is_dst="0" type="t" ></grid><grid deal_id="36052" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36053" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36053" hour="2" term="2016-01-01" value="0" is_dst="0" type="t" ></grid><grid deal_id="36054" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36054" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36055" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36055" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36056" hour="1" term="2016-01-01" value="1" is_dst="0" type="t" ></grid><grid deal_id="36056" hour="2" term="2016-01-01" value="1" is_dst="0" type="t" ></grid></Root>',@process_id='173480EA_63A9_48B5_BDCA_F867F22B738A',@term_start='2016-01-01',@hr_start='0',@hr_no='2'

--select @flag='w',@term_start='2016-01-01',@hr_start='0',@hr_no='2',@xml='<Root><grid process_row_id="33" hour="1" term="2016-01-01" value="6" is_dst="0" /></Root>'

--select @flag='w',@term_start='2016-01-01',@hr_start='0',@hr_no='1',@xml='<Root><grid process_row_id="33" hour="1" term="2016-01-01" value="2" is_dst="0" /><grid process_row_id="33" hour="1" term="2016-01-01" value="2" is_dst="0" /><grid process_row_id="33" hour="1" term="2016-01-01" value="2" is_dst="0" /></Root>'


--set @solver_decision='y'

DECLARE  @heat_rate INT
	,@minimum_capacity INT
	,@maximum_capacity INT
	,@online_indicator INT
	,@generation_category INT
	,@variable_om_rate int 
	,@power_dashboard varchar(250) 
	,@coefficient_a int
	,@coefficient_b int
	,@coefficient_c int
	,@ten_minute_reserve int
	,@capacity_usage int
	,@power_dashboard_generation varchar(250)

declare @st varchar(max) ,@column_list varchar(max),@column_list_sel VARCHAR(MAX)
declare @term_start_hr datetime,@term_end_hr datetime,@db_user varchar(30) ,@org_flag  varchar(1),@firm int
--set @pkg_id=replace(replace(str(cast(RAND() as numeric(20,20)),20,20),'0.','')
declare @power_solver varchar(250)



DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT


set @org_flag=@flag	
if 	 @flag in ('g' ,'o')
begin
	set @org_flag=@flag
	set @flag ='c'
end

set @term_start_hr =convert(varchar(10),@term_start,120)+ ' ' + right('00'+cast(@hr_start as varchar),2)+':00:00.000'
SELECT @term_end_hr = CASE WHEN @term_end IS NOT NULL THEN @term_end + '23:59:59.000' ELSE dateadd(hour,@hr_no-1,@term_start_hr) END

 select order_id=identity(int,1,1), term_start term_hr,0 is_dst into #tmp_hr from [dbo].[FNATermBreakdown]('h' ,@term_start_hr ,@term_end_hr)

 INSERT INTO #tmp_hr(term_hr,is_dst)
 SELECT 
	CAST(CONVERT(VARCHAR(10),[date],120)+' '+CAST([hour]-1 AS VARCHAR)+':00' AS DATETIME),1
 FROM
	mv90_dst
  WHERE 		
	[date] BETWEEN @term_start_hr AND @term_end_hr
	AND insert_delete = 'i'

set @db_user=dbo.FNADBUser()

if @process_id is null 
	set @process_id=REPLACE(newid(),'-','_')

CREATE TABLE #tmp_msg(
			a1 varchar(250) COLLATE DATABASE_DEFAULT,
			a2 varchar(250) COLLATE DATABASE_DEFAULT,
			a3 varchar(250) COLLATE DATABASE_DEFAULT,
			a4 varchar(250) COLLATE DATABASE_DEFAULT,
			a5 varchar(250) COLLATE DATABASE_DEFAULT,
			a6 varchar(250) COLLATE DATABASE_DEFAULT
	)

set @power_dashboard=dbo.FNAProcessTableName('power_dashboard', @db_user, @process_id)
set @power_dashboard_generation=dbo.FNAProcessTableName('power_dashboard_generation', @db_user, @process_id)
set @power_solver=dbo.FNAProcessTableName('power_solver', @db_user, @process_id)

CREATE TABLE #save_xml(
			process_row_id INT,
			hour INT,
			term DATETIME,
			value numeric(16,4),
			is_dst INT
	)

if @xml is not null and @flag = 'w'
begin
	
	INSERT INTO #save_xml
	SELECT DISTINCT
	process_row_id,[hour],[term], CASE WHEN [value]='y' THEN 1  WHEN [value]='n' THEN 0 ELSE [value] END,[is_dst]
	FROM 
	(
	SELECT
	 doc.col.value('@process_row_id', 'int') process_row_id
	,doc.col.value('@hour', 'int') [hour] 
	,doc.col.value('@term', 'datetime') [term] 
		,doc.col.value('@value', 'varchar(100)') [value] 
		,doc.col.value('@is_dst', 'numeric(16,4)') [is_dst] 
	FROM @xml.nodes('/Root/grid') doc(col)
	)a

end

 if @flag='s'	-- select value from table
 begin

	SELECT 
		row_id,
		group1,
		group2,
		deal_id,
		ref_id,
		term_dt,
		is_dst,
		value
	INTO
		#db_value
	FROM
		operational_dashboard_summary
	WHERE
		term_dt BETWEEN @term_start_hr AND @term_end_hr

	
	select * into #db_value1 from (
	SELECT DISTINCT term_dt,is_dst FROM #db_value
	
	) a order by 1
	
	select @column_list=isnull(@column_list+',','')+ '['+convert(varchar(16),term_dt,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +']' from #db_value1
	order by term_dt

	SELECT @column_list_sel = isnull(@column_list_sel+',','')+ 'ROUND(['+convert(varchar(16),term_dt,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +'],2)'+'['+convert(varchar(16),term_dt,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +']' from #db_value1 a
	order by term_dt

	SET @st = '
		SELECT  [group],group2,deal_id,'''' process_id,row_id,ref_id,'+@column_list_sel+'
		FROM
			(SELECT group1 [group],group2,deal_id,row_id,ref_id,convert(varchar(16),term_dt,120)+CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END  term_dt,value FROM #db_value) AS st
			PIVOT
			(
				MAX(value) FOR term_dt IN('+@column_list+')
			) AS Pivottable
		ORDER BY row_id '

	EXEC(@st)
	RETURN

 end


ELSE IF @flag IN ('c','w')  -- calculate the values
BEGIN		
	SELECT @heat_rate= 
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Flat Heat Rate'

	SELECT @minimum_capacity = 
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Minimum Capacity'

	SELECT @maximum_capacity=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Maximum Capacity'

	SELECT @online_indicator=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Online Indicator'
	
	SELECT @capacity_usage=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code='Capacity Usage'
	SELECT @generation_category=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Generation Category'

	SELECT @variable_om_rate=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Variable OM Rate'

	SELECT @coefficient_a=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Heat Rate A coefficient'

	SELECT @coefficient_b=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Heat Rate B coefficient'

	SELECT @coefficient_c=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Heat Rate C coefficient'

	SELECT @ten_minute_reserve=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = '10 Mins Reserve'

	SELECT @firm=
		value_id
	FROM static_data_value
	WHERE [TYPE_ID] = 5500 AND code = 'Firm'

	--select * from static_data_value WHERE [TYPE_ID] = 5500 AND code like '%firm%'

	--select @heat_rate,@minimum_capacity,@maximum_capacity,@online_indicator,@generation_category,@variable_om_rate

	create table #books
	( 
		sub_book_id  int,source_system_book_id1 int,source_system_book_id2 int,source_system_book_id3 int,source_system_book_id4  int
	)

	SET @st='
		insert into #books
		 ( 
			sub_book_id ,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4  
		)
		SELECT  book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 
		FROM source_system_book_map sbm            
			INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
			INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id
		WHERE 1=1 '
			+CASE WHEN  @sub IS NULL THEN '' ELSE ' AND stra.parent_entity_id in ('+@sub+')' END
			+CASE WHEN  @str IS NULL THEN '' ELSE ' AND stra.entity_id in ('+@str+')' END
			+CASE WHEN  @book IS NULL THEN '' ELSE ' AND book.entity_id in ('+@book+')' END	

	--print(@st)		
	EXEC(@st)

		
	 create table #tmp_deals 
	 (
		order_id int identity(1,1)
		,source_deal_header_id int
		,deal_id varchar(50) COLLATE DATABASE_DEFAULT
		,udf_time_series_id int
		,min_capacity numeric(12,2) 
		,max_capacity numeric(12,2)
		,heat_rate float	
		,generation_category int
		,running_sum numeric(12,0)
		,variable_om_rate  numeric(20,4) 
		,location_id INT 
		, coefficient_a	 numeric(20,6) 
		, coefficient_b	 numeric(20,6)
		, coefficient_c	 numeric(20,6)
		,ten_minute_reserve	varchar(1) COLLATE DATABASE_DEFAULT
		,udf_capacity_usage_id int
	 )


	set @st='
		insert into  #tmp_deals 
		 (
			 source_deal_header_id,deal_id,udf_time_series_id ,min_capacity,max_capacity,heat_rate,generation_category ,variable_om_rate,location_id,
			  coefficient_a, coefficient_b, coefficient_c ,ten_minute_reserve,udf_capacity_usage_id
		 ) 
		SELECT sdh.source_deal_header_id,sdh.deal_id,online_indicator.udf_value ,minimum_capacity.udf_value,maximum_capacity.udf_value,heat_rate.udf_value
			,generation_category.udf_value ,variable_om_rate.udf_value,sdd.location_id
			,coefficient_a.udf_value ,coefficient_b.udf_value,coefficient_c.udf_value,ten_minute_reserve.udf_value,capacity_usage.udf_value
		FROM  #books sbmp	  
		inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
				AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
				AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
				AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
		inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
			and template_name =''Generation Deal Template''
		cross apply
		( 
			select  u.udf_value
   			from  [user_defined_deal_fields] u 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u.udf_value)=1 
					and	 u.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='+cast(@online_indicator as varchar) +'
					AND uddft1.udf_template_id = u.udf_template_id 
		) online_indicator
		outer apply
		( 
			select  u.udf_value
   			from  [user_defined_deal_fields] u 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u.udf_value)=1 
					and	 u.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='+cast(@capacity_usage as varchar) +'
					AND uddft1.udf_template_id = u.udf_template_id 
		) capacity_usage
		cross apply
		( 
			select  u3.udf_value
   			from  [user_defined_deal_fields] u3 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft3 ON  isnumeric(u3.udf_value)=1 
					and	 u3.source_deal_header_id=sdh.source_deal_header_id and uddft3.field_id ='+cast(@heat_rate  as varchar )+'
					AND uddft3.udf_template_id = u3.udf_template_id 
		) heat_rate
		outer apply
		( 
			select  u2.udf_value
   			from  [user_defined_deal_fields] u2 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft2 ON  isnumeric(u2.udf_value)=1 
					and	 u2.source_deal_header_id=sdh.source_deal_header_id and uddft2.field_id ='+cast(@minimum_capacity  as varchar )+'
					AND uddft2.udf_template_id = u2.udf_template_id 
		) minimum_capacity

		outer apply
		( 
			select  u4.udf_value
   			from  [user_defined_deal_fields] u4 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft4 ON  isnumeric(u4.udf_value)=1 
					and	 u4.source_deal_header_id=sdh.source_deal_header_id and uddft4.field_id ='+cast(@generation_category  as varchar )+'
					AND uddft4.udf_template_id = u4.udf_template_id 
		) generation_category
		outer apply
		( 
			select  u5.udf_value
   			from  [user_defined_deal_fields] u5 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft5 ON  isnumeric(u5.udf_value)=1 
					and	 u5.source_deal_header_id=sdh.source_deal_header_id and uddft5.field_id ='+cast(@variable_om_rate  as varchar )+'
					AND uddft5.udf_template_id = u5.udf_template_id 
		) variable_om_rate
		outer apply
		( 
			select  u1.udf_value
   			from  [user_defined_deal_fields] u1 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft1 ON  isnumeric(u1.udf_value)=1 
					and	 u1.source_deal_header_id=sdh.source_deal_header_id and uddft1.field_id ='+cast(@maximum_capacity  as varchar )+'
					AND uddft1.udf_template_id = u1.udf_template_id 
		) maximum_capacity
		outer APPLY
		(
			SELECT MAX(location_id) location_id FROM source_deal_detail where source_deal_header_id = sdh.source_deal_header_id
		) sdd
		outer apply
		( 
			select  u6.udf_value
   			from  [user_defined_deal_fields] u6 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft6 ON  isnumeric(u6.udf_value)=1 
					and	 u6.source_deal_header_id=sdh.source_deal_header_id and uddft6.field_id ='+cast(@coefficient_a  as varchar )+'
					AND uddft6.udf_template_id = u6.udf_template_id 
		) coefficient_a
		outer apply
		( 
			select  u7.udf_value
   			from  [user_defined_deal_fields] u7 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft7 ON  isnumeric(u7.udf_value)=1 
					and	 u7.source_deal_header_id=sdh.source_deal_header_id and uddft7.field_id ='+cast(@coefficient_b  as varchar )+'
					AND uddft7.udf_template_id = u7.udf_template_id 
		) coefficient_b
		outer apply
		( 
			select  u8.udf_value
   			from  [user_defined_deal_fields] u8 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft8 ON  isnumeric(u8.udf_value)=1 
					and	 u8.source_deal_header_id=sdh.source_deal_header_id and uddft8.field_id ='+cast(@coefficient_c  as varchar )+'
					AND uddft8.udf_template_id = u8.udf_template_id 
		) coefficient_c
		outer apply
		( 
			select  u9.udf_value
   			from  [user_defined_deal_fields] u9 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft9 ON  isnumeric(u9.udf_value)=1 
					and	 u9.source_deal_header_id=sdh.source_deal_header_id and uddft9.field_id ='+cast(@ten_minute_reserve  as varchar )+'
					AND uddft9.udf_template_id = u9.udf_template_id 
		) ten_minute_reserve
		WHERE  1=1 --cast(isnull(heat_rate.udf_value,''0'') as numeric(18,6))<>0 '
	+case when @header_deal_ids IS NULL then '' else ' and sdh.source_deal_header_id in ('+@header_deal_ids+' )  ' end
	 +' 
	 order by cast(heat_rate.udf_value as numeric(20,8)),sdh.source_deal_header_id	'


	--print @st
	exec(@st)
		

	SELECT 
		sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT) hr,
		cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(sddh.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
		sddh.is_dst,
		sum(case when sdd.buy_sell_flag='s' then -1 else 1 end *  sddh.volume) volume
		,sales_name.sales_name
		,case when @org_flag ='g' then
			case when sales_name.sales_name in ('peak load','legacy sale','what if sale trade' ,'control area outbound schedules','firm sales from trades','non firm sales from trades') then 'Loads' else 'Purchases' end
		 else 
			case when sdht.template_name in ('peak load','legacy sale' ,'control area outbound schedules','Legacy Purchase','Control Area Inbound Schedules') then 'Loads' 
		 		when sdht.template_name in ('firm sales from trades','non firm sales from trades','Firm purchases from trades','non firm purchases from trades','What If Sales'	)  then 'Net Transactions'
		 	 else '' end
		  end sales_type,
		  sum(case when sdd.buy_sell_flag='s' then -1 else 1 end *  sddh.volume) volume_no_whatif
	into #total_sales
	FROM  #books sbmp	  
	inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
	 and sdht.template_name 
		in ('peak load','legacy sale','what if sale trade' ,'control area outbound schedules','firm sales from trades','non firm sales from trades','Legacy Purchase','What if Purchase Trade','Control Area Inbound Schedules','Firm purchases from trades','non firm purchases from trades','What If Sales')
	--	and template_name='Physical Power Sales' 
		--and (template_name='Physical Power Sales' or  template_name =case when @process_id is null then '----' else 'What If Sales' end)
	inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
	inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
		and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(REPLACE(sddh.hr,':00','') -1 as varchar),2)+':00:00.000' as datetime) 
		between @term_start_hr and @term_end_hr
	outer apply
		( 
			select  u5.udf_value
   			from  [user_defined_deal_fields] u5 
				inner JOIN [dbo].[user_defined_deal_fields_template] uddft5 ON  isnumeric(u5.udf_value)=1 
					and	 u5.source_deal_header_id=sdh.source_deal_header_id and uddft5.field_id =@firm
					AND uddft5.udf_template_id = u5.udf_template_id 
		)  firm
	outer apply
	(
	select case when @org_flag ='g' then 
			case when sdht.template_name='What If Sales' then 
				case when firm.udf_value=1 then
					case when (case when sdd.buy_sell_flag='s' then -1 else 1 end *sddh.volume)<0 then 'Firm sales from trades' else  'Firm purchases from trades' end
				else
					case when (case when sdd.buy_sell_flag='s' then -1 else 1 end *sddh.volume)<0 then 'Non Firm sales from trades' else  'Non Firm purchases from trades' end
				end
			else sdht.template_name end
		else cast(null as varchar(150)) end	 sales_name

	)	sales_name


	--where sdd.term_start between @term_start and @term_end

	group by sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT), sddh.is_dst
		,sales_name.sales_name
		,case when @org_flag ='g' then
			case when sales_name.sales_name in ('peak load','legacy sale','what if sale trade' ,'control area outbound schedules','firm sales from trades','non firm sales from trades') then 'Loads' else 'Purchases' end
		 else 
			case when sdht.template_name in ('peak load','legacy sale' ,'control area outbound schedules','Legacy Purchase','Control Area Inbound Schedules') then 'Loads' 
		 		when sdht.template_name in ('firm sales from trades','non firm sales from trades','Firm purchases from trades','non firm purchases from trades','What If Sales'	)  then 'Net Transactions'
		 	 else '' end
		  end 




	SELECT 
		sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT) hr,
		cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(sddh.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
		sddh.is_dst,
		sum( sddh.volume) volume
	into #total_purchases
	FROM  #books sbmp	  
	inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
	 and sdht.template_name 
		in ( 'Legacy Purchase','Control Area Inbound Schedules','Firm purchases from trades','non firm purchases from trades','What If Sales')

	inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
	inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
		and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(REPLACE(sddh.hr,':00','') -1 as varchar),2)+':00:00.000' as datetime) 
		between @term_start_hr and @term_end_hr
	
	where  sddh.volume>0 and sdd.buy_sell_flag='b'
	group by sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT), sddh.is_dst
	





--select * from #total_sales where datepart(hour,term_hr)=0
--return
	SELECT sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT) hr,
		cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(sddh.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
		sddh.is_dst,
		cast(0 as numeric(12,0)) [Total Spin]
		,cast(0 as numeric(12,0)) [Online Unit Spin]
		,sum( case when sdd.buy_sell_flag='s' then -1 else 1 end * sddh.volume) [Contracted Spin Sales]
	into #reserves
	FROM  #books sbmp	  
	inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
			AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
	inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
		and template_name in ('purchase spin','sale spin')
	inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
	inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
		and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(REPLACE(sddh.hr,':00','') -1 as varchar),2)+':00:00.000' as datetime) 
		between @term_start_hr and @term_end_hr
	group by sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT),sddh.is_dst


 
	select tsd.time_series_definition_id,sd.maturity,sd.value, sd.is_dst into #time_series_data from dbo.time_series_definition tsd 
	cross apply (
		select  d.maturity,	max(d.effective_date) effective_date from   dbo.time_series_data d  
		inner join #tmp_hr th on th.term_hr	 = d.maturity	 and  d.time_series_definition_id=tsd.time_series_definition_id
			and  isnull(d.effective_date,th.term_hr)<=isnull(d.maturity,th.term_hr)  
		group by 	 d.maturity 
	) eff
	inner join dbo.time_series_data sd on  sd.time_series_definition_id=tsd.time_series_definition_id and isnull(sd.effective_date,'1900-01-01')=isnull(eff.effective_date,'1900-01-01')
		and  isnull(sd.maturity,'1900-01-01')=isnull(eff.maturity,'1900-01-01')

	SELECT sdh.source_deal_header_id,tsd.maturity,is_dst,max(tsd.value) [status]
	into #online_status
	FROM  #tmp_deals sdh
	inner join #time_series_data tsd on tsd.time_series_definition_id =sdh.udf_time_series_id
	group by sdh.source_deal_header_id,tsd.maturity,is_dst



	if @xml is not null	and @flag='w'
	begin
		set @st='
			update #total_sales set volume=ts.volume+x.[value]
			  from #total_sales ts 
			  inner join #save_xml x on ts.term_date=x.term and ts.hr=x.[hour] AND ts.is_dst = x.is_dst AND x.process_row_id NOT IN(1,2) and ts.sales_type=''Net Transactions'''	  
		--print @st
		exec(@st)

		set @st='
			update #online_status set [status]=x.[value]
			  from #online_status ts
			inner join #save_xml x on CONVERT(VARCHAR(10),ts.maturity,120)=x.term and DATEPART(hh,ts.maturity)+1=x.[hour] AND ts.is_dst = x.is_dst
			WHERE x.process_row_id = ts.source_deal_header_id
			'

		--print @st
		exec(@st)
	  

		--set @st='
		--	update #online_status set [status]=x.[value]
		--	  from #online_status ts
		--	inner join #save_xml x on CONVERT(VARCHAR(10),ts.maturity,120)=x.term and DATEPART(hh,ts.maturity)+1=x.[hour] AND ts.is_dst = x.is_dst
		--	WHERE x.process_row_id = 2
		--	'  
		----print @st
		--exec(@st)
	
	end

	SELECT sdh.source_deal_header_id,tsd.maturity,is_dst,nullif(max(tsd.value),0) [usage]
	into #capacity_usage
	FROM  #tmp_deals sdh
	inner join #time_series_data tsd on tsd.time_series_definition_id =sdh.udf_capacity_usage_id
	group by sdh.source_deal_header_id,tsd.maturity,is_dst

	SELECT sdh.source_deal_header_id,sddh.term_date,sddh.hr,sddh.term_hr,sddh.is_dst,
		sum(sddh.volume) volume,sum(pr.price) price
	into #online_capacity_pre
	FROM  #tmp_deals sdh
	inner join  source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
	cross apply
	( 
		select 
			h.term_date,CAST(REPLACE(h.hr,':00','') AS INT) hr,h.is_dst,sum(h.volume) volume,	
			cast(convert(varchar(10),h.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(h.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime)  term_hr
		from  source_deal_detail_hour h where h.source_deal_detail_id=sdd.source_deal_detail_id
			and cast(convert(varchar(10),h.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(h.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime) 
				between @term_start_hr and @term_end_hr
			AND sdd.buy_sell_flag='b'
		group by h.term_date,CAST(REPLACE(h.hr,':00','') AS INT),h.is_dst		
	) sddh
	outer apply
	(
		select max(as_of_date) as_of_date from dbo.source_price_curve  where source_curve_def_id =sdd.curve_id 	 
		 and maturity_date=sddh.term_date and curve_source_value_id=4500
		 AND is_dst = sddh.is_dst
	) asofdate 
	outer apply
	( 
		select max(curve_value) price from  dbo.source_price_curve 
		where source_curve_def_id =sdd.curve_id and as_of_date= asofdate.as_of_date	 
				and maturity_date=sddh.term_date and curve_source_value_id=4500 
				AND sdd.buy_sell_flag='s' 
				AND is_dst = sddh.is_dst

	) pr
	group by sdh.source_deal_header_id,sddh.term_date,sddh.hr,sddh.term_hr,sddh.is_dst

	-- what -if
	DECLARE @source_deal_header_id VARCHAR(100)
	SELECT @source_deal_header_id = source_deal_header_id FROM source_Deal_header WHERE deal_id ='What If Sales'
	 	
	SELECT sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT) hr,
		cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(sddh.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
		sddh.is_dst,
		sum(ISNULL(x.value,volume)) [whatif_value]
	into #whatif
	FROM  
	 source_deal_header sdh 
	inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
	inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
		and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(CAST(REPLACE(sddh.hr,':00','') AS INT) -1 as varchar),2)+':00:00.000' as datetime) 
		between @term_start_hr and @term_end_hr
	LEFT JOIN #save_xml x on sddh.term_date=x.term and cast(replace(sddh.hr,':00','')as int)=x.[hour] AND sddh.is_dst = x.is_dst AND x.process_row_id = sdh.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	group by sddh.term_date,CAST(REPLACE(sddh.hr,':00','') AS INT),sddh.is_dst

	SELECT 
		p.source_deal_header_id,
		sdh.location_id,
		p.term_date,p.hr,p.term_hr,
		p.is_dst,
		isnull(cu.[usage],p.volume)*os.[status] volume	,CAST(0 AS numeric(20,8)) AS  price
	,CASE WHEN p.volume = 0 THEN 0 ELSE os.[status] END [status],sdh.order_id,sdh.udf_time_series_id 
		,cast(0 as numeric(20,8)) tot_sales	-- total sales
		,CAST(isnull(sdh.min_capacity,0)*isnull(os.[status],0) AS numeric(20,8))  min_cap_vol	-- minimum cap volume.
		,CAST(isnull(sdh.max_capacity,0)*isnull(os.[status],0) AS numeric(20,8)) max_cap_vol	-- minimum cap volume.
	--	,cast(0 as numeric(12,0)) remaining_sales	-- total sales after duducting min capacity vol
	--	,CAST((isnull(cu.[usage],p.volume)-isnull(sdh.min_capacity,0))*isnull(os.[status],0) AS numeric(20,8)) remaining_cap_volume -- online capacity volume after duducting min capacity vol.
		,CAST((isnull(cu.[usage],p.volume))*isnull(os.[status],0) AS numeric(20,8)) remaining_cap_volume 
		,cast(0 as numeric(20,8)) running_sum_cap_vol	-- 
		,cast(0 as numeric(20,8)) tot_cap_vol --min_cap_vol+remaining_cap_volume.
		------------------Base Case--------------------------
		,cast(0 as numeric(20,8)) MMBTU_required
		,cast(0 as numeric(20,8)) fuel_om
		,cast(0 as numeric(20,8)) mwh
		------------------What If--------------------------
		,cast(0 as numeric(20,8)) MMBTU_required1
		,cast(0 as numeric(20,8)) fuel_om1
		,cast(0 as numeric(20,8)) mwh1
		,cast(0 as numeric(20,8)) AS total_cost	
		,cast(0 as numeric(20,8)) offline_reserves
		,cast(0 as numeric(20,8)) offline_10min_capacity
		,off_volume=case when os.[status]=0 then isnull(cu.[usage],p.volume) else 0 end
		,cu.[usage] capacity_usage
		,case when @org_flag ='g' then p.volume else isnull(cu.[usage],p.volume) end volume_no_status
	,cast(0 as numeric(20,8)) AS total_min_cap
		,CAST(0 as numeric(20,8)) heat_rate
		,CAST(p.volume AS numeric(20,8))  actual_volume	
		,CAST(isnull(sdh.min_capacity,0) as numeric(20,8))  actual_min_cap_vol
		,CAST(isnull(sdh.max_capacity,0) as numeric(20,8)) actual_max_cap_vol
	into
		#online_capacity
	from 
		#tmp_deals sdh 
		inner join #online_capacity_pre p on sdh.source_deal_header_id=p.source_deal_header_id   
		left join #online_status os on os.source_deal_header_id=p.source_deal_header_id and os.maturity=p.term_hr AND os.is_dst=p.is_dst 
		--left join #total_sales ts on ts.term_hr=p.term_hr
		left join #capacity_usage cu on cu.source_deal_header_id=p.source_deal_header_id and cu.maturity=p.term_hr  AND cu.is_dst=p.is_dst	

	if @org_flag <>'g'
	begin 

		update  #online_capacity  set 	tot_sales=ts.volume from  #online_capacity oc 
		cross apply
		 (	
			select abs(sum(volume)) volume   from #total_sales where term_hr=oc.term_hr and is_dst=oc.is_dst
		  ) ts 

	
	
			SELECT 
				sddh.term_date,sddh.hr,
				cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(cast(replace(sddh.hr,':00','')as int) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
				sddh.is_dst,
				sum(case when sdd.buy_sell_flag='s' then -1 else 1 end *  sddh.volume) volume
								
			into 
			
			#reserves_adj
			FROM  #books sbmp	  
			inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
					AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
					AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
					AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
			inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
				and sdht.template_name in ('purchase spin','sale spin')
			inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
			inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
				and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(cast(replace(sddh.hr,':00','')as int) -1 as varchar),2)+':00:00.000' as datetime) 
				between @term_start_hr and @term_end_hr
			group by sddh.term_date,sddh.hr, sddh.is_dst 			




		update #reserves set [Online Unit Spin]=	tot.volume +isnull(s.volume,0)- isnull(ra.volume,0)
						, [Total Spin]=	[Contracted Spin Sales]	 -(tot.volume -isnull(s.volume,0))- isnull(ra.volume,0)
				 from #reserves r --inner join	  #total_sales	s on r.term_hr=s.term_hr AND r.is_dst=s.is_dst
		cross apply
		(
			 select sum(volume) volume from #total_sales where term_hr=r.term_hr AND is_dst=r.is_dst
		) s
		cross apply
		(
			 select sum(volume) volume from #online_capacity where term_hr=r.term_hr AND is_dst=r.is_dst
		) tot
		
		left  join #reserves_adj  ra  on r.term_hr=ra.term_hr AND r.is_dst=ra.is_dst
		
		
		SELECT 
			gmv.clm1_value effective_date,
			gmv.clm2_value generator,
			gmv.clm3_value fuel,
			gmv.clm4_value curve,
			gmv.clm5_value heat_rate
		INTO 
			#generic_mapping_hr
		FROM 
			generic_mapping_header gmh
			INNER JOIN generic_mapping_values gmv ON gmh.mapping_table_id = gmv.mapping_table_id
		WHERE 
			gmh.mapping_name = 'Generator Fuel Cost'

			----select * from adiha_process.dbo.power_solver_farrms_admin_4B4A4D9F_73A1_4203_B785_E918742029A8

		update #online_capacity	set 
		     price=pc.curve_value
			 ,heat_rate=ISNULL(gmh.heat_rate,sdh.heat_rate) 	
			 		from  #tmp_deals sdh 
			inner join #online_capacity p on sdh.source_deal_header_id=p.source_deal_header_id 
			OUTER APPLY
			(SELECT
				gmh.heat_rate,gmh.curve
			FROM 
				source_deal_header sdh1
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh1.template_id AND uddft.field_label = 'Fuel Type' 
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id AND uddf.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN time_series_definition tsd ON CAST(tsd.time_series_definition_id AS VARCHAR) = uddf.udf_value
				INNER JOIN time_series_data ts ON ts.time_series_definition_id = tsd.time_series_definition_id AND ts.maturity = p.term_hr
					AND ts.is_dst = p.is_dst
				INNER JOIN #generic_mapping_hr gmh ON gmh.generator = sdh.location_id
					AND gmh.fuel = ts.value
			WHERE
				 sdh1.source_deal_header_id = sdh.source_deal_header_id
			) gmh
			OUTER APPLY(
				SELECT 
					curve_value
				FROM
					source_price_curve_def spcd
					INNER JOIN source_price_curve spc ON spcd.source_curve_def_id = spc.source_curve_def_id 
				WHERE CAST(spc.source_curve_def_id AS VARCHAR) = gmh.curve
					AND ((spcd.Granularity = 980 AND CONVERT(VARCHAR(7),spc.maturity_date,120) = CONVERT(VARCHAR(7),p.term_date,120))
							OR (spcd.Granularity = 981 AND CONVERT(VARCHAR(10),spc.maturity_date,120) = CONVERT(VARCHAR(10),p.term_date,120))
							OR (spcd.Granularity = 982 AND spc.maturity_date = p.term_hr AND spc.is_dst = p.is_dst)
						)
			) pc
			
		if isnull(@solver_decision,'n')='n'
		begin

		 ---Allocating Remaining Sales after deducting minimum capacity volume---------
				----------------------------------------------------------------------------
			UPDATE oc
					SET oc.total_min_cap = oc1.min_cap_vol
				FROM 
					#online_capacity oc
					OUTER APPLY(SELECT SUM(min_cap_vol) min_cap_vol FROM #online_capacity WHERE term_hr = oc.term_hr AND is_dst = oc.is_dst AND  term_date IS NOT NULL) oc1

			update #online_capacity	set 	
							running_sum_cap_vol=  run_sum.volume
					from   #online_capacity p  
					outer apply
					(
						select sum(isnull(remaining_cap_volume,0)) volume	 
						from #online_capacity  where order_id<= p.order_id
							and term_hr=p.term_hr and isnull([status],0)=1
							AND is_dst=p.is_dst
					) run_sum
					where run_sum.volume-isnull(p.remaining_cap_volume,0)<=p.tot_sales
							and isnull([status],0)=1
	
				update #online_capacity	 	
						set	remaining_cap_volume=  0
					from #online_capacity p
						where  running_sum_cap_vol=0

				update #online_capacity	set 	
									tot_cap_vol=  remaining_cap_volume
							from #online_capacity p
								where  running_sum_cap_vol<=p.tot_sales	and isnull([status],0)=1 and running_sum_cap_vol<>0

				update #online_capacity	set 	
									tot_cap_vol=  remaining_cap_volume-(running_sum_cap_vol-p.tot_sales)
							from #online_capacity p
								where  running_sum_cap_vol>p.tot_sales	and isnull([status],0)=1 and running_sum_cap_vol<>0


    --   select total_min_cap,* from #online_capacity p where term_date='2016-01-01' price is null where datepart(hour,term_hr)=0 order by order_id
		end
		else
		begin

			set @st='SELECT p.source_deal_header_id,p.term_hr,p.is_dst,sdh.coefficient_a,sdh.coefficient_b,sdh.coefficient_c
						,sdh.variable_om_rate,price,sdh.min_capacity,p.volume max_capacity --sdh.max_capacity ---p.volume --
						, p.tot_sales	TotalMw
						, cast(0 as numeric(28,8)) lambada, cast(0 as numeric(28,8)) solver_value
					into '+ @power_solver +'
					from #tmp_deals sdh 
						inner join #online_capacity p on sdh.source_deal_header_id=p.source_deal_header_id 
					--	left join #total_purchases tp on tp.term_hr=p.term_hr and tp.is_dst=p.is_dst
						where p.term_hr is not null and nullif(p.volume,0) is not null and p.tot_sales>0			
						
						' 
--select * from adiha_process.dbo.power_solver_farrms_admin_EFD709EE_468C_46A9_BE6E_72722A53E8D3 order by 2,1

			EXEC spa_print @st
			exec(@st)  
			--return
		--	select * from  adiha_process.dbo.power_solver_farrms_admin_3521DE12_F6A6_4601_85A4_79C1C96AEA88 order by 2,1
			--  select * from #tmp_msg

			--call solver decisin		???????????????????????????????

			----insert into #tmp_msg  exec spa_run_power_solver_package @process_id,'y'

			exec spa_calc_power_solver @process_id

			set @st='	
				select max(totalmw) totalmw,sum(round(solver_value,0)) solver_value,term_hr,max(totalmw) -sum(round(solver_value,0)) diff_value
				into #round_diff
				from '+ @power_solver +'
				group by term_hr having max(totalmw) <>sum(round(solver_value,0));

				--select * from #round_diff
				update s set  solver_value =s.solver_value+d.diff_value
				from '+ @power_solver +' s inner join #round_diff d
				on s.term_hr=d.term_hr
				outer apply
				(
					select top(1) source_deal_header_id from '+ @power_solver +' where	term_hr=d.term_hr and d.diff_value<0 
						order by (solver_value-min_capacity) desc 
				) rnd_sur
				outer apply
				(
					select top(1) source_deal_header_id from '+ @power_solver +' where term_hr=d.term_hr and d.diff_value>0 
						order by (max_capacity-solver_value) desc 
				) rnd_dif
				where s.source_deal_header_id=isnull(rnd_sur.source_deal_header_id,rnd_dif.source_deal_header_id)
'
			--print @st
			exec(@st)  



			  ---tot_cap_vol= mmbtu	ax2+bx+c

			set @st='update #online_capacity set tot_cap_vol=round(s.solver_value,0)
					,MMBTU_required=(s.coefficient_a*power(round(s.solver_value,0),2))+(s.coefficient_b*(round(s.solver_value,0)))+s.coefficient_c from '+ @power_solver +' s
						inner join #online_capacity p on s.source_deal_header_id=p.source_deal_header_id 
							and p.term_hr=s.term_hr and p.is_dst =s.is_dst'
							 
-- select * from #online_capacity order by 5,1where datepart(hour,term_hr)=0
		  -- exec spa_print @st
		   exec(@st)


		---return

		end
		 ---------------------------------------------------------------------------------------------------------------------------

		 -------------------------------------------------------------------------------------------------------------------------
		------------calc logic--------------------------------------------------------------------------------------------------

		update #online_capacity	set 	
				MMBTU_required	=mmbtu.MMBTU_required,	 ---tot_cap_vol= mmbtu	ax2+bx+c
			fuel_om = (tot_cap_vol*sdh.variable_om_rate)+ (mmbtu.MMBTU_required  * price)--ISNULL(gmh.heat_rate,sdh.heat_rate) * tot_cap_vol
			,mwh =(mmbtu.MMBTU_required * price ) 
			,total_cost = (mmbtu.MMBTU_required * price )  +	(tot_cap_vol*sdh.variable_om_rate)
		from  #tmp_deals sdh 
			inner join #online_capacity p on sdh.source_deal_header_id=p.source_deal_header_id 
			OUTER APPLY
			(SELECT
				gmh.heat_rate,gmh.curve
			FROM 
				source_deal_header sdh1
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh1.template_id AND uddft.field_label = 'Fuel Type' 
				INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id AND uddf.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN time_series_definition tsd ON CAST(tsd.time_series_definition_id AS VARCHAR) = uddf.udf_value
				INNER JOIN time_series_data ts ON ts.time_series_definition_id = tsd.time_series_definition_id AND ts.maturity = p.term_hr
					AND ts.is_dst = p.is_dst
				INNER JOIN #generic_mapping_hr gmh ON gmh.generator = sdh.location_id
					AND gmh.fuel = ts.value
			WHERE
					sdh1.source_deal_header_id = sdh.source_deal_header_id
			) gmh

			OUTER APPLY
			(
			select abs(case when isnull(@solver_decision,'n')='n' then ISNULL(gmh.heat_rate,sdh.heat_rate) * tot_cap_vol else MMBTU_required end) MMBTU_required
				) mmbtu
			

		update a	set 	
			a.mwh = b.mwh
		FROM
		#online_capacity a
		OUTER APPLY  
		(
			SELECT 	SUM(fuel_om)/NULLIF(SUM(tot_cap_vol),0) mwh
			from  #online_capacity WHERE term_hr = a.term_hr AND is_dst = a.is_dst

		) b	
	
	
		 UPDATE a
			SET tot_sales = tot_sales-ISNULL(x.value,0)
		 FROM
			#online_capacity a 
			 LEFT JOIN #save_xml x on  CONVERT(VARCHAR(10),a.term_hr,120)=x.term and DATEPART(hh,a.term_hr)+1=x.[hour] AND a.is_dst = x.is_dst AND x.process_row_id NOT IN(1,2)

		if @flag <> 'w'
		BEGIN
			-- Insert into Detail calculation Table
			DELETE 
				odb
			FROM 
				operational_dashboard_detail odb
				INNER JOIN #online_capacity oc ON 
					--odb.source_deal_header_id = oc.source_deal_header_id
					ISNULL(odb.term_hr,'') = ISNULL(oc.term_hr,'')
	

			INSERT INTO operational_dashboard_detail(source_deal_header_id,location_id,term_date,hr,term_hr,is_dst,volume,price,status,order_id,udf_time_series_id,tot_sales,min_cap_vol,max_cap_vol,remaining_cap_volume,running_sum_cap_vol,tot_cap_vol,MMBTU_required,fuel_om,mwh,MMBTU_required1,fuel_om1,mwh1,total_cost,heat_rate)
			SELECT 
				source_deal_header_id,location_id,term_date,hr,term_hr,is_dst,volume,price,status,order_id,udf_time_series_id,tot_sales,min_cap_vol,max_cap_vol,remaining_cap_volume,running_sum_cap_vol,tot_cap_vol,MMBTU_required,fuel_om,mwh,MMBTU_required1,fuel_om1,mwh1,total_cost,heat_rate
			FROM
				#online_capacity
		 END --@flag <>'w'
	end  ----@org_flag <>'g'


	-----------------------------------------------------------------------------------------------------------
	------------Prepare output format---------------------------------------------------------------------------
				   
	select @column_list=isnull(@column_list+',','')+ '['+convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +']' from 
		(select distinct term_hr,is_dst from #online_capacity where term_hr is not null ) a
	
	SELECT @column_list_sel = isnull(@column_list_sel+',','')+ 'ROUND(['+convert(varchar(16),term_hr,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +'],2)'+'['+convert(varchar(16),term_hr,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +']' 
	from (select distinct term_hr,is_dst from #online_capacity where term_hr is not null ) a
	
		-- select order_id=identity(int,1,1), term_start term_hr into #tmp_hr from [dbo].[FNATermBreakdown]('h' ,'2015-01-01 00:00:00.000' ,'2015-01-02 00:00:00.000')

	declare @sql_select varchar(max) , @st1 varchar(max)


	   ---------------------------------------------------Online Status--------------------------------------------------------------------------------
	 ----============================================================================================================================================

	if object_id(@power_dashboard) is null or @org_flag ='g'
	begin
		set @sql_select='	
			SELECT cast(''Online Status'' as varchar(100)) [group], sdv.[description] group2,sdh.deal_id,'''+@process_id+''' process_id 
			,rowid=identity(int,1,1),sdh.source_deal_header_id ref_id,'+@column_list_sel

		set @st='
			FROM (
				SELECT source_deal_header_id, convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr ,[pivot_value_field] pivot_value FROM #online_capacity
			) as s
			PIVOT
			(
				sum(pivot_value)
				FOR term_hr  IN ('+ @column_list+')
			) AS pvt
			inner join #tmp_deals sdh on sdh.source_deal_header_id=pvt.source_deal_header_id
			left join static_data_value sdv on sdv.value_id=sdh.generation_category 
	
			'

		if  @org_flag ='g'
		begin
			set @sql_select='	
				SELECT cast(''Capacity Usage'' as varchar(100)) [group], cast('''' as varchar(250)) group2,sdh.deal_id,'''+@process_id+''' process_id 
				,rowid=identity(int,1,1),sdh.source_deal_header_id ref_id,'+@column_list

			 set @sql_select= @sql_select+	' 
				INTO '+ @power_dashboard
				+ replace(@st,'[pivot_value_field]','[capacity_usage]')

				--print(@sql_select)
				exec(@sql_select)
					
			set @sql_select='
			insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
			SELECT '''+@process_id+''' process_id,''Online Status'' [group], sdv.[description] group2,sdh.deal_id,sdh.source_deal_header_id ref_id ,'+@column_list

		end
		else
		begin

			set @sql_select='	
				SELECT cast(''Online Status'' as varchar(100)) [group], cast(sdv.[description] as varchar(250)) group2,sdh.deal_id,'''+@process_id+''' process_id 
				,rowid=identity(int,1,1),sdh.source_deal_header_id ref_id,'+@column_list

		end
		
		set @sql_select= @sql_select+
			case  when @org_flag ='g' then '' else ' INTO '+ @power_dashboard end
				+ replace(@st,'[pivot_value_field]','[status]')

		--print(@sql_select)
		exec(@sql_select)


	   ---------------------------------------------------Online Capacity--------------------------------------------------------------------------------
	 ----============================================================================================================================================
		set @sql_select='
			insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
			SELECT '''+@process_id+''' process_id,''Online Capacity'' [group], sdv.[description] group2,sdh.deal_id,sdh.source_deal_header_id ref_id ,'+@column_list


		 set @sql_select= @sql_select 
			+ replace(@st,'[pivot_value_field]','[volume_no_status]')

		 --print(@sql_select)
		 exec(@sql_select)
		 EXEC ('SELECT * INTO ' + @power_dashboard_generation + ' FROM #online_capacity')


		if  @org_flag ='g'
		begin

			SELECT 
				sddh.term_date,sddh.hr,
				cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(cast(replace(sddh.hr,':00','')as int) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
				sddh.is_dst,
				sum(case when sdd.buy_sell_flag='s' then -1 else 1 end *  sddh.volume) volume
				,sdht.template_name
			into #spin_requirement
			FROM  #books sbmp	  
			inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
					AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
					AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
					AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
			inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
			 and sdht.template_name in ('spin requirement')
			inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
			inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
				and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(cast(replace(sddh.hr,':00','')as int) -1 as varchar),2)+':00:00.000' as datetime) 
				between @term_start_hr and @term_end_hr
			group by sddh.term_date,sddh.hr, sddh.is_dst ,sdht.template_name
				
			
			SELECT 
				sddh.term_date,sddh.hr,
				cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(cast(replace(sddh.hr,':00','')as int) -1 as varchar),2)+':00:00.000' as datetime)  term_hr,
				sddh.is_dst,
				abs(sum(case when sdd.buy_sell_flag='s' then -1 else 1 end *  sddh.volume)) volume
				,sdht.template_name
				
			into #ancillary
			FROM  #books sbmp	  
			inner join source_deal_header sdh ON sdh.source_system_book_id1 = sbmp.source_system_book_id1 
					AND sdh.source_system_book_id2 = sbmp.source_system_book_id2 
					AND sdh.source_system_book_id3 = sbmp.source_system_book_id3 
					AND sdh.source_system_book_id4 = sbmp.source_system_book_id4  
			inner join source_deal_header_template sdht on sdht.template_id=sdh.template_id
				and sdht.template_name in ('purchase spin','purchase 10min spin','sale spin','sale 10min spin','interruptible loads')
			inner join source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
			inner join source_deal_detail_hour sddh on sddh.source_deal_detail_id=sdd.source_deal_detail_id
				and cast(convert(varchar(10),sddh.term_date,120)+ ' ' + right('00'+cast(cast(replace(sddh.hr,':00','')as int) -1 as varchar),2)+':00:00.000' as datetime) 
				between @term_start_hr and @term_end_hr
			group by sddh.term_date,sddh.hr, sddh.is_dst ,sdht.template_name			
			
			
			update #online_capacity set 	offline_reserves=off_volume
				,offline_10min_capacity=case when sdh.ten_minute_reserve='1' then  off_volume else 0 end
			 from  #online_capacity oc
				inner join #tmp_deals sdh  on sdh.source_deal_header_id=oc.source_deal_header_id 
		 

	   ---------------------------------------------------Sales--------------------------------------------------------------------------------
		 ----============================================================================================================================================
		if @org_flag ='g'
		BEGIN
			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,case when sales_type in (''Loads'') then '''' else ''Online Capacity'' end [group], sales_type group2,sales_name deal_id ,null ref_id,'+@column_list

			set @st='
				FROM (
					SELECT  sales_type,sales_name,convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name] where sales_type<>''Loads''
						group by sales_type,sales_name,term_hr,is_dst
				) as s
				PIVOT
				(
					sum(pivot_value)
					FOR term_hr IN ('+ @column_list+')
				) AS pvt
				'	
			 set @sql_select= @sql_select 
				+ replace(replace(@st,'[pivot_value_field]','abs(sum([volume]))'), '[source_table_name]','#total_sales')

			-- exec spa_print @sql_select
			 exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Online Capacity'' [group], ''Purchases'' group2,''What if Purchase Trade +ve'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')
				
			-- exec spa_print @sql_select
			 exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,case when sales_type in (''Loads'',''Purchases'') then '''' else ''Online Capacity'' end [group], sales_type group2,sales_name deal_id ,null ref_id,'+@column_list

			set @st='
				FROM (
					SELECT  sales_type,sales_name,convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]  where sales_type=''Loads''
						group by sales_type,sales_name,term_hr,is_dst
				) as s
				PIVOT
				(
					sum(pivot_value)
					FOR term_hr IN ('+ @column_list+')
				) AS pvt
				'	
			 set @sql_select= @sql_select 
				+ replace(replace(@st,'[pivot_value_field]','abs(sum([volume]))'), '[source_table_name]','#total_sales')

		--	 exec spa_print @sql_select
			 exec(@sql_select)

			 set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,'''' [group], ''Loads'' group2,''What if sale trade -ve'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

			-- exec spa_print @sql_select
			 exec(@sql_select)

		end 

		if @org_flag <> 'g'
		
		BEGIN

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,case when sales_type=''Loads'' then '''' else ''Online Capacity'' end [group], sales_type group2,sales_name deal_id ,null ref_id,'+@column_list

			set @st='
				FROM (
					SELECT  sales_type,sales_name,convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]
						group by sales_type,sales_name,term_hr,is_dst
				) as s
				PIVOT
				(
					sum(pivot_value)
					FOR term_hr IN ('+ @column_list+')
				) AS pvt
				'	
			set @sql_select= @sql_select 
			+ replace(replace(@st,'[pivot_value_field]','abs(sum([volume]))'), '[source_table_name]','#total_sales')

			---print(@sql_select)
			exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Net Transactions and Load'' [group], '''' group2,''What If + Purchase , - Sale'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

				--print(@sql_select)
			exec(@sql_select)
			
		end ---sales
		if @org_flag = 'g'
		BEGIN		
			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Required Spin'' [group], '''' group2,''Spin requirement'' deal_id,null ref_id ,'+@column_list

			set @st='
				FROM (
					SELECT  convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]
						group by term_hr,is_dst
				) as s
				PIVOT
				(
					sum(pivot_value)
					FOR term_hr IN ('+ @column_list+')
				) AS pvt'


			set @sql_select= @sql_select 
				+ replace(replace(@st,'[pivot_value_field]','sum([volume])'), '[source_table_name]','#spin_requirement')

			--print(@sql_select)
			exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Spin'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

			-- exec spa_print @sql_select
			 exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Spin with 10 minute ancillary spin deals'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

		---	 exec spa_print @sql_select
			 exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Spin available upon cutting non firm sales'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

			-- exec spa_print @sql_select
			 exec(@sql_select)

			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Spin upon cutting non firm purchases'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

			-- exec spa_print @sql_select
			 exec(@sql_select)
			 
			 	
			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Spin upon cutting interruptible loads'' deal_id ,null ref_id,'+replace(@column_list,'[','0 [')

		--	 exec spa_print @sql_select
			 exec(@sql_select)



 			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Offline reserves'' deal_id ,null ref_id,'+@column_list

	
			 set @sql_select= @sql_select 
				+ replace(replace(@st,'[pivot_value_field]','sum([offline_reserves])'), '[source_table_name]','#online_capacity')

			-- exec spa_print @sql_select
			 exec(@sql_select)

 			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Ancillary'' [group], '''' group2,template_name deal_id ,null ref_id,'+@column_list

	
			set @st='
				FROM (
					SELECT  template_name,convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM	[source_table_name]
						group by template_name,term_hr,is_dst
				) as s
				PIVOT
				(
					sum(pivot_value)
					FOR term_hr IN ('+ @column_list+')
				) AS pvt
				'	

			 set @sql_select= @sql_select 
				+ replace(replace(@st,'[pivot_value_field]','sum([volume])'), '[source_table_name]','#ancillary')

			-- exec spa_print @sql_select
			 exec(@sql_select)

  			set @sql_select='
				insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
				SELECT '''+@process_id+''' process_id,''Ancillary'' [group], '''' group2,''Offline 10min capacity'' deal_id ,null ref_id,'+@column_list

			set @st='
				FROM (
					SELECT  convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]
						group by term_hr,is_dst
				) as s
				PIVOT
				(
					sum(pivot_value)
					FOR term_hr IN ('+ @column_list+')
				) AS pvt'
			 set @sql_select= @sql_select 
				+ replace(replace(@st,'[pivot_value_field]','sum([offline_10min_capacity])'), '[source_table_name]','#online_capacity')

			-- exec spa_print @sql_select
			 exec(@sql_select)

			exec('select * from '+@power_dashboard +' order by rowid' )
			return
		end --g  
	end


	   ---------------------------------------------------Mimimum Units--------------------------------------------------------------------------------
	 ----============================================================================================================================================

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Minimum Units'' [group], sdv.[description] group2,sdh.deal_id,sdh.source_deal_header_id ref_id ,'+@column_list


	set @sql_select= @sql_select 
		+ replace(@st,'[pivot_value_field]','[min_cap_vol]')

		--print(@sql_select)
	exec(@sql_select)	
	 
	   ---------------------------------------------------Sales--------------------------------------------------------------------------------
	 ----============================================================================================================================================
	 	 
		
	 --	declare @st1 varchar(max)
		--if @flag = 's'
		--BEGIN
	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Net Transactions and Load'' [group], '''' group2,sales_type deal_id ,null ref_id,'+@column_list

	set @st1='
		FROM (
			SELECT  sales_type,sales_name,convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]
				group by sales_type,sales_name,term_hr,is_dst
		) as s
		PIVOT
		(
			sum(pivot_value)
			FOR term_hr IN ('+ @column_list+')
		) AS pvt
		'	
	set @sql_select= @sql_select 
		+ replace(replace(@st1,'[pivot_value_field]','sum([volume_no_whatif])'), '[source_table_name]','#total_sales')

	--print(@sql_select)
	exec(@sql_select)

		 
	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Net Transactions and Load'' [group], '''' group2,''What If + Purchase , - Sale'' deal_id ,'''+@source_deal_header_id+''' ref_id,'+@column_list_sel

	set @st='
		FROM (
			SELECT  convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN ''-DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]
				group by term_hr,is_dst
		) as s
		PIVOT
		(
			sum(pivot_value)
			FOR term_hr IN ('+ @column_list+')
		) AS pvt
		'	
	set @sql_select= @sql_select 
	+ replace(replace(@st,'[pivot_value_field]','max([whatif_value])')	, '[source_table_name]','#whatif')

	--print(@sql_select)
	exec(@sql_select)



	---------------------------------------------------Reserves--------------------------------------------------------------------------------
	----============================================================================================================================================

	set @st='
		FROM (
			SELECT  convert(varchar(16),term_hr,120)+ CASE WHEN is_dst=1 THEN '' -DST'' ELSE '''' END term_hr,[pivot_value_field] pivot_value FROM [source_table_name]
				group by term_hr,is_dst
		) as s
		PIVOT
		(
			sum(pivot_value)
			FOR term_hr IN ('+ @column_list+')
		) AS pvt
		'	

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Online Unit Spin'' deal_id,null ref_id ,'+@column_list


	set @sql_select= @sql_select+	
		+ replace(replace(@st,'[pivot_value_field]','sum([Online Unit Spin])'), '[source_table_name]','#reserves')

		--print(@sql_select)
	exec(@sql_select)

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id],ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Contracted Net Spin'' deal_id ,null ref_id,'+@column_list


	set @sql_select= @sql_select+	
		+ replace(replace(@st,'[pivot_value_field]','sum([Contracted Spin Sales])'), '[source_table_name]','#reserves')

	--print(@sql_select)
	exec(@sql_select)

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id],ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Reserves'' [group], '''' group2,''Total Spin'' deal_id,null ref_id ,'+@column_list
	
	set @sql_select= @sql_select+	
		+ replace(replace(@st,'[pivot_value_field]','sum([Total Spin])'), '[source_table_name]','#reserves')

		--print(@sql_select)
	exec(@sql_select)

	---------------------------------------------------Solver Results--------------------------------------------------------------------------------
	----============================================================================================================================================

	 
	---------------------------------------------------Best case------------------------
	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Solver Results'' [group], ''Base Case'' group2,''MMBTU required'' deal_id ,null ref_id,'+@column_list

		set @sql_select= @sql_select 
		+ replace(replace(@st,'[pivot_value_field]','round(sum([MMBTU_required]),0)')	, '[source_table_name]','#online_capacity')

		--print(@sql_select)
		exec(@sql_select)

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Solver Results'' [group],''Base Case'' group2,''Fuel and O&M dollars'' deal_id ,null ref_id,'+@column_list

		set @sql_select= @sql_select 
		+ replace(replace(@st,'[pivot_value_field]','sum([fuel_om])')	, '[source_table_name]','#online_capacity')

		--print(@sql_select)
	exec(@sql_select)

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Solver Results'' [group],''Base Case'' group2,''$/mwh'' deal_id,null ref_id ,'+@column_list

	set @sql_select= @sql_select 
		+ replace(replace(@st,'[pivot_value_field]','abs(MAX([mwh]))')	, '[source_table_name]','#online_capacity')

		--print(@sql_select)
	exec(@sql_select)


		 --if @flag='b' --best case
	if @flag = 'w' --what if case
	begin
		exec('delete '+@power_dashboard+' where [group2]=''Base Case''')
		exec('delete '+@power_dashboard+' where [group2]=''Delta''')

		 -------------------------------------------------what if----------------------------------------------------------------------------------------------
		SELECT * INTO #base_case FROM operational_dashboard_detail WHERE term_hr BETWEEN @term_start_hr AND @term_end_hr 


		set @sql_select='
			insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id], ref_id,'+@column_list+')
			SELECT '''+@process_id+''' process_id,''Solver Results'' [group], ''Base Case'' group2,''MMBTU required'' deal_id ,null ref_id,'+@column_list_sel

			set @sql_select= @sql_select 
			+ replace(replace(@st,'[pivot_value_field]','round(sum([MMBTU_required]),0)')	, '[source_table_name]','#base_case')

			--print(@sql_select)
			exec(@sql_select)

		set @sql_select='
			insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
			SELECT '''+@process_id+''' process_id,''Solver Results'' [group], ''Base Case'' group2,''Fuel and O&M dollars'' deal_id,null ref_id ,'+@column_list_sel

		set @sql_select= @sql_select 
			+ replace(replace(@st,'[pivot_value_field]','sum([fuel_om])')	, '[source_table_name]','#base_case')

			--print(@sql_select)
			exec(@sql_select)

		set @sql_select='
			insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
			SELECT '''+@process_id+''' process_id,''Solver Results'' [group], ''Base Case'' group2,''$/mwh'' deal_id ,null ref_id,'+@column_list_sel

		set @sql_select= @sql_select 
			+ replace(replace(@st,'[pivot_value_field]','abs(MAX([mwh]))')	, '[source_table_name]','#base_case')

			--print(@sql_select)
		exec(@sql_select)

	end
		-------------------------------------------------what if----------------------------------------------------------------------------------------------

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id], ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Solver Results'' [group],''What If'' group2,''MMBTU required'' deal_id ,null ref_id,'+@column_list_sel

		set @sql_select= @sql_select 
		+ replace(replace(@st,'[pivot_value_field]','round(sum(['+CASE WHEN @flag='w' THEN 'MMBTU_required' ELSE 'MMBTU_required1' END +']),0)')	, '[source_table_name]','#online_capacity')

		--print(@sql_select)
		exec(@sql_select)

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group], [group2],[deal_id], ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Solver Results'' [group],''What If'' group2,''Fuel and O&M dollars'' deal_id ,null ref_id,'+@column_list_sel

	set @sql_select= @sql_select 
		+ replace(replace(@st,'[pivot_value_field]','sum(['+CASE WHEN @flag='w' THEN 'fuel_om' ELSE 'fuel_om1' END +'])')	, '[source_table_name]','#online_capacity')

		--print(@sql_select)
		exec(@sql_select)

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
		SELECT '''+@process_id+''' process_id,''Solver Results'' [group], ''What If'' group2,''$/mwh'' deal_id ,null ref_id,'+@column_list_sel

		set @sql_select= @sql_select 
		+ replace(replace(@st,'[pivot_value_field]','abs(MAX(['+CASE WHEN @flag='w' THEN 'mwh' ELSE 'mwh1' END +']))')	, '[source_table_name]','#online_capacity')

	--print(@sql_select)
	exec(@sql_select)


	----------------------------------------------------------------
	-----------------------------------------------------------------------------------
end

	

		-------------------------------------------------Delta----------------------------------------------------------------------------------------------

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
		SELECT process_id,''Solver Results'' [group], ''Delta'' group2,deal_id , ref_id,'+replace(replace(@column_list,'[','sum('+CASE WHEN @flag='w' THEN '' ELSE  '0*' END+'['),']','])')	+'
		FROM
		(
			SELECT process_id,''Solver Results'' [group], ''Delta'' group2, deal_id, ref_id ,'+@column_list
			+' FROM '+	@power_dashboard+ ' where group2=''What If''  and [group]=''Solver Results'' AND deal_id <>''$/mwh''
			union all
			SELECT process_id,''Solver Results'' [group], ''Delta'' group2, deal_id, ref_id ,'+replace(@column_list,'[','-1*[')
			+' FROM '+	@power_dashboard+ ' where group2=''Base Case''  and [group]=''Solver Results'' AND deal_id <>''$/mwh''
		) del group by process_id,[group] ,deal_id, ref_id
		'

	--print(@sql_select)
	exec(@sql_select)

	SET @column_list_sel = ''
	SELECT @column_list_sel = isnull(@column_list_sel+',','')+ 'abs(SUM(p.['+convert(varchar(16),term_hr,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +'])'+'/MAX(NULLIF(a.['+convert(varchar(16),term_hr,120)+CASE WHEN is_dst=1 THEN '-DST' ELSE '' END +'],0)))' 
	from (select distinct term_hr,is_dst from #online_capacity where term_hr is not null ) a

	set @sql_select='
		insert into '+@power_dashboard+' (process_id,[group],[group2],[deal_id], ref_id,'+@column_list+')
		SELECT process_id,''Solver Results'' [group], ''Delta'' group2,''$/mwh'' deal_id , NULL ref_id'+@column_list_sel+'
		FROM
		'+@power_dashboard+' p
		OUTER APPLY
		(
			SELECT '+@column_list
			+' FROM '+	@power_dashboard+ ' where deal_id = ''What If + Purchase , - Sale''
		
		) a 
		WHERE group2 = ''Delta'' AND deal_id=''Fuel and O&M dollars''
		group by process_id
		'

	--print(@sql_select)
	exec(@sql_select)
	
		

	
		-----------------------------------------------------------------------------------------------------------------------------------------------
	--print @power_dashboard
	if @flag='w'
	BEGIN
		EXEC('SELECT * FROM '+@power_dashboard+' ORDER BY rowid')
	END
	ELSE 
	BEGIN



		SET @st='
		SELECT [group], group2,deal_id,rowid,ref_id,CAST(REPLACE(term_dt,''-DST'','''') AS DATETIME) term_dt,CASE WHEN CHARINDEX(''-DST'',term_dt,1)>0 THEN 1 ELSE 0 END is_dst, value	INTO 
			#final_db_data
			FROM 
			(SELECT [group], group2,deal_id,rowid,ref_id,'+@column_list+'
				FROM '+@power_dashboard+'
			) p
		UNPIVOT
			(value FOR term_dt IN 
				('+@column_list+')
		)AS unpvt;


		DELETE odb
		FROM
			#final_db_data fdb
			INNER JOIN operational_dashboard_summary odb ON 
				CAST(fdb.term_dt AS DATETIME) = odb.term_dt;

		INSERT INTO operational_dashboard_summary(row_id,group1,group2,deal_id,ref_id,term_dt,is_dst,value)
		SELECT
			rowid,[group], group2,deal_id,ref_id,term_dt,is_dst,CASE WHEN deal_id = ''What If + Purchase , - Sale'' THEN 0 ELSE value END
		FROM
			#final_db_data 

		'



		exec spa_print @st
		EXEC(@st)
	
		--SELECT 'Success' as [type], 'Calculation completed successfully' as [message]
		EXEC spa_ErrorHandler 0
				, 'spa_process_power_dashboard'
				, 'spa_process_power_dashboard'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
	END
END
ELSE IF @flag = 't'
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @save_xml
		SELECT * INTO #save_xml_deal FROM
		(
			SELECT deal_id,[hour],ISNULL(NULLIF(term,''),@term_start) term,value,[type],is_dst
		FROM   OPENXML(@idoc, '/Root/grid', 1)
		   WITH (
			deal_id INT '@deal_id',
			[hour] INT '@hour',
			term datetime '@term',
			value FLOAT '@value',
			[type] CHAR '@type',
			is_dst INT '@is_dst'
		   )
		) a
		
		/*
		UPDATE sddh
		SET sddh.volume = sx.value
		FROM #save_xml sx
		INNER JOIN source_deal_detail sdd ON sx.deal_id = sdd.source_deal_header_id AND sx.type = 'd'
		INNER JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id 
		WHERE sddh.term_date = sx.term and sddh.hr = sx.[hour] and sddh.is_dst = sx.is_dst
		
		INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, volume, granularity)
		SELECT sdd.source_deal_detail_id, sx.term, sx.hour, sx.is_dst [is_dst], sx.value, 982 [granularity]
		FROM #save_xml sx
		INNER JOIN source_deal_detail sdd ON sx.deal_id = sdd.source_deal_header_id AND sx.type = 'd' AND sdd.term_start <= sx.term AND sdd.term_end >= sx.term
		LEFT JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id 
		WHERE sddh.source_deal_detail_id IS NULL
	*/
		
		UPDATE tsda
		SET tsda.value = sx.value 
		FROM #save_xml_deal sx
		INNER JOIN source_deal_header sdh ON sx.deal_id = sdh.source_deal_header_id
		INNER JOIN source_deal_header_template sdht on sdht.template_id = sdh.template_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdht.template_id AND field_name = '307148'
		INNER JOIN user_defined_deal_fields uddf ON sdh.source_deal_header_id = uddf.source_deal_header_id AND uddft.udf_template_id = uddf.udf_template_id
		INNER JOIN time_series_definition tsd ON  tsd.time_series_definition_id = uddf.udf_value
		INNER JOIN time_series_data tsda ON tsd.time_series_definition_id = tsda.time_series_definition_id
		WHERE sx.type = 't' AND tsda.maturity = dateadd(hour,sx.[hour]-1,sx.term) AND tsda.is_dst = sx.is_dst
		
		
		-- insert into source_deal_header
		CREATE TABLE #temp_inserted_deals(
			source_deal_header_id INT,
			term_start DATETIME,
			term_end DATETIME
		)
		
		CREATE TABLE #temp_inserted_deal_detail(
			source_deal_detail_id INT,
			term_start DATETIME,
			term_end DATETIME
		)


		DECLARE @deal_term_start DATETIME,@deal_term_End DATETIME

		SELECT @deal_term_start = MAX(term) FROM #save_xml_deal
		SELECT @deal_term_End = MAX(term) FROM #save_xml_deal

		
		INSERT INTO source_deal_header(source_system_id,deal_id,deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,entire_term_start,entire_term_end,source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,description1,description2,description3,deal_category_value_id,trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,broker_id,generator_id,status_value_id,status_date,assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by,generation_source,aggregate_environment,aggregate_envrionment_comment,rec_price,rec_formula_id,rolling_avg,contract_id,legal_entity,internal_desk_id,product_id,internal_portfolio_id,commodity_id,reference,deal_locked,close_reference_id,block_type,block_define_id,granularity_id,Pricing,deal_reference_type_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,broker_currency_id,deal_status,term_frequency,option_settlement_date,verified_by,verified_date,risk_sign_off_by,risk_sign_off_date,back_office_sign_off_by,back_office_sign_off_date,book_transfer_id,confirm_status_type,sub_book,deal_rules,confirm_rule,description4,timezone_id,reference_detail_id)
		OUTPUT INSERTED.source_deal_header_id,inserted.entire_term_start,inserted.entire_term_end INTO #temp_inserted_deals
		SELECT source_system_id,deal_id+'-1',deal_date,ext_deal_id,physical_financial_flag,structured_deal_id,counterparty_id,@deal_term_start,@deal_term_End,source_deal_type_id,deal_sub_type_type_id,option_flag,option_type,option_excercise_type,source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,description1,description2,description3,deal_category_value_id,trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,broker_id,generator_id,status_value_id,status_date,assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by,generation_source,aggregate_environment,aggregate_envrionment_comment,rec_price,rec_formula_id,rolling_avg,contract_id,legal_entity,internal_desk_id,product_id,internal_portfolio_id,commodity_id,reference,deal_locked,close_reference_id,block_type,block_define_id,granularity_id,Pricing,deal_reference_type_id,unit_fixed_flag,broker_unit_fees,broker_fixed_cost,broker_currency_id,deal_status,term_frequency,option_settlement_date,verified_by,verified_date,risk_sign_off_by,risk_sign_off_date,back_office_sign_off_by,back_office_sign_off_date,book_transfer_id,confirm_status_type,sub_book,deal_rules,confirm_rule,description4,timezone_id,reference_detail_id
		FROM 
			source_deal_header 
		WHERE deal_id ='what if sales'
		
		UPDATE 
			sdh SET deal_id = 'What If Sales-'+CAST(tid.source_deal_header_id AS VARCHAR)
		FROM
			source_deal_header sdh INNER JOIN #temp_inserted_deals tid ON sdh.source_deal_header_id = tid.source_deal_header_id
	


		INSERT INTO source_deal_detail(source_deal_header_id,term_start,term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,formula_id,volume_left,settlement_volume,settlement_uom,price_adder,price_multiplier,settlement_date,day_count_id,location_id,meter_id,physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party,status,lock_deal_detail,pricing_type,pricing_period,event_defination,apply_to_all_legs,contractual_volume,contractual_uom_id,source_deal_group_id)
		OUTPUT inserted.source_deal_detail_id, inserted.term_start, inserted.term_end INTO #temp_inserted_deal_detail
		SELECT tid.source_deal_header_id,tid.term_start,tid.term_end,Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,sxd.value,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,formula_id,volume_left,settlement_volume,settlement_uom,price_adder,price_multiplier,settlement_date,day_count_id,location_id,meter_id,sdd.physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party,status,lock_deal_detail,pricing_type,pricing_period,event_defination,apply_to_all_legs,contractual_volume,contractual_uom_id,source_deal_group_id
		FROM
		#temp_inserted_deals tid
		CROSS JOIN
		(
			SELECT TOP 1 Leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,deal_detail_description,formula_id,volume_left,settlement_volume,settlement_uom,price_adder,price_multiplier,settlement_date,day_count_id,location_id,meter_id,sdd1.physical_financial_flag,Booked,process_deal_status,fixed_cost,multiplier,adder_currency_id,fixed_cost_currency_id,formula_currency_id,price_adder2,price_adder_currency2,volume_multiplier2,pay_opposite,capacity,settlement_currency,standard_yearly_volume,formula_curve_id,price_uom_id,category,profile_code,pv_party,status,lock_deal_detail,pricing_type,pricing_period,event_defination,apply_to_all_legs,contractual_volume,contractual_uom_id,source_deal_group_id 
			FROM
				source_deal_detail sdd1
				INNER JOIN source_deal_header sdh ON sdd1.source_deal_header_id = sdh.source_deal_header_id	 
			WHERE sdh.deal_id = 'what if sales'
		) sdd
		OUTER APPLY(SELECT MAX(value) value FROM  #save_xml_deal  WHERE term = tid.term_start ) sxd

		INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, volume, granularity)
		SELECT sdd.source_deal_detail_id, sx.term, sx.hour, sx.is_dst [is_dst], sx.value, 982 [granularity]
		FROM #save_xml_deal sx
		INNER JOIN #temp_inserted_deal_detail sdd ON  sdd.term_start <= sx.term AND sdd.term_end >= sx.term AND sx.type = 'd'


		--EXEC spa_ErrorHandler 0
		--		, 'spa_process_power_dashboard'
		--		, 'spa_process_power_dashboard'
		--		, 'Success' 
		--		, 'Changes have been saved successfully.'
		--		, ''
		



--update #inserted_deal_detail set org_source_deal_detail_id = sdd.source_deal_detail_id
--from  #tmp_header th 
--inner join #inserted_deal_detail idd on th.source_deal_header_id=idd.source_deal_header_id
--inner join source_deal_detail sdd on th.org_source_deal_header_id=sdd.source_deal_header_id
--	  and sdd.leg=idd.leg


/**********************insert into *[user_defined_deal_fields]*****************************************************/


--print 'INSERT INTO [dbo].[user_defined_deal_fields]'
--print	getdate()

SELECT @source_deal_header_id = source_deal_header_id FROM #temp_inserted_deals
	
INSERT INTO [dbo].[user_defined_deal_fields]
		([source_deal_header_id]
		,[udf_template_id]
		,[udf_value]
		,[create_user]
		,[create_ts])
SELECT	@source_deal_header_id 
		,u.[udf_template_id]
		, u.udf_value
		,@db_user
		,GETDATE()
from  source_deal_header th 
inner JOIN [dbo].[user_defined_deal_fields_template] uddft ON uddft.template_id = th.template_id
	and deal_id ='what if sales'
inner join   [user_defined_deal_fields] u 	 on  u.source_deal_header_id=th.source_deal_header_id AND  uddft.udf_template_id = u.udf_template_id

		
		insert into #tmp_msg EXEC spa_calc_deal_position_breakdown @source_deal_header_id
	--exec [dbo].[spa_update_deal_total_volume] @source_deal_header_ids=@source_deal_header_id, @process_id = NUll,@insert_type =0,@partition_no =1,@user_login_id=@db_user
	

		EXEC spa_process_power_dashboard @flag = 'c', @term_start = @term_start, @term_end = @term_start, @hr_start= @hr_start,@hr_no = @hr_no
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'spa_process_power_dashboard'
			, 'spa_process_power_dashboard'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	SELECT [date] FROM mv90_DST
	WHERE insert_delete = 'i'
END
		
ELSE IF @flag = 'r'
BEGIN

	CREATE TABLE #column_types(column_name VARCHAR(100) COLLATE DATABASE_DEFAULT)
	set @power_dashboard=dbo.FNAProcessTableName('power_dashboard', @db_user, @process_id)
	SET @st='INSERT INTO #column_types SELECT  column_name  FROM adiha_process.INFORMATION_SCHEMA.COLUMNS WITH(NOLOCK) WHERE TABLE_NAME='''+REPLACE(@power_dashboard,'adiha_process.dbo.','')+''' AND  data_type=''float'''
	EXEC(@st)
		
	select @column_list=isnull(@column_list+',','')+ '['+column_name +']' from #column_types a
	
	SET @st='
		SELECT [group], group2,deal_id,rowid,ref_id,CAST(REPLACE(term_dt,''-DST'','''') AS DATETIME) term_dt,CASE WHEN CHARINDEX(''-DST'',term_dt,1)>0 THEN 1 ELSE 0 END is_dst, value	
		INTO 	#final_db_data
			FROM 
		   (SELECT [group], group2,deal_id,rowid,ref_id,'+@column_list+'
				FROM '+@power_dashboard+' WHERE ISNULL(NULLIF(group2,''''),''Delta'') IN(''Delta'') AND deal_id IN(''Fuel and O&M dollars'',''MMBTU required'', ''What If + Purchase , - Sale'')
		   ) p
		UNPIVOT
		  (value FOR term_dt IN 
			  ('+@column_list+')
		)AS unpvt;

	SELECT ''mmbtu increase over time frame of what if'' as [h1], SUM(value) as [h2] FROM #final_db_data WHERE deal_id IN(''MMBTU required'')
	UNION ALL
	SELECT ''fuel and O&M cost over time frame of what if'' as [h1], SUM(value) as [h2] FROM #final_db_data WHERE deal_id IN(''Fuel and O&M dollars'')
	UNION ALL
	SELECT ''$mwh for what if '' as [h1], abs(SUM(CASE WHEN deal_id=''Fuel and O&M dollars'' THEN value ELSE 0 END)/NULLIF(SUM(CASE WHEN deal_id=''What If + Purchase , - Sale'' THEN ISNULL(value,0) ELSE 0 END),0)) as [h2] FROM #final_db_data '	

	EXEC(@st)


END

ELSE IF @flag = 'z'
BEGIN
	BEGIN TRY
		DECLARE @idoc1 INT
		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @save_xml
		SELECT * INTO #save_generator_xml
		FROM   OPENXML(@idoc1, '/Root/grid', 1)
		   WITH (
			deal_id VARCHAR(50) '@deal_id',
			[hour] INT '@hour',
			term datetime '@term',
			value FLOAT '@value',
			is_dst INT '@is_dst'
		   )
		
		UPDATE tsdd
			SET tsdd.value = CASE WHEN sgx.value = 0 THEN 0 ELSE 1 END		
		FROM #save_generator_xml sgx
		INNER JOIN source_deal_header sdh ON sgx.deal_id = CAST(sdh.source_deal_header_id AS VARCHAR)
		INNER JOIN user_defined_deal_fields uddf ON sdh.source_deal_header_id = uddf.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
		INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = uddf.udf_value
		INNER JOIN time_series_data tsdd ON tsd.time_series_definition_id = tsdd.time_series_definition_id AND tsdd.maturity = DATEADD(hh, sgx.[hour], sgx.term)
		WHERE uddft.Field_label IN ('Online Indicator')
		
		--UPDATE tsdd
		--	SET tsdd.value = sgx.value 	
		--FROM #save_generator_xml sgx
		--INNER JOIN source_deal_header sdh ON sgx.deal_id = CAST(sdh.source_deal_header_id AS VARCHAR)
		--INNER JOIN user_defined_deal_fields uddf ON sdh.source_deal_header_id = uddf.source_deal_header_id
		--INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id
		--INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
		--INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = uddf.udf_value
		--INNER JOIN time_series_data tsdd ON tsd.time_series_definition_id = tsdd.time_series_definition_id AND tsdd.maturity = DATEADD(hh, sgx.[hour], sgx.term)
		--WHERE uddft.Field_label IN ('Capacity Usage') AND sgx.value > 0

		--INSERT INTO time_series_data (time_series_definition_id, maturity, curve_source_value_id, value, is_dst)
		--SELECT tsd.time_series_definition_id, DATEADD(hh, sgx.[hour], sgx.term) [maturity], '4500' [curve_source_value_id], sgx.value, sgx.is_dst FROM #save_generator_xml sgx
		--INNER JOIN source_deal_header sdh ON sgx.deal_id = CAST(sdh.source_deal_header_id AS VARCHAR)
		--INNER JOIN user_defined_deal_fields uddf ON sdh.source_deal_header_id = uddf.source_deal_header_id
		--INNER JOIN user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id
		--INNER JOIN source_deal_header_template sdht ON sdht.template_id = uddft.template_id
		--INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = uddf.udf_value
		--LEFT JOIN time_series_data tsdd ON tsd.time_series_definition_id = tsdd.time_series_definition_id AND tsdd.maturity = DATEADD(hh, sgx.[hour], sgx.term)
		--WHERE uddft.Field_label IN ('Capacity Usage') AND tsdd.time_series_data_id IS NULL

		UPDATE sddh
		SET sddh.volume = sgx.value
		FROM #save_generator_xml sgx
		INNER JOIN source_deal_header sdh ON sgx.deal_id = sdh.deal_id
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id 
		AND sddh.term_date = sgx.term AND sddh.[hr] = sgx.[hour]+1 AND sddh.is_dst = sgx.is_dst

		EXEC spa_ErrorHandler 0
				, 'spa_process_power_dashboard'
				, 'spa_process_power_dashboard'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
		
	
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
			ROLLBACK
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'spa_process_power_dashboard'
			, 'spa_process_power_dashboard'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

ELSE IF @flag = 'x'
BEGIN
	SELECT pdf_xml FROM dashboard_snaphots WHERE dashboard_snaphots_id = @snapshot_id
END

ELSE IF @flag = 'p'
BEGIN
	BEGIN TRY
		
		INSERT INTO dashboard_snaphots (dashboard_snaphots_name, pdf_xml)
		SELECT @snapshot_name, @pdf_xml

	EXEC spa_ErrorHandler 0
				, 'spa_process_power_dashboard'
				, 'spa_process_power_dashboard'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
		
	
	END TRY
	BEGIN CATCH	
		IF @@TRANCOUNT > 0
			ROLLBACK
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'spa_process_power_dashboard'
			, 'spa_process_power_dashboard'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END
