
/****** Object:  StoredProcedure [dbo].[spa_emissions_tracking_report]    Script Date: 02/19/2009 17:54:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_emissions_tracking_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_emissions_tracking_report]

GO

/******************************************************
Created By: Anal Shrestha
Created On: 15/02/2008
Description: This SP is used to run the tracking report for all the emissions inventory, reductions.. etc.


******************************************************/

CREATE PROC [dbo].[spa_emissions_tracking_report]
		@as_of_date varchar(20),            
		@sub_entity_id varchar(100)=null,
		@strategy_entity_id varchar(100),
		@reporting_year INT,
		@report_section varchar(20), --use Schedule.Section.Part.Item format. For example., "I.2.A" for aggregated report
		@process_id varchar(50),
		@report_type varchar(1) = 'r', -- 'b' only show base period, 'r' only show reporting period, 'a' show both base and reporting
		@prod_month_from DATETIME = null,  --null
		@prod_month_to DATETIME  = null,  --null,
		@base_year_from int=null,
		@base_year_to int=null,
		@table_name varchar(100)=null,		
		@book_entity_id varchar(100)=null,	
		@forecast char(1)='r', 
		@curve_id INT =NULL,--gas
		@generator_group_id VARCHAR(50)=NULL, 
		@generator_id INT = NULL, 
		@source_sink_type varchar(200) = NULL, 
		@reduction_type int = NULL, 
		@reduction_sub_type int = NULL,
		@uom_id int=NULL,
		@technology_type int=null,	
		@technology_sub_type int=null,
		@primary_fuel int=null,
		@fuel_type int=null,
		@udf_source_sink_group int=null,
		@udf_group1 int=null,
		@udf_group2 int=null,
		@udf_group3 int=null,
		@include_hypothetical char(1)=null,
		@convert_heatinput_uom_id int=null,
		@show_co2e char(1)=null,
		@input_id int=null,
		@input_uom_id int=null,
		@program_scope varchar(100)=null,
		@limit_term_start datetime=null,
		@limit_term_end datetime=null,
		@not_include_reduction_benchmark char(1)='y',
		@baseline_reduction CHAR(1)='y', -- Show baseline reductions
		@project_reduction CHAR(1)='y',-- Show project based reductions
		@credit_offsets CHAR(1)='y', -- Show Credit offsets reductions
		@input_uom INT=NULL,
		@output_uom INT=NULL,
		-- drill down
		@drill_down_level int=null,
		@report_year_level int=NULL,--1 year1, 2 year2, 3 year3,4 year4 5 base year 6 reporting year
		@source varchar(100)=NULL,
		@group1 varchar(100)=NULL,
		@group2 varchar(100)=NULL,
		@group3 varchar(100)=NULL,
		@gas varchar(100)=NULL,
		@generator varchar(100)=NULL,
		@year int=null,
		@term_start datetime=NULL,
		@emissions_reductions char(1)=null,
		@deminimis char(1)='n',
		@use_process_id varchar(50)='RERUN',
		@form_type char(1)=null,
		@call_from_calc char(1)='n'
				

AS
SET NOCOUNT ON 
Begin
---------------------------
-----------UNCOMMENT BELOW FOR TESTING

-- DECLARE @as_of_date varchar(20)            
-- DECLARE  @sub_entity_id int
-- DECLARE  @strategy_entity_id int
-- DECLARE  @reporting_year INT
-- DECLARE  @prod_month_from DATETIME  --null
-- DECLARE  @prod_month_to DATETIME    --null
-- DECLARE  @report_type varchar(1) -- 'b' only show base period, 'r' only show reporting period, 'a' show both base and reporting
-- 
-- 
-- SET @as_of_date = '2006-12-31'
-- SET @sub_entity_id = 136
-- SET @strategy_entity_id = NULL
-- SET @reporting_year = 2006
-- SET @report_type = 'a'
-- drop table #ssbm 
-- drop table #temp 
-- drop table #temp2 
-- drop table #temp    
-- drop table #temp2    
-----------UNCOMMENT ABOVE FOR TESTING
---------------------------

--**************************************************
--EXEC spa_print 'start :'+convert(varchar(100),getdate(),113)
--**************************************************

	DECLARE @Sql_Select varchar(8000)
	DECLARE @Sql_Where varchar(8000)
	DECLARE  @co2e_curve_id INT
	DECLARE  @reporting_group_id int
	DECLARE @SQL VARCHAR(8000)
	DECLARE @base_yr1 int
	DECLARE @base_yr2 int
	DECLARE @base_yr3 int
	DECLARE @base_yr4 int
	DECLARE @base_yr_count int
	DECLARE @base_yr_from varchar(20)
	DECLARE @base_yr_to varchar(20)
	DECLARE @new_process_id varchar(100)
	DECLARE @sql_stmt varchar(8000)
	DECLARE @sql_stmt1 varchar(8000)
	DECLARE @input_count_duplicate int
	DECLARE @EQ_deal_type_id VARCHAR(50)
	DECLARE @tab_space varchar(50)
	DECLARE @process_id1 varchar(100)
	DECLARE @table_RECS varchar(128)
	DECLARE @reporting_year1 int
	DECLARE @max_base_year int
--*************************************************
--SET variables
--*************************************************

	SET @as_of_date = cast(year(@as_of_date) as varchar) + '-12-31' --Always make as of date as last day of the year
	SET @input_count_duplicate = 12
	SET @base_yr1 = null
	SET @base_yr2 = null
	SET @base_yr3 = null
	SET @base_yr4 = null
	SET @reporting_group_id = 5244 
	SET @base_yr_from=@base_year_from
	SET @base_yr_to=@base_year_to
	SET @tab_space = ''
	SET @sql_Where = ''    
	SET @EQ_deal_type_id='59,510,511'
	SET @co2e_curve_id=1

	IF @process_id is null
		SET @new_process_id=REPLACE(newid(),'-','_')
	ELSE
		SET @new_process_id=@process_id

	--Uday harcoding/changes
	IF isnull(@use_process_id, 'RERUN') NOT IN ('NEW', 'RERUN')
		SET @new_process_id  = @use_process_id

	IF @table_name is null
		SET @table_name='adiha_process.dbo.Emissions_Inventory_'+@new_process_id
		

	   
	IF @prod_month_from IS NOT NULL OR @prod_month_to IS NOT NULL
	begin
		IF @prod_month_from IS NOT NULL AND @prod_month_to IS NULL
			SET @prod_month_to = @prod_month_from
		IF @prod_month_from IS NULL AND @prod_month_to IS NOT NULL
			SET @prod_month_from = @prod_month_to
	end


	CREATE TABLE #reporting_group(reporting_group_id int)

	SET @Sql_Select='INSERT INTO #reporting_group select  max(emission_group_id) from ems_portfolio_hierarchy
			where  entity_id in('+@source_sink_type+')'
	
	exec(@Sql_Select)
		
	select @reporting_group_id=reporting_group_id from #reporting_group

