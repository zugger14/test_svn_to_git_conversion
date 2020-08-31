


/****** Object:  StoredProcedure [dbo].[spa_import_monthly_data]    Script Date: 02/22/2012 23:59:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_monthly_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_monthly_data]
GO


/****** Object:  StoredProcedure [dbo].[spa_import_monthly_data]    Script Date: 02/22/2012 23:59:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_import_monthly_data]
	@temp_table_name VARCHAR(100),
	@table_id VARCHAR(100),
	@job_name VARCHAR(100),
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50), 
	@drilldown_level INT = 1,
	@temp_header_table VARCHAR(128) = NULL
	  
AS

DECLARE @sql VARCHAR(MAX), @col VARCHAR(100)


CREATE TABLE [#tmp_staging_table]
(
	[recorderid] VARCHAR(100) COLLATE DATABASE_DEFAULT ,
	[channel] VARCHAR(10) COLLATE DATABASE_DEFAULT ,
	[date] VARCHAR(10) COLLATE DATABASE_DEFAULT ,
	[hour] VARCHAR(5) COLLATE DATABASE_DEFAULT ,
	[value] NUMERIC(38,20),
	[h_filename] [varchar](100) COLLATE DATABASE_DEFAULT  NULL, 
	[h_error] [varchar](1000) COLLATE DATABASE_DEFAULT  NULL, 
	[d_filename] [varchar](100) COLLATE DATABASE_DEFAULT  NULL, 
	[d_error] [varchar](1000) COLLATE DATABASE_DEFAULT  NULL
)
--CREATE  TABLE #tmp_missing_meter_id (meter_id VARCHAR(100) COLLATE DATABASE_DEFAULT )


IF @drilldown_level = 1
BEGIN
	EXEC ('INSERT INTO #tmp_staging_table SELECT [meter_id],ISNULL([channel],1), [date], [hour], [value] FROM ' + @temp_table_name)
END
ELSE IF @drilldown_level = 2
BEGIN
	EXEC ('INSERT INTO #tmp_staging_table SELECT [meter_id],ISNULL([channel],1), [date], [hour], [value], [h_filename], [h_error], [d_filename], [d_error] FROM ' + @temp_table_name) --   ' WHERE NULLIF(h_error, '''') IS NULL' )
	
END

-- insert data into mv90_data summary table
	SELECT	a.recorderid,
			dbo.FNAGETContractmonth(a.date) gen_date,
			dbo.FNAGETContractmonth(a.date) from_date,
			DATEADD(MONTH,1,dbo.FNAGETContractmonth(a.date))-1 to_date,
			a.channel,
			SUM(value) volume
	INTO	[#temp_summary]
	FROM	[#tmp_staging_table] a
	GROUP BY a.recorderid,a.channel,dbo.FNAGETContractmonth(a.date),DATEADD(MONTH,1,dbo.FNAGETContractmonth(a.date))-1	

	-- Delete the Data if  exists
	DELETE	md
	FROM	[mv90_data] md
			INNER JOIN meter_id mi ON mi.meter_id = md.meter_id
			INNER JOIN [#temp_summary] ts
				ON mi.recorderid = ts.recorderid  --ON md.[meter_id] = mi.meter_id --ts.[recorderid]
				AND md.[channel] = ts.[channel]
				AND [dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](ts.[from_date])

	CREATE TABLE #inserted_monthly_data (meter_id INT)

	EXEC('INSERT INTO [mv90_data] ( meter_id, gen_date, from_date, to_date,channel, volume,uom_id )
	OUTPUT inserted.meter_id INTO #inserted_monthly_data
	SELECT	mi.meter_id, ts.gen_date, ts.from_date, ts.to_date, ts.channel, ABS(ts.volume), su.source_uom_id
	FROM	[#temp_summary] ts 
	INNER JOIN meter_id mi ON mi.recorderid = ts.recorderid
	INNER JOIN (
		SELECT DISTINCT meter_id, uom FROM ' + @temp_header_table + '
		UNION
		SELECT DISTINCT mi_sub.recorderid [meter_id], h_sub.uom [uom] FROM ' + @temp_header_table + ' h_sub
		INNER JOIN meter_id mi ON mi.recorderid = h_sub.meter_id
		INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
		INNER JOIN #temp_summary ts ON ts.recorderid = mi_sub.recorderid
		WHERE ts.volume < 0		
		       
	) h ON h.meter_id = mi.recorderid 
	INNER JOIN source_uom su ON su.uom_id = h.uom 
	WHERE su.source_system_id = 2  
	')
	 
	 

---############### logic to import aggregate_to_meter as defined in group_meter_mapping


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

	 
 
 
 
DECLARE @type         CHAR        
SET @type = 's'


IF @drilldown_level = 1
BEGIN
	
	IF @@ERROR <> 0
	BEGIN
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   'Import Allocation Data(Hourly)',
			   'Data Errors',
			   'It is possible that the Data may be incorrect',
			   'Correct the error and reimport.'
	END


	--Check for errors        
	DECLARE @url_desc     VARCHAR(250)  
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
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id, 'Error', 'Import Data', 'Import Allocation Data(Hourly)', 'Data Error', 'Meter ID: ' + meter_id + ' not found in the system.', ''
		FROM #tmp_missing_meter_id 
		
	END
	    
	IF @error_count > 0         
	BEGIN        
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])        
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
		INSERT INTO [Import_Transactions_Log] ([process_id], [code], [module], [source], [type], [description], [nextsteps])
		SELECT @process_id,
			   'Success',
			   'Import Data',
			   'Import Allocation Data(Hourly)',
			   'Results',
			   'Import/Update Data completed without error for  RecorderID: ' + 
			   recorderID + ', Channel: ' + CAST(channel AS VARCHAR) + 
			   ', Volume: ' + CAST(dbo.FNARemoveTrailingZero(SUM(CAST(CAST([value] AS FLOAT) AS NUMERIC(38,20)))) AS VARCHAR(60)),
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
		INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)
		SELECT @process_id,
			   'Error',
			   'Import Data',
			   --'Import Meter Data (Monthly)',
			   'eBase Data Import (Monthly)', 
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
	--	'eBase Data Import (Monthly)',
	--	'Data Error',
	--	'Data Error for Meter Id ' + recorderid + ': ' + h_error,
	--	h_error
	--FROM #tmp_staging_table
	--WHERE NULLIF(h_error, '') IS NOT NULL 
	
	
	-- insert detail error if any
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
		'eBase Data Import (Monthly)',
		'Data Error',
		'Data Error for Meter Id ' + recorderid + ': ' + d_error,
		d_error
	FROM #tmp_staging_table
	WHERE NULLIF(d_error, '') IS NOT NULL 	
	    
	IF @error_count > 0 OR @type = 'e'     
	BEGIN        
		INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)        
		SELECT @process_id,
			   'Error',
			   'Import Transactions',
			   --'Import Meter Data (Monthly)',
			   'eBase Data Import (Monthly)', 
			   'Results',
			   'Import/Update Data completed with error(s).',
			   'Correct error(s) and reimport.'
		       
		SET @type = 'e'        
	END        
	
	IF EXISTS(SELECT 1 FROM #inserted_monthly_data)
	BEGIN
		INSERT INTO source_system_data_import_status ([process_id], [code], [module], [source], [type], [description], recommendation)
		SELECT @process_id,
			   'Success',
			   'Import Data',
			   --'Import Meter Data (Monthly)',
			   'Monthly Data Import (' + h_filename + ')', 
			   'Results',
			   'Import/Update Data completed without error for Meter ID: ' + 
			   recorderID + ', Channel: ' + CAST(channel AS VARCHAR) + 
			   ', Volume: ' + CAST(dbo.FNARemoveTrailingZero(SUM(CAST(CAST([value] AS FLOAT) AS NUMERIC(38,20)))) AS VARCHAR(60)) +
			   ', Term: ' + CONVERT(VARCHAR(7),MIN(CONVERT(datetime,date,126)),120)+'-01',
			   ''
		FROM   #tmp_staging_table
		GROUP BY
			   channel,
			   recorderid, h_filename, date
	END
END 



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

	EXEC spa_message_board 'i', @user_login_id, NULL, ' Import Allocation Data(Monthly)', @url_desc, '', '', @type, @job_name  
END
ELSE
BEGIN
	--SET @url_desc = '<a target="_blank" href="' + @url + '">' +
	--				'Meter data import process completed on as of date ' 
	--				+ dbo.FNAUserDateFormat(GETDATE(), @user_login_id) 
	--				+ CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END 
	--				+ '.</a>'        

	--EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @url_desc, '', '', @type, @job_name  
	
	SELECT @type [type]
END

GO


