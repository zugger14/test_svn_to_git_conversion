
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_get_emmission_input_report]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_emmission_input_report]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =====================================================================================================================================
-- Author:<Sudeep Lamsal>
-- Created date: <25th March, 2010>
-- Last Update date: <5th April, 2010>
-- Update By: <Sudeep Lamsal>
-- Description:	<Stored Procedure to generate two types of Reports and Graphs for Emmission Input Limit.
-- The first type of report illustrates details of Pollutants' Input Limit definition, Upper/Lower Limits with Output Sample Values.
-- The second type of report illustrates the Violation for each Pollutant. 
-- Similarly the Line graph illustrates Sample Value Vs. Upper/Lower Limit
-- and the Bar Chart illustrates Pollutant VS Violation.>
-- =======================================================================================================================================

--CREATE PROCEDURE [dbo].[spa_get_emmission_input_report]
CREATE PROCEDURE [dbo].[spa_get_emmission_input_report]
	@Plot char(1),
	@generator_id VARCHAR(200),
	@curve_id int=NULL,
	@convert_uom_id int=NULL,
	@as_of_date VARCHAR(50),
	@term_start VARCHAR(50),--Datetime=NULL,
	@term_end VARCHAR(50),--Datetime=NULL
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(100),
	@book_entity_id varchar(100)=null,
	@generator_group_name varchar(500)=null,
	--- EXTRA FILTERS --
	@technology int = null,
	@fuel_value_id int=null,
	@technology_sub_type int=null,
	@fuel_type int=null,
	@ems_book_id varchar(200)=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL,
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	---- Add New Parameters in this block -----
	@period_frequency INT = 704,
	---- END (Add New Parameters) -----
	------- DRILL DOWN -------
	@drill_term_start varchar(50)=null,
	@drill_curve_id VARCHAR(100)=NULL,
	------- NEW Filters -----
	@show_value_id int=null,
	@forecast_type int=null,
	------- Batch Process -------
	@batch_process_id varchar(50)=null,	
	@batch_report_param varchar(1000)=NULL
AS
SET NOCOUNT ON 
	DECLARE @Sql_Stmt varchar(max)
	DECLARE @Sql_tmpBookSelect varchar(max)
	DECLARE @Sql_tmpBookWhere varchar(max)
	DECLARE @Sql_Pivot varchar(max)
	DECLARE @str_batch_table varchar(max)
	
	DECLARE @Sql_LimitRpt varchar(max)
	DECLARE @Sql_ViolationRpt varchar(max)

--------------- Extracting DATE FROM DRILL DOWN OF PLOT ------------------------------------------------------------- 
DECLARE @drill_term_end varchar(50)
DECLARE @findDate varchar(5)

BEGIN TRY
		IF @drill_term_start IS NOT NULL
		BEGIN
			IF LEN(@drill_term_start)>4
			BEGIN
				SET @findDate= RIGHT(@drill_term_start,2)	
				SET @drill_term_end = CASE	WHEN @findDate= '01' THEN  LEFT(@drill_term_start,4) + '-01-31' 
											WHEN @findDate= '02' THEN  LEFT(@drill_term_start,4) + '-02-28' 
											WHEN @findDate= '03' THEN  LEFT(@drill_term_start,4) + '-03-31' 
											WHEN @findDate= '04' THEN  LEFT(@drill_term_start,4) + '-04-30' 
											WHEN @findDate= '05' THEN  LEFT(@drill_term_start,4) + '-05-31' 
											WHEN @findDate= '06' THEN  LEFT(@drill_term_start,4) + '-06-30' 
											WHEN @findDate= '07' THEN  LEFT(@drill_term_start,4) + '-07-31' 
											WHEN @findDate= '08' THEN  LEFT(@drill_term_start,4) + '-08-31' 
											WHEN @findDate= '09' THEN  LEFT(@drill_term_start,4) + '-09-30' 
											WHEN @findDate= '10' THEN  LEFT(@drill_term_start,4) + '-10-31' 
											WHEN @findDate= '11' THEN  LEFT(@drill_term_start,4) + '-11-30' 
											WHEN @findDate= '12' THEN  LEFT(@drill_term_start,4) + '-12-31' 
										  
											WHEN @findDate= 'Q1' THEN  LEFT(@drill_term_start,4) + '-03-31' 
											WHEN @findDate= 'Q2' THEN  LEFT(@drill_term_start,4) + '-06-30' 
											WHEN @findDate= 'Q3' THEN  LEFT(@drill_term_start,4) + '-09-30' 
											WHEN @findDate= 'Q4' THEN  LEFT(@drill_term_start,4) + '-12-31' 

											WHEN @findDate= 'st' THEN  LEFT(@drill_term_start,4) + '-06-30' 
											WHEN @findDate= 'nd' THEN  LEFT(@drill_term_start,4) + '-12-31' 
										  
									END
				IF(@findDate <> 'Q1' AND @findDate <> 'Q2' AND @findDate <> 'Q3' AND @findDate <> 'Q4' AND @findDate <> 'st' AND @findDate <> 'nd' )
					SET @drill_term_start  = @drill_term_start +'-01'
				
				IF(@findDate = 'Q1' OR @findDate = 'Q2' OR @findDate = 'Q3' OR @findDate = 'Q4')
				BEGIN
					SET @drill_term_start =	CASE WHEN @findDate='Q1' THEN  LEFT(@drill_term_start,4) + '-01-01' 
												 WHEN @findDate='Q2' THEN  LEFT(@drill_term_start,4) + '-04-01' 
												 WHEN @findDate='Q3' THEN  LEFT(@drill_term_start,4) + '-07-01' 
												 WHEN @findDate='Q4' THEN  LEFT(@drill_term_start,4) + '-10-01' 
										   END
				END
				IF(@findDate = 'st' OR @findDate = 'nd')
				BEGIN
					--SELECT @findDate
					SET @drill_term_start =	CASE WHEN @findDate='st' THEN  LEFT(@drill_term_start,4) + '-01-01' 
												 WHEN @findDate='nd' THEN  LEFT(@drill_term_start,4) + '-07-01' 
											END
				END
				
			END
			ELSE
				IF LEN(@drill_term_start)=4
				BEGIN
					SET @drill_term_end =  @drill_term_start+'-12-31'
					SET @drill_term_start  = @drill_term_start +'-01-01'
				END
		END