---************ Find the Reporting group_id for different protocol
		

--********************************************
-- Find the base Period
--********************************************
	CREATE TABLE #fas_id(fas_id int)

	SET @Sql_Select=
			'
			insert into #fas_id(fas_id)
			select fas_subsidiary_id from
				fas_subsidiaries WHERE fas_subsidiary_id in('+@sub_entity_id+')'

	EXEC(@Sql_Select)

	


	IF @base_year_from is null
		BEGIN
			IF @sub_entity_id is not null and (select count(*) FROM #fas_id)=1
				SELECT 	@base_yr_from = base_year_from, @base_yr_to = 
					isnull(base_year_to, base_year_from) FROM fas_subsidiaries WHERE fas_subsidiary_id in(SELECT fas_id FROM #fas_id)
			ELSE
				SELECT 	@base_yr_from = base_year_from, @base_yr_to = 
					isnull(base_year_to, base_year_from) FROM fas_subsidiaries WHERE fas_subsidiary_id=-1

			END
	ELSE
		BEGIN
			SET @base_yr_from=@base_year_from
			SET @base_yr_to=@base_year_to
		END



	SET @base_yr1 = @base_yr_from
	SET @base_yr_count = case when (@base_yr1 is not null) then 1 else null end

	IF (@base_yr1+1) <= @base_yr_to
		BEGIN
			SET @base_yr2 = @base_yr1+1
			SET @base_yr_count = @base_yr_count + 1
		END 
	IF (@base_yr1+2) <= @base_yr_to
			BEGIN
				SET @base_yr3 = @base_yr1+2
				SET @base_yr_count = @base_yr_count + 1
			END
	IF (@base_yr1+3) <= @base_yr_to
		BEGIN
			SET @base_yr4 = @base_yr1+3
			SET @base_yr_count = @base_yr_count + 1
		END



--*********************************
--Create temporary tables to select subsidiary,strategy and books
--*********************************
        
	CREATE TABLE #ssbm
		(                      
		 fas_book_id int,            
		 stra_book_id int,            
		 sub_entity_id int,
		 book_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
		 stra_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
		 sub_name VARCHAR(50) COLLATE DATABASE_DEFAULT            
		)            

	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  

	----------------------------------            
	SET @Sql_Select=            
		'INSERT INTO #ssbm            
		SELECT                      
		  book.entity_id AS fas_book_id,
		  book.parent_entity_id AS stra_book_id, 
		  stra.parent_entity_id AS sub_entity_id ,
		  book.entity_name AS book_name,	            
		  stra.entity_name AS stra_name,	            
		  sub.entity_name AS sub_name	            
		FROM            
		 portfolio_hierarchy book (nolock)             
		INNER JOIN            
		 Portfolio_hierarchy stra (nolock)            
		 ON            
		  book.parent_entity_id = stra.entity_id             
		INNER JOIN            
		 Portfolio_hierarchy sub (nolock)            
		 ON            
		  stra.parent_entity_id = sub.entity_id    		            

		WHERE 1=1 '            
	
		IF @sub_entity_id IS NOT NULL            
			SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR) + ') '             
		IF @strategy_entity_id IS NOT NULL            
			SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR) + ' ))'            
		IF @book_entity_id IS NOT NULL            
			SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_entity_id + ')) '            
		
		SET @Sql_Select=@Sql_Select+@Sql_Where            

	--Uday hardcoding/changes
	IF isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
		EXEC (@Sql_Select)            
	--------------------------------------------------------------    



--	IF @process_id is null
--	BEGIN
	---###########First Bring REC DEALS



	SET @process_id1 = REPLACE(newid(),'-','_')
		select @table_RECS=dbo.FNAProcessTableName('Emissions_REC',dbo.FNADBUser(),@process_id1)

	IF @reporting_year is not null
		SET @reporting_year1=@reporting_year

	IF @as_of_date is null and @reporting_year is not null
		SET @as_of_date='12/31/'+cast(@reporting_year as varchar)

		
	IF @prod_month_from is not null 
		SET @max_base_year=COALESCE(@base_yr4,@base_yr3,@base_yr2,@base_yr1)

	--Uday hardcoding/changes
--	IF isnull(@use_process_id, 'RERUN') IN ('NEW', 'RERUN')
--		EXEC spa_get_co2_avoided_recs @sub_entity_id, @as_of_date, @reporting_year1,@max_base_year,@convert_CO2_uom_id,@table_RECS


