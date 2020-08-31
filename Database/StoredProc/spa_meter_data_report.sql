IF OBJECT_ID('spa_meter_data_report') IS NOT NULL
	DROP PROC [dbo].[spa_meter_data_report]
GO
-- ===========================================================================================================
-- Params:
-- @meter_id VARCHAR(max)		- meter id
-- @location_id INT				- location id
-- @granularity INT				- Lower granularity (5Min, 10Min, 15Min, 30Min)(995, 994, 987, 989), Hourly = 982 and Monthly = 980
-- @prod_month_from DATETIME	- Date From
-- @prod_month_to DATETIME		- Date To
-- @hour_from INT				- Hour From
-- @hour_to INT					- Hour To
-- @grouping_option				- Report option Summary = 's' and Detail = 'd'
-- @format						- Report format Cross Tab = 'c' and Regular = 'r'
-- ===========================================================================================================
CREATE PROC [dbo].[spa_meter_data_report]
	@meter_id VARCHAR(max) = NULL,
	@location_id INT = NULL,
	@granularity INT = NULL,
	@prod_month_from DATETIME = NULL,
	@prod_month_to DATETIME = NULL,
	@hour_from INT = NULL,
	@hour_to INT = NULL,
	@grouping_option CHAR(1) = NULL,
	@format CHAR(1) = NULL,
	@round_value CHAR(2) = '0',
	@counterparty_id VARCHAR(MAX) = NULL,
	@commodity_id INT = NULL,
	@channel INT = NULL,
	@enhance_volume_flag CHAR(1) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,
	@page_size INT = NULL,
	@page_no INT = NULL
AS
/**************************TEST CODE START************************				
DECLARE	@meter_id VARCHAR(max) = 21,
		@location_id INT = NULL,
		@granularity INT = 994,
		@prod_month_from DATETIME = '2018-01-01',
		@prod_month_to DATETIME = '2018-01-31',
		@hour_from INT = NULL,
		@hour_to INT = NULL,
		@grouping_option CHAR(1) = 's',
		@format CHAR(1) = 'r',
		@round_value CHAR(2) = '2',
		@counterparty_id VARCHAR(MAX) = NULL,
		@commodity_id INT = NULL,
		@channel INT = '1',
		@enhance_volume_flag CHAR(1) = 'n',
		@batch_process_id VARCHAR(250) = 'FF86CE3A_5217_4A84_AE5A_3DB4189650CC_5b2774a2c3029',
		@batch_report_param VARCHAR(500) = 'spa_meter_data_report ''21'',NULL,''994'',''2018-01-01'',''2018-01-31'',NULL,NULL,''s'',''r'',''2'',NULL,NULL,''1'',''n''', 
		@enable_paging INT = 0,
		@page_size INT = NULL,
		@page_no INT = NULL	
			
--**************************TEST CODE END************************/		
BEGIN
SET NOCOUNT ON

DECLARE @sqlStmt VARCHAR(MAX), 
		@from INT,
		@to INT, 
		@hours VARCHAR(MAX),
		@tmp_pvt_table VARCHAR(200),
		@select VARCHAR(MAX),
		@listCol VARCHAR(MAX),
		@selectCol VARCHAR(MAX),
		@dstHour VARCHAR(100),
		@selectHourVolume VARCHAR(5000),
		@minusOne VARCHAR(5),
		@rowCount INT,		
		@dst_group_value_id INT

SELECT @dst_group_value_id = tz.dst_group_value_id
FROM dbo.adiha_default_codes_values adcv
INNER JOIN time_zones tz
	ON tz.timezone_id = adcv.var_value
WHERE adcv.instance_no = 1
	AND adcv.default_code_id = 36
	AND adcv.seq_no = 1
	
IF OBJECT_ID ('tempdb..#convert_time_format') IS NOT NULL
	DROP TABLE #convert_time_format
	
SELECT * 
INTO #convert_time_format
FROM dbo.FNAGetPivotGranularityColumn(@prod_month_from, @prod_month_to, @granularity, @dst_group_value_id)

			
SET @from = ISNULL(@hour_from, 1)
SET @to = ISNULL(@hour_to, 24)
SET @hours = ''

IF OBJECT_ID('tempdb..#tmp_calc_pvt_tbl') IS NOT NULL
	DROP TABLE #tmp_calc_pvt_tbl

