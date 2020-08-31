
/****** Object:  StoredProcedure [dbo].[spa_import_hourly_data]    Script Date: 02/23/2012 00:39:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_import_hourly_data]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_hourly_data]
GO

/****** Object:  StoredProcedure [dbo].[spa_import_hourly_data]    Script Date: 02/23/2012 00:39:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_import_hourly_data]	@temp_table_name VARCHAR(100),
	@table_id			VARCHAR(100),
	@job_name			VARCHAR(100),
	@process_id			VARCHAR(100),
	@user_login_id		VARCHAR(50), 
	@drilldown_level	INT = 1,
	@temp_header_table	VARCHAR(128) = NULL
AS
DECLARE @sql VARCHAR(MAX), @col VARCHAR(100)
DECLARE @url_desc     VARCHAR(250)  

CREATE TABLE [#tmp_staging_table] (
	[recorderid]		VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[channel]			VARCHAR(10) COLLATE DATABASE_DEFAULT,
	[DATE]				VARCHAR(20) COLLATE DATABASE_DEFAULT,
	[HOUR]				VARCHAR(5) COLLATE DATABASE_DEFAULT,
	[VALUE]				VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[h_filename]		VARCHAR(100) COLLATE DATABASE_DEFAULT NULL, 
	[h_error]			VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL, 
	[d_filename]		VARCHAR(100) COLLATE DATABASE_DEFAULT NULL, 
	[d_error]			VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
)
CREATE TABLE #tmp_missing_meter_id (meter_id VARCHAR(100) COLLATE DATABASE_DEFAULT)

BEGIN TRY	
	IF @drilldown_level = 1
	BEGIN
		EXEC ('INSERT INTO #tmp_staging_table([recorderid],[channel],[date],[hour],[value]) 
				SELECT [meter_id], ISNULL([channel],1), [dbo].[FNAClientToSqlDate]([date]), [hour], [value] 
				FROM ' + @temp_table_name)
	END
	
	ELSE IF @drilldown_level = 2
	BEGIN
		EXEC ('INSERT INTO #tmp_staging_table SELECT [meter_id], ISNULL([channel],1), [dbo].[FNAClientToSqlDate]([date]), [hour], [value], [h_filename], [h_error], [d_filename], [d_error] FROM ' + @temp_table_name)
	END	

	--SELECT SUBSTRING(hour, 1,CHARINDEX(':', hour)-1) FROM #tmp_staging_table WHERE hour LIKE '%:%'
	
	UPDATE t SET HOUR = SUBSTRING(HOUR, 1,CHARINDEX(':', HOUR)-1) FROM #tmp_staging_table t WHERE HOUR LIKE '%:%'
	
	DECLARE @type CHAR        

	SET @type = 's'
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
				 + '''Import Allocation Data(Hourly)''' + ',' 
				 + '''eBase Data Import(Hourly)''' + ',' 
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
	
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Allocation Data(Hourly)', @desc , @error_code, @job_name, 1
	
	RETURN
END CATCH 

CREATE TABLE #tmp_mv90_data_hour (
	[meter_id] INT,
	[channel] INT,
	[prod_date] DATETIME,
	[Hr1] FLOAT,
	[Hr2] FLOAT,
	[Hr3] FLOAT,
	[Hr4] FLOAT,
	[Hr5] FLOAT,
	[Hr6] FLOAT,
	[Hr7] FLOAT,
	[Hr8] FLOAT,
	[Hr9] FLOAT,
	[Hr10] FLOAT,
	[Hr11] FLOAT,
	[Hr12] FLOAT,
	[Hr13] FLOAT,
	[Hr14] FLOAT,
	[Hr15] FLOAT,
	[Hr16] FLOAT,
	[Hr17] FLOAT,
	[Hr18] FLOAT,
	[Hr19] FLOAT,
	[Hr20] FLOAT,
	[Hr21] FLOAT,
	[Hr22] FLOAT,
	[Hr23] FLOAT,
	[Hr24] FLOAT,
	[Hr25] FLOAT
)  
					
IF @drilldown_level = 1
BEGIN
	INSERT INTO [#tmp_mv90_data_hour]
	SELECT	[meter_id], [channel], [prod_date], 
			([1]) Hr1, ([2]) Hr2, ([3]) Hr3, ([4]) Hr4, ([5]) Hr5, ([6]) Hr6, 
			([7]) Hr7, ([8]) Hr8, ([9]) Hr9, ([10]) Hr10, ([11]) Hr11, ([12]) Hr12,
			([13]) Hr13, ([14]) Hr14, ([15]) Hr15, ([16]) Hr16, ([17]) Hr17, ([18]) Hr18, 
			([19]) Hr19, ([20]) Hr20, ([21]) Hr21, ([22]) Hr22, ([23]) Hr23, ([24]) Hr24, ([25]) Hr25
	FROM	(  
				SELECT	mi.[meter_id],
						tmp.[channel], 
						--CONVERT(DATETIME, tmp.[date], 103) [prod_date],
						tmp.[date] [prod_date],
						tmp.[hour],
						CASE 
							WHEN ( tmp.[date] = md.[date] AND CAST(tmp.[hour] AS INT) = md.[hour])
							THEN 0
							ELSE CAST(tmp.[value] AS FLOAT) 
						END [VALUE]
				FROM	#tmp_staging_table tmp
						INNER JOIN [meter_id] mi 
							ON mi.[recorderid] = tmp.[recorderId]
						LEFT JOIN [mv90_DST] md 
							--ON md.[year] = YEAR(CONVERT(DATETIME, tmp.[date], 103)) 
							ON md.[year] = YEAR( tmp.[date]) 
							AND md.[insert_delete] = 'd'				
			) p
	PIVOT(
			 SUM([VALUE]) FOR [HOUR] IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], 
										[10], [11], [12], [13], [14], [15], [16], 
										[17], [18], [19], [20], [21], [22], [23], 
										[24], [25])
		 ) pvt		
END
ELSE 
BEGIN
	INSERT INTO [#tmp_mv90_data_hour]
	SELECT	[meter_id], [channel], [prod_date], 
			([0]) Hr1, ([1]) Hr2, ([2]) Hr3, ([3]) Hr4, ([4]) Hr5, ([5]) Hr6, 
			([6]) Hr7, ([7]) Hr8, ([8]) Hr9, ([9]) Hr10, ([10]) Hr11, ([11]) Hr12,
			([12]) Hr13, ([13]) Hr14, ([14]) Hr15, ([15]) Hr16, ([16]) Hr17, ([17]) Hr18, 
			([18]) Hr19, ([19]) Hr20, ([20]) Hr21, ([21]) Hr22, ([22]) Hr23, ([23]) Hr24, ([24]) Hr25
	FROM	(  
				SELECT	mi.[meter_id],
						tmp.[channel], 
						--CONVERT(DATETIME, tmp.[date], 103) [prod_date],
						tmp.date [prod_date], 
						CAST(tmp.[hour] AS TINYINT) [HOUR],
						CASE 
							WHEN (tmp.[date] = md.[date] AND CAST(tmp.[hour] AS INT) + 1 = md.[hour])
							THEN 0
							ELSE CAST(tmp.[value] AS FLOAT) 
						END [VALUE]
				FROM	#tmp_staging_table tmp
						INNER JOIN [meter_id] mi 
							ON mi.[recorderid] = tmp.[recorderId]
						LEFT JOIN [mv90_DST] md 
							ON md.[year] = YEAR(tmp.[date]) 
							AND md.[insert_delete] = 'd'				
			) p
	PIVOT(
			 SUM([VALUE]) FOR [HOUR] IN ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], 
										[10], [11], [12], [13], [14], [15], [16], 
										[17], [18], [19], [20], [21], [22], [23], 
										[24])
		 ) pvt		
END

-- sum of the DST hours in the Hr3 = Hr3 + Hr25   
SELECT	@col = 'Hr' + CAST(md.hour AS VARCHAR) + ' = Hr' + CAST(md.hour AS VARCHAR) + ' + ISNULL(Hr25, 0)'
FROM	#tmp_mv90_data_hour tmp
		INNER JOIN mv90_DST md
		ON  md.date = tmp.prod_date
			AND md.insert_delete = 'i'

SET @sql = '
			UPDATE	tmp
			SET		' + @col + '
			FROM	#tmp_mv90_data_hour tmp
					INNER JOIN mv90_DST md
						ON  md.date = tmp.prod_date
						AND md.insert_delete = ''i''
			'
EXEC spa_print @sql
EXEC(@sql)

IF @drilldown_level = 1
BEGIN	 
	INSERT INTO #tmp_missing_meter_id (meter_id)
	SELECT	DISTINCT tmp.recorderid
	FROM	#tmp_staging_table tmp
			LEFT JOIN meter_id mi
				ON mi.recorderid = tmp.recorderid
	WHERE	mi.recorderid IS NULL	
END
-- insert data into mv90_data summary table
SELECT	a.meter_id,
		CONVERT(VARCHAR(7),a.[prod_date],120)+'-01' gen_date,
		CONVERT(VARCHAR(7),a.[prod_date],120)+'-01' from_date,
		DATEADD(MONTH,1,CONVERT(VARCHAR(7),a.[prod_date],120)+'-01')-1 to_date,
		a.channel,
		SUM(ISNULL(a.[Hr1],0) + ISNULL(a.[Hr2],0) + ISNULL(a.[Hr3],0) + ISNULL(a.[Hr4],0) + ISNULL(a.[Hr5],0) + ISNULL(a.[Hr6],0) + ISNULL(a.[Hr7],0) + ISNULL(a.[Hr8],0) + ISNULL(a.[Hr9],0) + ISNULL(a.[Hr10],0) + ISNULL(a.[Hr11],0) + ISNULL(a.[Hr12],0) + ISNULL(a.[Hr13],0) + ISNULL(a.[Hr14],0) + ISNULL(a.[Hr15],0) + ISNULL(a.[Hr16],0) + ISNULL(a.[Hr17],0) + ISNULL(a.[Hr18],0) + ISNULL(a.[Hr19],0) + ISNULL(a.[Hr20],0) + ISNULL(a.[Hr21],0) + ISNULL(a.[Hr22],0) + ISNULL(a.[Hr23],0) + ISNULL(a.[Hr24],0) ) volume
INTO	[#temp_summary]
FROM	[#tmp_mv90_data_hour] a
GROUP BY a.meter_id,a.channel,CONVERT(VARCHAR(7),a.[prod_date],120)+'-01',DATEADD(MONTH,1,CONVERT(VARCHAR(7),a.[prod_date],120)+'-01')-1	


-- Delete the Data if  exists
--DELETE	mdh
--FROM	[mv90_data_hour] mdh

--		INNER JOIN [mv90_data] md
--			ON  md.[meter_data_id] = mdh.[meter_data_id]
--		INNER JOIN [#tmp_mv90_data_hour] tf
--			ON  tf.[meter_id] = md.[meter_id]
--			AND md.[channel] = tf.[channel]
--			AND mdh.[prod_date] = tf.[prod_date]

--SELECT * FROM #deleted_mdh
--ALTER TABLE #deleted_mdh DROP COLUMN recid
            
--DELETE	md
--FROM	[mv90_data] md
--		INNER JOIN [#temp_summary] ts
--			ON md.[meter_id] = ts.[meter_id]
--			AND md.[channel] = ts.[channel]
--			AND [dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](ts.[from_date])

IF @drilldown_level = 1
BEGIN
	DELETE	mdh
		FROM	[mv90_data_hour] mdh		
				INNER JOIN [mv90_data] md
					ON  md.[meter_data_id] = mdh.[meter_data_id]
				INNER JOIN [#tmp_mv90_data_hour] tf
					ON  tf.[meter_id] = md.[meter_id]
					AND md.[channel] = tf.[channel]
					AND mdh.[prod_date] = tf.[prod_date]
	            
	DELETE	md
	FROM	[mv90_data] md
			INNER JOIN [#temp_summary] ts
				ON md.[meter_id] = ts.[meter_id]
				AND md.[channel] = ts.[channel]
				AND [dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](ts.[from_date])

	INSERT INTO [mv90_data] ( meter_id, gen_date, from_date, to_date,channel, volume,uom_id )
	SELECT	meter_id, gen_date, from_date, to_date, channel, volume, 0
	FROM	[#temp_summary]
END

IF @drilldown_level = 2
BEGIN
	-- insert if doesn't exists
	EXEC('INSERT INTO [mv90_data] ( meter_id, gen_date, from_date, to_date,channel, volume,uom_id )
		SELECT	t.meter_id, t.gen_date, t.from_date, t.to_date, t.channel, ABS(t.volume), su.source_uom_id
		FROM	[#temp_summary] t 
				INNER JOIN meter_id mi ON mi.meter_id = t.meter_id 
				INNER JOIN (
					SELECT DISTINCT meter_id, uom FROM ' + @temp_header_table + '
					UNION
					SELECT DISTINCT mi_sub.recorderid [meter_id], h_sub.uom [uom] 
					FROM ' + @temp_header_table + ' h_sub
							INNER JOIN meter_id mi ON mi.recorderid = h_sub.meter_id
							INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
							INNER JOIN #temp_summary ts ON ts.meter_id = mi_sub.meter_id
					WHERE ts.volume < 0	
				) h ON h.meter_id = mi.recorderid 
				INNER JOIN source_uom su ON su.uom_id = h.uom 
				LEFT JOIN mv90_data mv ON mv.meter_id = t.meter_id AND mv.from_date = t.from_date
		WHERE su.source_system_id = 2 
		AND mv.meter_id IS NULL ')

	UPDATE t SET t.Hr1 = ABS(t.Hr1), t.Hr2 = ABS(t.Hr2), t.Hr3 = ABS(t.Hr3), t.Hr4 = ABS(t.Hr4), t.Hr5 = ABS(t.Hr5), 
	   t.Hr6 = ABS(t.Hr6), t.Hr7 = ABS(t.Hr7), t.Hr8 = ABS(t.Hr8), t.Hr9 = ABS(t.Hr9), t.Hr10 = ABS(t.Hr10), 
	   t.Hr11 = ABS(t.Hr11), t.Hr12 = ABS(t.Hr12), t.Hr13 = ABS(t.Hr13), t.Hr14 = ABS(t.Hr14), t.Hr15 = ABS(t.Hr15), 
	   t.Hr16 = ABS(t.Hr16), t.Hr17 = ABS(t.Hr17), t.Hr18 = ABS(t.Hr18), t.Hr19 = ABS(t.Hr19), t.Hr20 = ABS(t.Hr20), 
	   t.Hr21 = ABS(t.Hr21), t.Hr22 = ABS(t.Hr22), t.Hr23 = ABS(t.Hr23), t.Hr24 = ABS(t.Hr24), t.Hr25 = ABS(t.Hr25) 
	FROM [#tmp_mv90_data_hour] t
		
	--update  values if already exists
	UPDATE mdh SET
		mdh.Hr1 = ISNULL(tmdh.Hr1, mdh.Hr1), mdh.Hr2 = ISNULL(tmdh.Hr2, mdh.Hr2), mdh.Hr3 = ISNULL(tmdh.Hr3, mdh.Hr3), 
		mdh.Hr4 = ISNULL(tmdh.Hr4, mdh.Hr4), mdh.Hr5 = ISNULL(tmdh.Hr5, mdh.Hr5), mdh.Hr6 = ISNULL(tmdh.Hr6, mdh.Hr6), 
		mdh.Hr7 = ISNULL(tmdh.Hr7, mdh.Hr7), mdh.Hr8 = ISNULL(tmdh.Hr8, mdh.Hr8), mdh.Hr9 = ISNULL(tmdh.Hr9, mdh.Hr9), 
		mdh.Hr10 = ISNULL(tmdh.Hr10, mdh.Hr10), mdh.Hr11 = ISNULL(tmdh.Hr11, mdh.Hr11), mdh.Hr12 = ISNULL(tmdh.Hr12, mdh.Hr12), 
		mdh.Hr13 = ISNULL(tmdh.Hr13, mdh.Hr13), mdh.Hr14 = ISNULL(tmdh.Hr14, mdh.Hr14), mdh.Hr15 = ISNULL(tmdh.Hr15, mdh.Hr15), 
		mdh.Hr16 = ISNULL(tmdh.Hr16, mdh.Hr16), mdh.Hr17 = ISNULL(tmdh.Hr17, mdh.Hr17), mdh.Hr18 = ISNULL(tmdh.Hr18, mdh.Hr18), 
		mdh.Hr19 = ISNULL(tmdh.Hr19, mdh.Hr19), mdh.Hr20 = ISNULL(tmdh.Hr20, mdh.Hr20), mdh.Hr21 = ISNULL(tmdh.Hr21, mdh.Hr21), 
		mdh.Hr22 = ISNULL(tmdh.Hr22, mdh.Hr22), mdh.Hr23 = ISNULL(tmdh.Hr23, mdh.Hr23), mdh.Hr24 = ISNULL(tmdh.Hr24, mdh.Hr24), 
		mdh.Hr25 = ISNULL(tmdh.Hr25, mdh.Hr25) 
	FROM [#tmp_mv90_data_hour]  tmdh
		INNER JOIN [mv90_data] md ON md.[meter_id] = tmdh.[meter_id] AND md.[from_date] = CONVERT(VARCHAR(7),tmdh.[prod_date],120)+'-01'
		INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
			AND tmdh.prod_date = mdh.prod_date

	--insert new data if not exists
	INSERT INTO [mv90_data_hour] ( [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [Hr25], [uom_id] )
	SELECT	md.[meter_data_id], tmdh.[prod_date], tmdh.[Hr1], tmdh.[Hr2], tmdh.[Hr3], tmdh.[Hr4], tmdh.[Hr5], tmdh.[Hr6], tmdh.[Hr7], tmdh.[Hr8], tmdh.[Hr9], tmdh.[Hr10], tmdh.[Hr11], tmdh.[Hr12], tmdh.[Hr13], tmdh.[Hr14], tmdh.[Hr15], tmdh.[Hr16], tmdh.[Hr17], tmdh.[Hr18], tmdh.[Hr19], tmdh.[Hr20], tmdh.[Hr21], tmdh.[Hr22], tmdh.[Hr23], tmdh.[Hr24], tmdh.[Hr25], md.[uom_id]
	FROM	[#tmp_mv90_data_hour] tmdh
			INNER JOIN [mv90_data] md
				ON md.[meter_id] = tmdh.[meter_id]
				AND md.[from_date] = CONVERT(VARCHAR(7),tmdh.[prod_date],120)+'-01'
			LEFT JOIN [mv90_data_hour] mdh ON mdh.meter_data_id = md.meter_data_id
				AND tmdh.prod_date = mdh.prod_date
	WHERE mdh.meter_data_id IS NULL
END
ELSE
BEGIN
	--insert new data
	INSERT INTO [mv90_data_hour] ( [meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [Hr25], [uom_id] )
	SELECT	md.[meter_data_id], [prod_date], [Hr1], [Hr2], [Hr3], [Hr4], [Hr5], [Hr6], [Hr7], [Hr8], [Hr9], [Hr10], [Hr11], [Hr12], [Hr13], [Hr14], [Hr15], [Hr16], [Hr17], [Hr18], [Hr19], [Hr20], [Hr21], [Hr22], [Hr23], [Hr24], [Hr25], md.[uom_id]
	FROM	[#tmp_mv90_data_hour] tmdh
			INNER JOIN [mv90_data] md
				ON md.[meter_id] = tmdh.[meter_id]
				AND md.[from_date] = CONVERT(VARCHAR(7),tmdh.[prod_date],120)+'-01'
				AND md.channel = tmdh.channel
END

IF @drilldown_level = 2
BEGIN
	-- update only vol if exists
	EXEC('UPDATE mv SET mv.volume = mdv.vol_sum  
	      FROM
			(
				SELECT SUM(ISNULL(mdh.Hr1,0) + ISNULL(mdh.Hr2,0) + ISNULL(mdh.Hr3,0) + ISNULL(mdh.Hr4,0) + ISNULL(mdh.Hr5,0) + ISNULL(mdh.Hr6,0) + 
					ISNULL(mdh.Hr7,0) + ISNULL(mdh.Hr8,0) + ISNULL(mdh.Hr9,0) + ISNULL(mdh.Hr10,0) + ISNULL(mdh.Hr11,0) + ISNULL(mdh.Hr12,0) + ISNULL(mdh.Hr13,0) + ISNULL(mdh.Hr14,0) + ISNULL(mdh.Hr15,0) + 
					ISNULL(mdh.Hr16,0) + ISNULL(mdh.Hr17,0) + ISNULL(mdh.Hr18,0) + ISNULL(mdh.Hr19,0) + ISNULL(mdh.Hr20,0) + ISNULL(mdh.Hr21,0) + ISNULL(mdh.Hr22,0) + 
					ISNULL(mdh.Hr23,0) + ISNULL(mdh.Hr24,0) ) vol_sum, meter_data_id
				FROM mv90_data_hour mdh GROUP BY mdh.meter_data_id
			) mdv
			INNER JOIN mv90_data mv ON mv.meter_data_id = mdv.meter_data_id
			INNER JOIN #temp_summary t ON t.meter_id = mv.meter_id
		   ')

---- logic to import aggregate_to_meter as defined in group_meter_mapping

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
		WHERE h.error_code = ''0'' AND md2.meter_id IS NULL AND gmm.aggregate_to_meter IS NOT NULL
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
			GROUP BY gmm2.aggregate_to_meter, mdh.prod_date
			--ORDER BY gmm2.aggregate_to_meter, prod_date
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
FROM (
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
GROUP BY gmm2.aggregate_to_meter, mdh.prod_date
')

--EXEC('
--	INSERT INTO mv90_data_hour(meter_data_id, prod_date, Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, Hr7, Hr8, Hr9, Hr10, Hr11, Hr12, Hr13, 
--										 Hr14, Hr15, Hr16, Hr17, Hr18, Hr19, Hr20, Hr21, Hr22, Hr23, Hr24, Hr25, uom_id)
--	  SELECT MAX(md_agg.meter_data_id) meter_data_id, mdh.prod_date,
--	  SUM(mdh.Hr1) agg_volume_hr1, SUM(mdh.Hr2) agg_volume_hr2, SUM(mdh.Hr3) agg_volume_hr3, SUM(mdh.Hr4) agg_volume_hr4, 
--	  SUM(mdh.Hr5) agg_volume_hr5, SUM(mdh.Hr6) agg_volume_hr6, SUM(mdh.Hr7) agg_volume_hr7, SUM(mdh.Hr8) agg_volume_hr8, 
--	  SUM(mdh.Hr9) agg_volume_hr9, SUM(mdh.Hr10) agg_volume_hr10, SUM(mdh.Hr11) agg_volume_hr11, SUM(mdh.Hr12) agg_volume_hr12, 
--	  SUM(mdh.Hr13) agg_volume_hr13, SUM(mdh.Hr14) agg_volume_hr14, SUM(mdh.Hr15) agg_volume_hr15, SUM(mdh.Hr16) agg_volume_hr16, 
--	  SUM(mdh.Hr17) agg_volume_hr17, SUM(mdh.Hr18) agg_volume_hr18, SUM(mdh.Hr19) agg_volume_hr19, SUM(mdh.Hr20) agg_volume_hr20, 
--	  SUM(mdh.Hr21) agg_volume_hr21, SUM(mdh.Hr22) agg_volume_hr22, SUM(mdh.Hr23) agg_volume_hr23, SUM(mdh.Hr24) agg_volume_hr24, 
--	  SUM(mdh.Hr25) agg_volume_hr25
--	  , MAX(md_agg.uom_id) uom_id

--FROM ' + @temp_header_table + ' h 
--INNER JOIN meter_id mi ON mi.recorderid = h.meter_id
--INNER JOIN group_meter_mapping gmm ON gmm.meter_id = mi.meter_id
--INNER JOIN group_meter_mapping gmm2 ON gmm2.aggregate_to_meter = gmm.aggregate_to_meter
--INNER JOIN mv90_data md ON md.meter_id = gmm2.meter_id
--INNER JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
--INNER JOIN mv90_data md_agg ON md_agg.meter_id = gmm.aggregate_to_meter
--	AND md_agg.from_date = md.from_date
--LEFT JOIN mv90_data_hour mdh_old ON mdh_old.meter_data_id = md_agg.meter_data_id
--	AND mdh_old.prod_date = mdh.prod_date
--WHERE h.error_code = ''0''
--	AND mdh_old.recid IS NULL
--GROUP BY gmm.aggregate_to_meter, mdh.prod_date

--')
END

IF @drilldown_level = 1
BEGIN
	IF @@ERROR <> 0
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps])
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   'Import Allocation Data(Hourly)',
			   'Data Errors',
			   'It is possible that the Data may be incorrect',
			   'Correct the error and reimport.'
	END

	-- check for data. if no data exists then give error  
	IF NOT EXISTS(SELECT DISTINCT meter_id FROM #tmp_mv90_data_hour)
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps])
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   'Import Allocation Data(Hourly)',
			   'Data Errors',
			   'It is possible that the file format may be incorrect',
			   'Correct the error and reimport.'
	END  

	--Check for errors        
	--DECLARE @url_desc     VARCHAR(250)  
	DECLARE @url          VARCHAR(250)  
	DECLARE @error_count  INT        
	SET @url_desc = 'Detail...'        
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_transactions_log ''' + @process_id + ''''        
	     
	SELECT @error_count = COUNT(*)
	FROM   Import_Transactions_Log
	WHERE  process_id = @process_id
		   AND code = 'Error'        
	
	IF EXISTS(SELECT * FROM #tmp_missing_meter_id)
	BEGIN
		SET @type = 'e'
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps])
		SELECT @process_id, 'Error', 'Import Data', 'Import Allocation Data(Hourly)', 'Data Error', 'Meter ID: ' + meter_id + ' not found in the system.', ''
		FROM #tmp_missing_meter_id 		
	END
	    
	IF @error_count > 0         
	BEGIN        
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps])        
		SELECT @process_id,
			   'Error',
			   'Import Transactions',
			   'Import Allocation Data(Hourly)',
			   'Results',
			   'Import/Update Data completed with error(s).',
			   'Correct error(s) and reimport.'
		       
		SET @type = 'e'        
	END        
	ELSE        
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [MODULE], [source], [TYPE], [description], [nextsteps])
		SELECT @process_id,
			   'Success',
			   'Import Data',
			   'Import Allocation Data(Hourly)',
			   'Results',
			   'Import/Update Data completed without error for  RecorderID: ' + 
			   recorderID + ', Channel: ' + CAST(channel AS VARCHAR) + 
			   ', Volume: ' + CAST(dbo.FNARemoveTrailingZero(SUM(CAST(CAST([VALUE] AS FLOAT) AS NUMERIC(38,20)))) AS VARCHAR(60)),
			   ''
		FROM   #tmp_staging_table
		GROUP BY
			   channel,
			   recorderid
	END
END	
ELSE
BEGIN
	IF @@ERROR <> 0
	BEGIN
		INSERT INTO source_system_data_import_status ([process_id], [code], [MODULE], [source], [TYPE], [description], recommendation)
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   --'Import Meter Data (Hourly)',
			   'eBase Data Import (Hourly)', 
			   'Data Errors',
			   'It is possible that the Data may be incorrect',
			   'Correct the error and reimport.'
		SET @type = 'e'	   
	END 
	ELSE
		SET @type = 's'

		-- check for data. if no data exists then give error  
		--IF NOT EXISTS(SELECT DISTINCT meter_id FROM #tmp_mv90_data_hour)
		--BEGIN
		--	INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)
		--	SELECT @process_id,
		--		   'Error',
		--		   'Import Data',
		--		   --'Import Meter Data (Hourly)',
		--		   'eBase Data Import', 
		--		   'Data Errors',
		--		   'It is possible that the file format may be incorrect',
		--		   'Correct the error and reimport.'
		--END  

		--Check for errors        
		
		SET @url_desc = 'Detail...'        
		SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''        
		     
		SELECT @error_count = COUNT(*)
		FROM   Import_Transactions_Log
		WHERE  process_id = @process_id
			   AND code = 'Error'        
		
		IF EXISTS(SELECT * FROM #tmp_missing_meter_id)
		BEGIN
			SET @type = 'e'
			--INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)
			--SELECT	@process_id, 
			--		'Error', 
			--		'Import Data', 
			--		--'Import Meter Data (Hourly)',
			--		'eBase Data Import',  
			--		'Data Error', 
			--		'Meter ID: ' + meter_id + ' not found in the system.', 
			--		''
			--FROM #tmp_missing_meter_id 
			
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
				'eBase Data Import (Hourly)',
				'Data Error',
				'Meter ID: ' + meter_id + ' not found in the system.', 
				''
			FROM #tmp_missing_meter_id				
		END
	

		--INSERT INTO source_system_data_import_status_detail
		--(
		--	-- status_id -- this column value is auto-generated,
		--	process_id,
		--	source,
		--	[type],
		--	[description],
		--	type_error
		--)
		--SELECT DISTINCT 
		--	@process_id,
		--	'eBase Data Import (Hourly)',
		--	'Data Error',
		--	'Data Error for Meter Id ' + recorderid + ': ' + h_error,
		--	h_error
		--FROM #tmp_staging_table
		--WHERE NULLIF(h_error, '') IS NOT NULL 
		
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
			'eBase Data Import (Hourly)',
			'Data Error',
			'Data Error for Meter Id ' + recorderid + ': ' + d_error,
			d_error
		FROM #tmp_staging_table
		WHERE NULLIF(d_error, '') IS NOT NULL 
			
		    
		IF @error_count > 0 OR @type = 'e'     
		BEGIN        
			INSERT INTO source_system_data_import_status ([process_id], [code], [MODULE], [source], [TYPE], [description], recommendation)        
			SELECT @process_id,
				   'Error',
				   'Import Transactions',
				   --'Import Meter Data (Hourly)',
				   'Hourly Data Import', 
				   'Results',
				   'Import/Update Data completed with error(s).',
				   'Correct error(s) and reimport.'
			       
			SET @type = 'e'        
		END        
		ELSE        
		BEGIN
			INSERT INTO source_system_data_import_status ([process_id], [code], [MODULE], [source], [TYPE], [description], recommendation)
			SELECT @process_id,
				   'Success',
				   'Import Data',
				   --'Import Meter Data(Hourly)',
				   'Hourly Data Import (' + h_filename + ')', 
				   'Results',
				   'Import/Update Data completed without error for  Meter ID: ' + 
				   recorderID + ', Channel: ' + CAST(channel AS VARCHAR) + 
				   ', Volume: ' + CAST(dbo.FNARemoveTrailingZero(SUM(CAST(CAST([VALUE] AS FLOAT) AS NUMERIC(38,20)))) AS VARCHAR(60)) +
				   ', Term: ' + CONVERT(VARCHAR(7),MIN(CONVERT(DATETIME,DATE,126)),120)+'-01',
				   ''
			FROM   #tmp_staging_table
			GROUP BY
				   channel,
				   recorderid,h_filename
		END
END	
		
EXEC spa_print 'aaa2'
--**********************************************************  
--------------------New Added to create deal based on mv90 data----------------------------------  
--**********************************************************  
DECLARE @tempTable               VARCHAR(128)  
DECLARE @sqlStmt                 VARCHAR(5000)  
DECLARE @strategy_name_for_mv90  VARCHAR(100)  
DECLARE @trader                  VARCHAR(100)  
DECLARE @default_uom             INT  

SET @strategy_name_for_mv90 = 'PPA'  
SET @trader = 'xcelgen'  
SET @default_uom = 24  
SET @user_login_id = @user_login_id
SET @process_id = REPLACE(NEWID(), '-', '_')  
SET @tempTable = dbo.FNAProcessTableName('deal_invoice', @user_login_id, @process_id)  

SET @sqlStmt = 'CREATE TABLE ' + @tempTable + ' (   
					[Book] [varchar] (255)  NULL ,        
					[Feeder_System_ID] [varchar] (255)  NULL ,        
					[Gen_Date_From] [varchar] (50)  NULL ,        
					[Gen_Date_To] [varchar] (50)  NULL ,        
					[Volume] [varchar] (255)  NULL ,        
					[UOM] [varchar] (50)  NULL ,        
					[Price] [varchar] (255)  NULL ,        
					[Formula] [varchar] (255)  NULL ,        
					[Counterparty] [varchar] (50)  NULL ,        
					[Generator] [varchar] (50)  NULL ,        
					[Deal_Type] [varchar] (10)  NULL ,        
					[Deal_Sub_Type] [varchar] (10)  NULL ,        
					[Trader] [varchar] (100)  NULL ,        
					[Broker] [varchar] (100)  NULL ,        
					[Rec_Index] [varchar] (255)  NULL ,        
					[Frequency] [varchar] (10)  NULL ,        
					[Deal_Date] [varchar] (50)  NULL ,        
					[Currency] [varchar] (255)  NULL ,        
					[Category] [varchar] (20)  NULL ,        
					[buy_sell_flag] [varchar] (10)  NULL,  
					[leg] [varchar] (20)  NULL  , 
					[settlement_volume] varchar(100),
					[settlement_uom] varchar(100)
				)'  
EXEC(@sqlStmt)  

SET @sqlStmt = 'INSERT INTO ' + @tempTable + ' (
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
				SELECT	MAX(s.[entity_name]) + ''_'' + ''' + @strategy_name_for_mv90 + ''' + ''_'' + MAX(sd1.[code]),
						''mv90_'' + CAST(rg.[generator_id] AS VARCHAR) + ''_'' + dbo.FNAContractMonthFormat(a.[from_date]),
						dbo.FNAGetSQLStandardDate(a.[from_date]),
						dbo.FNAGetSQLStandardDate(dbo.FNALastDayInDate(a.[from_date])),
						FLOOR(SUM(a.[volume]) * ISNULL(MAX(rg.[contract_allocation]), 1)),
						' + CAST(@default_uom AS VARCHAR) + ',
						NULL,
						MAX(rg.[ppa_counterparty_id]),
						rg.[generator_id],
						''Rec Energy'',
						''m'',
						''' + @trader + ''',
						a.[from_date],
						''USD'',
						''b'',
						1 ,
						SUM([settlement_volume]) * ISNULL(MAX(rg.[contract_allocation]), 1),
						MAX([uom_id])
				FROM	(
							SELECT	[meter_id], SUM([volume] * conv.[conversion_factor]) AS [volume], MAX(uom_id) AS [uom_id], SUM([volume]) AS [settlement_volume], MAX([from_date]) [from_date]
							FROM	(
										SELECT	mv.[meter_id],  
												(mv.[volume] - (COALESCE(meter.[gre_per], meter1.[gre_per], 0)) * mv.[volume]) * [mult_factor] AS [volume],  
												mv.[channel],  
												[mult_factor],  
												md.[uom_id],  
												CONVERT(VARCHAR(7),mv.[from_date],120)+''-01''  [from_date]
  										FROM	[#temp_summary] mv
	      										INNER JOIN ( SELECT [meter_id] FROM [recorder_generator_map] GROUP BY [meter_id] HAVING COUNT(DISTINCT [generator_id]) = 1) a
	      											ON mv.[meter_id] = a.[meter_id] 
	      										INNER JOIN [recorder_properties] md 
	      											ON mv.[meter_id] = md.[meter_id] 
	      											AND md.[channel] = mv.[channel]
	      										LEFT JOIN [meter_id_allocation] meter 
	      											ON meter.[meter_id] = mv.[meter_id]
	      											AND meter.[production_month] = mv.[from_date]
	      										LEFT JOIN [meter_id_allocation] meter1 
	      											ON meter1.[meter_id] = mv.[meter_id]
  										WHERE	mv.[volume] > 0
  									) a 
  									INNER JOIN [rec_volume_unit_conversion] conv 
  										ON a.[uom_id] = conv.[from_source_uom_id]
  										AND conv.[to_source_uom_id] = ' + CAST(@default_uom AS VARCHAR) + '
  										AND conv.[state_value_id] IS NULL 
  										AND conv.[assignment_type_value_id] IS NULL
  										AND conv.[curve_id] IS NULL
  								GROUP BY [meter_id]
  						) a
  						INNER JOIN [recorder_generator_map] rgm
  							ON rgm.[meter_id] = a.[meter_id]
  						INNER JOIN [rec_generator] rg 
  							ON rg.[generator_id] = rgm.[generator_id]
  						INNER JOIN [static_data_value] sd 
  							ON rg.[state_value_id] = sd.[value_id]
  						INNER JOIN [portfolio_hierarchy] s 
  							ON s.[entity_id] = rg.[legal_entity_value_id]
  						LEFT JOIN static_data_value sd1 
  							ON sd1.[value_id] = rg.[state_value_id]
				GROUP BY rg.[generator_id], a.[from_date]   
'   
EXEC(@sqlStmt)  
--EXEC spb_process_transactions @user_login_id, @tempTable, 'n', 'y'  
     
DECLARE @total_count    INT,
		@total_count_v  VARCHAR(50)   

SET @total_count = 0        
SELECT @total_count = COUNT(*) FROM [#tmp_staging_table]        

SET @total_count_v = CAST(ISNULL(@total_count, 0) AS VARCHAR) 

IF @drilldown_level = 1 
BEGIN
	SET @url_desc = '<a target="_blank" href="' + @url + '">' +
					'Allocation data import process completed on as of date ' 
					+ dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
					+ CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END 
					+ '.</a>'        

	EXEC spa_message_board 'i', @user_login_id, NULL, ' Import Allocation Data(Hourly)', @url_desc, '', '', @type, @job_name  		
END
ELSE
BEGIN
	--SET @url_desc = '<a target="_blank" href="' + @url + '">' +
	--				'Meter data import process completed on as of date ' 
	--				+ dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
	--				+ CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END 
	--				+ '.</a>'        

	--EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @url_desc, '', '', @type, @job_name	
	
	SELECT @type [TYPE]	
END
/************************************* Object: 'spa_import_hourly_data' END *************************************/

GO

