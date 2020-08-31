
IF OBJECT_ID(N'spa_import_short_term_forecast_data', N'P') IS NOT NULL
DROP PROC [dbo].[spa_import_short_term_forecast_data]
GO 


CREATE PROC [dbo].[spa_import_short_term_forecast_data]
	@temp_table_name VARCHAR(128),
	@type VARCHAR(50), -- p: power, g: gas
	@job_name VARCHAR(100),
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50),
	@as_of_date VARCHAR(30) = NULL, 
	@temp_log_table VARCHAR(128) = NULL

AS 

DECLARE @col VARCHAR(400)

SELECT @as_of_date = ISNULL(@as_of_date,GETDATE())
CREATE TABLE #inserted_short_term_data (short_term_forecast_id INT, [type] VARCHAR(5) COLLATE DATABASE_DEFAULT)
IF @type = 'g' -- Hourly  Data (gas data starting from 7th hour to next day 6th hr)
BEGIN
		TRUNCATE TABLE #inserted_short_term_data
		
		CREATE TABLE #stage_st_forecast_hour
		(
			[stage_st_forecast_hour_id] [int] IDENTITY(1,1) NOT NULL,
			[stage_st_header_log_id] [INT] NOT NULL,
			[st_forecast_group_name] [VARCHAR](128) COLLATE DATABASE_DEFAULT NOT NULL, [term_start] DATETIME, [Hr] INT, [value] VARCHAR(64) COLLATE DATABASE_DEFAULT
		)
		
		-- shifting 7th hour to 1st hour
		EXEC('INSERT INTO #stage_st_forecast_hour(stage_st_header_log_id, st_forecast_group_name, term_start, Hr, value )
				SELECT stage_st_header_log_id, st_forecast_group_name
				, CONVERT(VARCHAR(10),  DATEADD(hh, -6 , DATEADD(hh, Hr-1, CONVERT(DATETIME, term_start, 103)) ), 120) term_start_shifted
				, CAST( CAST( CAST( DATEADD(hh, -6 , DATEADD(hh, Hr-1, CONVERT(DATETIME, term_start, 103)) ) AS TIME ) AS VARCHAR(2) ) + 1 AS INT ) Hr_shifted
				, value FROM ' + @temp_table_name
				
			)
	
		-- DST 2nd row in 25th hr
		INSERT INTO #stage_st_forecast_hour(stage_st_header_log_id, st_forecast_group_name, term_start, Hr, value )
		select stage_st_header_log_id, st_forecast_group_name, term_start, 25 Hr, value FROM #stage_st_forecast_hour	
		WHERE stage_st_forecast_hour_id NOT IN
		(
		SELECT MIN(stage_st_forecast_hour_id)
		FROM #stage_st_forecast_hour
		GROUP BY [stage_st_header_log_id], [st_forecast_group_name], [term_start], [Hr]
		)

		CREATE TABLE #tmp_st_data_hour (
		[stage_st_header_log_id] INT,	
		[st_forecast_group_name] VARCHAR(128) COLLATE DATABASE_DEFAULT,
		[term_start] DATETIME,
		[Hr1] NUMERIC(38,20),
		[Hr2] NUMERIC(38,20),
		[Hr3] NUMERIC(38,20),
		[Hr4] NUMERIC(38,20),
		[Hr5] NUMERIC(38,20),
		[Hr6] NUMERIC(38,20),
		[Hr7] NUMERIC(38,20),
		[Hr8] NUMERIC(38,20),
		[Hr9] NUMERIC(38,20),
		[Hr10] NUMERIC(38,20),
		[Hr11] NUMERIC(38,20),
		[Hr12] NUMERIC(38,20),
		[Hr13] NUMERIC(38,20),
		[Hr14] NUMERIC(38,20),
		[Hr15] NUMERIC(38,20),
		[Hr16] NUMERIC(38,20),
		[Hr17] NUMERIC(38,20),
		[Hr18] NUMERIC(38,20),
		[Hr19] NUMERIC(38,20),
		[Hr20] NUMERIC(38,20),
		[Hr21] NUMERIC(38,20),
		[Hr22] NUMERIC(38,20),
		[Hr23] NUMERIC(38,20),
		[Hr24] NUMERIC(38,20),
		[Hr25] NUMERIC(38,20)
		)
	
	
	INSERT INTO [#tmp_st_data_hour]
		SELECT	[stage_st_header_log_id], [st_forecast_group_name], [term_start], 
				([0]) Hr1, ([1]) Hr2, ([2]) Hr3, ([3]) Hr4, ([4]) Hr5, ([5]) Hr6, 
				([6]) Hr7, ([7]) Hr8, ([8]) Hr9, ([9]) Hr10, ([10]) Hr11, ([11]) Hr12,
				([12]) Hr13, ([13]) Hr14, ([14]) Hr15, ([15]) Hr16, ([16]) Hr17, ([17]) Hr18, 
				([18]) Hr19, ([19]) Hr20, ([20]) Hr21, ([21]) Hr22, ([22]) Hr23, ([23]) Hr24, ([24]) Hr25
		FROM	(
					SELECT	tmp.stage_st_header_log_id,
							tmp.[st_forecast_group_name], 
							tmp.[term_start], 
							(CAST(tmp.[Hr] AS TINYINT) - 1) [hour],
							CASE 
								WHEN (tmp.[term_start] = md.[date] AND CAST(tmp.[Hr] AS INT) + 1 = md.[hour])
								THEN 0
								ELSE CAST(tmp.[value] AS NUMERIC(38,20)) 
							END [value]
					FROM	#stage_st_forecast_hour tmp
							LEFT JOIN [mv90_DST] md 
								ON md.[year] = YEAR(tmp.[term_start]) 
								AND md.[insert_delete] = 'd'				
				) p
		PIVOT(
				 SUM([value]) FOR [hour] IN ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], 
											[10], [11], [12], [13], [14], [15], [16], 
											[17], [18], [19], [20], [21], [22], [23], 
											[24])
			 ) pvt


	UPDATE sfh SET
		sfh.Hr1 = ISNULL(t.Hr1, sfh.Hr1), sfh.Hr2 = ISNULL(t.Hr2, sfh.Hr2), sfh.Hr3 = ISNULL(t.Hr3, sfh.Hr3), 
		sfh.Hr4 = ISNULL(t.Hr4, sfh.Hr4), sfh.Hr5 = ISNULL(t.Hr5, sfh.Hr5), sfh.Hr6 = ISNULL(t.Hr6, sfh.Hr6), 
		sfh.Hr7 = ISNULL(t.Hr7, sfh.Hr7), sfh.Hr8 = ISNULL(t.Hr8, sfh.Hr8), sfh.Hr9 = ISNULL(t.Hr9, sfh.Hr9), 
		sfh.Hr10 = ISNULL(t.Hr10, sfh.Hr10), sfh.Hr11 = ISNULL(t.Hr11, sfh.Hr11), sfh.Hr12 = ISNULL(t.Hr12, sfh.Hr12), 
		sfh.Hr13 = ISNULL(t.Hr13, sfh.Hr13), sfh.Hr14 = ISNULL(t.Hr14, sfh.Hr14), sfh.Hr15 = ISNULL(t.Hr15, sfh.Hr15), 
		sfh.Hr16 = ISNULL(t.Hr16, sfh.Hr16), sfh.Hr17 = ISNULL(t.Hr17, sfh.Hr17), sfh.Hr18 = ISNULL(t.Hr18, sfh.Hr18), 
		sfh.Hr19 = ISNULL(t.Hr19, sfh.Hr19), sfh.Hr20 = ISNULL(t.Hr20, sfh.Hr20), sfh.Hr21 = ISNULL(t.Hr21, sfh.Hr21), 
		sfh.Hr22 = ISNULL(t.Hr22, sfh.Hr22), sfh.Hr23 = ISNULL(t.Hr23, sfh.Hr23), sfh.Hr24 = ISNULL(t.Hr24, sfh.Hr24), 
		sfh.Hr25 = ISNULL(t.Hr25, sfh.Hr25)
	OUTPUT DELETED.st_forecast_hour_id, 'hour' [type] INTO #inserted_short_term_data
	FROM #tmp_st_data_hour t
	INNER JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name
	INNER JOIN st_forecast_hour sfh ON sfh.st_forecast_group_id = sdv.value_id AND  sfh.[term_start] = t.[term_start]
	WHERE sdv.type_id = 19600 
	

	EXEC('	INSERT INTO st_forecast_hour ( [st_forecast_group_id], [term_start],
				[Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12],
				[Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [Hr25],
				[create_user], [create_ts])
			  OUTPUT INSERTED.st_forecast_hour_id, ''hour'' [type] INTO #inserted_short_term_data
			SELECT sdv.value_id, t.term_start, t.[hr1], t.[hr2], t.[hr3], t.[hr4], t.[hr5], t.[hr6], t.[hr7], t.[hr8], t.[hr9], t.[hr10],
		    t.[hr11], t.[hr12], t.[hr13], t.[hr14], t.[hr15], t.[hr16], t.[hr17], t.[hr18], t.[hr19], t.[hr20],
			t.[hr21], t.[hr22], t.[hr23], t.[hr24], t.[hr25], ''' + @user_login_id + ''' user_login_id, ''' + @as_of_date + 
			''' as_of_date 
			FROM #tmp_st_data_hour t
			INNER JOIN ' + @temp_log_table + ' l ON t.stage_st_header_log_id = l.stage_st_header_log_id
			INNER JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name		
			LEFT JOIN st_forecast_hour sfh ON sfh.st_forecast_group_id = sdv.value_id AND  sfh.[term_start] = t.[term_start]						
			WHERE sdv.type_id = 19600 AND l.error_code = ''0'' AND sfh.st_forecast_group_id IS NULL ')


	IF EXISTS(SELECT 1 FROM #inserted_short_term_data)
	BEGIN
		
		INSERT INTO #imported_group(name)
		SELECT DISTINCT sdv.code from #inserted_short_term_data i
		INNER JOIN st_forecast_hour sfh ON sfh.st_forecast_hour_id = i.short_term_forecast_id
		INNER JOIN static_data_value sdv ON sdv.[value_id] = sfh.st_forecast_group_id
		WHERE sdv.type_id = 19600 AND i.[type] = 'hour'

		
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
				SELECT ''' + @process_id + ''', ''Success'', ''Import Data'', l.filename , ''ST Forecast'', 
				l.input_folder + '' Data Import: '' + CAST(COUNT(*) as VARCHAR(10)) + '' rows out of '' + CAST((COUNT(*) + ISNULL(prior_data_count, 0) ) AS VARCHAR(10)) + '' imported/updated successfully''
				FROM ' + @temp_table_name + ' t 
				INNER JOIN ' + @temp_log_table + ' l ON t.stage_st_header_log_id = l.stage_st_header_log_id
				LEFT JOIN (SELECT filename,sum(prior_data_count) prior_data_count from #ignored_st_data group by filename ) i ON i.[filename] = l.filename
				WHERE l.error_code = ''0'' AND l.input_folder = ''Gas''
				GROUP BY l.input_folder, l.filename,i.prior_data_count
				')

		EXEC('INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description])
				SELECT ''' + @process_id + ''', l.filename , ''ST Forecast'', 
				CAST(COUNT(*) AS VARCHAR(10)) + '' rows imported/updated successfully. ST Forecast Group: '' + t.st_forecast_group_name 
				FROM ' + @temp_table_name + ' t 
				INNER JOIN ' + @temp_log_table + ' l ON t.stage_st_header_log_id = l.stage_st_header_log_id
				--INNER JOIN #tmp_st_data_hour s ON s.stage_st_header_log_id = t.stage_st_header_log_id
				WHERE l.error_code = ''0'' AND l.input_folder = ''Gas''
				GROUP BY l.filename, t.st_forecast_group_name    
			')

	END
	

END


ELSE IF @type = 'p' -- Power Data ( 15mins Data)
BEGIN
		TRUNCATE TABLE #inserted_short_term_data
	
		CREATE TABLE #stage_st_forecast_mins
		(
			[stage_st_forecast_hour_id] [int] IDENTITY(1,1) NOT NULL,
			[stage_st_header_log_id] [INT] NOT NULL,
			[st_forecast_group_name] [VARCHAR](128) COLLATE DATABASE_DEFAULT NOT NULL, [term_start] DATETIME, [Hr] VARCHAR(5) COLLATE DATABASE_DEFAULT, [value] VARCHAR(64) COLLATE DATABASE_DEFAULT
		)
		
		EXEC('INSERT INTO #stage_st_forecast_mins(stage_st_header_log_id, st_forecast_group_name, term_start, Hr, value )
				SELECT stage_st_header_log_id, st_forecast_group_name, CONVERT(DATETIME, term_start, 103), CONVERT(CHAR(5), DATEADD(minute, 15*(Hr-1), 0), 108), value FROM ' + @temp_table_name )


		-- DST 2nd rows data into respective 25th mins cols
		INSERT INTO #stage_st_forecast_mins(stage_st_header_log_id, st_forecast_group_name, term_start, Hr, value )
		SELECT stage_st_header_log_id, st_forecast_group_name, term_start, 
		CASE 
			WHEN Hr = '02:00' THEN '24:00'
			WHEN Hr = '02:15' THEN '24:15'
			WHEN Hr = '02:30' THEN '24:30'
			WHEN Hr = '02:45' THEN '24:45'
			ELSE Hr
		END Hr, VALUE
		FROM #stage_st_forecast_mins
		WHERE stage_st_forecast_hour_id NOT IN
		(
		SELECT MIN(stage_st_forecast_hour_id)
		FROM #stage_st_forecast_mins
		GROUP BY [stage_st_header_log_id], [st_forecast_group_name], [term_start], [Hr]
		)
		

		CREATE TABLE #tmp_st_data_mins (
		[stage_st_header_log_id] INT,	
		[st_forecast_group_name] VARCHAR(128) COLLATE DATABASE_DEFAULT,
		[term_start] DATETIME,
		[Hr1_15] NUMERIC(38,20), [Hr1_30] NUMERIC(38,20), [Hr1_45] NUMERIC(38,20), [Hr1_60] NUMERIC(38,20), 
		[Hr2_15] NUMERIC(38,20), [Hr2_30] NUMERIC(38,20), [Hr2_45] NUMERIC(38,20), [Hr2_60] NUMERIC(38,20), 
		[Hr3_15] NUMERIC(38,20), [Hr3_30] NUMERIC(38,20), [Hr3_45] NUMERIC(38,20), [Hr3_60] NUMERIC(38,20), 
		[Hr4_15] NUMERIC(38,20), [Hr4_30] NUMERIC(38,20), [Hr4_45] NUMERIC(38,20), [Hr4_60] NUMERIC(38,20), 
		[Hr5_15] NUMERIC(38,20), [Hr5_30] NUMERIC(38,20), [Hr5_45] NUMERIC(38,20), [Hr5_60] NUMERIC(38,20), 
		[Hr6_15] NUMERIC(38,20), [Hr6_30] NUMERIC(38,20), [Hr6_45] NUMERIC(38,20), [Hr6_60] NUMERIC(38,20), 
		[Hr7_15] NUMERIC(38,20), [Hr7_30] NUMERIC(38,20), [Hr7_45] NUMERIC(38,20), [Hr7_60] NUMERIC(38,20), 
		[Hr8_15] NUMERIC(38,20), [Hr8_30] NUMERIC(38,20), [Hr8_45] NUMERIC(38,20), [Hr8_60] NUMERIC(38,20), 
		[Hr9_15] NUMERIC(38,20), [Hr9_30] NUMERIC(38,20), [Hr9_45] NUMERIC(38,20), [Hr9_60] NUMERIC(38,20), 
		[Hr10_15] NUMERIC(38,20), [Hr10_30] NUMERIC(38,20), [Hr10_45] NUMERIC(38,20), [Hr10_60] NUMERIC(38,20), 
		[Hr11_15] NUMERIC(38,20), [Hr11_30] NUMERIC(38,20), [Hr11_45] NUMERIC(38,20), [Hr11_60] NUMERIC(38,20), 
		[Hr12_15] NUMERIC(38,20), [Hr12_30] NUMERIC(38,20), [Hr12_45] NUMERIC(38,20), [Hr12_60] NUMERIC(38,20), 
		[Hr13_15] NUMERIC(38,20), [Hr13_30] NUMERIC(38,20), [Hr13_45] NUMERIC(38,20), [Hr13_60] NUMERIC(38,20), 
		[Hr14_15] NUMERIC(38,20), [Hr14_30] NUMERIC(38,20), [Hr14_45] NUMERIC(38,20), [Hr14_60] NUMERIC(38,20), 
		[Hr15_15] NUMERIC(38,20), [Hr15_30] NUMERIC(38,20), [Hr15_45] NUMERIC(38,20), [Hr15_60] NUMERIC(38,20), 
		[Hr16_15] NUMERIC(38,20), [Hr16_30] NUMERIC(38,20), [Hr16_45] NUMERIC(38,20), [Hr16_60] NUMERIC(38,20), 
		[Hr17_15] NUMERIC(38,20), [Hr17_30] NUMERIC(38,20), [Hr17_45] NUMERIC(38,20), [Hr17_60] NUMERIC(38,20), 
		[Hr18_15] NUMERIC(38,20), [Hr18_30] NUMERIC(38,20), [Hr18_45] NUMERIC(38,20), [Hr18_60] NUMERIC(38,20), 
		[Hr19_15] NUMERIC(38,20), [Hr19_30] NUMERIC(38,20), [Hr19_45] NUMERIC(38,20), [Hr19_60] NUMERIC(38,20), 
		[Hr20_15] NUMERIC(38,20), [Hr20_30] NUMERIC(38,20), [Hr20_45] NUMERIC(38,20), [Hr20_60] NUMERIC(38,20), 
		[Hr21_15] NUMERIC(38,20), [Hr21_30] NUMERIC(38,20), [Hr21_45] NUMERIC(38,20), [Hr21_60] NUMERIC(38,20), 
		[Hr22_15] NUMERIC(38,20), [Hr22_30] NUMERIC(38,20), [Hr22_45] NUMERIC(38,20), [Hr22_60] NUMERIC(38,20), 
		[Hr23_15] NUMERIC(38,20), [Hr23_30] NUMERIC(38,20), [Hr23_45] NUMERIC(38,20), [Hr23_60] NUMERIC(38,20), 
		[Hr24_15] NUMERIC(38,20), [Hr24_30] NUMERIC(38,20), [Hr24_45] NUMERIC(38,20), [Hr24_60] NUMERIC(38,20), 
		[Hr25_15] NUMERIC(38,20), [Hr25_30] NUMERIC(38,20), [Hr25_45] NUMERIC(38,20), [Hr25_60] NUMERIC(38,20)
		)
	
	
	INSERT INTO [#tmp_st_data_mins]
	SELECT	[stage_st_header_log_id], [st_forecast_group_name], [term_start],
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
				SELECT	tmp.stage_st_header_log_id,
						tmp.[st_forecast_group_name], 
						tmp.[term_start], 
						RIGHT('00'+tmp.[Hr], 5)[hour],						
						--CASE 
						--	WHEN ( CONVERT(DATETIME, tmp.[term_start], 102) = md.[date] AND CAST(STUFF(tmp.[Hr], CHARINDEX(':', tmp.[Hr]),3,'') AS INT) + 1 = md.[hour])
						--	THEN 0
						--	ELSE CAST(tmp.[value] AS NUMERIC(38,20)) 
						--END [value]
						CAST(tmp.[value] AS NUMERIC(38,20)) [value]
				FROM	[#stage_st_forecast_mins] tmp
					--	LEFT JOIN [mv90_DST] md 
						--	ON md.[year] = YEAR(CONVERT(DATETIME, tmp.[term_start], 102)) 
						--	AND md.[insert_delete] = 'd'
			) DataTable
	PIVOT	(
				SUM([value]) 
				FOR [hour] IN (
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

	--select * into adiha_process.dbo.test322 from [#tmp_st_data_mins]
	UPDATE sfm SET
	
	sfm.Hr1_15 = ISNULL(t.Hr1_15, sfm.Hr1_15), sfm.Hr1_30 = ISNULL(t.Hr1_30, sfm.Hr1_30), sfm.Hr1_45 = ISNULL(t.Hr1_45, sfm.Hr1_45), sfm.Hr1_60 = ISNULL(t.Hr1_60, sfm.Hr1_60), 
	sfm.Hr2_15 = ISNULL(t.Hr2_15, sfm.Hr2_15), sfm.Hr2_30 = ISNULL(t.Hr2_30, sfm.Hr2_30), sfm.Hr2_45 = ISNULL(t.Hr2_45, sfm.Hr2_45), sfm.Hr2_60 = ISNULL(t.Hr2_60, sfm.Hr2_60), 
	sfm.Hr3_15 = ISNULL(t.Hr3_15, sfm.Hr3_15), sfm.Hr3_30 = ISNULL(t.Hr3_30, sfm.Hr3_30), sfm.Hr3_45 = ISNULL(t.Hr3_45, sfm.Hr3_45), sfm.Hr3_60 = ISNULL(t.Hr3_60, sfm.Hr3_60), 
	sfm.Hr4_15 = ISNULL(t.Hr4_15, sfm.Hr4_15), sfm.Hr4_30 = ISNULL(t.Hr4_30, sfm.Hr4_30), sfm.Hr4_45 = ISNULL(t.Hr4_45, sfm.Hr4_45), sfm.Hr4_60 = ISNULL(t.Hr4_60, sfm.Hr4_60), 
	sfm.Hr5_15 = ISNULL(t.Hr5_15, sfm.Hr5_15), sfm.Hr5_30 = ISNULL(t.Hr5_30, sfm.Hr5_30), sfm.Hr5_45 = ISNULL(t.Hr5_45, sfm.Hr5_45), sfm.Hr5_60 = ISNULL(t.Hr5_60, sfm.Hr5_60), 
	sfm.Hr6_15 = ISNULL(t.Hr6_15, sfm.Hr6_15), sfm.Hr6_30 = ISNULL(t.Hr6_30, sfm.Hr6_30), sfm.Hr6_45 = ISNULL(t.Hr6_45, sfm.Hr6_45), sfm.Hr6_60 = ISNULL(t.Hr6_60, sfm.Hr6_60), 
	sfm.Hr7_15 = ISNULL(t.Hr7_15, sfm.Hr7_15), sfm.Hr7_30 = ISNULL(t.Hr7_30, sfm.Hr7_30), sfm.Hr7_45 = ISNULL(t.Hr7_45, sfm.Hr7_45), sfm.Hr7_60 = ISNULL(t.Hr7_60, sfm.Hr7_60), 
	sfm.Hr8_15 = ISNULL(t.Hr8_15, sfm.Hr8_15), sfm.Hr8_30 = ISNULL(t.Hr8_30, sfm.Hr8_30), sfm.Hr8_45 = ISNULL(t.Hr8_45, sfm.Hr8_45), sfm.Hr8_60 = ISNULL(t.Hr8_60, sfm.Hr8_60), 
	sfm.Hr9_15 = ISNULL(t.Hr9_15, sfm.Hr9_15), sfm.Hr9_30 = ISNULL(t.Hr9_30, sfm.Hr9_30), sfm.Hr9_45 = ISNULL(t.Hr9_45, sfm.Hr9_45), sfm.Hr9_60 = ISNULL(t.Hr9_60, sfm.Hr9_60), 
	sfm.Hr10_15 = ISNULL(t.Hr10_15, sfm.Hr10_15), sfm.Hr10_30 = ISNULL(t.Hr10_30, sfm.Hr10_30), sfm.Hr10_45 = ISNULL(t.Hr10_45, sfm.Hr10_45), sfm.Hr10_60 = ISNULL(t.Hr10_60, sfm.Hr10_60), 
	sfm.Hr11_15 = ISNULL(t.Hr11_15, sfm.Hr11_15), sfm.Hr11_30 = ISNULL(t.Hr11_30, sfm.Hr11_30), sfm.Hr11_45 = ISNULL(t.Hr11_45, sfm.Hr11_45), sfm.Hr11_60 = ISNULL(t.Hr11_60, sfm.Hr11_60), 
	sfm.Hr12_15 = ISNULL(t.Hr12_15, sfm.Hr12_15), sfm.Hr12_30 = ISNULL(t.Hr12_30, sfm.Hr12_30), sfm.Hr12_45 = ISNULL(t.Hr12_45, sfm.Hr12_45), sfm.Hr12_60 = ISNULL(t.Hr12_60, sfm.Hr12_60), 
	sfm.Hr13_15 = ISNULL(t.Hr13_15, sfm.Hr13_15), sfm.Hr13_30 = ISNULL(t.Hr13_30, sfm.Hr13_30), sfm.Hr13_45 = ISNULL(t.Hr13_45, sfm.Hr13_45), sfm.Hr13_60 = ISNULL(t.Hr13_60, sfm.Hr13_60), 
	sfm.Hr14_15 = ISNULL(t.Hr14_15, sfm.Hr14_15), sfm.Hr14_30 = ISNULL(t.Hr14_30, sfm.Hr14_30), sfm.Hr14_45 = ISNULL(t.Hr14_45, sfm.Hr14_45), sfm.Hr14_60 = ISNULL(t.Hr14_60, sfm.Hr14_60), 
	sfm.Hr15_15 = ISNULL(t.Hr15_15, sfm.Hr15_15), sfm.Hr15_30 = ISNULL(t.Hr15_30, sfm.Hr15_30), sfm.Hr15_45 = ISNULL(t.Hr15_45, sfm.Hr15_45), sfm.Hr15_60 = ISNULL(t.Hr15_60, sfm.Hr15_60), 
	sfm.Hr16_15 = ISNULL(t.Hr16_15, sfm.Hr16_15), sfm.Hr16_30 = ISNULL(t.Hr16_30, sfm.Hr16_30), sfm.Hr16_45 = ISNULL(t.Hr16_45, sfm.Hr16_45), sfm.Hr16_60 = ISNULL(t.Hr16_60, sfm.Hr16_60), 
	sfm.Hr17_15 = ISNULL(t.Hr17_15, sfm.Hr17_15), sfm.Hr17_30 = ISNULL(t.Hr17_30, sfm.Hr17_30), sfm.Hr17_45 = ISNULL(t.Hr17_45, sfm.Hr17_45), sfm.Hr17_60 = ISNULL(t.Hr17_60, sfm.Hr17_60), 
	sfm.Hr18_15 = ISNULL(t.Hr18_15, sfm.Hr18_15), sfm.Hr18_30 = ISNULL(t.Hr18_30, sfm.Hr18_30), sfm.Hr18_45 = ISNULL(t.Hr18_45, sfm.Hr18_45), sfm.Hr18_60 = ISNULL(t.Hr18_60, sfm.Hr18_60), 
	sfm.Hr19_15 = ISNULL(t.Hr19_15, sfm.Hr19_15), sfm.Hr19_30 = ISNULL(t.Hr19_30, sfm.Hr19_30), sfm.Hr19_45 = ISNULL(t.Hr19_45, sfm.Hr19_45), sfm.Hr19_60 = ISNULL(t.Hr19_60, sfm.Hr19_60), 
	sfm.Hr20_15 = ISNULL(t.Hr20_15, sfm.Hr20_15), sfm.Hr20_30 = ISNULL(t.Hr20_30, sfm.Hr20_30), sfm.Hr20_45 = ISNULL(t.Hr20_45, sfm.Hr20_45), sfm.Hr20_60 = ISNULL(t.Hr20_60, sfm.Hr20_60), 
	sfm.Hr21_15 = ISNULL(t.Hr21_15, sfm.Hr21_15), sfm.Hr21_30 = ISNULL(t.Hr21_30, sfm.Hr21_30), sfm.Hr21_45 = ISNULL(t.Hr21_45, sfm.Hr21_45), sfm.Hr21_60 = ISNULL(t.Hr21_60, sfm.Hr21_60), 
	sfm.Hr22_15 = ISNULL(t.Hr22_15, sfm.Hr22_15), sfm.Hr22_30 = ISNULL(t.Hr22_30, sfm.Hr22_30), sfm.Hr22_45 = ISNULL(t.Hr22_45, sfm.Hr22_45), sfm.Hr22_60 = ISNULL(t.Hr22_60, sfm.Hr22_60), 
	sfm.Hr23_15 = ISNULL(t.Hr23_15, sfm.Hr23_15), sfm.Hr23_30 = ISNULL(t.Hr23_30, sfm.Hr23_30), sfm.Hr23_45 = ISNULL(t.Hr23_45, sfm.Hr23_45), sfm.Hr23_60 = ISNULL(t.Hr23_60, sfm.Hr23_60), 
	sfm.Hr24_15 = ISNULL(t.Hr24_15, sfm.Hr24_15), sfm.Hr24_30 = ISNULL(t.Hr24_30, sfm.Hr24_30), sfm.Hr24_45 = ISNULL(t.Hr24_45, sfm.Hr24_45), sfm.Hr24_60 = ISNULL(t.Hr24_60, sfm.Hr24_60), 
	sfm.Hr25_15 = ISNULL(t.Hr25_15, sfm.Hr25_15), sfm.Hr25_30 = ISNULL(t.Hr25_30, sfm.Hr25_30), sfm.Hr25_45 = ISNULL(t.Hr25_45, sfm.Hr25_45), sfm.Hr25_60 = ISNULL(t.Hr25_60, sfm.Hr25_60)		
	OUTPUT DELETED.st_forecast_mins_id, 'mins' [type] INTO #inserted_short_term_data
	FROM [#tmp_st_data_mins]  t
	INNER JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name
	INNER JOIN st_forecast_mins sfm ON sfm.st_forecast_group_id = sdv.value_id AND  sfm.[term_start] = t.[term_start]
	WHERE sdv.type_id = 19600 
		
	EXEC('	INSERT INTO st_forecast_mins ( [st_forecast_group_id], [term_start],
				[Hr1_15], [Hr1_30], [Hr1_45], [Hr1_60], [Hr2_15], [Hr2_30], [Hr2_45], [Hr2_60], [Hr3_15], [Hr3_30], 
				[Hr3_45], [Hr3_60], [Hr4_15], [Hr4_30], [Hr4_45], [Hr4_60], [Hr5_15], [Hr5_30], [Hr5_45], [Hr5_60], 
				[Hr6_15], [Hr6_30], [Hr6_45], [Hr6_60], [Hr7_15], [Hr7_30], [Hr7_45], [Hr7_60], [Hr8_15], [Hr8_30], 
				[Hr8_45], [Hr8_60], [Hr9_15], [Hr9_30], [Hr9_45], [Hr9_60], [Hr10_15], [Hr10_30], [Hr10_45], 
				[Hr10_60], [Hr11_15], [Hr11_30], [Hr11_45], [Hr11_60], [Hr12_15], [Hr12_30], [Hr12_45], [Hr12_60], 
				[Hr13_15], [Hr13_30], [Hr13_45], [Hr13_60], [Hr14_15], [Hr14_30], [Hr14_45], [Hr14_60], [Hr15_15], 
				[Hr15_30], [Hr15_45], [Hr15_60], [Hr16_15], [Hr16_30], [Hr16_45], [Hr16_60], [Hr17_15], [Hr17_30], 
				[Hr17_45], [Hr17_60], [Hr18_15], [Hr18_30], [Hr18_45], [Hr18_60], [Hr19_15], [Hr19_30], [Hr19_45], 
				[Hr19_60], [Hr20_15], [Hr20_30], [Hr20_45], [Hr20_60], [Hr21_15], [Hr21_30], [Hr21_45], [Hr21_60], 
				[Hr22_15], [Hr22_30], [Hr22_45], [Hr22_60], [Hr23_15], [Hr23_30], [Hr23_45], [Hr23_60], [Hr24_15], 
				[Hr24_30], [Hr24_45], [Hr24_60], [Hr25_15], [Hr25_30], [Hr25_45], [Hr25_60],
				[create_user], [create_ts])
			OUTPUT INSERTED.st_forecast_mins_id, ''mins'' [type] INTO #inserted_short_term_data
			SELECT sdv.value_id, t.term_start, 
				t.[Hr1_15], t.[Hr1_30], t.[Hr1_45], t.[Hr1_60], t.[Hr2_15], t.[Hr2_30], t.[Hr2_45], t.[Hr2_60], t.[Hr3_15], t.[Hr3_30], 
				t.[Hr3_45], t.[Hr3_60], t.[Hr4_15], t.[Hr4_30], t.[Hr4_45], t.[Hr4_60], t.[Hr5_15], t.[Hr5_30], t.[Hr5_45], t.[Hr5_60], 
				t.[Hr6_15], t.[Hr6_30], t.[Hr6_45], t.[Hr6_60], t.[Hr7_15], t.[Hr7_30], t.[Hr7_45], t.[Hr7_60], t.[Hr8_15], t.[Hr8_30], 
				t.[Hr8_45], t.[Hr8_60], t.[Hr9_15], t.[Hr9_30], t.[Hr9_45], t.[Hr9_60], t.[Hr10_15], t.[Hr10_30], t.[Hr10_45], 
				t.[Hr10_60], t.[Hr11_15], t.[Hr11_30], t.[Hr11_45], t.[Hr11_60], t.[Hr12_15], t.[Hr12_30], t.[Hr12_45], t.[Hr12_60], 
				t.[Hr13_15], t.[Hr13_30], t.[Hr13_45], t.[Hr13_60], t.[Hr14_15], t.[Hr14_30], t.[Hr14_45], t.[Hr14_60], t.[Hr15_15], 
				t.[Hr15_30], t.[Hr15_45], t.[Hr15_60], t.[Hr16_15], t.[Hr16_30], t.[Hr16_45], t.[Hr16_60], t.[Hr17_15], t.[Hr17_30], 
				t.[Hr17_45], t.[Hr17_60], t.[Hr18_15], t.[Hr18_30], t.[Hr18_45], t.[Hr18_60], t.[Hr19_15], t.[Hr19_30], t.[Hr19_45], 
				t.[Hr19_60], t.[Hr20_15], t.[Hr20_30], t.[Hr20_45], t.[Hr20_60], t.[Hr21_15], t.[Hr21_30], t.[Hr21_45], t.[Hr21_60], 
				t.[Hr22_15], t.[Hr22_30], t.[Hr22_45], t.[Hr22_60], t.[Hr23_15], t.[Hr23_30], t.[Hr23_45], t.[Hr23_60], t.[Hr24_15], 
				t.[Hr24_30], t.[Hr24_45], t.[Hr24_60], t.[Hr25_15], t.[Hr25_30], t.[Hr25_45], t.[Hr25_60], 
				''' + @user_login_id + ''' user_login_id, ''' + @as_of_date + ''' as_of_date 
			FROM #tmp_st_data_mins t
			INNER JOIN ' + @temp_log_table + ' l ON t.stage_st_header_log_id = l.stage_st_header_log_id
			INNER JOIN static_data_value sdv ON sdv.code = t.st_forecast_group_name			
			LEFT JOIN st_forecast_mins sfm ON sfm.st_forecast_group_id = sdv.value_id AND  sfm.[term_start] = t.[term_start]						
			WHERE sdv.type_id = 19600 AND l.error_code = ''0'' AND sfm.st_forecast_group_id IS NULL ')									
		
	IF EXISTS(SELECT 1 FROM #inserted_short_term_data)
	BEGIN
		
		INSERT INTO #imported_group(name)
		SELECT DISTINCT sdv.code from #inserted_short_term_data i
		INNER JOIN st_forecast_mins sfm ON sfm.st_forecast_mins_id = i.short_term_forecast_id
		INNER JOIN static_data_value sdv ON sdv.[value_id] = sfm.st_forecast_group_id
		LEFT JOIN #imported_group ig ON ig.name = sdv.code
		WHERE sdv.type_id = 19600 AND i.[type] = 'mins' AND ig.name IS NULL
		
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
				SELECT ''' + @process_id + ''', ''Success'', ''Import Data'', l.filename , ''ST Forecast'', 
				l.input_folder + '' Data Import: '' + CAST(COUNT(*) as VARCHAR(10)) + '' rows out of '' + CAST((COUNT(*) + ISNULL(prior_data_count, 0) ) AS VARCHAR(10)) + '' imported/updated successfully''
				FROM ' + @temp_table_name + ' t 
				INNER JOIN ' + @temp_log_table + ' l ON t.stage_st_header_log_id = l.stage_st_header_log_id
				LEFT JOIN (SELECT filename,sum(prior_data_count) prior_data_count from #ignored_st_data group by filename ) i ON i.[filename] = l.filename
				WHERE l.error_code = ''0'' AND l.input_folder = ''Power''
				GROUP BY l.input_folder, l.filename,i.prior_data_count
				')

		EXEC('INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description])
				SELECT ''' + @process_id + ''', l.filename , ''ST Forecast'', 
				CAST(COUNT(*) AS VARCHAR(10)) + '' rows imported/updated successfully. ST Forecast Group: '' + t.st_forecast_group_name 
				FROM ' + @temp_table_name + ' t 
				INNER JOIN ' + @temp_log_table + ' l ON t.stage_st_header_log_id = l.stage_st_header_log_id
				--INNER JOIN #tmp_st_data_hour s ON s.stage_st_header_log_id = t.stage_st_header_log_id
				WHERE l.error_code = ''0'' AND l.input_folder = ''Power''
				GROUP BY l.filename, t.st_forecast_group_name    
			')
		
				
	END
	
										
END

DECLARE @url_desc     VARCHAR(250)  
DECLARE @url          VARCHAR(250)  
DECLARE @error_count  INT        


IF @@ERROR <> 0
BEGIN
	INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)
	SELECT @process_id,
		   'Error',
		   'Import Data',
		   'Short Term Forecast Import', 
		   'Data Errors',
		   'It is possible that the Data may be incorrect',
		   'Correct the error and reimport.'
	SET @type = 'e'	   
END
ELSE
	SET @type = 's'
	
SET @url_desc = 'Detail...'        
SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''        
     
SELECT @error_count = COUNT(*)
FROM   source_system_data_import_status
WHERE  process_id = @process_id
	   AND code = 'Error'   
	   

IF @error_count > 0 OR @type = 'e'     
BEGIN        
	INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)        
	SELECT @process_id,
		   'Error',
		   'Import Data',
		   'Short Term Forecast Import', 
		   'Results',
		   'Import/Update Data completed with error(s).',
		   'Correct error(s) and reimport.'
	       
	SET @type = 'e'        
END   

	   
	SELECT @type [type]
	   
GO	   
