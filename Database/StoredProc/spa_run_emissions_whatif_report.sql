
/****** Object:  StoredProcedure [dbo].[spa_run_emissions_whatif_report]    Script Date: 11/17/2009 22:25:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_emissions_whatif_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_emissions_whatif_report]
/****** Object:  StoredProcedure [dbo].[spa_run_emissions_whatif_report]    Script Date: 11/17/2009 22:25:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_get_emissions_inventory s,274,NULL,'2007-05-30','2007-05-30','r',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'172',NULL,NULL,'Vehicles',NULL
CREATE PROCEDURE [dbo].[spa_run_emissions_whatif_report]
	@flag char(1)='s', -- 's' summary,'d' detail
	@report_type char(1)='1', -- 1->Emissions,2->Intensity,3->Rate,4->Net Mwh
	@group_by char(1)='1', -- 1->Operating Compnay, 2->Business Units, 3->States, 4->Source/Sinks
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(500)=null,
	@fas_book_id varchar(500)=null,
	@as_of_date datetime=null,
	@term_start datetime=null,
	@term_end datetime=null,
	@technology int=null,
	@fuel_value_id int=null,
	@ems_book_id varchar(200)=null,
	@curve_id int=null,
	@convert_uom_id int=null,
	@show_co2e char(1)='n',
	@technology_sub_type int=null,
	@fuel_type int=null,
	@source_sink_type int=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL, 	   
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	@frequency int=null,
	@protocol int=null,
	@include_hypothetical CHAR(1)='n',
	@drill_criteria VARCHAR(100)=NULL,
	@drill_group CHAR(1)=NULL,
--	@process_table varchar(200)=null,
--	@process_id varchar(100) = null,
	@round_value CHAR(1) = '0',
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL,
	@enable_paging INT = NULL,   --'1'=enable, '0'=disable
	@page_size INT = NULL,
	@page_no INT = NULL

AS
SET NOCOUNT ON
BEGIN
declare @sql_Where varchar(1000)
DECLARE @Sql_Select varchar(8000)
DECLARE @sql varchar(MAX)
DECLARE @co2_uom_id int
DECLARE @co2_gas_id int
DECLARE @Output_id int
DECLARE @emisssions_reductions char(1)
DECLARE @co2e_curve_id int



--////////////////////////////Paging_Batch///////////////////////////////////////////
EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:',	@batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(128),@user_login_id varchar(50),@flag1 CHAR(1)
DECLARE @is_batch bit
set @str_batch_table=''
SET @str_get_row_number=''

declare @sql_stmt varchar(8000)


IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
IF (@is_batch = 1 OR @enable_paging = 1)
begin
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	exec spa_print '@temptablename:', @temptablename
	SET @str_batch_table=' INTO ' + @temptablename
	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	IF @enable_paging = 1
	BEGIN
		
		IF @page_size IS not NULL
		begin
			declare @row_to int,@row_from int
			set @row_to=@page_no * @page_size
			if @page_no > 1 
				set @row_from =((@page_no-1) * @page_size)+1
			else
				set @row_from =@page_no
			set @sql_stmt=''
			--	select @temptablename
			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns WITH(NOLOCK) where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			set @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
		--	exec spa_print @sql_stmt		
			exec(@sql_stmt)
			return
		END --else @page_size IS not NULL
	END --enable_paging = 1
end

--////////////////////////////End_Batch///////////////////////////////////////////



if @protocol is null  
	set @protocol=5244
--## for batch process
--DECLARE @str_batch_table varchar(1000)        
--	SET @str_batch_table=''        
--	IF @batch_process_id is not null        
--	 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         

SET @co2e_curve_id=-1
set @Output_id=1052
set @co2_gas_id = 127
select @co2_uom_id =  uom_id from source_price_curve_Def where source_curve_def_id = @co2_gas_id 

set @emisssions_reductions='e'

IF @term_start IS NOT NULL AND @term_end IS NULL            
 SET @term_end = @term_start            


if datediff(month,@term_start,@term_end)>59 and @frequency=703
	set @term_end=dateadd(month,59,@term_start)

--if @drill_criteria IS NOT NULL
--	SET @group_by=5

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
  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR(500)) + ') '             
 IF @strategy_entity_id IS NOT NULL            
  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR(500)) + ' ))'            
  IF @fas_book_id IS NOT NULL            
   SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @fas_book_id + ')) '            
SET @Sql_Select=@Sql_Select+@Sql_Where            

--print @Sql_Select

--Uday hardcoding/changes
--if isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
	EXEC (@Sql_Select)         

   

---------------------------------------
--------------------------------------------------
if @flag='s' or @flag='d'
BEGIN

	create table #temp(
		--detail_id int identity(1,1),
		op_name varchar(100) COLLATE DATABASE_DEFAULT,
		business_entity varchar(100) COLLATE DATABASE_DEFAULT,
		generator_id int,
		generator_name varchar(100) COLLATE DATABASE_DEFAULT,
		term_start datetime,
		as_of_date datetime,
		emission_type varchar(100) COLLATE DATABASE_DEFAULT,
		inventory float,
		reduction float,
		uom varchar(100) COLLATE DATABASE_DEFAULT,
		curve_name varchar(100) COLLATE DATABASE_DEFAULT,
		current_forecast char(1) COLLATE DATABASE_DEFAULT,
		curve_id int,
		[output]float,
		output_uom varchar(50) COLLATE DATABASE_DEFAULT,
		heatcontent float,
		heatcontent_uom varchar(50) COLLATE DATABASE_DEFAULT,
		frequency_id int,
		forecast_type int,
		fuel_type_value_id int,
		state varchar(100) COLLATE DATABASE_DEFAULT,
		generator_group_name varchar(100) COLLATE DATABASE_DEFAULT,
		seq_order int,
		group1 varchar(100) COLLATE DATABASE_DEFAULT,
		whatif_value FLOAT
	)
	set @sql='
	insert into #temp(
		op_name,
		business_entity,
		generator_id,
		generator_name,
		term_start,
		as_of_date,
		emission_type ,
		inventory ,
		reduction ,
		uom ,
		curve_name,
		current_forecast,
		curve_id,
		[output],
		output_uom,
		heatcontent,
		heatcontent_uom ,
		frequency_id ,
		forecast_type ,
		fuel_type_value_id ,
		state ,
		generator_group_name ,
		seq_order,
		group1,
		whatif_value 
	)
	select 
		ph.entity_name,
		ph1.entity_name,
		rg.generator_id,
		rg.name generator_name,
		ecdv.term_start term_start,
		ecdv.as_of_date as_of_date,'
		+case when @show_co2e='y'  then '''Co2e''' else 'ISNULL(Conv2.curve_label,spcd.curve_name) ' end +' as emission_type,
		(1-ISNULL(ownership_per,0))*ISNULL(ecdv.formula_value,ecdv.formula_value) * ISNULL(conv1.conversion_factor,1) * ISNULL(conv2.conversion_factor,1)  volume,
		ISNULL(NULLIF(ecdv.formula_value_reduction,0),ecdv.formula_value_reduction) * ISNULL(conv1.conversion_factor,1) * ISNULL(conv2.conversion_factor,1)  reduction_volume,
		su.uom_name as UOM,		
		ISNULL(Conv2.curve_label,spcd.curve_name),
		ecdv.current_forecast,
		ecdv.curve_id,
		ecdv.output_value,
		output_uom.uom_name,
		ecdv.heatcontent_value as heatcontent,
		heat.uom_name as heatcontent_uom,
		ecdv.frequency,
		ecdv.forecast_type,
		ecdv.fuel_type_value_id as fuel_type_value_id,
		state_value.description,
		rg.generator_group_name,
		esf.sequence_order,
		eph2.entity_name,
		(1-ISNULL(ownership_per,0))*ISNULL(ecdvw.formula_value,0) * ISNULL(conv1.conversion_factor,1) * ISNULL(conv2.conversion_factor,1)  whatif_value

	from
		ems_calc_detail_value ecdv inner join rec_generator rg on ecdv.generator_id=rg.generator_id
		inner join #ssbm on rg.fas_book_id=#ssbm.fas_book_id
		inner join portfolio_hierarchy ph on ph.entity_id=#ssbm.sub_entity_id
		and ph.hierarchy_level=2
		inner join portfolio_hierarchy ph1 on ph1.entity_id=#ssbm.stra_book_id
		and ph1.hierarchy_level=1
		inner join source_price_curve_def spcd on spcd.source_curve_def_id=ecdv.curve_id
	
		left join static_data_value sdv on sdv.value_id=ecdv.forecast_type
		left outer join rec_generator_group rgg on rgg.generator_group_name=rg.generator_group_name
		left join formula_editor fe on fe.formula_id=ecdv.formula_id
		left join formula_editor fe1 on fe1.formula_id=ecdv.formula_id_reduction
		left join formula_editor fe2 on fe2.formula_id=ecdv.formula_detail_id
		
		
			 LEFT JOIN rec_volume_unit_conversion Conv1 ON            
			 conv1.from_source_uom_id  = ISNULL(ecdv.uom_id,-1)
			 AND conv1.to_source_uom_id =COALESCE('+case when @convert_uom_id is not null then cast(@convert_uom_id as varchar) else 'NULL' END +',ecdv.uom_id,-1)
			 And conv1.state_value_id is null
			 AND conv1.assignment_type_value_id is null
			 AND conv1.curve_id  IS NULL

			 LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
			 conv2.from_source_uom_id = ISNULL(ecdv.uom_id,-1)
			 AND conv2.to_source_uom_id = ISNULL(ecdv.uom_id,-1)
			 And conv2.state_value_id IS NULL
			 AND conv2.assignment_type_value_id IS NULL
			 AND conv2.curve_id =ecdv.curve_id
			 AND conv2.to_curve_id ='+CAST(ISNULL(@curve_id,0) AS VARCHAR)+' 
		 LEFT JOIN source_uom su on su.source_uom_id=Conv1.to_source_uom_id
 		 --LEFT JOIN source_uom su1 on su1.source_uom_id=Conv3.to_source_uom_id 

		LEFT JOIN (select generator_id,sum(per_ownership) ownership_per from generator_ownership group by generator_id) ownership
		on rg.generator_id=ownership.generator_id
		left join static_data_value state_value on state_value.value_id=rg.state_value_id
		left join source_uom heat on heat.source_uom_id=ecdv.heatcontent_uom_id
		left join source_uom output_uom on output_uom.source_uom_id=ecdv.output_uom_id	
		--left join user_defined_group_detail udgd on udgd.rec_generator_id=rg.generator_id
		INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
		INNER JOIN (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id from 
						ems_source_model_effective where 1=1 group by generator_id) ab
		on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
		left join ems_source_formula esf on esf.ems_source_model_id = esme.ems_source_model_id and
		esf.curve_id = ecdv.curve_id and esf.forecast_type=ecdv.forecast_type'+
		' 
		left join source_sink_type sst on sst.generator_id=rg.generator_id	
		inner join ems_portfolio_hierarchy eph on eph.entity_id=sst.source_sink_type_id
		and eph.hierarchy_level=0 and emission_group_id='+cast(@protocol as varchar)+'
		inner join ems_portfolio_hierarchy eph1 on eph1.entity_id=eph.parent_entity_id
		and eph1.hierarchy_level=1		
		inner join ems_portfolio_hierarchy eph2 on eph2.entity_id=eph1.parent_entity_id
		and eph2.hierarchy_level=2 '+
		case when @ems_book_id is not null then '
		and (eph.entity_id in('+@ems_book_id
			+') or eph1.entity_id in('+@ems_book_id
			+') or eph2.entity_id in('+@ems_book_id+'))'
		else '' end+
	  ' left join ems_edr_include_inv edr_inc on edr_inc.generator_id=ecdv.generator_id and
		edr_inc.curve_id=ecdv.curve_id and ecdv.term_start between edr_inc.term_start and edr_inc.term_end
		--edr_inc.series_type=ecdv.forecast_type
		'+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' join user_defined_group_detail udgd on udgd.rec_generator_id=rg.generator_id 
		and isnull(udgd.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'
		LEFT JOIN ems_calc_detail_value_whatif ecdvw  ON 
				ecdv.generator_id=ecdvw.generator_id
				AND ecdv.term_start=ecdvw.term_start
				AND ecdv.term_end=ecdvw.term_end
				AND ecdv.curve_id=ecdvw.curve_id
				AND ecdv.forecast_type=ecdvw.forecast_type
				AND ecdv.fuel_type_value_id=ecdvw.fuel_type_value_id
	WHERE
		(edr_inc.generator_id is null or(edr_inc.generator_id is not null and (edr_inc.series_type=ecdv.forecast_type)))
		and (ecdv.term_start between '''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+''' or ecdv.term_end between 
			'''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+''')
		-- and(ei.fas_book_id is null or ei.fas_book_id>0)
'		+ case when @as_of_date is not null then ' And ecdv.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end

	if @technology is not null 
		set @sql=@sql+' and rg.technology ='+ cast(@technology as varchar(100))
	if @fuel_value_id is not null 
		set @sql=@sql+' and rg.fuel_value_id ='+ cast(@fuel_value_id as varchar(100))
	
	if @curve_id is not null AND @curve_id<>@co2e_curve_id
		set @sql=@sql+' and ecdv.curve_id ='+ cast(@curve_id as varchar(100))

	  set @sql=@sql 
	   + case when @as_of_date is not null then ' And ecdv.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end 
	   + case when @technology_sub_type is not null then ' And rg.classification_value_id='+cast(@technology_sub_type as varchar) else '' end
	   + case when @fuel_type is not null then ' And fe2.static_value_id='+cast(@fuel_type as varchar) else '' end
	   + case when @reduction_type is not null then ' And rg.reduction_type='+cast(@reduction_type as varchar) else '' end
	   + case when @reduction_sub_type is not null then ' And rg.reduction_sub_type='+cast(@reduction_sub_type as varchar) else '' end
	   + case when @udf_source_sink_group is not null then ' And udgd.user_defined_group_id='+cast(@udf_source_sink_group as varchar) else '' end
	   + case when @udf_group1 is not null then ' And rg.udf_group1='+cast(@udf_group1 as varchar) else '' end
	   + case when @udf_group2 is not null then ' And rg.udf_group2='+cast(@udf_group2 as varchar) else '' end
	   + case when @udf_group3 is not null then ' And rg.udf_group3='+cast(@udf_group3 as varchar) else '' end
	   + case when @report_type=5 then ' And isnull(rg.reduction_type,-1)=-1 ' 
			  when @report_type=6 then ' And isnull(rg.reduction_type,-1)<>-1 ' 
			  else '' 	end
	   +CASE WHEN @include_hypothetical='y' THEN '' ELSE ' and isnull(rg.is_hypothetical,''n'') = ''' +@include_hypothetical+''''  END 
	   + CASE WHEN @drill_criteria IS NOT NULL THEN
			CASE WHEN @drill_group=1 THEN ' AND ph.entity_name='''+@drill_criteria+''''
				 WHEN @drill_group=2 THEN ' AND ph1.entity_name='''+@drill_criteria+''''
				 WHEN @drill_group=3 THEN ' AND state_value.description='''+@drill_criteria+''''
				 WHEN @drill_group=4 THEN ' AND rg.generator_group_name='''+@drill_criteria+''''
				 WHEN @drill_group=6 THEN ' AND eph2.entity_name='''+@drill_criteria+''''
			ELSE '' END
			ELSE '' END

	set @sql=@sql +' 	'
--	EXEC spa_print @sql
	exec(@sql)
	


	set @sql=	case when @group_by=1 then 'select T2.op_name as [XE_OpCompany],'
					 when @group_by=2 then 'select T2.op_name as [XE_OpCompany],T2.business_entity as [Business Entity],'
					 when @group_by=3 then 'select T2.op_name as [XE_OpCompany],T2.state as [State],'
					 when @group_by=4 then 'select T2.op_name as [XE_OpCompany],ISNULL(T2.generator_group_name,T2.generator_name) as [Source/Sink Group],'
					 when @group_by=5 then 'select T2.op_name as [XE_OpCompany],dbo.FNAEmissionHyperlink(3,12101510,generator_name,generator_id,''"s"'') as [Source/Sink],'
					 when @group_by=6 then 'select T2.Group1 [Scope],'
				end+
			case when @group_by=6  then 'T2.generator_name as [Source],' else '' end
	
	SET @sql=@sql+'T2.emission_type [EmissionsType],'
			+CASE WHEN @frequency=703 then ' dbo.fnacontractmonthformat(term_start) '
									 when @frequency=706 then ' cast(YEAR(term_start) as varchar) '
							         when @frequency=704 then ' dbo.FNAGetQuarter(term_start) ' 	
								end 	
						+' AS Term,'
			+'SUM(Inventory) Inventory,SUM(ISNULL(whatif_value,Inventory)) [WhatIfvalue],
			 SUM(Inventory)-SUM(ISNULL(whatif_value,Inventory)) AS [Variance],MAX(T2.UOM) [UOM]
			 '+ @str_get_row_number + @str_batch_table +'
		FROM 
			#temp T2
		group by 
				T2.emission_type, '

	SET @sql=@sql+case when @group_by=1 then ' T2.op_name '
					 when @group_by=2 then ' T2.op_name,T2.business_entity '
					 when @group_by=3 then ' T2.op_name,T2.state'
					 when @group_by=4 then ' T2.op_name,ISNULL(T2.generator_group_name,T2.generator_name)'
					 when @group_by=5 then ' T2.op_name,T2.generator_name,T2.generator_id'
					 when @group_by=6 then ' T2.Group1,T2.op_name,T2.generator_name,T2.generator_id'
				end+
			CASE WHEN @frequency=703 then ' ,dbo.fnacontractmonthformat(term_start) '
									 when @frequency=706 then ' ,cast(YEAR(term_start) as varchar) '
							         when @frequency=704 then ' ,dbo.FNAGetQuarter(term_start) ' 	
								end+ 	
			' order by' +
		case when @group_by=1 then ' T2.op_name, '
					 when @group_by=2 then ' T2.op_name,T2.business_entity, '
					 when @group_by=3 then ' T2.op_name,T2.state,'
					 when @group_by=4 then ' T2.op_name,ISNULL(T2.generator_group_name,T2.generator_name),'
					 when @group_by=5 then ' T2.op_name,T2.generator_name,'
					 when @group_by=6 then ' T2.Group1,'
			 end+
			CASE WHEN @frequency=703 then ' dbo.fnacontractmonthformat(term_start) '
									 when @frequency=706 then ' cast(YEAR(term_start) as varchar) '
							         when @frequency=704 then ' dbo.FNAGetQuarter(term_start) ' 	
								end+ 	
		' ,T2.emission_type '

	--PRINT @sql
	
	
	EXEC(@sql)

END


--*****************FOR BATCH PROCESSING**********************************            
 

--IF  @batch_process_id is not null        
--BEGIN        
-- SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
-- EXEC(@str_batch_table)        
-- declare @report_name varchar(100)        
--
-- set @report_name='Emissions Inventory Report'        
--        
-- SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_run_emissions_intensity_report',@report_name)         
-- EXEC(@str_batch_table)        
--   
--END        
--********************************************************************   



if @is_batch = 1
begin
	exec spa_print '@str_batch_table'  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   exec spa_print @str_batch_table
	 EXEC(@str_batch_table)                   
	        
	declare @report_name varchar(100)        

	set @report_name='Emissions Inventory Report' 
	
	

	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_run_emissions_whatif_report',@report_name)         
--	 EXEC spa_print @str_batch_table
	 EXEC(@str_batch_table)        
	EXEC spa_print 'finsh spa_run_emissions_whatif_report'
	return
END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			set @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
		--	EXEC spa_print @sql_stmt
			exec(@sql_stmt)
		END
		return
END 

END




