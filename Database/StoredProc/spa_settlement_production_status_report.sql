
/****** Object:  StoredProcedure [dbo].[spa_settlement_production_status_report]    Script Date: 03/02/2009 14:08:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_settlement_production_status_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_settlement_production_status_report]
GO

CREATE PROCEDURE [dbo].[spa_settlement_production_status_report]                   
	@recorderid VARCHAR(250) = NULL,
	@term_start DATETIME = NULL,
	@term_end DATETIME = NULL,
	@show_generator CHAR(1) = 'y'
AS            

BEGIN 
DECLARE @Sql_Select VARCHAR(8000)           
SET NOCOUNT ON     
IF @term_start IS NOT NULL AND @term_end IS NULL            
	SET @term_end = @term_start            
IF @term_start IS NULL AND @term_end IS NOT NULL            
	SET @term_start = @term_end     
set @recorderid=replace(@recorderid,',',''',''')
--print(@recorderid)
--select @recorderid

set @term_start=cast(cast(datepart(yyyy,@term_start) as varchar)+'-'+cast(datepart(mm,@term_start) as varchar)+'-01' as datetime)
set @term_end=cast(cast(datepart(yyyy,@term_end) as varchar)+'-'+cast(datepart(mm,@term_end) as varchar)+'-01' as datetime)
create table #tmp ( prod_date datetime,recordid varchar(30) COLLATE DATABASE_DEFAULT)
while @term_start<=@term_end
begin
	set @Sql_Select='insert into #tmp select distinct '''+cast(@term_start as varchar)+''', meter_id from mv90_data where  meter_id in ('''+@recorderid+''')'
	exec spa_print @Sql_Select
exec(@Sql_Select)
set @term_start=dateadd(m,1,@term_start)

end
--select * from #tmp
--return
set @Sql_Select='
select counterparty_name Counterparty,'
if @show_generator='y' 
 set @Sql_Select=@Sql_Select+' tech.code Technology,rg.code as Generator,state.code as [Gen State],'

 set @Sql_Select=@Sql_Select+' s.[Production Month],s.[Record ID],s.Volumn,max(suom.uom_id) UOM,s.[Import Status]
from (select dbo.FNAGetContractMonth(t.prod_date) [Production Month],t.recordid [Record ID],sum(isnull(mv.volume,0)) as Volumn,max(case  when mv.meter_id is null then ''Missing'' else ''Imported'' end) [Import Status] 
	from #tmp t left join mv90_data mv on t.prod_date=cast(mv.from_date as datetime) and t.recordid=mv.meter_id
	group by dbo.FNAGetContractMonth(t.prod_date),t.recordid) s
		left join recorder_generator_map rgm on s.[Record ID]=rgm.meter_id 
		left join rec_generator rg on rgm.generator_id=rg.generator_id
		left join recorder_properties md on s.[Record ID]=md.meter_id --and md.channel=mv.channel  
		LEFT JOIN source_uom suom on suom.source_uom_id =md.uom_id
		left join source_counterparty sc on sc.source_counterparty_id=rg.ppa_counterparty_id
		left outer join static_data_value state on state.value_id =rg.gen_state_value_id
		left outer join static_data_value tech on tech.value_id = rg.technology 
		group by counterparty_name, tech.code,rg.code,state.code,s.[Production Month],s.[Record ID],s.[Import Status],Volumn
		order by counterparty_name,s.[Production Month],s.[Record ID]
'

exec(@Sql_Select)
END

