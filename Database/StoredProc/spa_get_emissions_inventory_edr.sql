
IF OBJECT_ID('[dbo].[spa_get_emissions_inventory_edr]') IS NOT NULL

DROP PROCEDURE [dbo].[spa_get_emissions_inventory_edr]
GO
--exec spa_get_emissions_inventory_edr s,NULL,NULL,'2001-07-01','2007-07-30',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'138,137,135,136',NULL,NULL,NULL,'n','s',706,NULL,'n'

--exec spa_get_emissions_inventory_edr s,'282','2001-01-01','2001-07-01','2007-01-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,null,null,NULL,NULL,null,null,'n','s',703,null,'n'

--exec spa_get_emissions_inventory s,274,NULL,'2007-05-30','2007-05-30','r',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'172',NULL,NULL,'Vehicles',NULL
CREATE PROCEDURE [dbo].[spa_get_emissions_inventory_edr]
	@flag char(1)='s', -- 's' summary,'d' detail
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100)=null,
	@fas_book_id varchar(100)=null,
	@generator_id varchar(1000)=NULL,
	@term_start datetime=null,
	@term_end datetime=null,
	@curve_id int=null,
	@frequency int=null,
	@view_hourly char(1)='n',
	@temp_table varchar(100)=null,
	@process_id varchar(100)=null,
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL


AS
BEGIN
declare @sql_Where varchar(1000)
DECLARE @Sql_Select varchar(8000)
DECLARE @sql varchar(8000)
DECLARE @co2_uom_id int
DECLARE @co2_gas_id int


--## for batch process
DECLARE @str_batch_table varchar(max)        
	SET @str_batch_table=''        
	IF @batch_process_id is not null        
	 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         


IF @term_start IS NOT NULL AND @term_end IS NULL            
 SET @term_end = @term_start            

------------------------------------------
-------------------------------------------
SET @sql_Where = ''            
CREATE TABLE #ssbm(                      
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)            

CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  

----------------------------------            
SET @Sql_Select=            
'INSERT INTO #ssbm            
SELECT                      
  book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
FROM            
 portfolio_hierarchy book (nolock)             
INNER JOIN            
 Portfolio_hierarchy stra (nolock)            
 ON            
  book.parent_entity_id = stra.entity_id               
WHERE 1=1 '            
IF @sub_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR) + ' ))'            
  IF @fas_book_id IS NOT NULL            
   SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @fas_book_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            

EXEC (@Sql_Select)            


create table #temp(
		generator_id int,
		generator_name varchar(100) COLLATE DATABASE_DEFAULT,
		facility_id varchar(100) COLLATE DATABASE_DEFAULT,
		Unit varchar(100) COLLATE DATABASE_DEFAULT,
		term_start datetime,
		inventory float,
		UOM Varchar(100) COLLATE DATABASE_DEFAULT,
		record_type int,
		sub_type int,
		edr_hr tinyint,
		op_time float,
		Co2_Mass float,
		SO2_Mass float,
		NOX_Rate float,
		Heat_input float,
		MDC float	
	)

	set @sql='
	insert into #temp
	select 
		rg.generator_id,
		rg.name generator_name,
		rg.[id] facility_id,
		ei.[stack_id] [Stackid],
		ei.edr_date term_start,
		ei.edr_value volume,
		NULL as UOM,
		ei.record_type_code record_type,
		ei.sub_type_id sub_type,
		ei.edr_hour,
		case when ei.record_type_code=300 and ei.sub_type_id=3405 then ei.edr_value else 0 end as [Op Time],
		case when ei.record_type_code=330 and ei.sub_type_id=3400 then ei.edr_value else 0 end as [Co2_Mass],
		case when ei.record_type_code=310 and ei.sub_type_id=3400 then ei.edr_value else 0 end as [SO2_Mass],
		case when ei.record_type_code=320 and ei.sub_type_id=3409 then ei.edr_value else 0 end as [NOX_Rate],
		case when ei.record_type_code=300 and ei.sub_type_id=3403 then ei.edr_value else 0 end as [Heat_Input],
		case when ei.record_type_code=202 and ei.sub_type_id=3406 then ei.edr_value else 0 end as [MDC]
--		case when ei.record_type_code in(202,330) then ''CO2''
--			 when ei.record_type_code in(320,324,325) then ''NOX''
--			 when ei.record_type_code in(310,313,314,200) then ''SO2''
--		else ''''
--		end,
--		sd.code
	from
		edr_raw_data ei inner join rec_generator rg on ei.facility_id=rg.id
		inner join #ssbm on rg.fas_book_id=#ssbm.fas_book_id
		left join static_data_value sd on sd.value_id=ei.sub_type_id
		left join ems_stack_unit_map esum on esum.ORSIPL_ID=ei.facility_id
		and esum.stack_id=ei.stack_id
		inner join ems_multiple_source_unit_map esm on esm.ORSIPL_ID=ei.facility_id
		and esm.EDR_unit_id=isnull(esum.unit_id,ei.unit_id) and esm.generator_id=rg.generator_id
 where
		((ei.edr_date between '''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+''')' 
		+')'

	if @generator_id is not null
		set @sql=@sql+' and rg.generator_id in ('+cast(@generator_id as varchar(100))+')'
	+case when @curve_id=127 then 'and ei.record_type_code in(202,300,330)'
		 when @curve_id=183 then 'and ei.record_type_code in(300,320,324,325)'
		 when @curve_id=1248 then 'and ei.record_type_code in(300,310,313,314,200)'
		 else ' and ei.record_type_code in(202,330,300,310,313,314,200,320,324,325)'	
	end	
--print @sql
exec(@sql)


-- Now return the actual result
set @sql='
select
	 T2.generator_name [Source],T2.facility_id [Facility ID],T2.Unit[Stack/Unit],dbo.fnadateformat(T2.term_start) [Date],T2.edr_hr [Hour],
	 sum(T2.op_time) as [OP Time],sum(T2.Co2_Mass) as [CO2 Mass],sum(T2.SO2_Mass) as [SO2 Mass],
	 sum(T2.NOX_Rate) as [NOX Rate],sum(T2.Heat_input) as [Heat Input],sum(T2.NOX_Rate)*sum(T2.Heat_input) as [NOX Mass],sum(T2.MDC) as [MDC]'+
	  case when @temp_table is not null then ' into '+@temp_table else '' end+
			@str_batch_table+
+' from
	#temp T2
group by 
		 T2.generator_name ,T2.facility_id,T2.Unit,dbo.fnadateformat(T2.term_start),T2.edr_hr
		 order by 
		 T2.generator_name ,T2.facility_id,T2.Unit,dbo.fnadateformat(T2.term_start),T2.edr_hr
'

exec(@sql)


set @sql='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @temp_table
EXEC spa_print @sql
exec(@sql)		


--*****************FOR BATCH PROCESSING**********************************            
 

IF  @batch_process_id is not null        
BEGIN        
 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
 EXEC(@str_batch_table)        
 declare @report_name varchar(100)        

 set @report_name='EDR Data Report'        
        
 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_get_emissions_inventory_edr',@report_name)         
 EXEC(@str_batch_table)        
 
END        
--********************************************************************   


END






