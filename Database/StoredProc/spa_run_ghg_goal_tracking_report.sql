
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_ghg_goal_tracking_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_ghg_goal_tracking_report]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- EXEC spa_run_ghg_goal_tracking_report '136', null, null, '01/01/2003', '12/31/2007', null, 706, 1, null, 271
--ALTER PROC [dbo].[spa_run_ghg_goal_tracking_report]
CREATE PROC [dbo].[spa_run_ghg_goal_tracking_report] 
	@sub_entity_id VARCHAR(500), 
	@strategy_entity_id VARCHAR(500), 
	@book_entity_id VARCHAR(500),
	@base_year_from int,
	@base_year_to int,	
	@term_start VARCHAR(20), 
	@term_end VARCHAR(20), 
	@curve_id INT =NULL, 
	@period_frequency INT = 704, 
	@type  INT = 1,
	@generator_group_id VARCHAR(50)=NULL,
	@generator_id INT = NULL, 
	@source_sink_type varchar(500) = NULL, 
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL, 	   
	@absolute_ratio_flag VARCHAR(1)='a', 
	@output_id INT=NULL, 
	@input_id INT=NULL, 
	@heatcontent_uom_id INT=NULL,
	@convert_uom_id int=NULL,
	@reporting_year varchar(4)=NULL,
	@forecast_type int=NULL,
	@scale_factor int=null,
	@forecast_separate char(1)='n',
	@show_co2e char(1)='n',
	@group_by char(1)=null, -- 1 term, 2- subsidiary 3- country,state 4 - source/sink type
	@reporting_month varchar(100)=null,
	@series_type varchar(100)=null,
	@technology_type int=null,
	@technology_sub_type int=null,
	@primary_fuel int=null,
	@fuel_type int=null,
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	@include_hypothetical char(1)=null,
	@show_target char(1)=null,
	@program_scope varchar(100)=null,
	@report_type char(1)='t',-- 't' tracking report,'a' analytical report,'s' statistical report
	@comp_input_id int =null,  -- Inputs to compare
	@comp_output_id int =null,
	@control_chart char(1)='n',
	@upper_limit_id int=null,
	@upper_udf float=null,
	@lower_limit_id int=null,
	@lower_udf float=null,
	@limit_term_start VARCHAR(20)=null, 
	@limit_term_end VARCHAR(20)=null, 
	@run_statistical_report char(1)='n',
	@not_include_reduction_benchmark char(1)='y',
	@show_average_base CHAR(1)='y',
	@baseline_reduction CHAR(1)='y', -- Show baseline reductions
	@project_reduction CHAR(1)='y',-- Show project based reductions
	@credit_offsets CHAR(1)='y', -- Show Credit offsets reductions
	@input_uom INT=NULL,
	@output_uom INT=NULL,
	@round_value INT =0,
	@process_id varchar(100)=null,
	@drill_level int=null,
	@drill_sub varchar(100)=null,
	@drill_term varchar(100)=NULL,
	@drill_type varchar(100)=NULL,
	@level1 varchar(100)=null,
	@level2 varchar(100)=null,
	@level3 varchar(100)=null,
	@level4 varchar(100)=null,	
	@batch_process_id varchar(50)=NULL,	
	@batch_report_param varchar(1000)=NULL
	
AS
SET NOCOUNT ON
---######### Declare variables
	DECLARE @Sql_Select VARCHAR(8000)      
	DECLARE @Sql_Where VARCHAR(5000)      
	DECLARE @table_name VARCHAR(128)      
	DECLARE @as_of_date VARCHAR(20)
	DECLARE @sql_stmt varchar(8000)
	DECLARE @div_factor float
	DECLARE @temp_table_name varchar(128)
	DECLARE @new_process_id varchar(100)
	DECLARE @input_output_id int
	DECLARE @period_frequency_new INT
	DECLARE @group_by_new char(1)
	DECLARE @drill_groups varchar(100)
	DECLARE @listCol VARCHAR(MAX),@listCol_sum VARCHAR(500),@listCol_series VARCHAR(500),@listCol_series_sum varchar(500),@listCol_series_hc varchar(500),@listCol_series_hcsum varchar(500),@listCol_max varchar(500)
	DECLARE @sql_output varchar(100),@sql_input varchar(100),@sql_hc varchar(100),@sql_reduc varchar(100),@max_seq_number int,@seq_count int
	DECLARE @Sql_Inv VARCHAR(8000)
	DECLARE  @co2e_curve_id INT
	DECLARE  @reporting_group_id int
	DECLARE @base_yr_count int
	DECLARE @base_yr_from varchar(20)
	DECLARE @base_yr_to varchar(20)
	DECLARE @show_base_year CHAR(1)
	DECLARE @get_base_line CHAR(1)
    DECLARE @drill_type_year VARCHAR(4) 
---------

--------	

	BEGIN TRY
		--@drill_type='2007', @drill_term = 'December'
		--When @drill_type consists of only numeric characters, it will be changed as
		--@drill_type='Inventory', @drill_term = '2007-12'
		--When @drill_type consists of not only numeric characters, it continues with the same orginal values.
		SELECT  @drill_type_year = CAST(@drill_type AS INT)
		SET @drill_term = CASE WHEN @drill_term = 'January'   THEN @drill_type_year + '-01'
							   WHEN @drill_term = 'February'  THEN @drill_type_year + '-02'
							   WHEN @drill_term = 'March'	  THEN @drill_type_year + '-03'
							   WHEN @drill_term = 'April'     THEN @drill_type_year + '-04'
							   WHEN @drill_term = 'May'		  THEN @drill_type_year + '-05'
							   WHEN @drill_term = 'June'      THEN @drill_type_year + '-06'
							   WHEN @drill_term = 'July'      THEN @drill_type_year + '-07'
							   WHEN @drill_term = 'August'    THEN @drill_type_year + '-08'
							   WHEN @drill_term = 'September' THEN @drill_type_year + '-09'
							   WHEN @drill_term = 'October'   THEN @drill_type_year + '-10'
							   WHEN @drill_term = 'November'  THEN @drill_type_year + '-11'
							   WHEN @drill_term = 'December'  THEN @drill_type_year + '-12'
						  END
		SET @drill_type = 'Inventory' 

	END TRY
	BEGIN CATCH
		--continues with the original @drill_term and @drill_type values.
	END CATCH


	if @sub_entity_id='NULL'
		SET @sub_entity_id=NULL
	if @strategy_entity_id='NULL'
		SET @strategy_entity_id=NULL
	if @book_entity_id='NULL'
		SET @book_entity_id=NULL
	IF @control_chart is null
		SET @control_chart='n'

	-- New Added
	set @group_by_new=@group_by
	set @drill_groups=@drill_sub
	if @drill_level=0
	begin
		set @drill_level=NULL
		 set @group_by=1 
	end

	if @reporting_month is null
		set @reporting_month='12'
	if @reporting_year is null
		set @reporting_year=year(@term_start)

	if @baseline_reduction IS NULL 
		SET @baseline_reduction='n'
	if @credit_offsets IS NULL 
		SET @credit_offsets='n'
	if @project_reduction IS NULL 
		SET @project_reduction='n'

	SET @period_frequency_new=@period_frequency
	
	if @process_id is null OR @process_id IN('Rerun')
		set @new_process_id=REPLACE(newid(),'-','_')
	else
		set @new_process_id=@process_id

	set @temp_table_name=dbo.FNAProcessTableName('temp_ems_graph', 'uu',@new_process_id)

	if @scale_factor=3350 
		set @div_factor=10
	else if @scale_factor=3351
		set @div_factor=100
	else if @scale_factor=3352
		set @div_factor=1000
	else if @scale_factor=3353
		set @div_factor=10000
	else if @scale_factor=3354
		set @div_factor=1000000
	else
		set @div_factor=1

	set @Sql_Where = ''

	SET @base_yr_count = 1

	if @forecast_separate is null
		set @forecast_separate='n'
	
	SET @reporting_group_id = 5244 
	SET @co2e_curve_id=-1
	SET @show_base_year='n'
	SET @get_base_line='n'
 -- Check if target is selected
	IF EXISTS(SELECT item from [dbo].[SplitCommaSeperatedValues](@series_type) WHERE item=-3)
		SET @show_target='y'
	
	-- Check if base year needs to show
	IF EXISTS(SELECT item from [dbo].[SplitCommaSeperatedValues](@series_type) WHERE item=-2) 
		BEGIN
			SET @not_include_reduction_benchmark='n'
			SET @show_base_year='y'
		END
	IF (@show_base_year='y' OR @baseline_reduction='y')
		SET @get_base_line='y'
	


--######################### for batch process
	DECLARE @str_batch_table varchar(max)        
	SET @str_batch_table=''        
	IF @batch_process_id is not null        
	 SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         




--*********************************************************      
-- check if process_id is not null THEN  get values from temp table


	IF @process_id is not null AND @process_id NOT IN('Rerun')
	BEGIN
			--print 'do nothing'
			set @table_name=@temp_table_name
	END
	ELSE
	BEGIN
			set @as_of_date = cast(year(@term_end) as varchar) + '-12-31'
			set @table_name = dbo.FNAProcessTableName('temp_ems_graph', 'uu', @new_process_id)

			if @comp_input_id is not null and @report_type='a'
				set @input_id=@comp_input_id
			else if @comp_output_id is not null and @report_type='a'
				set @output_id=@comp_output_id


		CREATE TABLE #ssbm
			(                      
				 fas_book_id int,            
				 stra_book_id int,            
				 sub_entity_id int,
				 book_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
				 stra_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
				 sub_name VARCHAR(50) COLLATE DATABASE_DEFAULT            
			)            


		SET @Sql_Select='            
			INSERT INTO #ssbm            
			SELECT                      
			  book.entity_id AS fas_book_id,
			  book.parent_entity_id AS stra_book_id, 
			  stra.parent_entity_id AS sub_entity_id ,
			  book.entity_name AS book_name,	            
			  stra.entity_name AS stra_name,	            
			  sub.entity_name AS sub_name	            
			FROM            
				portfolio_hierarchy book (nolock)INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id             
				INNER JOIN Portfolio_hierarchy sub (nolock) ON stra.parent_entity_id = sub.entity_id    		            
			WHERE 1=1 '            
			+CASE WHEN @sub_entity_id IS NOT NULL THEN  ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR(500)) + ') '  ELSE '' END          
			+CASE WHEN @strategy_entity_id IS NOT NULL THEN  ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR(500)) + ' ))' ELSE '' END            
			+CASE WHEN @book_entity_id IS NOT NULL THEN  ' AND (book.entity_id IN(' + @book_entity_id + ')) ' ELSE '' END            
			
			exec spa_print @Sql_Select
			EXEC(@Sql_Select)        

		-----------------------
			CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
			CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
			CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
		----------------------


	

