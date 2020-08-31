
IF OBJECT_ID(N'spa_import_15_mins_data', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_import_15_mins_data]
GO 

CREATE PROCEDURE [dbo].[spa_import_15_mins_data]
	@temp_table_name	VARCHAR(500),
	@table_id			VARCHAR(100),
	@job_name			VARCHAR(100),
	@process_id			VARCHAR(100),
	@user_login_id		VARCHAR(50), 
	@drilldown_level	INT = 1,		-- 1: 1 level drill down	-- 2: 2 level drilldown
	@temp_header_table	VARCHAR(128) = NULL	
AS

DECLARE @sql                     VARCHAR(8000),
        @url_desc                VARCHAR(250),
        @url                     VARCHAR(250),
        @error_count             INT,
        @type                    CHAR,
        @tempTable               VARCHAR(128),
        @sqlStmt                 VARCHAR(5000),
        @strategy_name_for_mv90  VARCHAR(100),
        @trader                  VARCHAR(100),
        @default_uom             INT,
        @total_count             INT,
        @total_count_v           VARCHAR(50),
        @listCol                 VARCHAR(MAX),
        @selectCol               VARCHAR(MAX),
        @col					VARCHAR(500)

IF OBJECT_ID('tempdb..#tmp_staging_table') IS NOT NULL
    DROP TABLE #tmp_staging_table
IF OBJECT_ID('tempdb..#tmp_missing_meter_id') IS NOT NULL
    DROP TABLE #tmp_missing_meter_id
    
CREATE TABLE [#tmp_staging_table] (
	[meter_id] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[channel] VARCHAR(10) COLLATE DATABASE_DEFAULT,
	[DATE] VARCHAR(20) COLLATE DATABASE_DEFAULT,
	[HOUR] VARCHAR(5) COLLATE DATABASE_DEFAULT,
	[VALUE] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[h_filename] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL, 
	[h_error] [VARCHAR](1000) COLLATE DATABASE_DEFAULT NULL, 
	[d_filename] [VARCHAR](100) COLLATE DATABASE_DEFAULT NULL, 
	[d_error] [VARCHAR](1000) COLLATE DATABASE_DEFAULT NULL
)
CREATE TABLE #tmp_missing_meter_id (meter_id VARCHAR(100) COLLATE DATABASE_DEFAULT)

