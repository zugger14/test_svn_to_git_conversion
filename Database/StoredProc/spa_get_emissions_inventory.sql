
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_get_emissions_inventory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_emissions_inventory]


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





--exec spa_get_emissions_inventory s,274,NULL,'2007-05-30','2007-05-30','r',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'172',NULL,NULL,'Vehicles',NULL
CREATE PROCEDURE [dbo].[spa_get_emissions_inventory]
--ALTER PROCEDURE [dbo].[spa_get_emissions_inventory]
	@flag char(1)='s', -- 's' SUMmary,'d' detail
	@generator_id varchar(max)=NULL,
	@as_of_date datetime=null,
	@term_start datetime=null,
	@term_end datetime=null,
	@current_forecast char(1)=null,
	@drill_curve varchar(100)=null,
	@drill_uom varchar(100)=null,
	@drill_term varchar(100)=null,
	@drill_generator_name varchar(500)=null,
	@emisssions_reductions char(1)='e',
	@drill_forecast_type varchar(100)=null,
	@forecast_type varchar(100)=null,	
	@fas_book_id varchar(100)=null,
	@technology int=null,
	@fuel_value_id int=null,
	@generator_group_name varchar(500)=null,
	@ems_book_id varchar(200)=null,
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100)=null,
	@curve_id int=null,
	@convert_uom_id int=null,
	@show_co2e char(1)='n',
	@report_type char(1)='s', -- 's' group by source/sink - 'g' group by Gas
	@technology_sub_type int=null,
	@fuel_type int=null,
	@source_sink_type int=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL, 	   
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	@transpose_report char(1)='n',
	@frequency int=null,
	@drill_sub varchar(100)=null,
	@drill_series_type VARCHAR(100)=null,
	@round_value CHAR(1)='0', 
	@show_base_period CHAR(1)='n',
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL

AS
BEGIN
	DECLARE @Sql_Select varchar(MAX)
	DECLARE @sql varchar(8000)
	DECLARE @sql2 varchar(8000)
	DECLARE @Sql_Inv VARCHAR(8000)
	DECLARE @co2e_curve_id int
	DECLARE @Output_id int
	DECLARE @str_batch_table varchar(max)        
	
	SET @Sql_Select = ''   

--################## for batch process

	SET @str_batch_table=''        
	IF @batch_process_id is not null      
		SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         
---###################
	
	

	SET @Output_id=1052
	SET @co2e_curve_id=-1


	IF @drill_series_type ='Inventory' OR @drill_series_type='Base'
		SET @drill_series_type=NULL

	IF @emisssions_reductions is NULL
		SET @emisssions_reductions='e'

	if @drill_curve='Co2e'
		set @drill_curve = NULL


	IF @term_start IS NOT NULL AND @term_end IS NULL            
	 SET @term_end = @term_start            

------------------------------------------
-------------------------------------------
         
	CREATE TABLE #ssbm(
	 fas_book_id int,            
	 stra_book_id int,            
	 sub_entity_id int            
	)            
	SET @Sql_Select=            
		'
		INSERT INTO #ssbm            
		SELECT                      
			book.entity_id fas_book_id,
			book.parent_entity_id stra_book_id, 
			stra.parent_entity_id sub_entity_id             
		FROM            
			portfolio_hierarchy book (nolock) INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
		WHERE 1=1 '            
		+CASE WHEN @sub_entity_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR(500)) + ') '  ELSE '' END
		+CASE WHEN @strategy_entity_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR(500)) + ' ))' ELSE '' END                 
		+CASE WHEN @fas_book_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @fas_book_id + ')) ' ELSE '' END                       

	
	EXEC (@Sql_Select)  
	       
---------------------------------------

	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])   
--------------------------------------------------

	DECLARE @param_def nvarchar(500)
	DECLARE @nsql nvarchar(1000)
	
	IF @sub_entity_id IS NULL AND @generator_id IS NULL
		SELECT  @sub_entity_id = 
				STUFF(( SELECT DISTINCT ',' + ltrim(str((sub_entity_id)))
				FROM    #ssbm
                ORDER BY ',' + ltrim(str((sub_entity_id))) FOR XML PATH('')), 1, 1, '') + ''

	
	SET @param_def = N'@sub_entity_id varchar(100) OUTPUT';
	IF @sub_entity_id IS NULL AND @generator_id IS NOT NULL
	BEGIN