END TRY
BEGIN CATCH
END CATCH

--SELECT @drill_term_start AS [TERM START], @drill_term_end AS [TERM END]
--RETURN
--------------- END Extracting DATE FROM DRILL DOWN OF PLOT -------------------------------------------------------------

	--################## for batch process

	SET @str_batch_table=''
	 
		IF @batch_process_id is not null      
			SELECT @str_batch_table=dbo.FNABatchProcess('s',@batch_process_id,@batch_report_param,NULL,NULL,NULL)         
	
	--###################

--	declare @s varchar(8000)
--	select @s = coalesce(@s + ',','') + Item
--	from FNASplitWithApstrophe (@generator_group_name)

BEGIN
	--**** START Creating Temporary table to store 3 levels of Book Structure ****---
	CREATE TABLE #tmpBookDetails(                      
		fas_book_id int,            
		stra_book_id int,            
		sub_entity_id int            
		)            
	--DELETE FROM tmpBookDetails
	SET @Sql_tmpBookWhere=''
	SET @Sql_tmpBookSelect=            
		'INSERT INTO #tmpBookDetails            
			SELECT                      
				book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
			FROM portfolio_hierarchy book (nolock) INNER JOIN Portfolio_hierarchy stra (nolock)            
			ON book.parent_entity_id = stra.entity_id            
            WHERE 1=1 '            
			IF @sub_entity_id IS NOT NULL            
				SET @Sql_tmpBookWhere = @Sql_tmpBookWhere + ' AND stra.parent_entity_id IN('+ @sub_entity_id + ')'             
			IF @strategy_entity_id IS NOT NULL            
				SET @Sql_tmpBookWhere = @Sql_tmpBookWhere + ' AND (stra.entity_id IN('+ @strategy_entity_id + '))'            
			IF @book_entity_id IS NOT NULL            
				SET @Sql_tmpBookWhere = @Sql_tmpBookWhere + ' AND (book.entity_id IN('+ @book_entity_id + '))'            
				SET @Sql_tmpBookSelect=@Sql_tmpBookSelect+@Sql_tmpBookWhere    
	
	--PRINT (@Sql_tmpBookSelect)
	EXEC (@Sql_tmpBookSelect)            
	--SELECT * FROM #tmpBookDetails  
	--**** END Creating Temporary table to store 3 levels of Book Structure ****---

	--**** START Creating Temporary table to store LIMIT DATA ****---

		CREATE TABLE #tmpSourceLimit(
			input_limit_id int IDENTITY(1,1) NOT NULL,
			source_generator_id int NULL,
			criteria_id int NULL,
			curve_id int NULL,
			uom_id int NULL,
			series_value_id int NULL,
			lower_limit_value float NULL,
			upper_limit_value float NULL,
		)
		INSERT INTO #tmpSourceLimit( 
			[source_generator_id],[criteria_id],[curve_id],
			[uom_id],[series_value_id],[lower_limit_value],[upper_limit_value]
		)
		SELECT source_generator_id, criteria_id,curve_id
			,uom_id,series_value_id,lower_limit_value,upper_limit_value
		FROM ems_source_input_limit WHERE source_generator_id IS NOT NULL
		
		DECLARE @criteria_id_temp int, @curve_id_temp int, @uom_id_temp int, @series_value_id_temp int
		DECLARE @lower_limit_value_temp float, @upper_limit_value_temp float
		DECLARE @id int,@minid int
		DECLARE @sql_lmt_ip varchar(MAX)

		SELECT @id=MIN(input_limit_id) FROM ems_source_input_limit WHERE source_generator_id is null
		SET @minid=@id

		WHILE @minid IS NOT NULL
		BEGIN
			INSERT INTO #tmpSourceLimit(source_generator_id)
			SELECT generator_id from rec_generator

			SET @criteria_id_temp = (SELECT criteria_id FROM ems_source_input_limit WHERE input_limit_id = @minid)
			SET @curve_id_temp = (SELECT curve_id FROM ems_source_input_limit WHERE input_limit_id = @minid)
			SET @uom_id_temp = (SELECT uom_id FROM ems_source_input_limit WHERE input_limit_id = @minid)
			SET @series_value_id_temp = (SELECT series_value_id FROM ems_source_input_limit WHERE input_limit_id = @minid)
			SET @lower_limit_value_temp = (SELECT lower_limit_value FROM ems_source_input_limit WHERE input_limit_id = @minid)
			SET @upper_limit_value_temp = (SELECT upper_limit_value FROM ems_source_input_limit WHERE input_limit_id = @minid)

			SET @sql_lmt_ip='
			UPDATE #tmpSourceLimit 
			SET
				criteria_id='+CAST(@criteria_id_temp AS VARCHAR)+',
				curve_id='+CAST(@curve_id_temp AS VARCHAR)+',
				uom_id='+CAST(@uom_id_temp AS VARCHAR)+',
				series_value_id='+CAST(@series_value_id_temp AS VARCHAR)+',
				lower_limit_value='+CAST(@lower_limit_value_temp AS VARCHAR)+',
				upper_limit_value='+CAST(@upper_limit_value_temp AS VARCHAR)+'
				WHERE criteria_id is NULL AND curve_id is NULL AND uom_id is NULL AND lower_limit_value is NULL and upper_limit_value is NULL'
			
			--PRINT @sql_lmt_ip
			EXEC(@sql_lmt_ip)

			SELECT @minid=MIN(input_limit_id) FROM ems_source_input_limit WHERE input_limit_id > @minid AND source_generator_id is null
		END
		--/* Delete Duplicate records which are not the first one  */
		;WITH CTE (source_generator_id,criteria_id,curve_id,series_value_id, DuplicateCount)
		AS
		(
			SELECT source_generator_id,criteria_id,curve_id,uom_id,
			ROW_NUMBER() OVER(PARTITION BY source_generator_id,criteria_id,curve_id,series_value_id ORDER BY input_limit_id) AS DuplicateCount
			FROM #tmpSourceLimit
		)
		DELETE FROM CTE WHERE DuplicateCount > 1
		

