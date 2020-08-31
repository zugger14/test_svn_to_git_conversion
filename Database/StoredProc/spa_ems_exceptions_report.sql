IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_exceptions_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_exceptions_report]
GO
/****** Object:  StoredProcedure [dbo].[spa_ems_exceptions_report]    Script Date: 06/23/2009 17:04:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_ems_exceptions_report]    
	 @report_type CHAR(1)='a',                --'a' Activity Data, 'f' Emissions factors
	 @sub_entity_id varchar(500),     
	 @strategy_entity_id varchar(500),     
	 @book_entity_id varchar(500),             		
	 @generator_id varchar(max) = null,            
	 @technology int = null,             
	 @generation_state int=null,
	 @jurisdiction int=null,
	 @generator_group varchar(100)=null	,
	 @fuel_type int=null,
	 @input_id int=null,	
	 @term_start datetime =null,
	 @term_end datetime =null	

AS    
SET NOCOUNT ON         
BEGIN


--###########################################
declare @sql_Where varchar(1000)
DECLARE @Sql_Select varchar(8000)

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
			 ON book.parent_entity_id = stra.entity_id               
		WHERE 1=1 '            
		IF @sub_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' +@sub_entity_id + ') '             
		 IF @strategy_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' +@strategy_entity_id + ' ))'            
		  IF @book_entity_id IS NOT NULL            
		  SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
		SET @Sql_Select=@Sql_Select+@Sql_Where            

	--print @Sql_Select
	exec(@Sql_Select)



----#########
create table #temp_date([id] int identity,term_start datetime,term_end datetime)
declare @count int
declare @terms_start_new datetime
declare @terms_end_new datetime
declare @MWH_input_id int
declare @input_name varchar(100)
set @MWH_input_id=92

select @input_name=input_name from ems_source_input where ems_source_input_id=@input_id

set @terms_start_new=dateadd(month,-1,@term_start)
while dbo.FNAGETCONTRACTMONTH(@terms_start_new)<=dbo.FNAGETCONTRACTMONTH(dateadd(month,-1,@term_end))
BEGIN

	set @terms_start_new=dateadd(month,1,@terms_start_new)
	set @terms_end_new=dateadd(month,1,@terms_start_new)-1

	insert into #temp_date(term_start,term_end)
	 select dbo.FNAGETCONTRACTMONTH(@terms_start_new),@terms_end_new
	
END


IF @report_type='a'
	BEGIN
		set @Sql_Select='
			select DISTINCT
				ph.entity_name as [OpCo],
				rg.name as  [Source/Sink],	
				rg.id as [External Facility ID],
				RG.[ID2] AS	Unit,
				dbo.fnadateformat(td.term_start) as [Term],
				esi.input_name as [Input]
			from 
				#temp_date td 
				JOIN rec_generator rg ON 1=1
				inner join #ssbm on rg.fas_book_id=#ssbm.fas_book_id
				INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
				INNER JOIN (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id FROM 
								ems_source_model_effective WHERE 1=1 group by generator_id) ab
				on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
				INNER JOIN ems_source_Model esm on esm.ems_source_model_id=esme.ems_source_model_id
				INNER JOIN ems_input_map eim on eim.source_model_id=esm.ems_source_model_id
				INNER JOIN ems_source_input esi on esi.ems_source_input_id=eim.input_id
				left join ems_gen_input egi on egi.ems_Input_id=eim.input_id 
					 and rg.generator_id=egi.generator_id 
					 AND ((td.term_start=egi.term_start AND egi.frequency=703) OR 	(YEAR(td.term_start)=YEAR(egi.term_start) AND egi.frequency=706))				
				left join static_data_value classification on classification.value_id=rg.classification_value_id
				left join static_data_value technology on technology.value_id=rg.technology
				left join static_data_value fuel on fuel.value_id=rg.fuel_value_id
				left join static_data_value state on state.value_id=rg.gen_state_value_id
				left join rec_generator_group rgg on rgg.generator_group_name=rg.generator_group_name
				LEFT JOIN portfolio_hierarchy ph on ph.entity_id=rg.legal_entity_value_id
				
			where 1=1 
				AND egi.input_value is null
				'
				+ case when @sub_entity_id is not null then ' and rg.legal_entity_value_id in('+@sub_entity_id+')' ELSE '' end
				+ case when @generator_id is not null then ' and rg.generator_id IN('+@generator_id+')' else '' end
				+ case when @technology is not null then ' and rg.technology='+cast(@technology as varchar) else '' end
				+ case when @generation_state is not null then ' and rg.gen_state_value_id='+cast(@generation_state as varchar) else '' end
				+ case when @jurisdiction is not null then ' and rg.state_value_id='+cast(@jurisdiction as varchar) else '' end	 
				+ case when @generator_group is not null then ' and rgg.generator_group_id='''+@generator_group+'''' else '' end 
				+ case when @fuel_type is not null then ' and rg.fuel_value_id='+cast(@fuel_type as varchar) else '' end+
				+ case when @input_id is not null then ' and  esi.ems_source_input_id='+cast(@input_id as varchar) else '' end+
			' 
			order by rg.name,dbo.fnadateformat(td.term_start) '
	--	EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)
	END
	ELSE
		BEGIN
			set @Sql_Select='
			select 
				rg.name as [Source/Sink],
				esm.ems_source_model_name [SourceModel],
				dbo.fnadateformat(cfv.prod_date) as [Term],								
				MAX(dbo.FNAFNACurveNames(fe.formula)) [Formula],
				--ISNULL(ecdv.formula_eval,ecdv.formula_eval_reduction) [FormulaValue]
				MAX(cfv.formula_str)[FormulaValue]
			FROM				
				rec_generator rg
				INNER JOIN #ssbm on rg.fas_book_id=#ssbm.fas_book_id
				INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
				INNER JOIN (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id FROM 
								ems_source_model_effective WHERE 1=1 group by generator_id) ab
				on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
				INNER JOIN ems_source_Model esm on esm.ems_source_model_id=esme.ems_source_model_id
				INNER JOIN ems_calc_detail_value ecdv on ecdv.generator_id=rg.generator_id
				INNER JOIN calc_formula_value cfv on cfv.generator_id=rg.generator_id
						 AND ecdv.term_start=cfv.prod_date AND ISNULL(cfv.formula_id,-1)=COALESCE(ecdv.formula_id,ecdv.formula_id_reduction,-1)
				LEFT JOIN formula_nested fn on fn.formula_group_id=ISNULL(ecdv.formula_id,ecdv.formula_id_reduction)
				LEFT JOIN formula_editor fe on fe.formula_id=COALESCE(fn.formula_id,ecdv.formula_id,ecdv.formula_id_reduction)
				left join static_data_value classification on classification.value_id=rg.classification_value_id
				left join static_data_value technology on technology.value_id=rg.technology
				left join static_data_value fuel on fuel.value_id=rg.fuel_value_id
				left join static_data_value state on state.value_id=rg.gen_state_value_id
				left join rec_generator_group rgg on rgg.generator_group_name=rg.generator_group_name

				
			WHERE 1=1 '+
			 		' AND ((ecdv.formula_str like ''%EMSConv%'' AND (ISNULL(ecdv.formula_eval,'''') like ''%undef%'' OR (cfv.formula_str LIKE ''%undef%'') )) OR
					(ecdv.formula_str_reduction like ''%EMSConv%'' AND (ISNULL(ecdv.formula_eval_reduction,'''') like ''%undef%'')))'
			+CASE WHEN @term_start IS NOT NULL THEN ' AND ecdv.term_start between '''+CAST(@term_start AS VARCHAR)+''' AND '''+CAST(@term_end AS VARCHAR)+'''' ELSE '' END
			+ case when @sub_entity_id is not null then ' and rg.legal_entity_value_id in('+@sub_entity_id+')' end
			+ case when @generator_id is not null then ' and rg.generator_id='+cast(@generator_id as varchar) else '' end
			+ case when @technology is not null then ' and rg.technology='+cast(@technology as varchar) else '' end
			+ case when @generation_state is not null then ' and rg.gen_state_value_id='+cast(@generation_state as varchar) else '' end
			+ case when @jurisdiction is not null then ' and rg.state_value_id='+cast(@jurisdiction as varchar) else '' end	 
			+ case when @generator_group is not null then ' and rgg.generator_group_id='''+@generator_group+'''' else '' end 
			+ case when @fuel_type is not null then ' and rg.fuel_value_id='+cast(@fuel_type as varchar) else '' end
			+' Group by rg.name ,esm.ems_source_model_name,dbo.fnadateformat(cfv.prod_date)'
	--	EXEC spa_print @Sql_Select
		EXEC(@Sql_Select)

		END
END 















GO
