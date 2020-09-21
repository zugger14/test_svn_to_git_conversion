IF OBJECT_ID(N'[dbo].[spa_display_price_curve]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_display_price_curve

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used for Returning different contract types for populating in the tree

	Parameters
	@flag : Operational flag
	@xml : Grid XML
	@source_price_curve : Source price curve id
	@curve_source_value : 
	@as_of_date_from : As of date from
	@as_of_date_to : As of date to
	@tenor_from : Tenor from date
	@tenor_to : Tenor from date
	@ask_bid : Value for ask_bid (y/n)
	@forward_settle : Value for forward or settle (f/s/b)
	@round_value : The round value to which curve values are rounded
	@process_id : The process table having price curve values
	@granularity : Granularity value (10Min, daily etc.)
	@source_curve_def_id : Source curve def id
	
*/

CREATE PROCEDURE [dbo].[spa_display_price_curve]
	@flag CHAR(1) = 's',
	@xml XML= NULL,
	@source_price_curve VARCHAR(MAX) = NULL,
	@curve_source_value VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@tenor_from VARCHAR(20) = NULL,
	@tenor_to VARCHAR(20) = NULL,
	@ask_bid CHAR(1) = 'y',
	@forward_settle CHAR(1) = 'b',
	@round_value VARCHAR(10) = 4,
	@process_id VARCHAR(200) = NULL,
	@granularity VARCHAR(20) = 'monthly',
	@source_curve_def_id varchar(500) = NULL
AS

SET NOCOUNT ON
  
/*TEST DATA    --

DECLARE @flag CHAR(1) = 's',
	@xml XML= NULL,
	@source_price_curve VARCHAR(max) = NULL,
	@curve_source_value VARCHAR(1000) = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@tenor_from VARCHAR(20) = NULL,
	@tenor_to VARCHAR(20) = NULL,
	@ask_bid CHAR(1) = 'y',
	@forward_settle CHAR(1) = 'b',
	@round_value VARCHAR(10) = 4,
	@process_id VARCHAR(200) = NULL,
	@granularity VARCHAR(20) = 'monthly',
	@source_curve_def_id varchar(500) = NULL

SELECT @flag='s',@source_price_curve='7174',@as_of_date_from='2019-03-31',@as_of_date_to='2019-05-17',@tenor_from='2019-05-18',@tenor_to='2019-05-31',@curve_source_value='4500',@round_value='4',@ask_bid='n',@forward_settle='b',@granularity='10Min'

--*/


BEGIN
	IF @flag = 't'
	BEGIN
		SELECT effective_date 
		FROM source_price_curve_def 
		WHERE source_curve_def_id = @source_price_curve
	END

DECLARE @header_detail CHAR(1)
DECLARE @select_sql VARCHAR(MAX)
DECLARE @where_sql VARCHAR(MAX)
DECLARE @order_sql VARCHAR(1000)
DECLARE @is_dst CHAR(1)
DECLARE @is_dst_default char(1)

IF @process_id IS NULL 
BEGIN 
	SET @header_detail = 'h' 
	SET @process_id = dbo.FNAGetNewID()
END

DECLARE @curve_source_list VARCHAR(5000)  = ''
DECLARE @curve_source_column_list_forward VARCHAR(max)  = ''
DECLARE @curve_source_column_list_forward_query VARCHAR(max)  = ''
DECLARE @curve_source_column_list_settled VARCHAR(max)  = ''
DECLARE @pivot_query_sql VARCHAR(MAX) = '' 
DECLARE @pivot_query_sql1 VARCHAR(MAX) = '' 
DECLARE @pivot_query_sql2 VARCHAR(MAX) = '' 
	DECLARE @pivot_query_sql3 VARCHAR(MAX) = ''
DECLARE @column_title_ask VARCHAR(MAX) = ''
DECLARE @column_title_bid VARCHAR(MAX) = '' 
DECLARE @column_title_mid VARCHAR(MAX) = ''
DECLARE @column_title_ask_s VARCHAR(MAX) = ''
DECLARE @column_title_bid_s VARCHAR(MAX) = '' 
DECLARE @column_title_mid_s VARCHAR(MAX) = ''
DECLARE @final_query VARCHAR(MAX) = ''
DECLARE @pivot_ask VARCHAR(MAX)=''
DECLARE @hourly_value CHAR(1)
DECLARE @colum_concat VARCHAR(MAX)
DECLARE @final_query_settle VARCHAR(MAX) = ''
DECLARE @process_table VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list',dbo.FNADBUser(),@process_id)
DECLARE @process_table_ask VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list_ask',dbo.FNADBUser(),@process_id)
DECLARE @process_table_bid VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list_bid',dbo.FNADBUser(),@process_id)
DECLARE @process_table_mid VARCHAR(500) = dbo.FNAProcessTableName('Price_Curve_list_mid',dbo.FNADBUser(),@process_id)
DECLARE @main_process_table VARCHAR(500) = dbo.FNAProcessTableName('Price_curve_main',dbo.FNADBUser(),@process_id)
DECLARE @hourly_header_table VARCHAR(500) = dbo.FNAProcessTableName('Hourly_header',dbo.FNADBUser(),@process_id)
DECLARE @grid_xml_table_name VARCHAR(500) = ''
DECLARE @delete_xml_table_name VARCHAR(500) = '';
DECLARE @curve_source_count INT = 0
DECLARE @query_insert VARCHAR(MAX) = ''
DECLARE @header_query VARCHAR(MAX) = ''
DECLARE @desc VARCHAR(500) = ''
DECLARE @table_name_settled VARCHAR(200)
DECLARE @table_name VARCHAR(1000) =''
DECLARE @settled_table_name VARCHAR(500) = dbo.FNAProcessTableName('Price_curve_main',dbo.FNADBUser(),@process_id)
DECLARE @granularity_id INT 
DECLARE @update_query VARCHAR(MAX) = ''
DECLARE @sql varchar(MAX) = ''
DECLARE @select_sql1 VARCHAR(MAX) 
DECLARE @where_sql1 VARCHAR(MAX) 
DECLARE @calc_result_derive VARCHAR(250)
DECLARE @time_zone VARCHAR(100)
DECLARE @default_dst_group_value_id VARCHAR(50)

	SET @calc_result_derive=dbo.FNAProcessTableName('calc_result_derive', dbo.FNADBUser(), @process_id)

	SET @main_process_table = @main_process_table + '_forward'

SELECT @table_name =  REPLACE(@main_process_table, 'adiha_process.dbo.', '')
SET @settled_table_name = @settled_table_name + '_settled'

SET @table_name_settled = REPLACE(@settled_table_name, 'adiha_process.dbo.', '')
DECLARE @count_settled INT = 0 

IF OBJECT_ID(N'tempdb..#as_of_date') IS NOT NULL
	DROP TABLE #as_of_date
IF OBJECT_ID(N'tempdb..#temp_header_list') IS NOT NULL
	DROP TABLE #temp_header_list			
IF OBJECT_ID(N'tempdb..#price_list') IS NOT NULL
	DROP TABLE #price_list
IF OBJECT_ID(N'tempdb..#column_header_list') IS NOT NULL
	DROP TABLE #column_header_list
IF OBJECT_ID(N'tempdb..#price_curve_column_header') IS NOT NULL
	DROP TABLE #price_curve_column_header
IF OBJECT_ID(N'tempdb..#price_curve_pivt') IS NOT NULL
	DROP TABLE #price_curve_pivt
IF OBJECT_ID(N'tempdb..#price_curve_ask') IS NOT NULL
	DROP TABLE #price_curve_ask
IF OBJECT_ID(N'tempdb..#price_curve_bid') IS NOT NULL
	DROP TABLE #price_curve_bid
IF OBJECT_ID(N'tempdb..#price_curve_mid') IS NOT NULL
	DROP TABLE #price_curve_mid
IF OBJECT_ID(N'tempdb..#price_curve_ask_s') IS NOT NULL
	DROP TABLE #price_curve_ask_s
IF OBJECT_ID(N'tempdb..#price_curve_bid_s') IS NOT NULL
	DROP TABLE #price_curve_bid_s
IF OBJECT_ID(N'tempdb..#price_curve_mid_s') IS NOT NULL
	DROP TABLE #price_curve_mid_s
	
IF OBJECT_ID(N'tempdb..#bid') IS NOT NULL
	DROP TABLE #bid
IF OBJECT_ID(N'tempdb..#ask') IS NOT NULL
	DROP TABLE #ask
IF OBJECT_ID(N'tempdb..#mid') IS NOT NULL
	DROP TABLE #mid
IF OBJECT_ID(N'tempdb..#overall') IS NOT NULL
	DROP TABLE #overall
IF OBJECT_ID(N'tempdb..#new_list') IS NOT NULL
	DROP TABLE #new_list
IF OBJECT_ID(N'tempdb..#curve_source_value_list ') IS NOT NULL
	DROP TABLE #curve_source_value_list
IF OBJECT_ID(N'tempdb..#source_price_curve_list ') IS NOT NULL
	DROP TABLE #source_price_curve_list
IF OBJECT_ID(N'tempdb..#grid_xml_process_table_name') IS NOT NULL
	DROP TABLE #grid_xml_process_table_name
IF OBJECT_ID(N'tempdb..#temp_price_curve') IS NOT NULL
	DROP TABLE #temp_price_curve	
IF OBJECT_ID(N'tempdb..#delete_xml_process_table_name') IS NOT NULL
	DROP TABLE #delete_xml_process_table_name
IF OBJECT_ID(N'tempdb..#curve_detail_data') IS NOT NULL
	DROP TABLE #curve_detail_data	
IF OBJECT_ID(N'tempdb..#settle_column_list') IS NOT NULL
	DROP TABLE #settle_column_list	
IF OBJECT_ID(N'tempdb..#maturity_date_list') IS NOT NULL
	DROP TABLE #maturity_date_list
IF OBJECT_ID(N'tempdb..#curve_detail_data_s') IS NOT NULL
	DROP TABLE #curve_detail_data_s
IF OBJECT_ID(N'tempdb..#curve_detail_data_f') IS NOT NULL
	DROP TABLE #curve_detail_data_f
	IF OBJECT_ID(N'tempdb..#temp_curve_detail_data_f') IS NOT NULL
		DROP TABLE #temp_curve_detail_data_f
IF OBJECT_ID(N'tempdb..#temp_header_list_old') IS NOT NULL
	DROP TABLE #temp_header_list_old
IF OBJECT_ID(N'tempdb..#dst') IS NOT NULL
	DROP TABLE #dst
IF OBJECT_ID(N'tempdb..#curve_value') IS NOT NULL
	DROP TABLE  #curve_value
IF OBJECT_ID(N'tempdb..#tmp_column') IS NOT NULL
	DROP TABLE  #tmp_column
IF OBJECT_ID(N'tempdb..#selected_curve_source_value_list') IS NOT NULL
	DROP TABLE  #selected_curve_source_value_list
IF OBJECT_ID(N'tempdb..#maturity_date_list_no_dst') IS NOT NULL
	DROP TABLE #maturity_date_list_no_dst

	SELECT @default_dst_group_value_id = tz.dst_group_value_id 
	,@is_dst_default = tz.apply_dst
	FROM dbo.adiha_default_codes_values (nolock)  adcv
	INNER JOIN time_zones tz 
		ON adcv.var_value = tz.TIMEZONE_ID  
	WHERE adcv.instance_no = 1 
		AND adcv.default_code_id = 36 
		AND adcv.seq_no = 1

IF @round_value = ''
BEGIN
	SET @round_value = 16;
END

IF @flag = 's'
BEGIN
 --BEGIN TRY

	DECLARE @effective_date DATE
	IF EXISTS (
		SELECT 1 FROM source_price_curve_def spcd
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_price_curve) sv
			ON sv.item = spcd.source_curve_def_id
		WHERE  spcd.effective_date = 'y')
	BEGIN
		SET @effective_date = (
				SELECT TOP 1 as_of_date
				FROM source_price_curve spc
				INNER JOIN dbo.SplitCommaSeperatedValues(@source_price_curve) sv
					ON sv.item = spc.source_curve_def_id
				WHERE as_of_date <= @as_of_date_from
				)
	END

	IF (@effective_date is NOT NULL)
	BEGIN
		SET @as_of_date_from = @effective_date
	END
	ELSE 	 
	BEGIN
		SET @as_of_date_from = NULLIF(@as_of_date_from,'')
	END

	SET @as_of_date_to = NULLIF(@as_of_date_to,'')
	
	IF @forward_settle <> 's'
	BEGIN
		SET @as_of_date_from = ISNULL(@as_of_date_from,@tenor_from)
    END

	IF @header_detail = 'h' 
	BEGIN
		SET @where_sql = ' WHERE 1 = 1'

		CREATE TABLE #source_price_curve_list(
			rowID int not null identity(1,1),
			price_curve_id INT,
			UNIQUE(price_curve_id) 
		)

		CREATE TABLE #curve_source_value_list(
			rowID int not null identity(1,1),
			curve_source_id INT
			UNIQUE(curve_source_id)
			)
		
		CREATE TABLE #overall( 
				value VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
				as_of_date VARCHAR(20) COLLATE DATABASE_DEFAULT ,
				ask_bid VARCHAR(20) COLLATE DATABASE_DEFAULT ,
				curve_name VARCHAR(50) COLLATE DATABASE_DEFAULT ,
				forward_settle CHAR(1) COLLATE DATABASE_DEFAULT 
			)

		CREATE TABLE #price_curve_column_header(	
					row_id INT IDENTITY(1,1),
					source_curve_def_id INT,
					curve_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
					curve_value FLOAT,
					as_of_date VARCHAR(12) COLLATE DATABASE_DEFAULT ,
					maturity_date VARCHAR(12) COLLATE DATABASE_DEFAULT ,
					curve_source_value_id INT,
					code VARCHAR(200) COLLATE DATABASE_DEFAULT ,
					ask FLOAT,
					column_header_ask VARCHAR(500) COLLATE DATABASE_DEFAULT ,
					bid Float,
					column_header_bid VARCHAR(500) COLLATE DATABASE_DEFAULT ,
					mid FLOAT,
					column_header_mid VARCHAR(500) COLLATE DATABASE_DEFAULT ,
					column_header varchar(500) COLLATE DATABASE_DEFAULT ,
					granularity VARCHAR(100) COLLATE DATABASE_DEFAULT ,
					[hour] VARCHAR(20) COLLATE DATABASE_DEFAULT ,
					forward_settle CHAR(1) COLLATE DATABASE_DEFAULT ,
					is_dst CHAR(1) COLLATE DATABASE_DEFAULT 
			)

		SELECT @granularity_id = sdv.value_id
		FROM static_data_value sdv
		WHERE sdv.[type_id] = 978
			AND code = @granularity

			SET @granularity = CASE 
				WHEN @granularity = '15min' THEN 'fifteen'
				WHEN @granularity = '30min' THEN 'thirty'
				WHEN @granularity = '10min' THEN 'rten'	
				WHEN @granularity = '5min' THEN 'zfive'
				WHEN @granularity = 'TOU Monthly' THEN 'monthly'
				WHEN @granularity = 'Monthly Hourly' THEN 'hourly'
				WHEN @granularity = 'TOU Daily' THEN 'Daily'
				ELSE @granularity 
			END
		
		IF @source_price_curve IS NOT NULL
		BEGIN	
			INSERT INTO #source_price_curve_list(price_curve_id)
				SELECT CAST(Item AS INT) price_curve_id 
				FROM  dbo.SplitCommaSeperatedValues(@source_price_curve)
		END
		
		SELECT TOP 1 @time_zone = tz.dst_group_value_id, @is_dst = tz.apply_dst
		FROM source_price_curve_def spcd
			INNER JOIN time_zones tz 
				ON spcd.time_zone = tz.timezone_id
			INNER JOIN #source_price_curve_list spcl 
				ON spcd.source_curve_def_id = spcl.price_curve_id

		Declare @dst_value VARCHAR(20) = ''

			
		IF(isnull(@is_dst,@is_dst_default) = 'y')
		BEGIN
			SET @dst_value = ISNULL(@time_zone,@default_dst_group_value_id)
		END

		SET @sql = '
			SELECT LEFT(clm_name,2) + '':'' + RIGHT(clm_name ,2) AS clm_name,
				alias_name,
				is_dst
			INTO ' + @hourly_header_table + '
			FROM [dbo].[FNAGetPivotGranularityColumn](''' + @tenor_from + ''',''' + @tenor_to + ''',''' + cast (@granularity_id as varchar(100) ) + ''','''+@dst_value+''') '
		
		EXEC(@sql)
	
		DECLARE @tenor_is_null BIT = 0

		IF NULLIF(@tenor_from,'') IS NULL AND NULLIF(@tenor_to,'') IS NULL
			SET @tenor_is_null = 1
			
		IF @tenor_from =''
		BEGIN
			SELECT @tenor_from = CONVERT(DATETIME,MIN(maturity_date),103)
			FROM source_price_curve spc
				INNER JOIN #source_price_curve_list spcl 
					ON spc.source_curve_def_id = spcl.price_curve_id
			WHERE as_of_date >= @as_of_date_from
		END

		IF @tenor_to = ''
		BEGIN
			SELECT @tenor_to = MAX(maturity_date) -- CONVERT(DATETIME,MAX(maturity_date),120)
			FROM source_price_curve spc
				INNER JOIN #source_price_curve_list spcl 
					ON spc.source_curve_def_id = spcl.price_curve_id
			WHERE as_of_date >=@as_of_date_from
		END
		ELSE 
		BEGIN
			IF @granularity = 'hourly'
			BEGIN 
			SET @tenor_to  = @tenor_to + ' 23:45:00'
			END

			ELSE IF @granularity = 'fifteen'
			BEGIN 
			SET @tenor_to  = @tenor_to + ' 23:45:00'
			END

			ELSE IF @granularity = 'thirty'
			BEGIN
			SET @tenor_to  = @tenor_to + ' 23:30:00'
			END

			ELSE IF @granularity = 'rten' 
			BEGIN 
			SET @tenor_to  = @tenor_to + ' 23:50:00'
			END

			ELSE IF @granularity = 'zfive' 
			BEGIN 
			SET @tenor_to  = @tenor_to + ' 23:55:00'
			END
		END

		IF @forward_settle <> 's'
		BEGIN
			SET @as_of_date_to = COALESCE(@as_of_date_to, @tenor_to, @tenor_from)
		END

		SELECT @hourly_value = 1
		FROM #source_price_curve_list s
			INNER JOIN source_price_curve_def spcd 
				ON spcd.source_curve_def_id = s.price_curve_id
		WHERE spcd.granularity IN (982,989,987,994,995,997)

		;WITH T(date)
			AS ( 
		SELECT CAST(@as_of_date_from As datetime)
		UNION ALL
		SELECT DateAdd(day,1,T.date) FROM T WHERE T.date < CAST(@as_of_date_to As datetime)
		)
		SELECT date INTO #as_of_date FROM T OPTION (MAXRECURSION 32767);
	
		IF @curve_source_value IS NOT NULL
		BEGIN
			INSERT INTO #curve_source_value_list(curve_source_id)
				SELECT CAST(Item AS INT) price_curve_id 
				FROM  dbo.SplitCommaSeperatedValues(@curve_source_value)
		END

			SELECT ROW_NUMBER() OVER (ORDER BY dbo.FNAdateformat(term_start)) as row_ord
				, @granularity_id granularity
		,CONVERT(date,term_start) as Maturity_date, term_end as maturity_date_end
		,CASE WHEN @hourly_value =1 THEN LEFT(Convert(VARCHAR(10),term_start,108),5) ELSE '00:00' END  as hour
		, is_dst
		INTO  #maturity_date_list
		FROM dbo.FNATermBreakdownDST(LEFT(@granularity,1),@tenor_from,@tenor_to,ISNULL(@time_zone,@default_dst_group_value_id))
		WHERE isnull(@is_dst,@is_dst_default) = 'y' 

		SELECT ROW_NUMBER() OVER (ORDER BY dbo.FNAdateformat(term_start)) as row_ord
				, @granularity_id granularity
		,CONVERT(date,term_start) as Maturity_date, term_end as maturity_date_end
		,CASE WHEN @hourly_value =1 THEN LEFT(Convert(VARCHAR(10),term_start,108),5) ELSE '00:00' END  as hour
		,0 is_dst
		INTO  #maturity_date_list_no_dst
		FROM dbo.FNATermBreakdown(LEFT(@granularity,1),@tenor_from,@tenor_to)
		WHERE  isnull(@is_dst,@is_dst_default)  = 'n' 

		INSERT INTO #maturity_date_list
		SELECT * FROM #maturity_date_list_no_dst
		
			SELECT  spcd.source_curve_def_id
				, b.date as_of_date,
				CASE 
					WHEN c.item = 'f' THEN dbo.FNADateFormat(CASE WHEN spcd.effective_date = 'y' THEN @as_of_date_to ELSE b.date END) +'::'
					ELSE '' 
				END + spcd.curve_name
				+ CASE 
					WHEN @curve_source_count > 1 THEN '::' + a.code
					ELSE '' 
				END
				+ CASE 
					WHEN @ask_bid = 'y' THEN '::' + d.item
					ELSE ''
				END column_header
				, c.item forward_settle
				, d.item ask_bid
				, a.curve_source_id curve_source_id
				, spcd.Granularity
				, c.forward_settle forward_settle_new
		INTO #temp_header_list_old
		FROM #source_price_curve_list spcl  
		INNER JOIN source_price_curve_def spcd 
		ON spcd.source_curve_def_id = spcl.price_curve_id
			CROSS APPLY(
				SELECT csvl.curve_source_id,sdv.code 
				FROM #curve_source_value_list csvl 
		INNER JOIN static_data_value sdv 
					ON sdv.value_id = csvl.curve_source_id AND sdv.type_id = 10007
			) a 
		CROSS APPLY(SELECT date FROM #as_of_date) b
			CROSS APPLY(
				SELECT item,spcd.forward_settle 
				FROM dbo.SplitCommaSeperatedValues('f,s')
			) c 
			OUTER APPLY(
				SELECT item,'f' as forward_settle,'y' as bid_ask 
				FROM  dbo.SplitCommaSeperatedValues('ask,bid,mid') 
				WHERE  @ask_bid = 'y'
			) d

			SELECT thl.source_curve_def_id, as_of_date, column_header, thl.forward_settle
				, ask_bid, curve_source_id, thl.granularity, forward_settle_new
		INTO  #temp_header_list
		FROM #temp_header_list_old thl
			LEFT JOIN source_price_curve_def spcd 
				ON spcd.source_curve_def_id = thl.source_curve_def_id
			WHERE ISNULL(thl.forward_settle_new,'') = CASE 
				WHEN spcd.forward_settle IS NULL THEN ISNULL(spcd.forward_settle,'')
				ELSE thl.forward_settle 
			END

			SET @select_sql = ' 
				INSERT INTO #price_curve_column_header (source_curve_def_id ,curve_name ,curve_value ,as_of_date, maturity_date ,curve_source_value_id ,code' 
					+ CASE 
						WHEN @ask_bid = 'y' THEN ',ask,column_header_ask,bid,column_header_bid,mid,column_header_mid'
						ELSE '' 
					END
					+ ',column_header,granularity'
					+ CASE 
						WHEN ISNULL(@hourly_value,0) = 1 THEN ',[hour]' 
						ELSE ''
					END 
					+ ',forward_settle,is_dst
				)
							SELECT spcd.source_curve_def_id,spcd.curve_name,ROUND(spc.~curve_value~,'+@round_value+') as curve_value,Convert(VARCHAR(12),spc.as_of_date,101),Convert(VARCHAR(12),spc.~maturity_date~,101)
							,spc.curve_source_value_id,sdv.code'
					+ CASE
						WHEN @ask_bid = 'y' THEN ', ROUND(spc.ask_value,' + @round_value + ') As ask_value
							, Convert(VARCHAR(12)
							, dbo.FNADateFormat(spc.as_of_date), 101)' + '+' + '''' + '::' + '''' + '+' + 'spcd.curve_name' + '+' + '''' + '::' + '''' + '+' + 'sdv.code' + '+' + '''' + '::' + '''' + '+' + '''' + 'ask' + '''' + ' As column_header_ask
							, ROUND(spc.bid_value, ' + @round_value + ') As bid_value
							, Convert(VARCHAR(12), dbo.FNADateFormat(spc.as_of_date), 101)' + '+' + '''' + '::' + '''' + '+' + 'spcd.curve_name' + '+' + '''' + '::' + '''' + '+' + 'sdv.code' + '+' + '''' + '::' + '''' + '+' + '''' + 'bid' + '''' + ' As column_header_bid
							, ROUND(spc.~curve_value~,'+@round_value+') mid_value' + '
							, Convert(VARCHAR(12), dbo.FNADateFormat(spc.as_of_date), 101)' + '+' + '''' + '::' + '''' + '+' + 'spcd.curve_name' + '+' + '''' + '::' + '''' + '+' + 'sdv.code' + '+' + '''' + '::' + '''' + '+' + '''' + 'mid' + ''''
						ELSE '' 
									END
					+ ', Convert(VARCHAR(12), dbo.FNADateFormat(spc.as_of_date), 101) ' + '+' + '''' + '::' + '''' + '+' + 'spcd.curve_name' + '+' + '''' + '::' + '''' + '+' + 'sdv.code AS column_header
					, sdv1.code as granularity '
					+ CASE 
						WHEN ISNULL(@hourly_value,0)=1 THEN ',LEFT(Convert(VARCHAR(10),spc.~maturity_date~,108),5)  as hour'
						ELSE ''
						   END
					+ ', CASE 
						WHEN spcd.Forward_Settle IS NULL THEN 
							CASE 
								WHEN spcd.exp_calendar_id IS NOT NULL THEN CASE 
									WHEN hg.hol_date = spc.~maturity_date~ AND hg.exp_date =spc.as_of_date THEN ''s''
									WHEN hg.hol_date IS NULL AND Convert(date,spc.~maturity_date~) = CONVERT(date,spc.as_of_date) THEN ''s''
									ELSE ''f'' 
								END
							ELSE CASE 
								WHEN Convert(date,spc.~maturity_date~) = CONVERT(date,spc.as_of_date) THEN ''s''
								ELSE ''f''
							END
						END
					ELSE 
						spcd.forward_settle
						END forward_settle
					,is_dst
				 FROM source_price_curve_def spcd 
					INNER JOIN #source_price_curve_list spcl
						ON spcd.source_curve_def_id = spcl.price_curve_id
						and isnull(spcd.derive_on_calculation,''n'')=''~y_n~''
					INNER JOIN ~source_price_curve~ spc 
						ON spc.~source_curve_def_id~ = spcl.price_curve_id
					and spc.curve_source_value_id=' + ISNULL(@curve_source_value, '4500') + '
					LEFT JOIN static_data_value sdv ON spc.curve_source_value_id = sdv.value_id AND sdv.type_id = 10007
					LEFT JOIN static_data_value sdv1 ON spcd.Granularity = sdv1.value_id and sdv1.type_id = 978
					LEFT JOIN holiday_group hg ON hg.hol_group_value_id =spcd.exp_calendar_id
						AND hg.hol_date = spc.~maturity_date~ AND hg.exp_date = spc.as_of_date
					LEFT JOIN static_data_value sdv2 ON sdv2.value_id = hg.hol_group_value_id AND sdv2.type_id = 10017
				'
						
			SET @where_sql = @where_sql 
				+ CASE 
					WHEN @as_of_date_from IS NOT NULL
					THEN ' AND spc.as_of_date >= '+''''+ @as_of_date_from +'''' 
					ELSE '' 
				END
				+ CASE
					WHEN @as_of_date_to IS NOT NULL THEN ' AND spc.as_of_date <= '+''''+ @as_of_date_to +''''
					ELSE '' 
				END
				+ CASE
					WHEN @tenor_from IS NOT NULL THEN ' AND spc.~maturity_date~ >= '+''''+ @tenor_from  +'''' 
					ELSE '' 
				END	  
				+ CASE
					WHEN @tenor_to IS NOT NULL THEN ' AND spc.~maturity_date~ <= '+''''+ @tenor_to +'''' 
					ELSE '' 
				END
						
		SET @order_sql = ' ORDER BY spcl.price_curve_id ASC'
			
			SET @select_sql1 = REPLACE(@select_sql, '~y_n~', 'n')
			SET @select_sql1 = REPLACE(@select_sql1, '~source_price_curve~', 'source_price_curve')
			SET @select_sql1 = REPLACE(@select_sql1, '~source_curve_def_id~', 'source_curve_def_id')
			SET @select_sql1 = REPLACE(@select_sql1, '~curve_value~', 'curve_value')
			SET @select_sql1 = REPLACE(@select_sql1, '~maturity_date~', 'maturity_date')
			
			SET @where_sql1 = REPLACE(@where_sql,'~maturity_date~', 'maturity_date')
			
		--print(@select_sql1)
		--print(@where_sql1)
		--print(@order_sql)
	
		EXEC (@select_sql1 + @where_sql1 + @order_sql)

			IF EXISTS (
				SELECT 1 
				FROM source_price_curve_def spcd 
				INNER JOIN #source_price_curve_list spcl
					ON spcd.source_curve_def_id = spcl.price_curve_id 
						AND ISNULL(spcd.derive_on_calculation,'n') = 'y'
			)		
			BEGIN
				EXEC [dbo].[spa_derive_curve_value] 
				@source_curve_def_id =@source_price_curve,
				@as_of_date_from =@as_of_date_from,
				@as_of_date_to =@as_of_date_to,
				@curve_source_value_id =@curve_source_value,
				@table_name = @calc_result_derive,
				@tenor_from  = @tenor_from,
				@tenor_to= @tenor_to,
					@curve_pracess_table = NULL
				SET @select_sql1 = REPLACE(@select_sql, '~y_n~', 'y')
					SET @select_sql1 = REPLACE(@select_sql1, '~source_price_curve~', @calc_result_derive)
					SET @select_sql1 = REPLACE(@select_sql1, '~source_curve_def_id~', 'curve_id')
					SET @select_sql1 = REPLACE(@select_sql1, '~curve_value~', 'formula_eval_value')
					SET @select_sql1 = REPLACE(@select_sql1, '~maturity_date~', 'prod_date')
					SET @where_sql1=REPLACE(@where_sql,'~maturity_date~', 'prod_date')

				--print(@select_sql1)
				--print(@where_sql1)
				--print(@order_sql)
			
				EXEC (@select_sql1 + @where_sql1 + @order_sql)
			END
	
			SELECT @curve_source_column_list_forward = @curve_source_column_list_forward
				+ CASE 
					WHEN  @curve_source_column_list_forward = '' THEN + '[' + column_header + ']' 
			ELSE ','+'[' + column_header +']'
				END
				, @curve_source_column_list_forward_query = @curve_source_column_list_forward_query 
				+ CASE 
					WHEN  @curve_source_column_list_forward_query = '' THEN + ' AND [' + column_header + '] IS NOT NULL ' 
															ELSE ' OR '+'[' + column_header +'] IS NOT NULL'
															END  
			FROM #temp_header_list
			WHERE forward_settle = 'f' 
			GROUP BY column_header
			ORDER BY MAX(as_of_date),MAX(source_curve_def_id)

			--SELECT * FROM #temp_header_list where forward_settle = 'f'
			SELECT DISTINCT column_header INTO #settle_column_list FROM #temp_header_list WHERE forward_settle = 's' 

	SELECT @count_settled = count(*) FROM #settle_column_list
		
	IF (@count_settled > 0)
	BEGIN
		SELECT  @curve_source_column_list_settled = @curve_source_column_list_settled + 
				CASE WHEN  @curve_source_column_list_settled = '' THEN  
					+'[' + column_header +']' 
				ELSE ','+'[' + column_header +']'
				END  
		FROM #settle_column_list
	 END

 
 	SELECT pcch.maturity_date,pcch.curve_value,pcch.ask,pcch.bid,pcch.forward_settle a,(pcch.curve_value) mid,
		thl.source_curve_def_id,ISNULL(thl.as_of_date,pcch.as_of_date)as_of_date,thl.column_header,thl.forward_settle,ask_bid,
				CASE 
					WHEN @hourly_value = 1 THEN [hour] 
					ELSE CONVERT(VARCHAR,CAST(0 as DATETIME),108) 
				END [hour],
		is_dst
	INTO #curve_detail_data
		FROM #temp_header_list thl
			LEFT JOIN #price_curve_column_header pcch 
				ON ISNULL(thl.as_of_date,pcch.as_of_date) =pcch.as_of_date 
				AND thl.source_curve_def_id = pcch.source_curve_def_id
				AND pcch.forward_settle = thl.forward_settle
				AND pcch.curve_source_value_id = thl.curve_source_id
	
	SELECT *  INTO #curve_detail_data_s 
			FROM #curve_detail_data 
			WHERE forward_settle = 's' 
				OR forward_settle IS NULL 
			ORDER BY column_header asc

			SELECT * 
			INTO #curve_detail_data_f 
			FROM #curve_detail_data 
			WHERE forward_settle = 'f' 
				OR forward_settle IS NULL

			SELECT c1.source_curve_def_id,c1.maturity_date, c1.column_header, c2.effective_date, MAX(c1.as_of_date) as_of_date
				INTO #temp_curve_detail_data_f
			FROM #curve_detail_data_f c1
			INNER JOIN source_price_curve_def c2 ON c2.source_curve_def_id = c1.source_curve_def_id
			WHERE c2.effective_date = 'y' AND c1.as_of_date <= CAST(@as_of_date_to AS DATETIME)
			group by c1.source_curve_def_id,c1.maturity_date, c1.column_header, c2.effective_date
			--order by c1.source_curve_def_id,c1.maturity_date, c1.column_header, c2.effective_date

			DELETE c1
			FROM #curve_detail_data_f c1
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = c1.source_curve_def_id
			LEFT JOIN #temp_curve_detail_data_f c2 ON c1.source_curve_def_id = c2.source_curve_def_id 
								AND c1.maturity_date = c2.maturity_date 
								AND c1.column_header = c2.column_header 
								AND  c1.as_of_date = c2.as_of_date
			WHERE c2.maturity_date IS NULL AND spcd.effective_date = 'y'




	SET @pivot_query_sql = 'SELECT * '
		
	IF @ask_bid = 'n'   
	BEGIN 			
				IF (@count_settled>0) 
					BEGIN
					SET @pivot_query_sql1 = ''
						SET @pivot_query_sql2 = ''
				
					SET @pivot_query_sql1 = ' 
						INTO '+ @settled_table_name + ' 
						FROM ( 
							SELECT row_ord, dbo.FNAdateformat(md.Maturity_date) as [Maturity Date], forward_settle, md.is_dst is_dst, dbo.FNAdateformat(as_of_date) as as_of_date '
							+ CASE WHEN ISNULL(@hourly_value,0)= 1 THEN ',ISNULL(cdd.[hour],md.[hour]) [Hour]' 
								ELSE ',''00:00'' as [hour]' 
							END 
							+ ',column_header,curve_value 
							FROM #maturity_date_list md 
							LEFT JOIN #curve_detail_data_s cdd 
								ON cdd.maturity_date = md.Maturity_date
							 AND  CONVERT(VARCHAR,CAST(cdd.[hour] as DATETIME),108) = CONVERT(VARCHAR,CAST(md.[hour] as DATETIME),108) 
							 AND DATEPART(mi,cdd.[hour]) = DATEPART(mi,md.[hour])
							 AND md.is_dst = cdd.is_dst
							WHERE forward_settle =''s'' 
								OR forward_settle is NULL ' 
								+ CASE 
									WHEN @tenor_is_null = 1 THEN ' AND as_of_date IS NOT NULL' 
									ELSE '' 
								END
								+' 
						) up
						PIVOT (AVG(curve_value) FOR column_header IN (
					'
							SET @pivot_query_sql2 = @curve_source_column_list_settled+')) AS PVT'
				
							--print(@pivot_query_sql+@pivot_query_sql1+@pivot_query_sql2)
							EXEC(@pivot_query_sql+@pivot_query_sql1+@pivot_query_sql2) 
				END

				IF  ((@forward_settle = 'f' OR @forward_settle = 'b') AND NULLIF(@curve_source_column_list_forward,'') IS NOT NULL )
					BEGIN
						SET @pivot_query_sql1 = ''
						SET @pivot_query_sql2 = ''
					SET @pivot_query_sql1 = ' 
						INTO ' + @main_process_table + ' 
						FROM ( 
							SELECT  row_ord,dbo.FNAdateformat(md.Maturity_date) as [Maturity Date],forward_settle,md.is_dst is_dst '
							+ CASE 
								WHEN ISNULL(@hourly_value,0)= 1 THEN ',ISNULL(cdd.[hour],md.[hour]) [Hour]' 
								ELSE ',''00:00'' as [hour]' 
							END
							+ ',column_header, curve_value
							FROM #maturity_date_list md 
							LEFT JOIN #curve_detail_data_f cdd 
								ON cdd.maturity_date = md.Maturity_date
							 AND  CONVERT(VARCHAR,CAST(cdd.[hour] as DATETIME),108) = CONVERT(VARCHAR,CAST(md.[hour] as DATETIME),108)
							 AND md.is_dst = cdd.is_dst 
									AND DATEPART(mi,cdd.[hour]) = DATEPART(mi,md.[hour]) 
							WHERE forward_settle =''f'' 
								OR forward_settle is NULL
						) up
				
						PIVOT (AVG(curve_value) FOR column_header IN (
					'
				
					SET @pivot_query_sql2 = ISNULL(@curve_source_column_list_forward,'')+')
						) AS PVT 
						WHERE 1 = 1 '
						+ CASE 
							WHEN @tenor_is_null = 1 THEN @curve_source_column_list_forward_query 
							ELSE ''
						END

							--print(@pivot_query_sql+@pivot_query_sql1+@pivot_query_sql2)
							EXEC(@pivot_query_sql+@pivot_query_sql1+@pivot_query_sql2)
			--RETURN
					END
			END			
	ELSE IF @ask_bid = 'y'
	BEGIN	
		--ASK
				SET @pivot_ask = ',ISNULL(md.is_dst,0) is_dst '
					+ CASE 
					WHEN ISNULL(@hourly_value,0)= 1 THEN ', ISNULL(cdd.[hour],md.[hour]) [hour]' 
					ELSE ', 0 as [hour]' 
				END

		SELECT DISTINCT column_header column_header_ask,as_of_date,'1' ask_bid,source_curve_def_id,forward_settle 
			INTO #price_curve_ask 
				FROM #temp_header_list 
				WHERE ask_bid = 'ask'

				SELECT @column_title_ask = @column_title_ask 
					+ CASE 
						WHEN  @column_title_ask = '' THEN  +'[' + column_header_ask +']' 
						ELSE ','+'[' + column_header_ask +']' 
					END  
				FROM #price_curve_ask 
				WHERE forward_settle = 'f'

				SELECT DISTINCT column_header_ask 
				INTO #price_curve_ask_s 
				FROM #price_curve_ask 
				WHERE forward_settle = 's' 
				GROUP BY column_header_ask

				SELECT  @column_title_ask_s = @column_title_ask_s 
					+ CASE 
						WHEN  @column_title_ask_s = '' THEN  +'[' + column_header_ask +']' 
						ELSE ','+'[' + column_header_ask +']'
					END  
		FROM #price_curve_ask_s 		

		IF @column_title_ask != ''
		BEGIN
					EXEC(
						@pivot_query_sql + ' 
						INTO '+ @process_table_ask +' 
						FROM ( 
							SELECT row_ord, md.Maturity_date [Maturity Date], forward_settle' + @pivot_ask +', column_header, ''1'' ask_bid, ask  
			FROM  #maturity_date_list md 
							LEFT JOIN #curve_detail_data_f cdd  
								ON cdd.maturity_date=md.Maturity_date 
			AND md.is_dst = cdd.is_dst
			AND CONVERT(VARCHAR,CAST(cdd.[hour] as DATETIME),108) = CONVERT(VARCHAR,CAST(md.[hour] as DATETIME),108) 
			   AND DATEPART(mi,cdd.[hour]) = DATEPART(mi,md.[hour])
							WHERE ask_bid = ''ask'' 
								OR ask_bid IS NULL 
								AND ISNULL(forward_settle,''f'') =''f'' 
						) up
						PIVOT (AVG(ask) 
							FOR column_header IN (' + @column_title_ask + ')
						) AS PVT1'
					)
		END
		
		IF @column_title_ask_s !=''
		BEGIN
					EXEC (
						@pivot_query_sql + ' 
						INTO ' + @process_table_ask + '_s' + ' 
						FROM (
							SELECT row_ord, md.Maturity_date [Maturity Date], as_of_date, forward_settle' + @pivot_ask +', column_header, ''1'' ask_bid, ask  
							FROM #maturity_date_list md 
							LEFT JOIN #curve_detail_data_s cdd
								ON ISNULL(cdd.maturity_date, '''') = ISNULL(md.Maturity_date, '''') 
								AND md.is_dst = cdd.is_dst 
								AND CONVERT(VARCHAR, CAST(cdd.[hour] as DATETIME), 108) = CONVERT(VARCHAR, CAST(md.[hour] as DATETIME), 108)
								AND DATEPART(mi, cdd.[hour]) = DATEPART(mi, md.[hour])
							WHERE ask_bid = ''ask''
								OR  ask_bid IS NULL 
								AND ISNULL(forward_settle,''s'') = ''s'' 
						) up
						PIVOT (AVG(ask) 
							FOR column_header IN (' + @column_title_ask_s + ')
						) AS PVT1'
					)
		END

--BID
		SELECT DISTINCT column_header column_header_bid,as_of_date,'2' ask_bid,source_curve_def_id,forward_settle
			INTO #price_curve_bid
				FROM  #temp_header_list
				WHERE ask_bid = 'bid'

				SELECT @column_title_bid = @column_title_bid
					+ CASE 
						WHEN  @column_title_bid = '' THEN  + '[' + column_header_bid + ']' 
						ELSE ',' + '[' + column_header_bid + ']'  
					END  
				FROM #price_curve_bid
				WHERE forward_settle = 'f'
		
				SELECT DISTINCT column_header_bid 
				INTO #price_curve_bid_s 
				FROM #price_curve_bid 
				WHERE forward_settle = 's' 
				GROUP BY column_header_bid

				SELECT  @column_title_bid_s = @column_title_bid_s 
					+ CASE 
						WHEN  @column_title_bid_s = '' THEN  +'[' + column_header_bid +']' 
						ELSE ','+'[' + column_header_bid +']'
					END  
		FROM #price_curve_bid_s
		 
		 IF @column_title_bid!=''
		 BEGIN
					EXEC (
						@pivot_query_sql + ' 
						INTO ' + @process_table_bid + ' 
						FROM ( 
							SELECT row_ord, md.Maturity_date [Maturity Date], forward_settle' + @pivot_ask +', column_header, ''2'' ask_bid, bid 
							FROM #maturity_date_list md 
							LEFT JOIN #curve_detail_data_f cdd
								ON cdd.maturity_date = md.Maturity_date 
									AND CONVERT(VARCHAR, CAST(cdd.[hour] as DATETIME), 108) = CONVERT(VARCHAR, CAST(md.[hour] as DATETIME), 108)
									AND md.is_dst = cdd.is_dst
									AND DATEPART(mi,cdd.[hour]) = DATEPART(mi,md.[hour])
							WHERE ask_bid = ''bid'' 
								OR  ask_bid IS NULL 
								AND ISNULL(forward_settle,''f'') =''f''
						) up
						PIVOT (AVG(bid) 
							FOR column_header IN (' + @column_title_bid + ')
						) AS PVT1'
					)
		END

		 IF @column_title_bid_s!=''
		 BEGIN
					EXEC (
						@pivot_query_sql+ ' 
						INTO ' + @process_table_bid + '_s' + ' 
						FROM (
							SELECT row_ord, md.Maturity_date [Maturity Date], as_of_date, forward_settle' + @pivot_ask +', column_header, ''2'' ask_bid, bid 
							FROM #maturity_date_list md
							LEFT JOIN #curve_detail_data_s cdd
								ON ISNULL(cdd.maturity_date, '''') = ISNULL(md.Maturity_date, '''') 
									AND CONVERT(VARCHAR, CAST(cdd.[hour] as DATETIME), 108) = CONVERT(VARCHAR, CAST(md.[hour] as DATETIME),108)
									AND md.is_dst = cdd.is_dst 
									AND DATEPART(mi,cdd.[hour]) = DATEPART(mi,md.[hour])
							WHERE ask_bid = ''bid'' 
								OR ask_bid IS NULL 
								AND ISNULL(forward_settle,''s'') =''s'' 
						) up
						PIVOT (AVG(bid) 
							FOR column_header IN (' + @column_title_bid_s + ')
						) AS PVT1'
					)
		 END
		
-- MID
		SELECT DISTINCT column_header column_header_mid,as_of_date,'3' ask_bid,source_curve_def_id,forward_settle 
			INTO #price_curve_mid
				FROM  #temp_header_list WHERE
		ask_bid = 'mid'

				SELECT @column_title_mid = @column_title_mid 
					+ CASE 
						WHEN  @column_title_mid = '' THEN  + '[' + column_header_mid + ']' 
						ELSE ',' + '[' + column_header_mid +']'  
					END  
				FROM #price_curve_mid 
				WHERE forward_settle = 'f'

		IF @column_title_mid !=''
		BEGIN
					EXEC (
						@pivot_query_sql+ ' 
						INTO '+ @process_table_mid +' 
						FROM (
							SELECT row_ord, md.maturity_date [Maturity Date], forward_settle' + @pivot_ask +', column_header, ''3'' ask_bid, mid 
							FROM  #maturity_date_list md 
							LEFT JOIN #curve_detail_data_f cdd  
								ON cdd.maturity_date=md.Maturity_date 
									AND CONVERT(VARCHAR, CAST(cdd.[hour] as DATETIME), 108) = CONVERT(VARCHAR, CAST(md.[hour] as DATETIME), 108)
									AND md.is_dst = cdd.is_dst
									AND DATEPART(mi, cdd.[hour]) = DATEPART(mi, md.[hour])
							WHERE ask_bid = ''mid'' 
							OR ask_bid IS NULL 
							AND ISNULL(forward_settle,''f'') =''f''
						) up
						PIVOT (AVG(mid) 
							FOR column_header IN (' + @column_title_mid + ')
						) AS PVT1'
					)
		END
		
				SELECT DISTINCT column_header_mid 
				INTO #price_curve_mid_s 
				FROM #price_curve_mid 
				WHERE forward_settle = 's' 
				GROUP BY column_header_mid

				SELECT  @column_title_mid_s = @column_title_mid_s 
					+ CASE 
						WHEN  @column_title_mid_s = '' THEN  + '[' + column_header_mid + ']' 
						ELSE ',' + '[' + column_header_mid + ']'  
					END  
					FROM #price_curve_mid_s  

		IF @column_title_mid_s !=''
		BEGIN
					EXEC (
						@pivot_query_sql+ ' 
						INTO '+ @process_table_mid + '_s' + ' 
						FROM (
							SELECT row_ord, md.maturity_date [Maturity Date], as_of_date, forward_settle' + @pivot_ask + ', column_header, ''3'' ask_bid, mid 
							FROM #maturity_date_list md	
							LEFT JOIN #curve_detail_data_s cdd 
							ON ISNULL(cdd.maturity_date, '''') = ISNULL(md.Maturity_date, '''') 
								AND CONVERT(VARCHAR, CAST(cdd.[hour] as DATETIME), 108) = CONVERT(VARCHAR, CAST(md.[hour] as DATETIME), 108)
								AND md.is_dst = cdd.is_dst 
								AND DATEPART(mi, cdd.[hour]) = DATEPART(mi, md.[hour])
							WHERE ask_bid = ''mid''
							OR ask_bid IS NULL
							AND ISNULL(forward_settle, ''s'') = ''s''
						) up
						PIVOT (AVG(mid) 
							FOR column_header IN (' + @column_title_mid_s + ')
						) AS PVT1'
					)
		END
	
				INSERT INTO #overall(
					value, as_of_date, ask_bid, curve_name, forward_settle
				)
				SELECT * FROM #price_curve_mid UNION ALL 
				SELECT * FROM #price_curve_bid UNION ALL
				SELECT * FROM #price_curve_ask
	
				DECLARE @c VARCHAR(MAX) = ''
	
		SELECT @c =@c+',['+CAST(value as VARCHAR(200)) + ']'
			FROM #overall 
			WHERE forward_settle = 'f'
		ORDER BY CONVERT(DATETIME,as_of_date,103) asc,curve_name asc,ask_bid asc
		
	IF @column_title_ask !='' AND @column_title_bid !='' AND @column_title_mid !='' 
	BEGIN
					SET @final_query = '
						SELECT  dbo.FNAdateformat(a.[maturity date]) [Maturity Date], ''f'' [forward_settle], a.is_dst, a.row_ord'
							+ CASE 
								WHEN ISNULL(@hourly_value, 0) = 1 THEN ', a.[hour]' 
								ELSE ',''00:00'' as [hour]'
									END
							+ @c + ' 
						INTO ' + @main_process_table + ' 
						FROM ' 
						+ CASE 
							WHEN @ask_bid = 'y' THEN @process_table_ask + ' a ' + ' 
								INNER JOIN ' + @process_table_bid + ' c 
									ON c.[maturity date] = a.[maturity date] 
										AND c.is_dst = a.is_dst' 
										+ CASE 
											WHEN @hourly_value = 1 THEN ' AND c.[hour] = a.[hour]' 
											ELSE ''
										END
								+ ' INNER JOIN ' + @process_table_mid + ' d 
										ON d.[maturity date] = a.[maturity date] 
											AND d.is_dst=a.is_dst'
											+ CASE 
												WHEN @hourly_value = 1 THEN ' AND d.[hour] = a.[hour]' 
												ELSE '' 
											END 
							ELSE  @process_table +' a ' 
						END
			--print (@final_query)
			EXEC (@final_query)
		END
	
		DECLARE @d VARCHAR(8000)
		SET @d = ''

				SELECT DISTINCT Value 
				INTO #new_list 
				FROM #overall 
			WHERE forward_settle = 's'
		GROUP BY value
		 
		SELECT  @d = @d+',['+CAST(value as VARCHAR(200)) + ']'
		FROM #new_list	

	IF @ask_bid = 'y' 
	BEGIN
		IF @column_title_ask_s !='' AND @column_title_bid_s !='' AND @column_title_mid_s !='' 
			BEGIN
						SET @final_query = '
							SELECT DISTINCT dbo.FNAdateformat(a.[maturity date]) [Maturity Date],''s'' [forward_settle], dbo.FNAdateformat(a.as_of_date) as_of_date, a.is_dst, a.row_ord'
								+ CASE 
									WHEN ISNULL(@hourly_value, 0) = 1 THEN ', a.[hour]' 
									ELSE ',''00:00'' as [hour]'
								END
								+ @d + ' 
							INTO ' + @settled_table_name + ' 
							FROM ' + @process_table_ask + '_s' + ' a ' + '
							INNER JOIN ' + @process_table_bid + '_s' + ' c 
								ON ISNULL(CONVERT(DATETIME, c.[as_of_date], 103), -1) = ISNULL(CONVERT(DATETIME, a.[as_of_date], 103), -1) 
									AND c.[maturity date] = a.[maturity date] 
									AND a.is_dst = c.is_dst '
									+ CASE 
										WHEN @hourly_value = 1 THEN ' AND c.[hour] = a.[hour] ' 
										ELSE '' 
									END + '
							INNER JOIN ' + @process_table_mid + '_s' + ' d
								ON ISNULL(CONVERT(DATETIME , d.[as_of_date] , 103), -1) = ISNULL(CONVERT(DATETIME, a.[as_of_date], 103), -1)
									AND d.[maturity date] = a.[maturity date] 
									AND a.is_dst = d.is_dst '
									+ CASE 
										WHEN @hourly_value = 1 THEN ' AND d.[hour] = a.[hour] ' 
										ELSE '' 
									END + '
							 WHERE ISNULL(a.[forward_settle], ''s'') = ''s''
						'	
		
						--print (@final_query)
		   				EXEC (@final_query)
			END
	END
			END	
	
			SET @header_query = ' 
				SELECT ROW_NUMBER() OVER (ORDER BY [forward settle], column_id) a, * 
				FROM (
					SELECT c.name, ' + '''' + @process_id + '''' + ' as process_id , ''f'' AS [forward settle], c.column_id
						, CASE 
							WHEN c.name = ''Maturity Date'' THEN ''a_1''
				WHEN c.name = ''forward_settle''  THEN ''a_2'' 
				WHEN c.name = ''hour''  THEN ''a_3'' 
				WHEN c.name = ''is_dst''  THEN ''a_4'' 
							ELSE ''a_5'' 
						END a2
					FROM adiha_process.sys.[columns] c 
					INNER JOIN adiha_process.sys.tables t 
						ON t.object_id = c.object_id
					WHERE t.name  =' + '''' + @table_name + '''
			'
			
			SET @header_query = @header_query + ' UNION ALL 
				SELECT c.name, ' + '''' + @process_id + '''' + ' AS process_id, ''s'' AS [forward settle], c.column_id
					, CASE 
						WHEN c.name = ''as_of_date''THEN ''b_0''
			   WHEN c.name = ''Maturity Date'' THEN ''b_1''
				WHEN c.name = ''forward_settle''  THEN ''b_2'' 
				WHEN c.name = ''hour''  THEN ''b_3'' 
				WHEN c.name = ''is_dst''  THEN ''b_4'' 
						ELSE ''b_5'' 
					END a2
				FROM adiha_process.sys.[columns] c 
				INNER JOIN adiha_process.sys.tables t 
					ON t.object_id = c.object_id
				WHERE t.name  = ' + '''' + @table_name_settled + '''
			' 

			SET @header_query = @header_query+ ') a1 
				WHERE name <> ''row_ord'' '
				+ CASE 
					WHEN @forward_settle <> 'b' THEN ' AND a1.[forward settle] = ' + '''' + @forward_settle +'''' 
					ELSE '' 
				END +' 
				ORDER by a2, a
			'
			
	EXEC(@header_query)
		END
	ELSE 
	BEGIN
		DECLARE @ParmDefinition nVARCHAR(500) = ''
			DECLARE @header_list nVARCHAR(MAX) = ''
			DECLARE @header_query_1 nVarchar(MAX)
			SET @header_query_1 = ''
			SET @table_name = '' 
			SET @table_name_settled = ''
			SELECT @table_name =  REPLACE(@main_process_table, 'adiha_process.dbo.', '')
			SET @table_name_settled = REPLACE(@settled_table_name, 'adiha_process.dbo.', '')
			SET @ParmDefinition = N' @head varchar(MAX) OUTPUT';

			SET @header_query_1 =  '
			IF OBJECT_ID(N''tempdb..#temp_table'') IS NOT NULL
				DROP TABLE #temp_table

				SELECT ROW_NUMBER() OVER (ORDER BY [forward settle],name,column_id) a  ,* 
				INTO #temp_table 
				FROM ('
					+ CASE 
						WHEN @forward_settle = 'f' THEN '
							SELECT c.name, '+''''+@process_id+'''' +' as process_id,''f'' AS [forward settle], c.column_id
								, CASE 
									WHEN c.name = ''Maturity Date'' THEN ''a_1''
											WHEN c.name = ''forward_settle''  THEN ''a_2''
											WHEN c.name = ''hour''  THEN ''a_3''
											WHEN c.name = ''is_dst''  THEN ''a_4'' 
									ELSE ''a_5''
								END a2
							FROM adiha_process.sys.[columns] c 
							INNER JOIN adiha_process.sys.tables t 
								ON t.object_id = c.object_id 
							WHERE t.name = ' + '''' + @table_name + '''
						'
						ELSE '
							SELECT c.name, '+''''+@process_id+'''' +' as process_id,''s'' AS [forward settle], c.column_id
								, CASE 
									WHEN c.name = ''Maturity Date'' THEN ''b_1''
						WHEN c.name = ''forward_settle''  THEN ''b_2''
						WHEN c.name = ''as_of_date''  THEN ''b_0''
						WHEN c.name = ''hour''  THEN ''b_3''
						WHEN c.name = ''is_dst''  THEN ''b_4''
									ELSE ''b_5'' 
								END a2
							FROM adiha_process.sys.[columns] c 
							INNER JOIN adiha_process.sys.tables t ON t.object_id = c.object_id 
							WHERE t.name = ' + '''' + @table_name_settled + '''
						' 
			END

			SET @header_query_1 = @header_query_1 + ') a1 '
				+ CASE 
					WHEN @forward_settle <> 'b' THEN ' WHERE a1.[forward settle] = ' + '''' + @forward_settle + '''' 
					ELSE '' 
				END +
				' ORDER BY a2
			
				SET @head = ''''
				SELECT @head = @head 
					+ CASE 
						WHEN name  <> ''Row_ord'' THEN
							CASE 
								WHEN @head = '''' THEN + ''['' + name + '']'' 
								ELSE +'',[''+ name +'']'' 
							END 
						ELSE '''' 
					END
				FROM #temp_table 
				ORDER BY a2, column_id
			'
			
			--print @header_query_1
			EXEC sp_executesql @header_query_1,@ParmDefinition, @head=@header_list OUTPUT;
		
			IF @forward_settle ='f'
			BEGIN
				DECLARE @forward_paging_process_table VARCHAR(500) = dbo.FNAProcessTableName('price_curve_forward_paging',dbo.FNADBUser(),@process_id)
				
				EXEC('
					SELECT IDENTITY(INT, 1, 1) AS id, ' + @header_list + ' 
					INTO ' + @forward_paging_process_table + ' 
					FROM ' + @main_process_table + ' 
					WHERE [maturity date] IS NOT NULL 
					ORDER BY YEAR(dbo.FNAClientToSqlDate([Maturity Date])), MONTH(dbo.FNAClientToSqlDate([Maturity Date])), DAY(dbo.FNAClientToSqlDate([Maturity Date])), DATEPART(hh, [hour]), ISNULL(is_dst, 0), DATEPART(mi, [hour])
				')

				SET @sql = '
					UPDATE mpt 
					SET [Hour] = hht.alias_name 
					FROM ' + @forward_paging_process_table + ' mpt 
					INNER JOIN ' + @hourly_header_table + ' hht 
						ON mpt.Hour = hht.clm_name 
							AND mpt.is_dst = hht.is_dst
				'

				EXEC(@sql)
				
				SELECT @forward_paging_process_table [process_table], @header_list [column_header]
			END
			ELSE
			BEGIN
				DECLARE @settle_paging_process_table VARCHAR(500) = dbo.FNAProcessTableName('price_curve_settle_paging',dbo.FNADBUser(),@process_id)
				
				EXEC('
					SELECT IDENTITY(INT, 1, 1) AS id, '+ @header_list +' 
					INTO ' + @settle_paging_process_table + ' 
					FROM ' + @settled_table_name  + ' 
					WHERE [maturity date] IS NOT NULL 
					ORDER BY YEAR(dbo.FNAClientToSqlDate([Maturity Date])), MONTH(dbo.FNAClientToSqlDate([Maturity Date])), DAY(dbo.FNAClientToSqlDate([Maturity Date])), DATEPART(hh, [hour]), ISNULL(is_dst, 0), DATEPART(mi, [hour]), as_of_date
				')

				SET @sql = '
					UPDATE mpt 
					SET [Hour] = hht.alias_name 
					FROM '+@settle_paging_process_table + ' mpt 
					INNER JOIN ' + @hourly_header_table + ' hht 
						ON mpt.Hour = hht.clm_name 
							AND mpt.is_dst = hht.is_dst
				'

				EXEC(@sql)

				SELECT @settle_paging_process_table [process_table], @header_list [column_header]
			END
	END
END
ELSE IF @flag = 'i'
	BEGIN
		BEGIN TRY
			DECLARE @grid_xml  VARCHAR(MAX)
			DECLARE @object_id VARCHAR(100)
			DECLARE @delete_xml VARCHAR(MAX)
			DECLARE @searchword VARCHAR(200)
			
			SELECT @time_zone = tz.dst_group_value_id,
			@granularity_id = spcd.Granularity
				FROM source_price_curve_def spcd
			LEFT JOIN time_zones tz 
				ON spcd.time_zone = tz.TIMEZONE_ID
				WHERE source_curve_def_id = @source_curve_def_id

			SET @xml= Convert(xml,@xml)

			SELECT @grid_xml = '<Root>'+CAST(col.query('.') AS VARCHAR(MAX))+'</Root>'
				FROM @xml.nodes('/Root/GridGroup/Grid') AS xmlData(col)
			
				SELECT @delete_xml = '<Root>'+CAST(col.query('.') AS VARCHAR(MAX))+'</Root>'
				FROM @xml.nodes('/Root/GridGroup/GridDelete') AS xmlData(col)  

			-- parse the Object ID
			SELECT @object_id = xmlData.col.value('@object_id','VARCHAR(100)')
			FROM @xml.nodes('/Root') AS xmlData(Col)   

		IF @grid_xml IS NOT NULL
				BEGIN
					CREATE TABLE #grid_xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  )

				INSERT INTO #grid_xml_process_table_name 
				EXEC spa_parse_xml_file 'b', NULL, @grid_xml
						
				SELECT @grid_xml_table_name = table_name 
				FROM #grid_xml_process_table_name

					DECLARE @tbl_name VARCHAR(200)

					SELECT @tbl_name = table_name
					FROM #grid_xml_process_table_name

				SET @sql = '
					DECLARE @dte_start VARCHAR(100)
						, @dte_end VARCHAR(100) 
												
													IF OBJECT_ID(N''tempdb..#temp_header_table'') IS NOT NULL
														DROP TABLE #temp_header_table

					SELECT @dte_start = MIN(maturity_date), @dte_end = MAX(maturity_date)
					FROM ' + @tbl_name + ''
				
				SET @sql += '
					SELECT * 
					INTO #temp_header_table 
					FROM [dbo].[FNAGetPivotGranularityColumn](IIF(ISNULL(@dte_start, '''') = '''', '''', @dte_start), 
						IIF(ISNULL(@dte_end, '''') = '''', ISNULL(@dte_start, ''''), ISNULL(@dte_end, '''')),
						''' + CAST(@granularity_id AS VARCHAR(50)) + ''',
						' + ISNULL(@time_zone, @default_dst_group_value_id) + '
					) a ' 

				SET @sql += '
					UPDATE gxptn 
					SET gxptn.hour = LEFT(tht.clm_name,2) + '':'' + RIGHT(tht.clm_name, 2) 
					FROM ' + @tbl_name + ' gxptn INNER JOIN #temp_header_table tht 
						ON REPLACE(gxptn.hour, ''DST'', '''') = REPLACE(tht.alias_name, ''DST'', '''') 
							AND tht.is_dst = gxptn.is_dst
				'

				EXEC (@sql)

					CREATE TABLE #temp_price_curve(
						price_curve_id INT PRIMARY KEY IDENTITY(1,1),
						as_of_date DATETIME NULL,
						Assessment_curve_type_value_id INT NULL,
						source_price_curve_def_id INT NULL,
						curve_source_value_id INT NULL,
						maturity_date  VARCHAR(25) COLLATE DATABASE_DEFAULT  NULL,
						curve_value FLOAT NULL,
						bid_value FLOAT NULL, 
						ask_value FLOAT NULL,
						mid_value FLOAT NULL,
						insert_update CHAR(1) COLLATE DATABASE_DEFAULT  NULL,
						forward_settle CHAR(1) COLLATE DATABASE_DEFAULT  NULL,
						is_dst CHAR(1) COLLATE DATABASE_DEFAULT  NULL,
						[hour] VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
					)
					
				SET @query_insert = '
					INSERT INTO #temp_price_curve(as_of_date, Assessment_curve_type_value_id, source_price_curve_def_id, curve_source_value_id
					, maturity_date, curve_value, bid_value, ask_value, mid_value, insert_update, forward_settle, is_dst, [hour])
				'

						SET @query_insert = @query_insert + '
					SELECT DISTINCT 
						CASE 
							WHEN a.as_of_date = '''' THEN 	
								CASE 
									WHEN spcd.exp_calendar_id IS NULL THEN CONVERT(VARCHAR, a.maturity_date, 101)
									ELSE CONVERT(VARCHAR, COALESCE(hg.exp_date, a.maturity_date), 101)
							END
							ELSE CONVERT(VARCHAR, a.as_of_date, 101)
						END  as_of_date, MAX(sdv1.value_id), spcd.source_curve_def_id, MAX(sdv.value_id)
						, a.maturity_date + '' '' + ISNULL(NULLIF(a.hour, ''''), ''00:00'') + '':00.000''
						, NULLIF(MAX(ISNULL(a.curve_value, a.mid)), '''')
						, NULLIF(MAX(CAST(a.bid AS FLOAT)), 0)
						, NULLIF(MAX(CAST(a.ask AS FLOAT)), 0)
						, NULLIF(MAX(CAST(a.mid AS FLOAT)), 0)
						, CASE 
							WHEN spc.source_curve_def_id IS NULL THEN ''i'' 
							ELSE ''u'' 
						END insert_update, a.forward_settle, a.is_dst, a.[hour]	 
					FROM ' + @grid_xml_table_name + ' a
					INNER JOIN source_price_curve_def spcd 
						ON spcd.curve_name = a.source_price_curve
					INNER JOIN static_data_value sdv 
						ON sdv.code = a.curve_source 
							AND sdv.type_id = 10007
					INNER JOIN static_data_value sdv1 
						ON sdv1.code = ''Forward'' 
							AND  sdv1.type_id = 75
					LEFT JOIN source_price_curve spc 
						ON CONVERT(CHAR(10), spc.maturity_date, 120) = a.maturity_date
								AND RIGHT(''0''+CAST(DATEPART(hh,spc.maturity_date) AS varchar(20)),2)+'':''+LEFT(CAST(DATEPART(mi,spc.maturity_date) AS VARCHAR(20))+''0'',2) = a.[hour]
								AND spc.curve_source_value_id = sdv.value_id
								AND spc.is_dst = a.is_dst
								AND spc.Assessment_curve_type_value_id = sdv1.value_id	
								AND spc.source_curve_def_id = spcd.source_curve_def_id
								AND ISNULL(spc.is_dst,0) = ISNULL(a.is_dst,0)
							AND spc.as_of_date = CASE 
								WHEN a.as_of_date <> '''' THEN a.as_of_date 
								 ELSE 
									CASE 
										WHEN spcd.exp_calendar_id IS NULL THEN CONVERT(VARCHAR, a.maturity_date, 101)
										WHEN spcd.exp_calendar_id IS NOT NULL 
											AND NOT EXISTS (
												SELECT 1 FROM holiday_group hg 
												WHERE hg.hol_group_value_id = spcd.exp_calendar_id 
													AND hg.hol_date = a.maturity_date
											) THEN CONVERT(VARCHAR, a.maturity_date, 101) 
										ELSE  (
											SELECT exp_date 
											FROM holiday_group hg 
											WHERE hg.hol_group_value_id = spcd.exp_calendar_id 
												AND hg.hol_date = a.maturity_date
										)  
									END 
							END
					LEFT JOIN holiday_group hg 
						ON hg.hol_group_value_id = spcd.exp_calendar_id 
							AND hg.hol_date = CONVERT(varchar, a.maturity_date, 101)
					LEFT JOIN static_data_value sdv2
						ON sdv2.value_id = hg.hol_group_value_id 
							AND sdv2.type_id = 10017
					GROUP BY a.maturity_date, a.as_of_date, a.forward_settle, hg.exp_date, spcd.exp_calendar_id, spcd.source_curve_def_id
						, spc.source_curve_def_id, [hour], a.is_dst
						'

						--print(@query_insert)
						EXEC(@query_insert)

				IF EXISTS(
					SELECT 1 FROM #temp_price_curve tpc 
					INNER JOIN lock_as_of_date laod 
						ON laod.close_date = tpc.as_of_date
				) --Check Lock As of Date
						BEGIN
							DECLARE @msg VARCHAR(100)
							DECLARE @close_date DATETIME
							SELECT TOP 1 @close_date  = as_of_date FROM #temp_price_curve
							SET @msg = 'As of Date (<b>' + dbo.FNADateFormat(@close_date) +  '</b>) has been locked. Please unlock first to proceed.'
	
							EXEC spa_ErrorHandler -1
							, 'lock_as_of_date' 
							, 'spa_lock_as_of_date'
							, 'Error'          
							, @msg
							, '' 
							RETURN
						END
					ELSE
				BEGIN
								-- Deleting value which is null
								DELETE source_price_curve
									FROM source_price_curve spc  	
					INNER JOIN #temp_price_curve t 
						ON dbo.FNADateFormat(spc.as_of_date) = dbo.FNADateFormat(t.as_of_date)
								AND dbo.FNADateFormat(spc.maturity_date) = dbo.FNADateFormat(t.maturity_date) 
							AND RIGHT('0' + CAST(DATEPART(hh, spc.maturity_date) AS VARCHAR(20)), 2) + ':' + LEFT(CAST(DATEPART(mi, spc.maturity_date) AS VARCHAR(20)) + '0', 2) = t.[hour]
								AND t.curve_value IS NULL
									AND t.is_dst = spc.is_dst
									AND spc.curve_source_value_id = t.curve_source_value_id 
									AND spc.Assessment_curve_type_value_id = t.Assessment_curve_type_value_id
									AND spc.source_curve_def_id = t.source_price_curve_def_id
								WHERE insert_update='u' 
								AND (ISNULL(spc.ask_value,'') IS NOT NULL AND t.ask_value IS NULL)
									AND (ISNULL(spc.bid_value,'') IS NOT NULL AND t.bid_value IS NULL )
				END
						
								UPDATE spc SET 
								spc.curve_value = CAST(COALESCE(NULLIF(t.curve_value,''),NULLIF(t.mid_value,''),NULLIF((ISNULL(t.ask_value,0)+ISNULL(t.bid_value,0))/CASE WHEN t.ask_value IS NULL OR t.bid_value IS NULL THEN 1 ELSE 2 END,NULL)) AS FLOAT),
								spc.bid_value =CAST(t.bid_value AS FLOAT) ,
								spc.ask_value =CAST(t.ask_value AS float),
								spc.update_ts = getDate(),
								spc.update_user = dbo.FNADBUser()	
									FROM #temp_price_curve t 
				INNER JOIN source_price_curve spc 
					ON spc.as_of_date = t.as_of_date
																	AND spc.maturity_date = t.maturity_date
																	AND spc.curve_source_value_id = t.curve_source_value_id 
																	AND spc.Assessment_curve_type_value_id = t.Assessment_curve_type_value_id
																	AND spc.source_curve_def_id = t.source_price_curve_def_id
																	AND spc.is_dst = t.is_dst
														WHERE t.insert_update = 'u'	
							
						INSERT INTO source_price_curve(as_of_date,Assessment_curve_type_value_id,curve_source_value_id,maturity_date,curve_value,bid_value,ask_value,is_dst,source_curve_def_id,create_user,create_ts)
					SELECT as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date
						, COALESCE(NULLIF(curve_value, ''), NULLIF(mid_value, ''), (ISNULL(ask_value, 0) + ISNULL(bid_value,0)) / CASE WHEN ask_value IS NULL OR bid_value IS NULL THEN 1 ELSE 2 END) c
						, NULLIF(bid_value,''), NULLIF(ask_value,'') a , ISNULL(is_dst,0), source_price_curve_def_id, dbo.FNADBUser(), getdate()
					FROM #temp_price_curve
					WHERE insert_update = 'i'

							SET @sql = dbo.FNAProcessDeleteTableSql(@grid_xml_table_name)							
							EXEC (@sql)
				END

				IF @delete_xml IS NOT NULL 
				BEGIN
					CREATE TABLE #delete_xml_process_table_name(table_name VARCHAR(200) COLLATE DATABASE_DEFAULT  )
				INSERT INTO #delete_xml_process_table_name 
				EXEC spa_parse_xml_file 'b', NULL, @delete_xml
				
						SELECT @delete_xml_table_name = table_name FROM #delete_xml_process_table_name
					
				SET @sql = '
					DECLARE @del_dte_start VARCHAR(100)
						, @del_dte_end VARCHAR(100)

						IF OBJECT_ID(N''tempdb..#temp_header_table_del'') IS NOT NULL
							DROP TABLE #temp_header_table_del

					SELECT  @del_dte_start = MIN(maturity_date), @del_dte_end = MAX(maturity_date) 
					FROM ' + @delete_xml_table_name + '
					SELECT * 
					INTO #temp_header_table_del 
					FROM [dbo].[FNAGetPivotGranularityColumn](IIF(ISNULL(@del_dte_start, '''') = '''', '''', @del_dte_start)
						, IIF(ISNULL(@del_dte_end, '''') = '''', ISNULL(@del_dte_start, ''''), ISNULL(@del_dte_end, ''''))
						,''' + CAST(@granularity_id AS VARCHAR(50)) + '''
						,' + ISNULL(@time_zone, @default_dst_group_value_id) + '
					) a

					UPDATE gxptn set gxptn.hour = LEFT(tht.clm_name, 2) + '':'' + RIGHT(tht.clm_name, 2) 
					FROM  ' + @delete_xml_table_name + ' gxptn 
					INNER JOIN #temp_header_table_del tht 
					ON REPLACE(gxptn.hour, ''DST'', '''') = REPLACE(tht.alias_name, ''DST'', '''') 
						AND tht.is_dst = gxptn.is_dst
				'
					EXEC(@sql)

					SET @query_insert=''
					
					SET @query_insert = @query_insert+ 'DELETE spc 
					FROM '+ @delete_xml_table_name + ' a
					INNER JOIN source_price_curve_def spcd 
						ON spcd.curve_name =  a.source_price_curve
					INNER JOIN static_data_value sdv 
						ON sdv.code = a.curve_source 
							AND sdv.type_id = 10007
					INNER JOIN source_price_curve spc
						ON spc.source_curve_def_id = spcd.source_curve_def_id 
							AND   CONVERT(CHAR(10),spc.maturity_date,120) =a.maturity_date							
							AND RIGHT(''0''+CAST(DATEPART(hh,spc.maturity_date) AS varchar(20)),2)+'':''+LEFT(CAST(DATEPART(mi,spc.maturity_date) AS VARCHAR(20))+''0'',2) = a.[hour]
							AND spc.curve_source_value_id = sdv.value_id
							AND spc.is_dst = a.is_dst
							AND spc.as_of_date = a.as_of_date
					'
				--print(@query_insert)
				EXEC(@query_insert)
					
						SET @sql = dbo.FNAProcessDeleteTableSql(@delete_xml_table_name)
						EXEC (@sql)
				END

					EXEC spa_ErrorHandler 0, 
					'Process Form Data', 
					'spa_display_price_curve', 
					'Success', 
					'Changes have been saved successfully.',
					''
		END TRY
		BEGIN CATCH
			DECLARE @error_id INT = ERROR_NUMBER()
			DECLARE @err VARCHAR(1024) = ''
			DECLARE @start_index VARCHAR(1024)
			DECLARE @constraint_name VARCHAR(1024)
			
			IF @error_id =2627 
			BEGIN
				 SET @err = ERROR_MESSAGE();
				 IF @error_id = 2627	--Unique Constraint
					BEGIN
						--	Find which table has been violated
						SET @table_name = 'source price curve'
						SET @err = 'Error Occurred<a href="#" onclick="$(this).next(''div'').toggle();"><br/><font size=1>Technical Details.</font></a>'		
						SET @err += '<div style="font-size:10px;color:red;display:none;" id="target">' + ERROR_MESSAGE() + '</div>'
						EXEC spa_ErrorHandler -1, 'Process Form Data', 
							'spa_display_price_curve', 'Error', 
							'Curve Value already Exists.', ''
					END
			END
			ELSE 
			BEGIN
				SET @desc = dbo.FNAHandleDBError('10151000')
				
				EXEC spa_ErrorHandler -1, 'Process Form Data', 
							'spa_display_price_curve', 'Error', 
							@desc, ''
			END
		END CATCH
	END

SET @sql = dbo.FNAProcessDeleteTableSql(@process_table)
EXEC (@sql)
IF @ask_bid = 'y'
	BEGIN
		SET @sql = dbo.FNAProcessDeleteTableSql(@process_table_ask)
		EXEC (@sql)
		SET @sql = dbo.FNAProcessDeleteTableSql(@process_table_bid)
		EXEC (@sql)
		SET @sql = dbo.FNAProcessDeleteTableSql(@process_table_mid)
		EXEC (@sql)
		SET @sql = dbo.FNAProcessDeleteTableSql(@process_table_ask+'_s')
		EXEC (@sql)
		SET @sql = dbo.FNAProcessDeleteTableSql(@process_table_bid+'_s')
		EXEC (@sql)
		SET @sql = dbo.FNAProcessDeleteTableSql(@process_table_mid+'_s')
		EXEC (@sql)
	END

	IF @flag = 'p'
	BEGIN
		SET @select_sql = '
			SELECT 
			spc.source_curve_def_id [Source Curve Def ID], 
			spcd.curve_id [Curve ID],
			spcd.curve_name [Curve Name],
			sdv.code [Curve Source], 
			dbo.FNADateFormat(spc.as_of_date) [As of Date], 
			dbo.FNADateFormat(spc.maturity_date) [Maturity Date],
			RIGHT(''0'' + RTRIM(DATEPART(hour, spc.maturity_date)), 2) + '':'' + RIGHT(''0'' + RTRIM(DATEPART(minute, spc.maturity_date)), 2)  [Hour],
			spc.is_dst [DST],
			spc.curve_value [Curve Value],
			spc.bid_value [Bid Value],
			spc.ask_value [Ask Value]
		FROM source_price_curve spc
		INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id = spcd.source_curve_def_id 
		LEFT JOIN static_data_value sdv ON sdv.value_id = spc.curve_source_value_id
		'

		IF @source_price_curve IS NOT NULL AND @source_price_curve <> ''
			SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @source_price_curve + ''') a ON spc.source_curve_def_id = a.item'

		IF @curve_source_value IS NOT NULL  AND @curve_source_value <> ''
			SET @select_sql += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @curve_source_value + ''') b ON spc.curve_source_value_id = b.item'
	
		SET @select_sql += ' WHERE 1 =1 '
	
		IF @as_of_date_from IS NOT NULL  AND @as_of_date_from <> ''
			SET @select_sql += ' AND spc.as_of_date >= ''' + @as_of_date_from + ''''

		IF @as_of_date_to IS NOT NULL  AND @as_of_date_to <> ''
			SET @select_sql += ' AND spc.as_of_date <= ''' + @as_of_date_to + ''''

		IF @tenor_from IS NOT NULL  AND @tenor_from <> ''
			SET @select_sql += ' AND spc.maturity_date >= ''' + @tenor_from + ''''

		IF @tenor_to IS NOT NULL  AND @tenor_to <> ''
			SET @select_sql += ' AND spc.maturity_date <= ''' + @tenor_to + ''''

		EXEC(@select_sql)
	END

	IF @flag IN ('v', 'z', 'x')
	BEGIN
		SELECT @granularity_id = spcd.Granularity
			,@time_zone = tz.dst_group_value_id
		FROM source_price_curve_def spcd
		LEFT JOIN time_zones tz 
			ON spcd.time_zone = tz.TIMEZONE_ID
		WHERE source_curve_def_id = @source_curve_def_id

		IF @flag = 'x'
		BEGIN
		SELECT IIF(is_dst=1,clm_name+'DST',clm_name) clm_name
			,alias_name
			FROM [dbo].[FNAGetPivotGranularityColumn](IIF(ISNULL(@tenor_from, '') = '', '', @tenor_from)
				, IIF(ISNULL(@tenor_to, '') = '', ISNULL(@tenor_from, ''), ISNULL(@tenor_to, ''))
				, @granularity_id
				, ISNULL(@time_zone, @default_dst_group_value_id)
			) a
		END

		IF @flag = 'v'
		BEGIN
			BEGIN TRY
				DECLARE @idoc INT = NULL
					,@reference_header VARCHAR(MAX)
					,@xml_header VARCHAR(MAX)
					,@pivot_header VARCHAR(MAX)
					,@process_table_name VARCHAR(800)
					,@unpivoted_process_table_name VARCHAR(800)
					,@deleted_data_process_table_name VARCHAR(800)
					,@unpivot_deleted_data_process_table_name VARCHAR(800)

				SET @process_table_name = dbo.FNAProcessTableName('price_curve_pivot_view', dbo.FNADBUser(), @process_id)
				SET @unpivoted_process_table_name = dbo.FNAProcessTableName('price_curve_unpivot_view', dbo.FNADBUser(), @process_id)
				SET @deleted_data_process_table_name = dbo.FNAProcessTableName('deleted_data_price_curve', dbo.FNADBUser(), @process_id)
				SET @unpivot_deleted_data_process_table_name = dbo.FNAProcessTableName('unpivot_deleted_price_curve', dbo.FNADBUser(), @process_id)

				EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

				IF OBJECT_ID('tempdb..#temp_pivot_curve_value') IS NOT NULL
					DROP TABLE #temp_pivot_curve_value

				IF OBJECT_ID('tempdb..#header_list') IS NOT NULL
					DROP TABLE #header_list

				SELECT @pivot_header = ISNULL(@pivot_header + ',', '') + CAST(a.clm_name AS VARCHAR(200))
				FROM (
					SELECT 'hr' + IIF(is_dst=1,clm_name+'DST',clm_name) clm_name
					FROM [dbo].[FNAGetPivotGranularityColumn](IIF(ISNULL(@tenor_from, '') = '', '', @tenor_from)
							, IIF(ISNULL(@tenor_to, '') = '', ISNULL(@tenor_from, ''), ISNULL(@tenor_to, ''))
							, @granularity_id
							, ISNULL(@time_zone, @default_dst_group_value_id)
					)
				) a

				SET @reference_header = 'as_of_date,curve_name,maturity_date,source_curve_def_id,' + @pivot_header

				IF @reference_header IS NOT NULL
				BEGIN
					IF EXISTS (SELECT 1 FROM OPENXML(@idoc, '/Root/GridGroup/Grid/GridRow', 2))
					BEGIN
						SELECT *
						INTO #header_list
						FROM dbo.SplitCommaSeperatedValues(@reference_header)

						SELECT @xml_header = ISNULL(@xml_header + ',', '') + CAST(a.item AS VARCHAR(2000))
						FROM (
							SELECT item + ' VARCHAR(200)' + '''' + '@' + item + '''' AS item
							FROM #header_list
							) a

						SET @sql = '
							DECLARE @idoc INT
								, @xml xml = ''' + cast(@xml AS VARCHAR(max)) + ''';  
						
							EXEC sp_xml_preparedocument @idoc OUTPUT, @xml 
						
							SELECT ' + @reference_header + ' 
							INTO ' + @process_table_name + '
									FROM  OPENXML(@idoc,''/Root/GridGroup/Grid/GridRow'',2)
							WITH (' + @xml_header + ')'

						EXEC (@sql)

						SET @sql = '
							SELECT r.source_curve_def_id, r.as_of_date, r.curve_name, r.maturity_date, r.is_dst, NULLIF(r.value,'''') value
								, LEFT(replace([time], ''hr'', '''') ,2) + 1 hour, RIGHT([time], IIF(is_dst = 1,3,2)) min 
							INTO ' + @unpivoted_process_table_name + '
							FROM (
								SELECT source_curve_def_id, as_of_date, curve_name
									, CAST(maturity_date + '' '' + LEFT(REPLACE([time],''hr'',''''), 2) + '':'' + RIGHT(REPLACE(REPLACE([time], ''hr'', ''''), ''DST'', ''''), 2) + '':00.000'' AS DATETIME) maturity_date
									, is_dst = IIF(RIGHT([time], 3) = ''DST'', 1, 0), [hour] [value], time
								FROM (
									SELECT ' + @reference_header + ' 
									FROM ' + @process_table_name + '
						) x
								UNPIVOT (
									[hour] FOR [time] IN (' + @pivot_header + ')
								) u
							) r
						'

						EXEC (@sql)

						SET @sql = '
							DELETE uptn 
							FROM ' + @unpivoted_process_table_name + ' AS uptn 
							INNER JOIN mv90_DST mvdst 
								ON convert(date, uptn.maturity_date) = convert(date, mvdst.date) 
							WHERE mvdst.insert_delete = ''d'' 
								AND uptn.hour = mvdst.hour 
								AND mvdst.dst_group_value_id = ' + ISNULL(@time_zone, @default_dst_group_value_id) + '
						'

						EXEC (@sql)

						SET @sql = '
							DELETE uptn 
							FROM ' + @unpivoted_process_table_name + ' AS uptn 
							LEFT JOIN mv90_DST mvdst 
								ON CONVERT(date, uptn.maturity_date) = CONVERT(date, mvdst.date) 
							WHERE mvdst.date is NULL and uptn.min = ''DST''
						'

						EXEC (@sql)

						SET @sql = 'DELETE ' + @unpivoted_process_table_name + ' WHERE value IS NULL'

						EXEC (@sql)

						SET @sql = '
							MERGE source_price_curve AS spc
								USING ' + @unpivoted_process_table_name + ' AS uptn
								ON (spc.source_curve_def_id = uptn.source_curve_def_id 
						  			AND spc.as_of_date = uptn.as_of_date 
									AND spc.maturity_date=uptn.maturity_date 
									AND spc.is_dst=uptn.is_dst
									) 
							WHEN NOT MATCHED BY TARGET THEN 
									INSERT(source_curve_def_id,as_of_date,maturity_date,curve_value,is_dst,Assessment_curve_type_value_id,curve_source_value_id) 
								VALUES(' + @source_curve_def_id + ', uptn.as_of_date, uptn.maturity_date, uptn.value, uptn.is_dst, 77, ' + ISNULL(@curve_source_value, '4500') + ')
							WHEN MATCHED THEN 
								UPDATE SET spc.curve_value = uptn.value
									, spc.is_dst=uptn.is_dst
									, as_of_date = uptn.as_of_date
									, maturity_date  = uptn.maturity_date
									, curve_source_value_id  = ' + ISNULL(@curve_source_value, '4500') + '
									;
						'

						EXEC (@sql)
					END

					-----------------------------------for deleting data--------------------------------------------------------
					IF OBJECT_ID('tempdb..#delete_header_list') IS NOT NULL
						DROP TABLE #delete_header_list

					IF EXISTS (SELECT 1 FROM OPENXML(@idoc, '/Root/GridGroup/GridDelete', 2))
					BEGIN
						SELECT *
						INTO #delete_header_list
						FROM dbo.SplitCommaSeperatedValues(@reference_header)

						SELECT @xml_header = ISNULL(@xml_header + ',', '') + CAST(a.item AS VARCHAR(500))
						FROM (
							SELECT item + ' VARCHAR(200)' + '''' + '@' + item + '''' AS item
							FROM #delete_header_list
							) a

						SET @sql = '
							DECLARE @idoc INT
								, @xml xml = ''' + CAST(@xml AS VARCHAR(MAX)) + ''';  
							
							EXEC sp_xml_preparedocument @idoc OUTPUT, @xml 
							SELECT ' + @reference_header + ' INTO ' + @deleted_data_process_table_name + '
									FROM  OPENXML(@idoc,''/Root/GridGroup/GridDelete/GridRow'',2)
									 WITH (
								' + @xml_header + '
							)'

						EXEC (@sql)

						SET @sql = '
							SELECT r.source_curve_def_id,r.as_of_date, r.curve_name, r.maturity_date, r.is_dst, r.value 
							INTO ' + @unpivot_deleted_data_process_table_name + ' 
							FROM (
								SELECT source_curve_def_id, as_of_date, curve_name
									, CAST(maturity_date + '' '' + LEFT(REPLACE([time], ''hr'', ''''), 2) + '':'' + RIGHT(REPLACE(REPLACE([time], ''hr'', ''''), ''DST'', ''''), 2) + '':00.000'' AS DATETIME) maturity_date
									, is_dst = IIF(RIGHT([time], 3) = ''DST'', 1, 0)
						  ,[hour] [value]
								FROM (
									SELECT ' + @reference_header + ' 
									FROM ' + @deleted_data_process_table_name + '
						) x
						unpivot (
									[hour] FOR [time] IN(' + @pivot_header + ')
								) u
							) r'

						EXEC (@sql)

						SET @sql = '
							DELETE spc 
							FROM source_price_curve spc 
							INNER JOIN ' + @unpivot_deleted_data_process_table_name + ' ddptn 
								ON spc.source_curve_def_id = ddptn.source_curve_def_id 
							WHERE spc.as_of_date = ddptn.as_of_date 
									AND spc.maturity_date=ddptn.maturity_date'

						EXEC (@sql)
					END
				END

				EXEC spa_ErrorHandler 0
					,'Process Form Data'
					,'spa_display_price_curve'
					,'Success'
					,'Changes have been saved successfully.'
					,''
			END TRY

			BEGIN CATCH
				EXEC spa_ErrorHandler - 1
					,'Process Form Data'
					,'spa_display_price_curve'
					,'Error'
					,'Error'
					,''
			END CATCH
		END

		IF @flag = 'z'
		BEGIN
			CREATE TABLE #selected_curve_source_value_list (
				rowID INT NOT NULL IDENTITY(1, 1)
				,curve_source_id INT UNIQUE (curve_source_id)
				)

			IF @curve_source_value IS NOT NULL
			BEGIN
				INSERT INTO #selected_curve_source_value_list (curve_source_id)
				SELECT CAST(Item AS INT) price_curve_id
				FROM dbo.SplitCommaSeperatedValues(@curve_source_value)
			END

			CREATE TABLE #curve_value (
				source_curve_def_id VARCHAR(500) COLLATE DATABASE_DEFAULT
				,as_of_date VARCHAR(10) COLLATE DATABASE_DEFAULT
				,curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT
				,maturity_date DATETIME
				,dt VARCHAR(10) COLLATE DATABASE_DEFAULT
				,hr VARCHAR(10) COLLATE DATABASE_DEFAULT
				,curve_value FLOAT
				)

			SET @sql = '
				INSERT INTO #curve_value (source_curve_def_id, as_of_date, curve_name, maturity_date, dt, hr, curve_value)
				SELECT spcd.source_curve_def_id, CONVERT(VARCHAR(10), spc.as_of_date, 120) as_of_date, spcd.curve_name, spc.maturity_date
					, CONVERT(VARCHAR(10), spc.maturity_date, 120) dt
					, RIGHT(''0'' + CAST(DATEPART(hour, spc.maturity_date) AS VARCHAR), 2) + RIGHT(''0'' + CAST(DATEPART(MINUTE, spc.maturity_date) AS VARCHAR), 2) + IIF(spc.is_dst = 1,''DST'', '''') hr
					, spc.curve_value
				FROM source_price_curve spc 
				INNER JOIN source_price_curve_def spcd 
					ON spc.source_curve_def_id = spcd.source_curve_def_id  
				INNER JOIN #selected_curve_source_value_list cs 
					ON cs.curve_source_id = spc.curve_source_value_id
				WHERE spc.curve_source_value_id = ' + @curve_source_value + '
					AND spcd.curve_name = ''' + @source_price_curve + ''' 
					AND spcd.Granularity = ' + CAST(@granularity_id AS VARCHAR(500)) 
					+ IIF(ISNULL(@as_of_date_from, '') = '', '', ' AND spc.as_of_date >= ''' + @as_of_date_from + '''') 
					+ IIF(ISNULL(@as_of_date_to, '') = '', '', ' AND spc.as_of_date <= ''' + @as_of_date_to + '''') 
					+ IIF(ISNULL(@tenor_from, '') = '', '', ' AND spc.maturity_date >= ''' + @tenor_from + '''') 
					+ IIF(ISNULL(@tenor_to, '') = '', '', ' AND spc.maturity_date <= ''' + @tenor_to + ' 23:59:00.000''')

			EXEC (@sql)

			DECLARE @grn_column VARCHAR(MAX)
				,@value_column VARCHAR(MAX)
				,@term_start VARCHAR(MAX)
				,@term_end VARCHAR(MAX)
				,@dst_group_value_id VARCHAR(MAX)
				,@header_name VARCHAR(MAX)

			SELECT clm_name
				,alias_name,is_dst
			INTO #tmp_column
			FROM [dbo].[FNAGetPivotGranularityColumn](IIF(ISNULL(@tenor_from, '') = '', '', @tenor_from)
				, IIF(ISNULL(@tenor_to, '') = '', ISNULL(@tenor_from, ''), ISNULL(@tenor_to, ''))
				, @granularity_id
				, ISNULL(@time_zone, @default_dst_group_value_id)
			)
			
			SELECT @value_column = ISNULL(@value_column + ',', '') + '[' + IIF(is_dst = 1, clm_name + 'DST', clm_name) + ']'
				, @grn_column = ISNULL(@grn_column + ',', '') + '[' + IIF(is_dst = 1,clm_name + 'DST', clm_name) + ']'
				FROM #tmp_column

			SELECT @header_name = ISNULL(@header_name + ',', '') + 'SUM([' + IIF(is_dst = 1, clm_name + 'DST', clm_name) + '])' + '[' + alias_name + ']'
				FROM #tmp_column

			SET @sql = '
				SELECT [Curve ID], [As Of Date], curve_name, dt, ' + @header_name + ' from (
					SELECT source_curve_def_id [Curve ID], as_of_date [As Of Date], curve_name, dt,' + @grn_column + ' 
					FROM (
						SELECT source_curve_def_id, as_of_date, curve_name, maturity_date, dt, hr, ROUND(ISNULL(curve_value, 0), ' + @round_value + ') curve_value
						FROM #curve_value
						) x
					pivot (
						SUM(curve_value) FOR hr IN (' + @value_column + ')
					) p
				)q 
				GROUP BY [Curve ID], [As Of Date], curve_name, dt'

			EXEC (@sql)
		END
	END
END