--		SELECT * from #tmpSourceLimit
--		SELECT * from #tmpSourceLimit WHERE curve_id=691 AND source_generator_id=403 ORDER BY input_limit_id
--		SELECT * from #tmpSourceLimit WHERE curve_id=692 AND source_generator_id=402 ORDER BY input_limit_id
		
		
	--**** END Creating Temporary table to store LIMIT DATA ****---


	--**** START Creating Temporary table to store INPUT LIMIT REPORT DATA ****---
	CREATE TABLE #tempEmsInputRpt(
		tempEmsInput_ID [int] IDENTITY(1,1) NOT NULL,
		ems_source_model_id [int] NULL,	
		ems_source_model_name [varchar](100) NULL,
		source_sink_code [varchar] (100) NULL,
		[source_sink_name] [varchar](100) NULL,
		--ems_input_id [int] NULL,
		--input_name [varchar](100) COLLATE DATABASE_DEFAULT NULL,
		--min_value [float] NULL,
		--max_value [float] NULL,
		limit_definition [varchar] (200) COLLATE DATABASE_DEFAULT NULL,
		lower_limit_value [float] NULL,
		upper_limit_value [float] NULL,
		as_of_date [datetime] NULL,
		term_start [datetime] NULL,
		--term_start [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL,
		term_end [datetime] NULL,
		curve_name [varchar](50) COLLATE DATABASE_DEFAULT NULL,
		--output_value [varchar](50) COLLATE DATABASE_DEFAULT NULL
		output_value float NULL,
		source_uom_id int NULL,
		uom_name varchar(50) COLLATE DATABASE_DEFAULT NULL,
		source_series_id int NULL,
		source_series_type varchar(50) COLLATE DATABASE_DEFAULT NULL
	)
	DECLARE @outPutVal float
	SET @outPutVal = 0.00

	SET @Sql_Stmt= 
		'INSERT INTO #tempEmsInputRpt
		 SELECT	ems_source_model.ems_source_model_id
			,ems_source_model.ems_source_model_name
			--,rec_generator.code
			,rec_generator.generator_id
			,rec_generator.[name]
			,static_data_value.code AS [Limit Definition]
			,#tmpSourceLimit.lower_limit_value
			,#tmpSourceLimit.upper_limit_value
			,ems_calc_detail_value.as_of_date
			,ems_calc_detail_value.term_start
			,ems_calc_detail_value.term_end
			,source_price_curve_def.curve_name '
			+CASE WHEN @convert_uom_id is not null THEN 
			',OutputAfterCal = 
				CASE WHEN (conv1.from_source_uom_id = ems_calc_detail_value.uom_id) AND  (conv1.to_source_uom_id IN ('+ CAST(@convert_uom_id AS VARCHAR) + ')) 
				THEN ((ems_calc_detail_value.formula_value)*ISNULL(conv1.conversion_factor,1)) ELSE ' + cast(@outPutVal as VARCHAR) + ' END '
			 ELSE ',OutputAfterCal = (ems_calc_detail_value.formula_value)*ISNULL(conv1.conversion_factor,1)' END +'
			,source_uom.source_uom_id 
			,source_uom.uom_name
			,st.value_id [Series ID]
			,st.code [Series Type]

			FROM ems_calc_detail_value
				INNER JOIN rec_generator ON rec_generator.generator_id = ems_calc_detail_value.generator_id
				INNER JOIN ems_source_model_effective ON ems_source_model_effective.generator_id = ems_calc_detail_value.generator_id
				INNER JOIN ems_source_model ON ems_source_model_effective.ems_source_model_id = ems_source_model.ems_source_model_id
				LEFT JOIN source_price_curve_def ON  ems_calc_detail_value.curve_id = source_price_curve_def.source_curve_def_id
				LEFT JOIN source_uom ON ems_calc_detail_value.uom_id = source_uom.source_uom_id
				LEFT JOIN static_data_value st ON st.value_id = ems_calc_detail_value.forecast_type
				INNER JOIN #tmpBookDetails ON #tmpBookDetails.fas_book_id = rec_generator.fas_book_id
				INNER JOIN portfolio_hierarchy ON portfolio_hierarchy.entity_id = #tmpBookDetails.fas_book_id 
				LEFT JOIN #tmpSourceLimit 
				ON ems_calc_detail_value.forecast_type = #tmpSourceLimit.series_value_id
					AND ems_calc_detail_value.curve_id = #tmpSourceLimit.curve_id
					AND ems_calc_detail_value.generator_id = #tmpSourceLimit.source_generator_id  
				INNER JOIN formula_nested ON formula_nested.formula_id = ems_calc_detail_value.formula_detail_id
					AND formula_nested.show_value_id = #tmpSourceLimit.criteria_id
				INNER JOIN static_data_value ON static_data_value.value_id = formula_nested.show_value_id
				LEFT JOIN rec_volume_unit_conversion Conv1 ON            
					 conv1.from_source_uom_id  = ems_calc_detail_value.uom_id
					 AND conv1.to_source_uom_id = '+CASE WHEN @convert_uom_id is not null then cast(@convert_uom_id as varchar) else ' ems_calc_detail_value.uom_id' end +'
					 And conv1.state_value_id is null
					 AND conv1.assignment_type_value_id is null
					 AND conv1.curve_id  IS NULL '	
