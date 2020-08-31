
/****** Object:  StoredProcedure [dbo].[spa_run_emissions_intensity_report]    Script Date: 01/18/2010 16:13:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_emissions_intensity_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_emissions_intensity_report]
/****** Object:  StoredProcedure [dbo].[spa_run_emissions_intensity_report]    Script Date: 01/18/2010 16:13:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec spa_get_emissions_inventory s,274,NULL,'2007-05-30','2007-05-30','r',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'172',NULL,NULL,'Vehicles',NULL
CREATE  PROCEDURE [dbo].[spa_run_emissions_intensity_report]
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
	@round_value CHAR(1)='0', 
	@process_table varchar(200)=null,
	@process_id varchar(100) = null,
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL

AS
SET NOCOUNT ON
BEGIN
	DECLARE @Sql_Inv VARCHAR(8000)
	DECLARE @Sql_Select varchar(MAX)
	DECLARE @co2_uom_id int
	DECLARE @co2_gas_id int
	DECLARE @Output_id int
	DECLARE @emisssions_reductions char(1)
	DECLARE @co2e_curve_id int
if @drill_criteria = '' set @drill_criteria = null

if @protocol is null  
	set @protocol=5244


--## for batch process
DECLARE @str_batch_or_paging_table varchar(1000)        
SET @str_batch_or_paging_table=''        
IF @batch_process_id is not null  --batch processing
	SELECT @str_batch_or_paging_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)
IF @process_id IS NOT NULL --paging
	SET @str_batch_or_paging_table = ' INTO ' + @process_table

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

	CREATE TABLE #ssbm(                      
		 fas_book_id int,            
		 stra_book_id int,            
		 sub_entity_id int            
	)            
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
		+CASE WHEN @sub_entity_id IS NOT NULL THEN  ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR(500)) + ') ' ELSE '' END
		+CASE WHEN @strategy_entity_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR(500)) + ' ))' ELSE '' END            
		+CASE WHEN @fas_book_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @fas_book_id + ')) ' ELSE '' END
		
	EXEC (@Sql_Select)            

	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])        



IF @sub_entity_id IS NULL
	SELECT  @sub_entity_id = 
				STUFF(( SELECT DISTINCT ',' + ltrim(str((sub_entity_id)))
				FROM    #ssbm
                ORDER BY ',' + ltrim(str((sub_entity_id))) FOR XML PATH('')), 1, 1, '') + ''


--- Find out the Inventory Table


	CREATE TABLE #ems_inv(
		generator_id INT,
		term_start DATETIME,
		term_end DATETIME,
		as_of_date DATETIME,
		curve_id INT,
		frequency INT,
		forecast_type INT,
		fuel_type_value_id INT,
		current_forecast CHAR(1) COLLATE DATABASE_DEFAULT,
		formula_id INT,
		formula_detail_id INT,
		formula_value FLOAT,
		uom_id INT,
		output_id INT,
		output_value FLOAT,
		output_uom_id INT,
		heatcontent_value FLOAT,
		heatcontent_uom_id INT,
		formula_eval VARCHAR(100) COLLATE DATABASE_DEFAULT,
		is_base_year INT			
	)

	SELECT @Sql_Inv=dbo.FNAGetProcessTableSQL('ems_calc_detail_value',@term_start,@term_end,@sub_entity_id,'n',NULL,NULL)	


	SET @sql_select= 
			' 
			INSERT INTO #ems_inv
			SELECT 
				generator_id ,
				term_start ,
				term_end ,
				as_of_date ,
				curve_id ,
				frequency ,
				forecast_type ,
				fuel_type_value_id ,
				current_forecast ,
				formula_id ,
				formula_detail_id,
				formula_value ,
				uom_id ,
				output_id ,
				output_value ,
				output_uom_id ,
				heatcontent_value ,
				heatcontent_uom_id,
				formula_eval,
				is_base_year  
			FROM
			  ('+@Sql_Inv+') ei
			WHERE 1=1
			AND ei.term_start between '''+CAST(@term_start AS VARCHAR)+''' AND '''+CAST(@term_end AS VARCHAR)+'''
			AND generator_id IN(select generator_id from rec_generator where fas_book_id IN(select fas_book_id FROM #ssbm))					'
			+ CASE WHEN @as_of_date is not null then ' And ei.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end

	EXEC(@sql_select)

---####################################
	CREATE  INDEX [IX_EI1] ON [#ems_inv]([generator_id])    
	CREATE  INDEX [IX_EI2] ON [#ems_inv]([curve_id])    
	CREATE  INDEX [IX_EI3] ON [#ems_inv]([term_start])    
	CREATE  INDEX [IX_EI4] ON [#ems_inv]([term_end])    
	CREATE  INDEX [IX_EI5] ON [#ems_inv]([forecast_type])    
	CREATE  INDEX [IX_EI6] ON [#ems_inv]([fuel_type_value_id])    
	
-----##################################
---------------------------------------
-- Find the Source Model efeective for that period


--------------------------------------------------
if @flag='s' or @flag='d'
BEGIN

	create table #temp(
		detail_id int identity(1,1),
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
		group1 varchar(100) COLLATE DATABASE_DEFAULT
	)
	set @sql_select='
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
		group1
	)
	select 
		ph.entity_name,
		ph1.entity_name,
		rg.generator_id,
		rg.name generator_name,
		ei.term_start term_start,
		ei.as_of_date as_of_date,'
		+case when @show_co2e='y'  then '''Co2e''' else 'ISNULL(Conv2.curve_label,spcd.curve_name) ' end +' as emission_type,
		(1-ISNULL(ownership_per,0))*(ei.formula_value) * ISNULL(conv1.conversion_factor,1) * ISNULL(conv2.conversion_factor,1)  volume,
		NULL  reduction_volume,
		su.uom_name as UOM,		
		ISNULL(Conv2.curve_label,spcd.curve_name),
		ei.current_forecast,
		ei.curve_id,
		ei.output_value,
		output_uom.uom_name,
		ei.heatcontent_value as heatcontent,
		heat.uom_name as heatcontent_uom,
		ei.frequency,
		ei.forecast_type,
		ei.fuel_type_value_id as fuel_type_value_id,
		state_value.description,
		rg.generator_group_name,
		ISNULL(esf.sequence_order,1),
		eph2.entity_name

	from
		#ems_inv ei 
		inner join rec_generator rg on ei.generator_id=rg.generator_id
		inner join #ssbm on rg.fas_book_id=#ssbm.fas_book_id
		inner join portfolio_hierarchy ph on ph.entity_id=#ssbm.sub_entity_id
		and ph.hierarchy_level=2
		inner join portfolio_hierarchy ph1 on ph1.entity_id=#ssbm.stra_book_id
		and ph1.hierarchy_level=1
		inner join source_price_curve_def spcd on spcd.source_curve_def_id=ei.curve_id
		left join static_data_value sdv on sdv.value_id=ei.forecast_type
		left outer join rec_generator_group rgg on rgg.generator_group_name=rg.generator_group_name
		left join formula_editor fe on fe.formula_id=ei.formula_id
		left join formula_editor fe2 on fe2.formula_id=ei.formula_detail_id
 	    LEFT JOIN rec_volume_unit_conversion Conv1 ON            
			 conv1.from_source_uom_id  = ISNULL(ei.uom_id,-1)
			 AND conv1.to_source_uom_id =COALESCE('+case when @convert_uom_id is not null then cast(@convert_uom_id as varchar) else 'NULL' END +',ei.uom_id,-1)
			 And conv1.state_value_id is null
			 AND conv1.assignment_type_value_id is null
			 AND conv1.curve_id  IS NULL

			 LEFT OUTER JOIN rec_volume_unit_conversion Conv2 ON            
			 conv2.from_source_uom_id = ISNULL(ei.uom_id,-1)
			 AND conv2.to_source_uom_id = ISNULL(ei.uom_id,-1)
			 And conv2.state_value_id IS NULL
			 AND conv2.assignment_type_value_id IS NULL
			 AND conv2.curve_id =ei.curve_id
			 AND conv2.to_curve_id ='+CAST(ISNULL(@curve_id,0) AS VARCHAR)+' 
		LEFT JOIN source_uom su on su.source_uom_id=Conv1.to_source_uom_id
		LEFT JOIN (select generator_id,sum(per_ownership) ownership_per from generator_ownership group by generator_id) ownership
		on rg.generator_id=ownership.generator_id
		left join static_data_value state_value on state_value.value_id=rg.state_value_id
		left join source_uom heat on heat.source_uom_id=ei.heatcontent_uom_id
		left join source_uom output_uom on output_uom.source_uom_id=ei.output_uom_id	
		INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
				AND ei.term_start between isnull(esme.effective_date,''1900-01-01'') AND isnull(esme.end_date,''9999-01-01'')
		INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id=esme.ems_source_model_id AND esmd.curve_id=ei.curve_id			
		left join ems_source_formula esf on esf.ems_source_model_detail_id = esmd.ems_source_model_detail_id AND esf.forecast_type=ei.forecast_type
		'+
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
	  ' left join ems_edr_include_inv edr_inc on edr_inc.generator_id=ei.generator_id and
		edr_inc.curve_id=ei.curve_id and ei.term_start between edr_inc.term_start and edr_inc.term_end
		--edr_inc.series_type=ei.forecast_type
		'+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' join user_defined_group_detail udgd on udgd.rec_generator_id=rg.generator_id 
		and isnull(udgd.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

		where
		(edr_inc.generator_id is null or(edr_inc.generator_id is not null and (edr_inc.series_type=ei.forecast_type)))
		and (ei.term_start between '''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+''' or ei.term_end between 
			'''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+''')
		 '
		+ case when @as_of_date is not null then ' And ei.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end

	   + CASE WHEN @technology IS NOT NULL THEN ' and rg.technology ='+ cast(@technology as varchar(100)) ELSE '' END
	   + CASE WHEN @fuel_value_id IS NOT NULL THEN ' and rg.fuel_value_id ='+ cast(@fuel_value_id as varchar(100)) ELSE '' END
	   + CASE WHEN @curve_id is not null AND @curve_id<>@co2e_curve_id THEN ' and ei.curve_id ='+ cast(@curve_id as varchar(100)) ELSE '' END
	   + case when @as_of_date is not null then ' And ei.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end 
	   + case when @technology_sub_type is not null then ' And rg.classification_value_id='+cast(@technology_sub_type as varchar) else '' end
	   + case when @fuel_type is not null then ' And fe2.static_value_id='+cast(@fuel_type as varchar) else '' end
	   + case when @reduction_type is not null then ' And rg.reduction_type='+cast(@reduction_type as varchar) else '' end
	   + case when @reduction_sub_type is not null then ' And rg.reduction_sub_type='+cast(@reduction_sub_type as varchar) else '' end
	   + case when @udf_source_sink_group is not null then ' And udgd.user_defined_group_id='+cast(@udf_source_sink_group as varchar) else '' end
	   + case when @udf_group1 is not null then ' And rg.udf_group1='+cast(@udf_group1 as varchar) else '' end
	   + case when @udf_group2 is not null then ' And rg.udf_group2='+cast(@udf_group2 as varchar) else '' end
	   + case when @udf_group3 is not null then ' And rg.udf_group3='+cast(@udf_group3 as varchar) else '' end
	   + case when @report_type=5 then ' And isnull(rg.source_sink_type,''s'')=''s'' ' 
			  when @report_type=6 then ' And isnull(rg.source_sink_type,''s'')=''k'' ' 
			  else '' 	end
	   + CASE WHEN @include_hypothetical='y' THEN '' ELSE ' and isnull(rg.is_hypothetical,''n'') = ''' +@include_hypothetical+''''  END 
	   + CASE WHEN ISNULL(@drill_criteria, '') <> '' THEN
				CASE WHEN @drill_group=1 THEN ' AND ph.entity_name='''+@drill_criteria+''''
				 WHEN @drill_group=2 THEN ' AND ph1.entity_name='''+@drill_criteria+''''
				 WHEN @drill_group=3 THEN ' AND state_value.description='''+@drill_criteria+''''
				 WHEN @drill_group=4 THEN ' AND rg.generator_group_name='''+@drill_criteria+''''
				 WHEN @drill_group=6 THEN ' AND eph2.entity_name='''+@drill_criteria+''''
				 ELSE '' END
			ELSE 
				CASE WHEN @drill_group=4 THEN ' AND rg.generator_group_name IS NULL' ELSE '' END
			END
			
		exec(@sql_select)

	create table #temp1(
		group1 varchar(100) COLLATE DATABASE_DEFAULT,
		op_name varchar(100) COLLATE DATABASE_DEFAULT,
		business_entity varchar(100) COLLATE DATABASE_DEFAULT,
		generator_id int,
		generator_name varchar(100) COLLATE DATABASE_DEFAULT,
		term_start datetime,
		emission_type varchar(100) COLLATE DATABASE_DEFAULT,
		state varchar(100) COLLATE DATABASE_DEFAULT,
		generator_group_name varchar(100) COLLATE DATABASE_DEFAULT,
		uom varchar(100) COLLATE DATABASE_DEFAULT,
		output_uom varchar(50) COLLATE DATABASE_DEFAULT,
		heatcontent_uom varchar(50) COLLATE DATABASE_DEFAULT,
		Inventory float,
		[output] float,
		[Heatcontent] float,
		reduction float,
		curve_id INT
	)

DECLARE @listCol VARCHAR(500),@listCol_sum VARCHAR(500)
DECLARE @sql_output varchar(100),@sql_hc varchar(100),@sql_reduc varchar(100),@max_seq_number int,@seq_count int

 
select @max_seq_number=max(seq_order),@seq_count=count(distinct seq_order) from #temp

SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + ltrim(str((seq_order)))
			 FROM    #temp
                   ORDER BY '],[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + ']'

SELECT  @listCol_sum = STUFF(( SELECT DISTINCT ',sum(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FROM    #temp
                   ORDER BY ',sum(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FOR XML PATH('')), 1,1, '')

if @listCol_sum is null
	set @listCol_sum='sum([0])[0]'

--SELECT  @listCol_sum = STUFF(( SELECT DISTINCT '],0))['+ltrim(str((seq_order-1)))+'],sum(NULLIF([' + ltrim(str((seq_order))) FROM    #temp
--                   ORDER BY '],0))['+ltrim(str((seq_order-1)))+'],sum(NULLIF([' + ltrim(str((seq_order))) FOR XML PATH('')), 1,9, '') + '],0))[' + ltrim(str((@max_seq_number)))+']'

SELECT  @sql_inv = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],a.[' + ltrim(str((seq_order))) FROM    #temp
                   ORDER BY '],a.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
SELECT  @sql_output = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],b.[' + ltrim(str((seq_order))) FROM    #temp
                   ORDER BY '],b.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
SELECT  @sql_hc = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],c.[' + ltrim(str((seq_order))) FROM    #temp
                   ORDER BY '],c.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
SELECT  @sql_reduc = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],d.[' + ltrim(str((seq_order))) FROM    #temp
                   ORDER BY '],d.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'



SET @sql_select =
	'
		insert into #temp1
		select a.group1,a.op_name,a.business_entity,a.generator_id,a.generator_name,a.term_start,a.emission_type,
					a.state,a.generator_group_name,a.uom ,a.output_uom,
					a.heatcontent_uom,'+@sql_inv+' as Inventory
					,'+@sql_output+' as Output,'+@sql_hc+' as [HeatContent],'+@sql_reduc+' as [Reduction],a.curve_id

		from
		(SELECT group1,op_name,business_entity,generator_id,generator_name,term_start,emission_type,state,generator_group_name,
				(uom)uom,max(heatcontent_uom)heatcontent_uom,max(output_uom)output_uom,curve_id,
				'+@listCol_sum+' FROM
		(SELECT	group1,op_name,business_entity,generator_id,generator_name,term_start,emission_type,
					fuel_type_value_id,state,generator_group_name,uom,output_uom,heatcontent_uom,inventory,seq_order,curve_id,forecast_type
			  FROM #temp
			   WHERE 1=1) src
		PIVOT (SUM(inventory) FOR seq_order

		IN ('+@listCol+')) AS pvt
		group by 
		group1,op_name,business_entity,generator_id,generator_name,term_start,emission_type,state,generator_group_name,curve_id,uom
		)a
		join
		(SELECT curve_id,term_start,generator_id,'+@listCol_sum+' FROM
		(SELECT [output],seq_order,curve_id,term_start,generator_id
					FROM #temp

					WHERE 1=1) src

		PIVOT (max([output]) FOR seq_order
		IN ('+@listCol+')) AS pvt
			group by curve_id,term_start,generator_id
		)b
		on a.generator_id=b.generator_id
		and a.curve_id=b.curve_id and a.term_start=b.term_start
		join
		(SELECT curve_id,term_start,generator_id,'+@listCol_sum+' FROM
		(SELECT [heatcontent],seq_order,curve_id,term_start,generator_id
					FROM #temp
					WHERE 1=1) src

		PIVOT (sum([heatcontent]) FOR seq_order
		IN ('+@listCol+')) AS pvt
			group by curve_id,term_start,generator_id
		)c
		on a.generator_id=c.generator_id
		and a.curve_id=c.curve_id and a.term_start=c.term_start
		join
		(SELECT curve_id,term_start,generator_id,'+@listCol_sum+' FROM
		(SELECT [reduction],seq_order,curve_id,term_start,generator_id
					FROM #temp
					WHERE 1=1) src
		PIVOT (sum([reduction]) FOR seq_order
		IN ('+@listCol+')) AS pvt
			group by curve_id,term_start,generator_id
		)d
		on a.generator_id=d.generator_id
		and a.curve_id=d.curve_id and a.term_start=d.term_start
	'

	EXECUTE (@sql_select)




	SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + ltrim(dbo.FNATermGrouping(term_start,@frequency))
				 FROM    #temp
					   ORDER BY '],[' + ltrim(dbo.FNATermGrouping(term_start,@frequency)) FOR XML PATH('')), 1, 2, '') + ']'
	IF @listCol is null
		set @listCol='[0]'


	SELECT  @listCol_sum = STUFF(( SELECT DISTINCT ',ROUND(sum([' + ltrim(dbo.FNATermGrouping(term_start,@frequency))+']),'+@round_value+')['+ltrim(dbo.FNATermGrouping(term_start,@frequency))+']' FROM    #temp
					   ORDER BY ',ROUND(sum([' + ltrim(dbo.FNATermGrouping(term_start,@frequency))+']),'+@round_value+')['+ltrim(dbo.FNATermGrouping(term_start,@frequency))+']' FOR XML PATH('')), 1,1, '')


	if @listCol_sum is null
		set @listCol_sum='sum([0])[0]'




	set @sql_select=	case when @group_by=1 then 'select op_name as Subsidiary,'
					 when @group_by=2 then 'select op_name as [Subsidiary],business_entity as [Business Entity],'
					 when @group_by=3 then 'select op_name as Subsidiary,state as [Entity],'
					 when @group_by=4 then 'select op_name as Subsidiary,generator_group_name as [Entity],'
					 when @group_by=5 then 'select op_name as Subsidiary,generator_name as [Entity],'
					 when @group_by=6 then 'select Group1 [Scope],'
				end+
			case when @report_type in(1,2,3,4,5,6) then ' emission_Type as [Emissions Type],'  
				 when @report_type in(2) then ' ''Intensity'' as [Type],'  
				 when @report_type in(3) then ' ''Net Mwh'' as [Type],'  
				 when @report_type in(4) then ' ''Heat Input'' as [Type],' else 
				'' end+
			case when @group_by=6  then 'generator_name as [Source],' else '' end




-------------#########################################################################
declare @a_ratio varchar(100),@sql_sum VARCHAR(1000)
set @a_ratio=''
--
--if (@report_type=2 )
--	set @a_ratio='MAX'

		--if @frequency=703
			select  @sql_sum=
						case when @report_type=1 then ' SUM(inventory) '
							  when @report_type=2 then '  SUM(inventory)/case when SUM(output)=0 then 1 else SUM(output) end  '
							  when @report_type=3 then '  SUM(heatcontent) '
							  when @report_type=4 then '  SUM(output) '
							  when (@report_type=5 or @report_type=6) then ' SUM(inventory) '
						end		
						


			set @sql_select=@sql_select+@listCol_sum+','+
						case when @report_type=1 or   (@report_type=5 or @report_type=6) then ' (uom) [UOM]'
							 when @report_type=2 then ' max(uom +''/''+output_uom) [UOM]'
							 when @report_type=3 then ' max(heatcontent_uom) [UOM]'
							 when @report_type=4 then ' max(output_uom)  [UOM]'
	
					end 	
			set @sql_select=@sql_select+@str_batch_or_paging_table+'
				FROM	
				(
					select 
						Group1,
						op_name,
						business_entity,
						state,
						generator_id,
						generator_name,
						dbo.FNATermGrouping(term_start,'+CAST(@frequency AS VARCHAR)+') as term,
						--term_start,
						emission_type,
						sum(Inventory) inventory,
						MAX(Output) output,
						sum(heatcontent) heatcontent,
						sum(reduction) reduction,
						uom,
						max(heatcontent_uom) heatcontent_uom,
						max(output_uom) output_uom,
						--max(fuel_type_value_id) fuel_type_value_id,
						generator_group_name,
						curve_id,' +@sql_sum +' as exp1
						
					from
						#temp1
					group by 	
						Group1,generator_name,dbo.FNATermGrouping(term_start,'+CAST(@frequency AS VARCHAR)+'),
						emission_type,uom,op_name,business_entity,
						state,generator_group_name,generator_id,curve_id
							
				)src
			PIVOT
			(sum(exp1) FOR term IN
				('+@listCol+'))
			AS PVT
			WHERE 1=1
			GROUP BY
				emission_type,uom, '+
	
		+case when @group_by=1 then ' op_name '
					 when @group_by=2 then ' op_name,business_entity '
					 when @group_by=3 then ' op_name,state'
					 when @group_by=4 then ' op_name,generator_group_name'
					 when @group_by=5 then ' op_name,generator_name,generator_id'
					 when @group_by=6 then ' Group1,op_name,generator_name,generator_id'
				end+
			' order by' +
		case when @group_by=1 then ' op_name, '
					 when @group_by=2 then ' op_name,business_entity, '
					 when @group_by=3 then ' op_name,state,'
					 when @group_by=4 then ' op_name,generator_group_name,'
					 when @group_by=5 then ' op_name,generator_name,'
					 when @group_by=6 then ' Group1,'
			 end+
		' emission_Type '
		--print @sql_select
		exec(@sql_select)
		
		--return total rows
		IF @process_id IS NOT NULL
		BEGIN
			SET @sql_select= 'SELECT COUNT(*) TotalRow, ''' + @process_id + ''' process_id FROM ' + @process_table
			
			EXEC(@sql_select)
		END
	
END


--*****************FOR BATCH PROCESSING**********************************            
 

IF  @batch_process_id is not null        
BEGIN        
 SELECT @str_batch_or_paging_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
 EXEC(@str_batch_or_paging_table)        
 declare @report_name varchar(100)        

 set @report_name='Emissions Inventory Report'        
        
 SELECT @str_batch_or_paging_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_run_emissions_intensity_report',@report_name)         
 EXEC(@str_batch_or_paging_table)        
   
END        
--********************************************************************   


END