---************************************************
EXEC spa_print 'Start Inventory Report 1 :'--+convert(varchar(100),getdate(),113)
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
			Fuel_type VARCHAR(50),
			base_year INT
		)


		IF @limit_term_start is not null
			BEGIN	
				SET @base_yr_from=cast(@limit_term_start as varchar)
				SET @base_yr_to=cast(@limit_term_end as varchar)
			END
		ELSE
			BEGIN
				SET @base_yr_from=cast(@base_year_from as varchar)+'-01-01'
				SET @base_yr_to=cast(@base_year_to as varchar)+'-12-31'
			END


	if @control_chart='y'
		BEGIN
			SET @base_year_from=YEAR(@limit_term_start)
			SET @base_year_to=YEAR(@limit_term_end)
		END

	IF @sub_entity_id IS NULL
		SELECT  @sub_entity_id = 
				STUFF(( SELECT DISTINCT ',' + ltrim(str((sub_entity_id)))
				FROM    #ssbm
                ORDER BY ',' + ltrim(str((sub_entity_id))) FOR XML PATH('')), 1, 1, '') + ''


----######################### COLLECT ALL Inventory Data

	CREATE TABLE #view_inventory(
		fas_book_id INT,
		emission_group_id INT,
		as_of_date DATETIME,
		Group1_ID INT,
		Group2_ID INT,
		Group3_ID INT,
		Group1 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Group2 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Group3 VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator_id INT,
		generator_group_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[name]  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		frequency INT,
		curve_id INT,
		curve_name  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		curve_des VARCHAR(100) COLLATE DATABASE_DEFAULT,
		volume FLOAT,
		uom_id INT,
		uom_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		reporting_year INT, 
		sub  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		captured_co2_emission CHAR(1) COLLATE DATABASE_DEFAULT,
		technology VARCHAR(100) COLLATE DATABASE_DEFAULT,
		technology_sub_type VARCHAR(100) COLLATE DATABASE_DEFAULT,
		reduc_start_date DATETIME,
		term_start DATETIME,
		term_end DATETIME,
		output_id INT,
		output_value FLOAT,
		output_uom_id INT,
		heatcontent_value FLOAT,
		heatcontent_uom_id INT,
		current_forecast CHAR(1) COLLATE DATABASE_DEFAULT,
		reduction_volume FLOAT,
		de_minimis_source  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		co2_captured_for_generator_id INT,
		series_type INT,
		code  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		fuel_type_value_id INT,
		ems_source_model_id INT,
		default_inventory INT,
		sequence_order INT,
		forecast_type INT,
		reduction_type INT,
		reduction_sub_type INT,
		technology_code INT,
		classification_value_id INT,
		fuel_value_id INT,
		user_defined_group_id INT,
		udf_group1 INT,
		udf_group2 INT,
		udf_group3 INT,
		is_hypothetical CHAR(1) COLLATE DATABASE_DEFAULT,
		OpCo VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[State]  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator_name  VARCHAR(250) COLLATE DATABASE_DEFAULT,
		ems_source_model_detail_id INT,
		FuelType  VARCHAR(100) COLLATE DATABASE_DEFAULT,
		base_year INT
	)

	SELECT @Sql_Inv=dbo.FNAGetProcessTableSQL('ems_calc_detail_value',@term_start,@term_end,@sub_entity_id,@get_base_line,@base_year_from,@base_year_to)	



	SET @sql_select=' 
		INSERT INTO #view_inventory
		SELECT
			rg.fas_book_id,
			book.emission_group_id,
  			ei.as_of_date,
			sub.entity_id  Group1_ID,
			stra.entity_id Group2_ID,
			book.entity_id Group3_ID,
			sub.entity_name	 as Group1,
			stra.entity_name as Group2, 
			book.entity_name as Group3,
			rg.generator_id,
			rg.generator_group_name,
			rg.[name], 
			ei.frequency, 
			ei.curve_id, 
			spcd.curve_name, 
			spcd.curve_des,
			ISNULL(ei.formula_value,volume)*ISNULL(1-ISNULL(ownership.ownership_per,0),1) volume,
			ei.uom_id uom_id, 
			su1.uom_name uom_name,	
			year(ei.term_start) reporting_year,
			sub.entity_name sub,
			captured_co2_emission,
			technology.code as technology,
			--technology.value_id as technology,
			classification.code as technology_sub_type,
			reduc_start_date,
			ei.term_start,
			ei.term_end,
			ei.output_id,
			ei.output_value,
			ei.output_uom_id,
			ei.heatcontent_value,
			ei.heatcontent_uom_id,
			ei.current_forecast,
			ei.formula_value*ISNULL(1-ISNULL(ownership.ownership_per,0),1) as reduction_volume,
			rg.de_minimis_source as de_minimis_source,
			rg.co2_captured_for_generator_id,
			ei.forecast_type as series_type,
			st_forecast.code,
			ei.fuel_type_value_id,
			esmd.ems_source_model_id,
			CASE WHEN esf.default_inventory=''y'' THEN  -1 else NULL end as default_inventory,
			esf.sequence_order,
			isnull(st.series_type_value_id,0) as forecast_type,
			rg.reduction_type,
			rg.reduction_sub_type,
			rg.technology as technology_code,
			rg.classification_value_id,
			rg.fuel_value_id,
			NULl as user_defined_group_id,
			udf_group1,
			udf_group2,
			udf_group3,
			rg.is_hypothetical,
			ph.entity_name as OpCo,
			state.code as State,
			rg.[name] as generator_name,
			esmd.ems_source_model_detail_id,
			fuel_type.code as [FuelType],
			CASE WHEN YEAR(ei.term_start) between '+ CASE WHEN @base_year_from IS NOT NULL THEN  CAST(@base_year_from AS VARCHAR) ELSE 'fs.base_year_from 
					' END +' AND '  + CASE WHEN @base_year_to IS NOT NULL THEN  CAST(@base_year_to AS VARCHAR)  ELSE 'fs.base_year_to '  END+ 
				 ' THEN  1 ELSE 0 END				
		FROM    
			dbo.source_sink_type sst  
			inner join dbo.ems_portfolio_hierarchy book ON sst.source_sink_type_id=book.entity_id
			INNER JOIN dbo.ems_portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id             
			INNER JOIN  dbo.ems_portfolio_hierarchy sub ON stra.parent_entity_id = sub.entity_id             
			INNER JOIN dbo.rec_generator rg on sst.generator_id = rg.generator_id
			INNER JOIN  ('+@Sql_Inv+') ei on ei.generator_id = rg.generator_id
			INNER JOIN #ssbm ON #ssbm.fas_book_id = rg.fas_book_id
				  AND book.emission_group_id='+cast(@reporting_group_id as varchar)+'
			INNER JOIN dbo.source_price_curve_def spcd on spcd.source_curve_def_id = ei.curve_id
			INNER JOIN ems_source_model_effective esme on esme.generator_id=rg.generator_id
					AND ei.term_start between isnull(esme.effective_date,''1900-01-01'') AND isnull(esme.end_date,''9999-01-01'')
			INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id=esme.ems_source_model_id AND esmd.curve_id=ei.curve_id			
			left JOIN dbo.static_data_value rating on rating.value_id = esmd.rating_value_id
			left JOIN dbo.static_data_value em on em.value_id = esmd.estimation_type_value_id
			left JOIN dbo.static_data_value technology on technology.value_id=rg.technology
			LEFT JOIN dbo.static_data_value classification on classification.value_id=rg.classification_value_id
			LEFT JOIN dbo.ems_source_formula esf on esf.ems_source_model_detail_id=esmd.ems_source_model_detail_id and esf.forecast_type=ei.forecast_type
			LEFT JOIN dbo.source_uom su1 on su1.source_uom_id =ISNULL(ei.uom_id,-1)
			LEFT JOIN dbo.formula_editor fe on fe.formula_id=ei.formula_id
			LEFT JOIN (select generator_id,sum(per_ownership) ownership_per from dbo.generator_ownership group by generator_id) ownership
			on rg.generator_id=ownership.generator_id
			LEFT JOIN dbo.static_data_value st_forecast on st_forecast.value_id=ei.forecast_type
			LEFT JOIN dbo.series_type st on st.series_type_value_id=ei.forecast_type and st.forecast_type=''f''
			LEFT JOIN dbo.portfolio_hierarchy ph on ph.entity_id=rg.legal_entity_value_id
			left join dbo.static_data_value state on state.value_id=rg.gen_state_value_id
			LEFT JOIN dbo.static_data_value fuel_type on fuel_type.value_id=ei.fuel_type_value_id 
			LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id=ph.entity_id
 		    left join ems_edr_include_inv edr_inc on edr_inc.generator_id=ei.generator_id and
					 edr_inc.curve_id=ei.curve_id and ei.term_start between edr_inc.term_start and edr_inc.term_end
			'+CASE WHEN @udf_source_sink_group IS NOT NULL THEN  ' join user_defined_group_detail udfg on udfg.rec_generator_id=ei.generator_id 
				  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

		where 	1=1 '
	SET @sql_where='AND (edr_inc.generator_id is null or(edr_inc.generator_id is not null and (edr_inc.series_type=ei.forecast_type)))'
				+CASE WHEN @program_scope is not null THEN  ' and esmd.ems_source_model_detail_id in(select ems_source_model_detail_id FROM ems_source_model_program
					where program_scope_value_id in('+@program_scope+'))' else '' end+
				' and book.emission_group_id='+cast(@reporting_group_id as varchar)+
				+CASE WHEN @generator_id is not null THEN  ' And rg.generator_id='+cast(@generator_id as varchar) else '' end
				+CASE WHEN @generator_group_id is not null and @generator_group_id<>'null' THEN  ' and isnull(rg.generator_group_name, '''') = ''' + @generator_group_id + '''' else '' end
				+CASE WHEN @source_sink_type  is not null THEN  
						' and (isnull(sub.entity_id, 1) in(' +@source_sink_type+') OR isnull(stra.entity_id,1) in('+@source_sink_type+
						') OR isnull(book.entity_id,1) in('+@source_sink_type+'))' 	 else '' end
				+CASE WHEN @reduction_type IS NOT NULL THEN  	' and isnull(rg.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
				+CASE WHEN @reduction_sub_type IS NOT NULL THEN  ' and isnull(rg.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
				+CASE WHEN @technology_type IS NOT NULL THEN  ' and isnull(rg.technology, 1) = ' + cast(@technology_type as varchar)	ELSE '' END +
				+CASE WHEN @technology_sub_type IS NOT NULL THEN  ' and isnull(rg.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
				+CASE WHEN @primary_fuel IS NOT NULL THEN  ' and isnull(rg.fuel_value_id, 1) = ' + cast(@primary_fuel as varchar)	ELSE '' END +
				+CASE WHEN @fuel_type IS NOT NULL THEN  ' and isnull(ei.fuel_type_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
				+CASE WHEN @udf_source_sink_group IS NOT NULL THEN  ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
				+CASE WHEN @udf_group1 IS NOT NULL THEN  ' and isnull(rg.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
				+CASE WHEN @udf_group2 IS NOT NULL THEN  ' and isnull(rg.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
				+CASE WHEN @udf_group3 IS NOT NULL THEN  ' and isnull(rg.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END +
				+CASE WHEN @include_hypothetical='n' THEN  ' and isnull(rg.is_hypothetical,''n'') = ''n''' ELSE '' END 
				+CASE WHEN @project_reduction ='n' THEN  ' AND ISNULL(rg.reduction_type,-1)=-1' ELSE '' END

	EXEC(@sql_select+@sql_where)


	-----######## End of Collecting Inventory Data



	-----------###############################
	CREATE TABLE #temp_input(
		term_start DATETIME,
		generator_id INT,
		curve_id INT,
		fuel_type_value_id INT,
		input_value FLOAT,
		input_uom VARCHAR(100) COLLATE DATABASE_DEFAULT
	)
	-----------###############################

		IF @input_id IS NOT NULL -- For input reports select inputs only
		BEGIN
			
			SET @sql_select='
			insert into #temp_input
			SELECT
				vi.term_start,
				vi.generator_id,
				('+CASE WHEN @curve_id=@Co2e_curve_id THEN  CAST(@Co2e_curve_id AS VARCHAR) ELSE ' vi.curve_id' END +'), 
				(vi.fuel_type_value_id),
				(egi.input_value*ISNULL(conv0.conversion_factor,1)) AS input_value,
				(su_inv.uom_name) AS input_uom
			from 
				 (SELECT generator_id,term_start, MAX(curve_id)curve_id,MAX(fuel_type_value_id)fuel_type_value_id FROM #view_inventory GROUP BY generator_id,term_start) vi
			     JOIN ems_gen_input egi ON egi.generator_id=vi.generator_id
										   AND egi.term_start=vi.term_start
				 JOIN ems_source_input esi on	esi.ems_source_input_id=egi.ems_input_id
				 left join rec_volume_unit_conversion conv0 on
				 conv0.from_source_uom_id  = esi.uom_id
				 AND conv0.to_source_uom_id ='+CASE WHEN @input_uom is not null THEN  cast(@input_uom as varchar) else ' esi.uom_id ' end+'
				 And conv0.state_value_id is null
				 AND conv0.assignment_type_value_id is null
				 AND conv0.curve_id is null 

				 left join source_uom su_inv on su_inv.source_uom_id=ISNULL(conv0.to_source_uom_id,esi.uom_id)	
				 left join ems_edr_include_inv edr_inc on edr_inc.generator_id=vi.generator_id and
					 edr_inc.curve_id=vi.curve_id and vi.term_start between edr_inc.term_start and edr_inc.term_end
				 '+CASE WHEN @udf_source_sink_group IS NOT NULL THEN  ' join user_defined_group_detail udfg on udfg.rec_generator_id=vi.generator_id 
				  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'
			where 	1=1 '+
			+CASE WHEN @input_id IS NOT NULL THEN  ' AND egi.ems_input_id='+CAST(@input_id AS VARCHAR) ELSE '' END
			--@sql_where
			--+CASE WHEN @curve_id is not null and @curve_id<>@Co2e_curve_id THEN  ' And vi.curve_id='+cast(@curve_id as varchar)  ELSE '' END

			EXEC(@Sql_Select)	
		--	exec spa_print @Sql_Select



		END

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
					CASE WHEN @curve_id=@Co2e_curve_id THEN  CAST(@Co2e_curve_id AS VARCHAR) ELSE ' vi.curve_id' END +', 
					ISNULL(Conv1.curve_label,vi.curve_name), 
					ISNULL(Conv1.curve_label,vi.curve_des),'
					+CASE WHEN @type=4 THEN  ' vi.volume' ELSE '
					CASE WHEN ISNULL(vi.reduction_type,-1)=-1  THEN  vi.volume else NUll end' END +' * ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1),
					conv0.to_source_uom_id, 
					--ISNULL(Conv1.curve_label,vi.curve_name)+'' ''+ su_inv.uom_name , 
					su_inv.uom_name ,
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
					
						CASE 
							 WHEN '''+@baseline_reduction+'''=''y'' AND '''+@project_reduction+'''=''y''  AND ISNULL(vi.reduction_type,-1)<>-1 THEN  vi.volume
							 WHEN '''+@baseline_reduction+'''=''y'' AND '''+@project_reduction+'''=''n''  AND ISNULL(vi.reduction_type,-1)<>-1 THEN  vi.volume
							 WHEN '''+@baseline_reduction+'''=''n'' AND '''+@project_reduction+'''=''y''  AND ISNULL(vi.reduction_type,-1)<>-1 THEN  
											CASE WHEN ISNULL(vi.reduction_type,-1)<>-1 THEN  vi.volume else 0 end
						 else 0 end *  ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1)*-1 
					  
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
					vi.fueltype [FuelType],
					vi.base_year
				from #view_inventory vi
					 INNER JOIN #ssbm ON #ssbm.fas_book_id = vi.fas_book_id
					 and vi.emission_group_id='+cast(@reporting_group_id as varchar)+'
					 left join rec_volume_unit_conversion conv0 on
					 conv0.from_source_uom_id  = vi.uom_id
					 AND conv0.to_source_uom_id =ISNULL('+CASE WHEN @convert_uom_id is not null THEN  cast(@convert_uom_id as varchar) else 'NULL' END +',vi.uom_id)
					 And conv0.state_value_id is null
					 AND conv0.assignment_type_value_id is null
					 AND conv0.curve_id is null 	
					 AND conv0.to_curve_id IS NULL

					 left join rec_volume_unit_conversion conv1 on
					 conv1.from_source_uom_id  = vi.uom_id
					 AND conv1.to_source_uom_id =vi.uom_id
					 And conv1.state_value_id is null
					 AND conv1.assignment_type_value_id is null
					 AND conv1.curve_id=vi.curve_id
					 AND conv1.to_curve_id='+CASE WHEN @curve_id IS NOT NULL THEN CAST(@curve_id AS VARCHAR) ELSE '0' END+'	

					 left join rec_volume_unit_conversion conv2 on
					 conv2.from_source_uom_id  = vi.heatcontent_uom_id
					 AND conv2.to_source_uom_id ='+CASE WHEN @heatcontent_uom_id is not null THEN  cast(@heatcontent_uom_id as varchar) else ' vi.heatcontent_uom_id ' end+'
					 And conv2.state_value_id is null
					 AND conv2.assignment_type_value_id is null
					 AND conv2.to_curve_id is null 
					 AND conv2.to_curve_id is null 

					 left join rec_volume_unit_conversion conv3 on
					 conv3.from_source_uom_id  = vi.output_uom_id
					 AND conv3.to_source_uom_id ='+CASE WHEN @output_uom is not null THEN  cast(@output_uom as varchar) else ' vi.output_uom_id ' end+'
					 And conv3.state_value_id is null
					 AND conv3.assignment_type_value_id is null
					 AND conv3.curve_id is null 
					 AND conv3.to_curve_id is null 

					 left join source_uom su_inv on su_inv.source_uom_id=conv0.to_source_uom_id	
					 left join source_uom su_output on su_output.source_uom_id=conv3.to_source_uom_id	
					 left join source_uom su_hi on su_hi.source_uom_id=conv2.to_source_uom_id	
				where 	1=1 '+
				CASE WHEN @curve_id is not null and @curve_id<>@Co2e_curve_id THEN  ' And vi.curve_id='+cast(@curve_id as varchar)  ELSE '' END

		
			EXEC(@Sql_Select)

		