--				+CASE WHEN @fuel_type is not null then
--				'LEFT JOIN formula_editor fe2 on fe2.static_value_id=ems_calc_detail_value.fuel_type_value_id'
--				else '' end
				+CASE WHEN @udf_source_sink_group is not null then
				'LEFT JOIN user_defined_group_detail udgd on udgd.rec_generator_id=rec_generator.generator_id'
				else '' end
				+CASE WHEN @ems_book_id is not null then
				' LEFT JOIN source_sink_type sst on sst.generator_id=rec_generator.generator_id
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
		' WHERE 1=1 '
				+CASE WHEN @generator_id IS NOT NULL THEN ' AND rec_generator.generator_id IN ('+ @generator_id + ')' ELSE '' END
				+CASE WHEN @curve_id IS NOT NULL THEN ' AND ems_calc_detail_value.curve_id ='+cast(@curve_id AS VARCHAR) ELSE '' END
				--+CASE WHEN @convert_uom_id IS NOT NULL THEN ' AND ems_calc_detail_value.uom_id ='+cast(@convert_uom_id AS VARCHAR) ELSE '' END
				+CASE WHEN @as_of_date IS NOT NULL THEN ' AND (ems_calc_detail_value.as_of_date) ='''+@as_of_date+'''' ELSE '' END
				+CASE WHEN @term_start IS NOT NULL THEN ' AND (ems_calc_detail_value.term_start) >='''+@term_start+'''' ELSE '' END
				+CASE WHEN @term_end IS NOT NULL THEN ' AND (ems_calc_detail_value.term_end) <='''+@term_end+'''' ELSE '' END
				+CASE WHEN @sub_entity_id IS NOT NULL THEN ' AND #tmpBookDetails.sub_entity_id IN ('+ @sub_entity_id + ')' ELSE '' END
				+CASE WHEN @strategy_entity_id IS NOT NULL THEN ' AND #tmpBookDetails.stra_book_id IN ('+ @strategy_entity_id + ')' ELSE '' END
				+CASE WHEN @book_entity_id IS NOT NULL THEN ' AND #tmpBookDetails.fas_book_id IN ('+ @book_entity_id + ')' ELSE '' END
				+CASE WHEN @generator_group_name IS NOT NULL THEN ' AND rec_generator.generator_group_name IN(SELECT item FROM SplitCommaSeperatedValues(''' + @generator_group_name + '''))' ELSE '' END
				+CASE WHEN @technology is not null THEN ' AND rec_generator.technology ='+ cast(@technology as varchar(100)) ELSE '' END
				+CASE WHEN @fuel_value_id is not null THEN ' AND rec_generator.fuel_value_id ='+ cast(@fuel_value_id as varchar(100)) ELSE '' END
				+CASE WHEN @technology_sub_type is not null then ' And rec_generator.classification_value_id='+cast(@technology_sub_type as varchar(100)) else '' end
				+CASE WHEN @fuel_type is not null then ' And ems_calc_detail_value.fuel_type_value_id='+cast(@fuel_type as varchar) else '' end
				+CASE WHEN @reduction_type is not null then ' And rec_generator.reduction_type='+cast(@reduction_type as varchar) else '' end
				+CASE WHEN @reduction_sub_type is not null then ' And rec_generator.reduction_sub_type='+cast(@reduction_sub_type as varchar) else '' end
				+CASE WHEN @udf_source_sink_group is not null then ' And udgd.user_defined_group_id='+cast(@udf_source_sink_group as varchar) else '' end
				+CASE WHEN @udf_group1 is not null then ' And rec_generator.udf_group1='+cast(@udf_group1 as varchar) else '' end
				+CASE WHEN @udf_group2 is not null then ' And rec_generator.udf_group2='+cast(@udf_group2 as varchar) else '' end
				+CASE WHEN @udf_group3 is not null then ' And rec_generator.udf_group3='+cast(@udf_group3 as varchar) else '' end
				--+CASE WHEN @drill_term_start IS NOT NULL THEN ' AND (ems_calc_detail_value.term_start) ='''+@drill_term_start+'''' ELSE '' END
				+CASE WHEN @drill_term_start IS NOT NULL THEN ' AND (ems_calc_detail_value.term_start) >='''+@drill_term_start+''' AND (ems_calc_detail_value.term_start) <='''+@drill_term_end+'''' ELSE '' END
				+CASE WHEN @drill_curve_id IS NOT NULL THEN ' AND source_price_curve_def.curve_name ='''+cast(@drill_curve_id AS VARCHAR) +'''' ELSE '' END
				+CASE WHEN @show_value_id IS NOT NULL THEN ' AND #tmpSourceLimit.criteria_id ='''+cast(@show_value_id AS VARCHAR) +'''' ELSE '' END
				+CASE WHEN @forecast_type IS NOT NULL THEN ' AND ems_calc_detail_value.forecast_type ='''+cast(@forecast_type AS VARCHAR) +'''' ELSE '' END

			--PRINT(@SQL_Stmt)
			--Return
	EXEC (@Sql_Stmt)
--**** END Creating Temporary table to store INPUT LIMIT REPORT DATA ****---
DECLARE @call_from varchar(5)

	SET @call_from = 's'
--SELECT * FROM #tempEmsInputRpt
--RETURN

	if @Plot ='n' --For Input Limit Report ONLY
		BEGIN
--			SET @Sql_LimitRpt=
--			'SELECT
--				dbo.FNAEmissionHyperlink(3,12101510,source_sink_name,source_sink_code,''"' + @call_from + '"'') AS [Source/Sink Name]
--				--[source_sink_name] AS [Source/Sink Name]
--				,ems_source_model_name AS [Source Model Name]
--				,curve_name AS [Pollutant]
--				--,dbo.fnadateformat(term_start) AS [Term]
--				,dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')[Term]
--				,limit_definition AS [Limit Definition]
--				,source_series_type AS [Series Type]
--				,output_value AS [Sample Value]
--				,ISNULL(lower_limit_value,0) AS [Lower Limit]
--				,ISNULL(upper_limit_value,0) AS [Upper Limit]
--				,uom_name AS [Unit of Measure]
--				,Violation = CASE WHEN output_value > ISNULL(upper_limit_value,0) then ''Y'' else ''N'' end	
--				'+@str_batch_table+'
--			FROM #tempEmsInputRpt 
--				ORDER BY [Source/Sink Name],[Source Model Name],[Pollutant],dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')' 			 



			SET @Sql_LimitRpt=
			'SELECT
				dbo.FNAEmissionHyperlink(3,12101510,source_sink_name,source_sink_code,''"' + @call_from + '"'') AS [Source/Sink Name]
				--[source_sink_name] AS [Source/Sink Name]
				,ems_source_model_name AS [Source Model Name]
				,curve_name AS [Pollutant]
				--,dbo.fnadateformat(term_start) AS [Term]
				,dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')[Term]
				,limit_definition AS [Limit Definition]
				,source_series_type AS [Series Type]
				,AVG(output_value) AS [Sample Value]
				,ISNULL(lower_limit_value,0) AS [Lower Limit]
				,ISNULL(upper_limit_value,0) AS [Upper Limit]
				,[Difference] = ISNULL(upper_limit_value,0) - AVG(output_value) 
				,uom_name AS [Unit of Measure]
				,Violation = CASE WHEN AVG(output_value) > ISNULL(upper_limit_value,0) then ''Y'' else ''N'' end	
				'+@str_batch_table+'
			FROM #tempEmsInputRpt 
				GROUP BY dbo.FNAEmissionHyperlink(3,12101510,source_sink_name,source_sink_code,''"' + @call_from + '"''),ems_source_model_name,curve_name,dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')
				,limit_definition,source_series_type,lower_limit_value,upper_limit_value,uom_name
				ORDER BY [Source/Sink Name],[Source Model Name],[Pollutant],dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')' 
			exec spa_print @Sql_LimitRpt
			EXEC (@Sql_LimitRpt)

		END
		Else if @Plot ='v' --Generate Exception Limit Report/drill down in Violation Count Report
			BEGIN

--				SELECT	
--					--[source_sink_name] AS [Source/Sink Name]
--					dbo.FNAEmissionHyperlink(3,12101510,source_sink_name,source_sink_code,'"' + @call_from + '"') AS [Source/Sink Name]
--					,ems_source_model_name AS [Source Model Name]
--					,curve_name AS [Pollutant]
--					--,dbo.fnadateformat(term_start) AS [Term]
--					,dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))[Term]
--					,limit_definition AS [Limit Definition]
--					,source_series_type AS [Series Type]
--					,output_value AS [Sample Value]
--					,ISNULL(lower_limit_value,0) AS [Lower Limit]
--					,ISNULL(upper_limit_value,0) AS [Upper Limit]
--					,uom_name AS [Unit of Measure]
--					,Violation = CASE WHEN output_value > ISNULL(upper_limit_value,0) then 'Y' else 'N' end	
--				FROM #tempEmsInputRpt
--				WHERE output_value > ISNULL(upper_limit_value,0)
--				ORDER BY [Source/Sink Name],[Source Model Name],[Pollutant],dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))
			
				SELECT	
					--[source_sink_name] AS [Source/Sink Name]
					dbo.FNAEmissionHyperlink(3,12101510,source_sink_name,source_sink_code,'"' + @call_from + '"') AS [Source/Sink Name]
					,ems_source_model_name AS [Source Model Name]
					,curve_name AS [Pollutant]
					--,dbo.fnadateformat(term_start) AS [Term]
					,dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))[Term]
					,limit_definition AS [Limit Definition]
					,source_series_type AS [Series Type]
					,AVG(output_value) AS [Sample Value]
					,ISNULL(lower_limit_value,0) AS [Lower Limit]
					,ISNULL(upper_limit_value,0) AS [Upper Limit]
					,[Difference] = ISNULL(upper_limit_value,0) - AVG(output_value)
					,uom_name AS [Unit of Measure]
					,Violation = CASE WHEN AVG(output_value) > ISNULL(upper_limit_value,0) then 'Y' else 'N' end	
				FROM #tempEmsInputRpt
				GROUP BY source_sink_name,source_sink_code,ems_source_model_name,curve_name
				,dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar)),limit_definition,source_series_type,lower_limit_value,upper_limit_value,uom_name
				HAVING AVG(output_value) > ISNULL(upper_limit_value,0)
				ORDER BY [Source/Sink Name],[Source Model Name],[Pollutant],dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))
		END
	ELSE if @Plot ='h' -- Report in HTML Format illustrating Violation Vs Pollutant
		BEGIN
			
			DECLARE @curve_name1 VARCHAR(5000)
			DECLARE @curve_nameIN1 VARCHAR(5000)
			DECLARE @curve_name_SUM VARCHAR(5000)
			-- Stuff Pollutant in the format of NULLIF([curve_name_a],0) [curve_name_a], NULLIF([curve_name_b],0)[curve_name_b]... to dyanamically use in Pivot Sql stmt below
			SELECT @curve_name1=  
				STUFF(( SELECT DISTINCT ', NULLIF(SUM([' + ltrim(curve_name) + ']),0)[' + ltrim(curve_name) +']'
							FROM    #tempEmsInputRpt
							 FOR XML PATH('')), 1, 2, '')  
			
			-- Stuff Pollutant in the format of [curve_name_a], [curve_name_b],... to dyanamically use in Pivot Sql stmt below
			SELECT @curve_nameIN1=
			STUFF(( SELECT DISTINCT '],[' + ltrim(curve_name)
							FROM    #tempEmsInputRpt
							ORDER BY '],[' + ltrim(curve_name) FOR XML PATH('')), 1, 2, '') + ']'

			
			SELECT @curve_name_SUM=  
				STUFF(( SELECT DISTINCT '+ ISNULL(SUM([' + ltrim(curve_name) + ']),0)'
							FROM    #tempEmsInputRpt
							 FOR XML PATH('')), 1, 2, '')  


			--SELECT @curve_name1
			--SELECT @curve_nameIN1
--			SELECT @curve_name_SUM
--			RETURN 
			
			if (@curve_nameIN1 is null)
			BEGIN
				set @curve_nameIN1='[No Pollutant Exists]'
				set @curve_name1='MAX([No Pollutant Exists]) as [No Pollutant Exists]'
				
			END

			BEGIN -- PIVOT is used to convert Pollutants from Rows to Coloumns 
				
					SET @Sql_ViolationRpt=
					'SELECT	
						
						dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')[Term Start],'+ @curve_name1 + ', ' + @curve_name_SUM + '[Violation Count]' + @str_batch_table +'
					FROM
						(SELECT AVG(output_value) output_value,curve_name, term_start FROM #tempEmsInputRpt 
							GROUP BY curve_name, term_start
							HAVING AVG(output_value) > ISNULL(MAX(upper_limit_value),0)) AS SourceTable
						PIVOT
						(
							COUNT(output_value) FOR curve_name IN ('+@curve_nameIN1+')
						 ) AS PivotTable GROUP BY dbo.FNATermGrouping(PivotTable.term_start,'+cast(@period_frequency as varchar)+')' 

						if  @Sql_ViolationRpt is null
						BEGIN
							SELECT @Sql_ViolationRpt as [No Pollutant Exists]
							RETURN
						END
					exec spa_print @Sql_ViolationRpt
					EXEC(@Sql_ViolationRpt)
			END
	END
	ELSE if @Plot ='l' -- Report in Line Graph to illustrate Sample Value Vs. Upper/Lower Limit 
		BEGIN
--			SELECT	
--				--dbo.fnadateformat(term_start) AS [Term Start]
--				dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))[Term Start]
--				,ISNULL(lower_limit_value,0) AS [Lower Limit]
--				,ISNULL(upper_limit_value,0) AS [Upper Limit]
--				,output_value AS [Sample Value]
--				,uom_name AS [Unit of Measure]
--				 FROM #tempEmsInputRpt ORDER BY CAST(term_start AS DATETIME)

			SELECT	
				--dbo.fnadateformat(term_start) AS [Term Start]
				dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))[Term Start]
				,ISNULL(lower_limit_value,0) AS [Lower Limit]
				,ISNULL(upper_limit_value,0) AS [Upper Limit]
				,AVG(output_value) AS [Sample Value]
				,uom_name AS [Unit of Measure]
				 FROM #tempEmsInputRpt 
				 GROUP BY dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar)),ISNULL(lower_limit_value,0),ISNULL(upper_limit_value,0),uom_name
				 ORDER BY dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))

		END

	ELSE if @Plot ='e' -- Report in Line Graph to illustrate Exceptional Limit Graph - Sample Value Vs. Upper/Lower Limit 
		BEGIN
--			SELECT	
--				--dbo.fnadateformat(term_start) AS [Term Start]
--				dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))[Term Start]
--				,ISNULL(lower_limit_value,0) AS [Lower Limit]
--				,ISNULL(upper_limit_value,0) AS [Upper Limit]
--				,output_value AS [Sample Value]
--				,uom_name AS [Unit of Measure]
--				 FROM #tempEmsInputRpt WHERE output_value > ISNULL(upper_limit_value,0) ORDER BY CAST(term_start AS DATETIME)
			SELECT	
				--dbo.fnadateformat(term_start) AS [Term Start]
				dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))[Term Start]
				,ISNULL(lower_limit_value,0) AS [Lower Limit]
				,ISNULL(upper_limit_value,0) AS [Upper Limit]
				,AVG(output_value) AS [Sample Value]
				,uom_name AS [Unit of Measure]
				 FROM #tempEmsInputRpt 
				GROUP BY dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar)),ISNULL(lower_limit_value,0),ISNULL(upper_limit_value,0),uom_name
				HAVING AVG(output_value) > ISNULL(upper_limit_value,0) 
				ORDER BY dbo.FNATermGrouping(term_start,cast(@period_frequency as varchar))


		END
	
	ELSE if @Plot ='b' -- Report in BAR CHART illustrating Violation Vs Pollutant
		BEGIN
			
			DECLARE @curve_name VARCHAR(5000)
			DECLARE @curve_nameIN VARCHAR(5000)
			-- Stuff Pollutant in the format of NULLIF([curve_name_a],0) [curve_name_a], NULLIF([curve_name_b],0)[curve_name_b]... to dyanamically use in Pivot Sql stmt below
			SELECT @curve_name=  
				STUFF(( SELECT DISTINCT ', NULLIF(SUM([' + ltrim(curve_name) + ']),0)[' + ltrim(curve_name) +']'
							FROM    #tempEmsInputRpt
							 FOR XML PATH('')), 1, 2, '')  
			
			-- Stuff Pollutant in the format of [curve_name_a], [curve_name_b],... to dyanamically use in Pivot Sql stmt below
			SELECT @curve_nameIN=
			STUFF(( SELECT DISTINCT '],[' + ltrim(curve_name)
							FROM    #tempEmsInputRpt
							ORDER BY '],[' + ltrim(curve_name) FOR XML PATH('')), 1, 2, '') + ']'
			
			if (@curve_nameIN is null)
			BEGIN
				set @curve_nameIN='[No Pollutant Exists]'
				set @curve_name='MAX([No Pollutant Exists]) as [No Pollutant Exists]'
			END

			BEGIN -- PIVOT is used to convert Pollutants from Rows to Coloumns 
--					SET @Sql_Pivot=
--					'SELECT	
--						--dbo.fnadateformat(term_start)AS [Term_Start],'+ @curve_name + ',''Count'' As [UOM] '+@str_batch_table +'
--						dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')[Term Start],'+ @curve_name + ',''Count'' As [UOM] '+@str_batch_table +'
--					FROM
--						(SELECT output_value,curve_name ,term_start FROM #tempEmsInputRpt WHERE output_value >
--						 ISNULL(upper_limit_value,0)) AS SourceTable
--						PIVOT
--						(
--							COUNT(output_value) FOR curve_name IN ('+@curve_nameIN+')
--						 ) AS PivotTable ORDER BY CAST(PivotTable.term_start AS DATETIME)'




					SET @Sql_Pivot=
					'SELECT	
						--dbo.fnadateformat(term_start)AS [Term_Start],'+ @curve_name + ',''Count'' As [UOM] '+@str_batch_table +'
						dbo.FNATermGrouping(term_start,'+cast(@period_frequency as varchar)+')[Term Start],'+ @curve_name + ',''Count'' As [UOM] '+@str_batch_table +'
					FROM
						(SELECT AVG(output_value) output_value,curve_name ,term_start FROM #tempEmsInputRpt 
							GROUP BY curve_name ,term_start
							HAVING AVG(output_value) > ISNULL(MAX(upper_limit_value),0)) AS SourceTable
						PIVOT
						(
							COUNT(output_value) FOR curve_name IN ('+@curve_nameIN+')
						 ) AS PivotTable GROUP BY dbo.FNATermGrouping(PivotTable.term_start,'+cast(@period_frequency as varchar)+')'

					--Print (@Sql_Pivot)
					EXEC(@Sql_Pivot)
			END
		END


		--*****************FOR BATCH PROCESSING**********************************            
 		IF  @batch_process_id is not null        
		BEGIN
			declare @report_name varchar(100)        	

			if @Plot='n'
			BEGIN
				set @report_name='Emission Limit Report'
			END        
			if @Plot='h'	
			BEGIN
				set @report_name='Limit Violation Count Report'
			END
			if @Plot='v'
			BEGIN
				set @report_name='Exception Limit Report'
			END

			SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)         
			EXEC(@str_batch_table)        
			
			SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_get_emmission_input_report',@report_name)         
			EXEC(@str_batch_table) 

		END        
		--********************************************************************  



END


