--		SELECT  @sub_entity_id = 
--				STUFF(( SELECT DISTINCT ',' + ltrim(str((legal_entity_value_id)))
--				FROM    rec_generator
--				WHERE generator_id in(@generator_id)
--                ORDER BY ',' + ltrim(str((legal_entity_value_id))) FOR XML PATH('')), 1, 1, '') + ''

		SET @nsql = N'SELECT  @sub_entity_id = 
				STUFF(( SELECT DISTINCT '','' + LTRIM(STR((legal_entity_value_id)))
				FROM rec_generator
				WHERE generator_id IN(' + @generator_id + ')
                ORDER BY '','' + LTRIM(STR((legal_entity_value_id))) FOR XML PATH('''')), 1, 1, '''') + '''''
		
		EXECUTE sp_executesql @nsql, @param_def, @sub_entity_id = @sub_entity_id OUTPUT;
		EXEC spa_print '@sub_entity_idA:', @sub_entity_id
	END

	IF @sub_entity_id IS NULL AND @generator_id IS NULL AND @generator_group_name IS NOT NULL
	BEGIN
--		SELECT  @sub_entity_id = 
--				STUFF(( SELECT DISTINCT ',' + ltrim(str((rg.legal_entity_value_id)))
--				FROM    rec_generator rg
--				left outer join rec_generator_group rgg on rgg.generator_group_name=rg.generator_group_name
--				WHERE rgg.generator_group_id in(@generator_group_name)
--              ORDER BY ',' + ltrim(str((rg.legal_entity_value_id))) FOR XML PATH('')), 1, 1, '') + ''

		SET @nsql = N'SELECT  @sub_entity_id = 
				STUFF(( SELECT DISTINCT '','' + LTRIM(STR((rg.legal_entity_value_id)))
				FROM rec_generator rg
				LEFT OUTER JOIN rec_generator_group rgg ON rgg.generator_group_name = rg.generator_group_name
				WHERE rgg.generator_group_id IN(' + @generator_group_name + ')
                ORDER BY '','' + LTRIM(STR((rg.legal_entity_value_id))) FOR XML PATH('''')), 1, 1, '''') + '''''

		
		EXECUTE sp_executesql @nsql, @param_def, @sub_entity_id = @sub_entity_id OUTPUT;
		EXEC spa_print '@sub_entity_idB:', @sub_entity_id
	END

------------
	
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
		formula_eval VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		is_base_year INT			
	)

	SELECT @Sql_Inv=dbo.FNAGetProcessTableSQL('ems_calc_detail_value',@term_start,@term_end,@sub_entity_id,@show_base_period,NULL,NULL)	

 
	SET @sql_select= 
			' 
			INSERT INTO #ems_inv
			SELECT 
				ei.generator_id ,
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
				CASE WHEN YEAR(ei.term_start) between fs.base_year_from AND fs.base_year_to  THEN 1 ELSE 0 END	
			FROM
			  ('+@Sql_Inv+') ei	
				LEFT JOIN rec_generator rg on rg.generator_id=ei.generator_id
				LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id=rg.legal_entity_value_id
			WHERE 1=1'
				+ CASE WHEN @as_of_date is not null then ' And ei.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end+
				+ CASE WHEN @forecast_type is not null then ' And ei.forecast_type in('+@forecast_type+')' else '' end
				+ CASE WHEN @generator_id is not null then ' And ei.generator_id in('+ @generator_id +')' else '' end
				
	EXEC(@sql_select)


---####################################
	CREATE  INDEX [IX_EI1] ON [#ems_inv]([generator_id])    
	CREATE  INDEX [IX_EI2] ON [#ems_inv]([curve_id])    
	CREATE  INDEX [IX_EI3] ON [#ems_inv]([term_start])    
	CREATE  INDEX [IX_EI4] ON [#ems_inv]([term_end])    
	CREATE  INDEX [IX_EI5] ON [#ems_inv]([forecast_type])    
	CREATE  INDEX [IX_EI6] ON [#ems_inv]([fuel_type_value_id])    
	
-----##################################





	IF @flag='s' or @flag='d'
	BEGIN

	CREATE TABLE #base_inv(
		generator_id INT,
		curve_id INT,
		forecast_type INT,
		fuel_type_value_id INT,	
		term_month INT,
		formula_value FLOAT
	)		


	IF @drill_sub IS NULL
	BEGIN

		SET @sql_select='
			INSERT INTO #base_inv
			SELECT 
				generator_id,
				curve_id,
				forecast_type,
				fuel_type_value_id,
				MONTH(term_start),
				SUM(formula_value)
			FROM
				#ems_inv
			WHERE
				is_base_year=1
			GROUP BY
				generator_id,curve_id,forecast_type,MONTH(term_start),fuel_type_value_id
			'
	EXEC(@sql_select)
	END		
	

------####################################
	CREATE  INDEX [IX_BE1] ON [#base_inv]([generator_id])    
	CREATE  INDEX [IX_BE2] ON [#base_inv]([curve_id])    
	CREATE  INDEX [IX_BE3] ON [#base_inv]([term_month])    
	
---------########################

	
		create table #temp(
			detail_id int,
			opco varchar(200) COLLATE DATABASE_DEFAULT,
			generator_id int,
			generator_name varchar(100) COLLATE DATABASE_DEFAULT,
			term_start datetime,
			as_of_date datetime,
			[Type] varchar(100) COLLATE DATABASE_DEFAULT,
			emission_type varchar(100) COLLATE DATABASE_DEFAULT,
			frequency varchar(100) COLLATE DATABASE_DEFAULT,
			inventory float,
			uom varchar(100) COLLATE DATABASE_DEFAULT,
			formula varchar(500) COLLATE DATABASE_DEFAULT,
			formula_format varchar(500) COLLATE DATABASE_DEFAULT,
			curve_name varchar(100) COLLATE DATABASE_DEFAULT,
			current_forecast char(1) COLLATE DATABASE_DEFAULT,
			curve_id int,
			[output]float,
			output_uom varchar(50) COLLATE DATABASE_DEFAULT,
			heatcontent float,
			heatcontent_uom varchar(50) COLLATE DATABASE_DEFAULT,
			frequency_id int,
			forecast_type int,
			conversion_factor float,
			fuel_type_value_id int,
			is_reduction CHAR(1) COLLATE DATABASE_DEFAULT
		)

			set @sql_select='
				insert into #temp
			SELECT 
				distinct
				NULL,
				ph.entity_name,
				rg.generator_id,
				rg.name generator_name,
				ei.term_start term_start,
				ei.as_of_date as_of_date,
				ISNULL(sdv.code,''Default Inventory'') as [Type],'
				+CASE WHEN @show_co2e='y' and (@drill_curve IS NULL OR @drill_curve<> 'Co2e') then '''Co2e''' else 'spcd.curve_name ' end +' as emission_type,
				''Monthly'' as [Frequency],
				(1-ISNULL(ownership_per,0))*ei.formula_value * ISNULL(conv1.conversion_factor,1) * ISNULL(conv2.conversion_factor,1)  volume,
				  su.uom_name  as UOM,
				CASE WHEN fe.formula_type=''n'' then '''' else ei.formula_eval+''<br><em>'' end ,
				CASE WHEN fe.formula_type=''n'' then ''Nested Formula'' else dbo.FNAFormulaFormat(fe.formula,''r'')+''</em>'' end as Formula,
				spcd.curve_name,
				ei.current_forecast,
				ei.curve_id,
				ei.output_value as Output,
				output.uom_name as output_uom,
				ei.heatcontent_value as heatcontent,
				heat.uom_name as heatcontent_uom,
				ISNULL(ei.frequency,703),
				ei.forecast_type,
				ISNULL(conv1.conversion_factor,1)*ISNULL(conv2.conversion_factor,1) as conversion_factor,
				ei.fuel_type_value_id as fuel_type_value_id,
				''n''

			from
				#ems_inv ei 
				INNER JOIN rec_generator rg on ei.generator_id=rg.generator_id
				INNER JOIN #ssbm on rg.fas_book_id=#ssbm.fas_book_id
				INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=ei.curve_id
				INNER JOIN ems_source_model_effective esme on esme.generator_id=ei.generator_id
				INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id = esme.ems_source_model_id
				and esmd.curve_id = ei.curve_id
				LEFT JOIN static_data_value sdv on sdv.value_id=ei.forecast_type
				left outer join rec_generator_group rgg on rgg.generator_group_name=rg.generator_group_name
				LEFT JOIN formula_editor fe on fe.formula_id=ei.formula_id
				LEFT JOIN formula_editor fe2 on fe2.formula_id=ei.formula_detail_id
			    LEFT JOIN rec_volume_unit_conversion Conv1 ON            
					 conv1.from_source_uom_id  = ISNULL(ei.uom_id,-1)
					 AND conv1.to_source_uom_id =COALESCE('+CASE WHEN @convert_uom_id is not null then cast(@convert_uom_id as varchar) else 'NULL' END +',ei.uom_id,-1)
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
				LEFT JOIN (select generator_id,SUM(per_ownership) ownership_per from generator_ownership group by generator_id) ownership
					 ON rg.generator_id=ownership.generator_id
				
				LEFT JOIN source_uom output on output.source_uom_id=ei.output_uom_id
				LEFT JOIN source_uom heat on heat.source_uom_id=ei.heatcontent_uom_id
				LEFT JOIN portfolio_hierarchy ph on ph.entity_id=rg.legal_entity_value_id
 				LEFT JOIN user_defined_group_detail udgd on udgd.rec_generator_id=rg.generator_id
				LEFT JOIN fas_subsidiaries fs on fs.fas_subsidiary_id=rg.legal_entity_value_id
				'
				+CASE WHEN @ems_book_id is not null then
				' LEFT JOIN source_sink_type sst on sst.generator_id=rg.generator_id
				  INNER JOIN ems_portfolio_hierarchy eph on eph.entity_id=sst.source_sink_type_id
				  and eph.hierarchy_level=0
				  INNER JOIN ems_portfolio_hierarchy eph1 on eph1.entity_id=eph.parent_entity_id
				  and eph1.hierarchy_level=1		
				  INNER JOIN ems_portfolio_hierarchy eph2 on eph2.entity_id=eph1.parent_entity_id
					  AND eph2.hierarchy_level=2 
					  AND (eph.entity_id in('+@ems_book_id
							+') or eph1.entity_id in ('+ @ems_book_id
							+') or eph2.entity_id in ('+ @ems_book_id+'))'
				 else '' end+
			 ' where 1=1'
			   + CASE WHEN @term_start is not null then ' And ei.term_start between '''+cast(@term_start as varchar)+''' AND '''+cast(@term_end as varchar)+'''' else '' end+
				' AND (is_base_year=0 OR(is_base_year=1 and YEAR('''+CAST(@term_start AS VARCHAR(20)) +''') BETWEEN fs.base_year_from AND fs.base_year_to))
				'			
			+CASE WHEN @technology is not null THEN ' and rg.technology ='+ cast(@technology as varchar(100)) ELSE '' END
			+CASE WHEN @fuel_value_id is not null THEN ' and rg.fuel_value_id ='+ cast(@fuel_value_id as varchar(100)) ELSE '' END
			+CASE WHEN @generator_group_name is not null THEN ' and rgg.generator_group_id in('+ cast(@generator_group_name as varchar(100))+')' ELSE '' END
			+CASE WHEN @curve_id is not null AND @curve_id<>@co2e_curve_id THEN ' and ei.curve_id ='+ cast(@curve_id as varchar(100)) ELSE '' END
			+CASE WHEN @drill_generator_name is not null then ' and rg.name='''+cast(@drill_generator_name as varchar(100))+'''' else '' end 	 
			+CASE WHEN @drill_term is not null then ' and dbo.fnagetcontractmonth(ei.term_start)=dbo.fnagetcontractmonth('''+@drill_term+''')' else '' end+
			+CASE WHEN @as_of_date is not null then ' And ei.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end 
			+CASE WHEN @technology_sub_type is not null then ' And rg.classification_value_id='+cast(@technology_sub_type as varchar) else '' end
			+CASE WHEN @fuel_type is not null then ' And fe2.static_value_id='+cast(@fuel_type as varchar) else '' end
			+CASE WHEN @reduction_type is not null then ' And rg.reduction_type='+cast(@reduction_type as varchar) else '' end
			+CASE WHEN @reduction_sub_type is not null then ' And rg.reduction_sub_type='+cast(@reduction_sub_type as varchar) else '' end
			+CASE WHEN @udf_source_sink_group is not null then ' And udgd.user_defined_group_id='+cast(@udf_source_sink_group as varchar) else '' end
			+CASE WHEN @udf_group1 is not null then ' And rg.udf_group1='+cast(@udf_group1 as varchar) else '' end
			+CASE WHEN @udf_group2 is not null then ' And rg.udf_group2='+cast(@udf_group2 as varchar) else '' end
			+CASE WHEN @udf_group3 is not null then ' And rg.udf_group3='+cast(@udf_group3 as varchar) else '' end
			+CASE WHEN ISNULL(@drill_sub, '') <> '' then 'And ph.entity_name='''+@drill_sub+'''' else '' end
			+CASE WHEN @drill_series_type IS NOT NULL THEN ' AND sdv.code='''+@drill_series_type+'''' ELSE '' END
			
		EXEC spa_print @sql_select
		EXEC(@sql_select)
		

----############### Now bring the deal Transactions
			SET @sql_select=
			'
			insert into #temp
			SELECT 
				NULL,
				dbo.FNAEmissionHyperlink(2,10131010, ph.entity_name,cast(sdh.source_deal_header_id as varchar),NULL),  
				rg.generator_id,
				rg.name generator_name,
				sdh.term_start term_start,
				sdh.deal_date as_of_date,
				NULL as [Type],
				spcd.curve_name as emission_type,
				CASE WHEN sdh.deal_volume_frequency=''a'' THEN ''Annually''
					 WHEN sdh.deal_volume_frequency=''q'' THEN ''Quaterly''
					ELSE ''Monthly'' END	AS frequency,
				CASE WHEN buy_sell_flag=''s'' THEN sdh.deal_volume*'+
					  'ISNULL(CO2Conv.conversion_factor,1)*ISNULL(conv1.conversion_factor,1) ELSE 0 END AS volume,
				ISNULL(CO2Conv.curve_label,spcd.curve_name)+'' ''+ su.uom_name  AS uom, 
				NULL as Formula, 
				NULL as Formula_format,
				spcd.curve_name AS curve_name, 
				CASE WHEN fas_deal_type_value_id=405 THEN ''t'' else ''r'' end as current_forecast,
				sdh.curve_id AS curve_id, 
				NULL as Output,
				NULL as output_uom,
				NULL as heatcontent,
				NULL as heatcontent_uom,
				CASE WHEN sdh.deal_volume_frequency=''m'' THEN 703
					 WHEN sdh.deal_volume_frequency=''q'' THEN 704
				 ELSE 706 END	AS frequency_id,
				NULL as forecast_type,'
				+CASE WHEN @show_co2e='y' then  'CO2Conv.conversion_factor*conv1.conversion_factor' else '1' end +'*conv1.conversion_factor  as conversion_factor,
				NULL as fuel_type_value_id,
				''n''
			from(		
				select 
					 (sdh.source_deal_header_id) source_deal_header_id,      
					 max(sdd.source_deal_detail_id) source_deal_detail_id,      
					 (sdd.buy_sell_flag) buy_sell_flag,             
					 max(sdh.counterparty_id) counterparty_id,            
					 max(sdh.source_deal_type_id) source_deal_type_id,
					 max(sdh.deal_sub_type_type_id) deal_sub_type_type_id,            
					 max(sdh.deal_date) deal_date,             
					 max(sdh.generator_id) generator_id,
					 sdd.curve_id,
					 SUM(sdd.volume_left) as deal_volume,
					 max(sdd.deal_volume_uom_id) as deal_volume_uom_id,            
					 max(sdh.source_system_book_id1) source_system_book_id1,            
					 max(sdd.deal_volume_frequency) as deal_volume_frequency,
					 sdd.term_start,
					 max(sdd.term_end) term_end,
					 (ssbm.fas_deal_type_value_id)fas_deal_type_value_id      

				from                
					 source_deal_header sdh 
					 INNER JOIN source_deal_detail sdd 
								ON sdd.source_deal_header_id = sdh.source_deal_header_id             
					 INNER JOIN source_system_book_map ssbm on
								ssbm.source_system_book_id1=sdh.source_system_book_id1	
								AND ssbm.source_system_book_id2=sdh.source_system_book_id2	
								AND ssbm.source_system_book_id3=sdh.source_system_book_id3	
								AND ssbm.source_system_book_id4=sdh.source_system_book_id4	
						
				WHERE 1=1 
					AND sdh.source_deal_type_id in(59,510,511) 
				 
					--AND year(term_start)=@reporting_year
					--sdh.deal_date<=@as_of_date
				GROUP BY 
					sdd.curve_id, sdd.term_start,sdh.generator_id,sdd.buy_sell_flag,ssbm.fas_deal_type_value_id,sdh.source_deal_header_id

			) sdh
			INNER JOIN rec_generator rg (nolock)
				ON rg.generator_id=sdh.generator_id
			INNER JOIN #ssbm (nolock)
				ON #ssbm.fas_book_id = rg.fas_book_id			
			INNER JOIN portfolio_hierarchy ph 
				ON ph.entity_id=#ssbm.sub_entity_id
					    
			LEFT OUTER JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdh.curve_id
			INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
				AND sdh.term_start between isnull(esme.effective_date,''1900-01-01'') AND isnull(esme.end_date,''9999-01-01'')
			INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id = esme.ems_source_model_id and
			esmd.curve_id = sdh.curve_id
			LEFT OUTER JOIN ems_source_formula esf 
				 ON esf.ems_source_model_detail_id=esmd.ems_source_model_detail_id AND esf.curve_id=sdh.curve_id AND esf.default_inventory=''y''
			LEFT OUTER JOIN static_data_value series 
				 ON series.value_id=esf.forecast_type
			LEFT OUTER JOIN dbo.series_type st 
				 ON st.series_type_value_id=esf.forecast_type and st.forecast_type=''f''			
			LEFT OUTER JOIN static_data_value rating on rating.value_id = esmd.rating_value_id
			LEFT OUTER JOIN static_data_value em on em.value_id = esmd.estimation_type_value_id
			LEFT OUTER JOIN static_data_value technology on technology.value_id=rg.technology
			LEFT OUTER JOIN static_data_value classification on classification.value_id=rg.classification_value_id
			LEFT OUTER JOIN static_data_value state on state.value_id=rg.gen_state_value_id

			LEFT OUTER JOIN rec_volume_unit_conversion conv1 on
				 conv1.from_source_uom_id  = sdh.deal_volume_uom_id 
				 AND conv1.to_source_uom_id ='+CASE WHEN @convert_uom_id is not null then cast(@convert_uom_id as varchar) else ' sdh.deal_volume_uom_id' end +'
				 And conv1.state_value_id is null
				 AND conv1.assignment_type_value_id is null
				 AND conv1.curve_id is null 	

			LEFT OUTER JOIN dbo.rec_volume_unit_conversion CO2Conv ON            
				 CO2Conv.from_source_uom_id  = sdh.deal_volume_uom_id
				 AND CO2Conv.to_source_uom_id = sdh.deal_volume_uom_id
				 And CO2Conv.state_value_id is null
				 AND CO2Conv.assignment_type_value_id is null
				 AND CO2Conv.curve_id = sdh.curve_id 
				AND CO2Conv.to_curve_id = '+CAST(ISNULL(@curve_id,-1) AS VARCHAR)+' 

			LEFT OUTER JOIN source_uom su on su.source_uom_id =conv1.to_source_uom_id
			LEFT JOIN source_counterparty sc 
				ON sc.source_counterparty_id=sdh.counterparty_id
			LEFT JOIN source_deal_type sdt 
				ON sdt.source_deal_type_id=sdh.source_deal_type_id
			LEFT JOIN source_deal_type sdt1 
				ON sdt.source_deal_type_id=sdh.deal_sub_type_type_id
				 '+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' join user_defined_group_detail udfg on udfg.rec_generator_id=rg.generator_id 
					  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

			WHERE 	1=1 
				 and fas_deal_type_value_id<>405
				 '+			
				' AND (ISNULL(rg.create_obligation_deal,''n'')=''n'' and ISNULL(reduction,''n'')=''n'')
				 and ((sdh.term_start between '''+cast(@term_start as varchar)+''' and  '''+cast(@term_end as varchar)+''' AND sdh.deal_volume_frequency<>''a'')
					   OR (YEAR(sdh.term_start) between '''+cast(YEAR(@term_start) as varchar)+''' and  '''+cast(YEAR(@term_end) as varchar)+''' AND sdh.deal_volume_frequency=''a'')) '		
				
				+CASE WHEN @generator_id is not null then ' And rg.generator_id in('+ @generator_id +')' else '' end
				+CASE WHEN @generator_group_name is not null and @generator_group_name<>'null' then ' and isnull(rg.generator_group_name, '''') = ''' + @generator_group_name + '''' else '' end
				+CASE WHEN @source_sink_type  is not null then 
						' and (isnull(sub.entity_id, 1) in(' +cast(@source_sink_type as varchar)+') OR isnull(stra.entity_id,1) in('+cast(@source_sink_type as varchar)+
						') OR isnull(book.entity_id,1) in('+cast(@source_sink_type as varchar)+'))' 	 else '' end
				+CASE WHEN @reduction_type IS NOT NULL THEN 	' and isnull(rg.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
				+CASE WHEN @reduction_sub_type IS NOT NULL THEN ' and isnull(rg.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
				+CASE WHEN @technology IS NOT NULL THEN ' and isnull(rg.technology, 1) = ' + cast(@technology as varchar)	ELSE '' END +
				+CASE WHEN @technology_sub_type IS NOT NULL THEN ' and isnull(rg.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
				--+CASE WHEN @primary_fuel IS NOT NULL THEN ' and isnull(vi.fuel_value_id, 1) = ' + cast(@primary_fuel as varchar)	ELSE '' END +
				+CASE WHEN @fuel_type IS NOT NULL THEN ' and isnull(rg.fuel_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
				+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
				+CASE WHEN @udf_group1 IS NOT NULL THEN ' and isnull(rg.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
				+CASE WHEN @udf_group2 IS NOT NULL THEN ' and isnull(rg.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
				+CASE WHEN @udf_group3 IS NOT NULL THEN ' and isnull(rg.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END 
				+CASE WHEN ISNULL(@drill_sub, '') <> '' then 'And ph.entity_name='''+@drill_sub+'''' else '' end
				+CASE WHEN @drill_series_type IS NOT NULL THEN ' AND series.code='''+@drill_series_type+'''' ELSE '' END

				if @curve_id is not null AND @curve_id<>@co2e_curve_id
					set @sql_select=@sql_select+ ' And sdh.curve_id='+cast(@curve_id as varchar)

			--PRINT @sql_select
			--EXEC(@sql_select)




--delete from #temp where UOM is null

	IF @flag='s'
	BEGIN
		DECLARE @sql_st varchar(8000)
		DECLARE @dyn_flds varchar(8000)
		DECLARE	@sno INT
		DECLARE	@sno1 INT
		DECLARE	@sno2 INT


		set @sno=1
		set @sno1=1
		set @sno2=1
		set @dyn_flds=''
		
		EXEC spa_print 'here'

		set @sql_st='select  egi.generator_id,egi.term_start,tmp.forecast_type'
		set @sql_st=@sql_st+ ' 
			INTO 
				#tmp_cross 
			FROM 
				ems_gen_input egi 
			INNER JOIN 
				#temp tmp on tmp.generator_id=tmp.generator_id AND tmp.term_start=egi.term_start
				LEFT JOIN source_uom su on egi.uom_id=su.source_uom_id 
			WHERE 
				egi.generator_id in(select generator_id from #temp) 
			GROUP BY 
				egi.generator_id,egi.term_start,tmp.forecast_type
			'

		
		SET @sql=@sql_st+'		
			select 
					t.opco as [Subsidiary],'
					+CASE WHEN @report_type='s' THEN ' dbo.FNAEmissionHyperlink(3,12101510,t.generator_name,t.generator_id,''''''s'''''') [Source/Sink],'
						 ELSE 'emission_type [Emissions Type],dbo.FNAEmissionHyperlink(3,12101510,t.generator_name,t.generator_id,''''''s'''''') [Source/Sink],' END+
					't.[Type] [Series Type],'
					+CASE WHEN @report_type='s' THEN 't.emission_type [Emissions Type],'
						 ELSE '' END+
					'dbo.FNAGetSQLStandardDate(t.as_Of_date) [As of Date],
					dbo.FNAGetSQLStandardDate(t.term_start) [Term],
					t.frequency [Frequency],
					ROUND(SUM(t.inventory),' +@round_value + ') [Inventory],'
					+CASE WHEN @show_base_period='y' THEN
						'ROUND(SUM(bi.formula_value)*MAX(conversion_factor),' +@round_value + ') [Base Inventory],
						ROUND((SUM(bi.formula_value)*MAX(conversion_factor))-SUM(t.inventory),' +@round_value + ') [Reduction],'
					ELSE '' END+					
					'(t.uom) [UOM],
					max(t.Output) [Output],
					max(t.Output_uom) [Output UOM],
					SUM(t.heatcontent) [Heat Input],
					max(t.heatcontent_uom) [Heat Input UOM]
					'+@str_batch_table+'
				from
					#temp t 
					LEFT join #base_inv bi on bi.generator_id=t.generator_id
						and bi.fuel_type_value_id=t.fuel_type_value_id			
						and bi.forecast_type=t.forecast_type			
						and bi.term_month=MONTH(t.term_start)			
						and bi.curve_id=t.curve_id
					LEFT JOIN #tmp_cross c on t.generator_id=c.generator_id and 
					CASE WHEN frequency_id=703 then t.term_start else cast(cast(year(t.term_start) as varchar)+''-01-01'' as datetime) end
								=c.term_start 
					and t.forecast_type=c.forecast_type
					LEFT JOIN emissions_inventory_edr edr on t.generator_id=edr.generator_id
					and t.curve_id=edr.curve_id and t.term_start=edr.term_start 
					and ISNULL(t.forecast_type,'''')=ISNULL(edr.forecast_type,'''')
					where 1=1 '
			 + CASE WHEN	@drill_curve is not null then ' and curve_name='''+@drill_curve+'''' else '' end
			set @sql=@sql+'
				group by t.OPCO,t.generator_name,t.Type,t.generator_id,
				t.emission_type,dbo.FNAGetSQLStandardDate(t.term_start),dbo.FNAGetSQLStandardDate(t.as_Of_date),
				t.frequency,t.uom,is_reduction
				order by t.generator_name,t.type,t.emission_type,
					dbo.FNAGetSQLStandardDate(t.as_Of_date),dbo.FNAGetSQLStandardDate(t.term_start),is_reduction
				'
			EXEC spa_print @sql
			exec(@sql)
							
 END	
 ELSE
 BEGIN




	DECLARE @input_str varchar(8000)
	set @input_str=''

	select 
		@input_str=@input_str+ISNULL(dbo.FNAGetInputCharacterstics(egi.ems_generator_id,egi.term_start)+'<br>','')

	from #temp tmp 
		LEFT JOIN ems_source_model_effective esme ON esme.generator_id=tmp.generator_id
				AND tmp.term_start BETWEEN ISNULL(esme.effective_date,'1900-01-01') AND ISNULL(esme.end_date,'9999-01-01')
		LEFT JOIN 
			ems_source_model esm ON esm.ems_source_model_id=esme.ems_source_model_id
		INNER JOIN ems_gen_input egi ON egi.generator_id=tmp.generator_id
			  AND egi.term_start=CASE WHEN esm.input_frequency=706 THEN CAST(CAST(YEAR(tmp.term_start) AS VARCHAR)+'-01-01' AS DATETIME) 
									  WHEN esm.input_frequency=705 THEN 
																	CASE WHEN CAST(MONTH(tmp.term_start) AS INT) <7 
																		 THEN CAST(CAST(YEAR(tmp.term_start) AS VARCHAR)+'-01-01' AS DATETIME)
																		 ELSE CAST(CAST(YEAR(tmp.term_start) AS VARCHAR)+'-07-01' AS DATETIME) 
																	END
									  ELSE tmp.term_start 
									  END
	WHERE 
		tmp.[type]=@drill_forecast_type
		AND tmp.curve_name=@drill_curve
	GROUP BY 
		egi.ems_generator_id,egi.term_start

--PRINT @input_str



		set @sql='select distinct
			opco as [Subsidiary],
			dbo.FNAEmissionHyperlink(3,12101510, generator_name,generator_id,''''''s'''''') as [Source/Sink],
			dbo.FNADateFormat(term_start) as [Term],
			type [Series Type],
			ROUND(SUM(inventory),' +@round_value + ') as  [Value],
			emission_type [Emissions Type],
			[UOM] as [UOM],
			'''+@input_str+''' as [Input Characteristics],
			max(CASE WHEN formula_format=''nested formula'' then ''Nested Formula'' else formula_format+'' <br> '' end +
			ISNULL(formula,'''')) as Formula,
			MAX(sd.code) as [Fuel Type]
		from
			#temp 
			LEFT JOIN static_data_value sd on sd.value_id=fuel_type_value_id
		where 1=1 '+
			
		   + CASE WHEN	@drill_curve is not null then ' and curve_name='''+@drill_curve+'''' else '' end+
		   + CASE WHEN	@drill_forecast_type is not null then ' AND type ='''+@drill_forecast_type+'''' else '' end+
		'	
			group by 
			dbo.FNAEmissionHyperlink(3,12101510, generator_name,generator_id,''''''s''''''),
			opco,generator_name ,
			dbo.FNADateFormat(term_start),
			type,emission_type,[UOM],formula
			
	'
	--print @sql
	exec(@sql)
	----------------------------------------------------
END

END

else if @flag ='f'
BEGIN

set @sql='
	select 
		distinct 
		dbo.FNACONTRACTMONTHFORMAT(cfv.prod_date) [Term Start],
		fn.sequence_order [Row Number],
		description1 [Description1],
		description2 [Description2],
		dbo.fnaformulaformat(fe.formula,''r'')+''<br>''+cfv.formula_str [Formula],
		((1-ISNULL(ownership_per,0))*(cfv.value))/CASE WHEN esm.input_frequency=706 then 1 else 1 end [Value],
		sd2.code [Fuel Type]
	 from 
		calc_formula_value cfv 	 
		INNER JOIN formula_nested fn  on fn.formula_group_id=cfv.formula_id and fn.sequence_order=cfv.seq_number
		LEFT JOIN formula_editor fe on fe.formula_id=fn.formula_Id
		INNER JOIN ems_calc_detail_value ei on isnull(ei.formula_id,ei.formula_id_reduction)=cfv.formula_id 
				   and dbo.fnagetcontractmonth(ei.term_start)=dbo.fnagetcontractmonth(cfv.prod_date) and ei.generator_id=cfv.generator_id
		INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id=ei.curve_id
		LEFT JOIN source_uom su on su.source_uom_id=ei.uom_id
		INNER JOIN rec_generator rg on rg.generator_id=ei.generator_id
		LEFT JOIN static_data_value reporttype on 	reporttype.value_id=ei.forecast_type
		LEFT JOIN (select generator_id,SUM(per_ownership) ownership_per from generator_ownership group by generator_id) ownership
		on ei.generator_id=ownership.generator_id
		LEFT JOIN static_data_value sd2 on sd2.value_id=fe.static_value_id
		LEFT JOIN portfolio_hierarchy ph on ph.entity_id=rg.legal_entity_value_id
		LEFT JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
				AND ei.term_start between isnull(esme.effective_date,''1900-01-01'') AND isnull(esme.end_date,''9999-01-01'')
		LEFT JOIN 
			ems_source_model esm on esm.ems_source_model_id=esme.ems_source_model_id
		
	where 1=1 and cfv.formula_str is not null'

	   + CASE WHEN  @generator_id is not null then ' and ei.generator_id='+ @generator_id else '' end
	   + CASE WHEN	@drill_curve is not null then ' and curve_name='''+@drill_curve+'''' else '' end
	   + CASE WHEN	@drill_term is not null then ' and ei.term_start=  CASE WHEN esm.input_frequency=706 then cast(cast(year('''+@drill_term+''') as varchar)+''-01-01'' as datetime) else '''+@drill_term+''' end ' else '' end
	   + CASE WHEN  @drill_generator_name is not null then ' and rg.name='''+@drill_generator_name+'''' else '' end+
	   + CASE WHEN  @as_of_date is not null then ' And ei.as_of_date='''+cast(@as_of_date as varchar)+'''' else '' end +
	   + CASE WHEN  @drill_forecast_type  is not null then 
				 ' AND ISNULL(reporttype.code,''Default Inventory'') ='''+@drill_forecast_type+'''' 
				
			else '' end
	   + CASE WHEN ISNULL(@drill_sub, '') <> '' then ' And ph.entity_name='''+@drill_sub+'''' else '' end

	exec spa_print @sql
	EXEC(@sql)
	END

--*****************FOR BATCH PROCESSING**********************************            
 

	IF  @batch_process_id is not null        
	BEGIN        
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
	 EXEC(@str_batch_table)        
	 declare @report_name varchar(100)        

	 set @report_name='Export Emissions Inventory Data'        
	        
	 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_get_emissions_inventory',@report_name)         
	 EXEC(@str_batch_table)        
	   
	END        
--********************************************************************   



END
