CREATE TABLE #tmp_calc_pvt_tbl(
	[meter_id]		INT,
	[recorderid]	VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[location]		VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[counterparty]	VARCHAR(200) COLLATE DATABASE_DEFAULT ,
	[prod_date]		DATETIME,
	[Volume]		NUMERIC(38,20),
	[uom_name]		VARCHAR(100) COLLATE DATABASE_DEFAULT 
)
/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000),
			@user_login_id VARCHAR(50),
			@sql_paging VARCHAR(8000),
			@is_batch BIT
			 
	SET @user_login_id = dbo.FNADBUser()
	SET @is_batch = IIF(@batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL, 1, 0)
	SET @str_batch_table = IIF(@is_batch = 1, ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id), '')

	IF @enable_paging = 1 --paging processing
	BEGIN
		IF @batch_process_id IS NULL
			SET @batch_process_id = dbo.FNAGetNewID()
		
		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		IF @page_no IS NOT NULL  
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)
			
			IF @granularity = 980
				SET @sql_paging = @sql_paging + ' ORDER BY [Meter ID], dbo.FNAClientToSqlDate([Term])'
			
			EXEC (@sql_paging)  
			RETURN  
		END
	END
	/*******************************************1st Paging Batch END**********************************************/ 
	
	IF @granularity = 982	--hourly
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_pivot_hour_table') IS NOT NULL
			DROP TABLE #tmp_pivot_hour_table

		CREATE TABLE #tmp_pivot_hour_table (
			[meter_id] INT, 
			[recorderid] VARCHAR(100) COLLATE DATABASE_DEFAULT, 
			[location] VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[prod_date] DATETIME,
			[period] CHAR(2) COLLATE DATABASE_DEFAULT,
			[Hr1] NUMERIC(38, 20),
			[Hr2] NUMERIC(38, 20),
			[Hr3] NUMERIC(38, 20),
			[Hr4] NUMERIC(38, 20),
			[Hr5] NUMERIC(38, 20),
			[Hr6] NUMERIC(38, 20),
			[Hr7] NUMERIC(38, 20),
			[Hr8] NUMERIC(38, 20),
			[Hr9] NUMERIC(38, 20),
			[Hr10] NUMERIC(38, 20),
			[Hr11] NUMERIC(38, 20),
			[Hr12] NUMERIC(38, 20),
			[Hr13] NUMERIC(38, 20),
			[Hr14] NUMERIC(38, 20),
			[Hr15] NUMERIC(38, 20),
			[Hr16] NUMERIC(38, 20),
			[Hr17] NUMERIC(38, 20),
			[Hr18] NUMERIC(38, 20),
			[Hr19] NUMERIC(38, 20),
			[Hr20] NUMERIC(38, 20),
			[Hr21] NUMERIC(38, 20),
			[Hr22] NUMERIC(38, 20),
			[Hr23] NUMERIC(38, 20),
			[Hr24] NUMERIC(38, 20),
			[Hr25] NUMERIC(38, 20),
			uom_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT 
		)
		
		SET @tmp_pvt_table = '#tmp_pivot_hour_table'
		SET @select = 'SELECT mi.meter_id [Meter ID],
							  mi.recorderid [Recorderid],
							  ' +  CASE WHEN @location_id IS NOT NULL THEN + ' sml.Location_Name [Location] ' ELSE 'NULL [Location]' END + '
							  , m.[prod_date] [Prod Month],
							  ''0'' [period],
							  m.[Hr1],
							  m.[Hr2],
							  m.[Hr3],
							  m.[Hr4],
							  m.[Hr5],
							  m.[Hr6],
							  m.[Hr7],
							  m.[Hr8],
							  m.[Hr9],
							  m.[Hr10],
							  m.[Hr11],
							  m.[Hr12],
							  m.[Hr13],
							  m.[Hr14],
							  m.[Hr15],
							  m.[Hr16],
							  m.[Hr17],
							  m.[Hr18],
							  m.[Hr19],
							  m.[Hr20],
							  m.[Hr21],
							  m.[Hr22],
							  m.[Hr23],
							  m.[Hr24],
							  m.[Hr25],
							  su.uom_name,
							  sc.counterparty_name
						FROM mv90_data_hour m 
						'		
		IF @format = 'c'
		BEGIN
			IF @grouping_option = 'd'
			BEGIN
				WHILE @from <= @to
				BEGIN
					SET @hours = @hours + 'CAST(Hr' + CAST(@from AS VARCHAR(50)) + ' AS NUMERIC(38, ' + @round_value + ')) [Hr' + CAST(@from AS VARCHAR(50)) + '], '
					SET @from = @from + 1 
					IF @from > @to
					  BREAK
				   ELSE
					  CONTINUE
				END
				SET @hours = LEFT(@hours, LEN(@hours) - 1) + ' '
			END
			ELSE
			BEGIN
				WHILE @from <= @to
				BEGIN
					SET @hours = @hours + 'ISNULL(Hr' + CAST(@from AS VARCHAR(50)) + ',0) + '
					SET @from = @from + 1 
					IF @from > @to
					  BREAK
				   ELSE
					  CONTINUE
				END
				SET @hours = LEFT(@hours, LEN(@hours) -1)						
			END
		END
		ELSE
		BEGIN
			SET @selectCol = 'hr1 [1], hr2 [2], hr3 [3], hr4 [4], hr5 [5], hr6 [6], hr7 [7], hr8 [8], hr9 [9], hr10 [10], hr11 [11], hr12 [12], hr13 [13], hr14 [14], hr15 [15], hr16 [16], hr17 [17], hr18 [18], hr19 [19], hr20 [20], hr21 [21], hr22 [22], hr23 [23], hr24 [24], hr25 [25], hr25 [dd]'
			SET @listCol = '[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25]'
			SET @dstHour = 'CAST(unpvt.Hour AS INT)'
			SET @minusOne = ''
			
			IF @grouping_option = 'd'
			BEGIN
				SET @selectHourVolume = 'CASE
											WHEN dst_extra_hr.date IS NOT NULL
											THEN dst_extra_hr.Hour
											ELSE unpvt.[Hour]
										END [Hour],
										0 period,
										CASE 
											WHEN dst_end.[Hour] = unpvt.[Hour] AND dst_end.date = [prod_date] 
											THEN CAST(Volume AS NUMERIC(38, ' + @round_value + ')) - ISNULL(unpvt.dd, 0)
											ELSE CAST(Volume AS NUMERIC(38, ' + @round_value + '))
										END [Volume],
										CASE
											WHEN dst_extra_hr.date IS NOT NULL THEN 1
											ELSE 0
										END is_dst								
									'
			END
			ELSE
			BEGIN
				--don't add value of Hr25 even it has non zero value as its already stored in Hr3 (Hr3 = Hr3 + Hr25)  
				SET @selectHourVolume = 'CAST(SUM(CASE WHEN unpvt.[Hour] = 25 THEN 0 ELSE Volume END) AS NUMERIC(38, ' + @round_value + ')) [Volume]'									
			END
			
		END
	END
	ELSE IF @granularity IN (995, 994, 987, 989) --For lower granularity 5Min, 10Min, 15Min, 30Min
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_pivot_hour_period_table') IS NOT NULL
			DROP TABLE #tmp_pivot_hour_period_table
		
		CREATE TABLE #tmp_pivot_hour_period_table (
			[meter_id] INT, [recorderid] VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[location] VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[prod_date] DATETIME,
			[period] INT,
			[Hr1] NUMERIC(38, 20),
			[Hr2] NUMERIC(38, 20),
			[Hr3] NUMERIC(38, 20),
			[Hr4] NUMERIC(38, 20),
			[Hr5] NUMERIC(38, 20),
			[Hr6] NUMERIC(38, 20),
			[Hr7] NUMERIC(38, 20),
			[Hr8] NUMERIC(38, 20),
			[Hr9] NUMERIC(38, 20),
			[Hr10] NUMERIC(38, 20),
			[Hr11] NUMERIC(38, 20),
			[Hr12] NUMERIC(38, 20),
			[Hr13] NUMERIC(38, 20),
			[Hr14] NUMERIC(38, 20),
			[Hr15] NUMERIC(38, 20),
			[Hr16] NUMERIC(38, 20),
			[Hr17] NUMERIC(38, 20),
			[Hr18] NUMERIC(38, 20),
			[Hr19] NUMERIC(38, 20),
			[Hr20] NUMERIC(38, 20),
			[Hr21] NUMERIC(38, 20),
			[Hr22] NUMERIC(38, 20),
			[Hr23] NUMERIC(38, 20),
			[Hr24] NUMERIC(38, 20),
			[Hr25] NUMERIC(38, 20),
			uom_name VARCHAR(100) COLLATE DATABASE_DEFAULT ,
			counterparty VARCHAR(100) COLLATE DATABASE_DEFAULT 
		)
		SET @tmp_pvt_table = '#tmp_pivot_hour_period_table'
		
		DECLARE @granularity_value INT = 5
		SET @granularity_value = CASE WHEN @granularity = 989 THEN 30 
									  WHEN @granularity = 987 THEN 15 
									  WHEN @granularity = 994 THEN 10 
									  WHEN @granularity = 995 THEN 5 
									  ELSE 0 
								 END 

		SET @select = 'SELECT mi.meter_id [Meter ID],
							  mi.recorderid [Recorderid],
							  ' +  CASE WHEN @location_id IS NOT NULL THEN + ' sml.Location_Name [Location] ' ELSE 'NULL [Location]' END + '
							  , m.[prod_date] [Prod Month]
							  , period + (period % ' + CAST(@granularity_value AS VARCHAR(10)) + ') ,
							  m.[Hr1],
							  m.[Hr2],
							  m.[Hr3],
							  m.[Hr4],
							  m.[Hr5],
							  m.[Hr6],
							  m.[Hr7],
							  m.[Hr8],
							  m.[Hr9],
							  m.[Hr10],
							  m.[Hr11],
							  m.[Hr12],
							  m.[Hr13],
							  m.[Hr14],
							  m.[Hr15],
							  m.[Hr16],
							  m.[Hr17],
							  m.[Hr18],
							  m.[Hr19],
							  m.[Hr20],
							  m.[Hr21],
							  m.[Hr22],
							  m.[Hr23],
							  m.[Hr24],
							  m.[Hr25],
							  su.uom_name,
							  sc.counterparty_name
						FROM mv90_data_hour m
					'		
		IF @format = 'c'
		BEGIN
			IF @grouping_option = 'd'
			BEGIN
				WHILE @from <= @to
				BEGIN
					SET @hours = @hours + 'SUM(CAST(Hr' + CAST(@from AS VARCHAR) + ' AS NUMERIC(38, ' + @round_value + '))) [Hr' + CAST(@from AS VARCHAR) + '], '
					SET @from = @from + 1 
					IF @from > @to
					  BREAK
				   ELSE
					  CONTINUE
				END
				SET @hours = LEFT(@hours, LEN(@hours) - 1) + ' '
			END
			ELSE
			BEGIN
				WHILE @from <= @to
				BEGIN
					SET @hours = @hours + 'ISNULL(Hr' + CAST(@from AS VARCHAR) + ',0) + '
					SET @from = @from + 1 
					IF @from > @to
					  BREAK
				   ELSE
					  CONTINUE
				END
				SET @hours = LEFT(@hours, LEN(@hours) -1)						
			END
		END
		ELSE
		BEGIN
			SET @selectCol = 'period,hr1 [1], hr2 [2], hr3 [3], hr4 [4], hr5 [5], hr6 [6], hr7 [7], hr8 [8], hr9 [9], hr10 [10], hr11 [11], hr12 [12], hr13 [13], hr14 [14], hr15 [15], hr16 [16], hr17 [17], hr18 [18], hr19 [19], hr20 [20], hr21 [21], hr22 [22], hr23 [23], hr24 [24], hr25 [25], hr25 [dd]'
			SET @listCol = '[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25]'
			SET @dstHour = 'CAST(unpvt.Hour AS INT)'
			SET @minusOne = ''
			
			IF @grouping_option = 'd'
			BEGIN
				SET @selectHourVolume = 'CASE
										WHEN dst_extra_hr.date IS NOT NULL
										THEN dst_extra_hr.Hour
										ELSE unpvt.[Hour]
									END [Hour], ISNULL(unpvt.period, 0) [Period],
									SUM(CASE 
										WHEN dst_end.[Hour] = unpvt.[Hour] AND dst_end.date = [prod_date] 
										THEN CAST(Volume AS NUMERIC(38, ' + @round_value + ')) - ISNULL(unpvt.dd, 0)
										ELSE CAST(Volume AS NUMERIC(38, ' + @round_value + '))
									END) [Volume],
									CASE
										WHEN dst_extra_hr.date IS NOT NULL THEN 1
										ELSE 0
									END is_dst									
									'
			END
			ELSE
			BEGIN
				--don't add value of Hr25 even it has non zero value as its already stored in Hr3 (Hr3 = Hr3 + Hr25)  
				SET @selectHourVolume = 'unpvt.[hour] [Hour], ISNULL(unpvt.period, 0) [Period], CAST(SUM(CASE WHEN unpvt.[Hour] = 25 THEN 0 ELSE Volume END) AS NUMERIC(38, ' + @round_value + ')) [Volume]'									
			END
			
		END
	END
	ELSE IF @granularity = 980	--monthly
	BEGIN
		DECLARE @sql_stmt VARCHAR(MAX)
		-- If (commodity IS GAS) and (hour table has no data) then use normal monthly reporting		
		SET @sql_stmt = '
		 SELECT [Meter ID] ' +  CASE WHEN @location_id IS NOT NULL THEN + ',[Location] ' ELSE '' END + ',[UOM],[Term],[Volume] ' + @str_batch_table + '
		 FROM
		 (
			 SELECT DISTINCT mi.recorderid [Meter ID]
		                         ' +  CASE WHEN @location_id IS NOT NULL THEN + ',sml.Location_Name [Location] ' ELSE '' END + '
		                         , 
		                         su.uom_name [UOM],
		                         dbo.FNADateFormat(md.from_date) [Term],
		                         CAST(md.volume AS NUMERIC(38, ' + @round_value +')) 
		                         [Volume]
		                  FROM   mv90_data md
		                         LEFT JOIN meter_id mi ON  md.meter_id = mi.meter_id
		                         ' +  CASE 
		                                   WHEN @location_id IS NOT NULL OR (@counterparty_id IS NOT NULL AND @meter_id IS NULL)
										   THEN   '-- LEFT JOIN source_minor_location_meter smlm ON  smlm.meter_id = mi.meter_id 
													--LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm.source_minor_location_id 
													OUTER APPLY(SELECT DISTINCT location_id 
										FROM source_deal_detail sdd INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sdd.location_id
										 WHERE smlm.meter_id = mi.meter_id
									) c1 LEFT JOIN 	source_minor_location_meter smlm1 ON smlm1.meter_id = mi.meter_id 
										 LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm1.source_minor_location_id '
										ELSE ''
		                              END +
		                         '
		                         LEFT JOIN meter_counterparty mc ON mc.meter_id = mi.meter_id AND ( CAST(CONVERT(char(7), md.from_date, 126) + ''-01'' AS DATETIME) BETWEEN ISNULL(mc.term_start, ''1900-01-01'') AND ISNULL(mc.term_end, ''9999-01-01'') )
		                         LEFT JOIN source_counterparty sc ON  sc.source_counterparty_id = mc.counterparty_id
		                         LEFT JOIN recorder_properties rp ON  md.meter_id = rp.meter_id AND rp.channel = md.channel
		                         LEFT JOIN source_uom su ON  su.source_uom_id = rp.uom_id
		                         LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
		                  WHERE (mdh.recid IS NULL)' + CASE WHEN @commodity_id IS NOT NULL THEN ' AND mi.commodity_id = ' + CAST(@commodity_id AS VARCHAR(50))  ELSE '' END + '
						AND md.from_date BETWEEN  ''' + CONVERT(VARCHAR(10), @prod_month_from, 121) + '''
										 AND ''' + CONVERT(VARCHAR(10), @prod_month_to, 121) + '''' +
						CASE WHEN @counterparty_id IS NOT NULL THEN ' AND mc.counterparty_id IN (' + CAST(@counterparty_id AS VARCHAR(10)) + ')' ELSE '' END +
						CASE WHEN @meter_id IS NOT NULL THEN ' AND md.meter_id IN (' + @meter_id +')'+'' ELSE '' END +
						CASE WHEN @location_id IS NOT NULL THEN ' AND smlm1.source_minor_location_id = ' + CAST(@location_id AS VARCHAR) ELSE '' END +
						' AND ISNULL(mdh.data_missing, ''n'') = ''' + @enhance_volume_flag + '''' + 
						CASE WHEN @channel IS NOT NULL THEN ' AND md.channel = ' + CAST(@channel AS VARCHAR)  ELSE '' 
						END


		-- get monthly sum from hourly for 15mins data
		IF ((SELECT commodity_id FROM source_commodity WHERE source_commodity_id = @commodity_id)!= 'Gas') OR @commodity_id is NULL
		SET @sql_stmt = @sql_stmt + 
		'
		 UNION ALL 
		' +	' SELECT DISTINCT mi.recorderid [Meter ID]
					   ' +  CASE WHEN @location_id IS NOT NULL THEN ',sml.Location_Name [Location] ' ELSE '' END + '
					   , su.uom_name [UOM]
					   , dbo.FNADateFormat(CONVERT(CHAR(7), MAX(a.prod_datetime), 126) + ''-01'') [Term]
					   , CAST(SUM(a.VALUE) AS NUMERIC(38, ' + @round_value +')) [Volume]
		FROM( 
		SELECT  unpvt.meter_id, DATEADD(hh,CAST(REPLACE(unpvt.[hour],''hr'','''') AS INT)-1,unpvt.prod_date) prod_datetime, unpvt.value value, unpvt.channel FROM 
			  (SELECT
					md.meter_id, mdh.prod_date,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24, md.channel
			  FROM
					mv90_data_hour mdh
					INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
					INNER JOIN meter_id mi2 ON mi2.meter_id = md.meter_id 
					WHERE 1=1 ' + CASE WHEN @commodity_id IS NOT NULL THEN ' AND mi2.commodity_id = ' + CAST(@commodity_id AS VARCHAR) ELSE '' END +
								  CASE WHEN @channel IS NOT NULL THEN ' AND md.channel = ' + CAST(@channel AS VARCHAR)  ELSE '' END +
								  ' AND ISNULL(mdh.data_missing, ''n'') = ''' + @enhance_volume_flag + '''' +
			  ')p
			  UNPIVOT
			  (value FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
			  ) AS unpvt  
		) a
		INNER JOIN meter_id mi ON a.meter_id = mi.meter_id
		' +  CASE 
			   WHEN @location_id IS NOT NULL OR (@counterparty_id IS NOT NULL AND @meter_id IS NULL)
			   THEN   ' OUTER APPLY(SELECT DISTINCT location_id 
										FROM source_deal_detail sdd INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sdd.location_id
										 WHERE smlm.meter_id = mi.meter_id
									) c1 
									LEFT JOIN source_minor_location_meter smlm1 ON smlm1.meter_id = mi.meter_id
									LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm1.source_minor_location_id 
									'
								   ELSE ''
			 END +
		'
        LEFT JOIN meter_counterparty mc ON mc.meter_id = mi.meter_id AND a.prod_datetime BETWEEN mc.term_start AND ISNULL(mc.term_end, ''9999-01-01'')
		LEFT JOIN source_counterparty sc ON  sc.source_counterparty_id = mc.counterparty_id
		LEFT JOIN recorder_properties rp ON  mi.meter_id = rp.meter_id AND rp.channel = a.channel
		LEFT JOIN source_uom su ON  su.source_uom_id = rp.uom_id
		WHERE a.prod_datetime BETWEEN  ''' + CONVERT(VARCHAR(10), @prod_month_from, 121) + '''
					 AND ''' + CONVERT(VARCHAR(23), @prod_month_to + ' 23:59:59.997', 121) + '''' +
		CASE WHEN @commodity_id IS NOT NULL THEN ' AND mi.commodity_id = ' + CAST(@commodity_id AS VARCHAR(50))  ELSE '' END +
		CASE WHEN @channel IS NOT NULL THEN ' AND rp.channel = ' + CAST(@channel AS VARCHAR(50))  ELSE '' END +
		CASE WHEN @counterparty_id IS NOT NULL THEN ' AND mc.counterparty_id IN (' + CAST(@counterparty_id AS VARCHAR(10)) + ')' ELSE '' END +
		CASE WHEN @meter_id IS NOT NULL THEN ' AND mi.meter_id IN (' + @meter_id +')'+'' ELSE '' END +
		CASE WHEN @location_id IS NOT NULL THEN ' AND smlm1.source_minor_location_id = ' + CAST(@location_id AS VARCHAR(50)) ELSE '' END +
					 
		'  GROUP BY mi.recorderid, ' +  CASE WHEN @location_id IS NOT NULL THEN + 'sml.Location_Name,' ELSE '' END + ' sc.counterparty_name, su.uom_name, YEAR(a.prod_datetime), MONTH(a.prod_datetime) '

	Else if (@commodity_id is not NULL or (SELECT commodity_id FROM source_commodity WHERE source_commodity_id = @commodity_id) = 'Gas')
		-- If (commodity IS GAS) AND (hour table has some data) then show total gas hour sum(i.e 1st day 7th hr to next month 1st day 6th hour) in monthly reporting		
		SET @sql_stmt = @sql_stmt + 
		'
		 UNION ALL 
		' +	' SELECT DISTINCT mi.recorderid [Meter ID]
					   ' +  CASE WHEN @location_id IS NOT NULL THEN ',sml.Location_Name [Location] ' ELSE '' END + '
					   , su.uom_name [UOM]
					   , dbo.FNADateFormat(CONVERT(CHAR(7), a.prod_datetime, 126) + ''-01'') [Term]
					   , CAST(SUM(a.VALUE) AS NUMERIC(38, ' + @round_value +')) [Volume]
		FROM( 
		SELECT  unpvt.meter_id, DATEADD(hh, -6, DATEADD(hh,CAST(REPLACE(unpvt.[hour],''hr'','''') AS INT)-1,unpvt.prod_date) ) prod_datetime, unpvt.value value, unpvt.channel FROM 
			  (SELECT
					md.meter_id, mdh.prod_date,
					hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24, md.channel
			  FROM
					mv90_data_hour mdh
					INNER JOIN mv90_data md ON md.meter_data_id = mdh.meter_data_id
					INNER JOIN meter_id mi2 ON mi2.meter_id = md.meter_id
					WHERE 1=1 ' + CASE WHEN @commodity_id IS NOT NULL THEN ' AND mi2.commodity_id = ' + CAST(@commodity_id AS VARCHAR) ELSE '' END +
								  CASE WHEN @channel IS NOT NULL THEN ' AND md.channel = ' + CAST(@channel AS VARCHAR)  ELSE '' END +
								  ' AND ISNULL(mdh.data_missing, ''n'') = ''' + @enhance_volume_flag + '''' + 
			  ')p
			  UNPIVOT
			  (value FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
			  ) AS unpvt  
		) a
		INNER JOIN meter_id mi ON a.meter_id = mi.meter_id
		' +  CASE 
			   WHEN @location_id IS NOT NULL OR (@counterparty_id IS NOT NULL AND @meter_id IS NULL)
			   THEN   ' --LEFT JOIN source_minor_location_meter smlm ON  smlm.meter_id = mi.meter_id
						--LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm.source_minor_location_id 
						OUTER APPLY(SELECT DISTINCT location_id 
										FROM source_deal_detail sdd INNER JOIN source_minor_location_meter smlm ON smlm.source_minor_location_id=sdd.location_id
										 WHERE smlm.meter_id = mi.meter_id
									) c1 
						LEFT JOIN source_minor_location_meter smlm1 ON smlm1.meter_id = mi.meter_id 
						LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm1.source_minor_location_id '
						
			   ELSE ''
			 END +
		'
        LEFT JOIN meter_counterparty mc ON mc.meter_id = mi.meter_id AND CAST(CONVERT(char(7), a.prod_datetime, 126) + ''-01'' AS DATETIME) BETWEEN mc.term_start AND ISNULL(mc.term_end, ''9999-01-01'')
		LEFT JOIN source_counterparty sc ON  sc.source_counterparty_id = mc.counterparty_id
		LEFT JOIN recorder_properties rp ON  mi.meter_id = rp.meter_id AND rp.channel = a.channel
		LEFT JOIN source_uom su ON  su.source_uom_id = rp.uom_id
		WHERE 
		CAST(CONVERT(char(7), a.prod_datetime, 126) + ''-01'' AS DATETIME) BETWEEN  ''' + CONVERT(VARCHAR(10), @prod_month_from, 121) + '''
					 AND ''' + CONVERT(VARCHAR(10), @prod_month_to, 121) + '''' +
		CASE WHEN @channel IS NOT NULL THEN ' AND rp.channel = ' + CAST(@channel AS VARCHAR(50))  ELSE '' END +
		CASE WHEN @counterparty_id IS NOT NULL THEN ' AND mc.counterparty_id IN (' + CAST(@counterparty_id AS VARCHAR(10)) + ')' ELSE '' END +
		CASE WHEN @meter_id IS NOT NULL THEN ' AND mi.meter_id IN (' + @meter_id +')'+'' ELSE ''  END +
		CASE WHEN @location_id IS NOT NULL THEN ' AND smlm1.source_minor_location_id = ' + CAST(@location_id AS VARCHAR(50)) ELSE '' END +
		'  GROUP BY mi.recorderid, ' +  CASE WHEN @location_id IS NOT NULL THEN + 'sml.Location_Name,' ELSE '' END + ' sc.counterparty_name, su.uom_name, CONVERT(char(7), a.prod_datetime, 126) + ''-01'', YEAR(a.prod_datetime), MONTH(a.prod_datetime) '

		SET  @sql_stmt = 	@sql_stmt+ ') a ORDER BY [Meter ID], dbo.FNAClientToSqlDate([Term])'

		--PRINT @sql_stmt
		EXEC(@sql_stmt) 
	
		
	END
	ELSE
	BEGIN
		RETURN
	END
	
	SET @sqlStmt = 'INSERT INTO ' + @tmp_pvt_table + ' ' + @select
	SET @sqlStmt = @sqlStmt +  '
										
										INNER JOIN mv90_data md
											ON md.meter_data_id = m.meter_data_id
										INNER JOIN meter_id mi
											ON mi.meter_id = md.meter_id
										LEFT JOIN recorder_properties rp
											ON mi.meter_id = rp.meter_id AND rp.channel = md.channel
										' + CASE 
										         WHEN @location_id IS NOT NULL 
													THEN + ' LEFT JOIN source_minor_location_meter smlm ON smlm.meter_id = mi.meter_id 
															 LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm.source_minor_location_id
															 LEFT JOIN source_deal_detail sdd ON sdd.location_id = sml.source_minor_location_id '
										         ELSE ''
										    END + 
										' LEFT JOIN meter_counterparty mc ON mc.meter_id = mi.meter_id  AND m.prod_date BETWEEN mc.term_start AND ISNULL(mc.term_end, ''9999-01-01'')
										LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = mc.counterparty_id 											
										  LEFT JOIN source_uom su ON su.source_uom_id = rp.uom_id
										WHERE	1 = 1 '
										+ CASE WHEN @prod_month_from IS NOT NULL THEN ' AND m.prod_date >= ''' + CONVERT(VARCHAR, @prod_month_from, 120) + '''' ELSE '' END
										+ CASE WHEN @prod_month_to IS NOT NULL THEN ' AND m.prod_date <= ''' + CONVERT(VARCHAR, @prod_month_to, 120) + '''' ELSE '' END
										+ ' AND ISNULL(m.data_missing, ''n'') =''' + @enhance_volume_flag + '''' 
										+ CASE WHEN @meter_id IS NOT NULL THEN ' AND mi.meter_id IN (' + @meter_id +')'+'' ELSE ''  END 
										+ CASE WHEN @channel IS NOT NULL THEN ' AND md.channel = ' + CAST(@channel AS VARCHAR(50))  ELSE '' END
										+ CASE WHEN @location_id IS NOT NULL THEN '	AND smlm.source_minor_location_id = ' + CAST(@location_id AS VARCHAR(50)) ELSE '' END
										+ CASE WHEN @counterparty_id IS NOT NULL THEN ' AND mc.counterparty_id IN (' + CAST (@counterparty_id AS VARCHAR(10)) + ')' ELSE '' END
										+ CASE WHEN @commodity_id IS NOT NULL THEN ' AND mi.commodity_id = ' + CAST(@commodity_id AS VARCHAR(50))  ELSE '' END
		
	EXEC(@sqlStmt)

	
			


	SET @rowCount = @@ROWCOUNT
	
	IF @format = 'c'
	BEGIN
		IF @grouping_option = 'd'
		BEGIN
			--PRINT 'crosstab / detail'
			IF @location_id IS NOT NULL
			BEGIN
				SET @sqlStmt = 'SELECT [recorderid] [Meter ID],
									location [Location],
									dbo.FNADateformat([prod_date]) [Date] , uom_name [UOM], period [Period],
									' + @hours + @str_batch_table + ' 
							FROM ' + @tmp_pvt_table + 
							CASE WHEN @granularity IN (994, 995, 987, 989) THEN ' GROUP BY  recorderid, location, prod_date, uom_name, period' ELSE '' END + '
			                 ORDER BY [location],dbo.FNAStdDate([prod_date])
							'	
			END
			ELSE 
			BEGIN
				SET @sqlStmt = 'SELECT [recorderid] [Meter ID],
				                       dbo.FNADateformat([prod_date]) 
				                       [Date],
				                       uom_name [UOM],
				                       period [Period],
				                       ' + @hours + @str_batch_table + '
				                FROM   ' + @tmp_pvt_table + 
				              CASE WHEN @granularity IN (994, 995, 987, 989) THEN ' GROUP BY  recorderid, location, prod_date, uom_name, period' ELSE '' END + '
				                 ORDER BY [Meter ID], dbo.FNAStdDate([prod_date]), period'
							
			END

			EXEC (@sqlStmt)
			
		END
		ELSE
		BEGIN
			--PRINT 'crosstab / summary'
			IF @rowCount > 0
			BEGIN
				SET @sqlStmt = 'INSERT INTO #tmp_calc_pvt_tbl (meter_id, recorderid, location, counterparty, prod_date, volume, uom_name) 
								SELECT	[meter_id], [recorderid], [Location], counterparty, [prod_date], ' + @hours + ' AS [Volume], uom_name 
								FROM	' + @tmp_pvt_table
				--PRINT @sqlStmt
				EXEC(@sqlStmt)
							
				
				SELECT  @listCol = STUFF(( SELECT  '], [' +  dbo.FNADateFormat(prod_date) 
							 FROM    #tmp_calc_pvt_tbl GROUP BY [prod_date] ORDER BY [prod_date] 
									FOR XML PATH('')), 1, 2, '') + ']'
									
				SELECT  @selectCol = STUFF(( SELECT  '], CAST([' + dbo.FNADateFormat(prod_date) + '] AS NUMERIC(38, ' + @round_value + ')) AS [' + dbo.FNADateFormat(prod_date)
							 FROM    #tmp_calc_pvt_tbl GROUP BY [prod_date] ORDER BY CAST ([prod_date] AS DATETIME) 
									FOR XML PATH('')), 1, 2, '') + ']'
				IF @location_id IS NOT NULL
				BEGIN
					SET @sqlStmt  = 'SELECT [Meter ID],
					                        [Location],
					                        uom_name [UOM],
					                        ' + @selectCol + ' 
					                        ' + @str_batch_table + '
					                 FROM   (
					                            SELECT [recorderid] [Meter ID],
					                                   location [Location],
					                                   dbo.FNADateFormat(prod_date) 
					                                   [Date],
					                                   Volume,
					                                   uom_name
					                            FROM   #tmp_calc_pvt_tbl
					                        ) DataTable
					                        PIVOT(SUM(Volume) FOR [Date] IN (' + @listCol + ')) 
					                        PivotTable'	
				END
				ELSE
				BEGIN
					SET @sqlStmt  = 'SELECT [Meter ID],
					                        uom_name [UOM],
					                        ' + @selectCol + ' 
					                        ' + @str_batch_table + '
					                 FROM   (
					                            SELECT [recorderid] [Meter ID],
					                                   dbo.FNADateFormat(prod_date) 
					                                   [Date],
					                                   Volume,
					                                   uom_name
					                            FROM   #tmp_calc_pvt_tbl
					                        ) DataTable
					                        PIVOT(SUM(Volume) FOR [Date] IN (' + @listCol + ')) 
					                        PivotTable'
				END					
				
			--	EXEC spa_print @sqlStmt
				EXEC (@sqlStmt)
			END
			ELSE
			BEGIN
				IF @location_id IS NOT NULL
				BEGIN
					SET @sqlStmt = 'SELECT [recorderid] [Meter ID],
				                       location [Location],
				                       uom_name [UOM] '+ @str_batch_table+ '
				                FROM   ' + @tmp_pvt_table	
				END
				ELSE
				BEGIN
					SET @sqlStmt = 'SELECT [recorderid] [Meter ID],
				                       uom_name [UOM] '+ @str_batch_table+ '
				                FROM   ' + @tmp_pvt_table
				END
				
				
			--	EXEC spa_print @sqlStmt
				EXEC (@sqlStmt)					
			END
		END
	END
	ELSE
	BEGIN
	--	EXEC spa_print 'Regular / '
		IF OBJECT_ID('tempdb..#temp_final_table') IS NOT NULL
				DROP TABLE #temp_final_table

		CREATE TABLE #temp_final_table (
			meter_id VARCHAR(500) COLLATE DATABASE_DEFAULT,
			[location] VARCHAR(100) COLLATE DATABASE_DEFAULT,
			uom VARCHAR(100) COLLATE DATABASE_DEFAULT,
			[date] VARCHAR(15) COLLATE DATABASE_DEFAULT,
			[hour] INT,
			[minute] INT,
			volume NUMERIC(38, 20),
			is_dst INT
		)


		IF @location_id IS NOT NULL
		BEGIN
			SET @sqlStmt = CASE WHEN @grouping_option = 's' THEN 'INSERT INTO #temp_final_table (meter_id, location, uom, date, hour, minute, volume)' 
						ELSE	' INSERT INTO #temp_final_table (meter_id, location, uom, date, hour, minute, volume, is_dst)' END + '
						SELECT	unpvt.[recorderid] [Meter ID],
								[location],
								uom_name [UOM],
								dbo.FNADateformat(prod_date) [Date],
						'
						+ @selectHourVolume +
						' FROM
						(SELECT 
							[recorderid], [meter_id], location, uom_name, prod_date, ' + @selectCol +
							' FROM ' + @tmp_pvt_table + ') p
						UNPIVOT
						(Volume for [Hour] IN
							(' + @listCol + ')
						) AS unpvt
						LEFT JOIN mv90_DST dst_extra_hr
							ON  ([prod_date]) = (dst_extra_hr.date)
							AND dst_extra_hr.insert_delete = ''i''
							AND dst_extra_hr.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
							AND ' + @dstHour + ' = 25
						--LEFT JOIN mv90_DST dst_missing_hr
						--	ON  ([prod_date]) = (dst_missing_hr.date)
						--	AND dst_missing_hr.insert_delete = ''d''
						--	AND dst_missing_hr.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
						--	AND dst_missing_hr.Hour ' + @minusOne + ' = ' + @dstHour + ' ' + @minusOne + '
						LEFT JOIN mv90_DST dst_end
							ON  YEAR([prod_date]) = (dst_end.YEAR)
							AND dst_end.insert_delete = ''i''
							AND dst_end.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
						WHERE 1 = 1
						AND ( CASE 
								WHEN ''' + @grouping_option + ''' = ''d'' 
								THEN CASE 
										WHEN dst_extra_hr.date IS NOT NULL 
										THEN dst_extra_hr.Hour ' + @minusOne + '
										ELSE ' + @dstHour + ' ' + @minusOne + '
								     END
								ELSE  ' + @dstHour + ' ' + @minusOne + '
							END 
							BETWEEN ' + CAST(ISNULL(@hour_from,1) AS VARCHAR(50)) + ' ' + @minusOne + ' AND ' + CAST(ISNULL(@hour_to,25) AS VARCHAR(50)) + ' ' + @minusOne + ') 						 
						AND (
							   (' + @dstHour + ' = 25 AND dst_extra_hr.date IS NOT NULL)
							   OR (' + @dstHour + ' <> 25)
						   )
					   --AND (dst_missing_hr.date IS NULL)
					   ' +
						CASE 
							WHEN @grouping_option = 's' THEN ' GROUP BY recorderid, location, prod_date, uom_name ' + 
									CASE WHEN @granularity IN(994,995,987,989) AND @grouping_option =  'd' THEN ', unpvt.[Hour], period' 
									ELSE ', unpvt.[Hour]' END 
									+ ' ORDER BY unpvt.[recorderid], uom_name, CAST(prod_date AS DATETIME), ISNULL(unpvt.[hour], 0) ' 
							ELSE '' 
						END + 
						CASE WHEN @grouping_option = 'd' AND @granularity IN (994, 995,987, 989) THEN ' GROUP BY recorderid, location, prod_date, uom_name, dst_extra_hr.date, dst_extra_hr.Hour, unpvt.hour, dst_end.date, dst_end.hour, unpvt.period ' ELSE '' END +   
						CASE WHEN @grouping_option = 'd' THEN ' ORDER BY unpvt.[recorderid], uom_name, CAST(prod_date AS DATETIME), 
							CASE 
								WHEN dst_extra_hr.date IS NOT NULL THEN dst_extra_hr.Hour ' + @minusOne + '
								ELSE ' + @dstHour + ' ' + @minusOne + '
						   END' ELSE '' END + 
						CASE WHEN @granularity IN(994,995,987,989) AND @grouping_option = 'd' THEN ', ISNULL(unpvt.[hour], 0), period' 
							ELSE '' 
						END
		END
		ELSE
		BEGIN
			
			SET @sqlStmt = CASE WHEN @grouping_option = 's' THEN 'INSERT INTO #temp_final_table (meter_id, uom, date, hour, minute, volume)' 
			ELSE 'INSERT INTO #temp_final_table (meter_id, uom, date, hour, minute, volume, is_dst)' END + '
						    SELECT unpvt.[recorderid] [Meter ID],
			                       uom_name [UOM],
			                       dbo.FNADateformat(prod_date) [Date],
			                       ' 
						+ @selectHourVolume +
						' 
						
						FROM
						(SELECT 
							[recorderid], [meter_id], counterparty, uom_name, prod_date, ' + @selectCol + ' FROM ' + @tmp_pvt_table + ') p
						UNPIVOT
						(Volume for [Hour] IN
							(' + @listCol + ')
						) AS unpvt
						LEFT JOIN mv90_DST dst_extra_hr
							ON  ([prod_date]) = (dst_extra_hr.date)
							AND dst_extra_hr.insert_delete = ''i''
							AND dst_extra_hr.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
							AND ' + @dstHour + ' = 25
						--LEFT JOIN mv90_DST dst_missing_hr
						--	ON  ([prod_date]) = (dst_missing_hr.date)
						--	AND dst_missing_hr.insert_delete = ''d''
						--	AND dst_missing_hr.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
						--	AND dst_missing_hr.Hour ' + @minusOne + ' = ' + @dstHour + ' ' + @minusOne + '
						LEFT JOIN mv90_DST dst_end
							ON  YEAR([prod_date]) = (dst_end.YEAR)
							AND dst_end.insert_delete = ''i''
							AND dst_end.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
						LEFT JOIN source_counterparty sc ON sc.counterparty_id = counterparty	
						LEFT JOIN meter_counterparty mc ON mc.meter_id = unpvt.meter_id AND  mc.counterparty_id = sc.source_counterparty_id AND prod_date BETWEEN mc.term_start AND ISNULL(mc.term_end, ''9999-01-01'')		
						WHERE 1 = 1
						' + CASE WHEN @counterparty_id IS NOT NULL THEN ' AND mc.counterparty_id IN (' + CAST(@counterparty_id AS VARCHAR(10)) + ')' ELSE '' END + '
						AND ( CASE 
								WHEN ''' + @grouping_option + ''' = ''d'' 
								THEN CASE 
										WHEN dst_extra_hr.date IS NOT NULL 
										THEN dst_extra_hr.Hour ' + @minusOne + '
										ELSE ' + @dstHour + ' ' + @minusOne + '
								     END
								ELSE  ' + @dstHour + ' ' + @minusOne + '
							END 
							BETWEEN ' + CAST(ISNULL(@hour_from,1) AS VARCHAR(50)) + ' ' + @minusOne + ' AND ' + CAST(ISNULL(@hour_to,25) AS VARCHAR(50)) + ' ' + @minusOne + ') 						 
						AND (
							   (' + @dstHour + ' = 25 AND dst_extra_hr.date IS NOT NULL)
							   OR (' + @dstHour + ' <> 25)
						   )
					   --AND (dst_missing_hr.date IS NULL)
					   ' +
						CASE 
							WHEN @grouping_option = 's' THEN ' GROUP BY recorderid, counterparty, prod_date, uom_name, unpvt.[Hour], period' 
									+ ' ORDER BY unpvt.[recorderid], uom_name, CAST(prod_date AS DATETIME), ISNULL(unpvt.[hour], 0) ' 
							ELSE '' 
						END + 
						CASE WHEN @grouping_option = 'd' AND @granularity IN (994, 995,987, 989) THEN ' GROUP BY recorderid, counterparty, prod_date, uom_name, dst_extra_hr.date, dst_extra_hr.Hour, unpvt.hour, dst_end.date, dst_end.hour, unpvt.period ' ELSE '' END +   
						CASE WHEN @grouping_option = 'd' THEN ' ORDER BY unpvt.[recorderid], uom_name, CAST(prod_date AS DATETIME), 
							CASE 
								WHEN dst_extra_hr.date IS NOT NULL THEN dst_extra_hr.Hour ' + @minusOne + '
								ELSE ' + @dstHour + ' ' + @minusOne + '
						   END' ELSE '' END + 
						CASE WHEN @granularity IN(994,995,987, 989) AND @grouping_option = 'd' THEN ', ISNULL(unpvt.[hour], 0), period' 
							ELSE '' 
						END 
		END
		
		EXEC(@sqlStmt)
		
		IF @grouping_option = 'd'
		BEGIN
					SET @sqlStmt = '
				SELECT meter_id [Meter ID],' +
					   CASE WHEN @location_id IS NOT NULL THEN '[location],' ELSE '' END +
					   'uom [UOM], 
					   [date] [Date],
					   CAST(ISNULL(LEFT(alias_name, 2), tft.hour) AS INT)  [Hour], 
					   ISNULL(IIF(RIGHT([alias_name], 3) = ''DST'', RIGHT([alias_name], 5), RIGHT([alias_name], 2)), RIGHT(''0'' + CAST(tft.[minute] AS VARCHAR(10)), 2)) [Minute], 
					   CAST(volume AS NUMERIC(38,' + @round_value + ')) [Volume]
				' + ISNULL(@str_batch_table, '') + '
				FROM #temp_final_table tft
				LEFT  JOIN #convert_time_format cs 
					ON cs.clm_name = RIGHT(''0'' + CAST(CAST(tft.[hour] AS INT) - 1 AS VARCHAR(10)), 2) + RIGHT(''0'' + CAST(tft.[minute] AS VARCHAR(10)), 2)
						AND tft.is_dst = cs.is_dst
				ORDER BY [date], tft.[hour], tft.[minute]
			'
			EXEC (@sqlStmt)
		END
		ELSE IF @grouping_option = 's' AND @format = 'r' AND @granularity IN(994,995,987,989,982)
		BEGIN
			SET @sqlStmt = '
				SELECT	meter_id [Meter ID],'
						+ CASE WHEN @location_id IS NOT NULL THEN '[location],' ELSE '' END +
						'uom [UOM], 
					   [date] [Date], Hour, Minute, CAST(volume AS NUMERIC(38,' + @round_value + ')) [Volume]
				' + @str_batch_table + '
				FROM #temp_final_table tft
				--INNER JOIN #convert_time_format cs 
				--	ON cs.clm_name = RIGHT(''0'' + CAST(CAST(tft.[hour] AS INT) - 1 AS VARCHAR(10)), 2) + RIGHT(''0'' + CAST(tft.[minute] AS VARCHAR(10)), 2)
				--		AND tft.is_dst = cs.is_dst
				ORDER BY [date], [hour], [minute]
			'
			EXEC (@sqlStmt)

			
		END
	END	

	/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
		EXEC(@str_batch_table)                   

		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_meter_data_report', 'Meter data Report')         
		EXEC(@str_batch_table)        
		RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
		EXEC(@sql_paging)
	END
	/*******************************************2nd Paging Batch END**********************************************/	END