--select * from #temp_inventory

		EXEC spa_print '2 Inserted in First Temp Table :'--+convert(varchar(100),getdate(),113)

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
					CASE WHEN sdh.deal_volume_frequency=''m'' THEN  703
						 WHEN sdh.deal_volume_frequency=''q'' THEN  704
						 ELSE 706
					END	AS frequency, '+
					CASE WHEN @curve_id=@Co2e_curve_id THEN  CAST(@Co2e_curve_id AS VARCHAR) ELSE ' sdh.curve_id' END +', 
					spcd.curve_name AS curve_name, 
					spcd.curve_des AS curve_des,
					CASE WHEN buy_sell_flag=''s'' THEN  sdh.deal_volume*ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1) ELSE 0 END AS volume,
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
					CASE WHEN fas_deal_type_value_id=405 THEN  ''t'' else ''r'' end as current_forecast,
					CASE WHEN buy_sell_flag=''b'' THEN  sdh.deal_volume*ISNULL(conv0.conversion_factor,1)*ISNULL(conv1.conversion_factor,1)
						 ELSE 0 END AS volume,  
					rg.de_minimis_source,
					NULL AS co2_captured_for_generator_id,
					CASE WHEN fas_deal_type_value_id=405 THEN  NULL else esf.forecast_type end AS Series_type,
					CASE WHEN fas_deal_type_value_id=405 THEN  NULL else series.code end AS series_code,
					CASE WHEN fas_deal_type_value_id=405 THEN  NULL else rg.fuel_value_id end ,
					esmd.ems_source_model_id,
					CASE WHEN fas_deal_type_value_id=405 THEN  NULL WHEN esf.default_inventory=''y'' THEN  -1 else NULL end as default_inventory,
					CASE WHEN fas_deal_type_value_id=405 THEN  NULL else esf.sequence_order end AS sequence_order,
					0 AS forecast_type,
					#ssbm.sub_name AS OpCo,
					state.Code AS state,
					rg.[name],
					NULL as uom_name1,
					NULL AS input_value,
					NULL AS uom_name2,
					NULL AS FuelType,	
					CASE WHEN YEAR(sdh.term_start) between '+ CASE WHEN @base_year_from IS NOT NULL THEN  CAST(@base_year_from AS VARCHAR) ELSE 'fs.base_year_from 
										' END +' AND '  + CASE WHEN @base_year_to IS NOT NULL THEN  CAST(@base_year_to AS VARCHAR)  ELSE 'fs.base_year_to '  END+ 
									 ' THEN  1 ELSE 0 END			
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
					AND sdh.term_start between isnull(esme.effective_date,''1900-01-01'') AND isnull(esme.end_date,''9999-01-01'')
				INNER JOIN ems_source_model_detail esmd on esmd.ems_source_model_id=esme.ems_source_model_id AND esmd.curve_id=sdh.curve_id			
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
				LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id=sub.entity_id
				LEFT OUTER JOIN rec_volume_unit_conversion conv0 on
					 conv0.from_source_uom_id  = sdh.deal_volume_uom_id
					 AND conv0.to_source_uom_id =ISNULL('+CASE WHEN @convert_uom_id is not null THEN  cast(@convert_uom_id as varchar) else 'NULL' END +',sdh.deal_volume_uom_id)
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
					 '+CASE WHEN @udf_source_sink_group IS NOT NULL THEN  ' join user_defined_group_detail udfg on udfg.rec_generator_id=rg.generator_id 
						  and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +'

				WHERE 	1=1 '+			
					' AND (ISNULL(rg.create_obligation_deal,''n'')=''n'' and ISNULL(reduction,''n'')=''n'')'
					+CASE WHEN @program_scope is not null THEN  ' and esmd.ems_source_model_detail_id in(select ems_source_model_detail_id FROM ems_source_model_program
						where program_scope_value_id in('+@program_scope+'))' else '' end+
					' and book.emission_group_id='+cast(@reporting_group_id as varchar)+
					' and ((sdh.term_start between '''+cast(@term_start as varchar)+''' and  '''+cast(@term_end as varchar)+''') OR
					((sdh.term_start) between '''+ CAST(CASE WHEN @base_yr_from IS NOT NULL THEN @base_yr_from ELSE @term_start END AS VARCHAR)+''' and '''+CAST(CASE WHEN @base_yr_to IS NOT NULL THEN @base_yr_to ELSE @term_end END  AS VARCHAR)+'''))'		
					+CASE WHEN @generator_id is not null THEN  ' And rg.generator_id='+cast(@generator_id as varchar) else '' end
					+CASE WHEN @generator_group_id is not null and @generator_group_id<>'null' THEN  ' and isnull(rg.generator_group_name, '''') = ''' + @generator_group_id + '''' else '' end
					+CASE WHEN @source_sink_type  is not null THEN  
							' and (isnull(sub.entity_id, 1) in(' +@source_sink_type+') OR isnull(stra.entity_id,1) in('+@source_sink_type+
							') OR isnull(book.entity_id,1) in('+@source_sink_type+'))' 	 else '' end
					+CASE WHEN @reduction_type IS NOT NULL THEN  	' and isnull(rg.reduction_type, 1) = ' + cast(@reduction_type as varchar) ELSE '' END 
					+CASE WHEN @reduction_sub_type IS NOT NULL THEN  ' and isnull(rg.reduction_sub_type, 1) = ' + cast(@reduction_sub_type as varchar)	ELSE '' END +
					+CASE WHEN @technology_type IS NOT NULL THEN  ' and isnull(rg.technology, 1) = ' + cast(@technology_type as varchar)	ELSE '' END +
					+CASE WHEN @technology_sub_type IS NOT NULL THEN  ' and isnull(rg.classification_value_id, 1) = ' + cast(@technology_sub_type as varchar)	ELSE '' END +
					+CASE WHEN @fuel_type IS NOT NULL THEN  ' and isnull(rg.fuel_value_id, 1) = ' + cast(@fuel_type as varchar)	ELSE '' END +
					+CASE WHEN @udf_source_sink_group IS NOT NULL THEN  ' and isnull(udfg.user_defined_group_id, 1) = ' + cast(@udf_source_sink_group as varchar)	ELSE '' END +
					+CASE WHEN @udf_group1 IS NOT NULL THEN  ' and isnull(rg.udf_group1, 1) = ' + cast(@udf_group1 as varchar)	ELSE '' END +
					+CASE WHEN @udf_group2 IS NOT NULL THEN  ' and isnull(rg.udf_group2, 1) = ' + cast(@udf_group2 as varchar)	ELSE '' END +
					+CASE WHEN @udf_group3 IS NOT NULL THEN  ' and isnull(rg.udf_group3, 1) = ' + cast(@udf_group3 as varchar)	ELSE '' END +
					+CASE WHEN @include_hypothetical IS NOT NULL THEN  ' and isnull(rg.is_hypothetical,''n'') = ''' +@include_hypothetical+'''' ELSE '' END 
					+' AND '''+@credit_offsets+'''=''y'''
					if @curve_id is not null and @curve_id<>@Co2e_curve_id
						set @sql_select=@sql_select+' And sdh.curve_id='+cast(@curve_id as varchar) 

					

			--print @Sql_Select
			EXEC(@Sql_Select)

			delete FROM #temp_inventory WHERE uom_name is null