BEGIN TRY
	-- Insert data into temporary from staging table
	IF @drilldown_level = 1
	BEGIN
		EXEC ('INSERT INTO #tmp_staging_table([meter_id],[channel],[date],[hour],[value]) 
				SELECT [meter_id], ISNULL([channel],1), [dbo].[FNAClientToSqlDate]([date]), [hour], [value] FROM ' + @temp_table_name)
	END
	ELSE IF @drilldown_level = 2
	BEGIN
		EXEC ('INSERT INTO #tmp_staging_table 
			SELECT [meter_id],ISNULL([channel],1), [dbo].[FNAClientToSqlDate]([date]), [hour], [value], [h_filename], [h_error], [d_filename], [d_error] FROM ' + @temp_table_name)
	END	
	
END TRY
BEGIN CATCH
	DECLARE @error_msg  VARCHAR(1000)
	DECLARE @desc	VARCHAR(8000)
	DECLARE @error_code VARCHAR(5)
	
	SET @error_msg = 'Error: ' + ERROR_MESSAGE()
	SET @error_code = 'e'
	EXEC spa_print @error_msg
	
	INSERT INTO source_system_data_import_status (
		process_id,
		code,
		MODULE,
		[source],
		[TYPE],
		[description],
		recommendation
	  )
	  EXEC (
			 'SELECT DISTINCT ' 
			 + '''' + @process_id + '''' + ',' 
			 + '''Error'''  + ',' 
			 + '''Import Allocation Data(15 mins)''' + ',' 
			 + '''eBase Data Import(15 mins)''' + ',' 
			 +  '''Error''' + ',' 
			 + '''' + @error_msg + '''' + ',' + 
			 '''Please check if the date format provided matches the Users Date format.''' + 
			 ' FROM ' + @temp_table_name
	  )
	
	SELECT @url_desc = './dev/spa_html.php?__user_name__=' + @user_login_id +
		   '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' 
		   + @user_login_id + ''''
	
	SELECT @desc = '<a target="_blank" href="' + @url_desc + '">' +
		   'Allocation data import process completed' +
		   CASE 
				WHEN (@error_code = 'e') THEN ' (ERRORS found)'
				ELSE ''
		   END +  ' </a>'
	
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Allocation Data(15 mins)', @desc , @error_code, @job_name, 1
	
	RETURN
END CATCH 	


--SELECT * FROM #tmp_staging_table ta
CREATE TABLE [#tmp_mv90_data_mins] (
	[meter_id] INT, [channel] INT, [prod_date] DATETIME,
	[Hr1_15] FLOAT, [Hr1_30] FLOAT,[Hr1_45] FLOAT, [Hr1_60] FLOAT,
	[Hr2_15] FLOAT, [Hr2_30] FLOAT, [Hr2_45] FLOAT, [Hr2_60] FLOAT, 
	[Hr3_15] FLOAT, [Hr3_30] FLOAT, [Hr3_45] FLOAT, [Hr3_60] FLOAT, 
	[Hr4_15] FLOAT, [Hr4_30] FLOAT, [Hr4_45] FLOAT, [Hr4_60] FLOAT, 
	[Hr5_15] FLOAT, [Hr5_30] FLOAT, [Hr5_45] FLOAT, [Hr5_60] FLOAT, 
	[Hr6_15] FLOAT, [Hr6_30] FLOAT, [Hr6_45] FLOAT, [Hr6_60] FLOAT, 
	[Hr7_15] FLOAT, [Hr7_30] FLOAT, [Hr7_45] FLOAT, [Hr7_60] FLOAT, 
	[Hr8_15] FLOAT, [Hr8_30] FLOAT, [Hr8_45] FLOAT, [Hr8_60] FLOAT, 
	[Hr9_15] FLOAT, [Hr9_30] FLOAT, [Hr9_45] FLOAT, [Hr9_60] FLOAT, 
	[Hr10_15] FLOAT, [Hr10_30] FLOAT, [Hr10_45] FLOAT, [Hr10_60] FLOAT, 
	[Hr11_15] FLOAT, [Hr11_30] FLOAT, [Hr11_45] FLOAT, [Hr11_60] FLOAT, 
	[Hr12_15] FLOAT, [Hr12_30] FLOAT, [Hr12_45] FLOAT, [Hr12_60] FLOAT, 
	[Hr13_15] FLOAT, [Hr13_30] FLOAT, [Hr13_45] FLOAT, [Hr13_60] FLOAT, 
	[Hr14_15] FLOAT, [Hr14_30] FLOAT, [Hr14_45] FLOAT, [Hr14_60] FLOAT, 
	[Hr15_15] FLOAT, [Hr15_30] FLOAT, [Hr15_45] FLOAT, [Hr15_60] FLOAT, 
	[Hr16_15] FLOAT, [Hr16_30] FLOAT, [Hr16_45] FLOAT, [Hr16_60] FLOAT, 
	[Hr17_15] FLOAT, [Hr17_30] FLOAT, [Hr17_45] FLOAT, [Hr17_60] FLOAT, 
	[Hr18_15] FLOAT, [Hr18_30] FLOAT, [Hr18_45] FLOAT, [Hr18_60] FLOAT, 
	[Hr19_15] FLOAT, [Hr19_30] FLOAT, [Hr19_45] FLOAT, [Hr19_60] FLOAT, 
	[Hr20_15] FLOAT, [Hr20_30] FLOAT, [Hr20_45] FLOAT, [Hr20_60] FLOAT, 
	[Hr21_15] FLOAT, [Hr21_30] FLOAT, [Hr21_45] FLOAT, [Hr21_60] FLOAT, 
	[Hr22_15] FLOAT, [Hr22_30] FLOAT, [Hr22_45] FLOAT, [Hr22_60] FLOAT, 
	[Hr23_15] FLOAT, [Hr23_30] FLOAT, [Hr23_45] FLOAT, [Hr23_60] FLOAT, 
	[Hr24_15] FLOAT, [Hr24_30] FLOAT, [Hr24_45] FLOAT, [Hr24_60] FLOAT, 
	[Hr25_15] FLOAT, [Hr25_30] FLOAT, [Hr25_45] FLOAT, [Hr25_60] FLOAT
)
	
INSERT INTO [#tmp_mv90_data_mins]
SELECT	[meter_id], [channel], [DATE], 
		[00:00], [00:15], [00:30], [00:45], 
		[01:00], [01:15], [01:30], [01:45], 
		[02:00], [02:15], [02:30], [02:45], 
		[03:00], [03:15], [03:30], [03:45], 
		[04:00], [04:15], [04:30], [04:45], 
		[05:00], [05:15], [05:30], [05:45], 
		[06:00], [06:15], [06:30], [06:45], 
		[07:00], [07:15], [07:30], [07:45], 
		[08:00], [08:15], [08:30], [08:45], 
		[09:00], [09:15], [09:30], [09:45], 
		[10:00], [10:15], [10:30], [10:45], 
		[11:00], [11:15], [11:30], [11:45], 
		[12:00], [12:15], [12:30], [12:45], 
		[13:00], [13:15], [13:30], [13:45], 
		[14:00], [14:15], [14:30], [14:45], 
		[15:00], [15:15], [15:30], [15:45], 
		[16:00], [16:15], [16:30], [16:45], 
		[17:00], [17:15], [17:30], [17:45], 
		[18:00], [18:15], [18:30], [18:45], 
		[19:00], [19:15], [19:30], [19:45], 
		[20:00], [20:15], [20:30], [20:45], 
		[21:00], [21:15], [21:30], [21:45], 
		[22:00], [22:15], [22:30], [22:45], 
		[23:00], [23:15], [23:30], [23:45], 
		[24:00], [24:15], [24:30], [24:45]
FROM	(
			SELECT	mi.meter_id,
					tmp.[channel],
					tmp.[date] [DATE],--CONVERT(DATETIME, tmp.[date], 102) [date],
					RIGHT('00'+tmp.[hour],5)[HOUR],						
					CASE 
						--WHEN ( CONVERT(DATETIME, tmp.[date], 102) = md.[date] AND CAST(STUFF(tmp.[hour], CHARINDEX(':', tmp.[hour]),3,'') AS INT) + 1 = md.[hour])
						WHEN ( tmp.[date] = md.[date] AND CAST(STUFF(tmp.[hour], CHARINDEX(':', tmp.[hour]),3,'') AS INT) + 1 = md.[hour])
						THEN 0
						ELSE CAST(tmp.[value] AS FLOAT) 
					END [VALUE]
			FROM	[#tmp_staging_table] tmp
					INNER JOIN [meter_id] mi
						ON  mi.[recorderid] = tmp.[meter_id]
					LEFT JOIN [mv90_DST] md 
						--ON md.[year] = YEAR(CONVERT(DATETIME, tmp.[date], 102)) 
						ON md.[year] = YEAR(tmp.[date]) 
						AND md.[insert_delete] = 'd'
		) DataTable
PIVOT	(
			SUM([VALUE]) 
			FOR [HOUR] IN (
							[00:00], [00:15], [00:30], [00:45], 
							[01:00], [01:15], [01:30], [01:45], 
							[02:00], [02:15], [02:30], [02:45], 
							[03:00], [03:15], [03:30], [03:45], 
							[04:00], [04:15], [04:30], [04:45], 
							[05:00], [05:15], [05:30], [05:45], 
							[06:00], [06:15], [06:30], [06:45], 
							[07:00], [07:15], [07:30], [07:45], 
							[08:00], [08:15], [08:30], [08:45], 
							[09:00], [09:15], [09:30], [09:45], 
							[10:00], [10:15], [10:30], [10:45], 
							[11:00], [11:15], [11:30], [11:45], 
							[12:00], [12:15], [12:30], [12:45], 
							[13:00], [13:15], [13:30], [13:45], 
							[14:00], [14:15], [14:30], [14:45], 
							[15:00], [15:15], [15:30], [15:45], 
							[16:00], [16:15], [16:30], [16:45], 
							[17:00], [17:15], [17:30], [17:45], 
							[18:00], [18:15], [18:30], [18:45], 
							[19:00], [19:15], [19:30], [19:45], 
							[20:00], [20:15], [20:30], [20:45], 
							[21:00], [21:15], [21:30], [21:45], 
							[22:00], [22:15], [22:30], [22:45], 
							[23:00], [23:15], [23:30], [23:45], 
							[24:00], [24:15], [24:30], [24:45]
						)
		) PivotTable

-- sum of the DST hours in the Hr3_15 = Hr3_15 + Hr25_00  
 SELECT @col = 'Hr' + CAST(md.hour AS VARCHAR) + '_15 = Hr' + CAST(md.hour AS VARCHAR) + '_15 + ISNULL(Hr25_15, 0),  
   Hr' + CAST(md.hour AS VARCHAR) + '_30 = Hr' + CAST(md.hour AS VARCHAR) + '_30 + ISNULL(Hr25_30, 0),  
   Hr' + CAST(md.hour AS VARCHAR) + '_45 = Hr' + CAST(md.hour AS VARCHAR) + '_45 + ISNULL(Hr25_45, 0),  
   Hr' + CAST(md.hour AS VARCHAR) + '_60 = Hr' + CAST(md.hour AS VARCHAR) + '_60 + ISNULL(Hr25_60, 0) '  
FROM	#tmp_mv90_data_mins tmp
		INNER JOIN mv90_DST md
		ON  md.date = tmp.prod_date
			   AND md.insert_delete = 'i'
SET @sql = '
			UPDATE	tmp
			SET		' + @col + '
			FROM	#tmp_mv90_data_mins tmp
			INNER JOIN mv90_DST md
				ON  md.date = tmp.prod_date
				AND md.insert_delete = ''i''
			'
EXEC spa_print @sql
EXEC(@sql)

-- insert data into mv90_data summary table
SELECT tf.[meter_id],
	   CONVERT(VARCHAR(7),tf.[prod_date],120)+'-01' [gen_date],
	   CONVERT(VARCHAR(7),tf.[prod_date],120)+'-01' [from_date],
	   DATEADD(MONTH, 1,  CONVERT(VARCHAR(7),tf.[prod_date],120)+'-01') -1 [to_date],
	   tf.[channel],
	   SUM(
	   		ISNULL(tf.[Hr1_15], 0) + ISNULL(tf.[Hr1_30], 0) + ISNULL(tf.[Hr1_45], 0) + ISNULL(tf.[Hr1_60], 0) + 
	   		ISNULL(tf.[Hr2_15], 0) + ISNULL(tf.[Hr2_30], 0) + ISNULL(tf.[Hr2_45], 0) + ISNULL(tf.[Hr2_60], 0) + 
	   		ISNULL(tf.[Hr3_15], 0) + ISNULL(tf.[Hr3_30], 0) + ISNULL(tf.[Hr3_45], 0) + ISNULL(tf.[Hr3_60], 0) + 
	   		ISNULL(tf.[Hr4_15], 0) + ISNULL(tf.[Hr4_30], 0) + ISNULL(tf.[Hr4_45], 0) + ISNULL(tf.[Hr4_60], 0) + 
	   		ISNULL(tf.[Hr5_15], 0) + ISNULL(tf.[Hr5_30], 0) + ISNULL(tf.[Hr5_45], 0) + ISNULL(tf.[Hr5_60], 0) + 
	   		ISNULL(tf.[Hr6_15], 0) + ISNULL(tf.[Hr6_30], 0) + ISNULL(tf.[Hr6_45], 0) + ISNULL(tf.[Hr6_60], 0) + 
	   		ISNULL(tf.[Hr7_15], 0) + ISNULL(tf.[Hr7_30], 0) + ISNULL(tf.[Hr7_45], 0) + ISNULL(tf.[Hr7_60], 0) + 
	   		ISNULL(tf.[Hr8_15], 0) + ISNULL(tf.[Hr8_30], 0) + ISNULL(tf.[Hr8_45], 0) + ISNULL(tf.[Hr8_60], 0) + 
	   		ISNULL(tf.[Hr9_15], 0) + ISNULL(tf.[Hr9_30], 0) + ISNULL(tf.[Hr9_45], 0) + ISNULL(tf.[Hr9_60], 0) + 
	   		ISNULL(tf.[Hr10_15], 0) + ISNULL(tf.[Hr10_30], 0) + ISNULL(tf.[Hr10_45], 0) + ISNULL(tf.[Hr10_60], 0) + 
	   		ISNULL(tf.[Hr11_15], 0) + ISNULL(tf.[Hr11_30], 0) + ISNULL(tf.[Hr11_45], 0) + ISNULL(tf.[Hr11_60], 0) + 
	   		ISNULL(tf.[Hr12_15], 0) + ISNULL(tf.[Hr12_30], 0) + ISNULL(tf.[Hr12_45], 0) + ISNULL(tf.[Hr12_60], 0) + 
	   		ISNULL(tf.[Hr13_15], 0) + ISNULL(tf.[Hr13_30], 0) + ISNULL(tf.[Hr13_45], 0) + ISNULL(tf.[Hr13_60], 0) + 
	   		ISNULL(tf.[Hr14_15], 0) + ISNULL(tf.[Hr14_30], 0) + ISNULL(tf.[Hr14_45], 0) + ISNULL(tf.[Hr14_60], 0) + 
	   		ISNULL(tf.[Hr15_15], 0) + ISNULL(tf.[Hr15_30], 0) + ISNULL(tf.[Hr15_45], 0) + ISNULL(tf.[Hr15_60], 0) + 
	   		ISNULL(tf.[Hr16_15], 0) + ISNULL(tf.[Hr16_30], 0) + ISNULL(tf.[Hr16_45], 0) + ISNULL(tf.[Hr16_60], 0) + 
	   		ISNULL(tf.[Hr17_15], 0) + ISNULL(tf.[Hr17_30], 0) + ISNULL(tf.[Hr17_45], 0) + ISNULL(tf.[Hr17_60], 0) + 
	   		ISNULL(tf.[Hr18_15], 0) + ISNULL(tf.[Hr18_30], 0) + ISNULL(tf.[Hr18_45], 0) + ISNULL(tf.[Hr18_60], 0) + 
	   		ISNULL(tf.[Hr19_15], 0) + ISNULL(tf.[Hr19_30], 0) + ISNULL(tf.[Hr19_45], 0) + ISNULL(tf.[Hr19_60], 0) + 
	   		ISNULL(tf.[Hr20_15], 0) + ISNULL(tf.[Hr20_30], 0) + ISNULL(tf.[Hr20_45], 0) + ISNULL(tf.[Hr20_60], 0) + 
	   		ISNULL(tf.[Hr21_15], 0) + ISNULL(tf.[Hr21_30], 0) + ISNULL(tf.[Hr21_45], 0) + ISNULL(tf.[Hr21_60], 0) + 
	   		ISNULL(tf.[Hr22_15], 0) + ISNULL(tf.[Hr22_30], 0) + ISNULL(tf.[Hr22_45], 0) + ISNULL(tf.[Hr22_60], 0) + 
	   		ISNULL(tf.[Hr23_15], 0) + ISNULL(tf.[Hr23_30], 0) + ISNULL(tf.[Hr23_45], 0) + ISNULL(tf.[Hr23_60], 0) + 
	   		ISNULL(tf.[Hr24_15], 0) + ISNULL(tf.[Hr24_30], 0) + ISNULL(tf.[Hr24_45], 0) + ISNULL(tf.[Hr24_60], 0) 
	   ) [volume]
	   INTO 
	   [#temp_summary]
FROM   [#tmp_mv90_data_mins] tf
GROUP BY
	   tf.[meter_id],
	   tf.[channel],
	   CONVERT(VARCHAR(7),tf.[prod_date],120)+'-01',
	   DATEADD(MONTH, 1,  CONVERT(VARCHAR(7),tf.[prod_date],120)+'-01') -1

--- Delete the Data if  exists
--DELETE mdm
--FROM   [mv90_data_mins] mdm
--       INNER JOIN [mv90_data] md
--            ON  md.[meter_data_id] = mdm.[meter_data_id]
--       INNER JOIN #tmp_mv90_data_mins tf
--            ON  tf.[meter_id] = md.[meter_id]
--            AND md.[channel] = tf.[channel]
--            AND mdm.[prod_date] = tf.[prod_date]
            
--DELETE	md
--FROM	[mv90_data] md
--		INNER JOIN [#temp_summary] ts
--			ON md.[meter_id] = ts.[meter_id]
--			AND md.[channel] = ts.[channel]
--			AND [dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](ts.[from_date])

IF @drilldown_level = 1
BEGIN		
	-- missing meter logic is only valid for import except in Ebase Interface(In Ebase missing meter is handled in Adaptor level)
	INSERT INTO #tmp_missing_meter_id (meter_id)
	SELECT	DISTINCT tmp.meter_id
	FROM #tmp_staging_table tmp
	LEFT JOIN meter_id mi
		ON mi.recorderid = tmp.meter_id
	WHERE	mi.recorderid IS NULL

	DELETE mdm
	FROM   [mv90_data_mins] mdm
	INNER JOIN [mv90_data] md
		ON  md.[meter_data_id] = mdm.[meter_data_id]
	INNER JOIN #tmp_mv90_data_mins tf
		ON  tf.[meter_id] = md.[meter_id]
		AND md.[channel] = tf.[channel]
		AND mdm.[prod_date] = tf.[prod_date]
		
	DELETE	mdm
	FROM	[mv90_data_hour] mdm
	INNER JOIN [mv90_data] md
		 ON  md.[meter_data_id] = mdm.[meter_data_id]
	INNER JOIN #tmp_mv90_data_mins tf
		 ON  tf.[meter_id] = md.[meter_id]
		 AND md.[channel] = tf.[channel]
		 AND mdm.[prod_date] = tf.[prod_date]
				 
	DELETE	md
	FROM	[mv90_data] md
	INNER JOIN [#temp_summary] ts
		ON md.[meter_id] = ts.[meter_id]
		AND md.[channel] = ts.[channel]
		AND [dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](ts.[from_date])
		
	INSERT INTO [mv90_data] ( [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id] )
	SELECT [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], 0
	FROM   #temp_summary

		--insert new data
	INSERT INTO [mv90_data_mins] (
			[meter_data_id], [prod_date], 
			[Hr1_15], [Hr1_30], [Hr1_45], [Hr1_60], 
			[Hr2_15], [Hr2_30], [Hr2_45], [Hr2_60], 
			[Hr3_15], [Hr3_30], [Hr3_45], [Hr3_60], 
			[Hr4_15], [Hr4_30], [Hr4_45], [Hr4_60], 
			[Hr5_15], [Hr5_30], [Hr5_45], [Hr5_60], 
			[Hr6_15], [Hr6_30], [Hr6_45], [Hr6_60], 
			[Hr7_15], [Hr7_30], [Hr7_45], [Hr7_60], 
			[Hr8_15], [Hr8_30], [Hr8_45], [Hr8_60], 
			[Hr9_15], [Hr9_30], [Hr9_45], [Hr9_60], 
			[Hr10_15], [Hr10_30], [Hr10_45], [Hr10_60], 
			[Hr11_15], [Hr11_30], [Hr11_45], [Hr11_60], 
			[Hr12_15], [Hr12_30], [Hr12_45], [Hr12_60], 
			[Hr13_15], [Hr13_30], [Hr13_45], [Hr13_60], 
			[Hr14_15], [Hr14_30], [Hr14_45], [Hr14_60], 
			[Hr15_15], [Hr15_30], [Hr15_45], [Hr15_60], 
			[Hr16_15], [Hr16_30], [Hr16_45], [Hr16_60], 
			[Hr17_15], [Hr17_30], [Hr17_45], [Hr17_60], 
			[Hr18_15], [Hr18_30], [Hr18_45], [Hr18_60], 
			[Hr19_15], [Hr19_30], [Hr19_45], [Hr19_60], 
			[Hr20_15], [Hr20_30], [Hr20_45], [Hr20_60], 
			[Hr21_15], [Hr21_30], [Hr21_45], [Hr21_60], 
			[Hr22_15], [Hr22_30], [Hr22_45], [Hr22_60], 
			[Hr23_15], [Hr23_30], [Hr23_45], [Hr23_60], 
			[Hr24_15], [Hr24_30], [Hr24_45], [Hr24_60], 
			[Hr25_15], [Hr25_30], [Hr25_45], [Hr25_60],
			[uom_id]
	)
	SELECT	md.[meter_data_id], [prod_date], 
			[Hr1_15], [Hr1_30], [Hr1_45], [Hr1_60], 
			[Hr2_15], [Hr2_30], [Hr2_45], [Hr2_60], 
			[Hr3_15], [Hr3_30], [Hr3_45], [Hr3_60], 
			[Hr4_15], [Hr4_30], [Hr4_45], [Hr4_60], 
			[Hr5_15], [Hr5_30], [Hr5_45], [Hr5_60], 
			[Hr6_15], [Hr6_30], [Hr6_45], [Hr6_60], 
			[Hr7_15], [Hr7_30], [Hr7_45], [Hr7_60], 
			[Hr8_15], [Hr8_30], [Hr8_45], [Hr8_60], 
			[Hr9_15], [Hr9_30], [Hr9_45], [Hr9_60], 
			[Hr10_15], [Hr10_30], [Hr10_45], [Hr10_60], 
			[Hr11_15], [Hr11_30], [Hr11_45], [Hr11_60], 
			[Hr12_15], [Hr12_30], [Hr12_45], [Hr12_60], 
			[Hr13_15], [Hr13_30], [Hr13_45], [Hr13_60], 
			[Hr14_15], [Hr14_30], [Hr14_45], [Hr14_60], 
			[Hr15_15], [Hr15_30], [Hr15_45], [Hr15_60], 
			[Hr16_15], [Hr16_30], [Hr16_45], [Hr16_60], 
			[Hr17_15], [Hr17_30], [Hr17_45], [Hr17_60], 
			[Hr18_15], [Hr18_30], [Hr18_45], [Hr18_60], 
			[Hr19_15], [Hr19_30], [Hr19_45], [Hr19_60], 
			[Hr20_15], [Hr20_30], [Hr20_45], [Hr20_60], 
			[Hr21_15], [Hr21_30], [Hr21_45], [Hr21_60], 
			[Hr22_15], [Hr22_30], [Hr22_45], [Hr22_60], 
			[Hr23_15], [Hr23_30], [Hr23_45], [Hr23_60], 
			[Hr24_15], [Hr24_30], [Hr24_45], [Hr24_60], 
			[Hr25_15], [Hr25_30], [Hr25_45], [Hr25_60],
			md.[uom_id]
	FROM	[#tmp_mv90_data_mins] tmdm
	INNER JOIN [mv90_data] md
		ON md.[meter_id] = tmdm.[meter_id]
		AND md.[from_date] =  CONVERT(VARCHAR(7),tmdm.[prod_date],120)+'-01'
		AND md.channel = tmdm.channel

	INSERT INTO mv90_data_hour(meter_data_id,prod_date,
	   Hr1, Hr2, Hr3, Hr4,
	   Hr5, Hr6, Hr7, Hr8,
	   Hr9, Hr10, Hr11, Hr12,
	   Hr13, Hr14, Hr15, Hr16,
	   Hr17, Hr18, Hr19, Hr20,
	   Hr21, Hr22, Hr23, Hr24, Hr25, uom_id)
	SELECT	md.meter_data_id,prod_date,
			SUM(ISNULL(Hr1_15, 0) + ISNULL(Hr1_30, 0) + ISNULL(Hr1_45, 0) + ISNULL(Hr1_60, 0)),
			SUM(ISNULL(Hr2_15, 0) + ISNULL(Hr2_30, 0) + ISNULL(Hr2_45, 0) + ISNULL(Hr2_60, 0)),
			SUM(ISNULL(Hr3_15, 0) + ISNULL(Hr3_30, 0) + ISNULL(Hr3_45, 0) + ISNULL(Hr3_60, 0)),
			SUM(ISNULL(Hr4_15, 0) + ISNULL(Hr4_30, 0) + ISNULL(Hr4_45, 0) + ISNULL(Hr4_60, 0)),
			SUM(ISNULL(Hr5_15, 0) + ISNULL(Hr5_30, 0) + ISNULL(Hr5_45, 0) + ISNULL(Hr5_60, 0)),
			SUM(ISNULL(Hr6_15, 0) + ISNULL(Hr6_30, 0) + ISNULL(Hr6_45, 0) + ISNULL(Hr6_60, 0)),
			SUM(ISNULL(Hr7_15, 0) + ISNULL(Hr7_30, 0) + ISNULL(Hr7_45, 0) + ISNULL(Hr7_60, 0)),
			SUM(ISNULL(Hr8_15, 0) + ISNULL(Hr8_30, 0) + ISNULL(Hr8_45, 0) + ISNULL(Hr8_60, 0)),
			SUM(ISNULL(Hr9_15, 0) + ISNULL(Hr9_30, 0) + ISNULL(Hr9_45, 0) + ISNULL(Hr9_60, 0)),
			SUM(ISNULL(Hr10_15, 0) + ISNULL(Hr10_30, 0) + ISNULL(Hr10_45, 0) + ISNULL(Hr10_60, 0)),
			SUM(ISNULL(Hr11_15, 0) + ISNULL(Hr11_30, 0) + ISNULL(Hr11_45, 0) + ISNULL(Hr11_60, 0)),
			SUM(ISNULL(Hr12_15, 0) + ISNULL(Hr12_30, 0) + ISNULL(Hr12_45, 0) + ISNULL(Hr12_60, 0)),
			SUM(ISNULL(Hr13_15, 0) + ISNULL(Hr13_30, 0) + ISNULL(Hr13_45, 0) + ISNULL(Hr13_60, 0)),
			SUM(ISNULL(Hr14_15, 0) + ISNULL(Hr14_30, 0) + ISNULL(Hr14_45, 0) + ISNULL(Hr14_60, 0)),
			SUM(ISNULL(Hr15_15, 0) + ISNULL(Hr15_30, 0) + ISNULL(Hr15_45, 0) + ISNULL(Hr15_60, 0)),
			SUM(ISNULL(Hr16_15, 0) + ISNULL(Hr16_30, 0) + ISNULL(Hr16_45, 0) + ISNULL(Hr16_60, 0)),
			SUM(ISNULL(Hr17_15, 0) + ISNULL(Hr17_30, 0) + ISNULL(Hr17_45, 0) + ISNULL(Hr17_60, 0)),
			SUM(ISNULL(Hr18_15, 0) + ISNULL(Hr18_30, 0) + ISNULL(Hr18_45, 0) + ISNULL(Hr18_60, 0)),
			SUM(ISNULL(Hr19_15, 0) + ISNULL(Hr19_30, 0) + ISNULL(Hr19_45, 0) + ISNULL(Hr19_60, 0)),
			SUM(ISNULL(Hr20_15, 0) + ISNULL(Hr20_30, 0) + ISNULL(Hr20_45, 0) + ISNULL(Hr20_60, 0)),
			SUM(ISNULL(Hr21_15, 0) + ISNULL(Hr21_30, 0) + ISNULL(Hr21_45, 0) + ISNULL(Hr21_60, 0)),
			SUM(ISNULL(Hr22_15, 0) + ISNULL(Hr22_30, 0) + ISNULL(Hr22_45, 0) + ISNULL(Hr22_60, 0)),
			SUM(ISNULL(Hr23_15, 0) + ISNULL(Hr23_30, 0) + ISNULL(Hr23_45, 0) + ISNULL(Hr23_60, 0)),
			SUM(ISNULL(Hr24_15, 0) + ISNULL(Hr24_30, 0) + ISNULL(Hr24_45, 0) + ISNULL(Hr24_60, 0)),
			SUM(ISNULL(Hr25_15, 0) + ISNULL(Hr25_30, 0) + ISNULL(Hr25_45, 0) + ISNULL(Hr25_60, 0)),
			md.[uom_id]
	FROM	[#tmp_mv90_data_mins] tmdm
	INNER JOIN [mv90_data] md
		ON md.[meter_id] = tmdm.[meter_id]
		AND md.[from_date] = CONVERT(VARCHAR(7),tmdm.[prod_date],120)+'-01'
		AND md.channel = tmdm.channel
	GROUP BY meter_data_id, prod_date, md.uom_id
END
ELSE
BEGIN
	-- insert if doesn't exists
	EXEC('INSERT INTO [mv90_data] ( [meter_id], [gen_date], [from_date], [to_date], [channel], [volume], [uom_id] )
		SELECT t.[meter_id], t.[gen_date], t.[from_date], t.[to_date], t.[channel], ABS(t.[volume]), su.source_uom_id
		FROM   #temp_summary t 
		INNER JOIN meter_id mi ON mi.meter_id = t.meter_id 
		INNER JOIN (
			SELECT DISTINCT meter_id, uom FROM ' + @temp_header_table + '
			UNION ALL
			SELECT DISTINCT mi_sub.recorderid [meter_id], h_sub.uom [uom] FROM ' + @temp_header_table + ' h_sub
			INNER JOIN meter_id mi ON mi.recorderid = h_sub.meter_id
			INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
			INNER JOIN #temp_summary ts ON ts.meter_id = mi_sub.meter_id
			WHERE ts.volume < 0
		) h ON h.meter_id = mi.recorderid 
		INNER JOIN source_uom su ON su.uom_id = h.uom 
		LEFT JOIN mv90_data mv ON mv.meter_id = t.meter_id AND mv.from_date = t.from_date
		WHERE su.source_system_id = 2 
			AND mv.meter_id IS NULL 
		')

	UPDATE t SET t.Hr1_15 = ABS(t.Hr1_15), t.Hr1_30 = ABS(t.Hr1_30), t.Hr1_45 = ABS(t.Hr1_45), t.Hr1_60 = ABS(t.Hr1_60), 
		t.Hr2_15 = ABS(t.Hr2_15), t.Hr2_30 = ABS(t.Hr2_30), t.Hr2_45 = ABS(t.Hr2_45), t.Hr2_60 = ABS(t.Hr2_60), 
		t.Hr3_15 = ABS(t.Hr3_15), t.Hr3_30 = ABS(t.Hr3_30), t.Hr3_45 = ABS(t.Hr3_45), t.Hr3_60 = ABS(t.Hr3_60), 
		t.Hr4_15 = ABS(t.Hr4_15), t.Hr4_30 = ABS(t.Hr4_30), t.Hr4_45 = ABS(t.Hr4_45), t.Hr4_60 = ABS(t.Hr4_60), 
		t.Hr5_15 = ABS(t.Hr5_15), t.Hr5_30 = ABS(t.Hr5_30), t.Hr5_45 = ABS(t.Hr5_45), t.Hr5_60 = ABS(t.Hr5_60), 
		t.Hr6_15 = ABS(t.Hr6_15), t.Hr6_30 = ABS(t.Hr6_30), t.Hr6_45 = ABS(t.Hr6_45), t.Hr6_60 = ABS(t.Hr6_60), 
		t.Hr7_15 = ABS(t.Hr7_15), t.Hr7_30 = ABS(t.Hr7_30), t.Hr7_45 = ABS(t.Hr7_45), t.Hr7_60 = ABS(t.Hr7_60), 
		t.Hr8_15 = ABS(t.Hr8_15), t.Hr8_30 = ABS(t.Hr8_30), t.Hr8_45 = ABS(t.Hr8_45), t.Hr8_60 = ABS(t.Hr8_60), 
		t.Hr9_15 = ABS(t.Hr9_15), t.Hr9_30 = ABS(t.Hr9_30), t.Hr9_45 = ABS(t.Hr9_45), t.Hr9_60 = ABS(t.Hr9_60), 
		t.Hr10_15 = ABS(t.Hr10_15), t.Hr10_30 = ABS(t.Hr10_30), t.Hr10_45 = ABS(t.Hr10_45), t.Hr10_60 = ABS(t.Hr10_60), 
		t.Hr11_15 = ABS(t.Hr11_15), t.Hr11_30 = ABS(t.Hr11_30), t.Hr11_45 = ABS(t.Hr11_45), t.Hr11_60 = ABS(t.Hr11_60),
		t.Hr12_15 = ABS(t.Hr12_15), t.Hr12_30 = ABS(t.Hr12_30), t.Hr12_45 = ABS(t.Hr12_45), t.Hr12_60 = ABS(t.Hr12_60), 
		t.Hr13_15 = ABS(t.Hr13_15), t.Hr13_30 = ABS(t.Hr13_30), t.Hr13_45 = ABS(t.Hr13_45), t.Hr13_60 = ABS(t.Hr13_60), 
		t.Hr14_15 = ABS(t.Hr14_15), t.Hr14_30 = ABS(t.Hr14_30), t.Hr14_45 = ABS(t.Hr14_45), t.Hr14_60 = ABS(t.Hr14_60), 
		t.Hr15_15 = ABS(t.Hr15_15), t.Hr15_30 = ABS(t.Hr15_30), t.Hr15_45 = ABS(t.Hr15_45), t.Hr15_60 = ABS(t.Hr15_60), 
		t.Hr16_15 = ABS(t.Hr16_15), t.Hr16_30 = ABS(t.Hr16_30), t.Hr16_45 = ABS(t.Hr16_45), t.Hr16_60 = ABS(t.Hr16_60), 
		t.Hr17_15 = ABS(t.Hr17_15), t.Hr17_30 = ABS(t.Hr17_30), t.Hr17_45 = ABS(t.Hr17_45), t.Hr17_60 = ABS(t.Hr17_60), 
		t.Hr18_15 = ABS(t.Hr18_15), t.Hr18_30 = ABS(t.Hr18_30), t.Hr18_45 = ABS(t.Hr18_45), t.Hr18_60 = ABS(t.Hr18_60), 
		t.Hr19_15 = ABS(t.Hr19_15), t.Hr19_30 = ABS(t.Hr19_30), t.Hr19_45 = ABS(t.Hr19_45), t.Hr19_60 = ABS(t.Hr19_60), 
		t.Hr20_15 = ABS(t.Hr20_15), t.Hr20_30 = ABS(t.Hr20_30), t.Hr20_45 = ABS(t.Hr20_45), t.Hr20_60 = ABS(t.Hr20_60), 
		t.Hr21_15 = ABS(t.Hr21_15), t.Hr21_30 = ABS(t.Hr21_30), t.Hr21_45 = ABS(t.Hr21_45), t.Hr21_60 = ABS(t.Hr21_60), 
		t.Hr22_15 = ABS(t.Hr22_15), t.Hr22_30 = ABS(t.Hr22_30), t.Hr22_45 = ABS(t.Hr22_45), t.Hr22_60 = ABS(t.Hr22_60), 
		t.Hr23_15 = ABS(t.Hr23_15), t.Hr23_30 = ABS(t.Hr23_30), t.Hr23_45 = ABS(t.Hr23_45), t.Hr23_60 = ABS(t.Hr23_60), 
		t.Hr24_15 = ABS(t.Hr24_15), t.Hr24_30 = ABS(t.Hr24_30), t.Hr24_45 = ABS(t.Hr24_45), t.Hr24_60 = ABS(t.Hr24_60), 
		t.Hr25_15 = ABS(t.Hr25_15), t.Hr25_30 = ABS(t.Hr25_30), t.Hr25_45 = ABS(t.Hr25_45), t.Hr25_60 = ABS(t.Hr25_60) 
	FROM [#tmp_mv90_data_mins] t

	--update  values if already exists
	UPDATE mdm SET
		mdm.Hr1_15 = ISNULL(tmdm.Hr1_15, mdm.Hr1_15), mdm.Hr1_30 = ISNULL(tmdm.Hr1_30, mdm.Hr1_30), mdm.Hr1_45 = ISNULL(tmdm.Hr1_45, mdm.Hr1_45), mdm.Hr1_60 = ISNULL(tmdm.Hr1_60, mdm.Hr1_60), 
		mdm.Hr2_15 = ISNULL(tmdm.Hr2_15, mdm.Hr2_15), mdm.Hr2_30 = ISNULL(tmdm.Hr2_30, mdm.Hr2_30), mdm.Hr2_45 = ISNULL(tmdm.Hr2_45, mdm.Hr2_45), mdm.Hr2_60 = ISNULL(tmdm.Hr2_60, mdm.Hr2_60), 
		mdm.Hr3_15 = ISNULL(tmdm.Hr3_15, mdm.Hr3_15), mdm.Hr3_30 = ISNULL(tmdm.Hr3_30, mdm.Hr3_30), mdm.Hr3_45 = ISNULL(tmdm.Hr3_45, mdm.Hr3_45), mdm.Hr3_60 = ISNULL(tmdm.Hr3_60, mdm.Hr3_60), 
		mdm.Hr4_15 = ISNULL(tmdm.Hr4_15, mdm.Hr4_15), mdm.Hr4_30 = ISNULL(tmdm.Hr4_30, mdm.Hr4_30), mdm.Hr4_45 = ISNULL(tmdm.Hr4_45, mdm.Hr4_45), mdm.Hr4_60 = ISNULL(tmdm.Hr4_60, mdm.Hr4_60), 
		mdm.Hr5_15 = ISNULL(tmdm.Hr5_15, mdm.Hr5_15), mdm.Hr5_30 = ISNULL(tmdm.Hr5_30, mdm.Hr5_30), mdm.Hr5_45 = ISNULL(tmdm.Hr5_45, mdm.Hr5_45), mdm.Hr5_60 = ISNULL(tmdm.Hr5_60, mdm.Hr5_60), 
		mdm.Hr6_15 = ISNULL(tmdm.Hr6_15, mdm.Hr6_15), mdm.Hr6_30 = ISNULL(tmdm.Hr6_30, mdm.Hr6_30), mdm.Hr6_45 = ISNULL(tmdm.Hr6_45, mdm.Hr6_45), mdm.Hr6_60 = ISNULL(tmdm.Hr6_60, mdm.Hr6_60), 
		mdm.Hr7_15 = ISNULL(tmdm.Hr7_15, mdm.Hr7_15), mdm.Hr7_30 = ISNULL(tmdm.Hr7_30, mdm.Hr7_30), mdm.Hr7_45 = ISNULL(tmdm.Hr7_45, mdm.Hr7_45), mdm.Hr7_60 = ISNULL(tmdm.Hr7_60, mdm.Hr7_60), 
		mdm.Hr8_15 = ISNULL(tmdm.Hr8_15, mdm.Hr8_15), mdm.Hr8_30 = ISNULL(tmdm.Hr8_30, mdm.Hr8_30), mdm.Hr8_45 = ISNULL(tmdm.Hr8_45, mdm.Hr8_45), mdm.Hr8_60 = ISNULL(tmdm.Hr8_60, mdm.Hr8_60), 
		mdm.Hr9_15 = ISNULL(tmdm.Hr9_15, mdm.Hr9_15), mdm.Hr9_30 = ISNULL(tmdm.Hr9_30, mdm.Hr9_30), mdm.Hr9_45 = ISNULL(tmdm.Hr9_45, mdm.Hr9_45), mdm.Hr9_60 = ISNULL(tmdm.Hr9_60, mdm.Hr9_60), 
		mdm.Hr10_15 = ISNULL(tmdm.Hr10_15, mdm.Hr10_15), mdm.Hr10_30 = ISNULL(tmdm.Hr10_30, mdm.Hr10_30), mdm.Hr10_45 = ISNULL(tmdm.Hr10_45, mdm.Hr10_45), mdm.Hr10_60 = ISNULL(tmdm.Hr10_60, mdm.Hr10_60), 
		mdm.Hr11_15 = ISNULL(tmdm.Hr11_15, mdm.Hr11_15), mdm.Hr11_30 = ISNULL(tmdm.Hr11_30, mdm.Hr11_30), mdm.Hr11_45 = ISNULL(tmdm.Hr11_45, mdm.Hr11_45), mdm.Hr11_60 = ISNULL(tmdm.Hr11_60, mdm.Hr11_60), 
		mdm.Hr12_15 = ISNULL(tmdm.Hr12_15, mdm.Hr12_15), mdm.Hr12_30 = ISNULL(tmdm.Hr12_30, mdm.Hr12_30), mdm.Hr12_45 = ISNULL(tmdm.Hr12_45, mdm.Hr12_45), mdm.Hr12_60 = ISNULL(tmdm.Hr12_60, mdm.Hr12_60), 
		mdm.Hr13_15 = ISNULL(tmdm.Hr13_15, mdm.Hr13_15), mdm.Hr13_30 = ISNULL(tmdm.Hr13_30, mdm.Hr13_30), mdm.Hr13_45 = ISNULL(tmdm.Hr13_45, mdm.Hr13_45), mdm.Hr13_60 = ISNULL(tmdm.Hr13_60, mdm.Hr13_60), 
		mdm.Hr14_15 = ISNULL(tmdm.Hr14_15, mdm.Hr14_15), mdm.Hr14_30 = ISNULL(tmdm.Hr14_30, mdm.Hr14_30), mdm.Hr14_45 = ISNULL(tmdm.Hr14_45, mdm.Hr14_45), mdm.Hr14_60 = ISNULL(tmdm.Hr14_60, mdm.Hr14_60), 
		mdm.Hr15_15 = ISNULL(tmdm.Hr15_15, mdm.Hr15_15), mdm.Hr15_30 = ISNULL(tmdm.Hr15_30, mdm.Hr15_30), mdm.Hr15_45 = ISNULL(tmdm.Hr15_45, mdm.Hr15_45), mdm.Hr15_60 = ISNULL(tmdm.Hr15_60, mdm.Hr15_60), 
		mdm.Hr16_15 = ISNULL(tmdm.Hr16_15, mdm.Hr16_15), mdm.Hr16_30 = ISNULL(tmdm.Hr16_30, mdm.Hr16_30), mdm.Hr16_45 = ISNULL(tmdm.Hr16_45, mdm.Hr16_45), mdm.Hr16_60 = ISNULL(tmdm.Hr16_60, mdm.Hr16_60), 
		mdm.Hr17_15 = ISNULL(tmdm.Hr17_15, mdm.Hr17_15), mdm.Hr17_30 = ISNULL(tmdm.Hr17_30, mdm.Hr17_30), mdm.Hr17_45 = ISNULL(tmdm.Hr17_45, mdm.Hr17_45), mdm.Hr17_60 = ISNULL(tmdm.Hr17_60, mdm.Hr17_60), 
		mdm.Hr18_15 = ISNULL(tmdm.Hr18_15, mdm.Hr18_15), mdm.Hr18_30 = ISNULL(tmdm.Hr18_30, mdm.Hr18_30), mdm.Hr18_45 = ISNULL(tmdm.Hr18_45, mdm.Hr18_45), mdm.Hr18_60 = ISNULL(tmdm.Hr18_60, mdm.Hr18_60), 
		mdm.Hr19_15 = ISNULL(tmdm.Hr19_15, mdm.Hr19_15), mdm.Hr19_30 = ISNULL(tmdm.Hr19_30, mdm.Hr19_30), mdm.Hr19_45 = ISNULL(tmdm.Hr19_45, mdm.Hr19_45), mdm.Hr19_60 = ISNULL(tmdm.Hr19_60, mdm.Hr19_60), 
		mdm.Hr20_15 = ISNULL(tmdm.Hr20_15, mdm.Hr20_15), mdm.Hr20_30 = ISNULL(tmdm.Hr20_30, mdm.Hr20_30), mdm.Hr20_45 = ISNULL(tmdm.Hr20_45, mdm.Hr20_45), mdm.Hr20_60 = ISNULL(tmdm.Hr20_60, mdm.Hr20_60), 
		mdm.Hr21_15 = ISNULL(tmdm.Hr21_15, mdm.Hr21_15), mdm.Hr21_30 = ISNULL(tmdm.Hr21_30, mdm.Hr21_30), mdm.Hr21_45 = ISNULL(tmdm.Hr21_45, mdm.Hr21_45), mdm.Hr21_60 = ISNULL(tmdm.Hr21_60, mdm.Hr21_60), 
		mdm.Hr22_15 = ISNULL(tmdm.Hr22_15, mdm.Hr22_15), mdm.Hr22_30 = ISNULL(tmdm.Hr22_30, mdm.Hr22_30), mdm.Hr22_45 = ISNULL(tmdm.Hr22_45, mdm.Hr22_45), mdm.Hr22_60 = ISNULL(tmdm.Hr22_60, mdm.Hr22_60), 
		mdm.Hr23_15 = ISNULL(tmdm.Hr23_15, mdm.Hr23_15), mdm.Hr23_30 = ISNULL(tmdm.Hr23_30, mdm.Hr23_30), mdm.Hr23_45 = ISNULL(tmdm.Hr23_45, mdm.Hr23_45), mdm.Hr23_60 = ISNULL(tmdm.Hr23_60, mdm.Hr23_60), 
		mdm.Hr24_15 = ISNULL(tmdm.Hr24_15, mdm.Hr24_15), mdm.Hr24_30 = ISNULL(tmdm.Hr24_30, mdm.Hr24_30), mdm.Hr24_45 = ISNULL(tmdm.Hr24_45, mdm.Hr24_45), mdm.Hr24_60 = ISNULL(tmdm.Hr24_60, mdm.Hr24_60), 
		mdm.Hr25_15 = ISNULL(tmdm.Hr25_15, mdm.Hr25_15), mdm.Hr25_30 = ISNULL(tmdm.Hr25_30, mdm.Hr25_30), mdm.Hr25_45 = ISNULL(tmdm.Hr25_45, mdm.Hr25_45), mdm.Hr25_60 = ISNULL(tmdm.Hr25_60, mdm.Hr25_60)		
	FROM [#tmp_mv90_data_mins]  tmdm
	INNER JOIN [mv90_data] md ON md.[meter_id] = tmdm.[meter_id] AND md.[from_date] = CONVERT(VARCHAR(7),tmdm.[prod_date],120)+'-01'
	INNER JOIN mv90_data_mins mdm ON md.meter_data_id = mdm.meter_data_id AND tmdm.prod_date = mdm.prod_date

	--insert new data if not exists
	INSERT INTO [mv90_data_mins] (
			[meter_data_id], [prod_date], 
			[Hr1_15], [Hr1_30], [Hr1_45], [Hr1_60], 
			[Hr2_15], [Hr2_30], [Hr2_45], [Hr2_60], 
			[Hr3_15], [Hr3_30], [Hr3_45], [Hr3_60], 
			[Hr4_15], [Hr4_30], [Hr4_45], [Hr4_60], 
			[Hr5_15], [Hr5_30], [Hr5_45], [Hr5_60], 
			[Hr6_15], [Hr6_30], [Hr6_45], [Hr6_60], 
			[Hr7_15], [Hr7_30], [Hr7_45], [Hr7_60], 
			[Hr8_15], [Hr8_30], [Hr8_45], [Hr8_60], 
			[Hr9_15], [Hr9_30], [Hr9_45], [Hr9_60], 
			[Hr10_15], [Hr10_30], [Hr10_45], [Hr10_60], 
			[Hr11_15], [Hr11_30], [Hr11_45], [Hr11_60], 
			[Hr12_15], [Hr12_30], [Hr12_45], [Hr12_60], 
			[Hr13_15], [Hr13_30], [Hr13_45], [Hr13_60], 
			[Hr14_15], [Hr14_30], [Hr14_45], [Hr14_60], 
			[Hr15_15], [Hr15_30], [Hr15_45], [Hr15_60], 
			[Hr16_15], [Hr16_30], [Hr16_45], [Hr16_60], 
			[Hr17_15], [Hr17_30], [Hr17_45], [Hr17_60], 
			[Hr18_15], [Hr18_30], [Hr18_45], [Hr18_60], 
			[Hr19_15], [Hr19_30], [Hr19_45], [Hr19_60], 
			[Hr20_15], [Hr20_30], [Hr20_45], [Hr20_60], 
			[Hr21_15], [Hr21_30], [Hr21_45], [Hr21_60], 
			[Hr22_15], [Hr22_30], [Hr22_45], [Hr22_60], 
			[Hr23_15], [Hr23_30], [Hr23_45], [Hr23_60], 
			[Hr24_15], [Hr24_30], [Hr24_45], [Hr24_60], 
			[Hr25_15], [Hr25_30], [Hr25_45], [Hr25_60],
			[uom_id]
	)
	SELECT	md.[meter_data_id], tmdm.[prod_date], 
			tmdm.[Hr1_15], tmdm.[Hr1_30], tmdm.[Hr1_45], tmdm.[Hr1_60], 
			tmdm.[Hr2_15], tmdm.[Hr2_30], tmdm.[Hr2_45], tmdm.[Hr2_60], 
			tmdm.[Hr3_15], tmdm.[Hr3_30], tmdm.[Hr3_45], tmdm.[Hr3_60], 
			tmdm.[Hr4_15], tmdm.[Hr4_30], tmdm.[Hr4_45], tmdm.[Hr4_60], 
			tmdm.[Hr5_15], tmdm.[Hr5_30], tmdm.[Hr5_45], tmdm.[Hr5_60], 
			tmdm.[Hr6_15], tmdm.[Hr6_30], tmdm.[Hr6_45], tmdm.[Hr6_60], 
			tmdm.[Hr7_15], tmdm.[Hr7_30], tmdm.[Hr7_45], tmdm.[Hr7_60], 
			tmdm.[Hr8_15], tmdm.[Hr8_30], tmdm.[Hr8_45], tmdm.[Hr8_60], 
			tmdm.[Hr9_15], tmdm.[Hr9_30], tmdm.[Hr9_45], tmdm.[Hr9_60], 
			tmdm.[Hr10_15], tmdm.[Hr10_30], tmdm.[Hr10_45], tmdm.[Hr10_60], 
			tmdm.[Hr11_15], tmdm.[Hr11_30], tmdm.[Hr11_45], tmdm.[Hr11_60], 
			tmdm.[Hr12_15], tmdm.[Hr12_30], tmdm.[Hr12_45], tmdm.[Hr12_60], 
			tmdm.[Hr13_15], tmdm.[Hr13_30], tmdm.[Hr13_45], tmdm.[Hr13_60], 
			tmdm.[Hr14_15], tmdm.[Hr14_30], tmdm.[Hr14_45], tmdm.[Hr14_60], 
			tmdm.[Hr15_15], tmdm.[Hr15_30], tmdm.[Hr15_45], tmdm.[Hr15_60], 
			tmdm.[Hr16_15], tmdm.[Hr16_30], tmdm.[Hr16_45], tmdm.[Hr16_60], 
			tmdm.[Hr17_15], tmdm.[Hr17_30], tmdm.[Hr17_45], tmdm.[Hr17_60], 
			tmdm.[Hr18_15], tmdm.[Hr18_30], tmdm.[Hr18_45], tmdm.[Hr18_60], 
			tmdm.[Hr19_15], tmdm.[Hr19_30], tmdm.[Hr19_45], tmdm.[Hr19_60], 
			tmdm.[Hr20_15], tmdm.[Hr20_30], tmdm.[Hr20_45], tmdm.[Hr20_60], 
			tmdm.[Hr21_15], tmdm.[Hr21_30], tmdm.[Hr21_45], tmdm.[Hr21_60], 
			tmdm.[Hr22_15], tmdm.[Hr22_30], tmdm.[Hr22_45], tmdm.[Hr22_60], 
			tmdm.[Hr23_15], tmdm.[Hr23_30], tmdm.[Hr23_45], tmdm.[Hr23_60], 
			tmdm.[Hr24_15], tmdm.[Hr24_30], tmdm.[Hr24_45], tmdm.[Hr24_60], 
			tmdm.[Hr25_15], tmdm.[Hr25_30], tmdm.[Hr25_45], tmdm.[Hr25_60],
			md.[uom_id]
	FROM	[#tmp_mv90_data_mins] tmdm
	INNER JOIN [mv90_data] md
		ON md.[meter_id] = tmdm.[meter_id]
		AND md.[from_date] = CONVERT(VARCHAR(7),tmdm.[prod_date],120)+'-01'
	LEFT JOIN [mv90_data_mins] mdm ON mdm.meter_data_id = md.meter_data_id AND tmdm.prod_date = mdm.prod_date
	WHERE mdm.meter_data_id IS NULL


	--update  values if already exists
	UPDATE mdh SET
		mdh.Hr1 = (ISNULL(Hr1_15, 0) + ISNULL(Hr1_30, 0) + ISNULL(Hr1_45, 0) + ISNULL(Hr1_60, 0)), 
		mdh.Hr2 = (ISNULL(Hr2_15, 0) + ISNULL(Hr2_30, 0) + ISNULL(Hr2_45, 0) + ISNULL(Hr2_60, 0)), 
		mdh.Hr3 = (ISNULL(Hr3_15, 0) + ISNULL(Hr3_30, 0) + ISNULL(Hr3_45, 0) + ISNULL(Hr3_60, 0)), 
		mdh.Hr4 = (ISNULL(Hr4_15, 0) + ISNULL(Hr4_30, 0) + ISNULL(Hr4_45, 0) + ISNULL(Hr4_60, 0)), 
		mdh.Hr5 = (ISNULL(Hr5_15, 0) + ISNULL(Hr5_30, 0) + ISNULL(Hr5_45, 0) + ISNULL(Hr5_60, 0)), 
		mdh.Hr6 = (ISNULL(Hr6_15, 0) + ISNULL(Hr6_30, 0) + ISNULL(Hr6_45, 0) + ISNULL(Hr6_60, 0)), 
		mdh.Hr7 = (ISNULL(Hr7_15, 0) + ISNULL(Hr7_30, 0) + ISNULL(Hr7_45, 0) + ISNULL(Hr7_60, 0)), 
		mdh.Hr8 = (ISNULL(Hr8_15, 0) + ISNULL(Hr8_30, 0) + ISNULL(Hr8_45, 0) + ISNULL(Hr8_60, 0)), 
		mdh.Hr9 = (ISNULL(Hr9_15, 0) + ISNULL(Hr9_30, 0) + ISNULL(Hr9_45, 0) + ISNULL(Hr9_60, 0)), 
		mdh.Hr10 = (ISNULL(Hr10_15, 0) + ISNULL(Hr10_30, 0) + ISNULL(Hr10_45, 0) + ISNULL(Hr10_60, 0)), 
		mdh.Hr11 = (ISNULL(Hr11_15, 0) + ISNULL(Hr11_30, 0) + ISNULL(Hr11_45, 0) + ISNULL(Hr11_60, 0)), 
		mdh.Hr12 = (ISNULL(Hr12_15, 0) + ISNULL(Hr12_30, 0) + ISNULL(Hr12_45, 0) + ISNULL(Hr12_60, 0)), 
		mdh.Hr13 = (ISNULL(Hr13_15, 0) + ISNULL(Hr13_30, 0) + ISNULL(Hr13_45, 0) + ISNULL(Hr13_60, 0)),
		mdh.Hr14 = (ISNULL(Hr14_15, 0) + ISNULL(Hr14_30, 0) + ISNULL(Hr14_45, 0) + ISNULL(Hr14_60, 0)), 
		mdh.Hr15 = (ISNULL(Hr15_15, 0) + ISNULL(Hr15_30, 0) + ISNULL(Hr15_45, 0) + ISNULL(Hr15_60, 0)), 
		mdh.Hr16 = (ISNULL(Hr16_15, 0) + ISNULL(Hr16_30, 0) + ISNULL(Hr16_45, 0) + ISNULL(Hr16_60, 0)), 
		mdh.Hr17 = (ISNULL(Hr17_15, 0) + ISNULL(Hr17_30, 0) + ISNULL(Hr17_45, 0) + ISNULL(Hr17_60, 0)), 
		mdh.Hr18 = (ISNULL(Hr18_15, 0) + ISNULL(Hr18_30, 0) + ISNULL(Hr18_45, 0) + ISNULL(Hr18_60, 0)), 
		mdh.Hr19 = (ISNULL(Hr19_15, 0) + ISNULL(Hr19_30, 0) + ISNULL(Hr19_45, 0) + ISNULL(Hr19_60, 0)), 
		mdh.Hr20 = (ISNULL(Hr20_15, 0) + ISNULL(Hr20_30, 0) + ISNULL(Hr20_45, 0) + ISNULL(Hr20_60, 0)), 
		mdh.Hr21 = (ISNULL(Hr21_15, 0) + ISNULL(Hr21_30, 0) + ISNULL(Hr21_45, 0) + ISNULL(Hr21_60, 0)), 
		mdh.Hr22 = (ISNULL(Hr22_15, 0) + ISNULL(Hr22_30, 0) + ISNULL(Hr22_45, 0) + ISNULL(Hr22_60, 0)), 
		mdh.Hr23 = (ISNULL(Hr23_15, 0) + ISNULL(Hr23_30, 0) + ISNULL(Hr23_45, 0) + ISNULL(Hr23_60, 0)), 
		mdh.Hr24 = (ISNULL(Hr24_15, 0) + ISNULL(Hr24_30, 0) + ISNULL(Hr24_45, 0) + ISNULL(Hr24_60, 0)), 
		mdh.Hr25 = (ISNULL(Hr25_15, 0) + ISNULL(Hr25_30, 0) + ISNULL(Hr25_45, 0) + ISNULL(Hr25_60, 0))
	FROM	[#tmp_mv90_data_mins] tmdm
	INNER JOIN [mv90_data] md ON md.[meter_id] = tmdm.[meter_id] AND md.[from_date] = CONVERT(VARCHAR(7),tmdm.[prod_date],120)+'-01'
	INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
		AND tmdm.prod_date = mdh.prod_date

	--insert new data if not exists
	INSERT INTO mv90_data_hour(meter_data_id,prod_date,
	   Hr1, Hr2, Hr3, Hr4,
	   Hr5, Hr6, Hr7, Hr8,
	   Hr9, Hr10, Hr11, Hr12,
	   Hr13, Hr14, Hr15, Hr16,
	   Hr17, Hr18, Hr19, Hr20,
	   Hr21, Hr22, Hr23, Hr24, Hr25, uom_id)
	SELECT	md.meter_data_id,tmdm.prod_date,
			SUM(ISNULL(Hr1_15, 0) + ISNULL(Hr1_30, 0) + ISNULL(Hr1_45, 0) + ISNULL(Hr1_60, 0)),
			SUM(ISNULL(Hr2_15, 0) + ISNULL(Hr2_30, 0) + ISNULL(Hr2_45, 0) + ISNULL(Hr2_60, 0)),
			SUM(ISNULL(Hr3_15, 0) + ISNULL(Hr3_30, 0) + ISNULL(Hr3_45, 0) + ISNULL(Hr3_60, 0)),
			SUM(ISNULL(Hr4_15, 0) + ISNULL(Hr4_30, 0) + ISNULL(Hr4_45, 0) + ISNULL(Hr4_60, 0)),
			SUM(ISNULL(Hr5_15, 0) + ISNULL(Hr5_30, 0) + ISNULL(Hr5_45, 0) + ISNULL(Hr5_60, 0)),
			SUM(ISNULL(Hr6_15, 0) + ISNULL(Hr6_30, 0) + ISNULL(Hr6_45, 0) + ISNULL(Hr6_60, 0)),
			SUM(ISNULL(Hr7_15, 0) + ISNULL(Hr7_30, 0) + ISNULL(Hr7_45, 0) + ISNULL(Hr7_60, 0)),
			SUM(ISNULL(Hr8_15, 0) + ISNULL(Hr8_30, 0) + ISNULL(Hr8_45, 0) + ISNULL(Hr8_60, 0)),
			SUM(ISNULL(Hr9_15, 0) + ISNULL(Hr9_30, 0) + ISNULL(Hr9_45, 0) + ISNULL(Hr9_60, 0)),
			SUM(ISNULL(Hr10_15, 0) + ISNULL(Hr10_30, 0) + ISNULL(Hr10_45, 0) + ISNULL(Hr10_60, 0)),
			SUM(ISNULL(Hr11_15, 0) + ISNULL(Hr11_30, 0) + ISNULL(Hr11_45, 0) + ISNULL(Hr11_60, 0)),
			SUM(ISNULL(Hr12_15, 0) + ISNULL(Hr12_30, 0) + ISNULL(Hr12_45, 0) + ISNULL(Hr12_60, 0)),
			SUM(ISNULL(Hr13_15, 0) + ISNULL(Hr13_30, 0) + ISNULL(Hr13_45, 0) + ISNULL(Hr13_60, 0)),
			SUM(ISNULL(Hr14_15, 0) + ISNULL(Hr14_30, 0) + ISNULL(Hr14_45, 0) + ISNULL(Hr14_60, 0)),
			SUM(ISNULL(Hr15_15, 0) + ISNULL(Hr15_30, 0) + ISNULL(Hr15_45, 0) + ISNULL(Hr15_60, 0)),
			SUM(ISNULL(Hr16_15, 0) + ISNULL(Hr16_30, 0) + ISNULL(Hr16_45, 0) + ISNULL(Hr16_60, 0)),
			SUM(ISNULL(Hr17_15, 0) + ISNULL(Hr17_30, 0) + ISNULL(Hr17_45, 0) + ISNULL(Hr17_60, 0)),
			SUM(ISNULL(Hr18_15, 0) + ISNULL(Hr18_30, 0) + ISNULL(Hr18_45, 0) + ISNULL(Hr18_60, 0)),
			SUM(ISNULL(Hr19_15, 0) + ISNULL(Hr19_30, 0) + ISNULL(Hr19_45, 0) + ISNULL(Hr19_60, 0)),
			SUM(ISNULL(Hr20_15, 0) + ISNULL(Hr20_30, 0) + ISNULL(Hr20_45, 0) + ISNULL(Hr20_60, 0)),
			SUM(ISNULL(Hr21_15, 0) + ISNULL(Hr21_30, 0) + ISNULL(Hr21_45, 0) + ISNULL(Hr21_60, 0)),
			SUM(ISNULL(Hr22_15, 0) + ISNULL(Hr22_30, 0) + ISNULL(Hr22_45, 0) + ISNULL(Hr22_60, 0)),
			SUM(ISNULL(Hr23_15, 0) + ISNULL(Hr23_30, 0) + ISNULL(Hr23_45, 0) + ISNULL(Hr23_60, 0)),
			SUM(ISNULL(Hr24_15, 0) + ISNULL(Hr24_30, 0) + ISNULL(Hr24_45, 0) + ISNULL(Hr24_60, 0)),
			SUM(ISNULL(Hr25_15, 0) + ISNULL(Hr25_30, 0) + ISNULL(Hr25_45, 0) + ISNULL(Hr25_60, 0)),
			md.[uom_id]
	FROM	[#tmp_mv90_data_mins] tmdm
			INNER JOIN [mv90_data] md
				ON md.[meter_id] = tmdm.[meter_id]
			AND md.[from_date] = CONVERT(VARCHAR(7),tmdm.[prod_date],120)+'-01'
			LEFT JOIN [mv90_data_hour] mdh ON mdh.meter_data_id = md.meter_data_id AND tmdm.prod_date = mdh.prod_date
			--CROSS APPLY dbo.fnagetdaywisedate(md.from_date,DATEADD(m,1,md.from_date)-1)  d
			--LEFT JOIN [mv90_data_hour] mdh ON mdh.meter_data_id = md.meter_data_id AND mdh.prod_date = d.day_date
	WHERE mdh.recid IS NULL
	GROUP BY md.meter_data_id, tmdm.prod_date, md.uom_id

		-- update only vol if exists
	UPDATE mv SET mv.volume = mdv.vol_sum  
	FROM (
			SELECT SUM(mdh.Hr1 + mdh.Hr2 + mdh.Hr3 + mdh.Hr4 + mdh.Hr5 + mdh.Hr6 + 
				mdh.Hr7 + mdh.Hr8 + mdh.Hr9 + mdh.Hr10 + mdh.Hr11 + mdh.Hr12 + mdh.Hr13 + mdh.Hr14 + mdh.Hr15 + 
				mdh.Hr16 + mdh.Hr17 + mdh.Hr18 + mdh.Hr19 + mdh.Hr20 + mdh.Hr21 + mdh.Hr22 + 
				mdh.Hr23 + mdh.Hr24 ) vol_sum, meter_data_id
			FROM mv90_data_hour mdh 
			GROUP BY mdh.meter_data_id
		) mdv
	INNER JOIN mv90_data mv ON mv.meter_data_id = mdv.meter_data_id
	INNER JOIN #temp_summary t ON t.meter_id = mv.meter_id

	----############### logic to import aggregate_to_meter as defined in group_meter_mapping

	EXEC('
		UPDATE md SET md.volume = meter_agg.agg_volume 
		FROM ' + @temp_header_table + ' h 
		INNER JOIN meter_id mi ON mi.recorderid = h.meter_id
		INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
		INNER JOIN mv90_data md ON md.meter_id = gmm.aggregate_to_meter
		INNER JOIN
		(
			SELECT gmm2.aggregate_to_meter agg_meter_id, md.from_date, SUM(md.volume) agg_volume
			FROM group_meter_mapping gmm2 
			INNER JOIN mv90_data md ON md.meter_id = gmm2.meter_id
			WHERE gmm2.aggregate_to_meter IS NOT NULL
			GROUP BY gmm2.aggregate_to_meter, md.from_date
		) meter_agg ON meter_agg.agg_meter_id = md.meter_id
			AND meter_agg.from_date = md.from_date
		WHERE h.error_code = ''0''
	')

	EXEC('
		INSERT INTO mv90_data (meter_id, gen_date, from_date, to_date, channel, volume, uom_id, descriptions)
		SELECT gmm.aggregate_to_meter, MAX(md.gen_date) gen_date, md.from_date, MAX(md.to_date) to_date, MAX(md.channel) channel, SUM(md.volume) volume, MAX(md.uom_id) uom_id, MAX(md.descriptions) descriptions
		FROM mv90_data md 
		INNER JOIN meter_id mi ON mi.meter_id = md.meter_id
		INNER JOIN ' + @temp_header_table + ' h ON h.meter_id = mi.recorderid
		INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
		LEFT JOIN mv90_data md2 ON md2.meter_id = gmm.aggregate_to_meter
			AND md2.from_date = md.from_date
		WHERE h.error_code = ''0'' AND md2.meter_id IS NULL
			AND gmm.aggregate_to_meter IS NOT NULL
		GROUP BY gmm.aggregate_to_meter, md.from_date	
	')

	EXEC('
	UPDATE mdh SET mdh.Hr1 = meter_agg.agg_volume_hr1, mdh.Hr2 = meter_agg.agg_volume_hr2, mdh.Hr3 = meter_agg.agg_volume_hr3, 
				   mdh.Hr4 = meter_agg.agg_volume_hr4, mdh.Hr5 = meter_agg.agg_volume_hr5, mdh.Hr6 = meter_agg.agg_volume_hr6, 
				   mdh.Hr7 = meter_agg.agg_volume_hr7, mdh.Hr8 = meter_agg.agg_volume_hr8, mdh.Hr9 = meter_agg.agg_volume_hr9, 
				   mdh.Hr10 = meter_agg.agg_volume_hr10, mdh.Hr11 = meter_agg.agg_volume_hr11, mdh.Hr12 = meter_agg.agg_volume_hr12, 
				   mdh.Hr13 = meter_agg.agg_volume_hr13, mdh.Hr14 = meter_agg.agg_volume_hr14, mdh.Hr15 = meter_agg.agg_volume_hr15, 
				   mdh.Hr16 = meter_agg.agg_volume_hr16, mdh.Hr17 = meter_agg.agg_volume_hr17, mdh.Hr18 = meter_agg.agg_volume_hr18, 
				   mdh.Hr19 = meter_agg.agg_volume_hr19, mdh.Hr20 = meter_agg.agg_volume_hr20, mdh.Hr21 = meter_agg.agg_volume_hr21, 
				   mdh.Hr22 = meter_agg.agg_volume_hr22, mdh.Hr23 = meter_agg.agg_volume_hr23, mdh.Hr24 = meter_agg.agg_volume_hr24, 
				   mdh.Hr25 = meter_agg.agg_volume_hr25
	FROM ' + @temp_header_table + ' h 
	INNER JOIN meter_id mi ON mi.recorderid = h.meter_id
	INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
	INNER JOIN mv90_data md ON md.meter_id = gmm.aggregate_to_meter
	INNER JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
	INNER JOIN
	(
		SELECT gmm2.aggregate_to_meter agg_meter_id, mdh.prod_date, 
			SUM(mdh.Hr1) agg_volume_hr1, SUM(mdh.Hr2) agg_volume_hr2, SUM(mdh.Hr3) agg_volume_hr3, SUM(mdh.Hr4) agg_volume_hr4, 
			SUM(mdh.Hr5) agg_volume_hr5, SUM(mdh.Hr6) agg_volume_hr6, SUM(mdh.Hr7) agg_volume_hr7, SUM(mdh.Hr8) agg_volume_hr8, 
			SUM(mdh.Hr9) agg_volume_hr9, SUM(mdh.Hr10) agg_volume_hr10, SUM(mdh.Hr11) agg_volume_hr11, SUM(mdh.Hr12) agg_volume_hr12, 
			SUM(mdh.Hr13) agg_volume_hr13, SUM(mdh.Hr14) agg_volume_hr14, SUM(mdh.Hr15) agg_volume_hr15, SUM(mdh.Hr16) agg_volume_hr16, 
			SUM(mdh.Hr17) agg_volume_hr17, SUM(mdh.Hr18) agg_volume_hr18, SUM(mdh.Hr19) agg_volume_hr19, SUM(mdh.Hr20) agg_volume_hr20, 
			SUM(mdh.Hr21) agg_volume_hr21, SUM(mdh.Hr22) agg_volume_hr22, SUM(mdh.Hr23) agg_volume_hr23, SUM(mdh.Hr24) agg_volume_hr24, 
			SUM(mdh.Hr25) agg_volume_hr25
		FROM group_meter_mapping gmm2 
		INNER JOIN mv90_data md ON md.meter_id = gmm2.meter_id
		INNER JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
		WHERE gmm2.aggregate_to_meter IS NOT NULL
		GROUP BY gmm2.aggregate_to_meter, mdh.prod_date
	) meter_agg ON meter_agg.agg_meter_id = md.meter_id	AND meter_agg.prod_date = mdh.prod_date
	WHERE h.error_code = ''0''
	')

	EXEC('
	INSERT INTO mv90_data_hour(meter_data_id, prod_date, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, 
											 Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, uom_id)					
		--  SELECT gmm2.aggregate_to_meter, mdh.prod_date
		  SELECT MAX(md_agg.meter_data_id) meter_data_id, mdh.prod_date,
		  SUM(mdh.Hr1) agg_volume_hr1, SUM(mdh.Hr2) agg_volume_hr2, SUM(mdh.Hr3) agg_volume_hr3, SUM(mdh.Hr4) agg_volume_hr4, 
		  SUM(mdh.Hr5) agg_volume_hr5, SUM(mdh.Hr6) agg_volume_hr6, SUM(mdh.Hr7) agg_volume_hr7, SUM(mdh.Hr8) agg_volume_hr8, 
		  SUM(mdh.Hr9) agg_volume_hr9, SUM(mdh.Hr10) agg_volume_hr10, SUM(mdh.Hr11) agg_volume_hr11, SUM(mdh.Hr12) agg_volume_hr12, 
		  SUM(mdh.Hr13) agg_volume_hr13, SUM(mdh.Hr14) agg_volume_hr14, SUM(mdh.Hr15) agg_volume_hr15, SUM(mdh.Hr16) agg_volume_hr16, 
		  SUM(mdh.Hr17) agg_volume_hr17, SUM(mdh.Hr18) agg_volume_hr18, SUM(mdh.Hr19) agg_volume_hr19, SUM(mdh.Hr20) agg_volume_hr20, 
		  SUM(mdh.Hr21) agg_volume_hr21, SUM(mdh.Hr22) agg_volume_hr22, SUM(mdh.Hr23) agg_volume_hr23, SUM(mdh.Hr24) agg_volume_hr24, 
		  SUM(mdh.Hr25) agg_volume_hr25
		  , MAX(md_agg.uom_id) uom_id		  
		FROM
		(
			SELECT DISTINCT gmm.aggregate_to_meter
			FROM ' + @temp_header_table + ' h 
			INNER JOIN meter_id mi ON mi.recorderid = h.meter_id
			INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
			WHERE h.error_code = ''0''
		) gmm_agg
		INNER JOIN group_meter_mapping gmm2 ON gmm2.aggregate_to_meter = gmm_agg.aggregate_to_meter
		INNER JOIN mv90_data md ON md.meter_id = gmm2.meter_id
		INNER JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
		INNER JOIN mv90_data md_agg ON md_agg.meter_id = gmm2.aggregate_to_meter
			AND md_agg.from_date = md.from_date
		LEFT JOIN mv90_data_hour mdh_old ON mdh_old.meter_data_id = md_agg.meter_data_id
			AND mdh_old.prod_date = mdh.prod_date
		WHERE 1 = 1
			AND mdh_old.recid IS NULL
			AND gmm2.aggregate_to_meter IS NOT NULL
		GROUP BY gmm2.aggregate_to_meter, mdh.prod_date
		')

	EXEC('
	UPDATE mdh SET
		mdh.Hr1_15 = meter_agg.agg_volume_hr1_15, mdh.Hr1_30 = meter_agg.agg_volume_hr1_30, mdh.Hr1_45 = meter_agg.agg_volume_hr1_45, mdh.Hr1_60 = meter_agg.agg_volume_hr1_60, 
		mdh.Hr2_15 = meter_agg.agg_volume_hr2_15, mdh.Hr2_30 = meter_agg.agg_volume_hr2_30, mdh.Hr2_45 = meter_agg.agg_volume_hr2_45, mdh.Hr2_60 = meter_agg.agg_volume_hr2_60, 
		mdh.Hr3_15 = meter_agg.agg_volume_hr3_15, mdh.Hr3_30 = meter_agg.agg_volume_hr3_30, mdh.Hr3_45 = meter_agg.agg_volume_hr3_45, mdh.Hr3_60 = meter_agg.agg_volume_hr3_60, 
		mdh.Hr4_15 = meter_agg.agg_volume_hr4_15, mdh.Hr4_30 = meter_agg.agg_volume_hr4_30, mdh.Hr4_45 = meter_agg.agg_volume_hr4_45, mdh.Hr4_60 = meter_agg.agg_volume_hr4_60, 
		mdh.Hr5_15 = meter_agg.agg_volume_hr5_15, mdh.Hr5_30 = meter_agg.agg_volume_hr5_30, mdh.Hr5_45 = meter_agg.agg_volume_hr5_45, mdh.Hr5_60 = meter_agg.agg_volume_hr5_60, 
		mdh.Hr6_15 = meter_agg.agg_volume_hr6_15, mdh.Hr6_30 = meter_agg.agg_volume_hr6_30, mdh.Hr6_45 = meter_agg.agg_volume_hr6_45, mdh.Hr6_60 = meter_agg.agg_volume_hr6_60, 
		mdh.Hr7_15 = meter_agg.agg_volume_hr7_15, mdh.Hr7_30 = meter_agg.agg_volume_hr7_30, mdh.Hr7_45 = meter_agg.agg_volume_hr7_45, mdh.Hr7_60 = meter_agg.agg_volume_hr7_60, 
		mdh.Hr8_15 = meter_agg.agg_volume_hr8_15, mdh.Hr8_30 = meter_agg.agg_volume_hr8_30, mdh.Hr8_45 = meter_agg.agg_volume_hr8_45, mdh.Hr8_60 = meter_agg.agg_volume_hr8_60, 
		mdh.Hr9_15 = meter_agg.agg_volume_hr9_15, mdh.Hr9_30 = meter_agg.agg_volume_hr9_30, mdh.Hr9_45 = meter_agg.agg_volume_hr9_45, mdh.Hr9_60 = meter_agg.agg_volume_hr9_60, 
		mdh.Hr10_15 = meter_agg.agg_volume_hr10_15,mdh.Hr10_30 = meter_agg.agg_volume_hr10_30,mdh.Hr10_45 = meter_agg.agg_volume_hr10_45,mdh.Hr10_60 = meter_agg.agg_volume_hr10_60, 
		mdh.Hr11_15 = meter_agg.agg_volume_hr11_15,mdh.Hr11_30 = meter_agg.agg_volume_hr11_30,mdh.Hr11_45 = meter_agg.agg_volume_hr11_45,mdh.Hr11_60 = meter_agg.agg_volume_hr11_60, 
		mdh.Hr12_15 = meter_agg.agg_volume_hr12_15,mdh.Hr12_30 = meter_agg.agg_volume_hr12_30,mdh.Hr12_45 = meter_agg.agg_volume_hr12_45,mdh.Hr12_60 = meter_agg.agg_volume_hr12_60, 
		mdh.Hr13_15 = meter_agg.agg_volume_hr13_15,mdh.Hr13_30 = meter_agg.agg_volume_hr13_30,mdh.Hr13_45 = meter_agg.agg_volume_hr13_45,mdh.Hr13_60 = meter_agg.agg_volume_hr13_60,
		mdh.Hr14_15 = meter_agg.agg_volume_hr14_15,mdh.Hr14_30 = meter_agg.agg_volume_hr14_30,mdh.Hr14_45 = meter_agg.agg_volume_hr14_45,mdh.Hr14_60 = meter_agg.agg_volume_hr14_60, 
		mdh.Hr15_15 = meter_agg.agg_volume_hr15_15,mdh.Hr15_30 = meter_agg.agg_volume_hr15_30,mdh.Hr15_45 = meter_agg.agg_volume_hr15_45,mdh.Hr15_60 = meter_agg.agg_volume_hr15_60, 
		mdh.Hr16_15 = meter_agg.agg_volume_hr16_15,mdh.Hr16_30 = meter_agg.agg_volume_hr16_30,mdh.Hr16_45 = meter_agg.agg_volume_hr16_45,mdh.Hr16_60 = meter_agg.agg_volume_hr16_60, 
		mdh.Hr17_15 = meter_agg.agg_volume_hr17_15,mdh.Hr17_30 = meter_agg.agg_volume_hr17_30,mdh.Hr17_45 = meter_agg.agg_volume_hr17_45,mdh.Hr17_60 = meter_agg.agg_volume_hr17_60, 
		mdh.Hr18_15 = meter_agg.agg_volume_hr18_15,mdh.Hr18_30 = meter_agg.agg_volume_hr18_30,mdh.Hr18_45 = meter_agg.agg_volume_hr18_45,mdh.Hr18_60 = meter_agg.agg_volume_hr18_60, 
		mdh.Hr19_15 = meter_agg.agg_volume_hr19_15,mdh.Hr19_30 = meter_agg.agg_volume_hr19_30,mdh.Hr19_45 = meter_agg.agg_volume_hr19_45,mdh.Hr19_60 = meter_agg.agg_volume_hr19_60,
		mdh.Hr20_15 = meter_agg.agg_volume_hr20_15,mdh.Hr20_30 = meter_agg.agg_volume_hr20_30,mdh.Hr20_45 = meter_agg.agg_volume_hr20_45,mdh.Hr20_60 = meter_agg.agg_volume_hr20_60, 
		mdh.Hr21_15 = meter_agg.agg_volume_hr21_15,mdh.Hr21_30 = meter_agg.agg_volume_hr21_30,mdh.Hr21_45 = meter_agg.agg_volume_hr21_45,mdh.Hr21_60 = meter_agg.agg_volume_hr21_60, 
		mdh.Hr22_15 = meter_agg.agg_volume_hr22_15,mdh.Hr22_30 = meter_agg.agg_volume_hr22_30,mdh.Hr22_45 = meter_agg.agg_volume_hr22_45,mdh.Hr22_60 = meter_agg.agg_volume_hr22_60, 
		mdh.Hr23_15 = meter_agg.agg_volume_hr23_15,mdh.Hr23_30 = meter_agg.agg_volume_hr23_30,mdh.Hr23_45 = meter_agg.agg_volume_hr23_45,mdh.Hr23_60 = meter_agg.agg_volume_hr23_60, 
		mdh.Hr24_15 = meter_agg.agg_volume_hr24_15,mdh.Hr24_30 = meter_agg.agg_volume_hr24_30,mdh.Hr24_45 = meter_agg.agg_volume_hr24_45,mdh.Hr24_60 = meter_agg.agg_volume_hr24_60, 
		mdh.Hr25_15 = meter_agg.agg_volume_hr25_15,mdh.Hr25_30 = meter_agg.agg_volume_hr25_30,mdh.Hr25_45 = meter_agg.agg_volume_hr25_45,mdh.Hr25_60 = meter_agg.agg_volume_hr25_60
	FROM ' + @temp_header_table + ' h 
	INNER JOIN meter_id mi ON mi.recorderid = h.meter_id
	INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
	INNER JOIN mv90_data md ON md.meter_id = gmm.aggregate_to_meter
	INNER JOIN mv90_data_mins mdh ON mdh.meter_data_id = md.meter_data_id
	INNER JOIN
	(
		SELECT gmm2.aggregate_to_meter agg_meter_id, mdh.prod_date, 
			SUM(Hr1_15)agg_volume_hr1_15, SUM(Hr1_30)agg_volume_hr1_30, SUM(Hr1_45)agg_volume_hr1_45, SUM(Hr1_60)agg_volume_hr1_60,
			SUM(Hr2_15)agg_volume_hr2_15, SUM(Hr2_30)agg_volume_hr2_30, SUM(Hr2_45)agg_volume_hr2_45, SUM(Hr2_60)agg_volume_hr2_60,
			SUM(Hr3_15)agg_volume_hr3_15, SUM(Hr3_30)agg_volume_hr3_30, SUM(Hr3_45)agg_volume_hr3_45, SUM(Hr3_60)agg_volume_hr3_60,
			SUM(Hr4_15)agg_volume_hr4_15, SUM(Hr4_30)agg_volume_hr4_30, SUM(Hr4_45)agg_volume_hr4_45, SUM(Hr4_60)agg_volume_hr4_60,
			SUM(Hr5_15)agg_volume_hr5_15, SUM(Hr5_30)agg_volume_hr5_30, SUM(Hr5_45)agg_volume_hr5_45, SUM(Hr5_60)agg_volume_hr5_60,
			SUM(Hr6_15)agg_volume_hr6_15, SUM(Hr6_30)agg_volume_hr6_30, SUM(Hr6_45)agg_volume_hr6_45, SUM(Hr6_60)agg_volume_hr6_60,
			SUM(Hr7_15)agg_volume_hr7_15, SUM(Hr7_30)agg_volume_hr7_30, SUM(Hr7_45)agg_volume_hr7_45, SUM(Hr7_60)agg_volume_hr7_60,
			SUM(Hr8_15)agg_volume_hr8_15, SUM(Hr8_30)agg_volume_hr8_30, SUM(Hr8_45)agg_volume_hr8_45, SUM(Hr8_60)agg_volume_hr8_60,
			SUM(Hr9_15)agg_volume_hr9_15, SUM(Hr9_30)agg_volume_hr9_30, SUM(Hr9_45)agg_volume_hr9_45, SUM(Hr9_60)agg_volume_hr9_60,
			SUM(Hr10_15)agg_volume_hr10_15, SUM(Hr10_30)agg_volume_hr10_30, SUM(Hr10_45)agg_volume_hr10_45, SUM(Hr10_60)agg_volume_hr10_60,
			SUM(Hr11_15)agg_volume_hr11_15, SUM(Hr11_30)agg_volume_hr11_30, SUM(Hr11_45)agg_volume_hr11_45, SUM(Hr11_60)agg_volume_hr11_60,
			SUM(Hr12_15)agg_volume_hr12_15, SUM(Hr12_30)agg_volume_hr12_30, SUM(Hr12_45)agg_volume_hr12_45, SUM(Hr12_60)agg_volume_hr12_60,
			SUM(Hr13_15)agg_volume_hr13_15, SUM(Hr13_30)agg_volume_hr13_30, SUM(Hr13_45)agg_volume_hr13_45, SUM(Hr13_60)agg_volume_hr13_60,
			SUM(Hr14_15)agg_volume_hr14_15, SUM(Hr14_30)agg_volume_hr14_30, SUM(Hr14_45)agg_volume_hr14_45, SUM(Hr14_60)agg_volume_hr14_60,
			SUM(Hr15_15)agg_volume_hr15_15, SUM(Hr15_30)agg_volume_hr15_30, SUM(Hr15_45)agg_volume_hr15_45, SUM(Hr15_60)agg_volume_hr15_60,
			SUM(Hr16_15)agg_volume_hr16_15, SUM(Hr16_30)agg_volume_hr16_30, SUM(Hr16_45)agg_volume_hr16_45, SUM(Hr16_60)agg_volume_hr16_60,
			SUM(Hr17_15)agg_volume_hr17_15, SUM(Hr17_30)agg_volume_hr17_30, SUM(Hr17_45)agg_volume_hr17_45, SUM(Hr17_60)agg_volume_hr17_60,
			SUM(Hr18_15)agg_volume_hr18_15, SUM(Hr18_30)agg_volume_hr18_30, SUM(Hr18_45)agg_volume_hr18_45, SUM(Hr18_60)agg_volume_hr18_60,
			SUM(Hr19_15)agg_volume_hr19_15, SUM(Hr19_30)agg_volume_hr19_30, SUM(Hr19_45)agg_volume_hr19_45, SUM(Hr19_60)agg_volume_hr19_60,
			SUM(Hr20_15)agg_volume_hr20_15, SUM(Hr20_30)agg_volume_hr20_30, SUM(Hr20_45)agg_volume_hr20_45, SUM(Hr20_60)agg_volume_hr20_60,
			SUM(Hr21_15)agg_volume_hr21_15, SUM(Hr21_30)agg_volume_hr21_30, SUM(Hr21_45)agg_volume_hr21_45, SUM(Hr21_60)agg_volume_hr21_60,
			SUM(Hr22_15)agg_volume_hr22_15, SUM(Hr22_30)agg_volume_hr22_30, SUM(Hr22_45)agg_volume_hr22_45, SUM(Hr22_60)agg_volume_hr22_60,
			SUM(Hr23_15)agg_volume_hr23_15, SUM(Hr23_30)agg_volume_hr23_30, SUM(Hr23_45)agg_volume_hr23_45, SUM(Hr23_60)agg_volume_hr23_60,
			SUM(Hr24_15)agg_volume_hr24_15, SUM(Hr24_30)agg_volume_hr24_30, SUM(Hr24_45)agg_volume_hr24_45, SUM(Hr24_60)agg_volume_hr24_60,
			SUM(Hr25_15)agg_volume_hr25_15, SUM(Hr25_30)agg_volume_hr25_30, SUM(Hr25_45)agg_volume_hr25_45, SUM(Hr25_60)agg_volume_hr25_60
		FROM group_meter_mapping gmm2 
		INNER JOIN mv90_data md ON md.meter_id = gmm2.meter_id
		INNER JOIN mv90_data_mins mdh ON mdh.meter_data_id = md.meter_data_id
		WHERE gmm2.aggregate_to_meter IS NOT NULL
		GROUP BY gmm2.aggregate_to_meter, mdh.prod_date
	) meter_agg ON meter_agg.agg_meter_id = md.meter_id	AND meter_agg.prod_date = mdh.prod_date
	WHERE h.error_code = ''0''
	')

	EXEC('
	INSERT INTO mv90_data_mins(meter_data_id, prod_date, [Hr1_15], [Hr1_30], [Hr1_45], [Hr1_60], 
			[Hr2_15], [Hr2_30], [Hr2_45], [Hr2_60], 
			[Hr3_15], [Hr3_30], [Hr3_45], [Hr3_60], 
			[Hr4_15], [Hr4_30], [Hr4_45], [Hr4_60], 
			[Hr5_15], [Hr5_30], [Hr5_45], [Hr5_60], 
			[Hr6_15], [Hr6_30], [Hr6_45], [Hr6_60], 
			[Hr7_15], [Hr7_30], [Hr7_45], [Hr7_60], 
			[Hr8_15], [Hr8_30], [Hr8_45], [Hr8_60], 
			[Hr9_15], [Hr9_30], [Hr9_45], [Hr9_60], 
			[Hr10_15], [Hr10_30], [Hr10_45], [Hr10_60], 
			[Hr11_15], [Hr11_30], [Hr11_45], [Hr11_60], 
			[Hr12_15], [Hr12_30], [Hr12_45], [Hr12_60], 
			[Hr13_15], [Hr13_30], [Hr13_45], [Hr13_60], 
			[Hr14_15], [Hr14_30], [Hr14_45], [Hr14_60], 
			[Hr15_15], [Hr15_30], [Hr15_45], [Hr15_60], 
			[Hr16_15], [Hr16_30], [Hr16_45], [Hr16_60], 
			[Hr17_15], [Hr17_30], [Hr17_45], [Hr17_60], 
			[Hr18_15], [Hr18_30], [Hr18_45], [Hr18_60], 
			[Hr19_15], [Hr19_30], [Hr19_45], [Hr19_60], 
			[Hr20_15], [Hr20_30], [Hr20_45], [Hr20_60], 
			[Hr21_15], [Hr21_30], [Hr21_45], [Hr21_60], 
			[Hr22_15], [Hr22_30], [Hr22_45], [Hr22_60], 
			[Hr23_15], [Hr23_30], [Hr23_45], [Hr23_60], 
			[Hr24_15], [Hr24_30], [Hr24_45], [Hr24_60], 
			[Hr25_15], [Hr25_30], [Hr25_45], [Hr25_60],uom_id)					
		  SELECT MAX(md_agg.meter_data_id) meter_data_id, mdh.prod_date,
	  		SUM(mdh.Hr1_15), SUM(mdh.Hr1_30), SUM(mdh.Hr1_45), SUM(mdh.Hr1_60),
			SUM(mdh.Hr2_15), SUM(mdh.Hr2_30), SUM(mdh.Hr2_45), SUM(mdh.Hr2_60),
			SUM(mdh.Hr3_15), SUM(mdh.Hr3_30), SUM(mdh.Hr3_45), SUM(mdh.Hr3_60),
			SUM(mdh.Hr4_15), SUM(mdh.Hr4_30), SUM(mdh.Hr4_45), SUM(mdh.Hr4_60),
			SUM(mdh.Hr5_15), SUM(mdh.Hr5_30), SUM(mdh.Hr5_45), SUM(mdh.Hr5_60),
			SUM(mdh.Hr6_15), SUM(mdh.Hr6_30), SUM(mdh.Hr6_45), SUM(mdh.Hr6_60),
			SUM(mdh.Hr7_15), SUM(mdh.Hr7_30), SUM(mdh.Hr7_45), SUM(mdh.Hr7_60),
			SUM(mdh.Hr8_15), SUM(mdh.Hr8_30), SUM(mdh.Hr8_45), SUM(mdh.Hr8_60),
			SUM(mdh.Hr9_15), SUM(mdh.Hr9_30), SUM(mdh.Hr9_45), SUM(mdh.Hr9_60),
			SUM(mdh.Hr10_15), SUM(mdh.Hr10_30), SUM(mdh.Hr10_45), SUM(mdh.Hr10_60),
			SUM(mdh.Hr11_15), SUM(mdh.Hr11_30), SUM(mdh.Hr11_45), SUM(mdh.Hr11_60),
			SUM(mdh.Hr12_15), SUM(mdh.Hr12_30), SUM(mdh.Hr12_45), SUM(mdh.Hr12_60),
			SUM(mdh.Hr13_15), SUM(mdh.Hr13_30), SUM(mdh.Hr13_45), SUM(mdh.Hr13_60),
			SUM(mdh.Hr14_15), SUM(mdh.Hr14_30), SUM(mdh.Hr14_45), SUM(mdh.Hr14_60),
			SUM(mdh.Hr15_15), SUM(mdh.Hr15_30), SUM(mdh.Hr15_45), SUM(mdh.Hr15_60),
			SUM(mdh.Hr16_15), SUM(mdh.Hr16_30), SUM(mdh.Hr16_45), SUM(mdh.Hr16_60),
			SUM(mdh.Hr17_15), SUM(mdh.Hr17_30), SUM(mdh.Hr17_45), SUM(mdh.Hr17_60),
			SUM(mdh.Hr18_15), SUM(mdh.Hr18_30), SUM(mdh.Hr18_45), SUM(mdh.Hr18_60),
			SUM(mdh.Hr19_15), SUM(mdh.Hr19_30), SUM(mdh.Hr19_45), SUM(mdh.Hr19_60),
			SUM(mdh.Hr20_15), SUM(mdh.Hr20_30), SUM(mdh.Hr20_45), SUM(mdh.Hr20_60),
			SUM(mdh.Hr21_15), SUM(mdh.Hr21_30), SUM(mdh.Hr21_45), SUM(mdh.Hr21_60),
			SUM(mdh.Hr22_15), SUM(mdh.Hr22_30), SUM(mdh.Hr22_45), SUM(mdh.Hr22_60),
			SUM(mdh.Hr23_15), SUM(mdh.Hr23_30), SUM(mdh.Hr23_45), SUM(mdh.Hr23_60),
			SUM(mdh.Hr24_15), SUM(mdh.Hr24_30), SUM(mdh.Hr24_45), SUM(mdh.Hr24_60),
			SUM(mdh.Hr25_15), SUM(mdh.Hr25_30), SUM(mdh.Hr25_45), SUM(mdh.Hr25_60),
			MAX(md_agg.uom_id) uom_id	
		FROM
		(
			SELECT DISTINCT gmm.aggregate_to_meter
			FROM ' + @temp_header_table + ' h 
			INNER JOIN meter_id mi ON mi.recorderid = h.meter_id
			INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
			WHERE h.error_code = ''0''
		) gmm_agg
		INNER JOIN group_meter_mapping gmm2 ON gmm2.aggregate_to_meter = gmm_agg.aggregate_to_meter
		INNER JOIN mv90_data md ON md.meter_id = gmm2.meter_id
		INNER JOIN mv90_data_mins mdh ON mdh.meter_data_id = md.meter_data_id
		INNER JOIN mv90_data md_agg ON md_agg.meter_id = gmm2.aggregate_to_meter
			AND md_agg.from_date = md.from_date
		LEFT JOIN mv90_data_mins mdh_old ON mdh_old.meter_data_id = md_agg.meter_data_id
			AND mdh_old.prod_date = mdh.prod_date
		WHERE 1 = 1
			AND mdh_old.recid IS NULL
			AND gmm2.aggregate_to_meter IS NOT NULL
		GROUP BY gmm2.aggregate_to_meter, mdh.prod_date
		')
END	

-- sum of the DST hours in the Hr3 = Hr3 + Hr25   
SELECT	@col = 'Hr' + CAST(md.hour AS VARCHAR) + '_15 = Hr' + CAST(md.hour AS VARCHAR) + '_15 + Hr25_15, 
				Hr' + CAST(md.hour AS VARCHAR) + '_30 = Hr' + CAST(md.hour AS VARCHAR) + '_30 + Hr25_30,
				Hr' + CAST(md.hour AS VARCHAR) + '_45 = Hr' + CAST(md.hour AS VARCHAR) + '_45 + Hr25_45,
				Hr' + CAST(md.hour AS VARCHAR) + '_60 = Hr' + CAST(md.hour AS VARCHAR) + '_60 + Hr25_60'
FROM	#tmp_mv90_data_mins tmp
		INNER JOIN mv90_DST md
		ON  md.date = tmp.prod_date
			AND md.insert_delete = 'i'

SET @sql = '
			UPDATE	tmp
			SET		' + @col + '
			FROM	#tmp_mv90_data_mins tmp
					INNER JOIN mv90_DST md
					ON  md.date = tmp.prod_date
						   AND md.insert_delete = ''i''
			'
EXEC spa_print @sql
EXEC(@sql)
			
SET @type = 's'
			
IF @drilldown_level = 1
BEGIN

	IF @@ERROR <> 0
	BEGIN

		INSERT INTO [Import_Transactions_Log] ( [process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps] )
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   'Import Allocation Data(15 Mins)',
			   'Data Errors',
			   'It is possible that the Data may be incorrect',
			   'Correct the error and reimport.'	
		
	END
		
	-- check for data. if no data exists then give error  
	IF NOT EXISTS(SELECT DISTINCT meter_id FROM  #tmp_mv90_data_mins)
	BEGIN
		INSERT INTO [Import_Transactions_Log] ( [process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps] )
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   'Import Allocation Data(15 Mins)',
			   'Data Errors',
			   'It is possible that the file format may be incorrect',
			   'Correct the error and reimport.'			
	END 
	         
	--Check for errors        
	SET @url_desc = 'Detail...'        
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_transactions_log ''' + @process_id + ''''
	
	IF EXISTS(SELECT * FROM #tmp_missing_meter_id)
	BEGIN
		SET @type = 'e'
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps])
		SELECT @process_id, 'Error', 'Import Data', 'Import Allocation Data(15 Mins)', 'Data Error', 'Meter ID: ' + meter_id + ' not found in the system.', ''
		FROM #tmp_missing_meter_id 		
	END
	
	SELECT @error_count = COUNT(*)
	FROM   Import_Transactions_Log
	WHERE  process_id = @process_id
		   AND code = 'Error'
	         
	INSERT INTO [Import_Transactions_Log] ( [process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps] )
	SELECT @process_id,
		   'Success',
		   'Import Data',
		   'Import Allocation Data(15 Mins)',
		   'Results',
		   'Import/Update Data completed without error for  Meter ID: ' + a.meter_id + ', Channel: ' +
		   CAST(a.channel AS VARCHAR) + ', Volume: ' + CAST(dbo.FNARemoveTrailingZero(SUM(CAST(CAST(a.[VALUE] AS FLOAT) AS NUMERIC(38, 20)))) AS VARCHAR(50)),
		   ''
	FROM [#tmp_staging_table] a
	LEFT JOIN #tmp_missing_meter_id b ON b.meter_id = a.meter_id
	WHERE b.meter_id IS NULL
	GROUP BY a.channel, a.meter_id 

	SET @type = 's'

	IF @error_count > 0
	BEGIN
		INSERT INTO [Import_Transactions_Log] ( [process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps] )
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   'Import Allocation Data(15 Mins)',
			   'Results',
			   'Import/Update Data completed with error(s).',
			   'Correct error(s) and reimport.'        
	   SET @type = 'e'
	END 	
	
	-- Import Audit that catch success as well as errors
	INSERT INTO source_system_data_import_status(process_id, code, [module], [source], [type], [description], recommendation) 
	SELECT @process_id,
		   a.code,
		   'Import Data',
		   'Import Allocation Data(15 Mins)',
		   a.[type],
		   a.[description],
		   a.nextsteps
	FROM [Import_Transactions_Log] a
	WHERE a.process_id = @process_id	
END
ELSE
BEGIN
	IF @@ERROR <> 0
	BEGIN
		INSERT INTO source_system_data_import_status (
			-- status_id -- this column value is auto-generated,
			Process_id,
			code,
			MODULE,
			source,
			[TYPE],
			[description],
			recommendation
		)
		VALUES
		(
			@process_id,
			'Error',
			'Import Data',
			--'Import Allocation Data (15 Mins)',
			'eBase Data Import (15 mins)',
			'Data Errors',
			'It is possible that the Data may be incorrect',
			'Correct the error and reimport.'
		)
	END
		
	-- check for data. if no data exists then give error  
	--IF NOT EXISTS(SELECT DISTINCT meter_id FROM  #tmp_mv90_data_mins)
	--BEGIN

	--	INSERT INTO source_system_data_import_status
	--	(
	--		Process_id,
	--		code,
	--		module,
	--		source,
	--		[type],
	--		[description],
	--		recommendation
	--	)
	--	VALUES
	--	(
	--		@process_id,
	--		'Error',
	--		'Import Data',
	--		--'Import Allocation Data (15 Mins)',
	--		'eBase Data Import',
	--		'Data Errors',
	--		'It is possible that the file format may be incorrect',
	--		'Correct the error and reimport.'	
	--	)		
	--END 
	         
	--Check for errors        
	SET @url_desc = 'Detail...'        
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''
	
	SELECT @error_count = COUNT(*)
	FROM   source_system_data_import_status
	WHERE  process_id = @process_id
		   AND code = 'Error'        


/* -- Safe to remove this commented block since,
   -- this logic is not valid for Ebase Import since missing meter is already handled with insertion logic.	
	IF EXISTS(SELECT * FROM #tmp_missing_meter_id)
	BEGIN
		SET @type = 'e'
		--INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)
		--SELECT	@process_id, 
		--		'Error', 
		--		'Import Data', 
		--		--'Import Allocation Data(15 Mins)',
		--		'eBase Data Import', 
		--		'Data Error', 
		--		'Meter ID: ' + meter_id + ' not found in the system.', 
		--		''
		--FROM #tmp_missing_meter_id 
		
		INSERT INTO source_system_data_import_status_detail
		(
			-- status_id -- this column value is auto-generated,
			process_id,
			source,
			[type],
			[description],
			type_error
		)
		SELECT DISTINCT 
			@process_id,
			'eBase Data Import (15 mins)',
			'Data Error',
			'Meter ID: ' + meter_id + ' not found in the system.', 
			''
		FROM #tmp_missing_meter_id				
		
	END
*/		
	
	INSERT INTO source_system_data_import_status_detail (
		-- status_id -- this column value is auto-generated,
		process_id,
		source,
		[TYPE],
		[description],
		type_error
	)
	SELECT DISTINCT 
		@process_id,
		'eBase Data Import (15 mins)',
		'Data Error',
		'Data Error for Meter Id ' + meter_id + ': ' + h_error,
		h_error
	FROM #tmp_staging_table
	WHERE NULLIF(h_error, '') IS NOT NULL 
	
	INSERT INTO source_system_data_import_status_detail (
		-- status_id -- this column value is auto-generated,
		process_id,
		source,
		[TYPE],
		[description],
		type_error
	)
	SELECT DISTINCT 
		@process_id,
		'eBase Data Import (15 mins)',
		'Data Error',
		'Data Error for Meter Id ' + meter_id + ': ' + d_error,
		d_error
	FROM #tmp_staging_table
	WHERE NULLIF(d_error, '') IS NOT NULL 
	
	INSERT INTO source_system_data_import_status ( [process_id], [code], [MODULE], [source], [TYPE], [description], recommendation)
	SELECT @process_id,
		   'Success',
		   'Import Data',
		   --'Import Allocation Data(15 Mins)',
		   '15 mins Data Import (' + h_filename + ')',
		   'Results',
		   'Import/Update Data completed without error for  Meter ID: ' 
		   + a.meter_id + ', Channel: ' +
		   CAST(a.channel AS VARCHAR) + ', Volume: ' + CAST(dbo.FNARemoveTrailingZero(SUM(CAST(CAST(a.[VALUE] AS FLOAT) AS NUMERIC(38, 20)))) AS VARCHAR(50)),
		   ''
	FROM [#tmp_staging_table] a
	LEFT JOIN #tmp_missing_meter_id b ON b.meter_id = a.meter_id
	WHERE b.meter_id IS NULL
	GROUP BY a.channel, a.meter_id, a.h_filename 
	SET @type = 's'
	
	IF @error_count > 0 OR @type = 'e'     
	BEGIN
		INSERT INTO source_system_data_import_status ( [process_id], [code], [MODULE], [source], [TYPE], [description], recommendation)
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   --'Import Allocation Data(15 Mins)',
			   '15 mins Data Import',
			   'Results',
			   'Import/Update Data completed with error(s).',
			   'Correct error(s) and reimport.'      
	   SET @type = 'e'
	END 
END

-- call sp to update position 
	DECLARE @effected_deals VARCHAR(300)
	SET @user_login_id=ISNULL(@user_login_id,dbo.FNADBUser())

	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
	
	EXEC('	
	SELECT 
		DISTINCT source_deal_header_id 
	INTO '+@effected_deals+'	
	FROM 
		[meter_id] mi
		CROSS APPLY(SELECT DISTINCT [meter_id] FROM [#tmp_staging_table] WHERE [meter_id] = mi.[recorderid]) tmp
		INNER JOIN source_minor_Location_meter smlm ON smlm.meter_id = mi.meter_id
		INNER JOIN source_deal_detail sdd ON sdd.location_id=smlm.source_minor_location_id'
		)
	EXEC spa_actual_position_calc @process_id
--***********************************************************************************************
--------------------New Added to create deal based on mv90 data----------------------------------  
--***********************************************************************************************
SET @strategy_name_for_mv90 = 'PPA'  
SET @trader = 'xcelgen'  
SET @default_uom = 24  
SET @user_login_id = @user_login_id
SET @process_id = REPLACE(NEWID(), '-', '_')
SET @tempTable = [dbo].[FNAProcessTableName]('deal_invoice', @user_login_id, @process_id)

SET @sqlStmt = 'CREATE TABLE ' + @tempTable + '	(
					[book] [VARCHAR] (255)  NULL ,        
					[feeder_system_id] [VARCHAR] (255)  NULL ,        
					[gen_date_from] [VARCHAR] (50)  NULL ,        
					[gen_date_to] [VARCHAR] (50)  NULL ,        
					[volume] [VARCHAR] (255)  NULL ,        
					[uom] [VARCHAR] (50)  NULL ,        
					[price] [VARCHAR] (255)  NULL ,        
					[formula] [VARCHAR] (255)  NULL ,        
					[counterparty] [VARCHAR] (50)  NULL ,        
					[generator] [VARCHAR] (50)  NULL ,        
					[deal_type] [VARCHAR] (10)  NULL ,        
					[deal_sub_type] [VARCHAR] (10)  NULL ,        
					[trader] [VARCHAR] (100)  NULL ,        
					[broker] [VARCHAR] (100)  NULL ,        
					[rec_index] [VARCHAR] (255)  NULL ,        
					[frequency] [VARCHAR] (10)  NULL ,        
					[deal_date] [VARCHAR] (50)  NULL ,        
					[currency] [VARCHAR] (255)  NULL ,        
					[category] [VARCHAR] (20)  NULL ,        
					[buy_sell_flag] [VARCHAR] (10)  NULL,  
					[leg] [VARCHAR] (20)  NULL  , 
					[settlement_volume] VARCHAR(100),
					[settlement_uom] VARCHAR(100)
				)'  
 EXEC(@sqlStmt)
 
 SET @sqlStmt = 'INSERT INTO ' + @tempTable + '  ( 
					[book],
					[feeder_system_id],
					[gen_date_from],
					[gen_date_to],
					[volume],
					[uom],
					[price],
					[counterparty],
					[generator],
					[deal_type],
					[frequency],
					[trader],
					[deal_date],
					[currency],
					[buy_sell_flag],
					[leg],
					[settlement_volume],
					[settlement_uom]
				)
				SELECT	MAX(s.[entity_name]) + ''_'' + ''' + @strategy_name_for_mv90 + ''' + ''_'' + MAX(sd1.[code]) [book],
						''mv90_'' + CAST(rg.[generator_id] AS VARCHAR) + ''_'' + [dbo].[FNAContractMonthFormat](a.[from_date]) [feeder_system_id],
						[dbo].[FNAGetSQLStandardDate](a.[from_date]) [gen_date_from],
						[dbo].[FNAGetSQLStandardDate]([dbo].[FNALastDayInDate](a.[from_date])) [gen_date_to],
						FLOOR(SUM(a.[volume]) * ISNULL(MAX(rg.[contract_allocation]), 1)) [volume],
						' + CAST(@default_uom AS VARCHAR) + ' [uom],
						NULL [price],
						MAX(rg.[ppa_counterparty_id]) [counterparty],
						rg.[generator_id] [generator],
						''Rec Energy'' [deal_type],
						''m'' [frequeny],
						''' + @trader + ''' [trader],
						a.[from_date] [deal_date],
						''USD'' [currency],
						''b'' [buy_sell_flag],
						1 [leg],
						SUM([settlement_volume]) * ISNULL(MAX(rg.[contract_allocation]), 1) [settlement_volume],
						MAX([uom_id]) [settlement_uom]							
				FROM	(
							SELECT	[meter_id],
									SUM([volume] * conv.[conversion_factor]) AS [volume],
									MAX([uom_id]) [uom_id],
									SUM([volume]) [settlement_volume],
									MAX([from_date]) [from_date]
							FROM	(
										SELECT	mv.[meter_id], ( mv.[volume] - (COALESCE(meter.[gre_per], meter1.[gre_per], 0)) * mv.volume ) * mult_factor AS volume,
												mv.[channel],
												[mult_factor],
												md.[uom_id],
												CONVERT(VARCHAR(7),mv.[from_date],120)+''-01'' [from_date]
										FROM	[#temp_summary] mv
												INNER JOIN (SELECT [meter_id] FROM [recorder_generator_map] GROUP BY [meter_id] HAVING COUNT(DISTINCT [generator_id]) = 1) a
													ON  mv.[meter_id] = a.[meter_id]
												 INNER JOIN [recorder_properties] md
													  ON  mv.[meter_id] = md.[meter_id]
													  AND md.[channel] = mv.[channel]
												 LEFT JOIN [meter_id_allocation] meter
													  ON  meter.[meter_id] = mv.[meter_id]
													  AND meter.[production_month] = mv.[from_date]
												 LEFT JOIN [meter_id_allocation] meter1
													  ON  meter1.[meter_id] = mv.[meter_id]
										WHERE  mv.[volume] > 0
									) a
									INNER JOIN [rec_volume_unit_conversion] conv
										ON  a.[uom_id] = conv.[from_source_uom_id]
										AND conv.[to_source_uom_id] = ' + CAST(@default_uom AS VARCHAR) + '
										AND conv.[state_value_id] IS NULL
										AND conv.[assignment_type_value_id] IS NULL
										AND conv.[curve_id] IS NULL
							GROUP BY [meter_id]
						) a
						INNER JOIN [recorder_generator_map] rgm
							ON  rgm.[meter_id] = a.[meter_id]
						INNER JOIN [rec_generator] rg
							ON  rg.[generator_id] = rgm.[generator_id]
						INNER JOIN [static_data_value] sd
							ON  rg.[state_value_id] = sd.[value_id]
						INNER JOIN [portfolio_hierarchy] s
							ON  s.[entity_id] = rg.[legal_entity_value_id]
						LEFT JOIN [static_data_value] sd1
							ON  sd1.[value_id] = rg.[state_value_id]
				GROUP BY rg.[generator_id], a.[from_date]    
'
EXEC(@sqlStmt)

--EXEC spb_process_transactions @user_login_id,@tempTable,'n','y'  

SET @total_count = 0

SELECT @total_count = COUNT(*)
FROM   [#tmp_staging_table]

SET @total_count_v = CAST(ISNULL(@total_count, 0) AS VARCHAR)

IF @drilldown_level = 1
BEGIN
	SET @url_desc = '<a target="_blank" href="' + @url + '">' 
					+ ' Allocation data import process completed on as of date ' 
					+ [dbo].[FNAUserDateFormat](GETDATE(), @user_login_id) 
					+ CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END 
					+ '.</a>'

	EXEC spa_message_board 'i', @user_login_id, NULL, ' Import Allocation Data(15 mins)', @url_desc, '', '', @type, @job_name 	
END
ELSE
BEGIN
	--SET @url_desc = '<a target="_blank" href="' + @url + '">' 
	--				+ ' Meter data import process completed on as of date ' 
	--				+ [dbo].[FNAUserDateFormat](GETDATE(), @user_login_id) 
	--				+ CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END 
	--				+ '.</a>'

	--EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @url_desc, '', '', @type, @job_name 
	
	SELECT @type [TYPE]		
END