---************************************************
--EXEC spa_print 'Start Inventory Report 1 :'+convert(varchar(100),getdate(),113)
---************************************************

		CREATE TABLE[dbo].[#temp_inventory] (
			[as_of_date] [datetime] NOT NULL ,
			[Group1_ID] [int] NULL ,
			[Group2_ID] [int] NULL ,
			[Group3_ID] [int] NULL ,
			[Group1] [varchar] (300)  NULL ,
			[Group2] [varchar] (200)  NOT NULL ,
			[Group3] [varchar] (200)  NOT NULL ,
			[generator_id] [int] NOT NULL ,
			[name] [varchar] (250)  NOT NULL ,
			[frequency] [int] NOT NULL ,
			[curve_id] [int] NOT NULL ,
			[curve_name] [varchar] (100)  NOT NULL ,
			[curve_des] [varchar] (250)  NULL ,
			[volume] [float] NULL ,
			[uom_id] [int]  NULL ,
			[uom_name] [varchar] (100)  NULL ,
			[reporting_year] [int] NULL ,
			[fuel_value_id] [int] NULL ,
			[sub] [varchar] (200)  NOT NULL ,
			[captured_co2_emission] [char] (10)  NULL ,
			[technology] [varchar] (100)   NULL ,
			[technology_sub_type] [varchar] (50)  NULL ,
			[first_gen_date] [datetime] NULL ,
			[term_start] [datetime] NULL ,
			[term_end] [datetime] NULL ,
			[output_id] [int] NULL ,
			[output_value] [float] NULL ,
			[output_uom] varchar(20) NULL ,
			[heatcontent_value] [float] NULL ,
			[heatcontent_uom_id] [int] NULL ,
			[current_forecast] [char] (1)  NULL ,
			[reduction_volume] [float] NULL ,
			[de_minimis_source] [varchar] (100)  NULL ,
			[co2_captured_for_generator_id] [int] NULL,
			series_type int NULL ,
			series_type_value varchar(100),
			fuel_type_value_id int,
			source_model_id	int,
			default_inventory int,
			seq_order int,
			forecast_type int,
			OpCo varchar(100),
			State varchar(20),
			generator_name varchar(100)	,
			heatinput_uom varchar(30),
			input_value float,
			input_uom varchar(100),
			Fuel_type VARCHAR(50)

		)

		CREATE  INDEX [IX_INV1] ON [#temp_inventory](generator_id)                  
		CREATE  INDEX [IX_INV2] ON [#temp_inventory](curve_id)                  
		CREATE  INDEX [IX_INV3] ON [#temp_inventory](term_start)       


		select generator_id,sum(per_ownership) ownership_per  into #ownership
		from generator_ownership group by generator_id


		IF @limit_term_start is not null
			BEGIN	
				SET @base_yr_from=cast(@limit_term_start as varchar)
				SET @base_yr_to=cast(@limit_term_end as varchar)
			END
		ELSE
			BEGIN
				SET @base_yr_from=cast(@base_yr_from as varchar)+'-01-01'
				SET @base_yr_to=cast(@base_yr_to as varchar)+'-12-31'
			END



	IF @input_id IS NOT NULL -- For input reports select inputs only
		BEGIN
			
			SET @sql_select='
			insert into #temp_inventory
			SELECT
				vi.as_of_date,
				vi.Group1_ID,
				vi.Group2_ID,
				vi.Group3_ID,
				vi.Group1,
				vi.Group2, 
				vi.Group3,
				vi.generator_id,
				vi.[name] as generator_name, 
				vi.frequency,'+
				CASE WHEN @curve_id=@Co2e_curve_id THEN CAST(@Co2e_curve_id AS VARCHAR) ELSE ' vi.curve_id' END +', 
				vi.curve_name, 
				vi.curve_des,
				0 as Volume,
				NULL AS to_source_uom_id, 
				NULL AS uom_name , 
				vi.reporting_year,
				vi.fuel_value_id,
				vi.sub,
				vi.captured_co2_emission,
				vi.technology,
				vi.technology_sub_type,
				vi.reduc_start_date,
				vi.term_start,
				vi.term_end,
				vi.output_id,
				0 AS output_value,
				NULL AS uom_name,
				0 AS heatcontentValue,
				NULL AS heatinput_uom_id,
				vi.current_forecast,
				0 as ReductionVolume,
				vi.de_minimis_source,
				vi.co2_captured_for_generator_id,
				vi.series_type,
				vi.code,
				vi.fuel_type_value_id,
				vi.ems_source_model_id,
				vi.default_inventory,
				vi.sequence_order,
				isnull(vi.forecast_type,0),
				vi.OpCo,
				vi.State,
				vi.generator_name,
				NULL AS uom_name,
				egi.input_value*ISNULL(conv0.conversion_factor,1) AS input_value,
				su_inv.uom_name AS input_uom,
				vi.fueltype [FuelType]

			from view_inventory vi

				 INNER JOIN #ssbm ON #ssbm.fas_book_id = vi.fas_book_id
				  and vi.emission_group_id='+cast(@reporting_group_id as varchar)+
				 'and ((term_start between '''+cast(@prod_month_from as varchar)+''' and  '''+cast(@prod_month_to as varchar)+''') OR ((term_start) between '''+cast(@base_yr_from as varchar)+''' and '''+cast(@base_yr_to as varchar)+'''))
				 JOIN ems_gen_input egi ON egi.generator_id=vi.generator_id
										   AND egi.term_start=vi.term_start
				 --JOIN ems_input_map eim on eim.input_id=vi.ems_source_model_id
				 JOIN ems_source_input esi on	esi.ems_source_input_id=egi.ems_input_id

				 left join rec_volume_unit_conversion conv0 on
				 conv0.from_source_uom_id  = esi.uom_id
				 AND conv0.to_source_uom_id ='+case when @input_uom is not null then cast(@input_uom as varchar) else ' esi.uom_id ' end+'
				 And conv0.state_value_id is null
				 AND conv0.assignment_type_value_id is null
				 AND conv0.curve_id is null 

				 left join source_uom su_inv on su_inv.source_uom_id=ISNULL(conv0.to_source_uom_id,esi.uom_id)	

				 left join ems_edr_include_inv edr_inc on edr_inc.generator_id=vi.generator_id and
				 edr_inc.curve_id=vi.curve_id and vi.term_start between edr_inc.term_start and edr_inc.term_end
				 '+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' join user_defined_group_detail udfg on udfg.rec_generator_id=vi.generator_id 
				  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

			where 	1=1 '+
				
				' and (edr_inc.generator_id is null or(edr_inc.generator_id is not null and (edr_inc.series_type=vi.series_type)))'
				+case when @program_scope is not null then ' and vi.ems_source_model_detail_id in(select ems_source_model_detail_id FROM ems_source_model_program
					where program_scope_value_id in('+@program_scope+'))' else '' end+
				' and vi.emission_group_id='+cast(@reporting_group_id as varchar)+
				' and ((vi.term_start between '''+cast(@prod_month_from as varchar)+''' and  '''+cast(@prod_month_to as varchar)+''') OR
				((vi.term_start) between '''+@base_yr_from+''' and '''+@base_yr_to+'''))'		
				+case when @generator_id is not null then ' And vi.generator_id='+cast(@generator_id as varchar) else '' end
				+case when @generator_group_id is not null and @generator_group_id<>'null' then ' and isnull(vi.generator_group_name, '''') = ''' + @generator_group_id + '''' else '' end
				+case when @source_sink_type  is not null then 
						' and (isnull(vi.Group1_id, 1) in(' +@source_sink_type+') OR isnull(vi.Group2_id,1) in('+@source_sink_type+
						') OR isnull(vi.Group3_id,1) in('+@source_sink_type+'))' 	 else '' end
				+CASE WHEN @reduction_type IS NOT NULL THEN 	' and isnull(vi.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
				+CASE WHEN @reduction_sub_type IS NOT NULL THEN ' and isnull(vi.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
				+CASE WHEN @technology_type IS NOT NULL THEN ' and isnull(vi.technology, 1) = ' + cast(@technology_type as varchar)	ELSE '' END +
				+CASE WHEN @technology_sub_type IS NOT NULL THEN ' and isnull(vi.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
				+CASE WHEN @primary_fuel IS NOT NULL THEN ' and isnull(vi.fuel_value_id, 1) = ' + cast(@primary_fuel as varchar)	ELSE '' END +
				+CASE WHEN @fuel_type IS NOT NULL THEN ' and isnull(vi.fuel_type_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
				+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
				+CASE WHEN @udf_group1 IS NOT NULL THEN ' and isnull(vi.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
				+CASE WHEN @udf_group2 IS NOT NULL THEN ' and isnull(vi.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
				+CASE WHEN @udf_group3 IS NOT NULL THEN ' and isnull(vi.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END +
				+CASE WHEN @include_hypothetical IS NOT NULL THEN ' and isnull(vi.is_hypothetical,''n'') = ''' +@include_hypothetical+'''' ELSE '' END 
				+CASE WHEN @project_reduction ='n' THEN ' AND ISNULL(vi.reduction_type,-1)=-1' ELSE '' END
				+CASE WHEN @input_id IS NOT NULL THEN ' AND egi.ems_input_id='+CAST(@input_id AS VARCHAR) ELSE '' END

			--print @Sql_Select
			EXEC(@Sql_Select)		
		END


	ELSE	
		BEGIN
			SET @sql_select=
				'
				insert into #temp_inventory
				SELECT
					vi.as_of_date,
					vi.Group1_ID,
					vi.Group2_ID,
					vi.Group3_ID,
					vi.Group1,
					vi.Group2, 
					vi.Group3,
					vi.generator_id,
					vi.[name] as generator_name, 
					vi.frequency,' +
					CASE WHEN @curve_id=@Co2e_curve_id THEN CAST(@Co2e_curve_id AS VARCHAR) ELSE ' vi.curve_id' END +', 
					vi.curve_name, 
					vi.curve_des,
					vi.volume * ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1),
					conv0.to_source_uom_id, 
					ISNULL(Conv1.curve_label,vi.curve_name)+'' ''+ su_inv.uom_name , 
					vi.reporting_year,
					vi.fuel_value_id,
					vi.sub,
					vi.captured_co2_emission,
					vi.technology,
					vi.technology_sub_type,
					vi.reduc_start_date,
					vi.term_start,
					vi.term_end,
					vi.output_id,
					vi.output_value*isnull(conv3.conversion_factor,1),
					su_output.uom_name,
					vi.heatcontent_value*ISNULL(conv2.conversion_factor,1),
					conv2.to_source_uom_id heatinput_uom_id,
					vi.current_forecast,
					
						case 
							 when '''+@baseline_reduction+'''=''y'' AND '''+@project_reduction+'''=''y''  then vi.reduction_volume
							 when '''+@baseline_reduction+'''=''y'' AND '''+@project_reduction+'''=''n''  then vi.reduction_volume
							 when '''+@baseline_reduction+'''=''n'' AND '''+@project_reduction+'''=''y''  then 
											CASE WHEN ISNULL(vi.reduction_type,-1)<>-1 then vi.reduction_volume else 0 end
						 else 0 end *  ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1) 
					  
					,vi.de_minimis_source,
					vi.co2_captured_for_generator_id,
					vi.series_type,
					vi.code,
					vi.fuel_type_value_id,
					vi.ems_source_model_id,
					vi.default_inventory,
					vi.sequence_order,
					isnull(vi.forecast_type,0),
					vi.OpCo,
					vi.State,
					vi.generator_name,
					su_hi.uom_name,
					NULL AS input_value,
					NULL AS input_uom,
					vi.fueltype [FuelType]
					
				from view_inventory vi
					 INNER JOIN #ssbm ON #ssbm.fas_book_id = vi.fas_book_id
					  and vi.emission_group_id='+cast(@reporting_group_id as varchar)+
					 'and ((term_start between '''+cast(@prod_month_from as varchar)+''' and  '''+cast(@prod_month_to as varchar)+''') OR ((term_start) between '''+cast(@base_yr_from as varchar)+''' and '''+cast(@base_yr_to as varchar)+'''))'+
					 '

					 left join rec_volume_unit_conversion conv0 on
					 conv0.from_source_uom_id  = vi.uom_id
					 AND conv0.to_source_uom_id =ISNULL('+case when @uom_id is not null then cast(@uom_id as varchar) else 'NULL' END +',vi.uom_id)
					 And conv0.state_value_id is null
					 AND conv0.assignment_type_value_id is null
					 AND conv0.curve_id is null 	

					 left join rec_volume_unit_conversion conv1 on
					 conv1.from_source_uom_id  = vi.uom_id
					 AND conv1.to_source_uom_id =vi.uom_id
					 And conv1.state_value_id is null
					 AND conv1.assignment_type_value_id is null
					 AND conv1.curve_id=vi.curve_id
					 AND conv1.to_curve_id='+CAST(@curve_id AS VARCHAR)+'	

					 left join rec_volume_unit_conversion conv2 on
					 conv2.from_source_uom_id  = vi.heatcontent_uom_id
					 AND conv2.to_source_uom_id ='+case when @convert_heatinput_uom_id is not null then cast(@convert_heatinput_uom_id as varchar) else ' vi.heatcontent_uom_id ' end+'
					 And conv2.state_value_id is null
					 AND conv2.assignment_type_value_id is null
					 AND conv2.curve_id is null 

					 left join rec_volume_unit_conversion conv3 on
					 conv3.from_source_uom_id  = vi.output_uom_id
					 AND conv3.to_source_uom_id ='+case when @output_uom is not null then cast(@output_uom as varchar) else ' vi.output_uom_id ' end+'
					 And conv3.state_value_id is null
					 AND conv3.assignment_type_value_id is null
					 AND conv3.curve_id is null 

					 left join source_uom su_inv on su_inv.source_uom_id=conv0.to_source_uom_id	
					 left join source_uom su_output on su_output.source_uom_id=conv3.to_source_uom_id	
					 left join source_uom su_hi on su_hi.source_uom_id=conv2.to_source_uom_id	

					 left join ems_edr_include_inv edr_inc on edr_inc.generator_id=vi.generator_id and
					 edr_inc.curve_id=vi.curve_id and vi.term_start between edr_inc.term_start and edr_inc.term_end
					 '+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' join user_defined_group_detail udfg on udfg.rec_generator_id=vi.generator_id 
					  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

				where 	1=1 '+
					
					' and (edr_inc.generator_id is null or(edr_inc.generator_id is not null and (edr_inc.series_type=vi.series_type)))'
					+case when @program_scope is not null then ' and vi.ems_source_model_detail_id in(select ems_source_model_detail_id FROM ems_source_model_program
						where program_scope_value_id in('+@program_scope+'))' else '' end+
					' and vi.emission_group_id='+cast(@reporting_group_id as varchar)+
					' and ((vi.term_start between '''+cast(@prod_month_from as varchar)+''' and  '''+cast(@prod_month_to as varchar)+''') OR
					((vi.term_start) between '''+@base_yr_from+''' and '''+@base_yr_to+'''))'		
					+case when @generator_id is not null then ' And vi.generator_id='+cast(@generator_id as varchar) else '' end
					+case when @generator_group_id is not null and @generator_group_id<>'null' then ' and isnull(vi.generator_group_name, '''') = ''' + @generator_group_id + '''' else '' end
					+case when @source_sink_type  is not null then 
							' and (isnull(vi.Group1_id, 1) in(' +@source_sink_type+') OR isnull(vi.Group2_id,1) in('+@source_sink_type+
							') OR isnull(vi.Group3_id,1) in('+@source_sink_type+'))' 	 else '' end
					+CASE WHEN @reduction_type IS NOT NULL THEN 	' and isnull(vi.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
					+CASE WHEN @reduction_sub_type IS NOT NULL THEN ' and isnull(vi.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
					+CASE WHEN @technology_type IS NOT NULL THEN ' and isnull(vi.technology, 1) = ' + cast(@technology_type as varchar)	ELSE '' END +
					+CASE WHEN @technology_sub_type IS NOT NULL THEN ' and isnull(vi.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
					+CASE WHEN @primary_fuel IS NOT NULL THEN ' and isnull(vi.fuel_value_id, 1) = ' + cast(@primary_fuel as varchar)	ELSE '' END +
					+CASE WHEN @fuel_type IS NOT NULL THEN ' and isnull(vi.fuel_type_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
					+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
					+CASE WHEN @udf_group1 IS NOT NULL THEN ' and isnull(vi.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
					+CASE WHEN @udf_group2 IS NOT NULL THEN ' and isnull(vi.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
					+CASE WHEN @udf_group3 IS NOT NULL THEN ' and isnull(vi.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END +
					+CASE WHEN @include_hypothetical IS NOT NULL THEN ' and isnull(vi.is_hypothetical,''n'') = ''' +@include_hypothetical+'''' ELSE '' END 
					+CASE WHEN @project_reduction ='n' THEN ' AND ISNULL(vi.reduction_type,-1)=-1' ELSE '' END

				if @curve_id is not null and @curve_id<>@Co2e_curve_id
					set @sql_select=@sql_select+' And vi.curve_id='+cast(@curve_id as varchar) 

			--print @Sql_Select
			EXEC(@Sql_Select)

		--EXEC spa_print '2 Inserted in First Temp Table :'+convert(varchar(100),getdate(),113)


--select * from #temp_inventory
---********************************************************
-- Now bring CO2Eq, So2, NOx deals FROM source_deal_header
--*********************************************************


		SET @Sql_Select=
				'		
				INSERT INTO #temp_inventory
				SELECT  
					sdh.deal_date as_of_date,
					sub.entity_id Group1_ID,
					stra.entity_id Group2_ID,
					book.entity_id Group3_ID,
					sub.entity_name Group1,
					stra.entity_name Group2, 
					book.entity_name Group3, 
					rg.generator_id generator_id, 
					rg.[name] generator_name, 
					CASE WHEN sdh.deal_volume_frequency=''m'' THEN 703
						 WHEN sdh.deal_volume_frequency=''q'' THEN 704
						 ELSE 706
					END	AS frequency, '+
					CASE WHEN @curve_id=@Co2e_curve_id THEN CAST(@Co2e_curve_id AS VARCHAR) ELSE ' sdh.curve_id' END +', 
					spcd.curve_name AS curve_name, 
					spcd.curve_des AS curve_des,
					CASE WHEN buy_sell_flag=''s'' THEN sdh.deal_volume*ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1) ELSE 0 END AS volume,
					conv0.to_source_uom_id AS uom_id,
					 ISNULL(conv1.curve_label,spcd.curve_name)+'' ''+su.uom_name AS uom_name, 
					YEAR(sdh.term_start) AS reporting_year,
					NULL AS fuel_value_id,
					sub.entity_name AS sub,
					rg.captured_co2_emission AS captured_co2_emission,
					rg.technology As technology,
					rg.classification_value_id AS technology_sub_type,
					rg.reduc_start_date AS reduc_start_date,
					sdh.term_start AS term_start,
					sdh.term_end AS term_end,
					NULL AS output_id,
					NULL AS ouput_value,
					NULL AS output_uom_name,
					NULL AS heatcontent_value,
					NULL AS heatinput_uom_id,
					CASE WHEN fas_deal_type_value_id=405 THEN ''t'' else ''r'' end as current_forecast,
					CASE WHEN buy_sell_flag=''b'' THEN sdh.deal_volume*ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1)
						 ELSE 0 END AS volume,  
					rg.de_minimis_source,
					NULL AS co2_captured_for_generator_id,
					CASE WHEN fas_deal_type_value_id=405 THEN NULL else esf.forecast_type end AS Series_type,
					CASE WHEN fas_deal_type_value_id=405 THEN NULL else series.code end AS series_code,
					CASE WHEN fas_deal_type_value_id=405 THEN NULL else rg.fuel_value_id end ,
					esmd.ems_source_model_id,
					CASE WHEN fas_deal_type_value_id=405 THEN NULL when esf.default_inventory=''y'' then -1 else NULL end as default_inventory,
					CASE WHEN fas_deal_type_value_id=405 THEN NULL else esf.sequence_order end AS sequence_order,
					0 AS forecast_type,
					#ssbm.sub_name AS OpCo,
					state.Code AS state,
					rg.[name],
					NULL as uom_name1,
					NULL AS input_value,
					NULL AS uom_name2,
					NULL AS FuelType			

				from(		
					select 
						 max(sdh.source_deal_header_id) source_deal_header_id,      
						 max(sdd.source_deal_detail_id) source_deal_detail_id,      
						 (sdd.buy_sell_flag) buy_sell_flag,             
						 max(sdh.counterparty_id) counterparty_id,            
						 max(sdh.source_deal_type_id) source_deal_type_id,
						 max(sdh.deal_sub_type_type_id) deal_sub_type_type_id,            
						 max(sdh.deal_date) deal_date,             
						 max(sdh.generator_id) generator_id,
						 sdd.curve_id,
						 sum(sdd.volume_left) as deal_volume,
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
						sdd.curve_id, sdd.term_start,sdh.generator_id,sdd.buy_sell_flag,ssbm.fas_deal_type_value_id

				) sdh
				INNER JOIN rec_generator rg (nolock)
					ON rg.generator_id=sdh.generator_id
				LEFT OUTER JOIN source_sink_type sst  
					ON 	sst.generator_id=rg.generator_id		
				LEFT OUTER JOIN ems_portfolio_hierarchy book              
					ON sst.source_sink_type_id=book.entity_id
				LEFT OUTER JOIN ems_portfolio_hierarchy stra              
					ON book.parent_entity_id = stra.entity_id             
				LEFT OUTER JOIN ems_portfolio_hierarchy sub             
					ON stra.parent_entity_id = sub.entity_id    
				INNER JOIN #ssbm (nolock)
					ON #ssbm.fas_book_id = rg.fas_book_id      
				LEFT OUTER JOIN source_price_curve_def spcd on spcd.source_curve_def_id = sdh.curve_id
				INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
				INNER JOIN (select max(isnull(effective_date,''1900-01-01'')) effective_date,generator_id FROM 
								ems_source_model_effective WHERE 1=1 group by generator_id) ab
				on esme.generator_id=ab.generator_id and isnull(esme.effective_date,''1900-01-01'')=ab.effective_date
				INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id = esme.ems_source_model_id and
				esmd.curve_id = sdh.curve_id
				LEFT OUTER JOIN ems_source_formula esf 
					 ON esf.ems_source_model_id=esmd.ems_source_model_id AND esf.curve_id=sdh.curve_id AND esf.default_inventory=''y''
				LEFT OUTER JOIN static_data_value series 
					 ON series.value_id=esf.forecast_type
				LEFT OUTER JOIN dbo.series_type st 
					 ON st.series_type_value_id=esf.forecast_type and st.forecast_type=''f''			
				LEFT OUTER JOIN static_data_value rating on rating.value_id = esmd.rating_value_id
				LEFT OUTER JOIN static_data_value em on em.value_id = esmd.estimation_type_value_id
				LEFT OUTER JOIN static_data_value technology on technology.value_id=rg.technology
				LEFT OUTER JOIN static_data_value classification on classification.value_id=rg.classification_value_id
				LEFT OUTER JOIN static_data_value state on state.value_id=rg.gen_state_value_id


				LEFT OUTER JOIN rec_volume_unit_conversion conv0 on
					 conv0.from_source_uom_id  = sdh.deal_volume_uom_id
					 AND conv0.to_source_uom_id =ISNULL('+case when @uom_id is not null then cast(@uom_id as varchar) else 'NULL' END +',sdh.deal_volume_uom_id)
					 And conv0.state_value_id is null
					 AND conv0.assignment_type_value_id is null
					 AND conv0.curve_id is null 	

				LEFT OUTER JOIN rec_volume_unit_conversion conv1 on
					 conv1.from_source_uom_id  = sdh.deal_volume_uom_id
					 AND conv1.to_source_uom_id =sdh.deal_volume_uom_id
					 And conv1.state_value_id is null
					 AND conv1.assignment_type_value_id is null
					 AND conv1.curve_id=sdh.curve_id
					 AND conv1.to_curve_id='+CAST(@curve_id AS VARCHAR)+'


				LEFT OUTER JOIN source_uom su on su.source_uom_id =conv0.to_source_uom_id


				LEFT JOIN source_counterparty sc 
					ON sc.source_counterparty_id=sdh.counterparty_id
				LEFT join source_deal_type sdt 
					ON sdt.source_deal_type_id=sdh.source_deal_type_id
				LEFT join source_deal_type sdt1 
					ON sdt.source_deal_type_id=sdh.deal_sub_type_type_id
					 '+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' join user_defined_group_detail udfg on udfg.rec_generator_id=rg.generator_id 
						  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

				WHERE 	1=1 '+			
					' AND (ISNULL(rg.create_obligation_deal,''n'')=''n'' and ISNULL(reduction,''n'')=''n'')'
					+case when @program_scope is not null then ' and esmd.ems_source_model_detail_id in(select ems_source_model_detail_id FROM ems_source_model_program
						where program_scope_value_id in('+@program_scope+'))' else '' end+
					' and book.emission_group_id='+cast(@reporting_group_id as varchar)+
					' and ((sdh.term_start between '''+cast(@prod_month_from as varchar)+''' and  '''+cast(@prod_month_to as varchar)+''') OR
					((sdh.term_start) between '''+@base_yr_from+''' and '''+@base_yr_to+'''))'		
					+case when @generator_id is not null then ' And rg.generator_id='+cast(@generator_id as varchar) else '' end
					+case when @generator_group_id is not null and @generator_group_id<>'null' then ' and isnull(rg.generator_group_name, '''') = ''' + @generator_group_id + '''' else '' end
					+case when @source_sink_type  is not null then 
							' and (isnull(sub.entity_id, 1) in(' +@source_sink_type+') OR isnull(stra.entity_id,1) in('+@source_sink_type+
							') OR isnull(book.entity_id,1) in('+@source_sink_type+'))' 	 else '' end
					+CASE WHEN @reduction_type IS NOT NULL THEN 	' and isnull(rg.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
					+CASE WHEN @reduction_sub_type IS NOT NULL THEN ' and isnull(rg.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
					+CASE WHEN @technology_type IS NOT NULL THEN ' and isnull(rg.technology, 1) = ' + cast(@technology_type as varchar)	ELSE '' END +
					+CASE WHEN @technology_sub_type IS NOT NULL THEN ' and isnull(rg.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
					--+CASE WHEN @primary_fuel IS NOT NULL THEN ' and isnull(vi.fuel_value_id, 1) = ' + cast(@primary_fuel as varchar)	ELSE '' END +
					+CASE WHEN @fuel_type IS NOT NULL THEN ' and isnull(rg.fuel_type_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
					+CASE WHEN @udf_source_sink_group IS NOT NULL THEN ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
					+CASE WHEN @udf_group1 IS NOT NULL THEN ' and isnull(rg.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
					+CASE WHEN @udf_group2 IS NOT NULL THEN ' and isnull(rg.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
					+CASE WHEN @udf_group3 IS NOT NULL THEN ' and isnull(rg.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END +
					+CASE WHEN @include_hypothetical IS NOT NULL THEN ' and isnull(rg.is_hypothetical,''n'') = ''' +@include_hypothetical+'''' ELSE '' END 
					+' AND '''+@credit_offsets+'''=''y'''
					if @curve_id is not null and @curve_id<>@Co2e_curve_id
						set @sql_select=@sql_select+' And sdh.curve_id='+cast(@curve_id as varchar) 

					

			--PRINT @Sql_Select
			EXEC(@Sql_Select)

		delete FROM #temp_inventory WHERE uom_name is null

		END



DECLARE @listCol VARCHAR(500),@listCol_sum VARCHAR(500),@listCol_series VARCHAR(500),@listCol_series_sum varchar(500),@listCol_series_hc varchar(500),@listCol_series_hcsum varchar(500),@listCol_max varchar(500)
DECLARE @sql_inv varchar(100),@sql_output varchar(100),@sql_hc varchar(100),@sql_reduc varchar(100),@max_seq_number int,@seq_count int

 
select @max_seq_number=max(seq_order),@seq_count=count(distinct seq_order) FROM #temp_inventory


SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + ltrim(str((seq_order)))
			 FROM    #temp_inventory
                   ORDER BY '],[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + ']'
IF @listCol is null
	SET @listCol='[0]'

SELECT  @listCol_sum = STUFF(( SELECT DISTINCT ',sum(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FROM    #temp_inventory
                   ORDER BY ',sum(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FOR XML PATH('')), 1,1, '')

IF @listCol_sum is null
	SET @listCol_sum='sum([0])[0]'



SELECT  @listCol_max = STUFF(( SELECT DISTINCT ',max(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FROM    #temp_inventory
                   ORDER BY ',max(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FOR XML PATH('')), 1,1, '') 

IF @listCol_max is null
	SET @listCol_max='max([0])[0]'

SELECT  @listCol_series = STUFF(( SELECT DISTINCT '],[' + ltrim(((series_type_value)))
			 FROM    #temp_inventory
                   ORDER BY '],[' + ltrim(((series_type_value))) FOR XML PATH('')), 1, 2, '') + ']'


IF @listCol_series is null
	SET @listCol_series='[series 0]'

SELECT  @listCol_series_sum = STUFF(( SELECT DISTINCT ',sum([' + ltrim(((series_type_value)))+'])['+ltrim(series_type_value)+']'
			 FROM    #temp_inventory
                   ORDER BY ',sum([' + ltrim(series_type_value)+'])['+ltrim(series_type_value)+']' FOR XML PATH('')), 1, 1, '')

IF @listCol_series_sum is null
	SET @listCol_series_sum='sum([series 0])[series 0]'


SELECT  @sql_inv = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],a.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
                   ORDER BY '],a.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
IF @sql_inv is null
	SET @sql_inv='a.[0]'
SELECT  @sql_output = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],c.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
                   ORDER BY '],c.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
IF @sql_output is null
	SET @sql_output='c.[0]'

SELECT  @sql_hc = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],d.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
                   ORDER BY '],d.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
IF @sql_hc is null
	SET @sql_hc='d.[0]'

SELECT  @sql_reduc = case when @seq_count>1 then 'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],e.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
                   ORDER BY '],e.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
IF @sql_reduc is null
	SET @sql_reduc='e.[0]'

SELECT  @listCol_series_hcsum = STUFF(( SELECT DISTINCT ',max([' + ltrim(((series_type_value)))+'])['+ltrim(series_type_value)+'_HI]'
			 FROM    #temp_inventory
                   ORDER BY ',max([' + ltrim(series_type_value)+'])['+ltrim(series_type_value)+'_HI]' FOR XML PATH('')), 1, 1, '')
IF @listCol_series_hcsum is null
	SET @listCol_series_hcsum='max([series 0])[series 0_HI]'

SELECT  @listCol_series_hc = STUFF(( SELECT DISTINCT '_HI],[' + ltrim(((series_type_value)))
			 FROM    #temp_inventory
                   ORDER BY '_HI],[' + ltrim(((series_type_value))) FOR XML PATH('')), 1, 5, '') + '_HI]'
IF @listCol_series_hc is null
	SET @listCol_series_hc='[series 0_HI]'


exec('select distinct series_type,series_type_value,forecast_type into '+@table_name+'_series_type'+' FROM #temp_inventory')



SET @sql_select=
'
SELECT
Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,Source1,Gas,Units,
		a.term_start,term_end,a.curve_id,uom_id,uom_name,
		sub,a.generator_id,output_id,output_uom,heatcontent_uom_id,base_year,current_forecast,a.frequency,base_year_count,forecast_type,
		OpCo,State,generator_name,heatinput_uom,input_value as [Input],input_uom,source_model_id,'+@sql_inv+' as Inventory
		,'+@sql_output+' as [Output],'+@sql_hc+' as [HeatInput],'+@sql_reduc+' as [Reduction],'+@listCol_series+','+@listCol_series_hc+',target,fuel_type
into '+@table_name+'
from
(
SELECT Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,max(curve_des) Source1,max(curve_name) as Gas,max(uom_name) Units,
		term_start,term_end,curve_id,'+@listCol_sum+',
		max(uom_id) as uom_id,
		max(uom_name) as uom_name,max(fuel_value_id) fuel_value_id,sub,generator_id,
		max(output_id) output_id,max(output_uom) output_uom,max(heatcontent_uom_id) as heatcontent_uom_id, 
		case when (term_start) between '''+cast(@base_yr_from as varchar)+''' and '''+cast(@base_yr_to as varchar)+''' then 1 else 0 end as base_year,
		max(current_forecast) current_forecast,max(frequency) frequency,'+cast(@base_yr_count as varchar)+' as base_year_count,
		forecast_type,OpCo,State,generator_name,max(heatinput_uom)heatinput_uom	,max(input_value) input_value,max(input_uom) input_uom,max(source_model_id)source_model_id,fuel_type
		
	FROM
(SELECT	 Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,curve_des,curve_name,term_start,term_end,curve_id,
		uom_id,uom_name,fuel_value_id,sub,generator_id,
		output_id,output_uom,heatcontent_uom_id, 
		current_forecast,frequency,volume,seq_order,reporting_year,technology,technology_sub_type,first_gen_date,
		source_model_id,forecast_type,OpCo,State,generator_name,heatinput_uom,input_uom,input_value,fuel_type	
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (SUM(volume) FOR seq_order
IN ('+@listCol+')) AS pvt
	group by Group1, reporting_year,
	Group1_ID,Group2_ID, Group3_ID, Group1, Group2, Group3, curve_id,
	sub,generator_id,technology,technology_sub_type,year(first_gen_date),
	term_start,term_end,source_model_id,forecast_type,OpCo,State,generator_name,fuel_type
)a
join
(select generator_id,term_start,curve_id,'+@listCol_series_sum+'
from
(SELECT	 generator_id,term_start,curve_id,series_type_value,volume
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (SUM(volume) FOR series_type_value
IN ('+@listCol_series+')) AS pvt
	group by generator_id,term_start,curve_id
)b
on a.generator_id=b.generator_id
and a.curve_id=b.curve_id and a.term_start=b.term_start
join
(select generator_id,term_start,curve_id,'+@listCol_sum+'
from
(SELECT	 generator_id,term_start,curve_id,seq_order,output_value
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (max(output_value) FOR seq_order
IN ('+@listCol+')) AS pvt
	group by generator_id,term_start,curve_id
)c
on a.generator_id=c.generator_id
and a.curve_id=c.curve_id and a.term_start=c.term_start
join
(select generator_id,term_start,curve_id,'+@listCol_max+'
from
(SELECT	 generator_id,term_start,curve_id,seq_order,heatcontent_value
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (sum(heatcontent_value) FOR seq_order
IN ('+@listCol+')) AS pvt
	group by generator_id,term_start,curve_id
)d
on a.generator_id=d.generator_id
and a.curve_id=d.curve_id and a.term_start=d.term_start
join
(select generator_id,term_start,curve_id,'+@listCol_sum+'
from
(SELECT	 generator_id,term_start,curve_id,seq_order,reduction_volume
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (sum(reduction_volume) FOR seq_order
IN ('+@listCol+')) AS pvt
	group by generator_id,term_start,curve_id
)e
on a.generator_id=e.generator_id
and a.curve_id=e.curve_id and a.term_start=e.term_start
join
(select generator_id,term_start,curve_id,'+@listCol_series_hcsum+'
from
(SELECT	 generator_id,term_start,curve_id,series_type_value,heatcontent_value
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (max(heatcontent_value) FOR series_type_value
IN ('+@listCol_series+')) AS pvt
	group by generator_id,term_start,curve_id
)f
on a.generator_id=f.generator_id
and a.curve_id=f.curve_id and a.term_start=f.term_start
join
(select generator_id,term_start,curve_id,sum([t])[target],frequency
from
(SELECT	 generator_id,term_start,curve_id,volume,current_forecast,frequency
      FROM #temp_inventory 
       WHERE 1=1 ) src
PIVOT (sum(volume) FOR current_forecast
IN ([t])) AS pvt
	group by generator_id,term_start,curve_id,frequency
)g
on a.generator_id=g.generator_id
and a.curve_id=g.curve_id and a.term_start=g.term_start
and a.frequency=g.frequency
'

--print @sql_select
exec(@sql_select)
--EXEC spa_print '2 Inserted in Last Temp Table :'+convert(varchar(100),getdate(),113)


--#########################-----------------------------------------------------
END




































































