
IF OBJECT_ID(N'[dbo].[spa_run_forecast_model]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_forecast_model]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 

--EXEC spa_run_forecastmodel  @forecast_model_id = 4,@forecast_mapping_id=1011,@as_of_date = '2016-01-01'
CREATE PROCEDURE [dbo].[spa_run_forecast_model]
	 @forecast_mapping_id INT 
	 ,@as_of_date VARCHAR(12)
	 ,@process_table_name VARCHAR(250) OUTPUT
	 ,@columlist_data VARCHAR(5000) OUTPUT
	 ,@neural_network VARCHAR(350) OUTPUT
AS
SET NOCOUNT ON
/*
	
	DECLARE @forecast_mapping_id INT 
	DECLARE @as_of_date VARCHAR(12)
	SELECT @forecast_mapping_id=1032,@as_of_date = '7/31/2016'--'2/29/2016' -- '11/21/2016' -- '
	DECLARE @process_table_name VARCHAR(250)
	DECLARE @columlist_data VARCHAR(5000)
	,@neural_network VARCHAR(350)
--*/

DECLARE @granularity VARCHAR(1)
DECLARE @date_from DATETIME
DECLARE @date_to  DATETIME
DECLARE @train_date DATETIME
DECLARE @process_table VARCHAR(250)
DECLARE @process_id VARCHAR(250) 
DECLARE @user_name VARCHAR(250)
DECLARE @column_list VARCHAR(5000)
DECLARE @dynamic_column VARCHAR(2500)
DECLARE @sql VARCHAR(MAX)
DECLARE @delete_field VARCHAR(MAX)
DECLARE @delete_count INT 
DECLARE @del_sql NVARCHAR(MAX)
SELECT @process_id = dbo.FNAGetNewID()
SELECT @user_name = dbo.FNADBUser()
SELECT @process_table = dbo.FNAProcessTableName('run_forecast',@user_name,@process_id)
SELECT @neural_network = dbo.FNAProcessTableName('neural_network',@user_name,@process_id)
DECLARE @forecast_model_id INT
DECLARE @ParmDefinition NVARCHAR(500)
DECLARE @desc VARCHAR(100)
DECLARE @start_date datetime
DECLARE @end_date datetime
DECLARE @peak_offpeak INT
DECLARE @block_value_id INT
SELECT @forecast_model_id = forecast_model_id FROM forecast_mapping WHERE forecast_mapping_id = @forecast_mapping_id
DECLARE @dividend INT 
DECLARE @output INT
--SELECT @process_table = '[adiha_process].[dbo].[run_forecast_hourly_pamatya_046B6E59_B4F2_487A_9412_186ED5257BE8]'
BEGIN TRY
	IF OBJECT_ID('tempdb..#forecast_model') IS NOT NULL
		DROP TABLE #forecast_model
	IF OBJECT_ID('tempdb..#neural_network') IS NOT NULL
		DROP TABLE #neural_network
	IF OBJECT_ID('tempdb..#term_break1') IS NOT NULL
		DROP TABLE #term_break1
	IF OBJECT_ID('tempdb..#term_break') IS NOT NULL
		DROP TABLE #term_break
	IF OBJECT_ID('tempdb..#forecast_columnlist') IS NOT NULL
		DROP TABLE #forecast_columnlist
	IF OBJECT_ID('tempdb..#week') IS NOT NULL 
		DROP TABLE #week
	IF OBJECT_ID('tempdb..#holidays') IS NOT NULL
		DROP TABLE #holidays
	IF OBJECT_ID('tempdb..#data_range') IS NOT NULL
		DROP TABLE #data_range
	IF OBJECT_ID('tempdb..#input_curve') IS NOT NULL
		DROP TABLE #input_curve
	IF OBJECT_ID('tempdb..#input_curve1') IS NOT NULL
		DROP TABLE #input_curve1
	IF OBJECT_ID('tempdb..#load_data') IS NOT NULL
		DROP TABLE #load_data
	IF OBJECT_ID('tempdb..#unpivot_load_data') IS NOT NULL
		DROP TABLE #unpivot_load_data
	IF OBJECT_ID('tempdb..#time_series_forecast') IS NOT NULL
		DROP TABLE #time_series_forecast
	IF OBJECT_ID('tempdb..#pivot_time_series') IS NOT NULL
		DROP TABLE #pivot_time_series
	IF OBJECT_ID('tempdb..#peak_offpeak') IS NOT NULL
		DROP TABLE #peak_offpeak
	IF OBJECT_ID('tempdb..#dividend') IS NOT NULL
			DROP TABLE #dividend
	IF OBJECT_ID('tempdb..#load_data1') IS NOT NULL
			DROP TABLE #load_data1
	
	SELECT forecast_model_id
		,forecast_model_name
		,forecast_type
		,sdv_ft.code forecast_type_name
		,forecast_category
		,sdv_fc.code forecast_category_name
		,forecast_granularity
		,sdv_fg.code granularity
		, CASE WHEN forecast_granularity = 989 THEN 't'  --thirtyMin
	   WHEN forecast_granularity = 987 THEN 'f' -- fifteenMin
	   WHEN forecast_granularity = 994 THEN 'n' --tenmin
	   WHEN forecast_granularity = 995 THEN 'v' -- five minute
	   ELSE  LOWER(LEFT(sdv_fg.code,1))+LOWER(LEFT(sdv_fg.code,1)) END  granularity_list
	INTO #forecast_model
	FROM forecast_model fm
	INNER JOIN static_data_value sdv_ft ON fm.forecast_type = sdv_ft.value_id
	INNER JOIN static_data_value sdv_fc ON fm.forecast_category = sdv_fc.value_id
	INNER JOIN static_data_value sdv_fg ON fm.forecast_granularity = sdv_fg.value_id
	WHERE fm.forecast_model_id = @forecast_model_id
	
	
	SELECT f.forecast_mapping_datarange_id
		,forecast_mapping_id
		,forecast_mapping_data_type
		,sdv.code data_type
		,granularity
		,sdv1.code granularity_name
		,f.value
	INTO #data_range
	FROM forecast_mapping_datarange f
	INNER JOIN Static_data_value sdv ON sdv.value_id = f.forecast_mapping_data_type
	INNER JOIN Static_data_value sdv1 ON sdv1.value_id = f.granularity
	WHERE f.forecast_mapping_id =@forecast_mapping_id
	
	IF EXISTS(SELECT 1 FROM #data_range)
	BEGIN
		SELECT @date_from =   CASE WHEN granularity = 980 THEN DATEADD(MM,-1*(CAST(f.value AS INT)),@as_of_date)  -- Monthly
								WHEN granularity = 981 THEN DATEADD(dd,-1*(CAST(f.value AS INT)-1),@as_of_date) -- daily
								--WHEN granularity = 982 THEN DATEADD(HH,-1*(CAST(f.value AS INT)-1),@as_of_date) -- hourly
								--WHEN granularity = 987 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) --15min
								--WHEN granularity = 989 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) --30Min
								--WHEN granularity = 990 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) --Weekly
								--WHEN granularity = 991 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) --Quarterly
								--WHEN granularity = 992 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) --Semi Annually
								WHEN granularity = 993 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) -- Annually
								--WHEN granularity = 994 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) -- 10 minutes
								--WHEN granularity = 995 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) -- 5 minutes
								ELSE '' END 
		FROM #data_range f WHERE  forecast_mapping_data_type = 44203

		SELECT @date_to =	CASE WHEN granularity = 980 THEN DATEADD(MM,1*(CAST(f.value AS INT)),@as_of_date) 
								WHEN granularity = 981 THEN DATEADD(dd,1*(CAST(f.value AS INT)),@as_of_date)
								--WHEN granularity = 982 THEN DATEADD(HH,1*(CAST(f.value AS INT)),@as_of_date)
								WHEN granularity = 993 THEN DATEADD(YY,-1*(CAST(f.value AS INT)),@as_of_date) -- Annually
								ELSE '' END  
				FROM #data_range f WHERE  forecast_mapping_data_type = 44202

		SELECT @train_date =  CASE WHEN granularity = 980 THEN DATEADD(MM,-1*(CAST(f.value AS INT)),@as_of_date) 
								WHEN granularity = 981 THEN DATEADD(dd,-1*(CAST(f.value AS INT)-1),@as_of_date)
								--WHEN granularity = 982 THEN DATEADD(HH,-1*(CAST(f.value AS INT)-1),@as_of_date)
								WHEN granularity = 993 THEN DATEADD(YY,-1*(CAST(f.value AS INT)-1),@as_of_date) -- Annually
								ELSE '' END  FROM #data_range f WHERE  forecast_mapping_data_type = 44204
					
	END
	ELSE 
	BEGIN
		EXEC spa_ErrorHandler 0
				, 'spa_run_forecastmodel'
				, 'spa_run_forecastmodel'
				, 'Success'
				, 'Data Range cannot be empty'
				, ''
		RETURN
	END
	
	
	EXEC('SELECT threshold
			,maximum_step
			,learning_rate
			,repetition
			,hidden_layer
			,algorithm [algorithm_id]
			,sdv.code [algorithm]
			, error_function [ error_function_id]
			,sdv1.code error_function
		INTO '+ @neural_network +
		' FROM forecast_model fm 
		LEFT JOIN static_data_value sdv ON sdv.value_id = fm.algorithm --AND sdv.type_id = 46100
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = fm.error_function AND sdv1.type_id = 46100
		WHERE fm.forecast_model_id = '+@forecast_model_id)

EXEC('IF NOT EXISTS(SELECT 1 FROM '+@neural_network+')
	BEGIN
		EXEC spa_ErrorHandler 0
				, ''spa_run_forecastmodel''
				, ''spa_run_forecastmodel''
				, ''Success''
				, ''Neural network parameters cannot be empty''
				, ''''
		RETURN
	END')
	
	

DECLARE @gran_forecast INT 
SELECT @gran_forecast = forecast_granularity FROM #forecast_model
	SELECT @granularity =  granularity_list FROM #forecast_model
	IF @granularity = 'h'
		SELECT @date_to = DATEADD(hh,23,@date_to)
	IF @granularity = 'm'
		BEGIN
			SELECT @date_from =  [dbo].[FNAGetNextFirstDate](@date_from,@gran_forecast)--[dbo].[FNAGetFirstLastDayOfMonth](@date_from,'f')
			SELECT @date_to =  [dbo].[FNAGetFirstLastDayOfMonth](@date_to,'l')
		END
	IF @granularity = 'y'
		BEGIN
			SELECT @date_from  = CAST(CAST(Year(@date_from) as varchar(4)) +'-01-01' AS Datetime)
			SELECT @date_to  = CAST(CAST(Year(@date_to) as varchar(4)) +'-12-31' AS Datetime)
		END

		SELECT @dividend = CASE WHEN @granularity = 't' THEN 2
						WHEN @granularity = 'f' THEN 4 
						WHEN @granularity = 'n' THEN 6
						WHEN @granularity = 'v' THEN 12
						WHEN @granularity = 'h' THEN 24
						ELSE 1 END	
--Term_breakdown

SELECT @output = forecast_type FROM #forecast_model WHERE forecast_model_id = @forecast_model_id

IF @granularity = 'f' 
BEGIN
	SELECT	@date_to = DATEADD(hour,23,@date_to)
	SELECT @date_to = DATEADD(n,45,@date_to)

END
IF @granularity = 't' 
BEGIN
	SELECT	@date_to = DATEADD(hour,23,@date_to)	
	SELECT @date_to = DATEADD(n,30,@date_to)
END
IF @granularity = 'n' 
BEGIN
	SELECT	@date_to = DATEADD(hour,23,@date_to)
	SELECT	@date_to = DATEADD(mi,40,@date_to)
END
IF @granularity = 'v' 
BEGIN
	SELECT	@date_to = DATEADD(hour,23,@date_to)
	SELECT	@date_to = DATEADD(mi,50,@date_to)
END	

	SELECT *
	INTO #term_break1
	FROM dbo.FNATermBreakdown(@granularity, @date_from, @date_to)


	SELECT term_start
		,term_end
		,DATEPART(Year, term_start) year
		,DATEPART(MONTH,term_start) Month
		,DATEPART(day, term_start) day
		,DATEPART(hour, term_start) hour
		,DATEPART(mi, term_start) period
		,insert_delete
		,0 is_DST
	INTO #term_break
	FROM #term_break1 tb
	LEFT JOIN mv90_dst ON CAST(DATE AS DATE) = CAST(tb.term_start AS DATE)
	
	
	INSERT INTO #term_break(term_start,term_end,year,month,day,hour,insert_delete,is_dst)
	SELECT term_start,term_end,year,month,day,hour,insert_delete, 1 FROM #term_break WHERE insert_delete = 'i' and DATEPART(hour,term_start)=3
	
	DELETE
	FROM #term_break WHERE insert_delete = 'd' and DATEPART(hour,term_start)=3
	
	SELECT @start_date = MIN(term_start),@end_date = MAX(term_end) FROM #term_break
	
	SELECT fm.forecast_model_id
		,fmi1.forecast_mapping_input_id
		,fmi.forecast_model_input_id
		,fm.granularity_list
		,fmi.series_type
		,sdv.code series_typename
		,fmi.series
		,REPLACE(coalesce(sdv1.code,tsd.time_series_NAME,sdv.code),' ','_') series_name
		,fm1.forecast_mapping_id
		,fm1.output_id
		,fmi1.input
		,fmi1.forecast
		,fmi.formula
		,fmi.output_series
		,tsd1.time_series_name series_name_forward
		,input_function
		,forecast_function
		,fm1.source_id
		,fm1.approval_required
	INTO #forecast_columnlist
	FROM #forecast_model fm
	INNER JOIN forecast_mapping fm1 ON fm1.forecast_model_id = fm.forecast_model_id AND fm1.forecast_mapping_id = @forecast_mapping_id
	INNER JOIN forecast_model_input fmi ON fmi.forecast_model_id = fm.forecast_model_id
	INNER JOIN forecast_mapping_input fmi1 ON fmi1.forecast_mapping_id = fm1.forecast_mapping_id
		AND fmi.forecast_model_input_id = fmi1.forecast_model_input_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = fmi.series_type
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = fmi.series AND sdv1.type_id = 44100
	LEFT JOIN time_series_definition tsd ON tsd.time_series_definition_id =  fmi.series
	LEFT JOIN time_series_definition tsd1 ON tsd1.time_series_definition_id = fmi.output_series
	WHERE use_in_model = 1 
	ORDER BY s_order
	
	SELECT @peak_offpeak = input  FROM #forecast_columnlist WHERE series_type =44105
	
	IF ISNULL(@peak_offpeak,0) <>0  
	BEGIN 
		SELECT block_value_id,week_day,onpeak_offpeak,load_input,RIGHT(load_value,LEN(load_value)-2) hr 
		INTO #peak_offpeak
		 FROM (
					SELECT block_value_id,week_day,onpeak_offpeak
						,Hr1
						,Hr2
						,Hr3
						,Hr4
						,Hr5
						,Hr6
						,Hr7
						,Hr8
						,Hr9
						,Hr10
						,Hr11
						,Hr12
						,Hr13
						,Hr14
						,Hr15
						,Hr16
						,Hr17
						,Hr18
						,Hr19
						,Hr20
						,Hr21
						,Hr22
						,Hr23
						,Hr24
					FROM hourly_block WHERE block_value_id = @peak_offpeak ) p
				UNPIVOT
				   (Load_input FOR load_value IN (Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24 )
				)AS unpvt
				WHERE Load_input = 1 
	END


	
	SET @column_list = 'CREATE TABLE '+@process_table + '('

	IF @granularity = 'h' OR  @granularity = 'f' OR @granularity = 't' OR @granularity = 'n' OR @granularity = 'v'
	BEGIN
		SET @column_list = @column_list +' is_dst INT,'
	END
	SET @column_list  = @column_list +' output_type char(1),termstart DATETIME,YEAR INT'--, Month INT,Day INT,hour INT,'
	IF @granularity = 'm' OR @granularity = 'd' OR @granularity = 'h' OR  @granularity = 'f' OR @granularity = 't' OR @granularity = 'n' OR @granularity = 'v'
	BEGIN
		SET @column_list = @column_list +' ,Month INT'
	END
	IF @granularity = 'd' OR @granularity = 'h' OR  @granularity = 'f' OR @granularity = 't' OR @granularity = 'n' OR @granularity = 'v'
	BEGIN
		SET @column_list = @column_list +' ,Day INT'
	END 
	IF @granularity = 'h' OR  @granularity = 'f' OR @granularity = 't' OR @granularity = 'n' OR @granularity = 'v'
	BEGIN
		SET @column_list = @column_list +' ,hour INT'
	END
	IF @granularity = 'f' OR @granularity = 't' OR @granularity = 'n' OR @granularity = 'v'
	BEGIN
		SET @column_list = @column_list +' ,period INT'
	END

	ALTER TABLE #forecast_columnlist
	ALTER column formula VARCHAR(500)

	SELECT  @dynamic_column = STUFF((SELECT  REPLACE(series_name,' ','') + CASE WHEN formula IS NOT NULL THEN  '_'+REPLACE(formula,'-','d') ELSE '' END + ' ,'  FROM #forecast_columnlist WHERE series_type <> 44105  FOR xml PATH ('')),1,0,'') 
	SELECT @dynamic_column = REPLACE(@dynamic_column,',',' numeric(38,20),')
	SELECT @column_list = @column_list+' , '+ @dynamic_column
	SELECT @columlist_data=	@dynamic_column
	SELECT @columlist_data = REPLACE(@columlist_data,' numeric(38,20),',',')
	SELECT @column_list = LEFT(@column_list,LEN(@column_list)-1)
	--EXEC('DROP TABLE '+@process_table)


	EXEC(@column_list+')')
	
		ALTER TABLE #term_break
		ADD  curve INT
	 
	 	ALTER TABLE #term_break
		ADD  time_series INT

		ALTER TABLE #term_break
		ADD  curve_granularity INT

		ALTER TABLE #term_break
		ADD  timeseries_granularity INT

		ALTER TABLE #term_break
		ADD output_type CHAR(1)

		UPDATE #term_break
			SET output_type = CASE 
				WHEN CAST(term_start  AS DATE)> @as_of_date
					AND CAST(term_start  AS DATE) <= @date_to
					THEN 'f'
				WHEN CAST(term_start  AS DATE) >= @train_date
					THEN 't'
				ELSE 'r'
				END
			
--'f' = forcast data 
--'t' = train data
--'r' = regular data
DECLARE @granularity_column VARCHAR(2000) =''

SET @sql = 'INSERT INTO ' + @process_table + '('
	IF @granularity = 'h'
		OR @granularity = 'f'
		OR @granularity = 't'
		OR @granularity = 'n'
		OR @granularity = 'v'
	BEGIN
		SET @sql = @sql + ' is_dst, '
	END
SET @sql = @sql + 'output_type,termstart,year'

	IF @granularity = 'm'
		OR @granularity = 'd'
		OR @granularity = 'h'
		OR @granularity = 'f'
		OR @granularity = 't'
		OR @granularity = 'n'
		OR @granularity = 'v'
	BEGIN
		SET @granularity_column = @granularity_column + ' ,Month '
	END

	IF @granularity = 'd'
		OR @granularity = 'h'
		OR @granularity = 'f'
		OR @granularity = 't'
		OR @granularity = 'n'
		OR @granularity = 'v'
	BEGIN
		SET @granularity_column = @granularity_column + ' ,Day '
	END

	IF @granularity = 'h'
		OR @granularity = 'f'
		OR @granularity = 't'
		OR @granularity = 'n'
		OR @granularity = 'v'
	BEGIN
		SET @granularity_column = @granularity_column + ' ,hour '
	END

	IF @granularity = 'f'
		OR @granularity = 't'
		OR @granularity = 'n'
		OR @granularity = 'v'
	BEGIN
		SET @granularity_column = @granularity_column + ' ,period '
	END

	SET @sql = @sql + @granularity_column + ') SELECT '
	IF @granularity = 'h'
		OR @granularity = 'f'
		OR @granularity = 't'
		OR @granularity = 'n'
		OR @granularity = 'v'
	BEGIN
		SET @sql = @sql + ' is_dst, '
	END

	SET @sql = @sql+'output_type,
						CAST(t.term_start as DATETIME),
						 [year] '
	SET @sql = @sql + @granularity_column + ' FROM #term_break t Order by term_start'
	----PRINT(@sql)
	EXEC (@sql)
	
		DECLARE 
			@forecast_model_id1 INT
			,@series_type INT
			,@series INT
			,@input VARCHAR(200)
			,@forecast VARCHAR(200)
			,@out VARCHAR(100)
			,@formula VARCHAR(100)
			,@holiday_type INT
			,@granularity_list VARCHAR(10)
			,@input_function VARCHAR(50)
			,@forecast_function VARCHAR(50)
			,@forecast_model_input_id INT
			,@source_id INT
			,@output_series INT
		DECLARE db_cursor CURSOR
		FOR
		SELECT forecast_model_id
			,series_type
			,series
			,input
			,forecast
			,output_id
			,formula
			,granularity_list
			,ISNULL(NULLIF(sdv.Code,'NULL'),' ')
			,ISNULL(NULLIF(sdv1.Code,'NULL'),' ')
			,forecast_model_input_id
			,source_id
			,output_series
			FROM #forecast_columnlist fc 
			LEFT JOIN static_data_value sdv ON sdv.value_id = fc.input_function AND sdv.type_id = 46400
			LEFT JOIN static_data_value sdv1 ON sdv1.value_id = fc.forecast_function AND sdv.type_id = 46400
			WHERE series_type <> 44105-- AND series_type = 44004
			ORDER BY 1 desc
		OPEN db_cursor
		FETCH NEXT
		FROM db_cursor
		INTO @forecast_model_id1
			,@series_type
			,@series
			,@input
			,@forecast
			,@out
			,@formula
			,@granularity_list
			,@input_function
			,@forecast_function
			,@forecast_model_input_id
			,@source_id
			,@output_series 
			
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		IF @series_type = 44001
			BEGIN	
				IF @series = 44101 -- WEEKEND
				BEGIN
					SET @sql = 'UPDATE a SET a.weekday =  DATEPART(DW,t.term_start) FROM #term_break t INNER JOIN ' + @process_table + ' a ON a.termstart = t.term_start '
				
					EXEC (@sql)
				END
				IF @series = 44102
				BEGIN
					SET @sql = 'UPDATE a SET a.holiday = [dbo].[FNARIsHoliday]('''',t.term_start,' + CAST(@input AS VARCHAR(100)) + ') FROM #term_break t INNER JOIN '
								 + @process_table 
								 + ' a ON a.termstart = t.term_start '
					EXEC (@sql)	
					
				END
		END
		IF @series_type = 44002
			BEGIN	
				IF OBJECT_ID('tempdb..#time_series1') IS NOT NULL
					DROP TABLE #time_series1
				IF OBJECT_ID('tempdb..#time_series') IS NOT NULL
								DROP TABLE #time_series

				IF OBJECT_ID('tempdb..#columns') IS NOT NULL
					DROP TABLE #columns
				
				CREATE TABLE #time_series1 (
					time_series_definition_id INT
					,maturity DATETIME
					,Hour INT
					,value NUMERIC(38, 20)
					,time_series_id VARCHAR(200) COLLATE DATABASE_DEFAULT
					,time_series_group INT
					,formula VARCHAR(10) COLLATE DATABASE_DEFAULT
					,day_prev DATETIME
					,time_series_id_1 VARCHAR(200) COLLATE DATABASE_DEFAULT
					,granularity VARCHAR(200) COLLATE DATABASE_DEFAULT
					)	
		
				CREATE TABLE #time_series (
					time_series_definition_id INT
					,maturity DATETIME
					,Hour INT
					,value NUMERIC(38, 20)
					,time_series_id VARCHAR(200) COLLATE DATABASE_DEFAULT
					,time_series_group INT
					,formula VARCHAR(10) COLLATE DATABASE_DEFAULT
					,day_prev DATETIME
					,time_series_id_1 VARCHAR(200) COLLATE DATABASE_DEFAULT
					,granularity VARCHAR(200) COLLATE DATABASE_DEFAULT
					)	
	
	IF OBJECT_ID('tempdb..#time_series_avg1') IS NOT NULL
			DROP TABLE #time_series_avg1
	IF OBJECT_ID('tempdb..#time_series_avg') IS NOT NULL
			DROP TABLE #time_series_avg
	CREATE TABLE #time_series_avg1 (
	time_series_definition_id INT
	,maturity DATETIME
	,value FLOAT
	,time_series_id VARCHAR(200) COLLATE DATABASE_DEFAULT
	,time_series_group INT
	)
	CREATE TABLE #time_series_avg (
	maturity DATETIME
	,value FLOAT
	
	)
	
		IF @input_function IN ('SUM','AVG')
		BEGIN
			SET @sql ='INSERT INTO #time_series_avg1
			SELECT tsd1.time_series_definition_id
				  ,tsd1.maturity
				  ,(value),
				  time_series_id,
				  time_series_group  
				  FROM #forecast_columnlist t
				INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = t.series
				INNER JOIN time_series_data tsd1 ON tsd1.time_series_definition_id = tsd.time_series_definition_id
					AND tsd1.time_series_group = t.input 
					AND tsd1.Curve_source_value_id = t.source_id '+
				CASE WHEN ISNULL(@peak_offpeak,0) <>0 THEN '	INNER JOIN #peak_offpeak  po 
				ON po.week_day = DATEPART(DW,tsd1.maturity) 
				AND po.hr =  DATEPART(HOUR,tsd1.maturity)+1' ELSE '' END
				+ '	
				WHERE t.series= '+CAST(@series as VARCHAR(100))+' AND CAST(tsd1.maturity AS DATE) >= '''+CAST(@start_date AS VARCHAR)+''' AND CAST(tsd1.maturity AS date) < = '''+CAST(@end_date AS VARCHAR)  
				+ ''' UNION ALL 
				SELECT tsd1.time_series_definition_id
				  ,tsd1.maturity 
				  ,(value),
				  time_series_id,
				  time_series_group  
				  FROM #forecast_columnlist t
				INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = t.output_series
				INNER JOIN time_series_data tsd1 ON tsd1.time_series_definition_id = tsd.time_series_definition_id
					AND tsd1.time_series_group = t.input 
					AND tsd1.Curve_source_value_id = t.source_id '+
				CASE WHEN ISNULL(@peak_offpeak,0) <>0 THEN '	INNER JOIN #peak_offpeak  po 
				ON po.week_day = DATEPART(DW,tsd1.maturity) 
				AND po.hr =  DATEPART(HOUR,tsd1.maturity)+1' ELSE '' END
				+ '	
				WHERE t.output_series= '+CAST(@output_series as VARCHAR(100))+' AND CAST(tsd1.maturity AS DATE) >= '''+CAST(@start_date AS VARCHAR)+''' AND CAST(tsd1.maturity AS date) < = '''+CAST(@end_date AS VARCHAR)  + '''
				--GROUP BY tsd1.time_series_definition_id,'
				--+CASE WHEN @granularity_list IN ('mm') THEN '' ELSE 'CAST(tsd1.maturity AS DATE),' END +' 
				--time_series_id,
				--time_series_group
					--PRINT(@sql)
					EXEC(@sql)
					
					SET @sql ='INSERT INTO #time_series_avg
					SELECT 
					  '+CASE WHEN @granularity_list IN ('mm') THEN 'MIN' ELSE '' END +' (CAST(maturity AS DATE))
					  ,'+@input_function+'(value) 
					  FROM #time_series_avg1
				GROUP BY ' + CASE WHEN @granularity_list IN ('mm') THEN 'MONTH(CAST(maturity AS DATE)),' ELSE '' END +
				CASE WHEN @granularity_list IN ('yy','mm') THEN 'Year' ELSE '' END +' (CAST(maturity AS DATE)) '
					PRINT(@sql)
					EXEC(@sql)
		END
	
		SET @sql = 'INSERT INTO #time_series1
				SELECT tsd1.time_series_definition_id
					,CAST(tb.term_start AS DATETIME)
					,tb.hour
					,value'
					+'
					,tsd.time_series_id
					,time_series_group
					,formula
					,DATEADD(dd,CAST(formula as INT),tsd1.maturity) day_prev
					,time_series_id+CASE WHEN formula IS NOT NULL THEN  ''_''+REPLACE(formula,''-'',''d'') ELSE '''' END time_series_id_1
					,CASE WHEN tsd.granulalrity = 989 THEN ''t''  --thirtyMin
					   WHEN  tsd.granulalrity = 987 THEN ''f'' -- fifteenMin
					   WHEN  tsd.granulalrity = 994 THEN ''n'' --tenmin
					   WHEN  tsd.granulalrity = 995 THEN ''v'' -- five minute
					   ELSE  LOWER(LEFT(sdv_fg.code,1))+LOWER(LEFT(sdv_fg.code,1)) END
				FROM #forecast_columnlist t
				INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = t.series
				INNER JOIN time_series_data tsd1 ON tsd1.time_series_definition_id = tsd.time_series_definition_id
					AND tsd1.time_series_group = t.input
					AND tsd1.Curve_source_value_id = t.source_id
					INNER JOIN static_data_value sdv_fg ON sdv_fg.value_id = tsd.granulalrity
					INNER JOIN #term_break tb ON '+ CASE WHEN ISNULL(@granularity_list,'')  IN ('f','t','n','v') 
					THEN  'tb.term_end' ELSE +'CASE  WHEN sdv_fg.value_id <> '''+CAST(ISNULL(@gran_forecast,'') AS VARCHAR)+''' THEN CAST(tb.term_start AS DATE) ELSE tb.term_start END'END
					 +' = tsd1.Maturity' +			CASE WHEN @granularity IN ('f','t','n','v') THEN
					  ' AND tb.hour = DATEPART(hour,tsd1.maturity)' ELSE '' END +
			' WHERE t.series = ' + CAST(@series as VARCHAR(100)) 
			
			SET @sql = @sql +' '+
				' UNION ALL
				SELECT tsd1.time_series_definition_id
					,CAST(tb.term_start AS DATETIME)
					,tb.hour,'+
					'value,tsd.time_series_id
					,time_series_group
					,formula
					,DATEADD(dd,CAST(formula as INT),tsd1.maturity) day_prev
					,time_series_id+CASE WHEN formula IS NOT NULL THEN  ''_''+REPLACE(formula,''-'',''d'') ELSE '''' END time_series_id_1
					,CASE WHEN tsd.granulalrity = 989 THEN ''t''  --thirtyMin
					   WHEN  tsd.granulalrity = 987 THEN ''f'' -- fifteenMin
					   WHEN  tsd.granulalrity = 994 THEN ''n'' --tenmin
					   WHEN  tsd.granulalrity = 995 THEN ''v'' -- five minute
					   ELSE  LOWER(LEFT(sdv_fg.code,1))+LOWER(LEFT(sdv_fg.code,1)) END
				FROM #forecast_columnlist t
				INNER JOIN time_series_definition tsd ON tsd.time_series_definition_id = t.output_series
				INNER JOIN time_series_data tsd1 ON tsd1.time_series_definition_id = tsd.time_series_definition_id
					AND tsd1.time_series_group = t.forecast
					AND tsd1.Curve_source_value_id = t.source_id
				INNER JOIN static_data_value sdv_fg ON sdv_fg.value_id = tsd.granulalrity
				INNER JOIN #term_break tb ON '+ CASE WHEN ISNULL(@granularity_list,'')  IN ('mm','f','t','n','v') THEN  'tb.term_end' ELSE +'CASE  WHEN sdv_fg.code <> '''+ISNULL(@granularity_list,'')+''' THEN CAST(tb.term_start AS DATE) ELSE tb.term_start END 'END +' = tsd1.Maturity' +			
				CASE WHEN @granularity IN ('f','t','n','v') THEN ' AND tb.hour = DATEPART(hour,tsd1.maturity)' ELSE '' END +

				' WHERE t.output_series = 
				'+ CAST(ISNULL(@output_series,0) as VARCHAR(100)) +' '
				PRINT(@sql)
				EXEC(@sql)
				
				
				SET @sql = 'INSERT INTO #time_series
						SELECT time_series_definition_id
							,maturity
							,'+CASE WHEN RTRIM(LTRIM(ISNULL(@input_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 'MIN' END +'(hour)
						,'+CASE WHEN RTRIM(LTRIM(ISNULL(@input_function,''))) IN ('SUM','AVG') THEN RTRIM(LTRIM(ISNULL(@input_function,''))) ELSE '' END +'(ISNULL(value,0))/'
						+CASE WHEN RTRIM(LTRIM(ISNULL(@input_function,''))) IN ('Evenly Allocate') THEN '24' ELSE '1' END
							+',time_series_id
							,time_series_group
							,formula
							,day_prev
							,time_series_id_1
							,granularity
						FROM #time_series1 WHERE time_series_definition_id ='+CAST(@series as VARCHAR(100))
						+CASE WHEN RTRIM(LTRIM(ISNULL(@input_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 
				' GROUP BY 
					time_series_definition_id
					,maturity
					,time_series_id
					,time_series_group
					,day_prev
					,time_series_id_1,formula,granularity
				' END
				+
				' UNION ALL
				SELECT time_series_definition_id
							,maturity
							,'+CASE WHEN RTRIM(LTRIM(ISNULL(@forecast_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 'MIN' END +'(hour)
						,'+CASE WHEN RTRIM(LTRIM(ISNULL(@forecast_function,''))) IN ('SUM','AVG') THEN RTRIM(LTRIM(ISNULL(@forecast_function,''))) ELSE '' END +'(ISNULL(value,0))/'
						+CASE WHEN RTRIM(LTRIM(ISNULL(@forecast_function,''))) IN ('Evenly Allocate') THEN '24' ELSE '1' END
							+',time_series_id
							,time_series_group
							,formula
							,day_prev
							,time_series_id_1
							,granularity
						FROM #time_series1 WHERE time_series_definition_id ='+CAST(ISNULL(@output_series,0)  as VARCHAR(100))
						+CASE WHEN RTRIM(LTRIM(ISNULL(@forecast_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 
				' GROUP BY 
					time_series_definition_id
					,maturity
					,time_series_id
					,time_series_group
					,day_prev
					,time_series_id_1,formula,granularity
				' END
					PRINT(@sql)
				EXEC(@sql) 
			--SELECT @input_function
		IF @input_function IN ('SUM','AVG')
		BEGIN
		DECLARE @sql_1 VARCHAR(MAX)
		SET @sql_1 = ' UPDATE ts  SET ts.value = tsa.value FROM #time_series ts
			 LEFT JOIN #time_series_avg tsa ON ' + CASE WHEN @granularity_list IN ('yy','mm') THEN ' YEAR(ts.maturity) = YEAR(tsa.maturity) AND  MONTH(ts.maturity) = MONTH(tsa.maturity)' ELSE ' ts.maturity = tsa.maturity ' END
			 EXEC(@sql_1)	
			
			
			
		
				INSERT INTO #time_series (time_series_definition_id,maturity,hour,value,time_series_id,time_series_group,time_series_id_1)
				SELECT @series,tsa.maturity,DATEPART(hour,tsa.maturity),tsa.value,a.series_name,a.input,a.series_name FROM #time_series_avg tsa LEFT JOIN  #time_series ts ON 
				 ts.maturity = tsa.maturity
				 CROSS APPLY( SELECT * FROM #forecast_columnlist WHERE series = @series)a 
				  WHERE time_series_definition_id IS NULL
			
		END
				DECLARE @column_list1 VARCHAR(MAX) = ''
				DECLARE @sum_colum_list VARCHAR(MAX)
				DECLARE @column_update VARCHAR(MAX)
				DECLARE @time_series_table VARCHAR(200) = 'adiha_process.dbo.pivot_time_series_' + CAST(@series AS VARCHAR(100)) + '_' + @process_id					
				--SELECT DISTINCT (time_series_id_1) time_series_id
				--	INTO #columns
	 		-- FROM #time_series
				SELECT series_name time_series_id
				INTO #columns
				FROM #forecast_columnlist WHERE series_type = @series_type AND series = @series

				INSERT INTO #columns(time_series_id)
				SELECT series_name_forward 
				FROM #forecast_columnlist WHERE series_type = @series_type AND series = @series

				SELECT @column_list1= STUFF((SELECT ',' + time_series_id 
				FROM #columns 
				FOR XML PATH('')), 1, 1, '') 
			
				SELECT @sum_colum_list= STUFF((SELECT ',SUM(' + time_series_id +')'+time_series_id
				FROM #columns
				FOR XML PATH('')), 1, 1, '') 
	

			IF  EXISTS(SELECT 1 FROM #columns) 
				BEGIN
					--DELETE FROM  #time_series WHERE ISNULL(value,0) = 0
					SET @sql = 'CREATE TABLE ' + @time_series_table + ' ( maturity DATETIME,hour INT, time_series_group INT,' + REPLACE(@column_list1, ',', ' FLOAT,') + ' FLOAT)'
					EXEC (@sql)
					
					SET @sql = 'INSERT INTO ' + @time_series_table + ' SELECT maturity,hour,time_series_group,' + @sum_colum_list + ' FROM (SELECT * FROM #time_series)p
					PIVOT
					(SUM(VALUE) FOR time_series_id_1 IN(' + @column_list1 + ')) AS PVT GROUP BY maturity,hour,time_series_group'
					PRINT(@sql)
					EXEC(@sql)		
				
					SELECT @column_update = 'UPDATE a SET '
					
					SELECT @column_update =@column_update+ STUFF((SELECT ',a.' + series_name+CASE WHEN formula IS NOT NULL THEN  '_'+REPLACE(formula,'-','d') ELSE '' END +' = CASE WHEN '''+ISNULL(series_name_forward,'a')+''' <> ''a'' THEN CASE WHEN a.termstart>='''+CAST(@date_From as VARCHAR(12))+'''  AND a.termstart < '''+CAST(DATEADD(dd, 1, @as_of_date) AS VARCHAR(12))+''' THEN ' + 'b.'+series_name+
					CASE WHEN formula IS NOT NULL THEN  '_'+REPLACE(formula,'-','d') ELSE '' END +' ELSE b.'+ISNULL(series_name_forward,series_name)+CASE WHEN formula IS NOT NULL THEN  '_'+REPLACE(formula,'-','d') ELSE '' END + ' END ELSE b.'+series_name +' END'
					FROM #forecast_columnlist WHERE series_type = @series_type AND series = @series
					FOR XML PATH('')), 1, 1, '') 
				
					SELECT @column_update = REPLACE(REPLACE(@column_update,'&gt;','>'),'&lt;','<')
			
					SELECT @column_update =@column_update  + ' FROM '+@process_table +
					' a INNER JOIN '+
					@time_series_table +
					' b ON '+
					CASE WHEN @granularity IN ('f','t','n','v') THEN 
					'CAST(a.termstart as DATE) = CAST(b.maturity as DATE) ' 
					ELSE CASE WHEN @granularity IN ('m') 
					THEN ' Year(a.termstart) = YEAR(b.maturity) AND MONTH(a.termstart) = MONTH(b.maturity)' 
					WHEN @granularity IN ('y') THEN ' Year(a.termstart) = YEAR(b.maturity)  '
					ELSE 
					'a.termstart = b.maturity ' END END + 
					CASE WHEN @granularity IN ('f','t','n','v') 
					THEN ' AND a.hour = DATEPART(hour,b.maturity) ' ELSE '' END
					
					PRINT(@column_update)
					EXEC(@column_update)
	

				END
			
				
		END 
	IF @series_type = 44003
		BEGIN 
			DECLARE @input_curve INT
			DECLARE @forecast_curve INT

			SELECT @input_curve = s.source_curve_def_id
			FROM #forecast_columnlist fc
			INNER JOIN source_price_curve_def s ON s.source_curve_def_id = fc.input
			WHERE fc.series_type =@series_type
			
			SELECT @forecast_curve = s.source_curve_def_id
			 FROM #forecast_columnlist fc
			INNER JOIN source_price_curve_def s ON s.source_curve_def_id = fc.forecast
			WHERE fc.series_type =@series_type
			
			UPDATE #term_break
				SET curve = CASE 
			WHEN term_start >= @date_From
				AND term_start < DATEADD(dd, 1, @as_of_date)
				THEN @input_curve
			ELSE @forecast_curve
			END

			CREATE TABLE #input_curve (
			maturity_date DATETIME
			,hour INT
			,curve_value NUMERIC(38, 20)
			)	
		
			CREATE TABLE #input_curve1 (
			maturity_date DATETIME
			,hour INT
			,curve_value NUMERIC(38, 20)
			)
			
					
			SET @sql = 'INSERT INTO #input_curve1
						SELECT
							CAST(maturity_date AS DATE)
							,(DATEPART(hour,maturity_date))
							,(curve_value) FROM source_price_curve spc ' +
				CASE WHEN (@peak_offpeak<>0) THEN 'INNER JOIN #peak_offpeak  po 
				ON po.week_day = DATEPART(DW,maturity_date) 
				AND po.hr =  DATEPART(HOUR,maturity_date)+1 ' ELSE '' END

				+ '	WHERE source_curve_def_id ='+ CAST(@input_curve AS VARCHAR(100))
						+' AND maturity_date >='''+ CAST(@date_from AS VARCHAR(100))
						+''' AND maturity_date < DATEADD(DD, 1,'''+ CAST(@end_date AS VARCHAR(100))+''')'
						+' AND curve_source_value_id ='''+ CAST(@source_id AS VARCHAR(100))+''''
					
				SET @sql = @sql+
					ISNULL(' UNION ALL 
					SELECT CAST(maturity_date AS DATE)
							,(DATEPART(hour,maturity_date))
							,(curve_value) FROM source_price_curve spc  ' +
				CASE WHEN (ISNULL(@peak_offpeak,0)<>0) THEN 'INNER JOIN #peak_offpeak  po 
				ON po.week_day = DATEPART(DW,maturity_date) 
				AND po.hr =  DATEPART(HOUR,maturity_date)+1 ' ELSE '' END
				+ '	
					WHERE source_curve_def_id =' + CAST(@forecast_curve AS VARCHAR(100))
						+' AND maturity_date >='''+ CAST(@start_date AS VARCHAR(100))+''''
						+' AND curve_source_value_id ='''+ CAST(@source_id AS VARCHAR(100))+'''','')
			
					SET @sql = @sql 
							+'AND maturity_date < DATEADD(DD, 1,'''+CAST( @end_date  AS VARCHAR(100)) +''')'
			PRINT(@sql)
			EXEC(@sql)
			

				SET @sql = 'INSERT INTO #input_curve(maturity_date,hour,curve_value)
						SELECT  '+CASE WHEN @input_function IN ('AVG','SUM') THEN 'MIN' ELSE '' END+'(maturity_date),'
								++CASE WHEN @input_function IN ('AVG','SUM') THEN 'MIN' ELSE '' END+ '(hour)
								,'+CASE WHEN @input_function IN ('AVG','SUM') THEN ISNULL(@input_function,'') ELSE '' END+  '(curve_value) 
							FROM #input_curve1 '	
			SET @sql  = @sql + CASE WHEN @input_function IN ('AVG','SUM') THEN ' GROUP BY ' + 
			CASE WHEN @granularity_list = 'mm' THEN 'Year(maturity_date),MONTH(maturity_date)' ELSE '(maturity_date)' END 
			ELSE '' END
		
			PRINT(@sql)
			EXEC(@sql)
			
			SELECT @sql = 'UPDATE a SET '
			SELECT @sql =@sql+ STUFF((SELECT ',a.' + series_name+CASE WHEN  formula IS NOT NULL THEN  '_'+REPLACE(ISNULL(formula,''),'-','d') ELSE '' END +' = curve_value '
							FROM #forecast_columnlist WHERE series_type = @series_type AND forecast_model_input_id = @forecast_model_input_id
					FOR XML PATH('')), 1, 1, '') 
				
				SELECT @sql =@sql  + ' FROM '+@process_table +' a 
				INNER JOIN #term_break tb ON a.termstart = tb.term_start
				INNER JOIN #input_curve ic ON '+CASE WHEN  @granularity_list = 'mm' THEN ' Year(a.termstart) = YEAR(ic.maturity_date) AND MONTH(a.termstart) = MONTH(ic.maturity_date) ' ELSE  +' CASE WHEN '''+@granularity +'''=''d'' OR '''+@granularity +'''=''m''   THEN DATEADD('+CASE WHEN @granularity_list ='hh' THEN 'hour' 
				WHEN @granularity_list IN ('f','t','n','v') THEN 'dd' 
					ELSE @granularity_list END+',ISNULL(CAST('+ISNULL(@formula,'0')+' as INT),0), a.termstart) ELSE  CAST(a.termstart AS DATE)   END=CASE WHEN '''+@granularity +'''=''d''    
					THEN DATEADD('+CASE WHEN @granularity_list ='hh' THEN 'hour' WHEN @granularity_list IN ('f','t','n','v') THEN 'dd' ELSE @granularity_list END+',ISNULL(CAST('+ISNULL(@formula,'0')+' as INT),0),ic.maturity_date) ELSE ic.maturity_date END'+ 
					CASE WHEN @granularity_list ='hh' THEN ' AND ic.hour ' WHEN @granularity_list IN ('f','t','n','v') THEN ' AND ic.hour' ELSE +' AND '''+ @granularity_list+'''' END  +' = '+
					CASE WHEN @granularity_list ='hh' THEN 'tb.hour' WHEN @granularity_list IN ('f','t','n','v') THEN ' tb.hour ' ELSE +''''+ @granularity_list +'''' END 
					
					  END
				+ CASE WHEN @output = 43802 THEN ' AND a.output_type <> ''f''' ELSE '' END
				PRINT(@sql)
				EXEC(@sql)
				
		END
	IF @series_type = 44004
		BEGIN 
			IF OBJECT_ID('tempdb..#load_data') IS NOT NULL
				DROP TABLE #load_data
			IF OBJECT_ID('tempdb..#load_mins') IS NOT NULL
				DROP TABLE #load_mins
			IF OBJECT_ID('tempdb..#load_input') IS NOT NULL
				DROP TABLE #load_input
			IF OBJECT_ID('tempdb..#unpivot_load_data') IS NOT NULL
				DROP TABLE #unpivot_load_data
			IF OBJECT_ID('tempdb..#unpivot_load_data1') IS NOT NULL
				DROP TABLE #unpivot_load_data1

			CREATE TABLE #unpivot_load_data (
				hr DATETIME
				,load_input NUMERIC(38, 20)
				)

				CREATE TABLE #unpivot_load_data1 (
				meter_id INT
				,from_date DATETIME
				,load_input NUMERIC(38, 20)
				,hr DATETIME
				)

			SELECT m.meter_id,mvd.meter_data_id,ISNULL(mdh.prod_date,from_date) from_date,ISNULL(Hr1,volume) Hr1
				,Hr2
				,Hr3
				,Hr4
				,Hr5
				,Hr6
				,Hr7
				,Hr8
				,Hr9
				,Hr10
				,Hr11
				,Hr12
				,Hr13
				,Hr14
				,Hr15
				,Hr16
				,Hr17
				,Hr18
				,Hr19
				,Hr20
				,Hr21
				,Hr22
				,Hr23
				,Hr24
				,Hr25
				,CASE WHEN m.granularity = 989 THEN 't'  --thirtyMin
			   WHEN  m.granularity = 987 THEN 'f' -- fifteenMin
			   WHEN  m.granularity = 994 THEN 'n' --tenmin
			   WHEN  m.granularity = 995 THEN 'v' -- five minute
	   ELSE  LOWER(LEFT(sdv_fg.code,1))+LOWER(LEFT(sdv_fg.code,1)) END  granularity
				INTO #load_input
		FROM meter_id  m 
			INNER JOIN #forecast_columnlist fc ON fc.input = m.meter_id and fc.series_type = @series_type 
			AND  fc.forecast_model_input_id =  @forecast_model_input_id
			INNER JOIN static_data_value sdv_fg ON sdv_fg.value_id = m.granularity
			LEFT JOIN mv90_data mvd ON mvd.meter_id = m.meter_id 
			LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = ISNULL(mvd.meter_data_id,m.meter_id)
		 WHERE (from_date   >= @date_From
						AND from_date < DATEADD(dd, 1,@as_of_date)) OR mdh.prod_date BETWEEN @date_from AND @as_of_date -- DATEADD(dd, 1,@as_of_date)
		
						
		SELECT m.meter_id
			,mdh.meter_data_id
			,mdh.prod_date from_date
			,Hr1_15
			,Hr1_30
			,Hr1_45
			,Hr1_60
			,Hr2_15
			,Hr2_30
			,Hr2_45
			,Hr2_60
			,Hr3_15
			,Hr3_30
			,Hr3_45
			,Hr3_60
			,Hr4_15
			,Hr4_30
			,Hr4_45
			,Hr4_60
			,Hr5_15
			,Hr5_30
			,Hr5_45
			,Hr5_60
			,Hr6_15
			,Hr6_30
			,Hr6_45
			,Hr6_60
			,Hr7_15
			,Hr7_30
			,Hr7_45
			,Hr7_60
			,Hr8_15
			,Hr8_30
			,Hr8_45
			,Hr8_60
			,Hr9_15
			,Hr9_30
			,Hr9_45
			,Hr9_60
			,Hr10_15
			,Hr10_30
			,Hr10_45
			,Hr10_60
			,Hr11_15
			,Hr11_30
			,Hr11_45
			,Hr11_60
			,Hr12_15
			,Hr12_30
			,Hr12_45
			,Hr12_60
			,Hr13_15
			,Hr13_30
			,Hr13_45
			,Hr13_60
			,Hr14_15
			,Hr14_30
			,Hr14_45
			,Hr14_60
			,Hr15_15
			,Hr15_30
			,Hr15_45
			,Hr15_60
			,Hr16_15
			,Hr16_30
			,Hr16_45
			,Hr16_60
			,Hr17_15
			,Hr17_30
			,Hr17_45
			,Hr17_60
			,Hr18_15
			,Hr18_30
			,Hr18_45
			,Hr18_60
			,Hr19_15
			,Hr19_30
			,Hr19_45
			,Hr19_60
			,Hr20_15
			,Hr20_30
			,Hr20_45
			,Hr20_60
			,Hr21_15
			,Hr21_30
			,Hr21_45
			,Hr21_60
			,Hr22_15
			,Hr22_30
			,Hr22_45
			,Hr22_60
			,Hr23_15
			,Hr23_30
			,Hr23_45
			,Hr23_60
			,Hr24_15
			,Hr24_30
			,Hr24_45
			,Hr24_60
			,Hr25_15
			,Hr25_30
			,Hr25_45
			,Hr25_60
			,CASE WHEN m.granularity = 989 THEN 't'  --thirtyMin
			   WHEN  m.granularity = 987 THEN 'f' -- fifteenMin
			   WHEN  m.granularity = 994 THEN 'n' --tenmin
			   WHEN  m.granularity = 995 THEN 'v' -- five minute 
			 ELSE  LOWER(LEFT(sdv_fg.code,1))+LOWER(LEFT(sdv_fg.code,1)) END   granularity
		INTO #load_mins
		FROM meter_id m
		INNER JOIN #forecast_columnlist fc ON fc.input = m.meter_id
			AND fc.series_type = @series_type
			AND fc.forecast_model_input_id = @forecast_model_input_id
		INNER JOIN static_data_value sdv_fg ON sdv_fg.value_id = m.granularity
		LEFT JOIN mv90_data mvd ON mvd.meter_id = m.meter_id 
		LEFT JOIN mv90_data_mins mdh ON mdh.meter_data_id = ISNULL(mvd.meter_data_id,m.meter_id)
		
		WHERE mdh.prod_date BETWEEN @date_from
				AND DATEADD(dd, 1, @as_of_date)
			
		
			SELECT ddh.profile_id
				,external_id
				,term_date
				,Hr1
				,Hr2
				,Hr3
				,Hr4
				,Hr5
				,Hr6
				,Hr7
				,Hr8
				,Hr9
				,Hr10
				,Hr11
				,Hr12
				,Hr13
				,Hr14
				,Hr15
				,Hr16
				,Hr17
				,Hr18
				,Hr19
				,Hr20
				,Hr21
				,Hr22
				,Hr23
				,Hr24
				,Hr25
				,CASE WHEN granularity = 989 THEN 't'  --thirtyMin
			   WHEN  granularity = 987 THEN 'f' -- fifteenMin
			   WHEN  granularity = 994 THEN 'n' --tenmin
			   WHEN  granularity = 995 THEN 'v' -- five minute
	   ELSE  LOWER(LEFT(sdv_fg.code,1))+LOWER(LEFT(sdv_fg.code,1)) END  granularity
			INTO #load_data
		  FROM forecast_profile pf 
		 INNER JOIN  #forecast_columnlist fc ON fc.forecast = pf.profile_id and fc.series_type = @series_type 
			AND  fc.forecast_model_input_id = @forecast_model_input_id
			INNER JOIN static_data_value sdv_fg ON sdv_fg.value_id = pf.granularity
			LEFT JOIN deal_detail_hour ddh ON ddh.profile_id = pf.profile_id


		IF ISNULL(@peak_offpeak,0)<>0
			BEGIN
				UPDATE li SET 
					 Hr1=li.Hr1*NULLIF(hb.Hr1,0)
					,Hr2=li.Hr2*NULLIF(hb.Hr2,0)
					,Hr3=li.Hr3*NULLIF(hb.Hr3,0)
					,Hr4=li.Hr4*NULLIF(hb.Hr4,0)
					,Hr5=li.Hr5*NULLIF(hb.Hr5,0)
					,Hr6=li.Hr6*NULLIF(hb.Hr6,0)
					,Hr7=li.Hr7*NULLIF(hb.Hr7,0)
					,Hr8=li.Hr8*NULLIF(hb.Hr8,0)
					,Hr9=li.Hr9*NULLIF(hb.Hr9,0)
					,Hr10=li.Hr10*NULLIF(hb.Hr10,0)
					,Hr11=li.Hr11*NULLIF(hb.Hr11,0)
					,Hr12=li.Hr12*NULLIF(hb.Hr12,0)
					,Hr13=li.Hr13*NULLIF(hb.Hr13,0)
					,Hr14=li.Hr14*NULLIF(hb.Hr14,0)
					,Hr15=li.Hr15*NULLIF(hb.Hr15,0)
					,Hr16=li.Hr16*NULLIF(hb.Hr16,0)
					,Hr17=li.Hr17*NULLIF(hb.Hr17,0)
					,Hr18=li.Hr18*NULLIF(hb.Hr18,0)
					,Hr19=li.Hr19*NULLIF(hb.Hr19,0)
					,Hr20=li.Hr20*NULLIF(hb.Hr20,0)
					,Hr21=li.Hr21*NULLIF(hb.Hr21,0)
					,Hr22=li.Hr22*NULLIF(hb.Hr22,0)
					,Hr23=li.Hr23*NULLIF(hb.Hr23,0)
					,Hr24=li.Hr24*NULLIF(hb.Hr24,0)
				FROM #load_input li INNER JOIN hourly_block hb ON 
					hb.week_day = DATEPART(dw,li.from_date) --AND hb.hour = DATEPART(hour,li.from_date)
					WHERE hb.block_value_id = @peak_offpeak
					

					UPDATE li SET 
						Hr1=li.Hr1* hb.Hr1
						,Hr2=li.Hr2*hb.Hr2
						,Hr3=li.Hr3*hb.Hr3
						,Hr4=li.Hr4*hb.Hr4
						,Hr5=li.Hr5*hb.Hr5
						,Hr6=li.Hr6*hb.Hr6
						,Hr7=li.Hr7*hb.Hr7
						,Hr8=li.Hr8*hb.Hr8
						,Hr9=li.Hr9*hb.Hr9
						,Hr10=li.Hr10*hb.Hr10
						,Hr11=li.Hr11*hb.Hr11
						,Hr12=li.Hr12*hb.Hr12
						,Hr13=li.Hr13*hb.Hr13
						,Hr14=li.Hr14*hb.Hr14
						,Hr15=li.Hr15*hb.Hr15
						,Hr16=li.Hr16*hb.Hr16
						,Hr17=li.Hr17*hb.Hr17
						,Hr18=li.Hr18*hb.Hr18
						,Hr19=li.Hr19*hb.Hr19
						,Hr20=li.Hr20*hb.Hr20
						,Hr21=li.Hr21*hb.Hr21
						,Hr22=li.Hr22*hb.Hr22
						,Hr23=li.Hr23*hb.Hr23
						,Hr24=li.Hr24*hb.Hr24
				FROM #load_data li INNER JOIN hourly_block hb ON 
					hb.week_day = DATEPART(dw,li.term_date) --AND hb.hour = DATEPART(hour,li.term_date)
					WHERE hb.block_value_id = @peak_offpeak

					UPDATE li SET 
						Hr1_15=hb.Hr1*li.Hr1_15
					,Hr1_30=hb.Hr1*li.Hr1_30
					,Hr1_45=hb.Hr1*li.Hr1_45
					,Hr1_60=hb.Hr1*li.Hr1_60
					,Hr2_15=hb.Hr2*li.Hr2_15
					,Hr2_30=hb.Hr2*li.Hr2_30
					,Hr2_45=hb.Hr2*li.Hr2_45
					,Hr2_60=hb.Hr2*li.Hr2_60
					,Hr3_15=hb.Hr3*li.Hr3_15
					,Hr3_30=hb.Hr3*li.Hr3_30
					,Hr3_45=hb.Hr3*li.Hr3_45
					,Hr3_60=hb.Hr3*li.Hr3_60
					,Hr4_15=hb.Hr4*li.Hr4_15
					,Hr4_30=hb.Hr4*li.Hr4_30
					,Hr4_45=hb.Hr4*li.Hr4_45
					,Hr4_60=hb.Hr4*li.Hr4_60
					,Hr5_15=hb.Hr5*li.Hr5_15
					,Hr5_30=hb.Hr5*li.Hr5_30
					,Hr5_45=hb.Hr5*li.Hr5_45
					,Hr5_60=hb.Hr5*li.Hr5_60
					,Hr6_15=hb.Hr6*li.Hr6_15
					,Hr6_30=hb.Hr6*li.Hr6_30
					,Hr6_45=hb.Hr6*li.Hr6_45
					,Hr6_60=hb.Hr6*li.Hr6_60
					,Hr7_15=hb.Hr7*li.Hr7_15
					,Hr7_30=hb.Hr7*li.Hr7_30
					,Hr7_45=hb.Hr7*li.Hr7_45
					,Hr7_60=hb.Hr7*li.Hr7_60
					,Hr8_15=hb.Hr8*li.Hr8_15
					,Hr8_30=hb.Hr8*li.Hr8_30
					,Hr8_45=hb.Hr8*li.Hr8_45
					,Hr8_60=hb.Hr8*li.Hr8_60
					,Hr9_15=hb.Hr9*li.Hr9_15
					,Hr9_30=hb.Hr9*li.Hr9_30
					,Hr9_45=hb.Hr9*li.Hr9_45
					,Hr9_60=hb.Hr9*li.Hr9_60
					,Hr10_15=hb.Hr10*li.Hr10_15
					,Hr10_30=hb.Hr10*li.Hr10_30
					,Hr10_45=hb.Hr10*li.Hr10_45
					,Hr10_60=hb.Hr10*li.Hr10_60
					,Hr11_15=hb.Hr11*li.Hr11_15
					,Hr11_30=hb.Hr11*li.Hr11_30
					,Hr11_45=hb.Hr11*li.Hr11_45
					,Hr11_60=hb.Hr11*li.Hr11_60
					,Hr12_15=hb.Hr12*li.Hr12_15
					,Hr12_30=hb.Hr12*li.Hr12_30
					,Hr12_45=hb.Hr12*li.Hr12_45
					,Hr12_60=hb.Hr12*li.Hr12_60
					,Hr13_15=hb.Hr13*li.Hr13_15
					,Hr13_30=hb.Hr13*li.Hr13_30
					,Hr13_45=hb.Hr13*li.Hr13_45
					,Hr13_60=hb.Hr13*li.Hr13_60
					,Hr14_15=hb.Hr14*li.Hr14_15
					,Hr14_30=hb.Hr14*li.Hr14_30
					,Hr14_45=hb.Hr14*li.Hr14_45
					,Hr14_60=hb.Hr14*li.Hr14_60
					,Hr15_15=hb.Hr15*li.Hr15_15
					,Hr15_30=hb.Hr15*li.Hr15_30
					,Hr15_45=hb.Hr15*li.Hr15_45
					,Hr15_60=hb.Hr15*li.Hr15_60
					,Hr16_15=hb.Hr16*li.Hr16_15
					,Hr16_30=hb.Hr16*li.Hr16_30
					,Hr16_45=hb.Hr16*li.Hr16_45
					,Hr16_60=hb.Hr16*li.Hr16_60
					,Hr17_15=hb.Hr17*li.Hr17_15
					,Hr17_30=hb.Hr17*li.Hr17_30
					,Hr17_45=hb.Hr17*li.Hr17_45
					,Hr17_60=hb.Hr17*li.Hr17_60
					,Hr18_15=hb.Hr18*li.Hr18_15
					,Hr18_30=hb.Hr18*li.Hr18_30
					,Hr18_45=hb.Hr18*li.Hr18_45
					,Hr18_60=hb.Hr18*li.Hr18_60
					,Hr19_15=hb.Hr19*li.Hr19_15
					,Hr19_30=hb.Hr19*li.Hr19_30
					,Hr19_45=hb.Hr19*li.Hr19_45
					,Hr19_60=hb.Hr19*li.Hr19_60
					,Hr20_15=hb.Hr20*li.Hr20_15
					,Hr20_30=hb.Hr20*li.Hr20_30
					,Hr20_45=hb.Hr20*li.Hr20_45
					,Hr20_60=hb.Hr20*li.Hr20_60
					,Hr21_15=hb.Hr21*li.Hr21_15
					,Hr21_30=hb.Hr21*li.Hr21_30
					,Hr21_45=hb.Hr21*li.Hr21_45
					,Hr21_60=hb.Hr21*li.Hr21_60
					,Hr22_15=hb.Hr22*li.Hr22_15
					,Hr22_30=hb.Hr22*li.Hr22_30
					,Hr22_45=hb.Hr22*li.Hr22_45
					,Hr22_60=hb.Hr22*li.Hr22_60
					,Hr23_15=hb.Hr23*li.Hr23_15
					,Hr23_30=hb.Hr23*li.Hr23_30
					,Hr23_45=hb.Hr23*li.Hr23_45
					,Hr23_60=hb.Hr23*li.Hr23_60
					,Hr24_15=hb.Hr24*li.Hr24_15
					,Hr24_30=hb.Hr24*li.Hr24_30
					,Hr24_45=hb.Hr24*li.Hr24_45
					,Hr24_60=hb.Hr24*li.Hr24_60
				FROM #load_mins li INNER JOIN hourly_block hb ON 
					hb.week_day = DATEPART(dw,li.from_date) --AND hb.hour = DATEPART(hour,li.from_date)
					WHERE hb.block_value_id = @peak_offpeak
			END
	DECLARE @sql_evenly VARCHAR(MAX) = 'UPDATE #load_input SET '
	DECLARE @sql_profile VARCHAR(MAX) = 'UPDATE #load_data SET ' 
	DECLARE @sql_mins VARCHAR(MAX) ='UPDATE #load_mins SET ' 
	IF @input_function IN('Evenly Allocate','USE Same') OR @forecast_function IN ('Evenly Allocate','USE Same')
	BEGIN
	DECLARE @i INT = 1 
	DECLARE @j INT = 1
	DECLARE @k INT 
		WHILE (@i<=25)
		BEGIN
			SET @sql_evenly = @sql_evenly + 'Hr'+CAST(@i as VARCHAR(20)) +' = Hr'+
			CASE WHEN @granularity IN ('f','t','n','v') THEN CAST(@i as VARCHAR(20)) ELSE '1' END 
			+'/'+CASE WHEN @input_function = 'Evenly Allocate' THEN 
				CASE WHEN @granularity IN ('h','f','t','n','v') THEN  CAST(@dividend as VARCHAR) 
					WHEN @granularity = 'dd' THEN 
			'24' ELSE '1' END END+','
		
			SET @sql_profile = @sql_profile + 'Hr'+CAST(@i as VARCHAR(20)) +' = Hr'+
			
			 CASE WHEN @granularity  IN ('f','t','n','v') THEN CAST(@i as VARCHAR(20)) ELSE '1' END +'/'+CASE WHEN @input_function = 'Evenly Allocate' THEN 
				CASE WHEN @granularity IN ('h','f','t','n','v') THEN  CAST(@dividend as VARCHAR) 
					WHEN @granularity = 'dd' THEN 
			'24' ELSE '1' END END +','
		--	+CASE WHEN @forecast_function = 'Evenly Allocate' THEN '24' ELSE '1' END +','
			SET @i=@i +1
		END
		SET @sql_evenly  = LEFT(@sql_evenly,LEN(@sql_evenly)-1)
		SET @sql_profile = LEFT(@sql_profile,LEN(@sql_profile) - 1) 
	
		EXEC(@sql_evenly)
		EXEC(@sql_profile)
		IF EXISTS(SELECT 1 FROM #load_mins)
		BEGIN
			WHILE (@j<=25)
			BEGIN
			SET @k = 15
				WHILE (@k<=60)
				BEGIN
				SET	@sql_mins = @sql_mins + 'Hr'+CAST(@j AS VARCHAR(20))+'_'+CAST(@k AS VARCHAR(20)) +' = Hr'+CASE WHEN @granularity IN ('m','d','h') THEN '1' ELSE CAST(@j AS VARCHAR(20)) END
				+'_15/'+ 
				CASE WHEN @input_function = 'Evenly Allocate' THEN CASE WHEN @granularity IN ('h','f','t','n','v') THEN CAST(@dividend As VARCHAR(20)) ELSE '24' END
				 ELSE '1' END +','
					SET @k = @k+15
				END
				SET @j=@j +1
			END
			SET @sql_mins  = LEFT(@sql_mins,LEN(@sql_mins)-1)
			PRINT(@sql_mins)
			EXEC(@sql_mins)
		END
	END
DECLARE @a VARCHAR(MAX)	
DECLARE @b INT = 0 
SELECT @b = 1  FROM #load_mins


		SET @sql = 'INSERT INTO #unpivot_load_data1 ' + 
		CASE WHEN @b = 0 THEN
		'	SELECT meter_id,from_date,'+
			--CASE 
			--	WHEN RTRIM(LTRIM(ISNULL(@input_function, ''))) IN (
			--			'SUM'
			--			,'AVG'
			--			)
			--		THEN RTRIM(LTRIM(ISNULL(@input_function, '')))
			--	ELSE ''
			--	END +
			 '(load_input)' 
					+','--+CASE WHEN RTRIM(LTRIM(ISNULL(@input_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 'MIN' END+
					+'(DATEADD(hh, CAST(RIGHT(load_value, len(load_value) - 2) AS INT)-1, from_date)) hr
				 FROM
				(SELECT meter_id,meter_data_id,from_date
						,Hr1
						,Hr2
						,Hr3
						,Hr4
						,Hr5
						,Hr6
						,Hr7
						,Hr8
						,Hr9
						,Hr10
						,Hr11
						,Hr12
						,Hr13
						,Hr14
						,Hr15
						,Hr16
						,Hr17
						,Hr18
						,Hr19
						,Hr20
						,Hr21
						,Hr22
						,Hr23
						,Hr24
						
					FROM #load_input) p
				UNPIVOT
				   (Load_input FOR load_value IN (Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24 )
				)AS unpvt'
				--+CASE WHEN RTRIM(LTRIM(ISNULL(@input_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 
				--' GROUP BY 
				--	meter_id,meter_data_id,from_date
					
				--' END
				
				
		 ELSE +' 
			 SELECT meter_id,from_date,'
			 +
			 '(load_input)'
					+','
					+'DATEADD(mi,CAST(REPLACE(RIGHT(load_value, CHARINDEX(''_'',RIGHT(load_value, len(load_value)-2))),''_'','''') as INT)-15, DATEADD(HOUR,CAST(LEFT(RIGHT(load_value, len(load_value)-2),CHARINDEX(''_'',RIGHT(load_value, len(load_value)-2),0)-1) as INT)-1,from_date))
			  hr FROM (
		 SELECT * FROM #load_mins)m UNPIVOT(load_input FOR load_value IN (Hr1_15
	,Hr1_30,Hr1_45,Hr1_60,Hr2_15,Hr2_30,Hr2_45,Hr2_60,Hr3_15,Hr3_30,Hr3_45,Hr3_60,Hr4_15,Hr4_30,Hr4_45,Hr4_60,Hr5_15,Hr5_30,Hr5_45,Hr5_60,Hr6_15,Hr6_30,Hr6_45,Hr6_60,Hr7_15,Hr7_30,Hr7_45,Hr7_60,Hr8_15,Hr8_30,Hr8_45,Hr8_60,Hr9_15,Hr9_30,Hr9_45,Hr9_60,Hr10_15,Hr10_30,Hr10_45,Hr10_60,Hr11_15,Hr11_30,Hr11_45,Hr11_60,Hr12_15,Hr12_30,Hr12_45,Hr12_60,Hr13_15,Hr13_30,Hr13_45,Hr13_60,Hr14_15,Hr14_30,Hr14_45,Hr14_60,Hr15_15,Hr15_30,Hr15_45,Hr15_60,Hr16_15,Hr16_30,Hr16_45,Hr16_60,Hr17_15,Hr17_30,Hr17_45,Hr17_60,Hr18_15,Hr18_30,Hr18_45,Hr18_60,Hr19_15
,Hr19_30,Hr19_45,Hr19_60,Hr20_15,Hr20_30,Hr20_45,Hr20_60,Hr21_15,Hr21_30,Hr21_45,Hr21_60,Hr22_15,Hr22_30,Hr22_45,Hr22_60,Hr23_15,Hr23_30,Hr23_45,Hr23_60,Hr24_15,Hr24_30,Hr24_45,Hr24_60)) AS unpvt
		'
		END
	+' UNION ALL
					SELECT profile_id
					,term_date
					,'+
				--	CASE 
				--WHEN RTRIM(LTRIM(ISNULL(@forecast_function, ''))) IN (
				--		'SUM'
				--		,'AVG'
				--		)
				--	THEN RTRIM(LTRIM(ISNULL(@forecast_function, '')))
				--ELSE ''
				--END +
				 '(Load_input),' 
				--+','+CASE WHEN RTRIM(LTRIM(ISNULL(@forecast_function,'')))  NOT IN ('SUM','AVG') THEN '' ELSE 'MIN' END
				+'(DATEADD(hh, CAST(RIGHT(load_value, len(load_value) - 2) AS INT)-1, term_date)) hr
				FROM 
				   (SELECT profile_id
						,external_id
						,term_date
						,Hr1
						,Hr2
						,Hr3
						,Hr4
						,Hr5
						,Hr6
						,Hr7
						,Hr8
						,Hr9
						,Hr10
						,Hr11
						,Hr12
						,Hr13
						,Hr14
						,Hr15
						,Hr16
						,Hr17
						,Hr18
						,Hr19
						,Hr20
						,Hr21
						,Hr22
						,Hr23
						,Hr24
						
					FROM #load_data) p
				UNPIVOT
				   (Load_input FOR load_value IN (Hr1,Hr2,Hr3,Hr4,Hr5,Hr6,Hr7,Hr8,Hr9,Hr10,Hr11,Hr12,Hr13,Hr14,Hr15,Hr16,Hr17,Hr18,Hr19,Hr20,Hr21,Hr22,Hr23,Hr24 )
				)AS unpvt'
			PRINT(@sql)
			EXEC(@sql)

			SET @sql = 'INSERT INTO #unpivot_load_data(hr,load_input)
						SELECT  '+CASE WHEN @input_function IN ('AVG','SUM') THEN 'MIN' ELSE '' END+'(hr),'
								+CASE WHEN @input_function IN ('AVG','SUM') THEN  ISNULL(@input_function,'') ELSE '' END+  '(load_input) 
							FROM #unpivot_load_data1 '	
			SET @sql  = @sql + CASE WHEN @input_function IN ('AVG','SUM') THEN ' GROUP BY ' + 
			CASE WHEN @granularity_list = 'mm' THEN 'MONTH(hr),Year(hr)'  
			WHEN @granularity_list = 'dd' THEN ' CAST(hr as DATE) '  
			ELSE '(hr)' END  
			
			ELSE '' END
			PRINT(@sql)
			EXEC(@sql)
			
			SELECT @sql = 'UPDATE a SET '
			SELECT @sql =@sql+ STUFF((SELECT ',a.' + series_name+CASE WHEN  formula IS NOT NULL THEN  '_'+REPLACE(ISNULL(formula,''),'-','d') ELSE '' END +' = load_input ' 
		FROM #forecast_columnlist WHERE series_type = @series_type AND forecast_model_input_id = @forecast_model_input_id
				FOR XML PATH('')), 1, 1, '') 

				SELECT @sql =@sql  + ' FROM '+@process_table +' a INNER JOIN #unpivot_load_data b ON '
					+ 
					CASE WHEN @granularity_list  IN ('mm','dd','f','t','v','n') 
						THEN 'CAST(a.termstart as DATE)= CAST( b.hr as DATE)'
						ELSE   'a.termstart = b.hr'  
					END 
					+ CASE WHEN @granularity_list  IN ('f','t','v','n') THEN 
						' AND DATEPART(hour,a.termstart) = DATEPART(hour,b.hr) '
						
						ELSE '' END 
					+ CASE WHEN @granularity_list  IN ('f','t','v','n') AND @b = 1 THEN 
						' AND DATEPART(mi,a.termstart) = DATEPART(mi,b.hr) '
						ELSE '' END 
						+ CASE WHEN @output = 43801 THEN ' AND a.output_type <> ''f''' ELSE '' END
						

						
		PRINT(@sql)
		EXEC(@sql)
	END
	   FETCH NEXT
	FROM db_cursor
	INTO @forecast_model_id1
		,@series_type
		,@series
		,@input
		,@forecast
		,@out
		,@formula
		,@granularity_list
		,@input_function
		,@forecast_function
		,@forecast_model_input_id
		,@source_id
		,@output_series 
END  

CLOSE db_cursor  
DEALLOCATE db_cursor 

SELECT  @process_table_name = @process_table
--EXEC('SELECT * FROM '+ @process_table + ' Order by termstart')
--Return
	SET @del_sql = 'SELECT @del_count_out = count(1) FROM ' + @process_table  +' WHERE ' 
	SET @sql = 'DELETE FROM ' + @process_table +' WHERE ' 
	SELECT @delete_field = REPLACE(@dynamic_column,' numeric(38,20),',' IS NULL OR ')
	SELECT @delete_field = LEFT(@delete_field,LEN(@delete_field)-2)
	
	SET @sql = @sql + REPLACE(@delete_field, ',', ' ') + ' AND output_type <>''f'''
	SET @del_sql = @del_sql + REPLACE(@delete_field, ',', ' ') + ' AND output_type <>''f'' AND termstart <>''' + @as_of_date + ''''
	SET @ParmDefinition = N'@del_count_out numeric(38,0) OUTPUT'
	

	EXECUTE sp_executesql @del_sql
		,@ParmDefinition
		,@del_count_out = @delete_count OUTPUT

 SET @desc =  'Data Generation process completed sucessfully. Following number of data has null fields in either of the columns:'+CAST(@delete_count as VARCHAR(100))
 
EXEC spa_ErrorHandler 0
				, 'spa_run_forecast_model'
				, 'spa_run_forecast_model'
				, 'Success'
				, @desc
				, ''
END TRY
BEGIN CATCH 
CLOSE db_cursor  
DEALLOCATE db_cursor 

	DECLARE @error_num INT,@error_msg VARCHAR(200),
	@error_proc VARCHAR(300)
	SELECT @error_num = error_number(),@error_msg=error_message(),@error_proc = ERROR_PROCEDURE()
		EXEC spa_ErrorHandler @error_num,@error_msg,@error_proc,@error_msg,'',@error_msg
END CATCH 





				