------######END of Collecting All Deals

		CREATE  INDEX [IX_INV1] ON [#temp_inventory](generator_id)                  
		CREATE  INDEX [IX_INV2] ON [#temp_inventory](curve_id)                  
		CREATE  INDEX [IX_INV3] ON [#temp_inventory](term_start)       

------#############


		SELECT @max_seq_number=max(seq_order),@seq_count=count(distinct seq_order) FROM #temp_inventory WHERE forecast_type=0



		SELECT  @listCol = STUFF(( SELECT DISTINCT '],[' + ltrim(str((seq_order)))
					 FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY '],[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + ']'

		IF @listCol is null
			SET @listCol='[0]'

		SELECT  @listCol_sum = STUFF(( SELECT DISTINCT ',sum(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY ',sum(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FOR XML PATH('')), 1,1, '')

		IF @listCol_sum is null
			SET @listCol_sum='sum([0])[0]'



		SELECT  @listCol_max = STUFF(( SELECT DISTINCT ',max(([' + ltrim(str((seq_order)))+']))['+ltrim(str((seq_order)))+']' FROM    #temp_inventory WHERE forecast_type=0
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


		SELECT  @sql_inv = CASE WHEN @seq_count>1 THEN  'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],a.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY '],a.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'

		IF @sql_inv is null
			SET @sql_inv='a.[0]'

		SELECT  @sql_output = CASE WHEN @seq_count>1 THEN  'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],c.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY '],c.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
		IF @sql_output is null
			SET @sql_output='c.[0]'

		SELECT  @sql_hc = CASE WHEN @seq_count>1 THEN  'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],d.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY '],d.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
		IF @sql_hc is null
			SET @sql_hc='d.[0]'

		SELECT  @sql_reduc = CASE WHEN @seq_count>1 THEN  'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],e.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY '],e.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
		IF @sql_reduc is null
			SET @sql_reduc='e.[0]'


		SELECT  @sql_input = CASE WHEN @seq_count>1 THEN  'COALESCE' else '' end+'('+STUFF(( SELECT DISTINCT '],h.[' + ltrim(str((seq_order))) FROM    #temp_inventory WHERE forecast_type=0
						   ORDER BY '],h.[' + ltrim(str((seq_order))) FOR XML PATH('')), 1, 2, '') + '])'
		IF @sql_input is null
			SET @sql_input='h.[0]'

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
					OpCo,State,generator_name,heatinput_uom,
					input_value as [Input],
					input_uom,source_model_id,'+@sql_inv+' as Inventory
					,'+@sql_output+' as [Output],'+@sql_hc+' as [HeatInput],'+@sql_reduc+' as [Reduction],'+@listCol_series+','+@listCol_series_hc+',fuel_type
			into '+@table_name+'
			from
			(
			SELECT Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,max(curve_des) Source1,max(curve_name) as Gas,max(uom_name) Units,
					term_start,term_end,curve_id,'+@listCol_sum+',fuel_type_value_id,
					max(uom_id) as uom_id,
					max(uom_name) as uom_name,max(fuel_value_id) fuel_value_id,sub,generator_id,
					max(output_id) output_id,max(output_uom) output_uom,max(heatcontent_uom_id) as heatcontent_uom_id, 
					base_year,
					max(current_forecast) current_forecast,max(frequency) frequency,'+cast(@base_yr_count as varchar)+' as base_year_count,
					forecast_type,OpCo,State,generator_name,max(heatinput_uom)heatinput_uom	,max(source_model_id)source_model_id,fuel_type
					
				FROM
			(SELECT	 Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,curve_des,curve_name,term_start,term_end,curve_id,
					uom_id,uom_name,fuel_value_id,sub,generator_id,
					output_id,output_uom,heatcontent_uom_id, 
					current_forecast,frequency,volume,seq_order,reporting_year,technology,technology_sub_type,first_gen_date,
					source_model_id,forecast_type,OpCo,State,generator_name,heatinput_uom,fuel_type,base_year,fuel_type_value_id
				  FROM #temp_inventory 
				   WHERE 1=1 ) src
			PIVOT (SUM(volume) FOR seq_order
			IN ('+@listCol+')) AS pvt
				group by Group1, reporting_year,
				Group1_ID,Group2_ID, Group3_ID, Group1, Group2, Group3, curve_id,
				sub,generator_id,technology,technology_sub_type,year(first_gen_date),
				term_start,term_end,source_model_id,forecast_type,OpCo,State,generator_name,fuel_type,base_year,fuel_type_value_id
			)a
			join
			(select generator_id,term_start,curve_id,fuel_type_value_id,'+@listCol_series_sum+'
			from
			(SELECT	 generator_id,term_start,curve_id,series_type_value,volume,fuel_type_value_id
				  FROM #temp_inventory 
				   WHERE 1=1 ) src
			PIVOT (SUM(volume) FOR series_type_value
			IN ('+@listCol_series+')) AS pvt
				group by generator_id,term_start,curve_id,fuel_type_value_id
			)b
			on a.generator_id=b.generator_id
			and a.curve_id=b.curve_id and a.term_start=b.term_start
			and ISNULL(a.fuel_type_value_id,-1)=ISNULL(b.fuel_type_value_id,-1)
			join
			(select generator_id,term_start,curve_id,fuel_type_value_id,'+@listCol_sum+'
			from
			(SELECT	 generator_id,term_start,curve_id,seq_order,output_value,fuel_type_value_id
				  FROM #temp_inventory 
				   WHERE 1=1 ) src
			PIVOT (SUM(output_value) FOR seq_order
			IN ('+@listCol+')) AS pvt
				group by generator_id,term_start,curve_id,fuel_type_value_id
			)c
			on a.generator_id=c.generator_id
			and a.curve_id=c.curve_id and a.term_start=c.term_start
			and ISNULL(a.fuel_type_value_id,-1)=ISNULL(c.fuel_type_value_id,-1)
			join
			(select generator_id,term_start,curve_id,fuel_type_value_id,'+@listCol_max+'
			from
			(SELECT	 generator_id,term_start,curve_id,seq_order,heatcontent_value,fuel_type_value_id
				  FROM #temp_inventory 
				   WHERE 1=1 ) src
			PIVOT (sum(heatcontent_value) FOR seq_order
			IN ('+@listCol+')) AS pvt
				group by generator_id,term_start,curve_id,fuel_type_value_id
			)d
			on a.generator_id=d.generator_id
			and a.curve_id=d.curve_id and a.term_start=d.term_start
			and ISNULL(a.fuel_type_value_id,-1)=ISNULL(d.fuel_type_value_id,-1)
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
--			join
--			(select generator_id,term_start,curve_id,sum([t])[target],frequency
--			from
--			(SELECT	 generator_id,term_start,curve_id,volume,current_forecast,frequency
--				  FROM #temp_inventory 
--				   WHERE 1=1 ) src
--			PIVOT (sum(volume) FOR current_forecast
--			IN ([t])) AS pvt
--				group by generator_id,term_start,curve_id,frequency
--			)g
--			on a.generator_id=g.generator_id
--			and a.curve_id=g.curve_id and a.term_start=g.term_start
--			and a.frequency=g.frequency
			LEFT JOIN #temp_input ti  
			ON a.generator_id=ti.generator_id
			--and a.curve_id=ti.curve_id 
			and a.term_start=ti.term_start
			AND a.fuel_type_value_id=ti.fuel_type_value_id
			'

		--print @sql_select
		exec(@sql_select)
		EXEC spa_print '2 Inserted in Last Temp Table :'--+convert(varchar(100),getdate(),113)



--select series_type_value from #temp_inventory
		--#########################-----------------------------------------------------
if not exists(select 'x' from #temp_inventory where series_type_value = 'Target')
	EXEC('alter table '+@table_name+' add  target FLOAT')

--		exec spa_emissions_tracking_report @as_of_date, @sub_entity_id, @strategy_entity_id, NULL, 
--					NULL, NULL, 'a',@term_start, @term_end,@base_year_from,@base_year_to, @table_name, @book_entity_id, NULL,
--					@curve_id,@generator_group_id,@generator_id,@source_sink_type,@reduction_type,@reduction_sub_type,
--					@convert_uom_id,@technology_type,@technology_sub_type,@primary_fuel,@fuel_type,@udf_source_sink_group,@udf_group1,@udf_group2,@udf_group3,
--					@include_hypothetical,@heatcontent_uom_id,@show_co2e,@input_id,@output_id,@program_scope,@limit_term_start,@limit_term_end,@not_include_reduction_benchmark,@baseline_reduction,@project_reduction,@credit_offsets,@input_uom,@output_uom


	IF @process_id IN('Rerun')
	BEGIN
		Exec spa_ErrorHandler 0, 'Goal Tracking report', 
						'spa_run_ghg_goal_tracking_report', 'Success', 
						'Success.',@new_process_id
		return
	END

		 EXEC spa_print '5 :'--+convert(varchar(100),getdate(),113)



	-- --Break target emissions to monthly
	 set @sql_stmt=
	 'insert into ' + @table_name + ' 
			(Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,Source1,Gas,Units,term_start,term_end,curve_id,uom_id,uom_name,sub,generator_id,output_id,output_uom,heatcontent_uom_id,base_year,current_forecast,frequency,base_year_count,forecast_type,OpCo,State,generator_name,heatinput_uom,Input,input_uom,source_model_id,Inventory,Output,HeatInput,Reduction,Target)
			select 
				Group1_ID,Group2_ID,Group3_ID,Group1,Group2,Group3,Source1,Gas,Units,
				cast(year(term_start) as varchar) + ''-'' + cast(a.month_id as varchar) + ''-01'' term_start, 
				dateadd(month,1,cast(cast(year(term_start) as varchar) + ''-'' + cast(a.month_id as varchar) + ''-01'' as datetime))-1 as term_end,
				curve_id,uom_id,uom_name,sub,generator_id,output_id,output_uom,heatcontent_uom_id,base_year,
				current_forecast,703 frequency,
				base_year_count,forecast_type,OpCo,State,generator_name,heatinput_uom,Input,input_uom,source_model_id,
				CASE WHEN (frequency = 704) THEN  Inventory/3 WHEN (frequency = 705) THEN  Inventory/6 WHEN (frequency = 706) THEN  Inventory/12 end  Inventory ,
				Output,HeatInput,
				CASE WHEN (frequency = 704) THEN  Reduction/3 WHEN (frequency = 705) THEN  Reduction/6 WHEN (frequency = 706) THEN  Reduction/12 end  Reduction,
				CASE WHEN (frequency = 704) THEN  Target/3 WHEN (frequency = 705) THEN  Target/6 WHEN (frequency = 706) THEN  Target/12 end  Target 
			from ' + @table_name + '  e
			cross join (select 1 as month_id union select 2 as month_id  union select 3 as month_id union select 4 as month_id 
									union select 5 as month_id union select 6 as month_id union select 7 as month_id union select 8 as month_id 
						union select 9 as month_id union select 10 as month_id union select 11 as month_id union select 12 as month_id)a
			where 1=1
				--and current_forecast = ''t'' 
				and frequency IN (704, 705, 706) '
		--print @sql_stmt
		exec(@sql_stmt)
		


			--delete non-monthly target emissions
		exec('delete ' + @table_name + '  where  frequency IN (704, 705, 706)')


			--exec('select * into '+@temp_table_name+' from #temp_ems_graph')
	END



	CREATE TABLE #temp_base
		(
		group1 varchar(200) COLLATE DATABASE_DEFAULT,
		group2 varchar(200) COLLATE DATABASE_DEFAULT,
		group3 varchar(200) COLLATE DATABASE_DEFAULT,
		generator_id varchar(200) COLLATE DATABASE_DEFAULT,
		base_year_volume float,
		base_year_count int,
		heatcontent_value float,
		input_value float,
		output_value float,
		uom_id int,
		input_uom varchar(100) COLLATE DATABASE_DEFAULT,	
		output_uom varchar(100) COLLATE DATABASE_DEFAULT,	
		base_year_from int,
		base_year_to int,
		opco varchar(100) COLLATE DATABASE_DEFAULT,
		state varchar(20) COLLATE DATABASE_DEFAULT,
		curve_id int,
		UCL_inv float,
		LCL_inv float,
		CL_inv float,
		UCL_hi float,
		LCL_hi float,
		CL_hi float,
		UCL_inp float,
		LCL_inp float,
		CL_inp float,
		fuel_type VARCHAR(100) COLLATE DATABASE_DEFAULT
		--term_start varchar(100) COLLATE DATABASE_DEFAULT
		)


	IF @control_chart='n'
	BEGIN
	set @sql_stmt = '
		INSERT INTO #temp_base(group1,group2,group3,generator_id,base_year_volume,base_year_count,heatcontent_value,input_value,output_value,uom_id,input_uom,
			output_uom,base_year_from,base_year_to,opco,state,curve_id,fuel_type)
		select
			sub,group2,group3,'
			+CASE WHEN @group_by=5 or @drill_level=4 THEN '' else 'max' end +'(generator_id),avg(base_year_volume),base_year_count,
			avg(heatcontent_value),avg(input),avg(output),uom_id,max(input_uom),
			max(output_uom),min(base_year_from),max(base_year_to),max(opco),max(state),curve_id,fuel_type
			
			from	
			(Select  
					max(sub)sub,max(group2)group2,max(group3)group3,
					'+CASE WHEN @group_by=5 THEN '' else 'max' end +'(e.generator_id) generator_id,
					sum(inventory) as base_year_volume, 
					max(e.base_year_count) base_year_count,
					sum(HeatInput) heatcontent_value, 
					SUM(input) input,
					SUM(output) output,
					e.uom_id,
					max(input_uom) as input_uom,
					max(output_uom) as output_uom,max(opco)opco,max(state)state,curve_id,max(inventory) as UCL_inv,
					min(inventory) as LCL_inv,avg(inventory) as CL_inv
					,dbo.FNATermGrouping(e.term_start,'+cast(@period_frequency as varchar)+')term_start
					,min(year(term_start)) base_year_from,max(year(term_start)) base_year_to
					,max(fuel_type) fuel_type	
				from '+@table_name+' e 
				INNER JOIN rec_generator rg on rg.generator_id = e.generator_id 
				where e.base_year = 1' 
				+CASE WHEN @drill_sub is not null THEN  
					CASE WHEN @group_by_new=2 THEN  ' And OpCo='''+@drill_sub+'''' 
						WHEN  @group_by_new=3 THEN  ' And ISNULL(state,'''')='''+@drill_sub+'''' 
						WHEN  @group_by_new=4 THEN  ' And group1='''+@drill_sub+'''' 
						WHEN  @group_by_new=6 THEN  ' And fuel_type='''+@drill_sub+'''' 
					else ''
					end		
				 else '' end+
				' group by 
				dbo.FNATermGrouping(e.term_start,'+cast(@period_frequency as varchar)+')' 
				+CASE WHEN @drill_level=1 THEN  ',sub'
					  WHEN @drill_level=2 THEN  ',group2'
					  WHEN @drill_level=3 THEN  ',group3'
					  WHEN @drill_level=4 THEN  ',e.generator_id'					
				else
					CASE WHEN @group_by=2 THEN  ',OpCo'
						 WHEN @group_by=3 THEN  ',State'
						 WHEN @group_by=4 THEN  ',group1'
						WHEN @group_by=6 THEN  ',fuel_type'
					else ''
					end	
				end		
				+',e.uom_id,e.curve_id '+CASE WHEN @group_by=5 THEN  ',e.generator_id' else '' end+'
				)a
				group by 
				sub,OpCo,group2,group3,base_year_count,uom_id,curve_id,fuel_type'+CASE WHEN @group_by=5  or @drill_level=4 THEN  ',generator_id' else '' end
	end
	else 
	begin

		  declare @ucl_sql_inv varchar(500),@lcl_sql_inv varchar(500),@cl_sql_inv varchar(500),
				  @ucl_sql_hi varchar(500),@lcl_sql_hi varchar(500),@cl_sql_hi varchar(500),
				  @ucl_sql_inp varchar(500),@lcl_sql_inp varchar(500),@cl_sql_inp varchar(500),@input_output VARCHAR(20)	


	IF @comp_input_id IS NOT NULL OR @input_id IS NOT NULL
		SET @input_output='Input'
	ELSE IF  @comp_output_id IS NOT NULL OR @output_id IS NOT NULL
		SET @input_output='Output'
	ELSE 
		SET @input_output='Input'

	  if @upper_limit_id=1550
		  begin
				 set @ucl_sql_inv='max(base_year_volume)'
				 set @ucl_sql_hi='max(heatcontent_value)'
				 set @ucl_sql_inp='max('+@input_output+')'
			end
	  else if @upper_limit_id=1552
			begin
				 set @ucl_sql_inv='min(base_year_volume)'
				 set @ucl_sql_hi='min(heatcontent_value)'
				 set @ucl_sql_inp='min('+@input_output+')'
			 end
	  else if @upper_limit_id=1554
			begin
				 set @ucl_sql_inv=cast(@upper_udf as varchar)
				 set @ucl_sql_hi=cast(@upper_udf as varchar)
				 set @ucl_sql_inp=cast(@upper_udf as varchar)
			 end
	
	  else if @upper_limit_id=1551
			begin
				 set @ucl_sql_inv='avg(base_year_volume)+3*stdev(base_year_volume)'
				 set @ucl_sql_hi='avg(heatcontent_value)+3*stdev(heatcontent_value)'
				 set @ucl_sql_inp='avg('+@input_output+')+3*stdev('+@input_output+')'
			 end
	  else if @upper_limit_id=1553
			begin
				 set @ucl_sql_inv='avg(base_year_volume)-3*stdev(base_year_volume)'
				 set @ucl_sql_hi='avg(heatcontent_value)-3*stdev(heatcontent_value)'
				 set @ucl_sql_inp='avg('+@input_output+')-3*stdev('+@input_output+')'
			 end

 
	  if @lower_limit_id=1550
		  begin
				 set @lcl_sql_inv='max(base_year_volume)'
				 set @lcl_sql_hi='max(heatcontent_value)'
				 set @lcl_sql_inp='max('+@input_output+')'
			end
	  else if @lower_limit_id=1552
			begin
				 set @lcl_sql_inv='min(base_year_volume)'
				 set @lcl_sql_hi='min(heatcontent_value)'
				 set @lcl_sql_inp='min('+@input_output+')'
			 end
	  else if @lower_limit_id=1554
			begin
				 set @lcl_sql_inv=cast(@lower_udf as varchar)
				 set @lcl_sql_hi=cast(@lower_udf as varchar)
				 set @lcl_sql_inp=cast(@lower_udf as varchar)
			 end
	  else if @lower_limit_id=1551
			begin
				 set @lcl_sql_inv='avg(base_year_volume)+3*stdev(base_year_volume)'
				 set @lcl_sql_hi='avg(heatcontent_value)+3*stdev(heatcontent_value)'
				 set @lcl_sql_inp='avg('+@input_output+')+3*stdev('+@input_output+')'
			 end
	  else if @lower_limit_id=1553
			begin
				 set @lcl_sql_inv='avg(base_year_volume)-3*stdev(base_year_volume)'
				 set @lcl_sql_hi='avg(heatcontent_value)-3*stdev(heatcontent_value)'
				 set @lcl_sql_inp='avg('+@input_output+')-3*stdev('+@input_output+')'
			 end
		
		set @cl_sql_inv='(('+@ucl_sql_inv+')+('+@lcl_sql_inv+'))/2'
		set @cl_sql_hi='(('+@ucl_sql_hi+')+('+@lcl_sql_hi+'))/2'
		set @cl_sql_inp='(('+@ucl_sql_inp+')+('+@lcl_sql_inp+'))/2'



		set @sql_stmt = '
		INSERT INTO #temp_base(group1,group2,group3,generator_id,base_year_volume,base_year_count,heatcontent_value,input_value,output_value,uom_id,input_uom,
			output_uom,opco,state,curve_id,base_year_from,base_year_to,UCL_inv,LCL_inv,CL_inv,UCL_hi,LCL_hi,CL_hi,UCL_inp,LCL_inp,CL_inp)
		select
			MAX(sub),MAX(group2),MAX(group3),MAX(generator_id),avg(base_year_volume),base_year_count,
			avg(heatcontent_value),avg(input),avg(output),uom_id,max(input_uom),max(output_uom),max(opco),
			max(state),curve_id,min(base_year_from),max(base_year_to),'
				    +@ucl_sql_inv+','+@lcl_sql_inv+','+@cl_sql_inv+','
				    +@ucl_sql_hi+','+@lcl_sql_hi+','+@cl_sql_hi+','
				    +@ucl_sql_inp+','+@lcl_sql_inp+','+@cl_sql_inp+
			' from	
			(Select  
					max(sub)sub,max(group2)group2,max(group3)group3,
					max(e.generator_id)generator_id,
					sum(ISNULL(inventory,0)) as base_year_volume, 
					max(e.base_year_count) base_year_count,
					sum(isnull(HeatInput,0)) heatcontent_value, 
					sum(isnull(input,0)) input,
					sum(isnull(output,0)) output,
					e.uom_id,
					max(input_uom) as input_uom,
					max(output_uom) as output_uom,max(opco)opco,max(state)state,curve_id,min(year(term_start)) base_year_from,
					max(year(term_start)) base_year_to
				from '+@table_name+' e 
				INNER JOIN rec_generator rg on rg.generator_id = e.generator_id 
				where e.base_year = 1' 
				+CASE WHEN @drill_sub is not null THEN  
					CASE WHEN @group_by_new=2 THEN  ' And OpCo='''+@drill_sub+'''' 
						WHEN  @group_by_new=3 THEN  ' And ISNULL(state, '''') ='''+@drill_sub+'''' 
						WHEN  @group_by_new=4 THEN  ' And group1='''+@drill_sub+'''' 
					else ''
					end		
				 else '' end+
				' group by 
				dbo.FNATermGrouping(e.term_start,'+cast(@period_frequency as varchar)+')' 
				+CASE WHEN @drill_level=1 THEN  ',sub'
					  WHEN @drill_level=2 THEN  ',group2'
					  WHEN @drill_level=3 THEN  ',group3'
					  WHEN @drill_level=4 THEN  ',e.generator_id'					
				else
					CASE WHEN @group_by=2 THEN  ',OpCo'
						 WHEN @group_by=3 THEN  ',State'
						 WHEN @group_by=4 THEN  ',group1'
					else ''
					end	
				end		
				+',e.uom_id,e.curve_id
				)a
				group by 
				base_year_count,uom_id,curve_id
				 '

	

	END
	--print @sql_stmt
	exec(@sql_stmt)

EXEC spa_print 'ppppppppppppppppppppppppp'

	IF @type=4
		SET @type=1

	create table #series(value_id int ,code varchar(100) COLLATE DATABASE_DEFAULT,forecast_type int)
	set @sql_select='insert into #series 
					 select * from '+@table_name+'_series_type where series_type in('+@series_type+')'
	exec(@sql_select)


	DECLARE @listCol1 varchar(1000)

	DECLARE @uom_name varchar(100)
	DECLARE @a_sum_sql varchar(500),@b_sum_sql_ratio varchar(100),@a_sum_sql_ratio varchar(100),@forecast_ratio varchar(100)
	DECLARE @b_sum_sql varchar(500),@control_sql varchar(500)
	DECLARE @uom varchar(100),@group_by_uom VARCHAR(100)


	set @group_by_uom=''
	

	set @a_sum_sql=''
		set @b_sum_sql ='round(max(tb.base_year_volume)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') [Base],'
		set @b_sum_sql_ratio ='max(tb.base_year_volume)/'+cast(@div_factor as varchar)
		
		if  (@type=2) 
		begin
			set @a_sum_sql ='round((sum(reduction)+CASE WHEN '''+@baseline_reduction+'''=''y'' THEN  max(tb.base_year_volume)-sum(inventory) ELSE 0 END)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') [Reduction],'
			set @a_sum_sql_ratio ='(sum(reduction))/'+cast(@div_factor as varchar)
			set @forecast_ratio='reduction'
		end
		if  (@type=1) and @series_type like '%-1%' 
		begin
	
	
			set @a_sum_sql ='round(sum(CASE WHEN '''+@forecast_separate+'''=''n'' and (term_start)>cast('+cast(@reporting_year as varchar)+'-'+isnull(cast(@reporting_month as varchar),12)+'-31 as Datetime)  THEN  inventory else isnull(inventory,0) end )/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') [Inventory],' 
			set @a_sum_sql_ratio ='isnull(sum(inventory),0)/'+cast(@div_factor as varchar)
			set @forecast_ratio='inventory'

		end	
		if  (@type=3) 
		begin
			set @a_sum_sql ='round((sum(reduction)+CASE WHEN '''+@baseline_reduction+'''=''y'' THEN  (max(tb.base_year_volume)-sum(inventory))*-1 ELSE 0 END)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') [Reduction],'
							+'round(sum(inventory)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') [Inventory],' 
			set @a_sum_sql_ratio ='sum(inventory)/'+cast(@div_factor as varchar)
			set @forecast_ratio='inventory'
		end
		set @uom='uom_name'
		set @group_by_uom='uom_name'
		--if @type=1
			SELECT   @listCol =					
					STUFF(( SELECT  DISTINCT ',round(SUM(CASE WHEN forecast_type=0 and '''+@forecast_separate+'''=''n'' and year(term_start)<='+cast(@reporting_year as varchar)+' and month(term_start)<='+isnull(cast(@reporting_month as varchar),12)+' THEN  '+@forecast_ratio+' else [' +ltrim(code)+'] end)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+']'
						FROM    #series where forecast_type<>0
                    ), 1,1, '')

			
			SELECT   @listCol1=
					STUFF(( SELECT  DISTINCT ',round(SUM([' +ltrim(code)+']),'+cast(@round_value as varchar)+')as['+ltrim(code)+']'
						FROM    #series where forecast_type=0
                    ORDER BY ',round(SUM([' +ltrim(code)+']),'+cast(@round_value as varchar)+')as['+ltrim(code)+']' FOR XML PATH('')), 1,1, '')
	set @control_sql=''

	if @control_chart='y'
	begin
			if @drill_level<1
				set @b_sum_sql=''

			set @control_sql='round(max(tb.UCL_inv),'+cast(@round_value as varchar)+')as UCL,
							 round(max(tb.CL_inv),'+cast(@round_value as varchar)+')as CL,
							 round(max(tb.lCL_inv),'+cast(@round_value as varchar)+')as LCL,'
	end
		

	if @absolute_ratio_flag='r'
	BEGIN
	set @listCol=NULL
	set @listCol1=NULL

	if @output_id is not null and @heatcontent_uom_id is null
		begin
			
			set @b_sum_sql = 'round('+@b_sum_sql_ratio+'/NULLIF((MAX(tb.output_value)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+') as [Base],'	
			set @a_sum_sql = 'round('+@a_sum_sql_ratio+'/NULLIF((SUM(f.output)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+') as [Output],'		

			set @uom='max('+@uom+'+''/''+f.output_uom)'
		 set @control_sql='round(max(tb.UCL_inv)/NULLIF((max(tb.UCL_inp)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as UCL,
							 round(max(tb.CL_inv)/NULLIF((max(tb.CL_inp)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as CL,
							 round(max(tb.LCL_inv)/NULLIF((max(tb.LCL_inp)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as LCL,'
			SELECT   @listCol =					
						STUFF(( SELECT  DISTINCT ',round((SUM(CASE WHEN forecast_type=0 and '''+@forecast_separate+'''=''n'' and year(term_start)<='+cast(@reporting_year as varchar)+' and month(term_start)<='+isnull(cast(@reporting_month as varchar),12)+' THEN  '+@forecast_ratio+' else [' +ltrim(code)+'] end)/NULLIF(sum(f.input),0))/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_OP]'
							FROM    #series where forecast_type<>0
						), 1,1, '')


				SELECT   @listCol1=
						STUFF(( SELECT  DISTINCT ',round(SUM([' +ltrim(code)+'])/NULLIF(sum(f.input),0),'+cast(@round_value as varchar)+')as['+ltrim(code)+'_OP]'
							FROM    #series where forecast_type=0
						ORDER BY ',round(SUM([' +ltrim(code)+'])/NULLIF(sum(f.input),0),'+cast(@round_value as varchar)+')as['+ltrim(code)+'_OP]' FOR XML PATH('')), 1,1, '')

		end
		else if @input_id is not null
		begin

			set @b_sum_sql = 'round('+@b_sum_sql_ratio+'/NULLIF((max(tb.input_value)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as [Base],'	
			set @a_sum_sql = 'round('+@a_sum_sql_ratio+'/NULLIF((SUM(f.input)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as [Input],'	
			set @uom='max('+@uom+'+''/''+f.input_uom)'
		 
			set @control_sql='round(max(tb.UCL_inv)/NULLIF((max(tb.UCL_inp)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as UCL,
							 round(max(tb.CL_inv)/NULLIF((max(tb.CL_inp)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as CL,
							 round(max(tb.LCL_inv)/NULLIF((max(tb.LCL_inp)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as LCL,'

			SELECT   @listCol =					
						STUFF(( SELECT  DISTINCT ',round((SUM(CASE WHEN forecast_type=0 and '''+@forecast_separate+'''=''n'' and year(term_start)<='+cast(@reporting_year as varchar)+' and month(term_start)<='+isnull(cast(@reporting_month as varchar),12)+' THEN  '+@forecast_ratio+' else [' +ltrim(code)+'] end)/NULLIF(sum(f.input),0))/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_IP]'
							FROM    #series where forecast_type<>0
						), 1,1, '')


				SELECT   @listCol1=
						STUFF(( SELECT  DISTINCT ',round(SUM([' +ltrim(code)+'])/NULLIF(sum(f.input),0),'+cast(@round_value as varchar)+')as['+ltrim(code)+'_IP]'
							FROM    #series where forecast_type=0
						ORDER BY ',round(SUM([' +ltrim(code)+'])/NULLIF(sum(f.input),0),'+cast(@round_value as varchar)+')as['+ltrim(code)+'_IP]' FOR XML PATH('')), 1,1, '')


		end
		else if @heatcontent_uom_id is not null and @output_id is null
		begin
			
			EXEC spa_print 'HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhHHHHHHHHHHHHHHHH'


			set @b_sum_sql = 'round('+@b_sum_sql_ratio+'/NULLIF((max(heatcontent_value)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+') as [Base],'	
			set @a_sum_sql = 'round('+@a_sum_sql_ratio+'/NULLIF((sum(heatinput)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+') as [HeatInput],'	
			set @uom='max('+@uom+'+''/''+heatinput_uom)'
			set @forecast_ratio=@forecast_ratio
			

		 set @control_sql='round(max(tb.UCL_inv)/NULLIF((max(tb.UCL_hi)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as UCL,
							 round(max(tb.CL_inv)/NULLIF((max(tb.CL_hi)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as CL,
							 round(max(tb.LCL_inv)/NULLIF((max(tb.LCL_hi)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as LCL,'

		  SELECT  @listCol = STUFF(( SELECT DISTINCT ',round(sum(CASE WHEN forecast_type=0 and '''+@forecast_separate+'''=''n'' and year(term_start)<='+cast(@reporting_year as varchar)+' and month(term_start)<='+isnull(cast(@reporting_month as varchar),12)+' THEN  '+@forecast_ratio+' else [' + ltrim(code)+'] end)/'+
					' sum(CASE WHEN forecast_type=0 and '''+@forecast_separate+'''=''n'' and year(term_start)<='+cast(@reporting_year as varchar)+' and month(term_start)<='+isnull(cast(@reporting_month as varchar),12)+' THEN  NULLIF(HeatInput,0) else NULLIF([' + ltrim(code)+'_HI],0) end) /'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_HI]'
				 FROM    #series where forecast_type<>0), 1, 1, '')


			SELECT  @listCol1 = STUFF(( SELECT DISTINCT ',round(sum([' + ltrim(code)+'])/'+'NULLIF(sum([' + ltrim(code)+'_HI]),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_HI]'
				 FROM    #series where forecast_type=0
					   ORDER BY ',round(sum([' + ltrim(code)+'])/'+'NULLIF(sum([' + ltrim(((code)))+'_HI]),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_HI]' FOR XML PATH('')), 1, 1, '')

			
			
		EXEC spa_print 'SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssSSSSSSSSSSSS'

		end
		else if @heatcontent_uom_id is not null and @output_id is not null
		begin
		
			set @b_sum_sql = 'round((max(heatcontent_value)/NULLIF(max(output_value),0))'+ '/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') as [Base],'	
			set @a_sum_sql = 'round((sum(heatinput)/NULLIF(sum(output),0))'+ '/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') as [HeatRate],'	
			set @uom='max(heatinput_uom'+'+''/''+'+'f.output_uom)'
		
			set @control_sql='round(max(tb.UCL_hi)/NULLIF(max(output_value),0),'+cast(@round_value as varchar)+')as UCL,
							 round(max(tb.LCL_hi)/NULLIF(max(output_value),0),'+cast(@round_value as varchar)+')as CL,
							 round(max(tb.CL_hi)/NULLIF(max(output_value),0),'+cast(@round_value as varchar)+')as LCL,'

			SELECT  @listCol = STUFF(( SELECT DISTINCT ',round(sum(CASE WHEN forecast_type=0 and '''+@forecast_separate+'''=''n'' and year(term_start)<='+cast(@reporting_year as varchar)+' and month(term_start)<='+isnull(cast(@reporting_month as varchar),12)+' THEN  NULLIF(HeatInput,0) else NULLIF([' + ltrim(code)+'_HI],0) end)/'+
					' NULLIF(sum(f.input),0) /'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_HR]'
				 FROM    #series where forecast_type<>0), 1, 1, '')


			SELECT  @listCol1 = STUFF(( SELECT DISTINCT ',round(sum([' + ltrim(code)+'_HI])/'+'NULLIF(sum(output),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_HR]'
				 FROM    #series where forecast_type=0
					   ORDER BY ',round(sum([' + ltrim(code)+'_HI])/'+'NULLIF(sum(output),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+')as['+ltrim(code)+'_HR]' FOR XML PATH('')), 1, 1, '')

		end
	END





	if @report_type='a' and (@comp_input_id is not null or @comp_output_id is not null)
	begin
			set @listCol=NULL
			set @listCol1=NULL


	set @control_sql='round(max(tb.UCL_inp),'+cast(@round_value as varchar)+')as UCL,
							 round(max(tb.CL_inp),'+cast(@round_value as varchar)+')as CL,
							 round(max(tb.LCL_inp),'+cast(@round_value as varchar)+')as LCL,'


		if(@comp_input_id is not null)
		begin
				
				set @b_sum_sql = 'round(NULLIF((MAX(tb.input_value)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as [Base],'	
					set @a_sum_sql = 'round(NULLIF((SUM(f.input)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as [Input],'	
				set @uom='max(f.input_uom)'

			end
		else if(@comp_output_id is not null) 
		begin
				set @b_sum_sql = 'round(NULLIF((max(tb.output_value)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as [Base],'	
			
				set @a_sum_sql = 'round(NULLIF((SUM(f.output)'+ '/'+cast(@div_factor as varchar)+'),0),'+cast(@round_value as varchar)+')as [OutPut],'	
				
				set @uom='max(f.output_uom)'

			
		end

	end

	if @listCol is not null and @listCol1 is not null
		set @listCol=isnull(@listCol,'')+isnull(','+@listCol1,'')
	if @listCol is not null and @listCol1 is null
		set @listCol=isnull(@listCol,'')
	if @listCol is null and @listCol1 is not null
		set @listCol=isnull(@listCol1,'')


	if @listCol is null or @listCol=''
		set @listCol=''
	else
		set @listCol=@listCol+','

	 
	if @show_base_year='n' --and @report_type='t'
		set @b_sum_sql =''

	if @control_chart='y' AND ISNULL(@drill_level,0)<=0
		set @b_sum_sql=''

	if @control_chart='n' 
		set @control_sql=''

--Added By Annal to avoid NULL in @sql_stmt
	IF @a_sum_sql is null
	SET @a_sum_sql=''

--SELECT * FROM adiha_process.dbo.temp_ems_graph_uu_00174FD7_8FB4_431A_841F_C141D8E6A258
--SELECT * FROM adiha_process.dbo.temp_ems_graph_uu_010A3961_08EF_44B6_B043_64099CB15142
--



EXEC spa_print '--##################Final Output*******************************************************************/'
	if @drill_level is not null
		BEGIN
		
--select @control_sql
--exec('select * from '+@table_name)
--select * from #temp_base
		set @sql_stmt = '
				select '+
				CASE WHEN @drill_level=1 THEN  ' f.group1 as [Level1],'
					 WHEN @drill_level=2 THEN  ' f.group2 as [Level2],'
					 WHEN @drill_level=3 THEN  ' f.group3 as [Level3],'	
					 WHEN @drill_level=4 THEN  ' f.generator_name as [Level4],' end+
					@b_sum_sql+
					CASE WHEN (@heatcontent_uom_id is not null and @output_id is not null) THEN 
							CASE WHEN @drill_type='HeatRate' THEN 
								'round(sum([heatcontent_value])/NULLIF(sum(nullif(f.input, 0)'+'),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],' 
								ELSE
								'round(sum(['+replace(@drill_type,'_HR','_HI')+'])/NULLIF(sum(nullif(f.output, 0)'+'),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],'
							END	
					 WHEN  @absolute_ratio_flag='r' and @input_id is not null THEN 
						'round(sum(['+replace(@drill_type,'_IP','')+'])/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],'
					 WHEN  @absolute_ratio_flag='r' and (@heatcontent_uom_id is null and @output_id is not null) THEN 
						'round(isnull(sum(inventory),0)/nullif(sum(['+replace(@drill_type,'_OP','')+']),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],'
					 WHEN (@heatcontent_uom_id is not null and @output_id is null) THEN  
						'round(sum(['+replace(@drill_type,'_HI','') +'])/NULLIF(sum(nullif(['+@drill_type +'], 0)'+'),0)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],'
					 WHEN @drill_type='Reduction' THEN 
						' round(sum([Reduction])+(CASE WHEN '''+@baseline_reduction+'''=''y'' THEN  (MAX(ISNULL(tb.base_year_volume,0))-SUM(ISNULL(inventory,0)))*-1 ELSE 0 END)/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],'
	   				ELSE
				'
						round(SUM(nullif(['+
						CASE WHEN @drill_type='base' or @drill_type='Inventory'   THEN  'Inventory' 
						ELSE 
							@drill_type + CASE WHEN @drill_type='UCL' OR @drill_type='CL' OR @drill_type='LCL' THEN '_inv' ELSE '' END 
						END +'], 0)'+')/'+cast(@div_factor as varchar)+','+cast(@round_value as varchar)+') ['+@drill_type+'],' end+
				@uom+' as [UOM]'+	
				CASE WHEN @drill_level=4 THEN  ',dbo.fnadateformat(min(term_start)) [Term Start],
					dbo.fnadateformat(max(term_end)) [Term End],
					max(current_forecast) [Current Forecast] ' else '' end +
				'from '+@table_name+' f 
				left join #temp_base tb on '+
--					CASE WHEN @input_id IS NOT NULL OR @comp_input_id IS NOT NULL THEN  ' f.input_uom=tb.input_uom' 
--					     WHEN @output_id IS NOT NULL OR @comp_output_id IS NOT NULL THEN  ' f.output_uom=tb.output_uom' 	
--						 ELSE '  f.uom_id=tb.uom_id' 
--					end 
				+'  tb.curve_id=f.curve_id'
				+CASE WHEN @drill_level=1 THEN  ' and f.group1=tb.group1'
					  WHEN @drill_level=2 THEN  ' and f.group2=tb.group2'
					  WHEN @drill_level=3 THEN  ' and f.group3=tb.group3'
					  WHEN @drill_level=4 THEN  ' and f.generator_id=tb.generator_id'
					end+						
				' where 1=1'+
				CASE WHEN @drill_type='base' THEN  ' AND base_year=1' ELSE 
				' and 	dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')='''+@drill_term+'''  '
			  END	
			+CASE WHEN @group_by_new=2 and @drill_groups is not null THEN 
				' And f.OpCO='''+@drill_groups+'''' else '' end
				+ CASE WHEN @group_by_new=3 and @drill_groups is not null THEN 
				' And ISNULL(f.state,'''')='''+@drill_groups+'''' else '' end
				+ CASE WHEN @group_by_new=4 and @drill_groups is not null THEN 
				' And f.group1='''+@drill_groups+'''' else '' end
			+CASE WHEN @drill_level=1 THEN  ' group by f.group1'  
				 WHEN @drill_level=2 THEN  ' and f.group1='''+@level1+''' group by f.group2'  
				 WHEN @drill_level=3 THEN  ' and f.group1='''+@level1+''' and f.group2='''+@level2+''' group by f.group3'  
				 WHEN @drill_level=4 THEN  ' and f.group1='''+@level1+''' and f.group2='''+@level2+''' and f.group3='''+@level3+''' group by f.generator_id,f.generator_name ' end 

				+','+CASE WHEN @absolute_ratio_flag='a' THEN  @group_by_uom+',' else '' end+ ' dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')
			order by '+CASE WHEN @drill_level=4 THEN  ' f.generator_name,' else '' end +  ' dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')'
		
		--PRINT 'STAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAART'
		--print @sql_stmt
		--PRINT 'STAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAART'
		
		exec(@sql_stmt)
		
		
		END


	ELSE 
	BEGIN		
		if @show_average_base='n'    -- This is to show average
			set @period_frequency=703


			set @sql_stmt = ' select '+
			  CASE 
				
				WHEN (@group_by=1 or  @group_by=5) THEN  
					 CASE WHEN @group_by=5 THEN  ' f.generator_name as [Source/Sink]' else 
					'dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+') Term'
					end
				WHEN @group_by=2 THEN  
				' f.OpCo as [OpCompany]'
				WHEN @group_by=3 THEN  
				' f.State as [Country/State]'
				WHEN @group_by=4 THEN  
				' f.group1 as [Source/Sink Type]'
				WHEN @group_by=6 THEN  
				' f.fuel_type as [FuelType]'
				end	

				+','+@b_sum_sql+@control_sql+@listCol+@a_sum_sql
				+CASE WHEN @show_target='y' THEN  'sum(target)'+ '/'+cast(@div_factor as varchar)+' as [Target],' else '' end
				+@uom+' as [UOM],
				'''+@new_process_id+''' as ProcessID
				 '+@str_batch_table+
				 CASE WHEN @show_average_base='n' THEN  ' INTO ##temp_benchMark ' ELSE '' END
				 +' from '+@table_name+' f 
				 left join #temp_base tb on '+ 
					CASE WHEN @input_id IS NOT NULL OR @comp_input_id IS NOT NULL THEN  ' f.input_uom=tb.input_uom' 
						 WHEN @output_id IS NOT NULL OR @comp_output_id IS NOT NULL THEN  ' f.output_uom=tb.output_uom' 
						 ELSE ' f.uom_id=tb.uom_id'
					END
					+' and f.curve_id=tb.curve_id '+
					CASE WHEN @group_by=2 THEN  ' and f.opco=tb.opco'
						 WHEN @group_by=3 THEN  ' and ISNULL(f.state,'''') = ISNULL(tb.state, '''')'
						 WHEN @group_by=4 THEN  ' and f.group1=tb.group1'
						 WHEN @group_by=5 THEN  ' and f.generator_id=tb.generator_id'
						 WHEN @group_by=6 THEN  ' and f.fuel_type=tb.fuel_type'
					else ''
					end	+
				' where 1=1 ' + 
					CASE WHEN @show_average_base='y' THEN  ' AND ((base_year<>1) or (base_year=1 and year('''+@term_start+''') between base_year_from and base_year_to))' ELSE '' END
						 	
				+CASE WHEN @drill_sub is not null THEN  
					CASE WHEN @group_by_new=2 THEN  ' And f.OpCo='''+@drill_sub+'''' 
						WHEN  @group_by_new=3 THEN  ' And ISNULL(f.state, '''') ='''+@drill_sub+'''' 
						WHEN  @group_by_new=4 THEN  ' And f.group1='''+@drill_sub+'''' 
						WHEN  @group_by_new=6 THEN  ' And f.fuel_type='''+@drill_sub+'''' 
					
					end		
				
				 else '' end+
				 CASE WHEN @group_by_new=6 THEN  ' AND f.fuel_type IS NOT NULL' ELSE '' END+
				 ' group by '+ CASE WHEN (@absolute_ratio_flag='a' and @report_type='t') or (@report_type='a' and @absolute_ratio_flag='a' and (@comp_input_id is null and @comp_output_id is null))
							   THEN  @uom+',' else '' end+ 
					 CASE WHEN (@group_by=1 or  @group_by=5) THEN  
						 CASE WHEN @group_by=5 THEN  ' f.generator_name ' else 
						 'dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+') '
							
						end
					 WHEN @group_by=2 THEN  
						' f.OpCo '
					 WHEN @group_by=3 THEN  
						' f.State '
					 WHEN @group_by=4 THEN  
						' f.group1'
					 WHEN @group_by=6 THEN  
						' f.fuel_type'

				 end			
				+' order by '+
				 CASE WHEN (@group_by=1 or  @group_by=5) THEN  
					  CASE WHEN @group_by=5 THEN  ' f.generator_name' else 
						'dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+') '
						
						end
					 WHEN @group_by=2 THEN  
						' f.OpCo '
					 WHEN @group_by=3 THEN  
						' f.State'
					 WHEN @group_by=4 THEN  
						' f.group1'				
					 WHEN @group_by=5 THEN  
						' f.generator_name'
					 WHEN @group_by=6 THEN  
						' f.fuel_type'
					end
		
		--	EXEC spa_print @sql_stmt
			
					
			EXEC spa_print 'ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRROOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR'
		
		exec(@sql_stmt)
				
		--SELECT @sql_stmt 
 
		if @show_average_base='n' 
		BEGIN
					
				SELECT  @listCol_sum = STUFF(( SELECT DISTINCT ',MAX(([' + ltrim(str((YEAR(TERM+'-01'))))+']))['+ltrim(str((YEAR(TERM+'-01'))))+']' FROM    ##temp_benchMark
					   ORDER BY ',MAX(([' + ltrim(str((YEAR(TERM+'-01'))))+']))['+ltrim(str((YEAR(TERM+'-01'))))+']' FOR XML PATH('')), 1,1, '')
					
				SELECT  @listCol = STUFF(( SELECT DISTINCT ',[' + ltrim(str((YEAR(TERM+'-01'))))+']' FROM    ##temp_benchMark
					   ORDER BY ',[' + ltrim(str((YEAR(TERM+'-01'))))+']' FOR XML PATH('')), 1,1, '')

			IF ISNULL(@listCol_sum,'')=''
				SELECT 'sss' Term,'sss' UOM,'sss' ProcessID FROM ##temp_benchMark
			ELSE
			begin
				 set @sql_stmt = 
					'
						SELECT DATENAME(MONTH,Term+''-01'')'+
						 ' as Term,'+@listCol_sum+',MAX(UOM) UOM,MAX(ProcessID) ProcessID
					FROM 
					(SELECT Term,'+

					 CASE WHEN @comp_input_id IS NOT NULL THEN  ' INPUT'
						  WHEN @comp_output_id IS NOT NULL THEN  ' OUTPUT'
						  WHEN @absolute_ratio_flag='r' and @input_id IS NOT NULL THEN  'INPUT'
						  WHEN @absolute_ratio_flag='r' and @output_id IS NOT NULL and @heatcontent_uom_id IS NOT NULL THEN  'Heatrate'
						  WHEN @absolute_ratio_flag='r' and @output_id IS NULL and @heatcontent_uom_id IS NOT NULL THEN  'HeatInput'
						  WHEN @absolute_ratio_flag='r' and @output_id IS NOT NULL and @heatcontent_uom_id IS NULL THEN  'OUTPUT'
						  ELSE 'Inventory' END+	
					' AS Inventory, YEAR(Term+''-01'') [Year],UOM,ProcessID
					FROM ##temp_benchMark) p
					PIVOT
					(
						SUM (Inventory)FOR [year] IN('+@listCol+')
					) AS pvt
					group by DATENAME(MONTH,Term+''-01''),MONTH(Term+''-01'') ORDER BY MONTH(Term+''-01'') '

			--	EXEC spa_print @sql_stmt
				--PRINT 'LAST AND END ! !'				
				exec(@sql_stmt)
			end
			drop table ##temp_benchMark
		END
	  END

--*****************FOR BATCH PROCESSING**********************************            
 

IF  @batch_process_id is not null        
BEGIN        
 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
 EXEC(@str_batch_table)        
 declare @report_name varchar(100)        

 set @report_name='Emissions Tracking Report'        
        
 SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_run_ghg_goal_tracking_report',@report_name)         
 EXEC(@str_batch_table)        
 
END        
--********************************************************************   

EXEC spa_print '6 :'--+convert(varchar(100),getdate(),113)
