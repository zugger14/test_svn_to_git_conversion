IF OBJECT_ID(N'spa_create_Tagging_Export', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_create_Tagging_Export]
 GO 


--[spa_create_Tagging_Export] null,'2008-03-01','2008-05-01'
create PROC [dbo].[spa_create_Tagging_Export]  
	    	@source_system_id int=null,
            @deal_date_from varchar(10) = NULL, 
			@deal_date_to varchar(10) = NULL,
			@source_deal_header_id varchar(5000)=null,
			@report_type varchar(1)='s'    

as
SET NOCOUNT ON

Declare @sql_Select varchar(5000)
Declare @sql_Where varchar (2000)
Declare @sql_From varchar (2000)
Declare @sql_group_by varchar (2000)
declare @sub_query varchar(1000)

--########### Group Label
declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
begin	
	select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
end
else
begin
	set @group1='Group1'
	set @group2='Group2'
	set @group3='Group3'
	set @group4='Group4'
end
--######## End
if @report_type='s' -- For Export
begin
SET @sql_Select = '
			select 
			sdh.deal_id as [Deal Tracking Number],
			sb4.source_book_name AS  ['+@group4+'] ,
			--case when ssbm.fas_deal_type_value_id=400 then ''Hedging Item'' else ''Hedged Item'' end Hedging_side,
			sb1.source_book_name AS ['+@group1+'] 
			
			from source_deal_header sdh inner join (
			select dta.source_deal_header_id,max(dta.create_ts) max_date from  deal_tagging_audit dta
			where dta.create_ts between '''+@deal_date_from+''' and '''+@deal_date_to+' 23:59:59''
			group by dta.source_deal_header_id) dtm on dtm.source_deal_header_id=sdh.source_deal_header_id
			--on dtm.max_date=dta.create_ts and dtm.source_deal_header_id=dta.source_deal_header_id
			inner join
				  source_book sb4 ON sdh.source_system_book_id4 = sb4.source_book_id LEFT OUTER JOIN
				  source_book sb1 ON sdh.source_system_book_id1 = sb1.source_book_id
				left outer join embedded_deal ed on sdh.source_deal_header_id=ed.bif_source_deal_header_id
				'
SET @sql_Where =' Where 1=1 and ed.bif_source_deal_header_id is null '
if @source_system_id is not null
	set @sql_Where=@sql_Where +' and sdh.source_system_id='+cast(@source_system_id as varchar)
if @source_deal_header_id is not null
	set @sql_Where=@sql_Where +' and sdh.source_deal_header_id in('+@source_deal_header_id +')'
end
else -- for GRID
begin

set @sub_query = 'select dta.source_deal_header_id,max(dta.create_ts) max_date from  deal_tagging_audit dta
					where'

IF @deal_date_from IS NOT NULL AND @deal_date_to IS NULL
	SELECT @sub_query = @sub_query + ' dta.create_ts >= CONVERT(DATETIME, ''' + @deal_date_from  + ''', 102)'

IF @deal_date_from IS NULL AND  @deal_date_to IS NOT NULL	
	SELECT @sub_query = @sub_query + ' dta.create_ts <= CONVERT(DATETIME, ''' + @deal_date_to +  ' 23:59:59' + ''', 102)'

IF @deal_date_from IS NOT NULL AND  @deal_date_to IS NOT NULL	
	SELECT @sub_query = @sub_query + ' dta.create_ts BETWEEN  CONVERT(DATETIME, ''' + @deal_date_from + ''', 102) AND CONVERT(DATETIME, ''' + @deal_date_to +  ' 23:59:59' + ''', 102)'

IF @deal_date_from IS NULL AND  @deal_date_to IS NULL	
	SELECT @sub_query = @sub_query + ' 1=1'

SET @sub_query = @sub_query + ' group by dta.source_deal_header_id'

exec spa_print @sub_query

SET @sql_Select = '
			select 
			sdh.source_deal_header_id as [Source Deal Header ID],
			sdh.deal_id as [Deal Tracking Number],
			sb4.source_book_name AS  ['+@group4+'] ,
			--case when ssbm.fas_deal_type_value_id=400 then ''Hedging Item'' else ''Hedged Item'' end Hedging_side,
			sb1.source_book_name AS ['+@group1+'] 
			
			from source_deal_header sdh inner join ('+@sub_query+') dtm on dtm.source_deal_header_id=sdh.source_deal_header_id
			--on dtm.max_date=dta.create_ts and dtm.source_deal_header_id=dta.source_deal_header_id
			inner join
				  source_book sb4 ON sdh.source_system_book_id4 = sb4.source_book_id LEFT OUTER JOIN
				  source_book sb1 ON sdh.source_system_book_id1 = sb1.source_book_id
				left outer join embedded_deal ed on sdh.source_deal_header_id=ed.bif_source_deal_header_id
				'
SET @sql_Where =' Where 1=1 and ed.bif_source_deal_header_id is null '
if @source_system_id is not null
	set @sql_Where=@sql_Where +' and sdh.source_system_id='+cast(@source_system_id as varchar)
if @source_deal_header_id is not null
	set @sql_Where=@sql_Where +' and sdh.source_deal_header_id in('+@source_deal_header_id +')'
end

exec spa_print @sql_Select, @sql_Where  
exec (@sql_Select+@sql_Where  )









